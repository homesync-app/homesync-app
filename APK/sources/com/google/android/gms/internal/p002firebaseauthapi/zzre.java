package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zziv;
import com.google.android.gms.internal.p002firebaseauthapi.zzrh;
import com.google.android.gms.internal.p002firebaseauthapi.zzwx;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.HashMap;
import javax.annotation.Nullable;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzre {
    private static final zzps<zzra, zzqw> zza = zzps.zza(new zzpu() { // from class: com.google.android.gms.internal.firebase-auth-api.zzrd
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzpu
        public final Object zza(zzbi zzbiVar) {
            return new zzsg((zzra) zzbiVar);
        }
    }, zzra.class, zzqw.class);
    private static final zzps<zzra, zzcc> zzb = zzps.zza(new zzpu() { // from class: com.google.android.gms.internal.firebase-auth-api.zzrg
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzpu
        public final Object zza(zzbi zzbiVar) {
            return zzaag.zza((zzra) zzbiVar);
        }
    }, zzra.class, zzcc.class);
    private static final zzbh<zzcc> zzc = zzod.zza("type.googleapis.com/google.crypto.tink.HmacKey", zzcc.class, zzwx.zzb.SYMMETRIC, zzwb.zzg());
    private static final zzot<zzrh> zzd = new zzot() { // from class: com.google.android.gms.internal.firebase-auth-api.zzrf
    };
    private static final zzor<zzrh> zze = new zzor() { // from class: com.google.android.gms.internal.firebase-auth-api.zzri
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzor
        public final zzbi zza(zzcb zzcbVar, Integer num) {
            return zzre.zza((zzrh) zzcbVar, num);
        }
    };
    private static final zziv.zza zzf = zziv.zza.zzb;

    static zzra zza(zzrh zzrhVar, @Nullable Integer num) throws GeneralSecurityException {
        return zzra.zzc().zza(zzrhVar).zza(zzaal.zza(zzrhVar.zzc())).zza(num).zza();
    }

    public static void zza(boolean z) throws GeneralSecurityException {
        zziv.zza zzaVar = zzf;
        if (!zzaVar.zza()) {
            throw new GeneralSecurityException("Can not use HMAC in FIPS-mode, as BoringCrypto module is not available.");
        }
        zzsj.zza();
        zzpa.zza().zza(zza);
        zzpa.zza().zza(zzb);
        zzox zzoxVarZza = zzox.zza();
        HashMap map = new HashMap();
        map.put("HMAC_SHA256_128BITTAG", zzrt.zza);
        map.put("HMAC_SHA256_128BITTAG_RAW", zzrh.zzd().zza(32).zzb(16).zza(zzrh.zzc.zzd).zza(zzrh.zza.zzc).zza());
        map.put("HMAC_SHA256_256BITTAG", zzrh.zzd().zza(32).zzb(32).zza(zzrh.zzc.zza).zza(zzrh.zza.zzc).zza());
        map.put("HMAC_SHA256_256BITTAG_RAW", zzrh.zzd().zza(32).zzb(32).zza(zzrh.zzc.zzd).zza(zzrh.zza.zzc).zza());
        map.put("HMAC_SHA512_128BITTAG", zzrh.zzd().zza(64).zzb(16).zza(zzrh.zzc.zza).zza(zzrh.zza.zze).zza());
        map.put("HMAC_SHA512_128BITTAG_RAW", zzrh.zzd().zza(64).zzb(16).zza(zzrh.zzc.zzd).zza(zzrh.zza.zze).zza());
        map.put("HMAC_SHA512_256BITTAG", zzrh.zzd().zza(64).zzb(32).zza(zzrh.zzc.zza).zza(zzrh.zza.zze).zza());
        map.put("HMAC_SHA512_256BITTAG_RAW", zzrh.zzd().zza(64).zzb(32).zza(zzrh.zzc.zzd).zza(zzrh.zza.zze).zza());
        map.put("HMAC_SHA512_512BITTAG", zzrt.zzb);
        map.put("HMAC_SHA512_512BITTAG_RAW", zzrh.zzd().zza(64).zzb(64).zza(zzrh.zzc.zzd).zza(zzrh.zza.zze).zza());
        zzoxVarZza.zza(Collections.unmodifiableMap(map));
        zzop.zza().zza(zze, zzrh.class);
        zzou.zza().zza(zzd, zzrh.class);
        zznq.zza().zza((zzbh) zzc, zzaVar, true);
    }
}
