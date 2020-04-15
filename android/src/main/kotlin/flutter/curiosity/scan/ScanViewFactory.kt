package flutter.curiosity.scan

import android.content.Context
import com.google.zxing.Result
import flutter.curiosity.CuriosityPlugin
import flutter.curiosity.utils.Utils
import io.flutter.plugin.common.*
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


class ScanViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, i: Int, any: Any): PlatformView {
        return Scanner(context, messenger, i, any);
//        return ScanView(context, messenger, i, any);
    }
}

class Scanner internal constructor(context: Context, messenger: BinaryMessenger, i: Int, any: Any) : PlatformView,
        EventChannel.StreamHandler,
        MethodChannel.MethodCallHandler, ScannerView.ResultHandler {
    private var scannerView: ScannerView = ScannerView(context)
    private var flashStatus: Boolean = false;
    private lateinit var eventSink: EventChannel.EventSink

    init {
        val anyMap = any as Map<*, *>
        EventChannel(messenger, "${CuriosityPlugin.scanView}/$i/event").setStreamHandler(this)
        MethodChannel(messenger, "${CuriosityPlugin.scanView}/$i/method").setMethodCallHandler(this)
        scannerView.setAutoFocus(true)
        scannerView.setAspectTolerance(0.5f)
        scannerView.setResultHandler(this)
        scannerView.startCamera()
        flashStatus = scannerView.flash
    }

    override fun getView(): ScannerView? {
        return scannerView
    }

    override fun dispose() {
        scannerView.stopCamera()
    }

    override fun onListen(o: Any, eventSink: EventChannel.EventSink) {
        this.eventSink = eventSink
    }

    override fun onCancel(arguments: Any?) {
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "startScan" -> scannerView.startCamera()
            "stopScan" -> scannerView.stopCamera()
            "setFlashMode" -> {
                Utils.logInfo("status" + methodCall.argument<Boolean>("status").toString())
                val status = methodCall.argument<Boolean>("status")
                if (status != null) {
                    scannerView.flash = status
                    result.success(scannerView.flash)
                }
            }
            "getFlashMode" -> result.success(scannerView.flash)
            else -> result.notImplemented()
        }
    }

    override fun handleResult(rawResult: Result?) {
        eventSink.success(ScanUtils.scanDataToMap(rawResult))
    }

}