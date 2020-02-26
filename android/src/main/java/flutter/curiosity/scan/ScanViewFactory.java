package flutter.curiosity.scan;

import android.content.Context;
import android.os.Build;

import androidx.annotation.RequiresApi;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class ScanViewFactory extends PlatformViewFactory {
    private final BinaryMessenger messenger;

    public ScanViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int i, Object object) {
        return new ScanView(context, messenger, i, object);
    }
}
