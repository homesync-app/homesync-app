package com.google.firebase.crashlytics;

import com.google.firebase.crashlytics.internal.Logger;
import java.util.Iterator;
import java.util.List;

/* JADX INFO: loaded from: classes3.dex */
public final class FlutterFirebaseCrashlyticsInternal {
    private static final String FLUTTER_BUILD_ID_DEFAULT_KEY = "com.crashlytics.flutter.build-id.0";
    private static final String LOADING_UNIT_KEY = "com.crashlytics.flutter.build-id.";

    public static void recordFatalException(Throwable th) {
        if (th == null) {
            Logger.getLogger().w("A null value was passed to recordFatalException. Ignoring.");
        } else {
            FirebaseCrashlytics.getInstance().core.logFatalException(th);
        }
    }

    public static void setFlutterBuildId(String str) {
        FirebaseCrashlytics.getInstance().core.setInternalKey(FLUTTER_BUILD_ID_DEFAULT_KEY, str);
    }

    public static void setLoadingUnits(List<String> list) {
        Iterator<String> it = list.iterator();
        int i = 0;
        while (it.hasNext()) {
            i++;
            FirebaseCrashlytics.getInstance().core.setInternalKey(LOADING_UNIT_KEY + i, it.next());
        }
    }

    private FlutterFirebaseCrashlyticsInternal() {
    }
}
