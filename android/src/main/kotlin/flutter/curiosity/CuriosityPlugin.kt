package flutter.curiosity

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import androidx.annotation.NonNull
import com.luck.picture.lib.config.PictureConfig
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
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.view.TextureRegistry


/**
 * CuriosityPlugin
 */
class CuriosityPlugin : MethodCallHandler, ActivityAware, FlutterPlugin, ActivityResultListener {
    private lateinit var curiosityChannel: MethodChannel
    private var scannerView: ScannerView? = null
    private lateinit var registry: TextureRegistry
    private lateinit var eventChannel: EventChannel

    companion object {
        var openSystemGalleryCode = 100
        var openSystemCameraCode = 101
        var installApkCode = 102
        var installPermission = 103
        lateinit var context: Context
        lateinit var call: MethodCall
        lateinit var activity: Activity
        lateinit var channelResult: MethodChannel.Result
    }

    override fun onAttachedToEngine(@NonNull plugin: FlutterPluginBinding) {
        val curiosity = "Curiosity"
        curiosityChannel = MethodChannel(plugin.binaryMessenger, curiosity)
        curiosityChannel.setMethodCallHandler(this)
        context = plugin.applicationContext
        registry = plugin.textureRegistry
        eventChannel = EventChannel(plugin.binaryMessenger, "$curiosity/event")

    }

    ///主要是用于获取当前flutter页面所处的Activity.
    override fun onAttachedToActivity(plugin: ActivityPluginBinding) {
        activity = plugin.activity
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
        curiosityChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        curiosityChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    ///主要用于接收Flutter端对原生方法调用的实现.
    override fun onMethodCall(_call: MethodCall, _result: MethodChannel.Result) {
        channelResult = _result
        call = _call
        scanner()
        gallery()
        tools()
    }

    private fun tools() {
        when (call.method) {
            "installApp" -> NativeTools.installApp()
            "getFilePathSize" -> channelResult.success(NativeTools.getFilePathSize())
            "unZipFile" -> channelResult.success(NativeTools.unZipFile())
            "callPhone" -> channelResult.success(NativeTools.callPhone())
            "goToMarket" -> channelResult.success(NativeTools.goToMarket())
            "isInstallApp" -> channelResult.success(NativeTools.isInstallApp())
            "exitApp" -> NativeTools.exitApp()
            "getAppInfo" -> channelResult.success(NativeTools.getAppInfo())
            "systemShare" -> channelResult.success(NativeTools.systemShare())
            "getGPSStatus" -> channelResult.success(NativeTools.getGPSStatus())
            "jumpGPSSetting" -> NativeTools.jumpGPSSetting()
            "jumpAppSetting" -> NativeTools.jumpAppSetting()
        }
    }

    private fun gallery() {
        when (call.method) {
            "openImagePicker" -> GalleryTools.openImagePicker()
            "deleteCacheDirFile" -> GalleryTools.deleteCacheDirFile()
            "openSystemGallery" -> GalleryTools.openSystemGallery()
            "openSystemCamera" -> GalleryTools.openSystemCamera()
            "saveFileToGallery" -> GalleryTools.saveFileToGallery()
            "saveImageToGallery" -> GalleryTools.saveImageToGallery()
        }
    }


    private fun scanner() {
        when (call.method) {
            "scanImagePath" -> ScannerTools.scanImagePath()
            "scanImageUrl" -> ScannerTools.scanImageUrl()
            "scanImageMemory" -> ScannerTools.scanImageMemory()
            "availableCameras" ->
                channelResult.success(CameraTools.getAvailableCameras(activity))
            "initializeCameras" -> {
                scannerView = ScannerView(registry.createSurfaceTexture())
                eventChannel.setStreamHandler(scannerView)
                scannerView!!.initCameraView()
            }
            "setFlashMode" -> {
                val status = call.argument<Boolean>("status")
                scannerView?.enableTorch(status === java.lang.Boolean.TRUE)
                channelResult.success("setFlashMode")
            }
            "disposeCameras" -> {
                scannerView?.dispose()
                eventChannel.setStreamHandler(null)
                channelResult.success("dispose")
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?): Boolean {
        if (resultCode == Activity.RESULT_OK) {
            if (requestCode == PictureConfig.REQUEST_CAMERA || requestCode == PictureConfig.CHOOSE_REQUEST) {
                channelResult.success(GalleryTools.onResult(intent))
            } else if (requestCode == openSystemGalleryCode) {
                val uri: Uri? = intent?.data
                channelResult.success(Tools.getRealPathFromURI(uri));
            } else if (requestCode == openSystemCameraCode) {
                val photoPath: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    context.getExternalFilesDir(Environment.DIRECTORY_PICTURES)?.path.toString() + "/TEMP.JPG"
                } else {
                    intent?.data?.encodedPath.toString();
                }
                channelResult.success(photoPath);
            } else if (requestCode == installApkCode) {
                channelResult.success("success")
            } else if (requestCode == installPermission) {
                //已经打开安装权限
                NativeTools.installApp()
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

