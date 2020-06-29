package flutter.curiosity.scanner

import android.content.Context
import android.graphics.ImageFormat
import android.hardware.camera2.*
import android.media.Image
import android.media.ImageReader
import android.os.Handler
import android.util.Size
import android.view.Surface
import com.google.zxing.*
import com.google.zxing.common.GlobalHistogramBinarizer
import flutter.curiosity.CuriosityPlugin
import flutter.curiosity.CuriosityPlugin.Companion.activity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry.SurfaceTextureEntry

class ScannerView(
        messenger: BinaryMessenger,
        call: MethodCall,
        private val texture: SurfaceTextureEntry,
        private val result: MethodChannel.Result) {
    private val cameraManager: CameraManager = activity.getSystemService(Context.CAMERA_SERVICE) as CameraManager
    private val previewSize: Size
    private var cameraDevice: CameraDevice? = null
    private var cameraCaptureSession: CameraCaptureSession? = null
    private var imageReader: ImageReader? = null
    private var captureRequestBuilder: CaptureRequest.Builder? = null
    private var lastCurrentTime = 0L
    private var eventSink: EventChannel.EventSink? = null
    private var multiFormatReader: MultiFormatReader = MultiFormatReader()
    private val topRatio: Double = call.argument<Double>("topRatio")!!
    private val leftRatio: Double = call.argument<Double>("leftRatio")!!
    private val widthRatio: Double = call.argument<Double>("widthRatio")!!
    private val heightRatio: Double = call.argument<Double>("heightRatio")!!

    enum class ResolutionPreset {
        Low, Medium, High, VeryHigh, UltraHigh, Max
    }

    init {
        val eventChannel = EventChannel(messenger, "${CuriosityPlugin.scanner}/${texture.id()}/event")
        eventChannel.setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any, sink: EventChannel.EventSink) {
                        eventSink = sink
                    }

                    override fun onCancel(arguments: Any) {
                        eventSink = null
                    }
                })
        val cameraId = call.argument<String>("cameraId")
        val resolutionPreset = call.argument<String>("resolutionPreset")
        val preset = ResolutionPreset.valueOf(resolutionPreset!!)
        previewSize = CameraUtils.computeBestPreviewSize(cameraId.toString(), preset)
        imageReader = ImageReader.newInstance(
                previewSize.width, previewSize.height, ImageFormat.YUV_420_888, 2)
        cameraManager.openCamera(
                cameraId.toString(),
                object : CameraDevice.StateCallback() {
                    override fun onOpened(device: CameraDevice) {
                        cameraDevice = device
                        try {
                            createCamera()
                        } catch (e: CameraAccessException) {
                            result.error("CameraAccess", e.message, null)
                            close()
                            return
                        }
                        val mutableMap: MutableMap<String, Any> = HashMap()
                        mutableMap["textureId"] = texture.id()
                        mutableMap["previewWidth"] = previewSize.width
                        mutableMap["previewHeight"] = previewSize.height
                        result.success(mutableMap)
                    }

                    override fun onDisconnected(cameraDevice: CameraDevice) {
                        close()
                    }

                    override fun onError(cameraDevice: CameraDevice, errorCode: Int) {
                        close()
                    }
                },
                null)
    }

    private fun createCamera() {
        captureRequestBuilder = cameraDevice!!.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW)
        val surfaceTexture = texture.surfaceTexture()
        surfaceTexture.setDefaultBufferSize(previewSize.width, previewSize.height)
        val surfaceView = Surface(surfaceTexture)
        captureRequestBuilder!!.addTarget(surfaceView)
        val remainingSurfaces = listOf(imageReader!!.surface)
        for (surface in remainingSurfaces) captureRequestBuilder!!.addTarget(surface)
        val callback: CameraCaptureSession.StateCallback = object : CameraCaptureSession.StateCallback() {
            override fun onConfigured(session: CameraCaptureSession) {
                if (cameraDevice == null) return
                cameraCaptureSession = session
                cameraCaptureSession!!.setRepeatingRequest(captureRequestBuilder!!.build(), null, null)
            }

            override fun onConfigureFailed(cameraCaptureSession: CameraCaptureSession) {
            }
        }

        val surfaceList: MutableList<Surface> = ArrayList()
        surfaceList.add(surfaceView)
        surfaceList.addAll(remainingSurfaces)
        cameraDevice!!.createCaptureSession(surfaceList, callback, null)
        imageReader!!.setOnImageAvailableListener(ImageAvailableListener(), Handler())
    }

    private inner class ImageAvailableListener : ImageReader.OnImageAvailableListener {
        override fun onImageAvailable(imageReader: ImageReader) {
            val image = imageReader.acquireLatestImage()
            val currentTime = System.currentTimeMillis()
            if (currentTime - lastCurrentTime >= 10L) {
                if (ImageFormat.YUV_420_888 == image?.format) {
                    val buffer = image.planes[0].buffer
                    val byteArray = ByteArray(buffer.remaining())
                    buffer[byteArray, 0, byteArray.size]
                    var result: Result?
                    result = identify(byteArray, image, true)
                    if (result == null) {
                        result = identify(byteArray, image, false)
                    }
                    if (result != null) {
                        eventSink?.success(ScannerTools.scanDataToMap(result))
                    }
                    buffer.clear()
                    lastCurrentTime = currentTime
                }
            }
            image?.close()
        }
    }


    private fun identify(byteArray: ByteArray, image: Image, verticalScreen: Boolean): Result? {
        val width: Int
        val height: Int
        val array: ByteArray
        if (verticalScreen) {
            array = rotateByteArray(byteArray, image)
            width = image.height
            height = image.width
        } else {
            width = image.width
            height = image.height
            array = byteArray
        }
        val left = (width * leftRatio).toInt()
        val top = (width * topRatio).toInt()
        val identifyWidth = (width * widthRatio).toInt()
        val identifyHeight = (height * heightRatio).toInt()
        val source = PlanarYUVLuminanceSource(
                array, width, height, left,
                top,
                identifyWidth, identifyHeight, false)
        val binaryBitmap = BinaryBitmap(GlobalHistogramBinarizer(source))
        var result: Result? = null
        try {
            result = multiFormatReader.decodeWithState(binaryBitmap)
        } catch (e: NotFoundException) {
            multiFormatReader.reset()
        }
        return result
    }

    private fun rotateByteArray(byteArray: ByteArray, image: Image): ByteArray {
        val width = image.width
        val height = image.height
        val rotatedData = ByteArray(byteArray.size)
        for (y in 0 until height) { // we scan the array by rows
            for (x in 0 until width) {
                rotatedData[x * height + height - y - 1] =
                        byteArray[x + y * width] //
            }
        }
        return rotatedData
    }

    fun enableTorch(status: Boolean) {
        if (status) {
            captureRequestBuilder!!.set(
                    CaptureRequest.FLASH_MODE, CameraMetadata.FLASH_MODE_TORCH)
            cameraCaptureSession!!.setRepeatingRequest(captureRequestBuilder!!.build(), null, null)
        } else {
            captureRequestBuilder!!.set(
                    CaptureRequest.FLASH_MODE, CameraMetadata.FLASH_MODE_OFF)
            cameraCaptureSession!!.setRepeatingRequest(captureRequestBuilder!!.build(), null, null)
        }
    }

    fun close() {
        cameraDevice!!.close()
        imageReader!!.close()
    }

    fun dispose() {
        close()
        texture.release()
    }

}


