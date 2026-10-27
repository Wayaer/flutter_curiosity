package flutter.curiosity

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Rect
import android.os.Build
import android.util.Log
import android.view.ViewTreeObserver
import flutter.curiosity.Tools.map
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class CuriosityPlugin :
    ActivityAware,
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    PluginRegistry.ActivityResultListener,
    ViewTreeObserver.OnGlobalLayoutListener {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var activityBinding: ActivityPluginBinding

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "Curiosity")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        channel.setMethodCallHandler(this)
        binding.addActivityResultListener(this)
    }

    override fun onReattachedToActivityForConfigChanges(pluginBinding: ActivityPluginBinding) {
        onAttachedToActivity(pluginBinding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onDetachedFromActivity() {
        if (::activityBinding.isInitialized) {
            activityBinding.removeActivityResultListener(this)
            val viewTreeObserver = activityBinding.activity.window?.decorView?.viewTreeObserver
            viewTreeObserver?.removeOnGlobalLayoutListener(this)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "exitApp" -> {
                result.success(true)
                Tools.exitApp(activityBinding.activity)
            }

            "installApk" -> {
                result.success(
                    startActivity(Tools.getInstallAppIntent(context, call.arguments as String))
                )
            }

            "getInstalledApps" -> {
                result.success(Tools.getInstalledApps(context))
            }

            "getPackageInfo" -> {
                result.success(getPackageInfo(call.arguments as String))
            }

            "addKeyboardListener" -> {
                val viewTreeObserver = activityBinding.activity.window?.decorView?.viewTreeObserver
                viewTreeObserver?.addOnGlobalLayoutListener(this)
                result.success(viewTreeObserver != null)
            }

            "removeKeyboardListener" -> {
                val viewTreeObserver = activityBinding.activity.window?.decorView?.viewTreeObserver
                viewTreeObserver?.removeOnGlobalLayoutListener(this)
                result.success(viewTreeObserver != null)
            }

            "getGPSStatus" -> {
                result.success(Tools.getGPSStatus(context))
            }

            "saveBytesImageToGallery" -> {
                result.success(ImageGalleryTools.saveBytesImageToGallery(context, call))
            }

            "saveFilePathToGallery" -> {
                result.success(ImageGalleryTools.saveFilePathToGallery(context, call))
            }

            else -> result.notImplemented()
        }
    }

    private fun getPackageInfo(packageName: String): Map<String, Any?>? {
        return try {
            val pm = context.packageManager
            val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                pm.getPackageInfo(packageName, 0)
            }
            packageInfo.map(pm)
        } catch (e: PackageManager.NameNotFoundException) {
            Log.d("CuriosityPlugin", "Package not found: $packageName", e)
            null
        }
    }

    private fun startActivity(intent: Intent?): Boolean {
        if (intent == null) return false
        return try {
            activityBinding.activity.startActivity(intent)
            true
        } catch (e: Exception) {
            Log.d("CuriosityPlugin", "startActivity failed", e)
            false
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?): Boolean {
        val map: MutableMap<String, Any> = HashMap()
        map["requestCode"] = requestCode
        map["resultCode"] = resultCode
        if (intent != null) {
            if (intent.extras != null) map["extras"] = intent.extras.toString()
            if (intent.data != null) map["data"] = intent.data.toString()
        }
        if (::channel.isInitialized) {
            channel.invokeMethod("onActivityResult", map)
        }
        return true
    }

    override fun onGlobalLayout() {
        if (!::activityBinding.isInitialized || !::channel.isInitialized) return
        val rect = Rect()
        val mainView = activityBinding.activity.window.decorView
        mainView.getWindowVisibleDisplayFrame(rect)
        val density = context.resources.displayMetrics.density
        channel.invokeMethod(
            "onKeyboardStatus",
            mapOf(
                "density" to density,
                "rootHeight" to mainView.rootView.height,
                "rootWidth" to mainView.rootView.width,
                "bottom" to rect.bottom,
                "top" to rect.top,
                "left" to rect.left,
                "right" to rect.right,
            )
        )
    }
}
