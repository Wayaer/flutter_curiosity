package flutter.curiosity;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;

import androidx.annotation.NonNull;

import flutter.curiosity.gallery.PicturePicker;
import flutter.curiosity.utils.AppInfo;
import flutter.curiosity.utils.FileUtils;
import flutter.curiosity.utils.Utils;
import flutter.curiosity.zxing.CameraScansViewFactory;
import flutter.curiosity.zxing.ImageScanHelper;
import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.app.Activity.RESULT_OK;

/**
 * CuriosityPlugin
 */
public class CuriosityPlugin implements MethodCallHandler, ActivityAware, FlutterPlugin, PluginRegistry.ActivityResultListener {
    private static ImageScanHelper imageScanHelper;
    @SuppressLint("StaticFieldLeak")
    public static Context context;
    @SuppressLint("StaticFieldLeak")
    public static Activity activity;
    public static String cameraScansView = "CuriosityCameraScansView";
    private String methodChannelName = "Curiosity";

    private Result result;

    private MethodCall call;
    private MethodChannel methodChannel;


    public void registerWith(Registrar registrar) {
        CuriosityPlugin plugin = new CuriosityPlugin();
        plugin.methodChannel = new MethodChannel(registrar.messenger(), methodChannelName);
        context = registrar.context();
        activity = registrar.activity();
        methodChannel.setMethodCallHandler(plugin);
        registrar.addActivityResultListener(plugin);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        activity = null;

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel = new MethodChannel(binding.getBinaryMessenger(), methodChannelName);
        context = binding.getApplicationContext();
        methodChannel.setMethodCallHandler(this);
        imageScanHelper = new ImageScanHelper(binding.getApplicationContext());
        binding.getPlatformViewRegistry().registerViewFactory(cameraScansView, new CameraScansViewFactory(binding.getBinaryMessenger()));
    }


    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        context = null;
        activity = null;
        methodChannel.setMethodCallHandler(null);
        methodChannel = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall c, @NonNull Result res) {
        result = res;
        call = c;
        scanQR();
        getAppInfo();
        gallery();
        utils();
    }

    private void utils() {
        switch (call.method) {
            case "clearAllCookie":
                Utils.clearAllCookie();
                break;
            case "installApp":
                Utils.installApp(call.argument("apkPath"));
                break;
            case "getAllCookie":
                result.success(Utils.getAllCookie(call.argument("url")));
                break;
            case "getFilePathSize":
                result.success(Utils.getFilePathSize(call.argument("filePath")));
                break;
            case "deleteFolder":
                FileUtils.deleteFolder(call.argument("folderPath"));
                break;
            case "deleteFile":
                FileUtils.deleteFile(call.argument("filePath"));
                break;
            case "goToMarket":
                Utils.goToMarket(call.argument("packageName"), call.argument("marketPackageName"));
                break;
            case "isInstallApp":
                result.success(Utils.isInstallApp(call.argument("packageName")));
                break;
            case "exitApp":
                Utils.exitApp();
                break;
        }
    }

    private void gallery() {
        switch (call.method) {
            case "openSelect":
                Log.i("进来了", "应该进来了");
                PicturePicker.openSelect( call);
                break;
            case "openCamera":
                PicturePicker.openCamera( call);
                break;
            case "deleteCacheDirFile":
                PicturePicker.deleteCacheDirFile( call);
                break;
        }
    }

    private void getAppInfo() {
        if (call.method.equals("getAppInfo")) {//获取包名信息
            try {
                result.success(AppInfo.getAppInfo(context));
            } catch (PackageManager.NameNotFoundException e) {
                result.error("Name not found", e.getMessage(), null);
            }
        }
    }

    private void scanQR() {
        switch (call.method) {
            case "scanImagePath"://扫描本地二维码
                imageScanHelper.scanImagePath(call, result);
                break;
            case "scanImageUrl"://识别url 二维码
                imageScanHelper.scanImageUrl(call, result);
                break;
            case "scanImageMemory"://扫描二维码
                imageScanHelper.scanImageMemory(call, result);
                break;
        }
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent intent) {
        if (resultCode == RESULT_OK) {
            PicturePicker.onChooseResult(requestCode, intent, activity, result);
        }
        result.error("resultCode  not found", "onActivityResult error", null);
        return false;
    }


}
