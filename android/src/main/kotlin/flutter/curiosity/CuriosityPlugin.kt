package flutter.curiosity

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import com.luck.picture.lib.config.PictureConfig
import flutter.curiosity.gallery.PicturePicker
import flutter.curiosity.scan.ScanUtils
import flutter.curiosity.scan.ScanViewFactory
import flutter.curiosity.utils.AppInfo
import flutter.curiosity.utils.FileUtils
import flutter.curiosity.utils.NativeUtils
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
    private lateinit var methodChannel: MethodChannel
    private lateinit var result: MethodChannel.Result

    companion object {
        //        此处是旧的插件加载注册方式
//        @JvmStatic
//        fun registerWith(registrar: Registrar) {
//            val plugin = CuriosityPlugin()
//            val methodChannel = MethodChannel(registrar.messenger(), "Curiosity")
//            context = registrar.context()
//            activity = registrar.activity()
//            methodChannel.setMethodCallHandler(plugin)
//            registrar.addActivityResultListener(plugin)
//        }
        lateinit var context: Context
        lateinit var call: MethodCall
        lateinit var activity: Activity
        var scanView = "scanView"

    }

    ///此处是新的插件加载注册方式
    override fun onAttachedToEngine(@NonNull pluginBinding: FlutterPluginBinding) {
        methodChannel = MethodChannel(pluginBinding.binaryMessenger, "Curiosity")
        methodChannel.setMethodCallHandler(this)
        context = pluginBinding.applicationContext
        pluginBinding.platformViewRegistry.registerViewFactory(scanView, ScanViewFactory(pluginBinding.binaryMessenger))
    }

    ///主要是用于获取当前flutter页面所处的Activity.
    override fun onAttachedToActivity(pluginBinding: ActivityPluginBinding) {
        activity = pluginBinding.activity
        pluginBinding.addActivityResultListener(this)
    }

    ///主要是用于获取当前flutter页面所处的Activity.
    override fun onDetachedFromActivity() {

    }

    ///Activity注销时
    override fun onReattachedToActivityForConfigChanges(pluginBinding: ActivityPluginBinding) {
        pluginBinding.removeActivityResultListener(this)
    }


    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
    }

    ///主要用于接收Flutter端对原生方法调用的实现.
    override fun onMethodCall(_call: MethodCall, _result: MethodChannel.Result) {
        result = _result
        call = _call
        scan()
        gallery()
        utils()
    }

    private fun utils() {
        when (call.method) {
            "clearAllCookie" -> NativeUtils.clearAllCookie()
            "installApp" -> result.success(NativeUtils.installApp())
            "getAllCookie" -> result.success(NativeUtils.getAllCookie())
            "getFilePathSize" -> result.success(NativeUtils.getFilePathSize())
            "unZipFile" -> result.success(FileUtils.unZipFile())
            "deleteDirectory" -> result.success(FileUtils.deleteDirectory())
            "deleteFile" -> result.success(FileUtils.deleteFile())
            "callPhone" -> result.success(NativeUtils.callPhone())
            "goToMarket" -> result.success(NativeUtils.goToMarket())
            "isInstallApp" -> result.success(NativeUtils.isInstallApp())
            "exitApp" -> NativeUtils.exitApp()
            "getAppInfo" -> result.success(AppInfo.getAppInfo())
            "getDirectoryAllName" -> result.success(FileUtils.getDirectoryAllName())
        }
    }

    private fun gallery() {
        when (call.method) {
            "openPicker" -> PicturePicker.openPicker(call)
            "openCamera" -> PicturePicker.openCamera(call)
            "deleteCacheDirFile" -> PicturePicker.deleteCacheDirFile(call)
        }
    }


    private fun scan() {
        when (call.method) {
            "scanImagePath" -> ScanUtils.scanImagePath(call, result)
            "scanImageUrl" -> ScanUtils.scanImageUrl(call, result)
            "scanImageMemory" -> ScanUtils.scanImageMemory(call, result)
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


    //以下暂时不知道的方法
    override fun onDetachedFromActivityForConfigChanges() {
        activity
    }


}

