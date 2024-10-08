package flutter.curiosity

import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Environment
import android.os.Build
import android.provider.MediaStore
import java.io.File
import java.io.FileInputStream
import android.text.TextUtils
import android.webkit.MimeTypeMap
import io.flutter.plugin.common.MethodCall
import java.io.OutputStream

object ImageGalleryTools {

    private fun generateUri(
        context: Context, extension: String = "JPG", name: String? = null
    ): Uri? {
        val fileName = name ?: System.currentTimeMillis().toString()
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

    fun saveBytesImage(context: Context, call: MethodCall): Boolean {
        val byteArray = call.argument<ByteArray>("bytes")!!
        val quality = call.argument<Int?>("quality")
        val name = call.argument<String?>("name")
        val extension = call.argument<String>("extension")!!
        var bitmap: Bitmap? = null
        val fileUri: Uri?
        var fos: OutputStream? = null
        var success = false
        try {
            bitmap = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)
            fileUri = generateUri(context, extension, name = name)
            if (fileUri != null) {
                fos = context.contentResolver.openOutputStream(fileUri)
                fos?.let {
                    val format = Bitmap.CompressFormat.valueOf(extension)
                    bitmap.compress(format, quality ?: 100, it)
                    it.flush()
                    success = true
                }
            }
        } catch (e: Exception) {
            println("saveBytesImage exception : $e")
            return false
        } finally {
            fos?.close()
            bitmap?.recycle()
        }
        if (success) {
            sendBroadcast(context, fileUri)
        }
        return success
    }

    fun saveFilePath(context: Context, filePath: String, name: String?): Boolean {
        val fileUri: Uri?
        var outputStream: OutputStream? = null
        var fileInputStream: FileInputStream? = null
        var success = false
        try {
            val originalFile = File(filePath)
            if (!originalFile.exists()) return false
            fileUri = generateUri(context, originalFile.extension, name)
            if (fileUri != null) {
                outputStream = context.contentResolver?.openOutputStream(fileUri)
                if (outputStream != null) {
                    fileInputStream = FileInputStream(originalFile)
                    val buffer = ByteArray(10240)
                    var count: Int
                    while (fileInputStream.read(buffer).also { count = it } > 0) {
                        outputStream.write(buffer, 0, count)
                    }
                    outputStream.flush()
                    success = true
                }
            }
        } catch (e: Exception) {
            println("saveFilePath exception : $e")
            return false
        } finally {
            outputStream?.close()
            fileInputStream?.close()
        }
        if (success) {
            sendBroadcast(context, fileUri)
        }
        return success
    }
}
