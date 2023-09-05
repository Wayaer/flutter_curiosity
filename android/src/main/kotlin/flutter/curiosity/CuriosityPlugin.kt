package flutter.curiosity

import android.app.Activity
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
        activityBinding.activity.window?.decorView?.viewTreeObserver?.addOnGlobalLayoutListener(
            this
        )
    }

    override fun onReattachedToActivityForConfigChanges(pluginBinding: ActivityPluginBinding) {
        onAttachedToActivity(pluginBinding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onDetachedFromActivity() {
        activityBinding.activity.window?.decorView?.viewTreeObserver?.removeOnGlobalLayoutListener(
            this
        )
    }


    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private var onActivityResultState = false
    private lateinit var result: MethodChannel.Result
    private var keyboardStatus = false

    private var installAppResultCode = 111

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        this.result = result
        when (call.method) {
            "exitApp" -> Tools.exitApp(activityBinding.activity)

            "installApp" -> result.success(
                startActivity(
                    Tools.getInstallAppIntent(
                        context, call
                    ), installAppResultCode
                )
            )

            "getPackageInfo" -> result.success(Tools.getPackageInfo(context))
            "getInstalledApps" -> result.success(
                Tools.getInstalledApps(
                    activityBinding.activity
                )
            )

            "getGPSStatus" -> result.success(
                Tools.getGPSStatus(
                    activityBinding.activity
                )
            )

            "onActivityResult" -> {
                onActivityResultState = true
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }

    private fun startActivity(intent: Intent?, requestCode: Int): Boolean {
        if (intent != null) {
            activityBinding.addActivityResultListener(this)
            try {
                activityBinding.activity.startActivityForResult(
                    intent, requestCode
                )
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
        if (onActivityResultState) {
            val map: MutableMap<String, Any> = HashMap()
            map["requestCode"] = requestCode
            map["resultCode"] = resultCode
            if (intent != null) {
                if (intent.extras != null) map["extras"] = intent.extras.toString()
                if (intent.data != null) map["data"] = intent.data.toString()
            }
            channel.invokeMethod("onActivityResult", map)
        }

        if (requestCode == installAppResultCode) {
            result.success(resultCode == Activity.RESULT_OK)
        }
        activityBinding.removeActivityResultListener(this)
        return true
    }


    override fun onGlobalLayout() {
        val rect = Rect()
        val mainView = activityBinding.activity.window.decorView
        mainView.getWindowVisibleDisplayFrame(rect)
        val newStatus = rect.height().toDouble() / mainView.rootView.height.toDouble() < 0.85
        if (keyboardStatus == newStatus) return
        keyboardStatus = newStatus
        channel.invokeMethod("keyboardStatus", newStatus)
    }

}

