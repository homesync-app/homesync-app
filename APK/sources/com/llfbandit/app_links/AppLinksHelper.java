package com.llfbandit.app_links;

import android.content.Intent;
import android.util.Log;

/* JADX INFO: loaded from: classes3.dex */
public class AppLinksHelper {
    private static final String TAG = "com.llfbandit.app_links";

    public static String getUrl(Intent intent) {
        String action = intent.getAction();
        if ("android.intent.action.SEND".equals(action) || "android.intent.action.SEND_MULTIPLE".equals(action) || "android.intent.action.SENDTO".equals(action)) {
            return null;
        }
        String dataString = intent.getDataString();
        if (dataString != null) {
            Log.d(TAG, "Handled intent: action: " + action + " / data: " + dataString);
        }
        return dataString;
    }
}
