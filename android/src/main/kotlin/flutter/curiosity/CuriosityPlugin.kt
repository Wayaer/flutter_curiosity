package flutter.curiosity

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import com.luck.picture.lib.config.PictureConfig
import flutter.curiosity.gallery.PicturePicker
import flutter.curiosity.scanner.ScannerMethodHandler
import flutter.curiosity.scanner.ScannerMethodHandler.Companion.scannerChannel
import flutter.curiosity.scanner.ScannerTools
import flutter.curiosity.tools.AppInfo
import flutter.curiosity.tools.FileTools
import flutter.curiosity.tools.NativeTools
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener

/**
 * CuriosityPlugin
 */
class CuriosityPlugin : MethodCallHandler, ActivityAware, FlutterPlugin, ActivityResultListener {
    private lateinit var curiosityChannel: MethodChannel
    private lateinit var result: MethodChannel.Result

    companion object {
        lateinit var context: Context
        lateinit var call: MethodCall
        lateinit var activity: Activity
        var scanner = "scanner"
    }

    ///此处是新的插件加载注册方式
    override fun onAttachedToEngine(@NonNull plugin: FlutterPluginBinding) {
        curiosityChannel = MethodChannel(plugin.binaryMessenger, "Curiosity")
        curiosityChannel.setMethodCallHandler(this)
        context = plugin.applicationContext
        ScannerMethodHandler(plugin.binaryMessenger, plugin.textureRegistry)
    }

    ///主要是用于获取当前flutter页面所处的Activity.
    override fun onAttachedToActivity(plugin: ActivityPluginBinding) {
        activity = plugin.activity
        plugin.addActivityResultListener(this)
    }

    ///主要是用于获取当前flutter页面所处的Activity.
    override fun onDetachedFromActivity() {
        onDetachedFromActivity()
    }

    ///Activity注销时
    override fun onReattachedToActivityForConfigChanges(plugin: ActivityPluginBinding) {
        plugin.removeActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        scannerChannel.setMethodCallHandler(null)
        curiosityChannel.setMethodCallHandler(null)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        curiosityChannel.setMethodCallHandler(null)
    }

    ///主要用于接收Flutter端对原生方法调用的实现.
    override fun onMethodCall(_call: MethodCall, _result: MethodChannel.Result) {
        result = _result
        call = _call
        scanner()
        gallery()
        tools()
    }

    private fun tools() {
        when (call.method) {
            "installApp" -> result.success(NativeTools.installApp())
            "getFilePathSize" -> result.success(NativeTools.getFilePathSize())
            "unZipFile" -> result.success(FileTools.unZipFile())
            "callPhone" -> result.success(NativeTools.callPhone())
            "goToMarket" -> result.success(NativeTools.goToMarket())
            "isInstallApp" -> result.success(NativeTools.isInstallApp())
            "exitApp" -> NativeTools.exitApp()
            "getAppInfo" -> result.success(AppInfo.getAppInfo())
            "systemShare" -> result.success(NativeTools.systemShare())
            "getGPSStatus" -> result.success(NativeTools.getGPSStatus())
            "jumpGPSSetting" -> NativeTools.jumpGPSSetting()
        }
    }

    private fun gallery() {
        when (call.method) {
            "openPicker" -> PicturePicker.openPicker(call)
            "openCamera" -> PicturePicker.openCamera(call)
            "deleteCacheDirFile" -> PicturePicker.deleteCacheDirFile(call)
        }
    }


    private fun scanner() {
        when (call.method) {
            "scanImagePath" -> ScannerTools.scanImagePath(call, result)
            "scanImageUrl" -> ScannerTools.scanImageUrl(call, result)
            "scanImageMemory" -> ScannerTools.scanImageMemory(call, result)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?): Boolean {
        if (this::result.isInitialized) {
            if (resultCode == Activity.RESULT_OK && intent != null) {
                if (requestCode == PictureConfig.REQUEST_CAMERA || requestCode == PictureConfig.CHOOSE_REQUEST) {
                    this.result.success(PicturePicker.onResult(requestCode, intent))
                }
            }
        }
        return true
    }


}

