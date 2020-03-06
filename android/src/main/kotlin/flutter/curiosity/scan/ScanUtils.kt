package flutter.curiosity.scan

import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Rect
import android.os.Handler
import com.google.zxing.BinaryBitmap
import com.google.zxing.MultiFormatReader
import com.google.zxing.PlanarYUVLuminanceSource
import com.google.zxing.RGBLuminanceSource
import com.google.zxing.common.HybridBinarizer
import flutter.curiosity.utils.NativeUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
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

object ScanUtils {
    private val executor: Executor = Executors.newSingleThreadExecutor()
    private val handler = Handler()
    private val multiFormatReader: MultiFormatReader = MultiFormatReader()

    fun scanImagePath(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("path")
        assert(path != null)
        val file = File(path.toString())
        if (file.isFile) {
            executor.execute {
                val bitmap = BitmapFactory.decodeFile(path)
                handler.post { result.success(scan(bitmap)) }
            }
        } else {
            result.success("")
        }
    }


    fun scanImageUrl(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        executor.execute {
            try {
                val myUrl = URL(url)
                val bitmap: Bitmap
                assert(url != null)
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

                handler.post { result.success(scan(bitmap)) }
            } catch (e: Exception) {
                handler.post { result.success(null) }
            }
        }
    }

    fun scanImageMemory(call: MethodCall, result: MethodChannel.Result) {
        val unit8List = call.argument<ByteArray>("unit8List")
        assert(unit8List != null)
        executor.execute {
            try {
                val bitmap: Bitmap = BitmapFactory.decodeByteArray(unit8List, 0, unit8List!!.size)
                handler.post { result.success(scan(bitmap)) }
            } catch (e: Exception) {
                handler.post { result.success(null) }
            }
        }
    }

    private fun scan(bitmap: Bitmap): Map<String, Any>? {
        multiFormatReader.setHints(NativeUtils.hints)
        val height = bitmap.height
        val width = bitmap.width
        val pixels = IntArray(width * height)
        return try {
            bitmap.getPixels(pixels, 0, width, 0, 0, width, height)
            val source = RGBLuminanceSource(
                    width,
                    height, pixels)
            val binaryBitmap = BinaryBitmap(HybridBinarizer(source))
            val decode = multiFormatReader.decode(binaryBitmap)
            NativeUtils.scanDataToMap(decode)
        } catch (e: Exception) {
            val data: MutableMap<String, Any> = HashMap()
            data["message"] = "Unrecognized data"
            data["type"] = 0
            data
        }

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

}