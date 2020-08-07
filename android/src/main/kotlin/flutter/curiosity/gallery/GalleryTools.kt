package flutter.curiosity.gallery

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.collection.ArrayMap
import androidx.core.content.FileProvider
import com.luck.picture.lib.PictureSelector
import com.luck.picture.lib.config.PictureConfig
import com.luck.picture.lib.config.PictureMimeType
import com.luck.picture.lib.tools.PictureFileUtils
import flutter.curiosity.CuriosityPlugin
import flutter.curiosity.CuriosityPlugin.Companion.activity
import flutter.curiosity.CuriosityPlugin.Companion.call
import flutter.curiosity.CuriosityPlugin.Companion.channelResult
import flutter.curiosity.CuriosityPlugin.Companion.context
import flutter.curiosity.gallery.GlideEngine.Companion.createGlideEngine
import flutter.curiosity.tools.Tools
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.util.*

object GalleryTools {

    fun openImagePicker() {
        val maxSelectNum = call.argument<Int>("maxSelectNum")!!
        val minSelectNum = call.argument<Int>("minSelectNum")!!
        val imageSpanCount = call.argument<Int>("imageSpanCount")!!
        val previewImage = call.argument<Boolean>("previewImage")!!
        val isZoomAnim = call.argument<Boolean>("isZoomAnim")!!
        val isCamera = call.argument<Boolean>("isCamera")!!
        val enableCrop = call.argument<Boolean>("enableCrop")!!
        val compress = call.argument<Boolean>("compress")!!
        val hideBottomControls = call.argument<Boolean>("hideBottomControls")!!
        val freeStyleCropEnabled = call.argument<Boolean>("freeStyleCropEnabled")!!
        val showCropCircle = call.argument<Boolean>("showCropCircle")!!
        val showCropFrame = call.argument<Boolean>("showCropFrame")!!
        val showCropGrid = call.argument<Boolean>("showCropGrid")!!
        val openClickSound = call.argument<Boolean>("openClickSound")!!
        val minimumCompressSize = call.argument<Int>("minimumCompressSize")!!
        val isGif = call.argument<Boolean>("isGif")!!
        val rotateEnabled = call.argument<Boolean>("rotateEnabled")!!
        val scaleEnabled = call.argument<Boolean>("scaleEnabled")!!
        val cropW = call.argument<Int>("cropW")!!
        val cropH = call.argument<Int>("cropH")!!
        val cropCompressQuality = call.argument<Int>("cropCompressQuality")!!
        val pickerSelectType = call.argument<Int>("pickerSelectType")!!
        val videoQuality = call.argument<Int>("videoQuality")!!
        val videoMaxSecond = call.argument<Int>("videoMaxSecond")!!
        val videoMinSecond = call.argument<Int>("videoMinSecond")!!
        val recordVideoSecond = call.argument<Int>("recordVideoSecond")!!
        val previewVideo = call.argument<Boolean>("previewVideo")!!
        val originalPhoto = call.argument<Boolean>("originalPhoto")!!
        val setOutputCameraPath = call.argument<String>("setOutputCameraPath")
        val pictureMimeType = when (pickerSelectType) {
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
        var suffixType = PictureMimeType.JPEG
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) suffixType = PictureMimeType.PNG_Q
        PictureSelector.create(activity)
                .openGallery(pictureMimeType) //全部.PictureMimeType.ofAll()、图片.ofImage()、视频.ofVideo()、音频.ofAudio()
                .imageEngine(createGlideEngine())
                .maxSelectNum(maxSelectNum) // 最大图片选择数量 int
                .minSelectNum(minSelectNum) // 最小选择数量 int
                .imageSpanCount(imageSpanCount) // 每行显示个数 int
                .selectionMode(if (maxSelectNum == 1) PictureConfig.SINGLE else PictureConfig.MULTIPLE) // 多选 or 单选 PictureConfig.MULTIPLE or PictureConfig.SINGLE
                .isPreviewImage(previewImage) // 是否可预览图片 true or false
                .isPreviewVideo(previewVideo) // 是否可预览视频 true or false
                .isCamera(isCamera) // 是否显示拍照按钮 true or false
                .imageFormat(suffixType) // 拍照保存图片格式后缀,默认jpeg
                .isZoomAnim(isZoomAnim) // 图片列表点击 缩放效果 默认true
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
                .videoQuality(videoQuality) // 视频录制质量 0 or 1 int
                .videoMaxSecond(videoMaxSecond) // 显示多少秒以内的视频or音频也可适用 int
                .videoMinSecond(videoMinSecond) // 显示多少秒以内的视频or音频也可适用 int
                .recordVideoSecond(recordVideoSecond) //视频秒数录制 默认60s int
                .isOriginalImageControl(originalPhoto)//是否显示原图按钮
                .setOutputCameraPath(if (setOutputCameraPath === "") context.getExternalFilesDir(Environment.DIRECTORY_PICTURES).toString() else setOutputCameraPath)
                .forResult(PictureConfig.CHOOSE_REQUEST) //结果回调onActivityResult code
    }


