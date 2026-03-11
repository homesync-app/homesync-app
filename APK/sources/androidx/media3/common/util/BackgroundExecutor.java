package androidx.media3.common.util;

import java.util.concurrent.Executor;

/* JADX INFO: loaded from: classes.dex */
public final class BackgroundExecutor {
    private static Executor staticInstance;

    public static synchronized Executor get() {
        if (staticInstance == null) {
            staticInstance = Util.newSingleThreadExecutor("ExoPlayer:BackgroundExecutor");
        }
        return staticInstance;
    }

    public static synchronized void set(Executor executor) {
        staticInstance = executor;
    }

    private BackgroundExecutor() {
    }
}
