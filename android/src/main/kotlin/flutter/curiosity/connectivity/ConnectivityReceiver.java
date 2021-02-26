
package flutter.curiosity.connectivity;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.Network;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;

import org.jetbrains.annotations.NotNull;

import io.flutter.plugin.common.EventChannel;


public class ConnectivityReceiver extends BroadcastReceiver
        implements EventChannel.StreamHandler {
    private final Context context;
    private final Connectivity connectivity;
    private EventChannel.EventSink events;
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private ConnectivityManager.NetworkCallback networkCallback;
    public static final String CONNECTIVITY_ACTION = "android.net.conn.CONNECTIVITY_CHANGE";

    public ConnectivityReceiver(Context context, Connectivity connectivity) {
        this.context = context;
        this.connectivity = connectivity;
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        this.events = events;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            networkCallback =
                    new ConnectivityManager.NetworkCallback() {
                        @Override
                        public void onAvailable(@NotNull Network network) {
                            sendEvent();
                        }

                        @Override
                        public void onLost(@NotNull Network network) {
                            sendEvent();
                        }
                    };
            connectivity.getConnectivity().registerDefaultNetworkCallback(networkCallback);
        } else {
            context.registerReceiver(this, new IntentFilter(CONNECTIVITY_ACTION));
        }
    }

    @Override
    public void onCancel(Object arguments) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            if (networkCallback != null) {
                connectivity.getConnectivity().unregisterNetworkCallback(networkCallback);
            }
        } else {
            context.unregisterReceiver(this);
        }
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        if (events != null) {
            events.success(connectivity.getNetworkType());
        }
    }


    private void sendEvent() {
        mainHandler.post(() -> events.success(connectivity.getNetworkType()));
    }
}
