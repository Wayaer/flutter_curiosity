package flutter.curiosity.scan;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.ContextWrapper;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.util.Log;

import com.google.zxing.BinaryBitmap;
import com.google.zxing.RGBLuminanceSource;
import com.google.zxing.Result;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.qrcode.QRCodeReader;

import java.io.File;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.cert.X509Certificate;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import flutter.curiosity.utils.NativeUtils;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ScanUtils extends ContextWrapper {

    private QRCodeReader reader = new QRCodeReader();
    private Executor executor = Executors.newSingleThreadExecutor();
    private Handler handler = new Handler();

    public ScanUtils(Context base) {
        super(base);
    }


    public void scanImagePath(MethodCall call, final MethodChannel.Result result) {
        final String path = call.argument("path");
        final File file = new File(path);
        if (file.isFile()) {
            executor.execute(() -> {
                Bitmap bitmap = BitmapFactory.decodeFile(path);
                scan(bitmap, result);
            });
        } else {
            result.success("");
        }
    }

    public void scan(Bitmap bitmap, final MethodChannel.Result result) {
        int height = bitmap.getHeight();
        int width = bitmap.getWidth();
        try {
            int[] pixels = new int[width * height];
            bitmap.getPixels(pixels, 0, width, 0, 0, width, height);
            RGBLuminanceSource source = new RGBLuminanceSource(
                    width,
                    height, pixels);
            BinaryBitmap binaryBitmap = new BinaryBitmap(new HybridBinarizer(source));
            final Result decode = reader.decode(binaryBitmap, NativeUtils.getHints());
            Log.d("result", "analyze: decode:" + decode.toString());
            handler.post(() -> result.success(NativeUtils.scanDataToMap(decode)));
        } catch (Exception e) {
            Log.d("result", "analyze: error");
            handler.post(() -> result.success(null));
        }

    }

    public void scanImageUrl(MethodCall call, final MethodChannel.Result result) {
        final String url = call.argument("url");
        executor.execute(() -> {
            try {
                URL myUrl = new URL(url);
                Bitmap bitmap;
                assert url != null;
                if (url.startsWith("https")) {
                    HttpsURLConnection connection = (HttpsURLConnection) myUrl.openConnection();
                    connection.setReadTimeout(6 * 60 * 1000);
                    connection.setConnectTimeout(6 * 60 * 1000);
                    TrustManager[] tm = {new MyX509TrustManager()};
                    SSLContext sslContext = SSLContext.getInstance("TLS");
                    sslContext.init(null, tm, new java.security.SecureRandom());
                    // 从上述SSLContext对象中得到SSLSocketFactory对象
                    SSLSocketFactory ssf = sslContext.getSocketFactory();
                    connection.setSSLSocketFactory(ssf);
                    connection.connect();
                    bitmap = BitmapFactory.decodeStream(connection.getInputStream());
                } else {
                    HttpURLConnection connection = (HttpURLConnection) myUrl.openConnection();
                    connection.setReadTimeout(6 * 60 * 1000);
                    connection.setConnectTimeout(6 * 60 * 1000);
                    connection.connect();
                    bitmap = BitmapFactory.decodeStream(connection.getInputStream());
                }
                scan(bitmap, result);


            } catch (Exception e) {
                Log.d("result", "analyze: error");
                handler.post(() -> result.success(null));
            }
        });
    }

    public void scanImageMemory(MethodCall call, final MethodChannel.Result result) {
        final byte[] unit8List = call.argument("unit8List");
        executor.execute(() -> {
            try {
                assert unit8List != null;
                Bitmap bitmap;
                bitmap = BitmapFactory.decodeByteArray(unit8List, 0, unit8List.length);
                scan(bitmap, result);
            } catch (Exception e) {
                Log.d("result", "analyze: error");
                handler.post(() -> result.success(null));
            }
        });
    }

    private static class MyX509TrustManager implements X509TrustManager {

        // 检查客户端证书
        @SuppressLint("TrustAllX509TrustManager")
        public void checkClientTrusted(X509Certificate[] chain, String authType) {
        }

        // 检查服务器端证书
        @SuppressLint("TrustAllX509TrustManager")
        public void checkServerTrusted(X509Certificate[] chain, String authType) {
        }

        // 返回受信任的X509证书数组
        public X509Certificate[] getAcceptedIssuers() {
            return null;
        }
    }
}
