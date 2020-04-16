package flutter.curiosity.scan

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.ImageFormat
import android.graphics.Rect
import android.view.View
import android.widget.FrameLayout
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
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView
import java.util.concurrent.Executor
import java.util.concurrent.Executors

@SuppressLint("ViewConstructor")
class ScanView internal constructor(context: Context, messenger: BinaryMessenger, i: Int, any: Any) :
        PlatformView, LifecycleOwner, CameraXConfig.Provider, EventChannel.StreamHandler,
        MethodCallHandler, FrameLayout(context) {
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
//    private var mViewFinderView: ViewFinderView? = null

    init {
        isScan = (anyMap["isScan"] as Boolean?)!!
        topRatio = anyMap["topRatio"] as Int
        leftRatio = anyMap["leftRatio"] as Int
        widthRatio = anyMap["widthRatio"] as Int
        heightRatio = anyMap["heightRatio"] as Int
        EventChannel(messenger, "$scanView/$i/event").setStreamHandler(this)
        MethodChannel(messenger, "$scanView/$i/method").setMethodCallHandler(this)
        multiFormatReader.setHints(ScanUtils.hints)
//        initLayout()
        initCameraView()
    }

    private fun initLayout() {
        initCameraView()
//        mViewFinderView = ViewFinderView(context)
//        addView(previewView)
//        addView(mViewFinderView)
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

    override fun onCancel(any: Any) {
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

    private fun buildLuminanceSource(byteArray: ByteArray, rect: Rect): PlanarYUVLuminanceSource? {
        val newRect = getRectInPreview(rect);
        return PlanarYUVLuminanceSource(byteArray, newRect.width(), newRect.height(), newRect.left, newRect.top,
                newRect.width(), newRect.height(), false)
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

    @Synchronized
    fun getRectInPreview(rect: Rect): Rect {
        return rect
//        val previewWidth = rect.width()
//        val previewHeight = rect.height()
//        val framingRect = mViewFinderView!!.framingRect
//        val viewFinderViewWidth = mViewFinderView!!.width
//        val viewFinderViewHeight = mViewFinderView!!.height
//        if (framingRect == null || viewFinderViewWidth == 0 || viewFinderViewHeight == 0) {
//            return rect
//        }
//        val newRect = Rect(rect)
//        if (previewWidth < viewFinderViewWidth) {
//            newRect.left = rect.left * previewWidth / viewFinderViewWidth
//            newRect.right = rect.right * previewWidth / viewFinderViewWidth
//        }
//        if (previewHeight < viewFinderViewHeight) {
//            newRect.top = rect.top * previewHeight / viewFinderViewHeight
//            newRect.bottom = rect.bottom * previewHeight / viewFinderViewHeight
//        }
//
//        Utils.logInfo(viewFinderViewWidth.toString())
//        Utils.logInfo(viewFinderViewHeight.toString())
//        Utils.logInfo(newRect.left.toString())
//        Utils.logInfo(newRect.top.toString())
//        Utils.logInfo(newRect.width().toString())
//        Utils.logInfo(newRect.height().toString())
//        return rect
    }

}



