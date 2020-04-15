package flutter.curiosity.scan

import android.content.Context
import android.content.res.Configuration
import android.graphics.ImageFormat
import android.graphics.Point
import android.graphics.Rect
import android.view.Display
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
import flutter.curiosity.CuriosityPlugin.Companion.activity
import flutter.curiosity.CuriosityPlugin.Companion.scanView
import flutter.curiosity.camera.preview.PreviewView
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
                .setTargetAspectRatio(AspectRatio.RATIO_16_9)
                .build()
        preview.setSurfaceProvider(previewView.previewSurfaceProvider)
        val imageAnalysis = ImageAnalysis.Builder().apply {
            setImageQueueDepth(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
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
                val rect = image.cropRect
                val buffer = image.planes[0].buffer
                val byteArray = ByteArray(buffer.remaining())
                buffer[byteArray, 0, byteArray.size]
                val source = buildLuminanceSource(byteArray, rect)
                val binaryBitmap = BinaryBitmap(HybridBinarizer(source))
                var result: Result? = null
                try {
                    result = multiFormatReader.decodeWithState(binaryBitmap)
                } catch (e: NotFoundException) {
                    // continue
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
                if (result != null) resultCode(result)
                buffer.clear()
                lastCurrentTime = currentTime
            }
            image.close()
        }
    }

    fun resultCode(result: Result) {
        previewView.post { eventSink.success(ScanUtils.scanDataToMap(result)) }
    }

    fun buildLuminanceSource(byteArray: ByteArray, rect: Rect): PlanarYUVLuminanceSource? {
        val newRect = getRectInPreview(rect);
        return PlanarYUVLuminanceSource(byteArray, newRect.width(), newRect.height(), newRect.left, newRect.top,
                newRect.width(), newRect.height(), false)
    }

    override fun onCancel(any: Any) {
    }

    private fun getRectInPreview(rect: Rect): Rect {
        return rect
//        val rect = Rect()
//        Utils.logInfo("比例")
//        Utils.logInfo(rect.width().toString())
//        Utils.logInfo(rect.height().toString())
//        Utils.logInfo("left$leftRatio==top$topRatio==width${widthRatio}==height${heightRatio}")
//        Utils.logInfo("rectLeft${rect.width() / 10 * leftRatio}==rectTop${rect.height() / 10 * topRatio}")
//        Utils.logInfo("rectWidth${rect.width() / 10 * widthRatio}==rectHeight${rect.height() / 10 * heightRatio}")
//        return newRect

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

    fun getScreenOrientation(): Int {
        val defaultDisplay: Display = activity.windowManager.defaultDisplay
        val point = Point()
        defaultDisplay.getSize(point)
        var orientation = Configuration.ORIENTATION_UNDEFINED
        if (point.x != point.y) {
            if (point.x < point.y) {
                orientation = Configuration.ORIENTATION_PORTRAIT
            } else {
                orientation = Configuration.ORIENTATION_LANDSCAPE
            }
        }
        return orientation
    }


}


