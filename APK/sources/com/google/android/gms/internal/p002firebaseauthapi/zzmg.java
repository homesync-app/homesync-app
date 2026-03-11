package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zziv;
import com.google.android.gms.internal.p002firebaseauthapi.zzkg;
import com.google.android.gms.internal.p002firebaseauthapi.zzwx;
import java.security.GeneralSecurityException;
import java.security.KeyPair;
import java.security.interfaces.ECPrivateKey;
import java.security.interfaces.ECPublicKey;
import java.security.spec.ECPoint;
import java.security.spec.EllipticCurve;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzmg {
    private static final zzps<zzki, zzbd> zza = zzps.zza(new zzpu() { // from class: com.google.android.gms.internal.firebase-auth-api.zzmj
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzpu
        public final Object zza(zzbi zzbiVar) {
            return zzma.zza((zzki) zzbiVar);
        }
    }, zzki.class, zzbd.class);
    private static final zzps<zzkq, zzbg> zzb = zzps.zza(new zzpu() { // from class: com.google.android.gms.internal.firebase-auth-api.zzmi
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzpu
        public final Object zza(zzbi zzbiVar) {
            return zzmd.zza((zzkq) zzbiVar);
        }
    }, zzkq.class, zzbg.class);
    private static final zzcd<zzbd> zzc = zzod.zza("type.googleapis.com/google.crypto.tink.HpkePrivateKey", zzbd.class, zzwr.zzf());
    private static final zzbh<zzbg> zzd = zzod.zza("type.googleapis.com/google.crypto.tink.HpkePublicKey", zzbg.class, zzwx.zzb.ASYMMETRIC_PUBLIC, zzwu.zzg());
    private static final zzor<zzkg> zze = new zzor() { // from class: com.google.android.gms.internal.firebase-auth-api.zzml
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzor
        public final zzbi zza(zzcb zzcbVar, Integer num) {
            return zzmg.zza((zzkg) zzcbVar, num);
        }
    };

    public static /* synthetic */ zzki zza(zzkg zzkgVar, Integer num) throws GeneralSecurityException {
        byte[] bArr;
        zzaaj zzaajVarZza;
        zzaal zzaalVarZza;
        if (zzkgVar.zze().equals(zzkg.zzf.zzd)) {
            byte[] bArrZza = zzaah.zza();
            zzaalVarZza = zzaal.zza(bArrZza, zzbf.zza());
            zzaajVarZza = zzaaj.zza(zzaah.zza(bArrZza));
        } else {
            if (!zzkgVar.zze().equals(zzkg.zzf.zza) && !zzkgVar.zze().equals(zzkg.zzf.zzb) && !zzkgVar.zze().equals(zzkg.zzf.zzc)) {
                throw new GeneralSecurityException("Unknown KEM ID");
            }
            zzzi zzziVarZzc = zzmk.zzc(zzkgVar.zze());
            KeyPair keyPairZza = zzzf.zza(zzzf.zza(zzziVarZzc));
            zzzh zzzhVar = zzzh.UNCOMPRESSED;
            ECPoint w = ((ECPublicKey) keyPairZza.getPublic()).getW();
            EllipticCurve curve = zzzf.zza(zzziVarZzc).getCurve();
            zznj.zza(w, curve);
            int iZza = zzzf.zza(curve);
            int iOrdinal = zzzhVar.ordinal();
            if (iOrdinal != 0) {
                if (iOrdinal == 1) {
                    int i = iZza + 1;
                    bArr = new byte[i];
                    byte[] bArrZza2 = zzne.zza(w.getAffineX());
                    System.arraycopy(bArrZza2, 0, bArr, i - bArrZza2.length, bArrZza2.length);
                    bArr[0] = (byte) (w.getAffineY().testBit(0) ? 3 : 2);
                } else {
                    if (iOrdinal != 2) {
                        throw new GeneralSecurityException("invalid format:" + String.valueOf(zzzhVar));
                    }
                    int i2 = iZza * 2;
                    bArr = new byte[i2];
                    byte[] bArrZza3 = zzne.zza(w.getAffineX());
                    if (bArrZza3.length > iZza) {
                        bArrZza3 = Arrays.copyOfRange(bArrZza3, bArrZza3.length - iZza, bArrZza3.length);
                    }
                    byte[] bArrZza4 = zzne.zza(w.getAffineY());
                    if (bArrZza4.length > iZza) {
                        bArrZza4 = Arrays.copyOfRange(bArrZza4, bArrZza4.length - iZza, bArrZza4.length);
                    }
                    System.arraycopy(bArrZza4, 0, bArr, i2 - bArrZza4.length, bArrZza4.length);
                    System.arraycopy(bArrZza3, 0, bArr, iZza - bArrZza3.length, bArrZza3.length);
                }
            } else {
                int i3 = (iZza * 2) + 1;
                bArr = new byte[i3];
                byte[] bArrZza5 = zzne.zza(w.getAffineX());
                byte[] bArrZza6 = zzne.zza(w.getAffineY());
                System.arraycopy(bArrZza6, 0, bArr, i3 - bArrZza6.length, bArrZza6.length);
                System.arraycopy(bArrZza5, 0, bArr, (iZza + 1) - bArrZza5.length, bArrZza5.length);
                bArr[0] = 4;
            }
            zzaajVarZza = zzaaj.zza(bArr);
            zzaalVarZza = zzaal.zza(zzne.zza(((ECPrivateKey) keyPairZza.getPrivate()).getS(), zzmk.zza(zzkgVar.zze())), zzbf.zza());
        }
        return zzki.zza(zzkq.zza(zzkgVar, zzaajVarZza, num), zzaalVarZza);
    }

    public static void zza(boolean z) throws GeneralSecurityException {
        if (!zziv.zza.zza.zza()) {
            throw new GeneralSecurityException("Registering HPKE Hybrid Encryption is not supported in FIPS mode");
        }
        zzkl.zza();
        zzox zzoxVarZza = zzox.zza();
        HashMap map = new HashMap();
        map.put("DHKEM_X25519_HKDF_SHA256_HKDF_SHA256_AES_128_GCM", zzkg.zzc().zza(zzkg.zze.zza).zza(zzkg.zzf.zzd).zza(zzkg.zzc.zza).zza(zzkg.zzb.zza).zza());
        map.put("DHKEM_X25519_HKDF_SHA256_HKDF_SHA256_AES_128_GCM_RAW", zzkg.zzc().zza(zzkg.zze.zzc).zza(zzkg.zzf.zzd).zza(zzkg.zzc.zza).zza(zzkg.zzb.zza).zza());
        map.put("DHKEM_X25519_HKDF_SHA256_HKDF_SHA256_AES_256_GCM", zzkg.zzc().zza(zzkg.zze.zza).zza(zzkg.zzf.zzd).zza(zzkg.zzc.zza).zza(zzkg.zzb.zzb).zza());
        map.put("DHKEM_X25519_HKDF_SHA256_HKDF_SHA256_AES_256_GCM_RAW", zzkg.zzc().zza(zzkg.zze.zzc).zza(zzkg.zzf.zzd).zza(zzkg.zzc.zza).zza(zzkg.zzb.zzb).zza());
        map.put("DHKEM_X25519_HKDF_SHA256_HKDF_SHA256_CHACHA20_POLY1305", zzkg.zzc().zza(zzkg.zze.zza).zza(zzkg.zzf.zzd).zza(zzkg.zzc.zza).zza(zzkg.zzb.zzc).zza());
        map.put("DHKEM_X25519_HKDF_SHA256_HKDF_SHA256_CHACHA20_POLY1305_RAW", zzkg.zzc().zza(zzkg.zze.zzc).zza(zzkg.zzf.zzd).zza(zzkg.zzc.zza).zza(zzkg.zzb.zzc).zza());
        map.put("DHKEM_P256_HKDF_SHA256_HKDF_SHA256_AES_128_GCM", zzkg.zzc().zza(zzkg.zze.zza).zza(zzkg.zzf.zza).zza(zzkg.zzc.zza).zza(zzkg.zzb.zza).zza());
        map.put("DHKEM_P256_HKDF_SHA256_HKDF_SHA256_AES_128_GCM_RAW", zzkg.zzc().zza(zzkg.zze.zzc).zza(zzkg.zzf.zza).zza(zzkg.zzc.zza).zza(zzkg.zzb.zza).zza());
        map.put("DHKEM_P256_HKDF_SHA256_HKDF_SHA256_AES_256_GCM", zzkg.zzc().zza(zzkg.zze.zza).zza(zzkg.zzf.zza).zza(zzkg.zzc.zza).zza(zzkg.zzb.zzb).zza());
        map.put("DHKEM_P256_HKDF_SHA256_HKDF_SHA256_AES_256_GCM_RAW", zzkg.zzc().zza(zzkg.zze.zzc).zza(zzkg.zzf.zza).zza(zzkg.zzc.zza).zza(zzkg.zzb.zzb).zza());
        map.put("DHKEM_P384_HKDF_SHA384_HKDF_SHA384_AES_128_GCM", zzkg.zzc().zza(zzkg.zze.zza).zza(zzkg.zzf.zzb).zza(zzkg.zzc.zzb).zza(zzkg.zzb.zza).zza());
        map.put("DHKEM_P384_HKDF_SHA384_HKDF_SHA384_AES_128_GCM_RAW", zzkg.zzc().zza(zzkg.zze.zzc).zza(zzkg.zzf.zzb).zza(zzkg.zzc.zzb).zza(zzkg.zzb.zza).zza());
        map.put("DHKEM_P384_HKDF_SHA384_HKDF_SHA384_AES_256_GCM", zzkg.zzc().zza(zzkg.zze.zza).zza(zzkg.zzf.zzb).zza(zzkg.zzc.zzb).zza(zzkg.zzb.zzb).zza());
        map.put("DHKEM_P384_HKDF_SHA384_HKDF_SHA384_AES_256_GCM_RAW", zzkg.zzc().zza(zzkg.zze.zzc).zza(zzkg.zzf.zzb).zza(zzkg.zzc.zzb).zza(zzkg.zzb.zzb).zza());
        map.put("DHKEM_P521_HKDF_SHA512_HKDF_SHA512_AES_128_GCM", zzkg.zzc().zza(zzkg.zze.zza).zza(zzkg.zzf.zzc).zza(zzkg.zzc.zzc).zza(zzkg.zzb.zza).zza());
        map.put("DHKEM_P521_HKDF_SHA512_HKDF_SHA512_AES_128_GCM_RAW", zzkg.zzc().zza(zzkg.zze.zzc).zza(zzkg.zzf.zzc).zza(zzkg.zzc.zzc).zza(zzkg.zzb.zza).zza());
        map.put("DHKEM_P521_HKDF_SHA512_HKDF_SHA512_AES_256_GCM", zzkg.zzc().zza(zzkg.zze.zza).zza(zzkg.zzf.zzc).zza(zzkg.zzc.zzc).zza(zzkg.zzb.zzb).zza());
        map.put("DHKEM_P521_HKDF_SHA512_HKDF_SHA512_AES_256_GCM_RAW", zzkg.zzc().zza(zzkg.zze.zzc).zza(zzkg.zzf.zzc).zza(zzkg.zzc.zzc).zza(zzkg.zzb.zzb).zza());
        zzoxVarZza.zza(Collections.unmodifiableMap(map));
        zzpa.zza().zza(zza);
        zzpa.zza().zza(zzb);
        zzop.zza().zza(zze, zzkg.class);
        zznq.zza().zza((zzbh) zzc, true);
        zznq.zza().zza((zzbh) zzd, false);
    }
}
