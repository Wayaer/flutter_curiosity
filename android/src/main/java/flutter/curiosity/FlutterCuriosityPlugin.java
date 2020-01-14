package flutter.curiosity;

import flutter.curiosity.zxing.ImageScanHelper;
import flutter.curiosity.zxing.ScanViewFactory;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterCuriosityPlugin
 */
public class FlutterCuriosityPlugin implements MethodCallHandler {
    private ImageScanHelper imageScanHelper;

    private FlutterCuriosityPlugin(Registrar registrar) {
        imageScanHelper = new ImageScanHelper(registrar.context());
    }

    public static void registerWith(Registrar registrar) {
        registrar.platformViewRegistry().registerViewFactory("FlutterCuriosityView", new ScanViewFactory(registrar.messenger()));
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "FlutterCuriosity");
        channel.setMethodCallHandler(new FlutterCuriosityPlugin(registrar));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "scanImagePath":
                imageScanHelper.scanImagePath(call, result);
                break;
            case "scanImageUrl":
                imageScanHelper.scanImageUrl(call, result);
                break;
            case "scanImageMemory":
                imageScanHelper.scanImageMemory(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }
}
