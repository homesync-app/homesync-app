package io.flutter.plugins.firebase.messaging;

import android.content.Context;
import android.util.Log;

/* JADX INFO: loaded from: classes3.dex */
public class ContextHolder {
    private static Context applicationContext;

    public static Context getApplicationContext() {
        return applicationContext;
    }

    public static void setApplicationContext(Context context) {
        Log.d("FLTFireContextHolder", "received application context.");
        applicationContext = context;
    }
}
