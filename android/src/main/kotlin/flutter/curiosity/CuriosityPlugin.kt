package flutter.curiosity

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.annotation.NonNull
import com.luck.picture.lib.config.PictureConfig
import flutter.curiosity.gallery.PicturePicker
import flutter.curiosity.scanner.CameraTools
import flutter.curiosity.scanner.ScannerTools
import flutter.curiosity.scanner.ScannerView
import flutter.curiosity.tools.AppInfo
import flutter.curiosity.tools.FileTools
import flutter.curiosity.tools.NativeTools
import flutter.curiosity.tools.Tools
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.view.TextureRegistry

/**
 * CuriosityPlugin
 */
class CuriosityPlugin : MethodCallHandler, ActivityAware, FlutterPlugin, EventChannel.StreamHandler, ActivityResultListener {
    private lateinit var curiosityChannel: MethodChannel
    private var scannerView: ScannerView? = null
    private lateinit var binaryMessenger: BinaryMessenger
    private lateinit var textureRegistry: TextureRegistry

    companion object {
        lateinit var context: Context
        lateinit var call: MethodCall
        lateinit var activity: Activity
        lateinit var channelResult: MethodChannel.Result
        lateinit var eventSink: EventChannel.EventSink
    }

    override fun onAttachedToEngine(@NonNull plugin: FlutterPluginBinding) {
        val curiosity = "Curiosity"
        curiosityChannel = MethodChannel(plugin.binaryMessenger, curiosity)
        curiosityChannel.setMethodCallHandler(this)
        context = plugin.applicationContext
        binaryMessenger = plugin.binaryMessenger
        textureRegistry = plugin.textureRegistry
        val eventChannel = EventChannel(binaryMessenger, "$curiosity/event")
        eventChannel.setStreamHandler(this)
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
        eventSink.endOfStream()
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        curiosityChannel.setMethodCallHandler(null)
        eventSink.endOfStream()
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
            "installApp" -> channelResult.success(NativeTools.installApp())
            "getFilePathSize" -> channelResult.success(NativeTools.getFilePathSize())
            "unZipFile" -> channelResult.success(FileTools.unZipFile())
            "callPhone" -> channelResult.success(NativeTools.callPhone())
            "goToMarket" -> channelResult.success(NativeTools.goToMarket())
            "isInstallApp" -> channelResult.success(NativeTools.isInstallApp())
            "exitApp" -> NativeTools.exitApp()
            "getAppInfo" -> channelResult.success(AppInfo.getAppInfo())
            "systemShare" -> channelResult.success(NativeTools.systemShare())
            "getGPSStatus" -> channelResult.success(NativeTools.getGPSStatus())
            "jumpGPSSetting" -> NativeTools.jumpGPSSetting()
        }
    }

    private fun gallery() {
        when (call.method) {
            "openPicker" -> PicturePicker.openPicker()
            "openCamera" -> PicturePicker.openCamera()
            "deleteCacheDirFile" -> PicturePicker.deleteCacheDirFile()
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
                scannerView = ScannerView(textureRegistry.createSurfaceTexture())
                scannerView!!.initCameraView()
            }
            "setFlashMode" -> {
                val status = call.argument<Boolean>("status")
                scannerView?.enableTorch(status === java.lang.Boolean.TRUE)
            }
            "disposeCameras" -> {
                scannerView?.dispose()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, intent: Intent?): Boolean {
        if (resultCode == Activity.RESULT_OK && intent != null) {
            if (requestCode == PictureConfig.REQUEST_CAMERA || requestCode == PictureConfig.CHOOSE_REQUEST) {
                channelResult.success(PicturePicker.onResult(requestCode, intent))
            }
        }
        return true
    }

    override fun onListen(arguments: Any, events: EventChannel.EventSink) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink
    }


}

