package com.google.android.gms.common.wrappers;

import android.content.Context;

/* JADX INFO: compiled from: com.google.android.gms:play-services-basement@@18.8.0 */
/* JADX INFO: loaded from: classes3.dex */
public class Wrappers {
    private static final Wrappers zzb = new Wrappers();
    private PackageManagerWrapper zza = null;

    public static PackageManagerWrapper packageManager(Context context) {
        return zzb.zza(context);
    }

    public final synchronized PackageManagerWrapper zza(Context context) {
        if (this.zza == null) {
            if (context.getApplicationContext() != null) {
                context = context.getApplicationContext();
            }
            this.zza = new PackageManagerWrapper(context);
        }
        return this.zza;
    }
}
