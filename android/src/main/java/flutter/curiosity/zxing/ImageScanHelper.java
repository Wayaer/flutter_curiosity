package flutter.curiosity.zxing;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.ContextWrapper;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.util.Log;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.DecodeHintType;
import com.google.zxing.RGBLuminanceSource;
import com.google.zxing.Result;
import com.google.zxing.common.HybridBinarizer;
import com.google.zxing.qrcode.QRCodeReader;

import java.io.File;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.cert.X509Certificate;
import java.util.EnumMap;
import java.util.Map;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import flutter.curiosity.utils.Utils;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ImageScanHelper extends ContextWrapper {

    private QRCodeReader reader = new QRCodeReader();
    private Executor executor = Executors.newSingleThreadExecutor();
    private Handler handler = new Handler();

    public ImageScanHelper(Context base) {
        super(base);
    }

    public void scanImagePath(MethodCall call, final MethodChannel.Result result) {
        final String path = call.argument("path");
        final File file = new File(path);
        if (file.isFile()) {
            executor.execute(() -> {
                Bitmap bitmap = BitmapFactory.decodeFile(path);
                int height = bitmap.getHeight();
                int width = bitmap.getWidth();
                try {
                    Map<DecodeHintType, Object> hints = new EnumMap<>(DecodeHintType.class);
                    hints.put(DecodeHintType.CHARACTER_SET, "utf-8");
                    hints.put(DecodeHintType.TRY_HARDER, Boolean.TRUE);
                    hints.put(DecodeHintType.POSSIBLE_FORMATS, BarcodeFormat.QR_CODE);
                    int[] pixels = new int[width * height];
                    bitmap.getPixels(pixels, 0, width, 0, 0, width, height);
                    RGBLuminanceSource source = new RGBLuminanceSource(
                            width,
                            height, pixels);
                    BinaryBitmap binaryBitmap = new BinaryBitmap(new HybridBinarizer(source));
                    final Result decode = reader.decode(binaryBitmap, hints);
                    Log.d("result", "analyze: decode:" + decode.toString());
                    handler.post(() -> result.success(Utils.toMap(decode)));
                } catch (Exception e) {
                    Log.d("result", "analyze: error");
                    handler.post(() -> result.success(null));
                }
            });
        } else {
            result.success("");
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
                int height = bitmap.getHeight();
                int width = bitmap.getWidth();
                Map<DecodeHintType, Object> hints = new EnumMap<>(DecodeHintType.class);
                hints.put(DecodeHintType.CHARACTER_SET, "utf-8");
                hints.put(DecodeHintType.TRY_HARDER, Boolean.TRUE);
                hints.put(DecodeHintType.POSSIBLE_FORMATS, BarcodeFormat.QR_CODE);
                int[] pixels = new int[width * height];
                bitmap.getPixels(pixels, 0, width, 0, 0, width, height);
                RGBLuminanceSource source = new RGBLuminanceSource(
                        width,
                        height, pixels);
                BinaryBitmap binaryBitmap = new BinaryBitmap(new HybridBinarizer(source));
                final Result decode = reader.decode(binaryBitmap, hints);
                Log.d("result", "analyze: decode:" + decode.toString());
                handler.post(() -> result.success(Utils.toMap(decode)));
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
                int height = bitmap.getHeight();
                int width = bitmap.getWidth();
                Map<DecodeHintType, Object> hints = new EnumMap<>(DecodeHintType.class);
                hints.put(DecodeHintType.CHARACTER_SET, "utf-8");
                hints.put(DecodeHintType.TRY_HARDER, Boolean.TRUE);
                hints.put(DecodeHintType.POSSIBLE_FORMATS, BarcodeFormat.QR_CODE);
                int[] pixels = new int[width * height];
                bitmap.getPixels(pixels, 0, width, 0, 0, width, height);
                RGBLuminanceSource source = new RGBLuminanceSource(
                        width,
                        height, pixels);
                BinaryBitmap binaryBitmap = new BinaryBitmap(new HybridBinarizer(source));
                final Result decode = reader.decode(binaryBitmap, hints);
                Log.d("result", "analyze: decode:" + decode.toString());
                handler.post(() -> result.success(Utils.toMap(decode)));
            } catch (Exception e) {
                Log.d("result", "analyze: error");
                handler.post(() -> result.success(null));
            }
        });
    }

    private class MyX509TrustManager implements X509TrustManager {

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
