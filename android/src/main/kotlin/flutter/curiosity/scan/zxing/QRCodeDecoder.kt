package flutter.curiosity.scan.zxing

import android.graphics.Bitmap
import com.google.zxing.*
import com.google.zxing.common.GlobalHistogramBinarizer
import com.google.zxing.common.HybridBinarizer
import java.util.*

/**
 * 描述:解析二维码图片。一维条码、二维码各种类型简介
 */
object QRCodeDecoder {
    private val ALL_HINT_MAP: MutableMap<DecodeHintType, Any?> = EnumMap<DecodeHintType, Any>(DecodeHintType::class.java)
    private val ONE_DIMENSION_HINT_MAP: MutableMap<DecodeHintType, Any> = EnumMap(DecodeHintType::class.java)
    private val TWO_DIMENSION_HINT_MAP: MutableMap<DecodeHintType, Any> = EnumMap(DecodeHintType::class.java)
    private val QR_CODE_HINT_MAP: MutableMap<DecodeHintType, Any> = EnumMap(DecodeHintType::class.java)
    private val CODE_128_HINT_MAP: MutableMap<DecodeHintType, Any> = EnumMap(DecodeHintType::class.java)
    private val EAN_13_HINT_MAP: MutableMap<DecodeHintType, Any> = EnumMap(DecodeHintType::class.java)
    private val HIGH_FREQUENCY_HINT_MAP: MutableMap<DecodeHintType, Any> = EnumMap(DecodeHintType::class.java)
    /**
     * 同步解析本地图片二维码。该方法是耗时操作，请在子线程中调用。
     *
     * @param picturePath 要解析的二维码图片本地路径
     * @return 返回二维码图片里的内容 或 null
     */
    fun syncDecodeQRCode(picturePath: String?): String? {
        return syncDecodeQRCode(BGAQRCodeUtil.getDecodeAbleBitmap(picturePath))
    }

    /**
     * 同步解析bitmap二维码。该方法是耗时操作，请在子线程中调用。
     *
     * @param bitmap 要解析的二维码图片
     * @return 返回二维码图片里的内容 或 null
     */
    private fun syncDecodeQRCode(bitmap: Bitmap?): String? {
        var result: Result
        var source: RGBLuminanceSource? = null
        return try {
            val width = bitmap!!.width
            val height = bitmap.height
            val pixels = IntArray(width * height)
            bitmap.getPixels(pixels, 0, width, 0, 0, width, height)
            source = RGBLuminanceSource(width, height, pixels)
            result = MultiFormatReader().decode(BinaryBitmap(HybridBinarizer(source)), ALL_HINT_MAP)
            result.text
        } catch (e: Exception) {
            e.printStackTrace()
            if (source != null) {
                try {
                    result = MultiFormatReader().decode(BinaryBitmap(GlobalHistogramBinarizer(source)), ALL_HINT_MAP)
                    return result.text
                } catch (e2: Throwable) {
                    e2.printStackTrace()
                }
            }
            null
        }
    }

    init {
        val allFormatList: MutableList<BarcodeFormat> = ArrayList()
        allFormatList.add(BarcodeFormat.AZTEC)
        allFormatList.add(BarcodeFormat.CODABAR)
        allFormatList.add(BarcodeFormat.CODE_39)
        allFormatList.add(BarcodeFormat.CODE_93)
        allFormatList.add(BarcodeFormat.CODE_128)
        allFormatList.add(BarcodeFormat.DATA_MATRIX)
        allFormatList.add(BarcodeFormat.EAN_8)
        allFormatList.add(BarcodeFormat.EAN_13)
        allFormatList.add(BarcodeFormat.ITF)
        allFormatList.add(BarcodeFormat.MAXICODE)
        allFormatList.add(BarcodeFormat.PDF_417)
        allFormatList.add(BarcodeFormat.QR_CODE)
        allFormatList.add(BarcodeFormat.RSS_14)
        allFormatList.add(BarcodeFormat.RSS_EXPANDED)
        allFormatList.add(BarcodeFormat.UPC_A)
        allFormatList.add(BarcodeFormat.UPC_E)
        allFormatList.add(BarcodeFormat.UPC_EAN_EXTENSION)
        // 可能的编码格式
        ALL_HINT_MAP[DecodeHintType.POSSIBLE_FORMATS] = allFormatList
        // 花更多的时间用于寻找图上的编码，优化准确性，但不优化速度
        ALL_HINT_MAP[DecodeHintType.TRY_HARDER] = true
        // 复杂模式，开启 PURE_BARCODE 模式（带图片 LOGO 的解码方案）
//        ALL_HINT_MAP.put(DecodeHintType.PURE_BARCODE, Boolean.TRUE);
// 编码字符集
        ALL_HINT_MAP[DecodeHintType.CHARACTER_SET] = "utf-8"
    }

