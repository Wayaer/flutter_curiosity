package flutter.curiosity.gallery

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Build
import android.os.Environment
import android.util.Base64
import androidx.annotation.RequiresApi
import androidx.collection.ArrayMap
import com.luck.picture.lib.PictureSelector
import com.luck.picture.lib.config.PictureConfig
import com.luck.picture.lib.config.PictureMimeType
import com.luck.picture.lib.entity.LocalMedia
import com.luck.picture.lib.tools.PictureFileUtils
import flutter.curiosity.BuildConfig
import flutter.curiosity.CuriosityPlugin.Companion.activity
import flutter.curiosity.CuriosityPlugin.Companion.call
import flutter.curiosity.CuriosityPlugin.Companion.context
import flutter.curiosity.gallery.GlideEngine.Companion.createGlideEngine
import io.flutter.plugin.common.MethodCall
import java.io.File
import java.io.FileInputStream
import java.util.*

object PicturePicker {
    private var maxSelectNum = 0
    private var minSelectNum = 0
    private var imageSpanCount = 0
    private var selectionMode = 0
    private var previewImage = false
    private var isZoomAnim = false
    private var isCamera = false
    private var enableCrop = false
    private var compress = false
    private var hideBottomControls = false
    private var freeStyleCropEnabled = false
    private var showCropCircle = false
    private var showCropFrame = false
    private var showCropGrid = false
    private var openClickSound = false
    private var previewVideo = false
    private var minimumCompressSize = 0
    private var isGif = false
    private var rotateEnabled = false
    private var scaleEnabled = false
    private var cropW = 0
    private var cropH = 0
    private var cropCompressQuality = 0
    private var pickerSelectType = 0
    private var videoQuality = 0
    private var videoMaxSecond = 0
    private var videoMinSecond = 0
    private var recordVideoSecond = 0
    private var setOutputCameraPath: String? = null
    private var selectList: List<LocalMedia>? = null
    private var pictureMimeType = 0
    private fun setValue() {
        maxSelectNum = call.argument<Int>("maxSelectNum")!!
        minSelectNum = call.argument<Int>("minSelectNum")!!
        imageSpanCount = call.argument<Int>("imageSpanCount")!!
        selectionMode = call.argument<Int>("selectionMode")!!
        previewImage = call.argument<Boolean>("previewImage")!!
        isZoomAnim = call.argument<Boolean>("isZoomAnim")!!
        isCamera = call.argument<Boolean>("isCamera")!!
        enableCrop = call.argument<Boolean>("enableCrop")!!
        compress = call.argument<Boolean>("compress")!!
        hideBottomControls = call.argument<Boolean>("hideBottomControls")!!
        freeStyleCropEnabled = call.argument<Boolean>("freeStyleCropEnabled")!!
        showCropCircle = call.argument<Boolean>("showCropCircle")!!
        showCropFrame = call.argument<Boolean>("showCropFrame")!!
        showCropGrid = call.argument<Boolean>("showCropGrid")!!
        openClickSound = call.argument<Boolean>("openClickSound")!!
        minimumCompressSize = call.argument<Int>("minimumCompressSize")!!
        isGif = call.argument<Boolean>("isGif")!!
        rotateEnabled = call.argument<Boolean>("rotateEnabled")!!
        scaleEnabled = call.argument<Boolean>("scaleEnabled")!!
        //        selectList = call.argument("selectList");
        cropW = call.argument<Int>("cropW")!!
        cropH = call.argument<Int>("cropH")!!
        cropCompressQuality = call.argument<Int>("cropCompressQuality")!!
        pickerSelectType = call.argument<Int>("pickerSelectType")!!
        videoQuality = call.argument<Int>("videoQuality")!!
        videoMaxSecond = call.argument<Int>("videoMaxSecond")!!
        videoMinSecond = call.argument<Int>("videoMinSecond")!!
        recordVideoSecond = call.argument<Int>("recordVideoSecond")!!
        setOutputCameraPath = call.argument<String>("setOutputCameraPath")
        pictureMimeType = when (pickerSelectType) {
            1 -> {
                PictureMimeType.ofImage()
            }
            2 -> {
                PictureMimeType.ofVideo()
            }
            else -> {
                PictureMimeType.ofAll()
            }
        }
    }

