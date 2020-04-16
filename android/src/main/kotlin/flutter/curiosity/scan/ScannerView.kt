package flutter.curiosity.scan

import android.content.Context
import android.content.res.Configuration
import android.hardware.Camera
import android.os.Handler
import android.os.Looper
import android.util.AttributeSet
import com.google.zxing.*
import com.google.zxing.common.HybridBinarizer
import flutter.curiosity.scan.ScanUtils.hints
import flutter.curiosity.scan.core.BarcodeScannerView
import flutter.curiosity.scan.core.DisplayUtils

class ScannerView : BarcodeScannerView {

    interface ResultHandler {
        fun handleResult(rawResult: Result?)
    }

    private val mMultiFormatReader: MultiFormatReader = MultiFormatReader()
    private var mResultHandler: ResultHandler? = null

    constructor(context: Context?) : super(context) {
        initMultiFormatReader()
    }

    constructor(context: Context?, attributeSet: AttributeSet?) : super(context, attributeSet) {
        initMultiFormatReader()
    }

    fun setResultHandler(resultHandler: ResultHandler?) {
        mResultHandler = resultHandler
    }

    private fun initMultiFormatReader() {
        mMultiFormatReader.setHints(hints)
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
            if (DisplayUtils.getScreenOrientation(context) == Configuration.ORIENTATION_PORTRAIT) {
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
                    rawResult = mMultiFormatReader.decodeWithState(bitmap)
                } catch (re: ReaderException) {
                    // continue
                } catch (npe: NullPointerException) {
                    // This is terrible
                } catch (ignored: ArrayIndexOutOfBoundsException) {
                } finally {
                    mMultiFormatReader.reset()
                }
                if (rawResult == null) {
                    val invertedSource = source.invert()
                    bitmap = BinaryBitmap(HybridBinarizer(invertedSource))
                    try {
                        rawResult = mMultiFormatReader.decodeWithState(bitmap)
                    } catch (e: NotFoundException) {
                        // continue
                    } finally {
                        mMultiFormatReader.reset()
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
        } catch (ignored: RuntimeException) {
        }
    }

    private fun buildLuminanceSource(data: ByteArray?, width: Int, height: Int): PlanarYUVLuminanceSource? {
        val rect = getFramingRectInPreview(width, height) ?: return null
        // Go ahead and assume it's YUV rather than die.
        var source: PlanarYUVLuminanceSource? = null
        try {
            source = PlanarYUVLuminanceSource(data, width, height, rect.left, rect.top,
                    rect.width(), rect.height(), false)
        } catch (ignored: Exception) {
        }
        return source
    }
}