package flutter.curiosity.scanner

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.ImageFormat
import android.os.CountDownTimer
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
import flutter.curiosity.CuriosityPlugin.Companion.scanner
import flutter.curiosity.camera.preview.PreviewView
import io.flutter.plugin.common.*
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.util.concurrent.Executor
import java.util.concurrent.Executors

class ScannerFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, i: Int, any: Any): PlatformView {
        return Scanner(context, messenger, i, any)
    }

    @SuppressLint("ViewConstructor")
    class Scanner internal constructor(context: Context, messenger: BinaryMessenger, i: Int, any: Any) :
            PlatformView, LifecycleOwner, CameraXConfig.Provider, EventChannel.StreamHandler,
            MethodCallHandler, FrameLayout(context) {
        private lateinit var lifecycleRegistry: LifecycleRegistry
        private lateinit var previewView: PreviewView
        private lateinit var event: EventSink
        private var lastCurrentTime = 0L //最后一次的扫描
        private lateinit var cameraProviderFuture: ListenableFuture<ProcessCameraProvider>
        private lateinit var cameraProvider: ProcessCameraProvider
        private lateinit var cameraControl: CameraControl
        private lateinit var cameraInfo: CameraInfo
        private var multiFormatReader: MultiFormatReader = MultiFormatReader()
        private val singleThreadExecutor: Executor = Executors.newSingleThreadExecutor()
        private val anyMap = any as Map<*, *>
        private val topRatio: Double
        private val leftRatio: Double
        private val widthRatio: Double
        private val heightRatio: Double
        private val countDownTimer: CountDownTimer


        init {
            topRatio = anyMap["topRatio"] as Double
            leftRatio = anyMap["leftRatio"] as Double
            widthRatio = anyMap["widthRatio"] as Double
            heightRatio = anyMap["heightRatio"] as Double
            EventChannel(messenger, "$scanner/$i/event").setStreamHandler(this)
            MethodChannel(messenger, "$scanner/$i/method").setMethodCallHandler(this)
            multiFormatReader.setHints(ScannerUtils.hints)
            initCameraView()
            countDownTimer = object : CountDownTimer(3000, 3000) { // starts at 3 seconds
                override fun onTick(secondsUntilDone: Long) {
                }

                override fun onFinish() {
                    cameraControl.setLinearZoom(0.5f)
                }
            }.start()
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
            imageAnalysis.setAnalyzer(singleThreadExecutor, ScanImageAnalysis())
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

        override fun onListen(o: Any, event: EventSink) {
            this.event = event
        }

        private inner class ScanImageAnalysis : ImageAnalysis.Analyzer {

            override fun analyze(imageProxy: ImageProxy) {
                val currentTime = System.currentTimeMillis()
                if (currentTime - lastCurrentTime >= 100L) {
                    if (ImageFormat.YUV_420_888 != imageProxy.format) {
                        imageProxy.close()
                        return
                    }
                    val buffer = imageProxy.planes[0].buffer
                    val byteArray = ByteArray(buffer.remaining())
                    buffer[byteArray, 0, byteArray.size]
                    var result: Result?
                    result = identify(byteArray, imageProxy, true)
                    if (result == null) {
                        result = identify(byteArray, imageProxy, false)
                    }
                    if (result != null) {
                        previewView.post { event.success(ScannerUtils.scanDataToMap(result)) }
                        countDownTimer.cancel()
                    }
                    buffer.clear()
                    lastCurrentTime = currentTime
                }
                imageProxy.close()
            }
        }

        private fun identify(byteArray: ByteArray, imageProxy: ImageProxy, verticalScreen: Boolean): Result? {
            val width = imageProxy.height
            val height = imageProxy.width
            val array = if (verticalScreen) {
                rotateByteArray(byteArray, imageProxy)
            } else {
                byteArray
            }
            val left = (width * leftRatio).toInt()
            val top = (width * topRatio).toInt()
            val identifyWidth = (width * widthRatio).toInt()
            val identifyHeight = (height * heightRatio).toInt()
            val source = PlanarYUVLuminanceSource(
                    array, width, height, left,
                    top,
                    identifyWidth, identifyHeight, false)
            val binaryBitmap = BinaryBitmap(HybridBinarizer(source))
            var result: Result? = null
            try {
                result = multiFormatReader.decodeWithState(binaryBitmap)
            } catch (e: NotFoundException) {
                multiFormatReader.reset()
                val invertedSource = source.invert()
                val invertBinaryBitmap = BinaryBitmap(HybridBinarizer(invertedSource))
                try {
                    result = multiFormatReader.decodeWithState(invertBinaryBitmap)
                } catch (e: NotFoundException) {
                    multiFormatReader.reset()
                }
            }
            return result

        }

        private fun rotateByteArray(byteArray: ByteArray, imageProxy: ImageProxy): ByteArray {
            val width = imageProxy.width
            val height = imageProxy.height
            val rotatedData = ByteArray(byteArray.size)
            for (y in 0 until height) { // we scan the array by rows
                for (x in 0 until width) {
                    rotatedData[x * height + height - y - 1] =
                            byteArray[x + y * width] //
                }
            }
            return rotatedData
        }

        override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
            when (methodCall.method) {
                "setFlashMode" -> {
                    val status = methodCall.argument<Boolean>("status")
                    if (status != null) {
                        cameraControl.enableTorch(status == java.lang.Boolean.TRUE)
                    }
                }
                else -> result.notImplemented()
            }
        }

    }
}

