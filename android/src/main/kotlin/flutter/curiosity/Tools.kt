package flutter.curiosityimport android.content.Contextimport android.content.pm.PackageManagerimport android.database.Cursorimport android.net.Uriimport android.os.Buildimport android.os.Bundleimport android.provider.MediaStoreimport androidx.core.content.ContextCompatimport io.flutter.Logimport java.io.Fileobject Tools {    fun extractBundle(headersMap: MutableMap<String, String>): Bundle {        val headersBundle = Bundle()        for (key in headersMap.keys) {            val value = headersMap[key]            headersBundle.putString(key, value)        }        return headersBundle    }    /**     * 判断设备是否root     *     * @return the boolean`true`: 是<br></br>`false`: 否     */    fun isDeviceRoot(): Boolean {        val su = "su"        val locations = arrayOf(            "/system/bin/", "/system/xbin/", "/sbin/", "/system/sd/xbin/", "/system/bin/failsafe/",            "/data/local/xbin/", "/data/local/bin/", "/data/local/"        )        for (location in locations) {            if (File(location + su).exists()) {                return true            }        }        return false    }    /**     * A simple emulator-detection based on the flutter tools detection logic and a couple of legacy     * detection systems     */    fun isEmulator(): Boolean {        return (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic")                || Build.FINGERPRINT.startsWith("generic")                || Build.FINGERPRINT.startsWith("unknown")                || Build.HARDWARE.contains("goldfish")                || Build.HARDWARE.contains("ranchu")                || Build.MODEL.contains("google_sdk")                || Build.MODEL.contains("Emulator")                || Build.MODEL.contains("Android SDK built for x86")                || Build.MANUFACTURER.contains("Genymotion")                || Build.PRODUCT.contains("sdk_google")                || Build.PRODUCT.contains("google_sdk")                || Build.PRODUCT.contains("sdk")                || Build.PRODUCT.contains("sdk_x86")                || Build.PRODUCT.contains("vbox86p")                || Build.PRODUCT.contains("emulator")                || Build.PRODUCT.contains("simulator"))    }    /**     * 打印日志     */    fun logInfo(content: String) {        Log.i("Curiosity--- ", content)    }    /**     * uri获取真实路径     */    fun getRealPathFromURI(contentURI: Uri?, context: Context): String? {        val result: String        val cursor: Cursor =            contentURI?.let { context.contentResolver.query(it, null, null, null, null) }!!        cursor.moveToFirst()        val idx: Int = cursor.getColumnIndex(MediaStore.Images.ImageColumns.DATA)        result = cursor.getString(idx)        cursor.close()        return result    }    /**     * 获取储存路径     */    fun getExternalDirectory(directory: String?, context: Context): String? {        return context.getExternalFilesDir(directory)?.absolutePath    }    /**     * 检测是否有权限     */    fun checkPermission(permission: String, context: Context): Boolean {        return ContextCompat.checkSelfPermission(context, permission) ==                PackageManager.PERMISSION_GRANTED    }    /**     * 是否有安装app 权限     */    fun canRequestPackageInstalls(context: Context): Boolean {        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {            context.packageManager.canRequestPackageInstalls()        } else {            true        }    }}