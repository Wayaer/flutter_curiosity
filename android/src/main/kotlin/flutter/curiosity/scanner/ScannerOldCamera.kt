package flutter.curiosity.scanner

import android.content.Context
import android.content.res.Configuration
import android.hardware.Camera
import android.os.Handler
import android.os.Looper
import android.util.AttributeSet
import com.google.zxing.*
import com.google.zxing.common.HybridBinarizer
import flutter.curiosity.CuriosityPlugin
import flutter.curiosity.scanner.core.BarcodeScannerView
import flutter.curiosity.scanner.core.DisplayTools
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.util.*

class ScannerOldCamera internal constructor(context: Context, messenger: BinaryMessenger, i: Int, any: Any) : PlatformView,
        EventChannel.StreamHandler, MethodChannel.MethodCallHandler, ScannerView.ResultHandler {
    private var scannerView: ScannerView = ScannerView(context)
    private var flashStatus: Boolean = false;
    private lateinit var eventSink: EventChannel.EventSink

    init {
        val anyMap = any as Map<*, *>
        EventChannel(messenger, "${CuriosityPlugin.scanner}/$i/event").setStreamHandler(this)
        MethodChannel(messenger, "${CuriosityPlugin.scanner}/$i/method").setMethodCallHandler(this)
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
            "setFlashMode" -> {
                val status = methodCall.argument<Boolean>("status")
                if (status != null) {
                    scannerView.flash = status
                    result.success(scannerView.flash)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun handleResult(rawResult: Result?) {
        eventSink.success(ScannerTools.scanDataToMap(rawResult))
    }

}

class ScannerView : BarcodeScannerView {
    interface ResultHandler {
        fun handleResult(rawResult: Result?)
    }

    private var mMultiFormatReader: MultiFormatReader? = null
    private var mFormats: List<BarcodeFormat>? = null
    private var mResultHandler: ResultHandler? = null

    companion object {
        val ALL_FORMATS: MutableList<BarcodeFormat> = ArrayList()

        init {
            ALL_FORMATS.add(BarcodeFormat.AZTEC)
            ALL_FORMATS.add(BarcodeFormat.CODABAR)
            ALL_FORMATS.add(BarcodeFormat.CODE_39)
            ALL_FORMATS.add(BarcodeFormat.CODE_93)
            ALL_FORMATS.add(BarcodeFormat.CODE_128)
            ALL_FORMATS.add(BarcodeFormat.DATA_MATRIX)
            ALL_FORMATS.add(BarcodeFormat.EAN_8)
            ALL_FORMATS.add(BarcodeFormat.EAN_13)
            ALL_FORMATS.add(BarcodeFormat.ITF)
            ALL_FORMATS.add(BarcodeFormat.MAXICODE)
            ALL_FORMATS.add(BarcodeFormat.PDF_417)
            ALL_FORMATS.add(BarcodeFormat.QR_CODE)
            ALL_FORMATS.add(BarcodeFormat.RSS_14)
            ALL_FORMATS.add(BarcodeFormat.RSS_EXPANDED)
            ALL_FORMATS.add(BarcodeFormat.UPC_A)
            ALL_FORMATS.add(BarcodeFormat.UPC_E)
            ALL_FORMATS.add(BarcodeFormat.UPC_EAN_EXTENSION)
        }
    }

    constructor(context: Context?) : super(context) {
        initMultiFormatReader()
    }

    constructor(context: Context?, attributeSet: AttributeSet?) : super(context, attributeSet) {
        initMultiFormatReader()
    }


    fun setResultHandler(resultHandler: ResultHandler?) {
        mResultHandler = resultHandler
    }

    private val formats: Collection<BarcodeFormat>
        get() = (if (mFormats == null) {
            ALL_FORMATS
        } else mFormats) as Collection<BarcodeFormat>

    private fun initMultiFormatReader() {
        val hints: MutableMap<DecodeHintType, Any?> = EnumMap(DecodeHintType::class.java)
        hints[DecodeHintType.POSSIBLE_FORMATS] = formats
        mMultiFormatReader = MultiFormatReader()
        mMultiFormatReader!!.setHints(hints)
    }

    override fun onPreviewFrame(byteArray: ByteArray, camera: Camera) {
        var data: ByteArray? = byteArray
        if (mResultHandler == null) {
            return
        }
        try {
            val parameters = camera.parameters
            val size = parameters.previewSize
            var width = size.width
            var height = size.height
            if (DisplayTools.getScreenOrientation(context) == Configuration.ORIENTATION_PORTRAIT) {
                val rotationCount = rotationCount
                if (rotationCount == 1 || rotationCount == 3) {
                    val tmp = width
                    width = height
                    height = tmp
                }
                data = getRotatedData(data, camera)
            }
            var rawResult: Result? = null
            val source = buildLuminanceSource(data, width, height)
            if (source != null) {
                var bitmap = BinaryBitmap(HybridBinarizer(source))
                try {
                    rawResult = mMultiFormatReader!!.decodeWithState(bitmap)
                } catch (re: ReaderException) {
                    // continue
                } catch (npe: NullPointerException) {
                    // This is terrible
                } catch (aoe: ArrayIndexOutOfBoundsException) {
                } finally {
                    mMultiFormatReader!!.reset()
                }
                if (rawResult == null) {
                    val invertedSource = source.invert()
                    bitmap = BinaryBitmap(HybridBinarizer(invertedSource))
                    try {
                        rawResult = mMultiFormatReader!!.decodeWithState(bitmap)
                    } catch (e: NotFoundException) {
                        // continue
                    } finally {
                        mMultiFormatReader!!.reset()
                    }
                }
            }
            val finalRawResult = rawResult
            if (finalRawResult != null) {
                val handler = Handler(Looper.getMainLooper())
                handler.post { // Stopping the preview can take a little long.
                    // So we want to set result handler to null to discard subsequent calls to
                    // onPreviewFrame.
                    val tmpResultHandler = mResultHandler
                    mResultHandler = null
                    stopCameraPreview()
                    tmpResultHandler?.handleResult(finalRawResult)
                }
            } else {
                camera.setOneShotPreviewCallback(this)
            }
        } catch (e: RuntimeException) {
        }
    }

    private fun buildLuminanceSource(data: ByteArray?, width: Int, height: Int): PlanarYUVLuminanceSource? {
        val rect = getFramingRectInPreview(width, height) ?: return null
        var source: PlanarYUVLuminanceSource? = null
        try {
            source = PlanarYUVLuminanceSource(data, width, height, rect.left, rect.top,
                    rect.width(), rect.height(), false)
        } catch (e: Exception) {
        }
        return source
    }
}