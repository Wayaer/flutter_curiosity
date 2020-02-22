package flutter.curiosity.scan;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.ImageFormat;
import android.graphics.SurfaceTexture;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.Rational;
import android.util.Size;
import android.view.View;
import android.view.WindowManager;

import androidx.annotation.NonNull;
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
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import flutter.curiosity.CuriosityPlugin;
import flutter.curiosity.utils.NativeUtils;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;


public class ScanView implements PlatformView, LifecycleOwner, EventChannel.StreamHandler, CameraXConfig.Provider, MethodChannel.MethodCallHandler {

    //    private LifecycleOwner lifecycleOwner;
    private LifecycleRegistry lifecycleRegistry;
    //    private TextureView textureView;
    private SurfaceTexture surfaceTexture;
    private boolean isPlay;
    private EventChannel.EventSink eventSink;
    private long lastCurrentTimestamp = 0L;//最后一次的扫描
    private MultiFormatReader multiFormatReader;
    private ListenableFuture<ProcessCameraProvider> cameraProviderFuture;
    private ProcessCameraProvider cameraProvider;

    private CameraControl cameraControl;
    private CameraInfo cameraInfo;
    private ExecutorService executor = Executors.newSingleThreadExecutor();
    private int width;
    private int height;
    private PreviewView previewView;
    private Context context;

    ScanView(Context ctx, BinaryMessenger messenger, int i, Object object) {
        context = ctx;
        Map map = (Map) object;
        isPlay = (Boolean) map.get("isPlay");
        width = (int) map.get("width");
        height = (int) map.get("height");
        new EventChannel(messenger, CuriosityPlugin.scanView + "_" + i + "/event")
                .setStreamHandler(this);
        MethodChannel methodChannel = new MethodChannel(messenger, CuriosityPlugin.scanView + "_" + i + "/method");
        methodChannel.setMethodCallHandler(this);
        lifecycleRegistry = new LifecycleRegistry(this);


//        textureView = new TextureView(context);

//        textureView.post(() -> startCamera(context, i));


    }

    @Override
    public void onCancel(Object o) {
        eventSink = null;
        multiFormatReader = new MultiFormatReader();
        multiFormatReader.setHints(NativeUtils.getHints());
        previewView = new PreviewView(context);
        cameraProviderFuture = ProcessCameraProvider.getInstance(context);
        previewView.post(() -> startCamera(context));
    }

