package flutter.curiosity

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
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
import io.flutter.plugin.common.PluginRegistry.Registrar

/**
 * CuriosityPlugin
 */
class CuriosityPlugin : MethodCallHandler, ActivityAware, FlutterPlugin, ActivityResultListener {
    private val methodChannelName = "Curiosity"
    private lateinit var result: MethodChannel.Result
    private lateinit var call: MethodCall
    private lateinit var methodChannel: MethodChannel

    companion object {
        //此处是旧的插件加载注册方式
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val plugin = CuriosityPlugin()
            val methodChannel = MethodChannel(registrar.messenger(), "Curiosity")
            context = registrar.context()
            activity = registrar.activity()
            methodChannel.setMethodCallHandler(plugin)
            registrar.addActivityResultListener(plugin)
        }

        @SuppressLint("StaticFieldLeak")
        lateinit var context: Context

        @SuppressLint("StaticFieldLeak")
        lateinit var activity: Activity
        var scanView = "scanView"

    }

    ///此处是新的插件加载注册方式
    override fun onAttachedToEngine(@NonNull pluginBinding: FlutterPluginBinding) {
        methodChannel = MethodChannel(pluginBinding.binaryMessenger, methodChannelName)
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
        appInfo()
        gallery()
        utils()
    }

    private fun utils() {
        when (call.method) {
            "clearAllCookie" -> NativeUtils.clearAllCookie()
            "installApp" -> isArgumentNull("apkPath") { NativeUtils.installApp(call.argument("apkPath")) }
            "getAllCookie" -> isArgumentNull("url") { result.success(NativeUtils.getAllCookie(call.argument("url"))) }
            "getFilePathSize" -> isArgumentNull("filePath") { result.success(NativeUtils.getFilePathSize(call.argument("filePath"))) }
            "unZipFile" -> isArgumentNull("filePath") { result.success(FileUtils.unZipFile(call.argument("filePath"))) }
            "deleteDirectory" -> isArgumentNull("directoryPath") { FileUtils.deleteDirectory(call.argument("directoryPath")) }
            "deleteFile" -> isArgumentNull("filePath") { FileUtils.deleteFile(call.argument("filePath")) }
            "goToMarket" -> isArgumentNull("packageName") {
                NativeUtils.goToMarket(call.argument("packageName"), call.argument
                ("marketPackageName"))
            }
            "isInstallApp" -> isArgumentNull("packageName") { result.success(NativeUtils.isInstallApp(call.argument("packageName"))) }
            "exitApp" -> NativeUtils.exitApp()
        }
    }

    private fun gallery() {
        when (call.method) {
            "openSelect" -> PicturePicker.openSelect(call)
            "openCamera" -> PicturePicker.openCamera(call)
            "deleteCacheDirFile" -> PicturePicker.deleteCacheDirFile(call)
        }
    }

    private fun appInfo() {
        when (call.method) {
            "getAppInfo" -> try {
                result.success(AppInfo.getAppInfo())
            } catch (e: PackageManager.NameNotFoundException) {
                result.error("Name not found", e.message, null)
            }
            "getDirectoryAllName" -> result.success(FileUtils.getDirectoryAllName(call))
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
        if (resultCode == Activity.RESULT_OK && intent != null) {
            if (requestCode == PictureConfig.REQUEST_CAMERA || requestCode == PictureConfig.CHOOSE_REQUEST) {
                PicturePicker.onResult(requestCode, intent, result)
            }
        }
        return true
    }

    //以下暂时不知道的方法
    private fun isArgumentNull(key: String, function: () -> Unit) {
        NativeUtils.isArgumentNull(key, call, result, function)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity
    }


}

