package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zziv;
import com.google.android.gms.internal.p002firebaseauthapi.zzqu;
import com.google.android.gms.internal.p002firebaseauthapi.zzwx;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.HashMap;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzqq {
    private static final zzor<zzqu> zza = new zzor() { // from class: com.google.android.gms.internal.firebase-auth-api.zzqt
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzor
        public final zzbi zza(zzcb zzcbVar, Integer num) {
            return zzqq.zza((zzqu) zzcbVar, num);
        }
    };
    private static final zzps<zzqp, zzqw> zzb = zzps.zza(new zzpu() { // from class: com.google.android.gms.internal.firebase-auth-api.zzqs
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzpu
        public final Object zza(zzbi zzbiVar) {
            return zzqq.zzb((zzqp) zzbiVar);
        }
    }, zzqp.class, zzqw.class);
    private static final zzps<zzqp, zzcc> zzc = zzps.zza(new zzpu() { // from class: com.google.android.gms.internal.firebase-auth-api.zzqv
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzpu
        public final Object zza(zzbi zzbiVar) {
            return zzqq.zza((zzqp) zzbiVar);
        }
    }, zzqp.class, zzcc.class);
    private static final zzbh<zzcc> zzd = zzod.zza("type.googleapis.com/google.crypto.tink.AesCmacKey", zzcc.class, zzwx.zzb.SYMMETRIC, zzsw.zzf());

    public static /* synthetic */ zzcc zza(zzqp zzqpVar) throws GeneralSecurityException {
        zza((zzqu) ((zzrn) zzqpVar.zza()));
        return zzaag.zza(zzqpVar);
    }

    public static /* synthetic */ zzqp zza(zzqu zzquVar, Integer num) throws GeneralSecurityException {
        zza(zzquVar);
        return zzqp.zzc().zza(zzquVar).zza(zzaal.zza(zzquVar.zzc())).zza(num).zza();
    }

    public static /* synthetic */ zzqw zzb(zzqp zzqpVar) throws GeneralSecurityException {
        zza((zzqu) ((zzrn) zzqpVar.zza()));
        return zzsh.zza(zzqpVar);
    }

    public static void zza(boolean z) throws GeneralSecurityException {
        if (!zziv.zza.zza.zza()) {
            throw new GeneralSecurityException("Registering AES CMAC is not supported in FIPS mode");
        }
        zzrz.zza();
        zzop.zza().zza(zza, zzqu.class);
        zzpa.zza().zza(zzb);
        zzpa.zza().zza(zzc);
        zzox zzoxVarZza = zzox.zza();
        HashMap map = new HashMap();
        map.put("AES_CMAC", zzrt.zzc);
        map.put("AES256_CMAC", zzrt.zzc);
        map.put("AES256_CMAC_RAW", zzqu.zzd().zza(32).zzb(16).zza(zzqu.zza.zzd).zza());
        zzoxVarZza.zza(Collections.unmodifiableMap(map));
        zznq.zza().zza((zzbh) zzd, true);
    }

    private static void zza(zzqu zzquVar) throws GeneralSecurityException {
        if (zzquVar.zzc() != 32) {
            throw new GeneralSecurityException("AesCmacKey size wrong, must be 32 bytes");
        }
    }
}
