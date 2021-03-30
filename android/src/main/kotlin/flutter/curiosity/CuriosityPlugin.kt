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


/**
 * CuriosityPlugin
 */
class CuriosityPlugin : ActivityAware, FlutterPlugin, ActivityResultListener, ViewTreeObserver.OnGlobalLayoutListener {
    private var curiosityChannel: MethodChannel? = null
    private lateinit var context: Context
    private lateinit var activity: Activity
    private var scannerEvent: EventChannel? = null
    private var mainView: View? = null
    private var keyboardStatus = false

    companion object {
        var openSystemGalleryCode = 100
        var openSystemCameraCode = 101
        var installApkCode = 102
        var installPermission = 103
        lateinit var call: MethodCall
        lateinit var channelResult: MethodChannel.Result
    }

    override fun onAttachedToEngine(@NonNull plugin: FlutterPluginBinding) {
        context = plugin.applicationContext
        val curiosity = "Curiosity"
        val scannerEventName = "$curiosity/event/scanner"
        curiosityChannel = MethodChannel(plugin.binaryMessenger, curiosity)

        var scannerView: ScannerView? = null
        curiosityChannel?.setMethodCallHandler { _call, _result ->
            channelResult = _result
            call = _call
            when (call.method) {
                "exitApp" -> NativeTools.exitApp()
                "installApp" -> NativeTools.installApp(context, activity)
                "getFilePathSize" -> channelResult.success(NativeTools.getFilePathSize())
                "callPhone" -> channelResult.success(NativeTools.callPhone(context, activity))
                "goToMarket" -> channelResult.success(NativeTools.goToMarket(activity))
                "isInstallApp" -> channelResult.success(NativeTools.isInstallApp(activity))
                "getAppInfo" -> channelResult.success(NativeTools.getAppInfo(context))
                "getDeviceInfo" -> channelResult.success(NativeTools.getDeviceInfo(context))
                "getInstalledApp" -> channelResult.success(NativeTools.getInstalledApp(context))
                "getGPSStatus" -> channelResult.success(NativeTools.getGPSStatus(context))
                "systemShare" -> channelResult.success(NativeTools.systemShare(activity))
                "jumpGPSSetting" -> channelResult.success(NativeTools.jumpGPSSetting(context, activity))
                "jumpAppSetting" -> channelResult.success(NativeTools.jumpAppSetting(context, activity))
                "jumpSystemSetting" -> channelResult.success(NativeTools.jumpSystemSetting(activity))
                ///相机拍照图库选择
                "openSystemGallery" -> GalleryTools.openSystemGallery(activity)
                "openSystemCamera" -> GalleryTools.openSystemCamera(context, activity)
                "saveFileToGallery" -> GalleryTools.saveFileToGallery(context)
                "saveImageToGallery" -> GalleryTools.saveImageToGallery(context)
                ///扫码相机相关
                "scanImagePath" -> ScannerTools.scanImagePath(activity)
                "scanImageUrl" -> ScannerTools.scanImageUrl(activity)
                "scanImageMemory" -> ScannerTools.scanImageMemory(activity)
                "availableCameras" ->
                    channelResult.success(CameraTools.getAvailableCameras(activity))
                "initializeCameras" -> {
                    scannerEvent = EventChannel(plugin.binaryMessenger, scannerEventName)
                    scannerView = ScannerView(plugin.textureRegistry.createSurfaceTexture(), activity)
                    scannerEvent?.setStreamHandler(scannerView)
                    scannerView!!.initCameraView()
                }
                "setFlashMode" -> {
                    val status = call.argument<Boolean>("status")
                    scannerView?.enableTorch(status === java.lang.Boolean.TRUE)
                    channelResult.success("setFlashMode")
                }
                "disposeCameras" -> {
                    scannerView?.dispose()
                    scannerEvent?.setStreamHandler(null)
                    scannerEvent = null
                    channelResult.success("dispose")
                }
                else -> channelResult.notImplemented()
            }

        }

    }

    ///主要是用于获取当前flutter页面所处的Activity.
    override fun onAttachedToActivity(plugin: ActivityPluginBinding) {
        activity = plugin.activity
        mainView = activity.window.decorView
        mainView!!.viewTreeObserver.addOnGlobalLayoutListener(this)
        plugin.addActivityResultListener(this)
    }


    ///主要是用于获取当前flutter页面所处的Activity.
    override fun onDetachedFromActivity() {
    }

    ///Activity注销时
    override fun onReattachedToActivityForConfigChanges(plugin: ActivityPluginBinding) {
        plugin.removeActivityResultListener(this)
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
            val newStatus = r.height().toDouble() / mainView!!.rootView.height.toDouble() < 0.85
            if (keyboardStatus == newStatus) return
            keyboardStatus = newStatus
            curiosityChannel?.invokeMethod("keyboardStatus", newStatus)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?): Boolean {
        if (resultCode == Activity.RESULT_OK) {
            when (requestCode) {
                openSystemGalleryCode -> {
                    val uri: Uri? = intent?.data
                    channelResult.success(Tools.getRealPathFromURI(uri, context))
                }
                openSystemCameraCode -> {
                    val photoPath: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        context.getExternalFilesDir(Environment.DIRECTORY_PICTURES)?.path.toString() + "/TEMP.JPG"
                    } else {
                        intent?.data?.encodedPath.toString()
                    }
                    channelResult.success(photoPath)
                }
                installApkCode -> {
                    channelResult.success("success")
                }
                installPermission -> {
                    //已经打开安装权限
                    NativeTools.installApp(context, activity)
                }
            }
        } else if (resultCode == Activity.RESULT_CANCELED) {
            //未打开安装应用权限
            if (requestCode == installPermission) channelResult.success("not permissions")
            //取消安装
            if (requestCode == installApkCode) channelResult.success("cancel")
        }
        return true
    }


}

