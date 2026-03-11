package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzbs implements zzoa {
    private static final zzbu zza = new zzbu() { // from class: com.google.android.gms.internal.firebase-auth-api.zzbr
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbu
        public final void zza(zzbs zzbsVar) {
            zzbs.zzd(zzbsVar);
        }
    };
    private final zzbi zzb;
    private final zzxc zzc;
    private final zzbk zzd;
    private final int zze;
    private final boolean zzf;
    private final boolean zzg;
    private final zzbu zzh;

    static /* synthetic */ void zzd(zzbs zzbsVar) {
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzoa
    public final int zza() {
        return this.zze;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzoa
    public final zzbi zzb() {
        this.zzh.zza(this);
        return this.zzb;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzoa
    public final zzbk zzc() {
        return this.zzd;
    }

    private zzbs(zzbi zzbiVar, zzxc zzxcVar, int i, boolean z, boolean z2, zzbu zzbuVar) {
        zzbk zzbkVar;
        this.zzb = zzbiVar;
        this.zzc = zzxcVar;
        int i2 = zzbo.zza[zzxcVar.ordinal()];
        if (i2 == 1) {
            zzbkVar = zzbk.zza;
        } else if (i2 == 2) {
            zzbkVar = zzbk.zzc;
        } else {
            zzbkVar = zzbk.zzb;
        }
        this.zzd = zzbkVar;
        this.zze = i;
        this.zzf = z;
        this.zzg = z2;
        this.zzh = zzbuVar;
    }

    public final boolean zze() {
        return this.zzf;
    }
}
