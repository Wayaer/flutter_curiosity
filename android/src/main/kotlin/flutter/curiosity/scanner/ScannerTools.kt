package flutter.curiosity.scanner

import android.app.Activity
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.Image
import android.os.Handler
import android.os.Looper
import com.google.zxing.*
import com.google.zxing.common.GlobalHistogramBinarizer
import com.google.zxing.common.HybridBinarizer
import flutter.curiosity.CuriosityPlugin.Companion.call
import flutter.curiosity.CuriosityPlugin.Companion.result
import java.io.File
import java.net.URL
import java.util.*
import java.util.concurrent.Executor
import java.util.concurrent.Executors
import javax.net.ssl.HttpsURLConnection
import javax.net.ssl.SSLSocketFactory
import kotlin.collections.ArrayList


object ScannerTools {
    private val executor: Executor = Executors.newSingleThreadExecutor()
    private val multiFormatReader: MultiFormatReader = MultiFormatReader()
    private val handler = Handler(Looper.getMainLooper())

    fun scanImagePath(activity: Activity) {
        val path = call.arguments as String
        val file = File(path)
        if (file.isFile) {
            executor.execute {
                try {
                    val bitmap = BitmapFactory.decodeFile(path)
                    if (bitmap != null) {
                        handler.post {
                            result.success(
                                decodeBitmap
                                    (bitmap, activity)
                            )
                        }
                    }
                } catch (e: NotFoundException) {
                    handler.post { result.success(null) }
                }
            }
        } else {
            result.success(null)
        }
    }

    fun scanImageUrl(activity: Activity) {
        val url = call.arguments as String
        executor.execute {
            try {
                val myUrl = URL(url)
                val bitmap: Bitmap
                val connection = myUrl.openConnection() as HttpsURLConnection
                connection.readTimeout = 6 * 60 * 1000
                connection.connectTimeout = 6 * 60 * 1000
                if (url.startsWith("https")) {
                    connection.sslSocketFactory = SSLSocketFactory.getDefault() as SSLSocketFactory
                }
                connection.connect()
                bitmap = BitmapFactory.decodeStream(connection.inputStream)
                if (bitmap != null) {
                    handler.post {
                        result.success(
                            decodeBitmap
                                (bitmap, activity)
                        )
                    }
                }
            } catch (e: NotFoundException) {
                handler.post { result.success(null) }
            }
        }
    }


    fun scanImageMemory(activity: Activity) {
        val byteArray = call.arguments as ByteArray
        executor.execute {
            try {
                val bitmap: Bitmap = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)
                handler.post {
                    result.success(
                        decodeBitmap(
                            bitmap, activity
                        )
                    )
                }
            } catch (e: NotFoundException) {
                handler.post { result.success(null) }
            }

        }

    }

    private fun decodeBitmap(bitmap: Bitmap, activity: Activity): Map<String, Any>? {
        multiFormatReader.setHints(hints)
        val height = bitmap.height
        val width = bitmap.width
        val hints: MutableMap<DecodeHintType, Any> = EnumMap(DecodeHintType::class.java)
        hints[DecodeHintType.TRY_HARDER] = java.lang.Boolean.TRUE
        val array: ByteArray = ImageHelper(activity).getYUV420(
            width, height,
            bitmap
        )
        val source = PlanarYUVLuminanceSource(
            array,
            width,
            height,
            0,
            0,
            width,
            height,
            false
        )
        var result: Result?
        try {
            result = multiFormatReader.decodeWithState(BinaryBitmap(GlobalHistogramBinarizer(source)))
            return scanDataToMap(result)
        } catch (e: NotFoundException) {
            try {
                result = multiFormatReader.decodeWithState(BinaryBitmap(HybridBinarizer(source)))
                return scanDataToMap(result)
            } catch (e: NotFoundException) {

            }
        } finally {
            bitmap.recycle()
        }
        return null
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


    fun decodeImage(
        byteArray: ByteArray,
        image: Image,
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
            array = rotateByteArray(byteArray, image)
            width = image.height
            height = image.width
            identifyWidth = (width * widthRatio).toInt()
            identifyHeight = (height * heightRatio).toInt()
            left = (width * leftRatio).toInt()
            top = (height * topRatio).toInt()
        } else {
            width = image.width
            height = image.height
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
            result = multiFormatReader.decode(binaryBitmap, hints)
        } catch (e: NotFoundException) {
            if (verticalScreen) result =
                decodeImage(byteArray, image, false, topRatio, leftRatio, widthRatio, heightRatio)
        }
        return result
    }

    private fun rotateByteArray(byteArray: ByteArray, image: Image): ByteArray {
        val width = image.width
        val height = image.height
        val rotatedData = ByteArray(byteArray.size)
        for (y in 0 until height) { // we scan the array by rows
            for (x in 0 until width) {
                rotatedData[x * height + height - y - 1] =
                    byteArray[x + y * width] //
            }
        }
        return rotatedData
    }

}