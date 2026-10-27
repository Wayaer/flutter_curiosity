package flutter.curiosity

import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.text.TextUtils
import android.util.Log
import android.webkit.MimeTypeMap
import io.flutter.plugin.common.MethodCall
import java.io.File
import java.io.FileInputStream

object ImageGalleryTools {

    private const val TAG = "CuriosityImageGallery"

    private fun generateUri(context: Context, extension: String, fileName: String): Uri? {
        val mimeType = getMIMEType(extension)
        val isVideo = mimeType?.startsWith("video") == true
        val displayName = if (extension.isEmpty()) fileName else "$fileName.$extension"
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // >= android 10
            val uri = if (isVideo) {
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI
            } else {
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            }
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, displayName)
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH,
                    if (isVideo) Environment.DIRECTORY_MOVIES else Environment.DIRECTORY_PICTURES
                )
                if (!TextUtils.isEmpty(mimeType)) {
                    put(
                        if (isVideo) MediaStore.Video.Media.MIME_TYPE else MediaStore.Images.Media.MIME_TYPE,
                        mimeType
                    )
                }
            }
            context.contentResolver.insert(uri, values)
        } else {
            // < android 10
            val storePath = Environment.getExternalStoragePublicDirectory(
                if (isVideo) Environment.DIRECTORY_MOVIES else Environment.DIRECTORY_PICTURES
            ).absolutePath
            val appDir = File(storePath).apply { if (!exists()) mkdirs() }
            Uri.fromFile(File(appDir, displayName))
        }
    }

    /**
     * Returns the mime type of [extension].
     */
    private fun getMIMEType(extension: String): String? {
        if (TextUtils.isEmpty(extension)) return null
        return MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension.lowercase())
    }

    /**
     * Sends a media scanner broadcast so the saved file shows up in the gallery on Android 9 and below.
     */
    private fun sendBroadcast(context: Context, fileUri: Uri?) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q && fileUri != null) {
            val mediaScanIntent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
            mediaScanIntent.data = fileUri
            context.sendBroadcast(mediaScanIntent)
        }
    }

    fun saveBytesImageToGallery(context: Context, call: MethodCall): Boolean {
        val byteArray = call.argument<ByteArray>("bytes") ?: return false
        val quality = call.argument<Int>("quality") ?: 100
        val name = call.argument<String>("name") ?: System.currentTimeMillis().toString()
        val extension = call.argument<String>("extension") ?: return false
        val sourceBitmap = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size) ?: return false
        var targetUri: Uri? = null
        var success = false
        try {
            targetUri = generateUri(context, extension, name)
            val targetStream = targetUri?.let { context.contentResolver.openOutputStream(it) }
            if (targetStream != null) {
                targetStream.use { stream ->
                    val format = when (extension.lowercase()) {
                        "png" -> Bitmap.CompressFormat.PNG
                        "jpeg", "jpg" -> Bitmap.CompressFormat.JPEG
                        else -> null
                    }
                    if (format != null) {
                        success = sourceBitmap.compress(format, quality, stream)
                        stream.flush()
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "saveBytesImageToGallery failed", e)
        } finally {
            sourceBitmap.recycle()
        }
        if (!success && targetUri != null) {
            runCatching { context.contentResolver.delete(targetUri, null, null) }
        }
        if (success) {
            sendBroadcast(context, targetUri)
        }
        return success
    }

    fun saveFilePathToGallery(context: Context, call: MethodCall): Boolean {
        val sourcePath = call.argument<String>("path") ?: return false
        val name = call.argument<String>("name") ?: return false
        var targetUri: Uri? = null
        var success = false
        try {
            val sourceFile = File(sourcePath)
            if (!sourceFile.exists()) return false
            targetUri = generateUri(context, sourceFile.extension, name)
            val targetStream = targetUri?.let { context.contentResolver.openOutputStream(it) }
            if (targetStream != null) {
                targetStream.use { output ->
                    FileInputStream(sourceFile).use { input ->
                        val buffer = ByteArray(10 * 1024)
                        var count: Int
                        while (input.read(buffer).also { count = it } > 0) {
                            output.write(buffer, 0, count)
                        }
                        output.flush()
                        success = true
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "saveFilePathToGallery failed", e)
        }
        if (!success && targetUri != null) {
            runCatching { context.contentResolver.delete(targetUri, null, null) }
        }
        if (success) {
            sendBroadcast(context, targetUri)
        }
        return success
    }
}
