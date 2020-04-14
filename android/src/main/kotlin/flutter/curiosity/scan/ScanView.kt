package flutter.curiosity.scan

import android.content.Context
import android.graphics.ImageFormat
import android.graphics.Rect
import android.view.View
import androidx.camera.camera2.Camera2Config
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import com.google.common.util.concurrent.ListenableFuture
import com.google.zxing.*
import com.google.zxing.common.HybridBinarizer
import flutter.curiosity.CuriosityPlugin.Companion.scanView
import flutter.curiosity.camera.preview.PreviewView
import flutter.curiosity.utils.Utils
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView
import java.util.concurrent.Executor
import java.util.concurrent.Executors

class ScanView internal constructor(private val context: Context, messenger: BinaryMessenger, i: Int, any: Any) :
        PlatformView, LifecycleOwner, CameraXConfig.Provider, EventChannel.StreamHandler,
        MethodCallHandler {
    private lateinit var lifecycleRegistry: LifecycleRegistry
    private lateinit var previewView: PreviewView
    private var isScan: Boolean
    private lateinit var eventSink: EventSink
    private var lastCurrentTime = 0L //最后一次的扫描
    private lateinit var cameraProviderFuture: ListenableFuture<ProcessCameraProvider>
    private lateinit var cameraProvider: ProcessCameraProvider
    private lateinit var cameraControl: CameraControl
    private lateinit var cameraInfo: CameraInfo
    private var multiFormatReader: MultiFormatReader = MultiFormatReader()
    private val executor: Executor = Executors.newSingleThreadExecutor()
    private val anyMap = any as Map<*, *>
    private val topRatio: Int
    private val leftRatio: Int
    private val widthRatio: Int
    private val heightRatio: Int

    init {
        isScan = (anyMap["isScan"] as Boolean?)!!
        topRatio = anyMap["topRatio"] as Int
        leftRatio = anyMap["leftRatio"] as Int
        widthRatio = anyMap["widthRatio"] as Int
        heightRatio = anyMap["heightRatio"] as Int
        EventChannel(messenger, "$scanView/$i/event").setStreamHandler(this)
        MethodChannel(messenger, "$scanView/$i/method").setMethodCallHandler(this)
        multiFormatReader.setHints(ScanUtils.hints)
        initCameraView()
    }

    override fun getView(): View {
        if (lifecycleRegistry.currentState != Lifecycle.State.RESUMED) {
            lifecycleRegistry.currentState = Lifecycle.State.RESUMED
        }
        return previewView
    }

    private fun initCameraView() {
        cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        lifecycleRegistry = LifecycleRegistry(this)
        previewView = PreviewView(context)
        val preview = Preview.Builder()
                .setTargetAspectRatio(AspectRatio.RATIO_4_3)
                .build()
        preview.setSurfaceProvider(previewView.previewSurfaceProvider)
        val imageAnalysis = ImageAnalysis.Builder().apply {
            setImageQueueDepth(ImageAnalysis.STRATEGY_BLOCK_PRODUCER)
        }.build()
        imageAnalysis.setAnalyzer(executor, ScanImageAnalysis())
        previewView.post { startCamera(context, preview, imageAnalysis) }
    }

    private fun startCamera(context: Context, preview: Preview, imageAnalysis: ImageAnalysis) {
        val cameraSelector = CameraSelector.Builder().requireLensFacing(CameraSelector.LENS_FACING_BACK).build()
        cameraProviderFuture.addListener(Runnable {
            cameraProvider = cameraProviderFuture.get()
            val camera = cameraProvider.bindToLifecycle(this, cameraSelector, preview,
                    imageAnalysis)
            cameraControl = camera.cameraControl
            cameraInfo = camera.cameraInfo

        }, ContextCompat.getMainExecutor(context))
    }

    override fun getCameraXConfig(): CameraXConfig {
        return Camera2Config.defaultConfig()
    }

    private inner class ScanImageAnalysis : ImageAnalysis.Analyzer {
        override fun analyze(image: ImageProxy) {
            val currentTime = System.currentTimeMillis()
            if (currentTime - lastCurrentTime >= 100L && isScan == java.lang.Boolean.TRUE) {
                if (ImageFormat.YUV_420_888 != image.format) {
                    return
                }
                val buffer = image.planes[0].buffer
                val byteArray = ByteArray(buffer.remaining())
                buffer[byteArray, 0, byteArray.size]
                val height = image.height
                val width = image.width
                val source = buildLuminanceSource(byteArray, width, height);
                val binaryBitmap = BinaryBitmap(HybridBinarizer(source))
                var result: Result? = null
                try {
                    result = multiFormatReader.decodeWithState(binaryBitmap)
                } catch (e: NotFoundException) {

                } finally {
                    multiFormatReader.reset()
                }
                if (result == null) {
                    val invertedSource = source?.invert()
                    val invertBinaryBitmap = BinaryBitmap(HybridBinarizer(invertedSource))
                    try {
                        result = multiFormatReader.decodeWithState(invertBinaryBitmap)
                    } catch (e: NotFoundException) {
                        // continue
                    } finally {
                        multiFormatReader.reset()
                    }
                }
                if (result != null) {
                    resultCode(result)
                }
                buffer.clear()
                lastCurrentTime = currentTime
            }
            image.close()
        }
    }

    fun resultCode(result: Result) {
        previewView.post { eventSink.success(ScanUtils.scanDataToMap(result)) }
    }

    fun buildLuminanceSource(byteArray: ByteArray, width: Int, height: Int): PlanarYUVLuminanceSource? {
//        Utils.logInfo("图像宽高")
//        Utils.logInfo(width.toString())
//        Utils.logInfo(height.toString())
//        Utils.logInfo("可识别区宽高度")
//        Utils.logInfo((width / 10 * widthRatio).toString())
//        Utils.logInfo((height / 10 * heightRatio).toString())
//        Utils.logInfo("距离头部和左边的距离")
//        Utils.logInfo((width / 10 * leftRatio).toString())
//        Utils.logInfo((height / 10 * topRatio).toString())
        return PlanarYUVLuminanceSource(byteArray,
                width, height, (width / 10 * leftRatio), ((height / 10 * topRatio)), (width / 10 * widthRatio),
                (height / 10 * heightRatio), false)
//        val rect: Rect = getFramingRectInPreview(width, height)
//        return PlanarYUVLuminanceSource(byteArray, width, height, rect.left, rect.top,
//                rect.width(), rect.height(), false)
    }

    override fun onCancel(any: Any) {
    }

    private fun getFramingRectInPreview(previewWidth: Int, previewHeight: Int): Rect {
        val rect = Rect()
        val rectViewWidth = (previewWidth / 10 * leftRatio)
        val rectViewHeight = (previewHeight / 10 * leftRatio)
        Utils.logInfo(previewWidth.toString())
        Utils.logInfo(previewHeight.toString())

        Utils.logInfo(rectViewWidth.toString())
        Utils.logInfo(rectViewHeight.toString())

        if (rectViewWidth < previewWidth) {
//            rect.left = rect.left * previewWidth / rectViewWidth;
//            rect.right = rect.right * previewWidth / rectViewWidth;
            rect.left = previewWidth / 10
            rect.right = previewWidth / 10
        }
        if (rectViewHeight < previewHeight) {
//            rect.top = rect.top * previewHeight / rectViewHeight;
//            rect.bottom = rect.bottom * previewHeight / rectViewHeight;
            rect.top = previewHeight / 10;
            rect.bottom = previewHeight / 10;
        }

        Utils.logInfo(rect.left.toString());
        Utils.logInfo(rect.right.toString());
        Utils.logInfo(rect.width().toString());
        Utils.logInfo(rect.height().toString());
        return rect

    }

    override fun getLifecycle(): Lifecycle {
        return lifecycleRegistry
    }

    override fun dispose() {
        lifecycleRegistry.currentState = Lifecycle.State.DESTROYED
        cameraProvider.unbindAll()
    }

    override fun onListen(o: Any, eventSink: EventSink) {
        this.eventSink = eventSink
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "startScan" -> isScan = true
            "stopScan" -> isScan = false
            "setFlashMode" -> {
                val status = methodCall.argument<Boolean>("status")
                if (status != null) {
                    cameraControl.enableTorch(status)
                }
            }
            "getFlashMode" -> result.success(cameraInfo.torchState)
            else -> result.notImplemented()
        }
    }


}

