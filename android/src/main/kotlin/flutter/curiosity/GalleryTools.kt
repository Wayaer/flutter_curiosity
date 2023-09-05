package flutter.curiosity

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import java.io.File

object GalleryTools {

    fun getSystemGalleryIntent(): Intent {
        val intent = Intent(Intent.ACTION_PICK)
        intent.type = "image/*"
        return intent
    }

    fun getSystemCameraIntent(context: Context, activity: Activity, call: MethodCall): Intent {
        val arguments = call.arguments as MutableMap<*, *>
        var cameraSavePath = arguments["savePath"] as String?
        if (cameraSavePath == null) cameraSavePath =
            context.getExternalFilesDir(Environment.DIRECTORY_PICTURES)?.path.toString() + "/TEMP.JPG"
        val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
        val uri: Uri
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            //第二个参数为 包名.fierier
            uri = FileProvider.getUriForFile(
                activity, context.packageName.toString() + ".provider", File(cameraSavePath)
            )
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        } else uri = Uri.fromFile(File(cameraSavePath))
        intent.putExtra(MediaStore.EXTRA_OUTPUT, uri)
        return intent
    }


}