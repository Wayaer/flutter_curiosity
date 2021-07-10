package flutter.curiosity.scanner

import android.app.Activity
import android.graphics.BitmapFactory
import com.google.zxing.*
import com.google.zxing.common.GlobalHistogramBinarizer
import flutter.curiosity.CuriosityPlugin.Companion.call
import flutter.curiosity.CuriosityPlugin.Companion.curiosityEvent
import flutter.curiosity.CuriosityPlugin.Companion.result
import java.util.*
import kotlin.collections.ArrayList


object ScannerTools {
    private val multiFormatReader: MultiFormatReader = MultiFormatReader()

    fun scanImageByte(activity: Activity) {
        val byteArray = call.argument<ByteArray>("byte")!!
        val scanTypes = call.argument<List<String>?>("scanTypes")
        if (scanTypes != null) setHints(scanTypes)
        try {
            val bitmap = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)
            if (bitmap == null) {
                result.success(null)
                return
            }
            val height = bitmap.height
            val width = bitmap.width
            val hints: MutableMap<DecodeHintType, Any> = EnumMap(DecodeHintType::class.java)
            hints[DecodeHintType.TRY_HARDER] = java.lang.Boolean.TRUE
            val array = ImageHelper(activity).getYUV420(
                width, height,
                bitmap
            )
            val resultData = decodeImage(array, height, width, true, 0.0, 0.0, 1.0, 1.0)
            if (resultData != null) {
                bitmap.recycle()
                result.success(scanDataToMap(resultData))
            } else {
                bitmap.recycle()
                result.success(null)
            }
        } catch (e: NotFoundException) {
            result.success(null)
        }
    }


    fun scanImageYUV() {
        val byteArray = call.argument<ByteArray>("byte")!!
        val width = call.argument<Int>("width")!!
        val height = call.argument<Int>("height")!!
        val topRatio = call.argument<Double>("topRatio")!!
        val leftRatio = call.argument<Double>("leftRatio")!!
        val widthRatio = call.argument<Double>("widthRatio")!!
        val heightRatio = call.argument<Double>("heightRatio")!!
        val scanTypes = call.argument<List<String>?>("scanTypes")
        if (scanTypes != null) setHints(scanTypes)
        val resultData = decodeImage(
            byteArray,
            height,
            width,
            true,
            topRatio,
            leftRatio,
            widthRatio,
            heightRatio
        )
        if (resultData != null) {
            curiosityEvent?.sendEvent(scanDataToMap(resultData))
            return
        }
        curiosityEvent?.sendEvent(null)
    }


    fun scanDataToMap(result: Result): Map<String, Any> {
        val data: MutableMap<String, Any> = HashMap()
        data["code"] = result.text
        data["type"] = result.barcodeFormat.name
        return data
    }

    // 识别 Image 中的二维码
    fun decodeImage(
        byteArray: ByteArray,
        imageHeight: Int,
        imageWidth: Int,
        verticalScreen: Boolean,
        topRatio: Double,
        leftRatio: Double,
        widthRatio: Double,
        heightRatio: Double
    ): Result? {
        val width: Int
        val height: Int
        val left: Int
        val top: Int
        val identifyWidth: Int
        val identifyHeight: Int
        val array: ByteArray

        if (verticalScreen) {
            array = rotateByteArray(byteArray, imageWidth, imageHeight)
            width = imageHeight
            height = imageWidth
            top = (height * topRatio).toInt()
            left = (width * leftRatio).toInt()
            identifyWidth = (width * widthRatio).toInt()
            identifyHeight = (height * heightRatio).toInt()

        } else {
            width = imageWidth
            height = imageHeight
            top = (width * leftRatio).toInt()
            left = (height * topRatio).toInt()
            identifyWidth = (width * heightRatio).toInt()
            identifyHeight = (height * widthRatio).toInt()
            array = byteArray
        }

        val source = PlanarYUVLuminanceSource(
            array, width, height, left,
            top,
            identifyWidth, identifyHeight, false
        )
        val binaryBitmap = BinaryBitmap(GlobalHistogramBinarizer(source))
        var result: Result? = null
        try {
            result = multiFormatReader.decodeWithState(binaryBitmap)
        } catch (e: NotFoundException) {
            if (verticalScreen) result =
                decodeImage(
                    byteArray,
                    imageHeight,
                    imageWidth,
                    false,
                    topRatio,
                    leftRatio,
                    widthRatio,
                    heightRatio
                )
        }
        return result
    }

    // 旋转图片
    private fun rotateByteArray(byteArray: ByteArray, width: Int, height: Int): ByteArray {
        val rotatedData = ByteArray(byteArray.size)
        for (y in 0 until height) {
            for (x in 0 until width) {
                rotatedData[x * height + height - y - 1] =
                    byteArray[x + y * width]
            }
        }
        return rotatedData
    }

    fun setHints(scanTypes: List<String>) {
        val decodeFormats: MutableCollection<BarcodeFormat> = ArrayList()
        if (!scanTypes.isNullOrEmpty()) {
            scanTypes.forEach { type ->
                when (type) {
                    "upcA" -> decodeFormats.add(BarcodeFormat.UPC_A)
                    "upcE" -> decodeFormats.add(BarcodeFormat.UPC_E)
                    "ean13" -> decodeFormats.add(BarcodeFormat.EAN_13)
                    "ean8" -> decodeFormats.add(BarcodeFormat.EAN_8)
                    "codaBar" -> decodeFormats.add(BarcodeFormat.CODABAR)
                    "code39" -> decodeFormats.add(BarcodeFormat.CODE_39)
                    "code93" -> decodeFormats.add(BarcodeFormat.CODE_93)
                    "code128" -> decodeFormats.add(BarcodeFormat.CODE_128)
                    "itf" -> decodeFormats.add(BarcodeFormat.ITF)
                    "rss14" -> decodeFormats.add(BarcodeFormat.RSS_14)
                    "rssExpanded" -> decodeFormats.add(BarcodeFormat.RSS_EXPANDED)
                    "qrCode" -> decodeFormats.add(BarcodeFormat.QR_CODE)
                    "aztec" -> decodeFormats.add(BarcodeFormat.AZTEC)
                    "dataMatrix" -> decodeFormats.add(BarcodeFormat.DATA_MATRIX)
                    "maxICode" -> decodeFormats.add(BarcodeFormat.MAXICODE)
                    "pdf417" -> decodeFormats.add(BarcodeFormat.PDF_417)
                    "upcEanExtension" -> decodeFormats.add(BarcodeFormat.UPC_EAN_EXTENSION)
                }
            }
        } else {
            decodeFormats.add(BarcodeFormat.QR_CODE)
        }
        val hints: MutableMap<DecodeHintType, Any> = mutableMapOf()
        hints[DecodeHintType.CHARACTER_SET] = "UTF-8"
        hints[DecodeHintType.POSSIBLE_FORMATS] = decodeFormats
        hints[DecodeHintType.TRY_HARDER] = true
        multiFormatReader.setHints(hints)
    }
}