package com.google.firebase.crashlytics;

import androidx.media3.container.NalUnitUtil;
import com.google.firebase.crashlytics.CustomKeysAndValues;
import io.flutter.plugins.firebase.crashlytics.Constants;
import kotlin.Metadata;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: KeyValueBuilder.kt */
/* JADX INFO: loaded from: classes3.dex */
@Metadata(d1 = {"\u0000:\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0004\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0010\u0002\n\u0002\u0010\u000e\n\u0000\n\u0002\u0010\u000b\n\u0002\u0010\u0006\n\u0002\u0010\u0007\n\u0002\u0010\b\n\u0002\u0010\t\n\u0000\u0018\u00002\u00020\u0001B\u0011\b\u0002\u0012\u0006\u0010\u0002\u001a\u00020\u0003¢\u0006\u0004\b\u0004\u0010\u0005B\t\b\u0010¢\u0006\u0004\b\u0004\u0010\u0006J\r\u0010\u0007\u001a\u00020\bH\u0000¢\u0006\u0002\b\tJ\u0016\u0010\n\u001a\u00020\u000b2\u0006\u0010\n\u001a\u00020\f2\u0006\u0010\r\u001a\u00020\u000eJ\u0016\u0010\n\u001a\u00020\u000b2\u0006\u0010\n\u001a\u00020\f2\u0006\u0010\r\u001a\u00020\u000fJ\u0016\u0010\n\u001a\u00020\u000b2\u0006\u0010\n\u001a\u00020\f2\u0006\u0010\r\u001a\u00020\u0010J\u0016\u0010\n\u001a\u00020\u000b2\u0006\u0010\n\u001a\u00020\f2\u0006\u0010\r\u001a\u00020\u0011J\u0016\u0010\n\u001a\u00020\u000b2\u0006\u0010\n\u001a\u00020\f2\u0006\u0010\r\u001a\u00020\u0012J\u0016\u0010\n\u001a\u00020\u000b2\u0006\u0010\n\u001a\u00020\f2\u0006\u0010\r\u001a\u00020\fR\u000e\u0010\u0002\u001a\u00020\u0003X\u0082\u0004¢\u0006\u0002\n\u0000¨\u0006\u0013"}, d2 = {"Lcom/google/firebase/crashlytics/KeyValueBuilder;", "", "builder", "Lcom/google/firebase/crashlytics/CustomKeysAndValues$Builder;", "<init>", "(Lcom/google/firebase/crashlytics/CustomKeysAndValues$Builder;)V", "()V", "build", "Lcom/google/firebase/crashlytics/CustomKeysAndValues;", "build$com_google_firebase_firebase_crashlytics", Constants.KEY, "", "", "value", "", "", "", "", "", "com.google.firebase-firebase-crashlytics"}, k = 1, mv = {2, 0, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final class KeyValueBuilder {
    private final CustomKeysAndValues.Builder builder;

    private KeyValueBuilder(CustomKeysAndValues.Builder builder) {
        this.builder = builder;
    }

    public KeyValueBuilder() {
        this(new CustomKeysAndValues.Builder());
    }

    public final CustomKeysAndValues build$com_google_firebase_firebase_crashlytics() {
        CustomKeysAndValues customKeysAndValuesBuild = this.builder.build();
        Intrinsics.checkNotNullExpressionValue(customKeysAndValuesBuild, "build(...)");
        return customKeysAndValuesBuild;
    }

    public final void key(String key, boolean value) {
        Intrinsics.checkNotNullParameter(key, "key");
        this.builder.putBoolean(key, value);
    }

    public final void key(String key, double value) {
        Intrinsics.checkNotNullParameter(key, "key");
        this.builder.putDouble(key, value);
    }

    public final void key(String key, float value) {
        Intrinsics.checkNotNullParameter(key, "key");
        this.builder.putFloat(key, value);
    }

    public final void key(String key, int value) {
        Intrinsics.checkNotNullParameter(key, "key");
        this.builder.putInt(key, value);
    }

    public final void key(String key, long value) {
        Intrinsics.checkNotNullParameter(key, "key");
        this.builder.putLong(key, value);
    }

    public final void key(String key, String value) {
        Intrinsics.checkNotNullParameter(key, "key");
        Intrinsics.checkNotNullParameter(value, "value");
        this.builder.putString(key, value);
    }
}