    private void startCamera(Context context) {

//        textureView.setSurfaceTexture( new SurfaceTexture( ));
//        textureView.setSurfaceTextureListener(new TextureView.SurfaceTextureListener() {
//            @Override
//            public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
//                Log.i("宽高1", "surface可用");
//                surfaceTexture = surface;
//            }
//
//            @Override
//            public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
//            }
//
//            @Override
//            public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
//                return false;
//            }
//
//            @Override
//            public void onSurfaceTextureUpdated(SurfaceTexture surface) {
//            }
//        });

//        Preview.SurfaceProvider surfaceProvider = request -> request.setSurface(new Surface(surfaceTexture));
        CameraSelector cameraSelector = new CameraSelector.Builder().requireLensFacing(CameraSelector.LENS_FACING_BACK).build();
        //获取屏幕宽高
        DisplayMetrics outMetrics = new DisplayMetrics();
        WindowManager manager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        manager.getDefaultDisplay().getMetrics(outMetrics);
//        Log.i("宽高", outMetrics.widthPixels + "=" + outMetrics.heightPixels);
        Log.i("宽高2", width + "=" + height);
        //设置预览
        @SuppressLint("RestrictedApi") Preview preview = new Preview.Builder()
                .setTargetAspectRatioCustom(Rational.parseRational(outMetrics.widthPixels + ":" + outMetrics.heightPixels))
                .setTargetResolution(new Size(outMetrics.widthPixels, outMetrics.heightPixels))
                .build();
        preview.setSurfaceProvider(executor, previewView.getPreviewSurfaceProvider());

        //设置分析
        ImageAnalysis imageAnalysis = new ImageAnalysis.Builder()
                .setImageQueueDepth(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .setTargetResolution(new Size(outMetrics.widthPixels, outMetrics.heightPixels))
                .build();
        imageAnalysis.setAnalyzer(executor, new QRCodeAnalyzer());


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


    @Override
    public View getView() {
        if (lifecycleRegistry.getCurrentState() != Lifecycle.State.RESUMED) {
            lifecycleRegistry.markState(Lifecycle.State.RESUMED);
        }
        return previewView;
    }


    @NonNull
    @Override
    public Lifecycle getLifecycle() {
        return lifecycleRegistry;
    }

    @NonNull
    @Override
    public CameraXConfig getCameraXConfig() {
        return Camera2Config.defaultConfig();
    }
//
//    private Preview buildPreView(Context context) {
//        //获取屏幕宽高
//        DisplayMetrics outMetrics = new DisplayMetrics();
//        WindowManager manager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
//        manager.getDefaultDisplay().getMetrics(outMetrics);
//
//        Log.i("宽高", outMetrics.widthPixels + "=" + outMetrics.heightPixels);
//
//
//        //初始化 Preview 配置
////        PreviewConfig config = new PreviewConfig.Builder()

//////                .build();
////        mPreview = new Preview(config);
////        mPreview.setSurfaceProvider();
////        mPreview.setOnPreviewOutputUpdateListener(output -> {
////            if (textureView != null) {
////                textureView.setSurfaceTexture(output.getSurfaceTexture());
////            }
////        });
////        return mPreview;
//    }
//
//    private UseCase buildImageAnalysis() {
////        ImageAnalysisConfig config = new ImageAnalysisConfig.Builder()
////                .setImageReaderMode(ImageAnalysis.ImageReaderMode.ACQUIRE_LATEST_IMAGE)
////                .build();
//
//        ImageAnalysisConfig imageAnalysisConfig = new ImageAnalysisConfig.Builder<>();
//        OptionsBundle optionsBundle = new OptionsBundle();
//
////        analysis.setAnalyzer(new QRCodeAnalyzer());
//
//        return analysis;
//    }


    private class QRCodeAnalyzer implements ImageAnalysis.Analyzer {

        @Override
        public void analyze(@NonNull ImageProxy imageProxy) {
//             @SuppressLint("UnsafeExperimentalUsageError") Image image = imageProxy.getImage();
//            if (image != null) {
//                Log.i("Imagessssss", image.getWidth() + "," + image.getHeight());
//            }

            long currentTimestamp = System.currentTimeMillis();
            if (currentTimestamp - lastCurrentTimestamp >= 1L && isPlay == Boolean.TRUE) {
                if (ImageFormat.YUV_420_888 != imageProxy.getFormat()) {
                    return;
                }
                ByteBuffer buffer = imageProxy.getPlanes()[0].getBuffer();
                byte[] array = new byte[buffer.remaining()];
                buffer.get(array);
                int height = imageProxy.getHeight();
                int width = imageProxy.getWidth();

                Log.i("宽高3", width + "===" + height);
                PlanarYUVLuminanceSource source = new PlanarYUVLuminanceSource(array,
                        width,
                        height,
                        0,
                        0,
                        width,
                        height,
                        false);

                try {
                    final Result result = multiFormatReader.decode(new BinaryBitmap(new HybridBinarizer(source)));
                    Log.i("扫码出来的数据", result.getText());
                    if (result != null && eventSink != null) {
                        previewView.post(() -> {
                            if (eventSink != null)
                                eventSink.success(NativeUtils.scanDataToMap(result));
                        });
                    }
                } catch (Exception e) {
                    buffer.clear();
                }
                lastCurrentTimestamp = currentTimestamp;
            }
        }
    }


    @Override
    public void dispose() {
        lifecycleRegistry.markState(Lifecycle.State.DESTROYED);
        cameraProvider.unbindAll();
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
//                result.success(null);
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
