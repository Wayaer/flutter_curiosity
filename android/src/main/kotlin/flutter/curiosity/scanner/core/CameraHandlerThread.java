package flutter.curiosity.scanner.core;


import android.hardware.Camera;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;

class CameraHandlerThread extends HandlerThread {

    private BarcodeScannerView mScannerView;

    CameraHandlerThread(BarcodeScannerView scannerView) {
        super("CameraHandlerThread");
        mScannerView = scannerView;
        start();
    }

    void startCamera(final int cameraId) {
        Handler localHandler = new Handler(getLooper());
        localHandler.post(new Runnable() {
            @Override
            public void run() {
                final Camera camera = CameraUtils.getCameraInstance(cameraId);
                Handler mainHandler = new Handler(Looper.getMainLooper());
                mainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        mScannerView.setupCameraPreview(CameraWrapper.getWrapper(camera, cameraId));
                    }
                });
            }
        });
    }
}
