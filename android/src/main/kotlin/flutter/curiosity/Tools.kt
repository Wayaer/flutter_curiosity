package flutter.curiosityimport android.app.Activityimport android.app.ActivityManagerimport android.content.Contextimport android.content.Intentimport android.content.pm.ApplicationInfoimport android.content.pm.PackageInfoimport android.database.Cursorimport android.location.LocationManagerimport android.net.Uriimport android.os.Buildimport android.os.Processimport android.provider.MediaStoreimport androidx.collection.ArrayMapimport androidx.core.content.FileProviderimport io.flutter.plugin.common.MethodCallimport java.io.Fileimport kotlin.system.exitProcessobject Tools {    /**     * 获取app 信息     */    fun getPackageInfo(context: Context): Map<String, Any?> {        val pm = context.packageManager        val info = context.packageManager.getPackageInfo(context.packageName, 0)        return mapOf<String, Any?>(            "sdkVersion" to Build.VERSION.SDK_INT,            "buildNumber" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) info.longVersionCode.toString() else info.versionCode.toString(),            "appName" to info.applicationInfo.loadLabel(pm).toString(),            "packageName" to info.packageName,            "version" to info.versionName,            "firstInstallTime" to info.firstInstallTime,            "lastUpdateTime" to info.lastUpdateTime,        )    }    /**     * 获取应用列表     */    fun getInstalledApps(context: Context): ArrayList<MutableMap<String, Any>> {        val list: ArrayList<MutableMap<String, Any>> = ArrayList()        val pm = context.packageManager        val packages: MutableList<PackageInfo> = pm.getInstalledPackages(0) // 获取所有已安装程序的包信息        for (packageInfo in packages) {            val info: MutableMap<String, Any> = ArrayMap()            info["isSystemApp"] =                (packageInfo.applicationInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0            info["version"] = packageInfo.versionName            info["appName"] = packageInfo.applicationInfo.loadLabel(pm)            info["packageName"] = packageInfo.packageName            info["buildNumber"] =                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) packageInfo.longVersionCode.toString() else packageInfo.versionCode.toString()            info["lastUpdateTime"] = packageInfo.lastUpdateTime            list.add(info)        }        return list    }    /**     * 退出app     */    fun exitApp(activity: Activity) {        //杀死进程，否则就算退出App，App处于空进程并未销毁，再次打开也不会初始化Application        val manager = activity.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager        manager.runningAppProcesses.forEach { processInfo ->            if (processInfo.pid != Process.myPid()) {                Process.killProcess(processInfo.pid)            }        }        exitProcess(0)    }    /**     * 判断GPS是否开启，GPS或者AGPS开启一个就认为是开启的     * @return true 表示开启     */    fun getGPSStatus(context: Context): Boolean {        val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager        // 通过GPS卫星定位，定位级别可以精确到街（通过24颗卫星定位，在室外和空旷的地方定位准确、速度快）        val gps: Boolean = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)        // 通过WLAN或移动网络(3G/2G)确定的位置（也称作AGPS，辅助GPS定位。主要用于在室内或遮盖物（建筑群或茂密的深林等）密集的地方定位）        val network: Boolean = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)        return gps || network    }    /**     * 安装apk     */    fun getInstallAppIntent(context: Context, call: MethodCall): Intent? {        //安装        val apkPath = call.arguments as String        val file = File(apkPath)        if (!file.exists()) {            return null        }        val intent = Intent(Intent.ACTION_VIEW)        //版本在7.0以上是不能直接通过uri访问的        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {            //参数1 上下文, 参数2 Provider主机地址 和配置文件中保持一致   参数3  共享的文件            val apkUri = FileProvider.getUriForFile(                context, context.packageName + ".provider", file            )            //添加这一句表示对目标应用临时授权该Uri所代表的文件            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)            intent.setDataAndType(                apkUri, "application/vnd.android.package-archive"            )        } else {            intent.setDataAndType(                Uri.fromFile(file), "application/vnd.android.package-archive"            )        }        return intent    }}