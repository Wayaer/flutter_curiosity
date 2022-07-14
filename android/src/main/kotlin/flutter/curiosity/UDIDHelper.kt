package flutter.curiosity

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import android.provider.Settings
import android.telephony.TelephonyManager
import android.text.TextUtils
import java.util.*


@SuppressLint("StaticFieldLeak")
object UDIDHelper {

    private var uuid: String? = null

    // 生成一个唯一id
    fun generateUniqueDeviceId(): String {
        var serial: String?
        val serialId =
            "35" + Build.BOARD.length % 10 + Build.BRAND.length % 10 + Build.CPU_ABI.length % 10 + Build.DEVICE.length % 10 + Build.DISPLAY.length % 10 + Build.HOST.length % 10 + Build.ID.length % 10 + Build.MANUFACTURER.length % 10 + Build.MODEL.length % 10 + Build.PRODUCT.length % 10 + Build.TAGS.length % 10 + Build.TYPE.length % 10 + Build.USER.length % 10
        try {
            serial = Build::class.java.getField("SERIAL")[null]?.toString()
            //API>=9 使用serial号
            return UUID(serialId.hashCode().toLong(), serial.hashCode().toLong()).toString()
        } catch (exception: java.lang.Exception) {
            serial = "serial" // 随便一个初始化
        }
        return UUID(serialId.hashCode().toLong(), serial.hashCode().toLong()).toString()
    }

    // 获取设备唯一id
    fun getUniqueDeviceId(context: Context): String? {
        if (!TextUtils.isEmpty(uuid)) {
            return uuid
        }
        try {
            // 为空再获取AndroidId
            if (TextUtils.isEmpty(uuid)) {
                uuid = getAndroidID(context)
            }

            // 为空再获取imei
            if (TextUtils.isEmpty(uuid)) {
                uuid = getDeviceId(context)
            }
        } catch (ignore: Exception) {
        }
        // 都为空，创建1个新的UUID
        if (TextUtils.isEmpty(uuid)) {
            uuid = newUUID
        }
        return uuid
    }


    /**
     * 获取AndroidId
     */
    @SuppressLint("HardwareIds")
    private fun getAndroidID(context: Context): String? {
        val id = Settings.Secure.getString(
            context.contentResolver, Settings.Secure.ANDROID_ID
        )
        return if ("9774d56d682e549c" == id) {
            null
        } else {
            id
        }
    }

    /**
     * 获取DeviceId
     */
    private fun getDeviceId(context: Context): String? {
        val tm =
            context.applicationContext.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        return tm.deviceId
    }

    /**
     * 获得1个新的UUID
     */
    private val newUUID: String
        get() = UUID.randomUUID().toString()


}