    @SuppressLint("NewApi")
    fun openPicker() {
        setValue()
        PictureSelector.create(activity)
                .openGallery(pictureMimeType) //全部.PictureMimeType.ofAll()、图片.ofImage()、视频.ofVideo()、音频.ofAudio()
                .imageEngine(createGlideEngine())
                .maxSelectNum(maxSelectNum) // 最大图片选择数量 int
                .minSelectNum(minSelectNum) // 最小选择数量 int
                .imageSpanCount(imageSpanCount) // 每行显示个数 int
                .selectionMode(if (selectionMode == 1) PictureConfig.SINGLE else PictureConfig.MULTIPLE) // 多选 or 单选 PictureConfig.MULTIPLE or PictureConfig.SINGLE
                .isPreviewImage(previewImage) // 是否可预览图片 true or false
                .isPreviewVideo(previewVideo) // 是否可预览视频 true or false
//                .enablePreviewAudio(false) // 是否可播放音频 true or false
                .isCamera(isCamera) // 是否显示拍照按钮 true or false
                .imageFormat(PictureMimeType.JPEG) // 拍照保存图片格式后缀,默认jpeg
                .isZoomAnim(isZoomAnim) // 图片列表点击 缩放效果 默认true
//                .sizeMultiplier(0.5F) // glide 加载图片大小 0~1之间 如设置 .glideOverride()无效
                .isEnableCrop(enableCrop) // 是否裁剪 true or false
                .isCompress(compress) // 是否压缩 true or false
                .withAspectRatio(cropW, cropH) // int 裁剪比例 如16:9 3:2 3:4 1:1 可自定义
                .hideBottomControls(hideBottomControls) // 是否显示uCrop工具栏，默认不显示 true or false
                .isGif(isGif) // 是否显示gif图片 true or false
                .freeStyleCropEnabled(freeStyleCropEnabled) // 裁剪框是否可拖拽 true or false
                .circleDimmedLayer(showCropCircle) // 是否圆形裁剪 true or false
                .showCropFrame(showCropFrame) // 是否显示裁剪矩形边框 圆形裁剪时建议设为false   true or false
                .showCropGrid(showCropGrid) // 是否显示裁剪矩形网格 圆形裁剪时建议设为false    true or false
                .isOpenClickSound(openClickSound) // 是否开启点击声音 true or false
                .cutOutQuality(cropCompressQuality) // 裁剪压缩质量 默认90 int
                .minimumCompressSize(minimumCompressSize) // 小于100kb的图片不压缩
                .synOrAsy(true) //同步true或异步false 压缩 默认同步
                .rotateEnabled(rotateEnabled) // 裁剪是否可旋转图片 true or false
                .scaleEnabled(scaleEnabled) // 裁剪是否可放大缩小图片 true or false
//                .selectionMedia(selectList) // 当前已选中的图片 List
                .videoQuality(videoQuality) // 视频录制质量 0 or 1 int
                .videoMaxSecond(videoMaxSecond) // 显示多少秒以内的视频or音频也可适用 int
                .videoMinSecond(videoMinSecond) // 显示多少秒以内的视频or音频也可适用 int
                .recordVideoSecond(recordVideoSecond) //视频秒数录制 默认60s int
                .setOutputCameraPath(if (setOutputCameraPath === "") context.getExternalFilesDir(Environment.DIRECTORY_PICTURES).toString() else setOutputCameraPath)
                .forResult(PictureConfig.CHOOSE_REQUEST) //结果回调onActivityResult code
    }

