package flutter.curiosity

import android.content.Context
import android.content.Intent
import android.graphics.Rect
import android.util.Log
import android.view.ViewTreeObserver
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class CuriosityPlugin : ActivityAware, FlutterPlugin, MethodChannel.MethodCallHandler,
    PluginRegistry.ActivityResultListener, ViewTreeObserver.OnGlobalLayoutListener {

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
        activityBinding.removeActivityResultListener(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private lateinit var result: MethodChannel.Result

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        this.result = result
        when (call.method) {
            "exitApp" -> Tools.exitApp(activityBinding.activity)
            "installApk" -> result.success(
                startActivity(Tools.getInstallAppIntent(context, call.arguments as String))
            )

            "getInstalledApps" -> result.success(
                Tools.getInstalledApps(activityBinding.activity)
            )

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

            "getGPSStatus" -> result.success(
                Tools.getGPSStatus(activityBinding.activity)
            )

            "saveBytesImageToGallery" -> {
                result.success(ImageGalleryTools.saveBytesImage(context, call))
            }

            "saveFilePathToGallery" -> {
                val filePath = call.argument<String>("filePath")!!
                val name = call.argument<String?>("name")
                result.success(ImageGalleryTools.saveFilePath(context, filePath, name))
            }

            else -> result.notImplemented()
        }
    }

    private fun startActivity(intent: Intent?): Boolean {
        if (intent != null) {
            try {
                activityBinding.activity.startActivity(intent)
                return true
            } catch (e: Exception) {
                Log.d("ActivityException", e.toString())
            }
        }
        return false
    }


    override fun onActivityResult(
        requestCode: Int, resultCode: Int, intent: Intent?
    ): Boolean {
        val map: MutableMap<String, Any> = HashMap()
        map["requestCode"] = requestCode
        map["resultCode"] = resultCode
        if (intent != null) {
            if (intent.extras != null) map["extras"] = intent.extras.toString()
            if (intent.data != null) map["data"] = intent.data.toString()
        }
        channel.invokeMethod("onActivityResult", map)
        return true
    }


    override fun onGlobalLayout() {
        val rect = Rect()
        val mainView = activityBinding.activity.window.decorView
        mainView.getWindowVisibleDisplayFrame(rect)
        val density = context.resources.displayMetrics.density
        channel.invokeMethod(
            "onKeyboardStatus", mapOf(
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

