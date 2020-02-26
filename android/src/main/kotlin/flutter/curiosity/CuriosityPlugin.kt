package flutter.curiosity

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
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
        @SuppressLint("StaticFieldLeak")
        lateinit var context: Context
        @SuppressLint("StaticFieldLeak")
        lateinit var activity: Activity
        var scanView = "scanView"
    }

    fun registerWith(registrar: Registrar) {
        val plugin = CuriosityPlugin()
        plugin.methodChannel = MethodChannel(registrar.messenger(), methodChannelName)
        context = registrar.context()
        activity = registrar.activity()
        methodChannel.setMethodCallHandler(plugin)
        registrar.addActivityResultListener(plugin)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
    override fun onDetachedFromActivity() {}
    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, methodChannelName)
        context = binding.applicationContext
        methodChannel.setMethodCallHandler(this)
        binding.platformViewRegistry.registerViewFactory(scanView, ScanViewFactory(binding.binaryMessenger))
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        context
        activity
        methodChannel.setMethodCallHandler(null)
        methodChannel
    }

    override fun onMethodCall(_call: MethodCall, _result: MethodChannel.Result) {
        result = _result
        call = _call
        scan()
        appInfo
        gallery()
        utils()
    }

    private fun utils() {
        when (call.method) {
            "clearAllCookie" -> NativeUtils.clearAllCookie()
            "installApp" -> isArgumentNull("apkPath") { NativeUtils.installApp(call.argument("apkPath")) }
            "getAllCookie" -> isArgumentNull("url") { result.success(NativeUtils.getAllCookie(call.argument("url"))) }
            "getFilePathSize" -> isArgumentNull("filePath") { result.success(NativeUtils.getFilePathSize(call.argument("filePath"))) }
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

    private val appInfo: Unit
        get() {
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

    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent): Boolean {
        if (resultCode == Activity.RESULT_OK) {
            PicturePicker.onResult(requestCode, intent, result)
        }
        result.error("resultCode  not found", "onActivityResult error", null)
        return false
    }

    private fun isArgumentNull(key: String, function: () -> Unit) {
        NativeUtils.isArgumentNull(key, call, result, function)
    }

}