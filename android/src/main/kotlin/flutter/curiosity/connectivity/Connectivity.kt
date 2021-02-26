package flutter.curiosity.connectivity

import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build

class Connectivity(val connectivity: ConnectivityManager) {
    val networkType: String
        get() {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val network = connectivity.activeNetwork
                val capabilities = connectivity.getNetworkCapabilities(network)
                        ?: return "none"
                if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
                        || capabilities.hasTransport(NetworkCapabilities.TRANSPORT_ETHERNET)) {
                    return "wifi"
                }
                if (capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)) {
                    return "mobile"
                }
            }
            return networkTypeLegacy
        }

    // handle type for Android versions less than Android 9
    private val networkTypeLegacy: String
        get() {
            val info = connectivity.activeNetworkInfo
            if (info == null || !info.isConnected) {
                return "none"
            }
            return when (info.type) {
                ConnectivityManager.TYPE_ETHERNET, ConnectivityManager.TYPE_WIFI, ConnectivityManager.TYPE_WIMAX -> "wifi"
                ConnectivityManager.TYPE_MOBILE, ConnectivityManager.TYPE_MOBILE_DUN, ConnectivityManager.TYPE_MOBILE_HIPRI -> "mobile"
                else -> "none"
            }
        }
}