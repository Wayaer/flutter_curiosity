package flutter.curiosity.scan

import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Handler
import android.util.Log
import com.google.zxing.BinaryBitmap
import com.google.zxing.RGBLuminanceSource
import com.google.zxing.common.HybridBinarizer
import com.google.zxing.qrcode.QRCodeReader
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import  flutter.curiosity.utils.NativeUtils
import java.io.File
import java.net.HttpURLConnection
import java.net.URL
import java.security.SecureRandom
import java.security.cert.X509Certificate
import java.util.concurrent.Executor
import java.util.concurrent.Executors
import javax.net.ssl.HttpsURLConnection
import javax.net.ssl.SSLContext
import javax.net.ssl.TrustManager
import javax.net.ssl.X509TrustManager

object ScanUtils {
    private val reader = QRCodeReader()
    private val executor: Executor = Executors.newSingleThreadExecutor()
    private val handler = Handler()
    fun scanImagePath(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String>("path")
        assert(path != null)
        val file = File(path.toString())
        if (file.isFile) {
            executor.execute {
                val bitmap = BitmapFactory.decodeFile(path)
                scan(bitmap, result)
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
                    val tm = arrayOf<TrustManager>(MyX509TrustManager())
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
                scan(bitmap, result)
            } catch (e: Exception) {
                Log.d("result", "analyze: error")
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
                scan(bitmap, result)
            } catch (e: Exception) {
                Log.d("result", "analyze: error")
                handler.post { result.success(null) }
            }
        }
    }

    private fun scan(bitmap: Bitmap, result: MethodChannel.Result) {
        val height = bitmap.height
        val width = bitmap.width
        try {
            val pixels = IntArray(width * height)
            bitmap.getPixels(pixels, 0, width, 0, 0, width, height)
            val source = RGBLuminanceSource(
                    width,
                    height, pixels)
            val binaryBitmap = BinaryBitmap(HybridBinarizer(source))
            val decode = reader.decode(binaryBitmap, NativeUtils.hints)
            Log.d("result", "analyze: decode:$decode")
            handler.post { result.success(NativeUtils.scanDataToMap(decode)) }
        } catch (e: Exception) {
            Log.d("result", "analyze: error")
            handler.post { result.success(null) }
        }
    }

    private class MyX509TrustManager : X509TrustManager {
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