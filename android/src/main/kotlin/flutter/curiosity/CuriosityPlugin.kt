package flutter.curiosity

import android.app.Activity
import android.content.Intent
import android.graphics.Rect
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.view.View
import android.view.ViewTreeObserver
import androidx.annotation.NonNull
import flutter.curiosity.gallery.GalleryTools
import flutter.curiosity.tools.NativeTools
import flutter.curiosity.tools.Tools
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import java.util.*


class CuriosityPlugin : ActivityAware, FlutterPlugin, ActivityResultListener,
    ViewTreeObserver.OnGlobalLayoutListener, MethodChannel.MethodCallHandler,
    RequestPermissionsResultListener {
    private var curiosityChannel: MethodChannel? = null
    private var plugin: FlutterPluginBinding? = null
    private var activityPlugin: ActivityPluginBinding? = null

    private var onActivityResultState = false
    private var onRequestPermissionsResultState = false

    private var mainView: View? = null
    private var keyboardStatus = false

    companion object {
        var openSystemGalleryCode = 100
        var openSystemCameraCode = 101
        var installApkCode = 102
        var installPermissionCode = 103
        var openSystemShareCode = 110
        var resultCode = 111
        var resultSuccess = "success"
        var resultCancel = "cancel"
        var resultFail = "fail"
        lateinit var call: MethodCall
        lateinit var result: MethodChannel.Result
        var curiosityEvent: CuriosityEvent? = null
    }

    override fun onAttachedToEngine(@NonNull pluginBinding: FlutterPluginBinding) {
        plugin = pluginBinding
        curiosityChannel = MethodChannel(pluginBinding.binaryMessenger, "Curiosity")
        curiosityChannel?.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        _call: MethodCall,
        _result: MethodChannel.Result
    ) {
        result = _result
        call = _call
        when (call.method) {
            "exitApp" -> NativeTools.exitApp()
            "startCuriosityEvent" -> {
                if (curiosityEvent == null) {
                    curiosityEvent = CuriosityEvent(plugin!!.binaryMessenger)
                }
                result.success(curiosityEvent != null)
            }
            "sendCuriosityEvent" -> {
                curiosityEvent?.sendEvent(call.arguments)
                result.success(curiosityEvent != null)
            }
            "stopCuriosityEvent" -> {
                if (curiosityEvent != null) {
                    curiosityEvent?.dispose()
                    curiosityEvent = null
                }
                result.success(curiosityEvent == null)
            }
            "installApp" -> NativeTools.installApp(
                plugin!!.applicationContext,
                activityPlugin!!.activity
            )
            "openAppMarket" -> result.success(NativeTools.openAppMarket(activityPlugin!!.activity))
            "isInstallApp" -> result.success(NativeTools.isInstallApp(activityPlugin!!.activity))
            "getAppInfo" -> result.success(NativeTools.getAppInfo(plugin!!.applicationContext))
            "getAppPath" -> result.success(NativeTools.getAppPath(plugin!!.applicationContext))
            "getDeviceInfo" -> result.success(NativeTools.getDeviceInfo(activityPlugin!!.activity))
            "getInstalledApp" -> result.success(NativeTools.getInstalledApp(activityPlugin!!.activity))
            "getGPSStatus" -> result.success(NativeTools.getGPSStatus(activityPlugin!!.activity))
            "openSystemSetting" -> NativeTools.openSystemSetting(activityPlugin!!.activity)
            ///相机拍照图库选择
            "openSystemGallery" -> GalleryTools.openSystemGallery(activityPlugin!!.activity)
            "openSystemCamera" -> GalleryTools.openSystemCamera(
                plugin!!.applicationContext,
                activityPlugin!!.activity
            )
            "saveFileToGallery" -> GalleryTools.saveFileToGallery(plugin!!.applicationContext)
            "saveImageToGallery" -> GalleryTools.saveImageToGallery(plugin!!.applicationContext)
            "onActivityResult" -> {
                onActivityResultState = true
                result.success(true)
            }
            "onRequestPermissionsResult" -> {
                onRequestPermissionsResultState = true
                result.success(true)
            }
            else -> result.notImplemented()
        }

    }

    override fun onAttachedToActivity(pluginBinding: ActivityPluginBinding) {
        activityPlugin = pluginBinding
        mainView = pluginBinding.activity.window.decorView
        mainView!!.viewTreeObserver.addOnGlobalLayoutListener(this)
        pluginBinding.addActivityResultListener(this)
        pluginBinding.addRequestPermissionsResultListener(this)
    }

    override fun onReattachedToActivityForConfigChanges(plugin: ActivityPluginBinding) {
        onAttachedToActivity(plugin)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onDetachedFromActivity() {
        activityPlugin?.removeActivityResultListener(this)
        activityPlugin?.removeRequestPermissionsResultListener(this)
    }


    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        plugin = null
        activityPlugin = null
        curiosityChannel?.setMethodCallHandler(null)
        curiosityChannel = null
        activityPlugin!!.activity.window.decorView.viewTreeObserver
            .removeOnGlobalLayoutListener(this)
        curiosityEvent?.dispose()
        curiosityEvent = null
    }

    override fun onGlobalLayout() {
        val rect = Rect()
        if (mainView != null) {
            mainView!!.getWindowVisibleDisplayFrame(rect)
            val newStatus = rect.height()
                .toDouble() / mainView!!.rootView.height.toDouble() < 0.85
            if (keyboardStatus == newStatus) return
            keyboardStatus = newStatus
            curiosityChannel?.invokeMethod("keyboardStatus", newStatus)
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
            curiosityChannel?.invokeMethod("onActivityResult", map)
        }

        if (resultCode == Activity.RESULT_OK) {
            when (requestCode) {
                openSystemGalleryCode -> {
                    val uri: Uri? = intent?.data
                    result.success(
                        Tools.getRealPathFromURI(
                            uri,
                            plugin!!.applicationContext
                        )
                    )
                }
                openSystemCameraCode -> {
                    val photoPath: String =
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            plugin!!.applicationContext.getExternalFilesDir(Environment.DIRECTORY_PICTURES)?.path.toString() + "/TEMP.JPG"
                        } else {
                            intent?.data?.encodedPath.toString()
                        }
                    result.success(photoPath)
                }
                installApkCode -> result.success(resultSuccess)
                openSystemShareCode -> result.success(resultSuccess)
                installPermissionCode -> NativeTools.installApp(
                    plugin!!.applicationContext,
                    activityPlugin!!.activity
                )
            }
        } else if (resultCode == Activity.RESULT_CANCELED) {
            when (requestCode) {
                //未打开安装应用权限
                installPermissionCode -> result.success("not permissions")
                //取消安装
                installApkCode -> result.success(resultCancel)
                openSystemShareCode -> result.success(resultCancel)
            }
        }
        return true
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>?,
        grantResults: IntArray?
    ): Boolean {
        if (onRequestPermissionsResultState) {
            val map: MutableMap<String, Any> = HashMap()
            map["requestCode"] = requestCode
            if (permissions != null) map["permissions"] = permissions.toList()
            if (grantResults != null) map["grantResults"] = grantResults.toList()
            curiosityChannel?.invokeMethod("onRequestPermissionsResult", map)
        }
        return true
    }

}

