package flutter.curiosity.gallery;

import android.app.Activity;
import android.content.Intent;
import android.os.Environment;
import android.util.Base64;

import androidx.collection.ArrayMap;

import com.luck.picture.lib.PictureSelector;
import com.luck.picture.lib.config.PictureConfig;
import com.luck.picture.lib.config.PictureMimeType;
import com.luck.picture.lib.entity.LocalMedia;
import com.luck.picture.lib.tools.PictureFileUtils;

import java.io.File;
import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import flutter.curiosity.CuriosityPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

@SuppressWarnings("ALL")
public class PicturePicker {
    static int maxSelectNum;
    static int minSelectNum;
    static int imageSpanCount;
    static int selectionMode;
    static boolean previewImage;
    static boolean isZoomAnim;
    static boolean isCamera;
    static boolean enableCrop;
    static boolean compress;
    static boolean hideBottomControls;
    static boolean freeStyleCropEnabled;
    static boolean showCropCircle;
    static boolean showCropFrame;
    static boolean showCropGrid;
    static boolean openClickSound;
    static boolean previewVideo;
    static int minimumCompressSize;
    static boolean isGif;
    static boolean rotateEnabled;
    static boolean scaleEnabled;
    static int cropW;
    static int cropH;
    static int cropCompressQuality;
    static int selectValueType;
    static int videoQuality;
    static int videoMaxSecond;
    static int videoMinSecond;
    static int recordVideoSecond;
    static String setOutputCameraPath;
    static List<LocalMedia> selectList;
    static int pictureMimeType = 0;

    static void setValue(MethodCall call) {
        maxSelectNum = call.argument("maxSelectNum");
        minSelectNum = call.argument("minSelectNum");
        imageSpanCount = call.argument("imageSpanCount");
        selectionMode = call.argument("selectionMode");
        previewImage = call.argument("previewImage");
        isZoomAnim = call.argument("isZoomAnim");
        isCamera = call.argument("isCamera");
        enableCrop = call.argument("enableCrop");
        compress = call.argument("compress");
        hideBottomControls = call.argument("hideBottomControls");
        freeStyleCropEnabled = call.argument("freeStyleCropEnabled");
        showCropCircle = call.argument("showCropCircle");
        showCropFrame = call.argument("showCropFrame");
        showCropGrid = call.argument("showCropGrid");
        openClickSound = call.argument("openClickSound");
        minimumCompressSize = call.argument("minimumCompressSize");
        isGif = call.argument("isGif");
        rotateEnabled = call.argument("rotateEnabled");
        scaleEnabled = call.argument("scaleEnabled");
//        selectList = call.argument("selectList");
        cropW = call.argument("cropW");
        cropH = call.argument("cropH");
        cropCompressQuality = call.argument("cropCompressQuality");
        selectValueType = call.argument("selectValueType");
        videoQuality = call.argument("videoQuality");
        videoMaxSecond = call.argument("videoMaxSecond");
        videoMinSecond = call.argument("videoMinSecond");
        recordVideoSecond = call.argument("recordVideoSecond");
        setOutputCameraPath = call.argument("setOutputCameraPath");
        if (selectValueType == 1) {
            pictureMimeType = PictureMimeType.ofImage();
        } else if (selectValueType == 2) {
            pictureMimeType = PictureMimeType.ofVideo();
        } else if (selectValueType == 3) {
            pictureMimeType = PictureMimeType.ofAudio();
        } else {
            pictureMimeType = PictureMimeType.ofAll();
        }
    }

