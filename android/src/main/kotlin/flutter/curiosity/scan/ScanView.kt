package flutter.curiosity.scan

import android.content.Context
import android.graphics.ImageFormat
import android.util.Log
import android.view.View
import android.view.ViewGroup
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
import com.google.zxing.PlanarYUVLuminanceSource
import com.google.zxing.common.HybridBinarizer
import com.luck.picture.lib.tools.ToastUtils
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
import java.util.concurrent.Executors

class ScanView internal constructor(private val context: Context, messenger: BinaryMessenger?, i: Int, any: Any) : PlatformView, LifecycleOwner, CameraXConfig.Provider, EventChannel.StreamHandler, MethodCallHandler {
    private lateinit var lifecycleRegistry: LifecycleRegistry
    private lateinit var previewView: PreviewView
    private var isPlay: Boolean
    private lateinit var eventSink: EventSink
    private var lastCurrentTimestamp = 0L //最后一次的扫描
    private lateinit var cameraProviderFuture: ListenableFuture<ProcessCameraProvider>
    private lateinit var cameraProvider: ProcessCameraProvider
    private lateinit var cameraControl: CameraControl
    private lateinit var cameraInfo: CameraInfo
    private var multiFormatReader = MultiFormatReader()

    init {
        val map = any as Map<*, *>
        isPlay = (map["isPlay"] as Boolean?)!!
        val width = map["width"] as Int
        val height = map["height"] as Int
        EventChannel(messenger, scanView + "_" + i + "/event").setStreamHandler(this)
        MethodChannel(messenger, scanView + "_" + i + "/method").setMethodCallHandler(this)
        initCameraView(width, height)
    }

    private fun initCameraView(width: Int, height: Int) {
        cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        lifecycleRegistry = LifecycleRegistry(this)
        previewView = PreviewView(context)
        previewView.layoutParams = ViewGroup.LayoutParams(width, height)
        previewView.implementationMode = PreviewView.ImplementationMode.TEXTURE_VIEW
        val preview = Preview.Builder()
//                .setTargetResolution(Size(width, height))
                .build()
        preview.setSurfaceProvider(previewView.previewSurfaceProvider)
        val imageAnalysis = ImageAnalysis.Builder().apply {
            setImageQueueDepth(ImageAnalysis.STRATEGY_BLOCK_PRODUCER)
//            setTargetResolution(Size(width, height))
        }.build()
        imageAnalysis.setAnalyzer(Executors.newSingleThreadExecutor(), ScanImageAnalysis())
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
            val currentTimestamp = System.currentTimeMillis()
            if (currentTimestamp - lastCurrentTimestamp >= 1L && isPlay == java.lang.Boolean.TRUE) {
                if (ImageFormat.YUV_420_888 != image.format) {
                    return
                }
                val buffer = image.planes[0].buffer
                val array = ByteArray(buffer.remaining())
//                Log.i("Base64", Base64.encodeBase64String(array));
                buffer[array, 0, array.size]
                val height = image.height
                val width = image.width
                val source = PlanarYUVLuminanceSource(array,
                        width,
                        height,
                        0,
                        0,
                        width,
                        height,
                        false)
                val binaryBitmap = BinaryBitmap(HybridBinarizer(source))
//                multiFormatReader.setHints();
                try {
                    val result = multiFormatReader.decode(binaryBitmap, NativeUtils.hints)
                    ToastUtils.s(context, "扫码识别成功")
                    if (result != null) {
                        previewView.post { eventSink.success(NativeUtils.scanDataToMap(result)) }
                    }
                } catch (e: Exception) {
                    Log.i("无二维码数据", "无二维码数据")
                    buffer.clear()
                }
                lastCurrentTimestamp = currentTimestamp
            }
            image.close()
        }
    }

    override fun onCancel(any: Any) {
    }

    override fun getView(): View {
        if (lifecycleRegistry.currentState != Lifecycle.State.RESUMED) {
            lifecycleRegistry.currentState = Lifecycle.State.RESUMED
        }
        return previewView
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

