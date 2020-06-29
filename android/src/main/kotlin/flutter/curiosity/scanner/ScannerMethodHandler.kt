package flutter.curiosity.scanner

import android.hardware.camera2.CameraAccessException
import flutter.curiosity.CuriosityPlugin.Companion.activity
import flutter.curiosity.CuriosityPlugin.Companion.scanner
import flutter.curiosity.tools.Tools
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.view.TextureRegistry

class ScannerMethodHandler(
        private val messenger: BinaryMessenger,
        private val textureRegistry: TextureRegistry) : MethodCallHandler {
    private lateinit var scannerView: ScannerView

    init {
        scannerChannel = MethodChannel(messenger, "$scanner/method")
        scannerChannel.setMethodCallHandler(this)

    }

    companion object {
        lateinit var scannerChannel: MethodChannel
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "availableCameras" -> try {
                result.success(CameraUtils.getAvailableCameras(activity))
            } catch (e: Exception) {
                handleException(e, result)
            }
            "initialize" -> {
                try {
                    scannerView = ScannerView(messenger, call, textureRegistry.createSurfaceTexture(), result)
                } catch (e: Exception) {
                    handleException(e, result)
                }
            }
            "setFlashMode" -> {
                val status = call.argument<Boolean>("status")
                Tools.logInfo(status.toString());
                scannerView.enableTorch(status === java.lang.Boolean.TRUE)
            }
            "dispose" -> {
                scannerView.dispose()
            }
        }
    }


    private fun handleException(exception: Exception, result: MethodChannel.Result) {
        if (exception is CameraAccessException) {
            result.error("CameraAccess", exception.message, null)
        }
        throw (exception as RuntimeException)
    }

}
