package flutter.curiosity.zxing;

import android.content.Context;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class   CameraScansViewFactory extends PlatformViewFactory {
    private final BinaryMessenger messenger;

    public CameraScansViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger=messenger;
    }

    @Override
    public PlatformView create(Context context, int i, Object o) {
        return new CameraScansView(context,messenger,i,o);
    }
}
