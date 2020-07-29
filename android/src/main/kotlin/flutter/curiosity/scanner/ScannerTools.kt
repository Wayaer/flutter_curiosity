package flutter.curiosity.scanner

import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.Image
import android.os.Handler
import com.google.zxing.*
import com.google.zxing.common.GlobalHistogramBinarizer
import flutter.curiosity.CuriosityPlugin.Companion.call
import flutter.curiosity.CuriosityPlugin.Companion.channelResult
import io.flutter.BuildConfig
import java.io.File
import java.net.HttpURLConnection
import java.net.URL
import java.security.SecureRandom
import java.security.cert.X509Certificate
import java.util.*
import java.util.concurrent.Executor
import java.util.concurrent.Executors
import javax.net.ssl.HttpsURLConnection
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManager
import javax.net.ssl.X509TrustManager

object ScannerTools {
    private val executor: Executor = Executors.newSingleThreadExecutor()
    private val multiFormatReader: MultiFormatReader = MultiFormatReader()

    fun scanImagePath() {
        val path = call.argument<String>("path")
        if (BuildConfig.DEBUG && path == null) {
            error("Assertion failed")
        }
        val file = File(path.toString())
        if (file.isFile) {
            executor.execute {
                val bitmap = BitmapFactory.decodeFile(path)
                Handler().post { channelResult.success(decodeBitmap(bitmap)) }
            }
        } else {
            channelResult.success(null)
        }
    }

    fun scanImageUrl() {
        val url = call.argument<String>("url")
        executor.execute {
            val myUrl = URL(url)
            val bitmap: Bitmap
            if (BuildConfig.DEBUG && url == null) {
                error("Assertion failed")
            }
            if (url!!.startsWith("https")) {
                val connection = myUrl.openConnection() as HttpsURLConnection
                connection.readTimeout = 6 * 60 * 1000
                connection.connectTimeout = 6 * 60 * 1000
                val tm = arrayOf<TrustManager>(X509Trust())
                val sslContext = SSLContext.getInstance("TLS")
                sslContext.init(null, tm, SecureRandom())
                // 从上述SSLContext对象中得到SSLSocketFactory对象
                val ssf = sslContext.socketFactory
                connection.sslSocketFactory = ssf
                connection.connect()
                bitmap = BitmapFactory.decodeStream(connection.inputStream)
            } else {
                val connection = myUrl.openConnection() as HttpURLConnection
                connection.readTimeout = 6 * 60 * 1000
                connection.connectTimeout = 6 * 60 * 1000
                connection.connect()
                bitmap = BitmapFactory.decodeStream(connection.inputStream)
            }
            Handler().post { channelResult.success(decodeBitmap(bitmap)) }
        }
    }

    fun scanImageMemory() {
        val unit8List = call.argument<ByteArray>("unit8List")
        if (BuildConfig.DEBUG && unit8List == null) {
            error("Assertion failed")
        }
        executor.execute {
            val bitmap: Bitmap = BitmapFactory.decodeByteArray(unit8List, 0, unit8List!!.size)
            Handler().post { channelResult.success(decodeBitmap(bitmap)) }
        }
    }

    private fun decodeBitmap(bitmap: Bitmap): Map<String, Any>? {
        multiFormatReader.setHints(hints)
        val height = bitmap.height
        val width = bitmap.width
        val pixels = IntArray(width * height)
        bitmap.getPixels(pixels, 0, width, 0, 0, width, height)
        var result: Result? = null
        val source = RGBLuminanceSource(
                width,
                height, pixels)
        try {
            result = multiFormatReader.decodeWithState(BinaryBitmap(GlobalHistogramBinarizer(source)))
        } catch (e: NotFoundException) {
            try {
                result = multiFormatReader.decodeWithState(BinaryBitmap(GlobalHistogramBinarizer(source.invert())))
            } catch (e: NotFoundException) {
            }
        }
        return scanDataToMap(result)
    }

    private class X509Trust : X509TrustManager {
        // 检查客户端证书
        @SuppressLint("TrustAllX509TrustManager")
        override fun checkClientTrusted(chain: Array<X509Certificate>, authType: String) {
        }

        // 检查服务器端证书
        @SuppressLint("TrustAllX509TrustManager")
        override fun checkServerTrusted(chain: Array<X509Certificate>, authType: String) {
        }

        // 返回受信任的X509证书数组
        override fun getAcceptedIssuers(): Array<X509Certificate>? {
            return null
        }
    }

    // 这里设置可扫描的类型
    private val hints: Map<DecodeHintType, Any>
        get() {
            val decodeFormats: MutableCollection<BarcodeFormat> = ArrayList<BarcodeFormat>()
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

    fun scanDataToMap(result: Result?): Map<String, Any>? {
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


    fun decodeImage(byteArray: ByteArray, image: Image, verticalScreen: Boolean, topRatio: Double, leftRatio: Double, widthRatio: Double, heightRatio: Double): Result? {
        val width: Int
        val height: Int
        val array: ByteArray
        if (verticalScreen) {
            array = rotateByteArray(byteArray, image)
            width = image.height
            height = image.width
        } else {
            width = image.width
            height = image.height
            array = byteArray
        }
        val left = (width * leftRatio).toInt()
        val top = (width * topRatio).toInt()
        val identifyWidth = (width * widthRatio).toInt()
        val identifyHeight = (height * heightRatio).toInt()
        val source = PlanarYUVLuminanceSource(
                array, width, height, left,
                top,
                identifyWidth, identifyHeight, false)
        val binaryBitmap = BinaryBitmap(GlobalHistogramBinarizer(source))
        var result: Result? = null
        try {
            result = multiFormatReader.decode(binaryBitmap, hints)
        } catch (e: NotFoundException) {
            if (verticalScreen) result = decodeImage(byteArray, image, false, topRatio, leftRatio, widthRatio, heightRatio)
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