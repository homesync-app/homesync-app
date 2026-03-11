package com.google.android.gms.common.util;

import android.os.StrictMode;

/* JADX INFO: compiled from: com.google.android.gms:play-services-basement@@18.8.0 */
/* JADX INFO: loaded from: classes3.dex */
final class zzc {
    static StrictMode.VmPolicy.Builder zza(StrictMode.VmPolicy.Builder builder) {
        return builder.permitUnsafeIntentLaunch();
    }
}
