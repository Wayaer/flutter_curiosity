package flutter.curiosity.scan;

import android.content.Context;
import android.graphics.ImageFormat;
import android.os.Build;
import android.util.Log;
import android.util.Size;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.camera.camera2.Camera2Config;
import androidx.camera.core.Camera;
import androidx.camera.core.CameraControl;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.CameraXConfig;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageProxy;
import androidx.camera.core.Preview;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.camera.view.PreviewView;
import androidx.core.content.ContextCompat;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.LifecycleRegistry;

import com.google.common.util.concurrent.ListenableFuture;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.PlanarYUVLuminanceSource;
import com.google.zxing.Result;
import com.google.zxing.common.HybridBinarizer;

import java.nio.ByteBuffer;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Executors;

import flutter.curiosity.CuriosityPlugin;
import flutter.curiosity.utils.NativeUtils;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;


public class ScanView implements PlatformView, LifecycleOwner, CameraXConfig.Provider,
        EventChannel.StreamHandler,
        MethodChannel.MethodCallHandler {

    private LifecycleRegistry lifecycleRegistry;
    private PreviewView previewView;
    private boolean isPlay;
    private EventChannel.EventSink eventSink;
    private long lastCurrentTimestamp = 0L;//最后一次的扫描

    private ListenableFuture<ProcessCameraProvider> cameraProviderFuture;
    private ProcessCameraProvider cameraProvider;
    private CameraControl cameraControl;
    private CameraInfo cameraInfo;
    private Context context;

    ScanView(Context ctx, BinaryMessenger messenger, int i, Object object) {
        context = ctx;
        Map map = (Map) object;
        isPlay = (Boolean) map.get("isPlay");
        int width = (int) map.get("width");
        int height = (int) map.get("height");
        new EventChannel(messenger, CuriosityPlugin.scanView + "_" + i + "/event")
                .setStreamHandler(this);
        MethodChannel methodChannel = new MethodChannel(messenger, CuriosityPlugin.scanView + "_" + i + "/method");
        methodChannel.setMethodCallHandler(this);
        previewView = initPreviewView(width, height);
        previewView.post(() -> startCamera(context, initPreview(width, height), initImageAnalysis(width, height)));
    }


    private PreviewView initPreviewView(int width, int height) {
        lifecycleRegistry = new LifecycleRegistry(this);
        cameraProviderFuture = ProcessCameraProvider.getInstance(context);
        previewView = new PreviewView(context);
        previewView.setLayoutParams(new ViewGroup.LayoutParams(width, height));
        previewView.setImplementationMode(PreviewView.ImplementationMode.TEXTURE_VIEW);
        return previewView;
    }


    private ImageAnalysis initImageAnalysis(int width, int height) {
        //设置分析
        ImageAnalysis imageAnalysis = new ImageAnalysis.Builder()
                .setImageQueueDepth(ImageAnalysis.STRATEGY_BLOCK_PRODUCER)
                .setTargetResolution(new Size(width, height))
                .build();
        imageAnalysis.setAnalyzer(Executors.newSingleThreadExecutor(), new ScanImageAnalysis());
        return imageAnalysis;
    }

    private Preview initPreview(int width, int height) {
        Preview preview = new Preview.Builder()
                .setTargetResolution(new Size(width, height))
                .build();
        preview.setSurfaceProvider(previewView.getPreviewSurfaceProvider());
        return preview;
    }

    private void startCamera(Context context, Preview preview, ImageAnalysis imageAnalysis) {
        CameraSelector cameraSelector = new CameraSelector.Builder().requireLensFacing(CameraSelector.LENS_FACING_BACK).build();
        cameraProviderFuture.addListener(() -> {
            try {
                cameraProvider = cameraProviderFuture.get();
                Camera camera = cameraProvider.bindToLifecycle(this, cameraSelector, preview,
                        imageAnalysis);
                cameraControl = camera.getCameraControl();
                cameraInfo = camera.getCameraInfo();
            } catch (ExecutionException | InterruptedException e) {
                e.printStackTrace();
            }
        }, ContextCompat.getMainExecutor(context));
    }

    @NonNull
    @Override
    public CameraXConfig getCameraXConfig() {
        return Camera2Config.defaultConfig();
    }


    private class ScanImageAnalysis implements ImageAnalysis.Analyzer {
        private MultiFormatReader multiFormatReader = new MultiFormatReader();

        @Override
        public void analyze(@NonNull ImageProxy image) {
            long currentTimestamp = System.currentTimeMillis();
            if (currentTimestamp - lastCurrentTimestamp >= 1L && isPlay == Boolean.TRUE) {
                if (ImageFormat.YUV_420_888 != image.getFormat()) {
                    return;
                }
                ByteBuffer buffer = image.getPlanes()[0].getBuffer();
                byte[] array = new byte[buffer.remaining()];

                buffer.get(array, 0, array.length);
                int height = image.getHeight();
                int width = image.getWidth();
                PlanarYUVLuminanceSource source = new PlanarYUVLuminanceSource(array,
                        width,
                        height,
                        0,
                        0,
                        width,
                        height,
                        false);
                BinaryBitmap binaryBitmap = new BinaryBitmap(new HybridBinarizer(source.invert()));
//                multiFormatReader.setHints(NativeUtils.getHints());
                final Result result;
                try {
                    result = multiFormatReader.decode(binaryBitmap, NativeUtils.getHints());
//                    Log.i("扫码出来的数据", result.getText());
                    Log.i("扫码出来的数据", "");
                    if (result != null && eventSink != null) {
                        previewView.post(() -> {
                            if (eventSink != null)
                                eventSink.success(NativeUtils.scanDataToMap(result));
                        });
                    }
                } catch (Exception e) {
                    Log.i("无二维码数据", "无二维码数据");
                    buffer.clear();
                }
                lastCurrentTimestamp = currentTimestamp;
            }
            image.close();
        }
    }

    @Override
    public void onCancel(Object object) {
        eventSink = null;
    }

    @Override
    public View getView() {
        if (lifecycleRegistry.getCurrentState() != Lifecycle.State.RESUMED) {
            lifecycleRegistry.setCurrentState(Lifecycle.State.RESUMED);
        }
        return previewView;
    }

    @NonNull
    @Override
    public Lifecycle getLifecycle() {
        return lifecycleRegistry;
    }


    @Override
    public void dispose() {
        lifecycleRegistry.markState(Lifecycle.State.DESTROYED);
        if (cameraProvider != null) cameraProvider.unbindAll();
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "startScan":
                isPlay = true;
//                result.success(null);x
                break;
            case "stopScan":
                isPlay = false;
//                result.success(null);
                break;
            case "setFlashMode":
                boolean isOpen = methodCall.argument("isOpen");
                cameraControl.enableTorch(isOpen);
                break;
            case "getFlashMode":
                result.success(cameraInfo.getTorchState());
                break;
            default:
                result.notImplemented();
                break;
        }
    }

}
