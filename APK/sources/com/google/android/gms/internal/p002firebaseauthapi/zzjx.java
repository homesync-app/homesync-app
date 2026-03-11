package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzdi;
import com.google.android.gms.internal.p002firebaseauthapi.zzdx;
import com.google.android.gms.internal.p002firebaseauthapi.zziv;
import com.google.android.gms.internal.p002firebaseauthapi.zzkb;
import com.google.android.gms.internal.p002firebaseauthapi.zzwx;
import java.security.GeneralSecurityException;
import java.security.KeyPair;
import java.security.interfaces.ECPrivateKey;
import java.security.interfaces.ECPublicKey;
import java.security.spec.ECParameterSpec;
import java.util.Collections;
import java.util.HashMap;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzjx {
    private static final zzps<zzke, zzbd> zza = zzps.zza(new zzpu() { // from class: com.google.android.gms.internal.firebase-auth-api.zzka
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzpu
        public final Object zza(zzbi zzbiVar) {
            return zzzb.zza((zzke) zzbiVar);
        }
    }, zzke.class, zzbd.class);
    private static final zzps<zzkh, zzbg> zzb = zzps.zza(new zzpu() { // from class: com.google.android.gms.internal.firebase-auth-api.zzjz
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzpu
        public final Object zza(zzbi zzbiVar) {
            return zzze.zza((zzkh) zzbiVar);
        }
    }, zzkh.class, zzbg.class);
    private static final zzcd<zzbd> zzc = zzod.zza("type.googleapis.com/google.crypto.tink.EciesAeadHkdfPrivateKey", zzbd.class, zzvn.zzf());
    private static final zzbh<zzbg> zzd = zzod.zza("type.googleapis.com/google.crypto.tink.EciesAeadHkdfPublicKey", zzbg.class, zzwx.zzb.ASYMMETRIC_PUBLIC, zzvq.zzh());
    private static final zzor<zzkb> zze = new zzor() { // from class: com.google.android.gms.internal.firebase-auth-api.zzkc
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzor
        public final zzbi zza(zzcb zzcbVar, Integer num) {
            return zzjx.zza((zzkb) zzcbVar, num);
        }
    };

    public static /* synthetic */ zzke zza(zzkb zzkbVar, Integer num) throws GeneralSecurityException {
        ECParameterSpec eCParameterSpec;
        zzkb.zzc zzcVarZzd = zzkbVar.zzd();
        if (zzcVarZzd == zzkb.zzc.zza) {
            eCParameterSpec = zznj.zza;
        } else if (zzcVarZzd == zzkb.zzc.zzb) {
            eCParameterSpec = zznj.zzb;
        } else {
            if (zzcVarZzd != zzkb.zzc.zzc) {
                throw new GeneralSecurityException("Unsupported curve type: " + String.valueOf(zzcVarZzd));
            }
            eCParameterSpec = zznj.zzc;
        }
        KeyPair keyPairZza = zzzf.zza(eCParameterSpec);
        return zzke.zza(zzkh.zza(zzkbVar, ((ECPublicKey) keyPairZza.getPublic()).getW(), num), zzaam.zza(((ECPrivateKey) keyPairZza.getPrivate()).getS(), zzbf.zza()));
    }

    static String zza() {
        return "type.googleapis.com/google.crypto.tink.EciesAeadHkdfPrivateKey";
    }

    public static void zza(boolean z) throws GeneralSecurityException {
        if (!zziv.zza.zza.zza()) {
            throw new GeneralSecurityException("Registering ECIES Hybrid Encryption is not supported in FIPS mode");
        }
        zzlq.zza();
        zzox zzoxVarZza = zzox.zza();
        HashMap map = new HashMap();
        map.put("ECIES_P256_HKDF_HMAC_SHA256_AES128_GCM", zzkb.zzc().zza(zzkb.zzc.zza).zza(zzkb.zzb.zzc).zza(zzkb.zze.zzb).zza(zzkb.zzd.zza).zza(zzdx.zze().zza(12).zzb(16).zzc(16).zza(zzdx.zza.zzc).zza()).zza());
        map.put("ECIES_P256_HKDF_HMAC_SHA256_AES128_GCM_RAW", zzkb.zzc().zza(zzkb.zzc.zza).zza(zzkb.zzb.zzc).zza(zzkb.zze.zzb).zza(zzkb.zzd.zzc).zza(zzdx.zze().zza(12).zzb(16).zzc(16).zza(zzdx.zza.zzc).zza()).zza());
        map.put("ECIES_P256_COMPRESSED_HKDF_HMAC_SHA256_AES128_GCM", zzkb.zzc().zza(zzkb.zzc.zza).zza(zzkb.zzb.zzc).zza(zzkb.zze.zza).zza(zzkb.zzd.zza).zza(zzdx.zze().zza(12).zzb(16).zzc(16).zza(zzdx.zza.zzc).zza()).zza());
        map.put("ECIES_P256_COMPRESSED_HKDF_HMAC_SHA256_AES128_GCM_RAW", zzkb.zzc().zza(zzkb.zzc.zza).zza(zzkb.zzb.zzc).zza(zzkb.zze.zza).zza(zzkb.zzd.zzc).zza(zzdx.zze().zza(12).zzb(16).zzc(16).zza(zzdx.zza.zzc).zza()).zza());
        map.put("ECIES_P256_HKDF_HMAC_SHA256_AES128_GCM_COMPRESSED_WITHOUT_PREFIX", zzkb.zzc().zza(zzkb.zzc.zza).zza(zzkb.zzb.zzc).zza(zzkb.zze.zza).zza(zzkb.zzd.zzc).zza(zzdx.zze().zza(12).zzb(16).zzc(16).zza(zzdx.zza.zzc).zza()).zza());
        map.put("ECIES_P256_HKDF_HMAC_SHA256_AES128_CTR_HMAC_SHA256", zzkb.zzc().zza(zzkb.zzc.zza).zza(zzkb.zzb.zzc).zza(zzkb.zze.zzb).zza(zzkb.zzd.zza).zza(zzdi.zzf().zza(16).zzb(32).zzd(16).zzc(16).zza(zzdi.zza.zzc).zza(zzdi.zzc.zzc).zza()).zza());
        map.put("ECIES_P256_HKDF_HMAC_SHA256_AES128_CTR_HMAC_SHA256_RAW", zzkb.zzc().zza(zzkb.zzc.zza).zza(zzkb.zzb.zzc).zza(zzkb.zze.zzb).zza(zzkb.zzd.zzc).zza(zzdi.zzf().zza(16).zzb(32).zzd(16).zzc(16).zza(zzdi.zza.zzc).zza(zzdi.zzc.zzc).zza()).zza());
        map.put("ECIES_P256_COMPRESSED_HKDF_HMAC_SHA256_AES128_CTR_HMAC_SHA256", zzkb.zzc().zza(zzkb.zzc.zza).zza(zzkb.zzb.zzc).zza(zzkb.zze.zza).zza(zzkb.zzd.zza).zza(zzdi.zzf().zza(16).zzb(32).zzd(16).zzc(16).zza(zzdi.zza.zzc).zza(zzdi.zzc.zzc).zza()).zza());
        map.put("ECIES_P256_COMPRESSED_HKDF_HMAC_SHA256_AES128_CTR_HMAC_SHA256_RAW", zzkb.zzc().zza(zzkb.zzc.zza).zza(zzkb.zzb.zzc).zza(zzkb.zze.zza).zza(zzkb.zzd.zzc).zza(zzdi.zzf().zza(16).zzb(32).zzd(16).zzc(16).zza(zzdi.zza.zzc).zza(zzdi.zzc.zzc).zza()).zza());
        zzoxVarZza.zza(Collections.unmodifiableMap(map));
        zzpa.zza().zza(zza);
        zzpa.zza().zza(zzb);
        zzop.zza().zza(zze, zzkb.class);
        zznq.zza().zza((zzbh) zzc, true);
        zznq.zza().zza((zzbh) zzd, false);
    }
}