    init {
        val oneDimenFormatList: MutableList<BarcodeFormat> = ArrayList()
        oneDimenFormatList.add(BarcodeFormat.CODABAR)
        oneDimenFormatList.add(BarcodeFormat.CODE_39)
        oneDimenFormatList.add(BarcodeFormat.CODE_93)
        oneDimenFormatList.add(BarcodeFormat.CODE_128)
        oneDimenFormatList.add(BarcodeFormat.EAN_8)
        oneDimenFormatList.add(BarcodeFormat.EAN_13)
        oneDimenFormatList.add(BarcodeFormat.ITF)
        oneDimenFormatList.add(BarcodeFormat.PDF_417)
        oneDimenFormatList.add(BarcodeFormat.RSS_14)
        oneDimenFormatList.add(BarcodeFormat.RSS_EXPANDED)
        oneDimenFormatList.add(BarcodeFormat.UPC_A)
        oneDimenFormatList.add(BarcodeFormat.UPC_E)
        oneDimenFormatList.add(BarcodeFormat.UPC_EAN_EXTENSION)
        ONE_DIMENSION_HINT_MAP[DecodeHintType.POSSIBLE_FORMATS] = oneDimenFormatList
        ONE_DIMENSION_HINT_MAP[DecodeHintType.TRY_HARDER] = true
        ONE_DIMENSION_HINT_MAP[DecodeHintType.CHARACTER_SET] = "utf-8"
    }

    init {
        val twoDimenFormatList: MutableList<BarcodeFormat> = ArrayList()
        twoDimenFormatList.add(BarcodeFormat.AZTEC)
        twoDimenFormatList.add(BarcodeFormat.DATA_MATRIX)
        twoDimenFormatList.add(BarcodeFormat.MAXICODE)
        twoDimenFormatList.add(BarcodeFormat.QR_CODE)
        TWO_DIMENSION_HINT_MAP[DecodeHintType.POSSIBLE_FORMATS] = twoDimenFormatList
        TWO_DIMENSION_HINT_MAP[DecodeHintType.TRY_HARDER] = true
        TWO_DIMENSION_HINT_MAP[DecodeHintType.CHARACTER_SET] = "utf-8"
    }

    init {
        QR_CODE_HINT_MAP[DecodeHintType.POSSIBLE_FORMATS] = listOf(BarcodeFormat.QR_CODE)
        QR_CODE_HINT_MAP[DecodeHintType.TRY_HARDER] = true
        QR_CODE_HINT_MAP[DecodeHintType.CHARACTER_SET] = "utf-8"
    }

    init {
        CODE_128_HINT_MAP[DecodeHintType.POSSIBLE_FORMATS] = listOf(BarcodeFormat.CODE_128)
        CODE_128_HINT_MAP[DecodeHintType.TRY_HARDER] = true
        CODE_128_HINT_MAP[DecodeHintType.CHARACTER_SET] = "utf-8"
    }

    init {
        EAN_13_HINT_MAP[DecodeHintType.POSSIBLE_FORMATS] = listOf(BarcodeFormat.EAN_13)
        EAN_13_HINT_MAP[DecodeHintType.TRY_HARDER] = true
        EAN_13_HINT_MAP[DecodeHintType.CHARACTER_SET] = "utf-8"
    }

    init {
        val highFrequencyFormatList: MutableList<BarcodeFormat> = ArrayList()
        highFrequencyFormatList.add(BarcodeFormat.QR_CODE)
        highFrequencyFormatList.add(BarcodeFormat.UPC_A)
        highFrequencyFormatList.add(BarcodeFormat.EAN_13)
        highFrequencyFormatList.add(BarcodeFormat.CODE_128)
        HIGH_FREQUENCY_HINT_MAP[DecodeHintType.POSSIBLE_FORMATS] = highFrequencyFormatList
        HIGH_FREQUENCY_HINT_MAP[DecodeHintType.TRY_HARDER] = true
        HIGH_FREQUENCY_HINT_MAP[DecodeHintType.CHARACTER_SET] = "utf-8"
    }
}