    fun deleteCacheDirFile() {
        val selectValueType = call.argument<Int>("selectValueType")
        val pictureMimeType: Int
        pictureMimeType = when (selectValueType) {
            1 -> {
                PictureMimeType.ofImage()
            }
            2 -> {
                PictureMimeType.ofVideo()
            }
            3 -> {
                PictureMimeType.ofAudio()
            }
            else -> {
                PictureMimeType.ofAll()
            }
        }
        PictureFileUtils.deleteCacheDirFile(activity, pictureMimeType)
        channelResult.success(Tools.resultSuccess())

    }

    fun onResult(intent: Intent?): MutableList<Map<String, Any>>? {
        // 图片、视频、音频选择结果回调
        // 例如 LocalMedia 里面返回四种path
        // 1.media.getPath(); 为原图path
        // 2.media.getCutPath();为裁剪后path，需判断media.isCut();是否为true  注意：音视频除外
        // 3.media.getCompressPath();为压缩后path，需判断media.isCompressed();是否为true  注意：音视频除外
        // 如果裁剪并压缩了，以取压缩路径为准，因为是先裁剪后压缩的
        // 4.media.getAndroidQToPath();为Android Q版本特有返回的字段，此字段有值就用来做上传使用
        val selectList = PictureSelector.obtainMultipleResult(intent)
        val resultList: MutableList<Map<String, Any>> = ArrayList()
        for (localMedia in selectList) {
            val resultMap: MutableMap<String, Any> = ArrayMap()
            resultMap["size"] = localMedia.size
            if (localMedia.path != null) resultMap["path"] = localMedia.path
            if (localMedia.isCut) {
                if (localMedia.cutPath != null) resultMap["cutPath"] = localMedia.cutPath
            }
            if (localMedia.isCompressed) {
                if (localMedia.compressPath != null) resultMap["compressPath"] = localMedia.compressPath
            }
            if (localMedia.chooseModel == PictureMimeType.ofVideo()) {
                resultMap["duration"] = localMedia.duration
            }
            resultMap["width"] = localMedia.width
            resultMap["height"] = localMedia.height
            if (localMedia.fileName != null) resultMap["fileName"] = localMedia.fileName
            resultList.add(resultMap)
        }
        return resultList;
    }

    fun openSystemGallery() {
        val intent = Intent(Intent.ACTION_PICK) //跳转到 ACTION_IMAGE_CAPTURE
        intent.type = "image/*"
        activity.startActivityForResult(intent, CuriosityPlugin.openSystemGalleryCode)
    }

    fun openSystemCamera() {
        var cameraSavePath = call.argument<String>("path")
        if (cameraSavePath == null) cameraSavePath = context.getExternalFilesDir(Environment.DIRECTORY_PICTURES)?.path.toString() + "/TEMP.JPG"
        val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        val uri: Uri
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            //第二个参数为 包名.fileprovider
            uri = FileProvider.getUriForFile(activity, context.packageName.toString() + ".fileprovider", File(cameraSavePath));
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        } else {
            uri = Uri.fromFile(File(cameraSavePath))
        }
        intent.putExtra(MediaStore.EXTRA_OUTPUT, uri);
        activity.startActivityForResult(intent, CuriosityPlugin.openSystemCameraCode)
    }

    fun saveImageToGallery() {
        val image = call.argument<ByteArray>("imageBytes") ?: return
        val quality = call.argument<Int>("quality") ?: return
        val name = call.argument<String>("name")
        channelResult.success(saveImage(BitmapFactory.decodeByteArray(image, 0, image.size), quality, name))
    }

    fun saveFileToGallery() {
        val filePath = call.arguments as String
        try {
            val originalFile = File(filePath)
            val file = generateFile(originalFile.extension)
            originalFile.copyTo(file)
            val uri = Uri.fromFile(file)
            context.sendBroadcast(Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri))
            channelResult.success(uri.toString())
        } catch (e: IOException) {
            e.printStackTrace()
            channelResult.error(e.printStackTrace().toString(), null, null)
        }
    }

    private fun saveImage(bmp: Bitmap, quality: Int, name: String?): String {
        val file = generateFile("jpg", name = name)
        try {
            val fos = FileOutputStream(file)
            println("ImageGallerySaverPlugin $quality")
            bmp.compress(Bitmap.CompressFormat.JPEG, quality, fos)
            fos.flush()
            fos.close()
            val uri = Uri.fromFile(file)
            context.sendBroadcast(Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri))
            bmp.recycle()
            return uri.toString()
        } catch (e: IOException) {
            e.printStackTrace()
        }
        return ""
    }

    private fun generateFile(extension: String = "", name: String? = null): File {
        val storePath = Environment.getExternalStorageDirectory().absolutePath + File.separator + getApplicationName()
        val appDir = File(storePath)
        if (!appDir.exists()) {
            appDir.mkdir()
        }
        var fileName = name ?: System.currentTimeMillis().toString()
        if (extension.isNotEmpty()) {
            fileName += (".$extension")
        }
        return File(appDir, fileName)
    }

    private fun getApplicationName(): String {
        var ai: ApplicationInfo? = null
        try {
            ai = context.packageManager.getApplicationInfo(context.packageName, 0)
        } catch (e: PackageManager.NameNotFoundException) {
        }
        val appName: String
        appName = if (ai != null) {
            val charSequence = context.packageManager.getApplicationLabel(ai)
            StringBuilder(charSequence.length).append(charSequence).toString()
        } else {
            "curiosity_temp_saver"
        }
        return appName
    }

}