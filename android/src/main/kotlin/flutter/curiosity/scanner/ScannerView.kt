package flutter.curiosity.scanner

import android.app.Activity
import android.content.Context
import android.graphics.ImageFormat
import android.hardware.camera2.*
import android.media.ImageReader
import android.os.Handler
import android.os.Looper
import android.util.Size
import android.view.Surface
import flutter.curiosity.CuriosityPlugin.Companion.call
import flutter.curiosity.CuriosityPlugin.Companion.result
import flutter.curiosity.tools.NativeTools
import flutter.curiosity.tools.Tools
import io.flutter.plugin.common.EventChannel
import io.flutter.view.TextureRegistry.SurfaceTextureEntry
import java.util.concurrent.Executor
import java.util.concurrent.Executors


class ScannerView(private val texture: SurfaceTextureEntry, activity: Activity, context: Context) :
    EventChannel.StreamHandler {

    private var cameraManager: CameraManager = activity.getSystemService(Context.CAMERA_SERVICE) as CameraManager
    private lateinit var previewSize: Size
    private var _context = context
    private var cameraDevice: CameraDevice? = null
    private var cameraCaptureSession: CameraCaptureSession? = null
    private var imageStreamReader: ImageReader? = null
    private var captureRequestBuilder: CaptureRequest.Builder? = null
    private var lastCurrentTime = 0L
    private val handler = Handler(Looper.getMainLooper())
    private val singleThreadExecutor: Executor = Executors.newSingleThreadExecutor()
    private var cameraId: String = call.argument<String>("cameraId").toString()
    private val topRatio: Double = call.argument<Double>("topRatio")!!
    private val leftRatio: Double = call.argument<Double>("leftRatio")!!
    private val widthRatio: Double = call.argument<Double>("widthRatio")!!
    private val heightRatio: Double = call.argument<Double>("heightRatio")!!
    private lateinit var eventSink: EventChannel.EventSink

    init {
        //获取预览大小
        val preset = call.argument<String>("resolutionPreset")
        if (preset != null) previewSize = CameraTools.computeBestPreviewSize(cameraId, preset)
    }

    fun initCameraView() {
        if (NativeTools.checkPermission(android.Manifest.permission.CAMERA, _context)) {
            cameraManager.openCamera(
                cameraId,
                object : CameraDevice.StateCallback() {
                    override fun onOpened(device: CameraDevice) {
                        cameraDevice = device
                        try {
                            createCaptureSession()
                            resultMap("onOpened")
                        } catch (e: Exception) {
                            resultMap("CreateCaptureSession Exception")
                        }
                    }

                    override fun onDisconnected(cameraDevice: CameraDevice) {
                        resultMap("onDisconnected")
                        close()
                    }

                    override fun onError(cameraDevice: CameraDevice, errorCode: Int) {
                        resultMap("onError")
                        close()
                    }
                },
                Handler(Looper.getMainLooper())
            )
        }
    }

    private fun resultMap(cameraState: String) {
        val mutableMap: MutableMap<String, Any> = HashMap()
        mutableMap["cameraState"] = cameraState
        mutableMap["textureId"] = texture.id()
        mutableMap["previewWidth"] = previewSize.width
        mutableMap["previewHeight"] = previewSize.height
        result.success(mutableMap)
    }

    /**
     * 创建预览会话
     */
    private fun createCaptureSession() {
        imageStreamReader = ImageReader.newInstance(
            previewSize.width, previewSize.height, ImageFormat.YUV_420_888, 2
        )
        captureRequestBuilder = cameraDevice?.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW)
        val surfaceTexture = texture.surfaceTexture()
        surfaceTexture.setDefaultBufferSize(previewSize.width, previewSize.height)
        val surface = Surface(surfaceTexture)
        captureRequestBuilder?.addTarget(surface)  // 将CaptureRequest的构建器与Surface对象绑定在一起
        captureRequestBuilder?.addTarget(imageStreamReader!!.surface)
        captureRequestBuilder?.set(
            CaptureRequest.CONTROL_AF_MODE,
            CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE
        ) // 自动对焦
        imageStreamReader?.setOnImageAvailableListener({ imageReader ->
            singleThreadExecutor.execute {
                val image = imageReader.acquireLatestImage()
                val currentTime = System.currentTimeMillis()
                if (currentTime - lastCurrentTime >= 1L) {
                    if (ImageFormat.YUV_420_888 == image?.format) {
                        val buffer = image.planes[0].buffer
                        val byteArray = ByteArray(buffer.remaining())
                        buffer[byteArray, 0, byteArray.size]
                        try {
                            val result = ScannerTools.decodeImage(
                                byteArray,
                                image,
                                true,
                                topRatio,
                                leftRatio,
                                widthRatio,
                                heightRatio
                            )
                            if (result != null) handler.post {
                                eventSink.success(ScannerTools.scanDataToMap(result))
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
        cameraDevice?.createCaptureSession(
            arrayListOf(surface, imageStreamReader!!.surface),
            object : CameraCaptureSession.StateCallback() {
                override fun onConfigureFailed(session: CameraCaptureSession) {
                }

                override fun onConfigured(session: CameraCaptureSession) {
                    cameraCaptureSession = session
                    try {
                        cameraCaptureSession?.setRepeatingRequest(
                            captureRequestBuilder!!.build(),
                            null,
                            Handler(Looper.getMainLooper())
                        )
                    } catch (e: Exception) {
                        resultMap("CreateCaptureSession Exception")
                    }
                }
            },
            handler
        )
    }


    fun enableTorch(status: Boolean) {
//        if (captureRequestBuilder == null || cameraCaptureSession == null) return
        Tools.logInfo("setFlashModesetFlashModesetFlashModesetFlashMode11111")
        if (status) {
            captureRequestBuilder?.set(
                CaptureRequest.FLASH_MODE, CameraMetadata.FLASH_MODE_TORCH
            )
            cameraCaptureSession?.setRepeatingRequest(captureRequestBuilder!!.build(), null, null)
        } else {
            Tools.logInfo("setFlashModesetFlashModesetFlashModesetFlashMode1122111")
            captureRequestBuilder?.set(
                CaptureRequest.FLASH_MODE, CameraMetadata.FLASH_MODE_OFF
            )
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
        eventSink.endOfStream()
    }

    override fun onListen(arguments: Any, events: EventChannel.EventSink) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink.endOfStream()
    }


}









