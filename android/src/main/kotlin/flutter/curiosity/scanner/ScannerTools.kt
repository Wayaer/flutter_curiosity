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
        val byteArray = call.arguments as ByteArray
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


    fun scanDataToMap(result: Result?): Map<String, Any> {
        val data: MutableMap<String, Any> = HashMap()
        if (result == null) {
            data["code"] = ""
            data["type"] = ""
        } else {
            data["code"] = result.text
            data["type"] = result.barcodeFormat.name
        }
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
        multiFormatReader.setHints(hints)
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
                decodeImage(byteArray, imageHeight, imageWidth, false, topRatio, leftRatio, widthRatio, heightRatio)
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

    // 这里设置可扫描的类型
    private val hints: Map<DecodeHintType, Any>
        get() {
            val decodeFormats: MutableCollection<BarcodeFormat> = ArrayList()
            //一维码
            decodeFormats.add(BarcodeFormat.UPC_A)
            decodeFormats.add(BarcodeFormat.UPC_E)
            decodeFormats.add(BarcodeFormat.EAN_13)
            decodeFormats.add(BarcodeFormat.EAN_8)
            decodeFormats.add(BarcodeFormat.CODABAR)
            decodeFormats.add(BarcodeFormat.CODE_39)
            decodeFormats.add(BarcodeFormat.CODE_93)
            decodeFormats.add(BarcodeFormat.CODE_128)
            decodeFormats.add(BarcodeFormat.ITF)
            decodeFormats.add(BarcodeFormat.RSS_14)
            decodeFormats.add(BarcodeFormat.RSS_EXPANDED)
            //二维码
            decodeFormats.add(BarcodeFormat.QR_CODE)
            decodeFormats.add(BarcodeFormat.AZTEC)
            decodeFormats.add(BarcodeFormat.DATA_MATRIX)
//            decodeFormats.add(BarcodeFormat.MAXICODE)
//            decodeFormats.add(BarcodeFormat.PDF_417)
            val hints: MutableMap<DecodeHintType, Any> = mutableMapOf()
            hints[DecodeHintType.CHARACTER_SET] = "UTF-8"
            hints[DecodeHintType.POSSIBLE_FORMATS] = decodeFormats
            hints[DecodeHintType.TRY_HARDER] = true
            return hints
        }
}