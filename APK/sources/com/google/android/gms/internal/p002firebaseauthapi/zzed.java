package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzeg;
import com.google.android.gms.internal.p002firebaseauthapi.zziv;
import com.google.android.gms.internal.p002firebaseauthapi.zzwx;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.HashMap;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzed {
    private static final zzps<zzdz, zzba> zza = zzps.zza(new zzpu() { // from class: com.google.android.gms.internal.firebase-auth-api.zzec
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzpu
        public final Object zza(zzbi zzbiVar) {
            return zzip.zza((zzdz) zzbiVar);
        }
    }, zzdz.class, zzba.class);
    private static final zzor<zzeg> zzb = new zzor() { // from class: com.google.android.gms.internal.firebase-auth-api.zzef
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzor
        public final zzbi zza(zzcb zzcbVar, Integer num) {
            zzeg zzegVar = (zzeg) zzcbVar;
            return zzdz.zze().zza(zzegVar).zza(num).zza(zzaal.zza(zzegVar.zzb())).zza();
        }
    };
    private static final zzot<zzeg> zzc = new zzot() { // from class: com.google.android.gms.internal.firebase-auth-api.zzee
    };
    private static final zzbh<zzba> zzd = zzod.zza("type.googleapis.com/google.crypto.tink.AesGcmSivKey", zzba.class, zzwx.zzb.SYMMETRIC, zzuj.zze());

    public static void zza(boolean z) throws GeneralSecurityException {
        if (!zziv.zza.zza.zza()) {
            throw new GeneralSecurityException("Registering AES GCM SIV is not supported in FIPS mode");
        }
        zzhb.zza();
        zzox zzoxVarZza = zzox.zza();
        HashMap map = new HashMap();
        map.put("AES128_GCM_SIV", zzeg.zzc().zza(16).zza(zzeg.zzb.zza).zza());
        map.put("AES128_GCM_SIV_RAW", zzeg.zzc().zza(16).zza(zzeg.zzb.zzc).zza());
        map.put("AES256_GCM_SIV", zzeg.zzc().zza(32).zza(zzeg.zzb.zza).zza());
        map.put("AES256_GCM_SIV_RAW", zzeg.zzc().zza(32).zza(zzeg.zzb.zzc).zza());
        zzoxVarZza.zza(Collections.unmodifiableMap(map));
        zzou.zza().zza(zzc, zzeg.class);
        zzop.zza().zza(zzb, zzeg.class);
        zzpa.zza().zza(zza);
        zznq.zza().zza((zzbh) zzd, true);
    }
}
