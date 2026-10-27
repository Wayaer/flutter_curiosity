package flutter.curiosity

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.location.LocationManager
import android.net.Uri
import android.os.Build
import android.os.Process
import androidx.core.content.FileProvider
import java.io.File
import kotlin.system.exitProcess

object Tools {

    fun PackageInfo.map(pm: PackageManager): Map<String, Any?> {
        val flags = applicationInfo?.flags ?: 0
        return mapOf(
            "isSystemApp" to ((flags and ApplicationInfo.FLAG_SYSTEM) != 0),
            "buildNumber" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                longVersionCode.toString()
            } else {
                versionCode.toString()
            },
            "appName" to (applicationInfo?.loadLabel(pm)?.toString() ?: packageName),
            "packageName" to packageName,
            "version" to versionName,
            "lastUpdateTime" to lastUpdateTime,
            "firstInstallTime" to firstInstallTime,
        )
    }

    /**
     * Returns the apps installed on the device.
     */
    fun getInstalledApps(context: Context): ArrayList<Map<String, Any?>> {
        val list = ArrayList<Map<String, Any?>>()
        val pm = context.packageManager
        val packages = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getInstalledPackages(PackageManager.PackageInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            pm.getInstalledPackages(0)
        }
        for (info in packages) {
            list.add(info.map(pm))
        }
        return list
    }

    /**
     * Exits the app and kills its background processes.
     */
    fun exitApp(activity: Activity) {
        // Kill the processes, otherwise the app is still alive in an empty process.
        val manager = activity.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        manager.runningAppProcesses?.forEach { processInfo ->
            if (processInfo.pid != Process.myPid()) {
                Process.killProcess(processInfo.pid)
            }
        }
        activity.finishAffinity()
        exitProcess(0)
    }

    /**
     * Whether GPS or AGPS is enabled.
     */
    fun getGPSStatus(context: Context): Boolean {
        val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val gps = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
        val network = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
        return gps || network
    }

    /**
     * Returns the intent used to install the APK located at [apkPath].
     */
    fun getInstallAppIntent(context: Context, apkPath: String): Intent? {
        val file = File(apkPath)
        if (!file.exists()) return null
        return try {
            val intent = Intent(Intent.ACTION_VIEW)
            val uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                // The provider authority must match the one declared in AndroidManifest.xml.
                intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                FileProvider.getUriForFile(context, "${context.packageName}.provider", file)
            } else {
                Uri.fromFile(file)
            }
            intent.setDataAndType(uri, "application/vnd.android.package-archive")
            intent
        } catch (e: Exception) {
            println(e)
            null
        }
    }
}