    public static void openSelect(MethodCall call) {
        setValue(call);
        PictureSelector.create(CuriosityPlugin.activity)
                .openGallery(pictureMimeType)//全部.PictureMimeType.ofAll()、图片.ofImage()、视频.ofVideo()、音频.ofAudio()
                .loadImageEngine(GlideEngine.createGlideEngine())
                .maxSelectNum(maxSelectNum) // 最大图片选择数量 int
                .minSelectNum(minSelectNum) // 最小选择数量 int
                .imageSpanCount(imageSpanCount) // 每行显示个数 int
                .selectionMode(selectionMode == 1 ? PictureConfig.SINGLE : PictureConfig.MULTIPLE) // 多选 or 单选 PictureConfig.MULTIPLE or PictureConfig.SINGLE
                .previewImage(previewImage) // 是否可预览图片 true or false
                .previewVideo(previewVideo) // 是否可预览视频 true or false
                .enablePreviewAudio(false) // 是否可播放音频 true or false
                .isCamera(isCamera) // 是否显示拍照按钮 true or false
                .imageFormat(PictureMimeType.PNG) // 拍照保存图片格式后缀,默认jpeg
                .isZoomAnim(isZoomAnim) // 图片列表点击 缩放效果 默认true
                .sizeMultiplier(0.5f) // glide 加载图片大小 0~1之间 如设置 .glideOverride()无效
                .enableCrop(enableCrop) // 是否裁剪 true or false
                .compress(compress) // 是否压缩 true or false
                .glideOverride(160, 160) // int glide 加载宽高，越小图片列表越流畅，但会影响列表图片浏览的清晰度
                .withAspectRatio(cropW, cropH) // int 裁剪比例 如16:9 3:2 3:4 1:1 可自定义
                .hideBottomControls(hideBottomControls) // 是否显示uCrop工具栏，默认不显示 true or false
                .isGif(isGif) // 是否显示gif图片 true or false
                .freeStyleCropEnabled(freeStyleCropEnabled) // 裁剪框是否可拖拽 true or false
                .circleDimmedLayer(showCropCircle) // 是否圆形裁剪 true or false
                .showCropFrame(showCropFrame) // 是否显示裁剪矩形边框 圆形裁剪时建议设为false   true or false
                .showCropGrid(showCropGrid) // 是否显示裁剪矩形网格 圆形裁剪时建议设为false    true or false
                .openClickSound(openClickSound) // 是否开启点击声音 true or false
                .cropCompressQuality(cropCompressQuality) // 裁剪压缩质量 默认90 int
                .minimumCompressSize(minimumCompressSize) // 小于100kb的图片不压缩
                .synOrAsy(true) //同步true或异步false 压缩 默认同步
                .rotateEnabled(rotateEnabled) // 裁剪是否可旋转图片 true or false
                .scaleEnabled(scaleEnabled) // 裁剪是否可放大缩小图片 true or false
//                .selectionMedia(selectList) // 当前已选中的图片 List
                .videoQuality(videoQuality) // 视频录制质量 0 or 1 int
                .videoMaxSecond(videoMaxSecond) // 显示多少秒以内的视频or音频也可适用 int
                .videoMinSecond(videoMinSecond) // 显示多少秒以内的视频or音频也可适用 int
                .recordVideoSecond(recordVideoSecond) //视频秒数录制 默认60s int
                .setOutputCameraPath(setOutputCameraPath == "" ? String.valueOf(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)) : setOutputCameraPath)
                .forResult(PictureConfig.CHOOSE_REQUEST);//结果回调onActivityResult code

    }


    public static void openCamera(MethodCall call) {
        setValue(call);
        PictureSelector.create(CuriosityPlugin.activity)
                .openCamera(pictureMimeType)
                .imageFormat(PictureMimeType.PNG)// 拍照保存图片格式后缀,默认jpeg
                .enableCrop(enableCrop)// 是否裁剪 true or false
                .compress(compress)// 是否压缩 true or false
                .glideOverride(160, 160)// int glide 加载宽高，越小图片列表越流畅，但会影响列表图片浏览的清晰度
                .withAspectRatio(cropW, cropH)// int 裁剪比例 如16:9 3:2 3:4 1:1 可自定义
                .hideBottomControls(enableCrop)// 是否显示uCrop工具栏，默认不显示 true or false
                .freeStyleCropEnabled(freeStyleCropEnabled)// 裁剪框是否可拖拽 true or false
                .circleDimmedLayer(showCropCircle)// 是否圆形裁剪 true or false
                .showCropFrame(showCropFrame)// 是否显示裁剪矩形边框 圆形裁剪时建议设为false   true or false
                .showCropGrid(showCropGrid)// 是否显示裁剪矩形网格 圆形裁剪时建议设为false    true or false
                .cropCompressQuality(cropCompressQuality)// 裁剪压缩质量 默认90 int
                .minimumCompressSize(minimumCompressSize)// 小于100kb的图片不压缩
                .synOrAsy(true)//同步true或异步false 压缩 默认同步
                .rotateEnabled(rotateEnabled) // 裁剪是否可旋转图片 true or false
                .scaleEnabled(scaleEnabled)// 裁剪是否可放大缩小图片 true or false
                .openClickSound(openClickSound)// 是否开启点击声音 true or false
                .maxSelectNum(maxSelectNum)// 最大图片选择数量 int
                .minSelectNum(minSelectNum)// 最小选择数量 int
                .imageSpanCount(imageSpanCount)// 每行显示个数 int
                .selectionMode(selectionMode)// 多选 or 单选 PictureConfig.MULTIPLE or PictureConfig.SINGLE
                .previewImage(previewImage)// 是否可预览视频 true or false
                .previewVideo(previewVideo)// 是否可预览视频 true or false
                .videoQuality(videoQuality)// 视频录制质量 0 or 1 int
                .videoMaxSecond(videoMaxSecond)// 显示多少秒以内的视频or音频也可适用 int
                .videoMinSecond(videoMinSecond)// 显示多少秒以内的视频or音频也可适用 int
                .recordVideoSecond(recordVideoSecond)
                .setOutputCameraPath(setOutputCameraPath == "" ? String.valueOf(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)) : setOutputCameraPath)
                .forResult(PictureConfig.REQUEST_CAMERA);

    }

    public static void deleteCacheDirFile(MethodCall call) {
        int selectValueType = call.argument("selectValueType");
        int pictureMimeType = 0;
        if (selectValueType == 1) {
            pictureMimeType = PictureMimeType.ofImage();
        } else if (selectValueType == 2) {
            pictureMimeType = PictureMimeType.ofVideo();
        } else if (selectValueType == 3) {
            pictureMimeType = PictureMimeType.ofAudio();
        } else {
            pictureMimeType = PictureMimeType.ofAll();
        }
        PictureFileUtils.deleteCacheDirFile(CuriosityPlugin.activity, pictureMimeType);
    }

    public static void onChooseResult(int requestCode, Intent intent, Activity activity, MethodChannel.Result result) {
        // 图片、视频、音频选择结果回调
        // 例如 LocalMedia 里面返回四种path
        // 1.media.getPath(); 为原图path
        // 2.media.getCutPath();为裁剪后path，需判断media.isCut();是否为true  注意：音视频除外
        // 3.media.getCompressPath();为压缩后path，需判断media.isCompressed();是否为true  注意：音视频除外
        // 如果裁剪并压缩了，以取压缩路径为准，因为是先裁剪后压缩的
        // 4.media.getAndroidQToPath();为Android Q版本特有返回的字段，此字段有值就用来做上传使用
        List<LocalMedia> selectList = PictureSelector.obtainMultipleResult(intent);
        if (requestCode == PictureConfig.REQUEST_CAMERA) {
            onChooseResult(selectList, result);
        } else if (requestCode == PictureConfig.CHOOSE_REQUEST) {
            onChooseResult(selectList, result);
        }
    }

    private static void onChooseResult(List<LocalMedia> selectList, MethodChannel.Result result) {
        List<Map<String, Object>> resultList = new ArrayList<>();
        for (LocalMedia localMedia : selectList) {
            Map<String, Object> resultMap = new ArrayMap<>();
            resultMap.put("path", localMedia.getPath());
            resultMap.put("size", localMedia.getSize());
            if (localMedia.isCut()) {
                resultMap.put("cutPath", localMedia.getCutPath());
            }
            if (localMedia.isCompressed()) {
                resultMap.put("compressPath", localMedia.getCompressPath());
            }
            if (localMedia.getChooseModel() == PictureMimeType.ofVideo()) {
                resultMap.put("duration", localMedia.getDuration());
            }
            resultMap.put("width", localMedia.getWidth());
            resultMap.put("height", localMedia.getHeight());
            resultList.add(resultMap);
        }
        result.success(resultList);
    }

    private static String encodeBase64(String path) throws Exception {
        File file = new File(path);
        FileInputStream inputFile = new FileInputStream(file);
        byte[] buffer = new byte[(int) file.length()];
        inputFile.read(buffer);
        inputFile.close();
        return Base64.encodeToString(buffer, Base64.DEFAULT);
    }
}

