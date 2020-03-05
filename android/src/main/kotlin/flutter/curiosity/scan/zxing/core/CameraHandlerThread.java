package flutter.curiosity.scan.zxing.core;


import android.hardware.Camera;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;


public class CameraHandlerThread extends HandlerThread {

    private BarcodeScannerView mScannerView;

    public CameraHandlerThread(BarcodeScannerView scannerView) {
        super("CameraHandlerThread");
        mScannerView = scannerView;
        start();
    }

    public void startCamera(final int cameraId) {
        Handler localHandler = new Handler(getLooper());
        localHandler.post(() -> {
            final Camera camera = CameraUtils.getCameraInstance(cameraId);
            Handler mainHandler = new Handler(Looper.getMainLooper());
            mainHandler.post(() -> mScannerView.setupCameraPreview(CameraWrapper.getWrapper(camera, cameraId)));
        });
    }
}
