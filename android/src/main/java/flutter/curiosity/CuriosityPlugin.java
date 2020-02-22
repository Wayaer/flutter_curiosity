package flutter.curiosity;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;

import androidx.annotation.NonNull;

import flutter.curiosity.gallery.PicturePicker;
import flutter.curiosity.scan.ScanHelper;
import flutter.curiosity.utils.AppInfo;
import flutter.curiosity.utils.FileUtils;
import flutter.curiosity.utils.NativeUtils;
import flutter.curiosity.scan.ScanViewFactory;
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
    private static ScanHelper scanUtils;
    @SuppressLint("StaticFieldLeak")
    public static Context context;
    @SuppressLint("StaticFieldLeak")
    public static Activity activity;
    public static String scanView = "scanView";
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
        scanUtils = new ScanHelper(binding.getApplicationContext());
        binding.getPlatformViewRegistry().registerViewFactory(scanView, new ScanViewFactory(binding.getBinaryMessenger()));
    }


    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        context = null;
        activity = null;
        methodChannel.setMethodCallHandler(null);
        methodChannel = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall _call, @NonNull Result _result) {
        result = _result;
        call = _call;
        scan();
        getAppInfo();
        gallery();
        utils();
    }

    private void utils() {
        switch (call.method) {
            case "clearAllCookie":
                NativeUtils.clearAllCookie();
                break;
            case "installApp":
                NativeUtils.installApp(call.argument("apkPath"));
                break;
            case "getAllCookie":
                result.success(NativeUtils.getAllCookie(call.argument("url")));
                break;
            case "getFilePathSize":
                result.success(NativeUtils.getFilePathSize(call.argument("filePath")));
                break;
            case "deleteDirectory":
                FileUtils.deleteDirectory(call.argument("directoryPath"));
                break;
            case "deleteFile":
                FileUtils.deleteFile(call.argument("filePath"));
                break;
            case "goToMarket":
                NativeUtils.goToMarket(call.argument("packageName"), call.argument("marketPackageName"));
                break;
            case "isInstallApp":
                result.success(NativeUtils.isInstallApp(call.argument("packageName")));
                break;
            case "exitApp":
                NativeUtils.exitApp();
                break;
        }
    }

    private void gallery() {
        switch (call.method) {
            case "openSelect":
                PicturePicker.openSelect(call);
                break;
            case "openCamera":
                PicturePicker.openCamera(call);
                break;
            case "deleteCacheDirFile":
                PicturePicker.deleteCacheDirFile(call);
                break;
        }
    }

    private void getAppInfo() {
        switch (call.method) {
            case "getAppInfo":
                try {
                    result.success(AppInfo.getAppInfo(context));
                } catch (PackageManager.NameNotFoundException e) {
                    result.error("Name not found", e.getMessage(), null);
                }
                break;
            case "getDirectoryAllName":
                result.success(FileUtils.getDirectoryAllName(call));
                break;
        }
    }


    private void scan() {
        switch (call.method) {
            case "scanImagePath"://扫描本地二维码
                scanUtils.scanImagePath(call, result);
                break;
            case "scanImageUrl"://识别url 二维码
                scanUtils.scanImageUrl(call, result);
                break;
            case "scanImageMemory"://扫描二维码
                scanUtils.scanImageMemory(call, result);
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
