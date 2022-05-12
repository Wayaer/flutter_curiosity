package flutter.curiosity

import android.app.Activity
import android.content.Intent
import android.graphics.Rect
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.util.Log
import android.view.ViewTreeObserver
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class CuriosityMethodCall(
    private var activityBinding: ActivityPluginBinding,
    private var pluginBinding: FlutterPlugin.FlutterPluginBinding,
    private var channel: MethodChannel
) :
    MethodChannel.MethodCallHandler, PluginRegistry.ActivityResultListener,
    PluginRegistry.RequestPermissionsResultListener,
    ViewTreeObserver.OnGlobalLayoutListener {
    private var onActivityResultState = false
    private var onRequestPermissionsResultState = false
    private var hasResult = false
    private lateinit var result: MethodChannel.Result
    private var keyboardStatus = false

    var event: CuriosityEvent? = null

    private var openSystemGalleryCode = 100
    private var openSystemCameraCode = 101
    private var installPermissionCode = 102
    private var openActivityResultCode = 111

    override fun onMethodCall(call: MethodCall, _result: MethodChannel.Result) {
        result = _result
        hasResult = true
        when (call.method) {
            "exitApp" -> NativeTools.exitApp(activityBinding.activity)
            "startCuriosityEvent" -> {
                if (event == null) {
                    event = CuriosityEvent(pluginBinding.binaryMessenger)
                }
                resultSuccess(event != null)
            }
            "sendCuriosityEvent" -> {
                event?.sendEvent(call.arguments)
                resultSuccess(event != null)
            }
            "stopCuriosityEvent" -> {
                if (event != null) {
                    event?.dispose()
                    event = null
                }
                resultSuccess(event == null)
            }
            "checkCanInstallApp" -> {
                val state =
                    Tools.canRequestPackageInstalls(pluginBinding.applicationContext)
                if (state) {
                    resultSuccess(state)
                } else {
                    val open = call.arguments as Boolean
                    if (open && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        resultSuccess(
                            startActivity(
                                NativeTools.getRequestPackageInstallsIntent(
                                    pluginBinding.applicationContext
                                ), installPermissionCode
                            )
                        )
                    } else {
                        resultSuccess(false)
                    }
                }
            }
            "installApp" -> resultSuccess(
                startActivity(
                    NativeTools.getInstallAppIntent(
                        pluginBinding.applicationContext, call
                    ), openActivityResultCode
                )
            )
            "openAppMarket" ->
                resultSuccess(
                    startActivity(
                        NativeTools.getAppMarketIntent(call),
                        openActivityResultCode
                    )
                )
            "isInstallApp" -> resultSuccess(
                NativeTools.isInstallApp(
                    activityBinding.activity,
                    call
                )
            )
            "getAppInfo" -> resultSuccess(NativeTools.getAppInfo(pluginBinding.applicationContext))
            "getAppPath" -> resultSuccess(NativeTools.getAppPath(pluginBinding.applicationContext))
            "getDeviceInfo" -> resultSuccess(
                NativeTools.getDeviceInfo(
                    activityBinding.activity
                )
            )
            "getInstalledApp" -> resultSuccess(
                NativeTools.getInstalledApp(
                    activityBinding.activity
                )
            )
            "getGPSStatus" -> resultSuccess(
                NativeTools.getGPSStatus(
                    activityBinding.activity
                )
            )
            "openSystemSetting" -> resultSuccess(
                startActivity(
                    NativeTools.getSystemSettingIntent(
                        activityBinding.activity,
                        call
                    ), openActivityResultCode
                )
            )
            ///相机拍照图库选择
            "openSystemGallery" -> {
                val state = startActivity(
                    GalleryTools.getSystemGalleryIntent(),
                    openSystemGalleryCode
                )
                if (!state) resultSuccess(null)
            }
            "openSystemCamera" -> {
                val state = startActivity(
                    GalleryTools.getSystemCameraIntent(
                        pluginBinding.applicationContext,
                        activityBinding.activity,
                        call
                    ), openSystemCameraCode
                )
                if (!state) resultSuccess(null)
            }
            "saveFileToGallery" -> GalleryTools.saveFileToGallery(
                pluginBinding.applicationContext,
                call,
                result
            )
            "saveImageToGallery" -> GalleryTools.saveImageToGallery(
                pluginBinding.applicationContext,
                call,
                result
            )
            "onActivityResult" -> {
                onActivityResultState = true
                resultSuccess(true)
            }
            "onRequestPermissionsResult" -> {
                onRequestPermissionsResultState = true
                resultSuccess(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun startActivity(intent: Intent?, requestCode: Int): Boolean {
        if (intent != null) {
            activityBinding.addActivityResultListener(this)
            try {
                activityBinding.activity.startActivityForResult(
                    intent,
                    requestCode
                )
                return true
            } catch (e: Exception) {
                Log.d("ActivityException", e.toString())
            }
        }
        return false
    }

    private fun resultSuccess(any: Any?) {
        if (hasResult) {
            try {
                result.success(any)
                hasResult = false
            } catch (e: Exception) {
                Log.d("ResultException", e.toString())
            }
        }
    }

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        intent: Intent?
    ): Boolean {
        if (onActivityResultState) {
            val map: MutableMap<String, Any> = HashMap()
            map["requestCode"] = requestCode
            map["resultCode"] = resultCode
            if (intent != null) {
                if (intent.extras != null)
                    map["extras"] = intent.extras.toString()
                if (intent.data != null) map["data"] = intent.data.toString()
            }
            channel.invokeMethod("onActivityResult", map)
        }

        if (requestCode == openActivityResultCode) {
            resultSuccess(resultCode == Activity.RESULT_OK)
        } else if (resultCode == Activity.RESULT_OK) {
            when (requestCode) {
                openSystemGalleryCode -> {
                    val uri: Uri? = intent?.data
                    resultSuccess(
                        Tools.getRealPathFromURI(
                            uri,
                            pluginBinding.applicationContext
                        )
                    )
                }
                openSystemCameraCode -> {
                    val photoPath: String =
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            pluginBinding.applicationContext.getExternalFilesDir(
                                Environment.DIRECTORY_PICTURES
                            )?.path.toString() + "/TEMP.JPG"
                        } else {
                            intent?.data?.encodedPath.toString()
                        }
                    resultSuccess(photoPath)
                }
                installPermissionCode -> resultSuccess(
                    Tools.canRequestPackageInstalls(
                        pluginBinding.applicationContext
                    )
                )
            }
        }
        activityBinding.removeActivityResultListener(this)
        return true
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (onRequestPermissionsResultState) {
            val map: MutableMap<String, Any> = HashMap()
            map["requestCode"] = requestCode
            map["permissions"] = permissions.toList()
            map["grantResults"] =
                grantResults.toList()
            channel.invokeMethod("onRequestPermissionsResult", map)
        }
        return true
    }

    override fun onGlobalLayout() {
        val rect = Rect()
        val mainView = activityBinding.activity.window.decorView
        mainView.getWindowVisibleDisplayFrame(rect)
        val newStatus = rect.height()
            .toDouble() / mainView.rootView.height.toDouble() < 0.85
        if (keyboardStatus == newStatus) return
        keyboardStatus = newStatus
        channel.invokeMethod("keyboardStatus", newStatus)
    }

}