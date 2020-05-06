package flutter.curiosity.scanner.core;

import android.content.Context;
import android.graphics.Rect;
import android.hardware.Camera;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;


public abstract class BarcodeScannerView extends FrameLayout implements Camera.PreviewCallback {

    private CameraWrapper mCameraWrapper;
    private CameraPreview mPreview;
    private IViewFinder mViewFinderView;
    private Rect mFramingRectInPreview;
    private CameraHandlerThread mCameraHandlerThread;
    private Boolean mFlashState;
    private boolean mAutoFocusState = true;
    private float mAspectTolerance = 0.1f;

    public BarcodeScannerView(Context context) {
        super(context);
        mViewFinderView = new ViewFinderView(getContext());
    }

    public BarcodeScannerView(Context context, AttributeSet attributeSet) {
        super(context, attributeSet);
        mViewFinderView = new ViewFinderView(getContext());
    }


    public final void setupLayout(CameraWrapper cameraWrapper) {
        removeAllViews();

        mPreview = new CameraPreview(getContext(), cameraWrapper, this);
        mPreview.setAspectTolerance(mAspectTolerance);
        addView(mPreview);
        if (mViewFinderView instanceof View) {
            addView((View) mViewFinderView);
        } else {
            throw new IllegalArgumentException("IViewFinder object returned by " +
                    "'createViewFinderView()' should be instance of android.view.View");
        }
    }


    public void startCamera(int cameraId) {
        if (mCameraHandlerThread == null) {
            mCameraHandlerThread = new CameraHandlerThread(this);
        }
        mCameraHandlerThread.startCamera(cameraId);
    }

    public void setupCameraPreview(CameraWrapper cameraWrapper) {
        mCameraWrapper = cameraWrapper;
        if (mCameraWrapper != null) {
            setupLayout(mCameraWrapper);
            mViewFinderView.setupViewFinder();
            if (mFlashState != null) {
                setFlash(mFlashState);
            }
            setAutoFocus(mAutoFocusState);
        }
    }

    public void startCamera() {
        startCamera(CameraTools.getDefaultCameraId());
    }

    public void stopCamera() {
        if (mCameraWrapper != null) {
            mPreview.stopCameraPreview();
            mPreview.setCamera(null, null);
            mCameraWrapper.mCamera.release();
            mCameraWrapper = null;
        }
        if (mCameraHandlerThread != null) {
            mCameraHandlerThread.quit();
            mCameraHandlerThread = null;
        }
    }

    public void stopCameraPreview() {
        if (mPreview != null) {
            mPreview.stopCameraPreview();
        }
    }

    public synchronized Rect getFramingRectInPreview(int previewWidth, int previewHeight) {
        if (mFramingRectInPreview == null) {
            Rect framingRect = mViewFinderView.getFramingRect();
            int viewFinderViewWidth = mViewFinderView.getWidth();
            int viewFinderViewHeight = mViewFinderView.getHeight();
            if (framingRect == null || viewFinderViewWidth == 0 || viewFinderViewHeight == 0) {
                return null;
            }

            Rect rect = new Rect(framingRect);

            if (previewWidth < viewFinderViewWidth) {
                rect.left = rect.left * previewWidth / viewFinderViewWidth;
                rect.right = rect.right * previewWidth / viewFinderViewWidth;
            }

            if (previewHeight < viewFinderViewHeight) {
                rect.top = rect.top * previewHeight / viewFinderViewHeight;
                rect.bottom = rect.bottom * previewHeight / viewFinderViewHeight;
            }

            mFramingRectInPreview = rect;
        }
        return mFramingRectInPreview;
    }

    public boolean getFlash() {
        if (mCameraWrapper != null && CameraTools.isFlashSupported(mCameraWrapper.mCamera)) {
            Camera.Parameters parameters = mCameraWrapper.mCamera.getParameters();
            return parameters.getFlashMode().equals(Camera.Parameters.FLASH_MODE_TORCH);
        }
        return false;
    }

    public void setFlash(boolean flag) {
        mFlashState = flag;
        if (mCameraWrapper != null && CameraTools.isFlashSupported(mCameraWrapper.mCamera)) {

            Camera.Parameters parameters = mCameraWrapper.mCamera.getParameters();
            if (flag) {
                if (parameters.getFlashMode().equals(Camera.Parameters.FLASH_MODE_TORCH)) {
                    return;
                }
                parameters.setFlashMode(Camera.Parameters.FLASH_MODE_TORCH);
            } else {
                if (parameters.getFlashMode().equals(Camera.Parameters.FLASH_MODE_OFF)) {
                    return;
                }
                parameters.setFlashMode(Camera.Parameters.FLASH_MODE_OFF);
            }
            mCameraWrapper.mCamera.setParameters(parameters);
        }
    }

    public void setAutoFocus(boolean state) {
        mAutoFocusState = state;
        if (mPreview != null) {
            mPreview.setAutoFocus(state);
        }
    }

    public void setAspectTolerance(float aspectTolerance) {
        mAspectTolerance = aspectTolerance;
    }

    public byte[] getRotatedData(byte[] data, Camera camera) {
        Camera.Parameters parameters = camera.getParameters();
        Camera.Size size = parameters.getPreviewSize();
        int width = size.width;
        int height = size.height;

        int rotationCount = getRotationCount();

        if (rotationCount == 1 || rotationCount == 3) {
            for (int i = 0; i < rotationCount; i++) {
                byte[] rotatedData = new byte[data.length];
                for (int y = 0; y < height; y++) {
                    for (int x = 0; x < width; x++)
                        rotatedData[x * height + height - y - 1] = data[x + y * width];
                }
                data = rotatedData;
                int tmp = width;
                width = height;
                height = tmp;
            }
        }

        return data;
    }

    public int getRotationCount() {
        int displayOrientation = mPreview.getDisplayOrientation();
        return displayOrientation / 90;
    }
}

