package flutter.curiosity.scan

import android.content.Context
import android.graphics.ImageFormat
import android.util.Size
import android.view.View
import androidx.camera.camera2.Camera2Config
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import com.google.common.util.concurrent.ListenableFuture
import com.google.zxing.BinaryBitmap
import com.google.zxing.MultiFormatReader
import com.google.zxing.NotFoundException
import com.google.zxing.PlanarYUVLuminanceSource
import com.google.zxing.common.HybridBinarizer
import flutter.curiosity.CuriosityPlugin.Companion.scanView
import flutter.curiosity.camera.preview.PreviewView
import flutter.curiosity.utils.NativeUtils
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
    private var isPlay: Boolean
    private lateinit var eventSink: EventSink
    private var lastCurrentTime = 0L //最后一次的扫描
    private lateinit var cameraProviderFuture: ListenableFuture<ProcessCameraProvider>
    private lateinit var cameraProvider: ProcessCameraProvider
    private lateinit var cameraControl: CameraControl
    private lateinit var cameraInfo: CameraInfo
    private var multiFormatReader: MultiFormatReader = MultiFormatReader()
    private val executor: Executor = Executors.newSingleThreadExecutor()
    private val anyMap = any as Map<*, *>
    private val topRatio: Double
    private val leftRatio: Double
    private val widthRatio: Double
    private val heightRatio: Double

    init {
        isPlay = (anyMap["isPlay"] as Boolean?)!!
        topRatio = anyMap["topRatio"] as Double
        leftRatio = anyMap["leftRatio"] as Double
        widthRatio = anyMap["widthRatio"] as Double
        heightRatio = anyMap["heightRatio"] as Double
        EventChannel(messenger, scanView + "_" + i + "/event").setStreamHandler(this)
        MethodChannel(messenger, scanView + "_" + i + "/method").setMethodCallHandler(this)

        initCameraView()
    }

    override fun getView(): View {
        if (lifecycleRegistry.currentState != Lifecycle.State.RESUMED) {
            lifecycleRegistry.currentState = Lifecycle.State.RESUMED
        }
        return previewView
    }

    private fun initCameraView() {
        val width = anyMap["width"] as Int
        val height = anyMap["height"] as Int
        cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        lifecycleRegistry = LifecycleRegistry(this)
        previewView = PreviewView(context)
        val preview = Preview.Builder()
                .setTargetAspectRatio(AspectRatio.RATIO_16_9)
                .build()
        preview.setSurfaceProvider(previewView.previewSurfaceProvider)
        val imageAnalysis = ImageAnalysis.Builder().apply {
            setImageQueueDepth(ImageAnalysis.STRATEGY_BLOCK_PRODUCER)
            setTargetResolution(Size(width, height))
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
            if (currentTime - lastCurrentTime >= 100L && isPlay == java.lang.Boolean.TRUE) {
                if (ImageFormat.YUV_420_888 != image.format) {
                    return
                }
                val buffer = image.planes[0].buffer
                val byteArray = ByteArray(buffer.remaining())
                buffer[byteArray, 0, byteArray.size]
                val height = image.height
                val width = image.width
                val binaryBitmap = BinaryBitmap(HybridBinarizer(PlanarYUVLuminanceSource(byteArray,
                        width, height, (width * leftRatio).toInt(), ((height * topRatio).toInt()), (width * widthRatio).toInt(),
                        (height * heightRatio).toInt(), false)))
                try {
                    val result = multiFormatReader.decode(binaryBitmap, NativeUtils.hints)
//                    NativeUtils.logInfo(result.text)
                    if (result != null) {
                        previewView.post { eventSink.success(NativeUtils.scanDataToMap(result)) }
                    }
                } catch (e: NotFoundException) {
                }
                buffer.clear()
                lastCurrentTime = currentTime
            }
            image.close()
        }
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

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "startScan" -> isPlay = true
            "stopScan" -> isPlay = false
            "setFlashMode" -> {
                val isOpen = methodCall.argument<Boolean>("isOpen")!!
                cameraControl.enableTorch(isOpen)
            }
            "getFlashMode" -> result.success(cameraInfo.torchState)
            else -> result.notImplemented()
        }
    }


}

