package flutter.curiosity.scanner

import android.content.Context
import android.graphics.ImageFormat
import android.hardware.camera2.*
import android.media.ImageReader
import android.os.Handler
import android.util.Size
import android.view.Surface
import flutter.curiosity.CuriosityPlugin.Companion.activity
import flutter.curiosity.CuriosityPlugin.Companion.call
import flutter.curiosity.CuriosityPlugin.Companion.channelResult
import flutter.curiosity.CuriosityPlugin.Companion.eventSink
import flutter.curiosity.tools.Tools
import io.flutter.view.TextureRegistry.SurfaceTextureEntry
import java.util.concurrent.Executor
import java.util.concurrent.Executors

class ScannerView(private val texture: SurfaceTextureEntry) {
    private var cameraManager: CameraManager = activity.getSystemService(Context.CAMERA_SERVICE) as CameraManager
    private lateinit var previewSize: Size
    private var cameraDevice: CameraDevice? = null
    private var cameraCaptureSession: CameraCaptureSession? = null
    private var imageStreamReader: ImageReader? = null
    private var captureRequestBuilder: CaptureRequest.Builder? = null
    private var lastCurrentTime = 0L
    private val handler = Handler()
    private val singleThreadExecutor: Executor = Executors.newSingleThreadExecutor()
    private var cameraId: String = call.argument<String>("cameraId").toString()
    private val topRatio: Double = call.argument<Double>("topRatio")!!
    private val leftRatio: Double = call.argument<Double>("leftRatio")!!
    private val widthRatio: Double = call.argument<Double>("widthRatio")!!
    private val heightRatio: Double = call.argument<Double>("heightRatio")!!

    init {
        //获取预览大小
        val preset = call.argument<String>("resolutionPreset")
        if (preset != null) previewSize = CameraTools.computeBestPreviewSize(cameraId, preset)
    }

    fun initCameraView() {
        cameraManager.openCamera(
                cameraId,
                object : CameraDevice.StateCallback() {
                    override fun onOpened(device: CameraDevice) {
                        cameraDevice = device
                        try {
                            createCaptureSession()
                            val mutableMap: MutableMap<String, Any> = HashMap()
                            mutableMap["textureId"] = texture.id()
                            mutableMap["previewWidth"] = previewSize.width
                            mutableMap["previewHeight"] = previewSize.height
                            channelResult.success(mutableMap)
                        } catch (e: Exception) {
                            Tools.logInfo("CreateCaptureSession Exception")
                        }
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

    /**
     * 创建预览会话
     */
    private fun createCaptureSession() {
        imageStreamReader = ImageReader.newInstance(
                previewSize.width, previewSize.height, ImageFormat.YUV_420_888, 2)
        captureRequestBuilder = cameraDevice?.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW)
        val surfaceTexture = texture.surfaceTexture()
        surfaceTexture.setDefaultBufferSize(previewSize.width, previewSize.height)
        val surface = Surface(surfaceTexture)
        captureRequestBuilder?.addTarget(surface)  // 将CaptureRequest的构建器与Surface对象绑定在一起
        captureRequestBuilder?.addTarget(imageStreamReader!!.surface)
        captureRequestBuilder?.set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE) // 自动对焦
        imageStreamReader?.setOnImageAvailableListener({ imageReader ->
            singleThreadExecutor.execute {
                val image = imageReader.acquireLatestImage()
                val currentTime = System.currentTimeMillis()
                if (currentTime - lastCurrentTime >= 10L) {
                    if (ImageFormat.YUV_420_888 == image?.format) {

                        val buffer = image.planes[0].buffer
                        val byteArray = ByteArray(buffer.remaining())
                        buffer[byteArray, 0, byteArray.size]
                        try {
                            val result = ScannerTools.decodeImage(byteArray, image, true, topRatio, leftRatio, widthRatio, heightRatio)
                            if (result != null) {
                                handler.post {
                                    eventSink.success(ScannerTools.scanDataToMap(result))
                                }
                            }
                        } catch (e: Exception) {
                        }
                        buffer.clear()
                        lastCurrentTime = currentTime
                    }
                }
                image?.close()
            }
        }, handler)
        // 为相机预览，创建一个CameraCaptureSession对象
        closeCaptureSession()
        cameraDevice?.createCaptureSession(arrayListOf(surface, imageStreamReader!!.surface), object : CameraCaptureSession.StateCallback() {
            override fun onConfigureFailed(session: CameraCaptureSession) {
            }

            override fun onConfigured(session: CameraCaptureSession) {
                cameraCaptureSession = session
                try {
                    cameraCaptureSession?.setRepeatingRequest(captureRequestBuilder!!.build(), null, Handler())
                } catch (e: Exception) {
//                    Tools.logInfo("CameraCaptureSession Exception")
                }
            }
        }, handler)
    }


    fun enableTorch(status: Boolean) {
        if (captureRequestBuilder == null || cameraCaptureSession == null) return
        if (status) {
            captureRequestBuilder?.set(
                    CaptureRequest.FLASH_MODE, CameraMetadata.FLASH_MODE_TORCH)
            cameraCaptureSession?.setRepeatingRequest(captureRequestBuilder!!.build(), null, null)
        } else {
            captureRequestBuilder?.set(
                    CaptureRequest.FLASH_MODE, CameraMetadata.FLASH_MODE_OFF)
            cameraCaptureSession?.setRepeatingRequest(captureRequestBuilder!!.build(), null, null)
        }
    }

    private fun closeCaptureSession() {
        if (cameraCaptureSession != null) {
            cameraCaptureSession?.close()
            cameraCaptureSession = null
        }
    }

    fun close() {
        closeCaptureSession()
        cameraDevice?.close()
        imageStreamReader?.close()
    }

    fun dispose() {
        close()
        texture.release()
    }


}









