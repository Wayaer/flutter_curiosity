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
import android.webkit.MimeTypeMap
import io.flutter.plugin.common.MethodCall
import java.io.File
import java.io.FileInputStream
import java.io.OutputStream

object ImageGalleryTools {

    private fun generateUri(context: Context, extension: String, fileName: String): Uri? {
        val mimeType = getMIMEType(extension)
        val isVideo = mimeType?.startsWith("video") == true
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // >= android 10
            val uri = when {
                isVideo -> MediaStore.Video.Media.EXTERNAL_CONTENT_URI
                else -> MediaStore.Images.Media.EXTERNAL_CONTENT_URI
            }
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH, when {
                        isVideo -> Environment.DIRECTORY_MOVIES
                        else -> Environment.DIRECTORY_PICTURES
                    }
                )
                if (!TextUtils.isEmpty(mimeType)) {
                    put(
                        when {
                            isVideo -> MediaStore.Video.Media.MIME_TYPE
                            else -> MediaStore.Images.Media.MIME_TYPE
                        }, mimeType
                    )
                }
            }
            context.contentResolver?.insert(uri, values)
        } else {
            // < android 10
            val storePath = Environment.getExternalStoragePublicDirectory(
                when {
                    isVideo -> Environment.DIRECTORY_MOVIES
                    else -> Environment.DIRECTORY_PICTURES
                }
            ).absolutePath
            val appDir = File(storePath).apply {
                if (!exists()) {
                    mkdir()
                }
            }
            val file =
                File(appDir, if (extension.isNotEmpty()) "$fileName.$extension" else fileName)
            Uri.fromFile(file)
        }
    }

    /**
     * get file Mime Type
     *
     * @param extension extension
     * @return file Mime Type
     */
    private fun getMIMEType(extension: String): String? {
        return if (!TextUtils.isEmpty(extension)) {
            MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension.lowercase())
        } else {
            null
        }
    }

    /**
     * Send storage success notification
     *
     * @param context context
     * @param fileUri file path
     */
    private fun sendBroadcast(context: Context, fileUri: Uri?) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            val mediaScanIntent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
            mediaScanIntent.data = fileUri
            context.sendBroadcast(mediaScanIntent)
        }
    }

    fun saveBytesImageToGallery(context: Context, call: MethodCall): Boolean {
        val byteArray = call.argument<ByteArray>("bytes")!!
        val quality = call.argument<Int>("quality")!!
        val name = call.argument<String>("name")!!
        val extension = call.argument<String>("extension")!!
        var sourceBitmap: Bitmap? = null
        var targetUri: Uri? = null
        var targetStream: OutputStream? = null
        var success = false
        try {
            sourceBitmap = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)
            targetUri = generateUri(context, extension, name)
            if (targetUri != null) {
                targetStream = context.contentResolver.openOutputStream(targetUri)
                targetStream?.let {
                    val format = Bitmap.CompressFormat.valueOf(extension.uppercase())
                    sourceBitmap.compress(format, quality, it)
                    it.flush()
                    success = true
                }
            }
        } catch (e: Exception) {
            println("saveBytesImageToGallery exception : $e")
        } finally {
            targetStream?.close()
            sourceBitmap?.recycle()
        }
        if (success) {
            sendBroadcast(context, targetUri)
        }
        return success
    }

    fun saveFilePathToGallery(context: Context, call: MethodCall): Boolean {
        val sourcePath = call.argument<String>("path")!!
        val name = call.argument<String>("name")!!
        var targetUri: Uri? = null
        var targetStream: OutputStream? = null
        var sourceStream: FileInputStream? = null
        var success = false
        try {
            val sourceFile = File(sourcePath)
            if (!sourceFile.exists()) return false
            targetUri = generateUri(context, sourceFile.extension, name)
            if (targetUri != null) {
                targetStream = context.contentResolver?.openOutputStream(targetUri)
                if (targetStream != null) {
                    sourceStream = FileInputStream(sourceFile)
                    val buffer = ByteArray(10240)
                    var count: Int
                    while (sourceStream.read(buffer).also { count = it } > 0) {
                        targetStream.write(buffer, 0, count)
                    }
                    targetStream.flush()
                    success = true
                }
            }
        } catch (e: Exception) {
            println("saveFilePathToGallery exception : $e")
        } finally {
            targetStream?.close()
            sourceStream?.close()
        }
        if (success) {
            sendBroadcast(context, targetUri)
        }
        return success
    }
}
