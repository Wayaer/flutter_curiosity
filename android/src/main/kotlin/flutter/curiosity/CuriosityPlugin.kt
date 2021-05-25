package flutter.curiosity

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Rect
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.view.View
import android.view.ViewTreeObserver
import androidx.annotation.NonNull
import flutter.curiosity.gallery.GalleryTools
import flutter.curiosity.scanner.CameraTools
import flutter.curiosity.scanner.ScannerTools
import flutter.curiosity.scanner.ScannerView
import flutter.curiosity.tools.NativeTools
import flutter.curiosity.tools.Tools
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import java.util.*


/**
 * CuriosityPlugin
 */
class CuriosityPlugin : ActivityAware, FlutterPlugin, ActivityResultListener,
    ViewTreeObserver.OnGlobalLayoutListener, MethodChannel.MethodCallHandler,
    RequestPermissionsResultListener {
    private var curiosityChannel: MethodChannel? = null
    private lateinit var context: Context
    private lateinit var activity: Activity
    private var scannerEvent: EventChannel? = null
    private var mainView: View? = null
    private var keyboardStatus = false
    private val curiosity = "Curiosity"
    private lateinit var pluginBinding: FlutterPluginBinding
    private var onActivityResultState = false
    private var onRequestPermissionsResultState = false
    private var scannerView: ScannerView? = null

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
    }

    override fun onAttachedToEngine(@NonNull plugin: FlutterPluginBinding) {
        context = plugin.applicationContext
        pluginBinding = plugin
        curiosityChannel = MethodChannel(plugin.binaryMessenger, curiosity)
        curiosityChannel?.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        _call: MethodCall,
        _result: MethodChannel.Result
    ) {
        val scannerEventName = "$curiosity/event/scanner"
        result = _result
        call = _call
        when (call.method) {
            "exitApp" -> NativeTools.exitApp()
            "installApp" -> NativeTools.installApp(context, activity)
            "openAppMarket" -> result.success(NativeTools.openAppMarket(activity))
            "isInstallApp" -> result.success(NativeTools.isInstallApp(activity))
            "getAppInfo" -> result.success(NativeTools.getAppInfo(context))
            "getDeviceInfo" -> result.success(NativeTools.getDeviceInfo(context))
            "getInstalledApp" -> result.success(NativeTools.getInstalledApp(context))
            "getGPSStatus" -> result.success(NativeTools.getGPSStatus(context))
            "openSystemShare" -> {
                val data = NativeTools.openSystemShare(activity)
                if (data != null) result.success(data)
            }
            "openSystemSetting" -> NativeTools.openSystemSetting(activity)
            ///相机拍照图库选择
            "openSystemGallery" -> GalleryTools.openSystemGallery(activity)
            "openSystemCamera" -> GalleryTools.openSystemCamera(
                context,
                activity
            )
            "saveFileToGallery" -> GalleryTools.saveFileToGallery(context)
            "saveImageToGallery" -> GalleryTools.saveImageToGallery(context)
            ///扫码相机相关
            "scanImagePath" -> ScannerTools.scanImagePath(activity)
            "scanImageUrl" -> ScannerTools.scanImageUrl(activity)
            "scanImageMemory" -> ScannerTools.scanImageMemory(activity)
            "availableCameras" ->
                result.success(
                    CameraTools.getAvailableCameras(
                        activity
                    )
                )
            "initializeCameras" -> {
                scannerEvent =
                    EventChannel(
                        pluginBinding.binaryMessenger,
                        scannerEventName
                    )
                scannerView = ScannerView(
                    pluginBinding.textureRegistry.createSurfaceTexture(),
                    activity,
                    context
                )
                scannerEvent?.setStreamHandler(scannerView)
                scannerView?.initCameraView()
            }
            "setFlashMode" -> {
                val status = call.arguments as Boolean
                scannerView?.enableTorch(status)
                result.success("setFlashMode")
            }
            "disposeCameras" -> {
                scannerView?.dispose()
                scannerEvent?.setStreamHandler(null)
                scannerEvent = null
                result.success("dispose")
            }
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

    ///主要是用于获取当前flutter页面所处的Activity.
    override fun onAttachedToActivity(plugin: ActivityPluginBinding) {
        activity = plugin.activity
        mainView = activity.window.decorView
        mainView!!.viewTreeObserver.addOnGlobalLayoutListener(this)
        plugin.addActivityResultListener(this)
        plugin.addRequestPermissionsResultListener(this)
    }


    ///主要是用于获取当前flutter页面所处的Activity.
    override fun onDetachedFromActivity() {
    }

    ///Activity注销时
    override fun onReattachedToActivityForConfigChanges(plugin: ActivityPluginBinding) {
        plugin.removeActivityResultListener(this)
        plugin.removeRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        dispose()
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        dispose()
    }

    private fun dispose() {
        curiosityChannel?.setMethodCallHandler(null)
        scannerEvent?.setStreamHandler(null)
        activity.window.decorView.viewTreeObserver
            .removeOnGlobalLayoutListener(this)
        scannerEvent = null
        curiosityChannel = null
    }

    override fun onGlobalLayout() {
        val r = Rect()
        if (mainView != null) {
            mainView!!.getWindowVisibleDisplayFrame(r)
            val newStatus = r.height()
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
                            context
                        )
                    )
                }
                openSystemCameraCode -> {
                    val photoPath: String =
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            context.getExternalFilesDir(Environment.DIRECTORY_PICTURES)?.path.toString() + "/TEMP.JPG"
                        } else {
                            intent?.data?.encodedPath.toString()
                        }
                    result.success(photoPath)
                }
                installApkCode -> result.success(resultSuccess)
                openSystemShareCode -> result.success(resultSuccess)
                installPermissionCode -> NativeTools.installApp(
                    context,
                    activity
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

