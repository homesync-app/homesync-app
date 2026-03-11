package com.google.android.recaptcha.internal;

import kotlin.jvm.functions.Function0;
import kotlin.jvm.internal.Lambda;

/* JADX INFO: compiled from: com.google.android.recaptcha:recaptcha@@18.6.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzdp extends Lambda implements Function0 {
    public static final zzdp zza = new zzdp();

    public zzdp() {
        super(0);
    }

    @Override // kotlin.jvm.functions.Function0
    public final Object invoke() throws zzbd {
        int i = zzav.zza;
        Object objZzb = zzau.zza().zzb("com.google.android.recaptcha.internal.zzfj".hashCode());
        if (objZzb != null) {
            return (zzfj) objZzb;
        }
        throw new zzbd(zzbb.zzb, zzba.zzax, null);
    }
}
