package flutter.curiosity.gallery

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider

import flutter.curiosity.CuriosityPlugin
import flutter.curiosity.CuriosityPlugin.Companion.call
import flutter.curiosity.CuriosityPlugin.Companion.result
import flutter.curiosity.CuriosityPlugin.Companion.resultFail
import flutter.curiosity.CuriosityPlugin.Companion.resultSuccess
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

object GalleryTools {

    fun openSystemGallery(activity: Activity) {
        val intent = Intent(Intent.ACTION_PICK)
        intent.type = "image/*"
        activity.startActivityForResult(intent, CuriosityPlugin.openSystemGalleryCode)
    }

    fun openSystemCamera(context: Context, activity: Activity) {
        val arguments = call.arguments as MutableMap<*, *>
        var cameraSavePath = arguments["savePath"] as String?
        if (cameraSavePath == null) cameraSavePath =
            context.getExternalFilesDir(Environment.DIRECTORY_PICTURES)?.path.toString() + "/TEMP.JPG"
        val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        val uri: Uri
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            //第二个参数为 包名.fierier
            uri =
                FileProvider.getUriForFile(activity, context.packageName.toString() + ".provider", File(cameraSavePath))
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        } else uri = Uri.fromFile(File(cameraSavePath))
        intent.putExtra(MediaStore.EXTRA_OUTPUT, uri)
        activity.startActivityForResult(intent, CuriosityPlugin.openSystemCameraCode)
    }

    fun saveImageToGallery(context: Context) {
        val image = call.argument<ByteArray>("imageBytes") ?: return
        val quality = call.argument<Int>("quality") ?: return
        val name = call.argument<String>("name")
        val file = generateFile(context, "jpg", name = name)
        val bmp = BitmapFactory.decodeByteArray(image, 0, image.size)
        try {
            val fos = FileOutputStream(file)
            bmp.compress(Bitmap.CompressFormat.JPEG, quality, fos)
            fos.flush()
            fos.close()
            val uri = Uri.fromFile(file)
            context.sendBroadcast(Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri))
            bmp.recycle()
            result.success(uri.toString())
        } catch (e: IOException) {
            e.printStackTrace()
            result.success(resultFail)
        }

    }

    fun saveFileToGallery(context: Context) {
        val filePath = call.arguments as String
        try {
            val originalFile = File(filePath)
            val file = generateFile(context, originalFile.extension)
            originalFile.copyTo(file)
            val uri = Uri.fromFile(file)
            context.sendBroadcast(Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri))
            result.success(resultSuccess)
        } catch (e: IOException) {
            e.printStackTrace()
            result.success(resultFail)
        }
    }


    private fun generateFile(
        context: Context, extension: String = "", name:
        String? = null
    ):
            File {
        val storePath = context.getExternalFilesDir(null)?.path.toString() +
                File.separator + getApplicationName(context)
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

    private fun getApplicationName(context: Context): String {
        var ai: ApplicationInfo? = null
        try {
            ai = context.packageManager.getApplicationInfo(context.packageName, 0)
        } catch (e: PackageManager.NameNotFoundException) {
        }
        return if (ai != null) {
            val charSequence = context.packageManager.getApplicationLabel(ai)
            StringBuilder(charSequence.length).append(charSequence).toString()
        } else {
            "curiosity_temp_save"
        }
    }

}