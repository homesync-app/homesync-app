package com.google.android.gms.internal.p002firebaseauthapi;

import javax.annotation.Nullable;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzbq {
    private boolean zza;
    private zzbk zzb;

    @Nullable
    private final zzcb zzc;
    private zzbp zzd;

    @Nullable
    private zzbn zze;

    public final zzbq zza() {
        zzbn zzbnVar = this.zze;
        if (zzbnVar != null) {
            zzbnVar.zzb();
        }
        this.zza = true;
        return this;
    }

    public final zzbq zzb() {
        this.zzd = zzbp.zza;
        return this;
    }

    private zzbq(zzcb zzcbVar) {
        this.zzb = zzbk.zza;
        this.zzd = null;
        this.zze = null;
        this.zzc = zzcbVar;
    }
}
