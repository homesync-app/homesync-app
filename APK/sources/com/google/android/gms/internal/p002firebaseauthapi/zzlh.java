package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzvh;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzlh {
    public static final zzxb zza;
    private static final byte[] zzb;

    @Deprecated
    private static zzxb zza(zzvw zzvwVar, zzvy zzvyVar, zzvb zzvbVar, zzxb zzxbVar, zzxz zzxzVar, byte[] bArr) {
        zzvh.zza zzaVarZza = zzvh.zza();
        zzvt zzvtVar = (zzvt) ((zzalf) zzvt.zza().zza(zzvwVar).zza(zzvyVar).zza(zzajv.zza(bArr)).zze());
        return (zzxb) ((zzalf) zzxb.zza().zza(zzjx.zza()).zza(zzxzVar).zza(((zzvh) ((zzalf) zzaVarZza.zza((zzvk) ((zzalf) zzvk.zzc().zza(zzvtVar).zza((zzve) ((zzalf) zzve.zza().zza(zzxbVar).zze())).zza(zzvbVar).zze())).zze())).zzj()).zze());
    }

    static {
        byte[] bArr = new byte[0];
        zzb = bArr;
        zza = zza(zzvw.NIST_P256, zzvy.SHA256, zzvb.UNCOMPRESSED, zzcv.zza, zzxz.TINK, bArr);
        zza(zzvw.NIST_P256, zzvy.SHA256, zzvb.COMPRESSED, zzcv.zza, zzxz.RAW, bArr);
        zza(zzvw.NIST_P256, zzvy.SHA256, zzvb.UNCOMPRESSED, zzcv.zzc, zzxz.TINK, bArr);
    }
}
