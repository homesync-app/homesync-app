package androidx.media3.common.util;

import android.os.Looper;
import android.text.TextUtils;
import com.google.common.base.Preconditions;
import org.checkerframework.checker.nullness.qual.EnsuresNonNull;
import org.checkerframework.dataflow.qual.Pure;

/* JADX INFO: loaded from: classes.dex */
public final class Assertions {
    private Assertions() {
    }

    @Deprecated
    @Pure
    public static void checkArgument(boolean z) {
        Preconditions.checkArgument(z);
    }

    @Deprecated
    @Pure
    public static void checkArgument(boolean z, Object obj) {
        Preconditions.checkArgument(z, obj);
    }

    @Deprecated
    @Pure
    public static int checkIndex(int i, int i2, int i3) {
        if (i < i2 || i >= i3) {
            throw new IndexOutOfBoundsException();
        }
        return i;
    }

    @Deprecated
    @Pure
    public static void checkState(boolean z) {
        Preconditions.checkState(z);
    }

    @Deprecated
    @Pure
    public static void checkState(boolean z, Object obj) {
        Preconditions.checkState(z, obj);
    }

    @EnsuresNonNull({"#1"})
    @Deprecated
    @Pure
    public static <T> T checkStateNotNull(T t) {
        return (T) Preconditions.checkNotNull(t);
    }

    @EnsuresNonNull({"#1"})
    @Deprecated
    @Pure
    public static <T> T checkStateNotNull(T t, Object obj) {
        return (T) Preconditions.checkNotNull(t, obj);
    }

    @EnsuresNonNull({"#1"})
    @Deprecated
    @Pure
    public static <T> T checkNotNull(T t) {
        return (T) Preconditions.checkNotNull(t);
    }

    @EnsuresNonNull({"#1"})
    @Deprecated
    @Pure
    public static <T> T checkNotNull(T t, Object obj) {
        return (T) Preconditions.checkNotNull(t, obj);
    }

    @EnsuresNonNull({"#1"})
    @Deprecated
    @Pure
    public static String checkNotEmpty(String str) {
        Preconditions.checkArgument(!TextUtils.isEmpty(str));
        return str;
    }

    @EnsuresNonNull({"#1"})
    @Deprecated
    @Pure
    public static String checkNotEmpty(String str, Object obj) {
        Preconditions.checkArgument(!TextUtils.isEmpty(str), obj);
        return str;
    }

    @Deprecated
    @Pure
    public static void checkMainThread() {
        Preconditions.checkState(Looper.myLooper() == Looper.getMainLooper(), "Not in application's main thread");
    }
}
