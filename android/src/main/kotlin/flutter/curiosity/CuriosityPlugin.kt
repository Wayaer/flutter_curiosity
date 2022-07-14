package flutter.curiosity

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel


class CuriosityPlugin : ActivityAware, FlutterPlugin {

    private lateinit var channel: MethodChannel
    private lateinit var pluginBinding: FlutterPluginBinding
    private lateinit var activityBinding: ActivityPluginBinding
    private lateinit var methodCall: CuriosityMethodCall


    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        pluginBinding = binding
        channel = MethodChannel(binding.binaryMessenger, "Curiosity")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        methodCall =
            CuriosityMethodCall(activityBinding, pluginBinding, channel)
        channel.setMethodCallHandler(methodCall)
        onDetachedFromActivity()
        activityBinding.activity.window?.decorView?.viewTreeObserver
            ?.addOnGlobalLayoutListener(methodCall)
    }

    override fun onReattachedToActivityForConfigChanges(pluginBinding: ActivityPluginBinding) {
        onAttachedToActivity(pluginBinding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onDetachedFromActivity() {
        activityBinding.activity.window?.decorView?.viewTreeObserver
            ?.removeOnGlobalLayoutListener(methodCall)
        activityBinding.removeRequestPermissionsResultListener(methodCall)
    }


    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        methodCall.event?.dispose()
        channel.setMethodCallHandler(methodCall)
    }

}

