package flutter.curiosity.scan

import android.content.Context
import android.graphics.*
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
    private val topRatio: Double
    private val leftRatio: Double
    private val widthRatio: Double
    private val heightRatio: Double

    init {
        isScan = (anyMap["isScan"] as Boolean?)!!
        topRatio = anyMap["topRatio"] as Double
        leftRatio = anyMap["leftRatio"] as Double
        widthRatio = anyMap["widthRatio"] as Double
        heightRatio = anyMap["heightRatio"] as Double
        EventChannel(messenger, "$scanView/$i/event").setStreamHandler(this)
        MethodChannel(messenger, "$scanView/$i/method").setMethodCallHandler(this)
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
                var height = image.height
                var width = image.width
                val source = PlanarYUVLuminanceSource(byteArray,
                        width, height, (width * leftRatio).toInt(), ((height * topRatio).toInt()), (width * widthRatio).toInt(),
                        (height * heightRatio).toInt(), false)
                val binaryBitmap = BinaryBitmap(HybridBinarizer(source))
                try {
                    val result = multiFormatReader.decode(binaryBitmap, ScanUtils.hints)
                    if (result != null) {
                        previewView.post { eventSink.success(ScanUtils.scanDataToMap(result)) }
                    }
                } catch (e: NotFoundException) {
//                    val yBuffer = image.planes[0].buffer // Y
//                    val uBuffer = image.planes[1].buffer // U
//                    val vBuffer = image.planes[2].buffer // V
//                    val ySize = yBuffer.remaining()
//                    val uSize = uBuffer.remaining()
//                    val vSize = vBuffer.remaining()
//                    val nv21 = ByteArray(ySize + uSize + vSize)
//                    //U and V are swapped
//                    yBuffer.get(nv21, 0, ySize)
//                    vBuffer.get(nv21, ySize, vSize)
//                    uBuffer.get(nv21, ySize + vSize, uSize)
//
//                    val yuvImage = YuvImage(nv21, ImageFormat.NV21, width, height, null)
//                    val out = ByteArrayOutputStream()
//                    yuvImage.compressToJpeg(Rect(0, 0, yuvImage.width, yuvImage.height), 50, out)
//                    val imageBytes = out.toByteArray()
//                    val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
//                    val bitmap = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)
//                    val matrix = Matrix() //旋转图片 动作
//                    matrix.setRotate(90.0F) //旋转角度
//                    val resizedBitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)// 创建新的图片
//                    Utils.logInfo("旋转图片完成，开始识别")
//                    previewView.post { eventSink.success(ScanUtils.identifyBitmap(resizedBitmap)) }
//                    val source1 = PlanarYUVLuminanceSource(byteArray,
//                            resizedBitmap.width, height, (resizedBitmap.width * leftRatio).toInt(), ((resizedBitmap.height * topRatio).toInt()), (resizedBitmap.width * widthRatio).toInt(),
//                            (resizedBitmap.height * heightRatio).toInt(), false)
//                    val binaryBitmap1 = BinaryBitmap(HybridBinarizer(source1))
//                    try {
//                        val result = multiFormatReader.decode(binaryBitmap1, ScanUtils.hints)
//                        if (result != null) {
//                            previewView.post { eventSink.success(ScanUtils.scanDataToMap(result)) }
//                        }
//                    } catch (e: NotFoundException) {
//
//                    }

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
            "startScan" -> isScan = true
            "stopScan" -> isScan = false
            "setFlashMode" -> {
                cameraControl.enableTorch(methodCall.argument<Boolean>("status")!!)
            }
            "getFlashMode" -> result.success(cameraInfo.torchState)
            else -> result.notImplemented()
        }
    }

    fun rotateBitmap(bitmap: Bitmap): Bitmap {
        val matrix = Matrix()
        matrix.setRotate(90.toFloat(), bitmap.width.toFloat() / 2,
                bitmap.height.toFloat() / 2)
        val targetX: Float = bitmap.height.toFloat()
        val targetY: Float = 0f
        val values = FloatArray(9)
        matrix.getValues(values)
        val x1 = values[Matrix.MTRANS_X]
        val y1 = values[Matrix.MTRANS_Y]
        matrix.postTranslate(targetX - x1, targetY - y1)
        val canvasBitmap: Bitmap = Bitmap.createBitmap(bitmap.height, bitmap.width,
                Bitmap.Config.ARGB_8888)
        val paint = Paint()
        val canvas = Canvas(canvasBitmap)
        canvas.drawBitmap(bitmap, matrix, paint)
        return canvasBitmap
    }


}

