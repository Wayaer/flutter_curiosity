package flutter.curiosity

import android.app.Activity
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
    private var activityBinding: ActivityPluginBinding? = null
    private var keyboardListenerRequested = false

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "Curiosity")
        channel.setMethodCallHandler(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        binding.addActivityResultListener(this)
        if (keyboardListenerRequested) {
            decorViewTreeObserver()?.addOnGlobalLayoutListener(this)
        }
    }

    override fun onReattachedToActivityForConfigChanges(pluginBinding: ActivityPluginBinding) {
        onAttachedToActivity(pluginBinding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onDetachedFromActivity() {
        activityBinding?.removeActivityResultListener(this)
        removeKeyboardLayoutListener()
        activityBinding = null
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        removeKeyboardLayoutListener()
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null
        keyboardListenerRequested = false
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "exitApp" -> {
                val activity = activityBinding?.activity
                if (activity == null) {
                    result.success(false)
                } else {
                    result.success(true)
                    Tools.exitApp(activity)
                }
            }

            "installApk" -> {
                val activity = activityBinding?.activity
                result.success(
                    activity != null &&
                        startActivity(activity, Tools.getInstallAppIntent(context, call.arguments as String))
                )
            }

            "getInstalledApps" -> {
                result.success(Tools.getInstalledApps(context))
            }

            "getPackageInfo" -> {
                result.success(getPackageInfo(call.arguments as String))
            }

            "addKeyboardListener" -> {
                val viewTreeObserver = decorViewTreeObserver()
                if (viewTreeObserver == null) {
                    keyboardListenerRequested = false
                    result.success(false)
                } else {
                    viewTreeObserver.addOnGlobalLayoutListener(this)
                    keyboardListenerRequested = true
                    result.success(true)
                }
            }

            "removeKeyboardListener" -> {
                keyboardListenerRequested = false
                result.success(removeKeyboardLayoutListener())
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

    private fun startActivity(activity: Activity, intent: Intent?): Boolean {
        if (intent == null) return false
        return try {
            activity.startActivity(intent)
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
        return false
    }

    override fun onGlobalLayout() {
        if (!::channel.isInitialized) return
        val mainView = activityBinding?.activity?.window?.decorView ?: return
        val rect = Rect()
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

    private fun decorViewTreeObserver(): ViewTreeObserver? {
        return activityBinding?.activity?.window?.decorView?.viewTreeObserver
    }

    private fun removeKeyboardLayoutListener(): Boolean {
        val observer = decorViewTreeObserver() ?: return false
        if (observer.isAlive) {
            observer.removeOnGlobalLayoutListener(this)
        }
        return true
    }
}