    @SuppressLint("NewApi")
    fun openCamera() {
        setValue()
        PictureSelector.create(activity)
                .openCamera(pictureMimeType)
                .imageFormat(PictureMimeType.JPEG) // 拍照保存图片格式后缀,默认jpeg
                .isEnableCrop(enableCrop) // 是否裁剪 true or false
                .isCompress(compress) // 是否压缩 true or false
                .withAspectRatio(cropW, cropH) // int 裁剪比例 如16:9 3:2 3:4 1:1 可自定义
                .hideBottomControls(enableCrop) // 是否显示uCrop工具栏，默认不显示 true or false
                .freeStyleCropEnabled(freeStyleCropEnabled) // 裁剪框是否可拖拽 true or false
                .circleDimmedLayer(showCropCircle) // 是否圆形裁剪 true or false
                .showCropFrame(showCropFrame) // 是否显示裁剪矩形边框 圆形裁剪时建议设为false   true or false
                .showCropGrid(showCropGrid) // 是否显示裁剪矩形网格 圆形裁剪时建议设为false    true or false
                .cutOutQuality(cropCompressQuality) // 裁剪压缩质量 默认90 int
                .minimumCompressSize(minimumCompressSize) // 小于100kb的图片不压缩
                .synOrAsy(true) //同步true或异步false 压缩 默认同步
                .rotateEnabled(rotateEnabled) // 裁剪是否可旋转图片 true or false
                .scaleEnabled(scaleEnabled) // 裁剪是否可放大缩小图片 true or false
                .isOpenClickSound(openClickSound) // 是否开启点击声音 true or false
                .maxSelectNum(maxSelectNum) // 最大图片选择数量 int
                .minSelectNum(minSelectNum) // 最小选择数量 int
                .imageSpanCount(imageSpanCount) // 每行显示个数 int
                .selectionMode(selectionMode) // 多选 or 单选 PictureConfig.MULTIPLE or PictureConfig.SINGLE
                .isPreviewImage(previewImage) // 是否可预览视频 true or false
                .isPreviewVideo(previewVideo) // 是否可预览视频 true or false
                .videoQuality(videoQuality) // 视频录制质量 0 or 1 int
                .videoMaxSecond(videoMaxSecond) // 显示多少秒以内的视频or音频也可适用 int
                .videoMinSecond(videoMinSecond) // 显示多少秒以内的视频or音频也可适用 int
                .recordVideoSecond(recordVideoSecond)
                .setOutputCameraPath(if (setOutputCameraPath === "") context.getExternalFilesDir(Environment.DIRECTORY_PICTURES).toString() else setOutputCameraPath)
                .forResult(PictureConfig.REQUEST_CAMERA)
    }

    fun deleteCacheDirFile() {
        val selectValueType = call.argument<Int>("selectValueType")
        if (BuildConfig.DEBUG && selectValueType == null) {
            error("Assertion failed")
        }
        val pictureMimeType: Int
        pictureMimeType = when (selectValueType) {
            1 -> {
                PictureMimeType.ofImage()
            }
            2 -> {
                PictureMimeType.ofVideo()
            }
            else -> {
                PictureMimeType.ofAll()
            }
        }
        PictureFileUtils.deleteCacheDirFile(activity, pictureMimeType)
    }

    fun onResult(requestCode: Int, intent: Intent): MutableList<Map<String, Any>>? {
        // 图片、视频、音频选择结果回调
        // 例如 LocalMedia 里面返回四种path
        // 1.media.getPath(); 为原图path
        // 2.media.getCutPath();为裁剪后path，需判断media.isCut();是否为true  注意：音视频除外
        // 3.media.getCompressPath();为压缩后path，需判断media.isCompressed();是否为true  注意：音视频除外
        // 如果裁剪并压缩了，以取压缩路径为准，因为是先裁剪后压缩的
        // 4.media.getAndroidQToPath();为Android Q版本特有返回的字段，此字段有值就用来做上传使用
        val selectList = PictureSelector.obtainMultipleResult(intent)
        if (requestCode == PictureConfig.REQUEST_CAMERA) {
            return onChooseResult(selectList)
        } else if (requestCode == PictureConfig.CHOOSE_REQUEST) {
            return onChooseResult(selectList)
        }
        return null
    }

    private fun onChooseResult(selectList: MutableList<LocalMedia>): MutableList<Map<String, Any>> {
        val resultList: MutableList<Map<String, Any>> = ArrayList()
        for (localMedia in selectList) {
            val resultMap: MutableMap<String, Any> = ArrayMap()
            resultMap["path"] = localMedia.path
            resultMap["size"] = localMedia.size
            if (localMedia.isCut) {
                resultMap["cutPath"] = localMedia.cutPath
            }
            if (localMedia.isCompressed) {
                resultMap["compressPath"] = localMedia.compressPath
            }
            if (localMedia.chooseModel == PictureMimeType.ofVideo()) {
                resultMap["duration"] = localMedia.duration
            }
            resultMap["width"] = localMedia.width
            resultMap["height"] = localMedia.height
            resultMap["fileName"] = localMedia.fileName
            resultList.add(resultMap)
        }
        return resultList;
    }


}