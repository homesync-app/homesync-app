package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzkg;
import java.math.BigInteger;
import java.security.GeneralSecurityException;
import java.security.spec.ECParameterSpec;
import java.util.Arrays;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzki extends zzlj {
    private final zzkq zza;
    private final zzaal zzb;

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzlj, com.google.android.gms.internal.p002firebaseauthapi.zzce
    public final /* synthetic */ zzbi zzc() {
        return (zzkq) zzc();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzlj, com.google.android.gms.internal.p002firebaseauthapi.zzbi
    public final /* synthetic */ zzcb zza() {
        return (zzkg) zza();
    }

    public static zzki zza(zzkq zzkqVar, zzaal zzaalVar) throws GeneralSecurityException {
        ECParameterSpec eCParameterSpec;
        if (zzkqVar == null) {
            throw new GeneralSecurityException("HPKE private key cannot be constructed without an HPKE public key");
        }
        if (zzaalVar == null) {
            throw new GeneralSecurityException("HPKE private key cannot be constructed without secret");
        }
        zzkg.zzf zzfVarZze = ((zzkg) ((zzlg) zzkqVar.zza())).zze();
        int iZza = zzaalVar.zza();
        String str = "Encoded private key byte length for " + String.valueOf(zzfVarZze) + " must be %d, not " + iZza;
        if (zzfVarZze == zzkg.zzf.zza) {
            if (iZza != 32) {
                throw new GeneralSecurityException(String.format(str, 32));
            }
        } else if (zzfVarZze == zzkg.zzf.zzb) {
            if (iZza != 48) {
                throw new GeneralSecurityException(String.format(str, 48));
            }
        } else if (zzfVarZze == zzkg.zzf.zzc) {
            if (iZza != 66) {
                throw new GeneralSecurityException(String.format(str, 66));
            }
        } else {
            if (zzfVarZze != zzkg.zzf.zzd) {
                throw new GeneralSecurityException("Unable to validate private key length for " + String.valueOf(zzfVarZze));
            }
            if (iZza != 32) {
                throw new GeneralSecurityException(String.format(str, 32));
            }
        }
        zzkg.zzf zzfVarZze2 = ((zzkg) ((zzlg) zzkqVar.zza())).zze();
        byte[] bArrZzb = zzkqVar.zze().zzb();
        byte[] bArrZza = zzaalVar.zza(zzbf.zza());
        if (zzfVarZze2 == zzkg.zzf.zza || zzfVarZze2 == zzkg.zzf.zzb || zzfVarZze2 == zzkg.zzf.zzc) {
            if (zzfVarZze2 == zzkg.zzf.zza) {
                eCParameterSpec = zznj.zza;
            } else if (zzfVarZze2 == zzkg.zzf.zzb) {
                eCParameterSpec = zznj.zzb;
            } else if (zzfVarZze2 == zzkg.zzf.zzc) {
                eCParameterSpec = zznj.zzc;
            } else {
                throw new IllegalArgumentException("Unable to determine NIST curve params for " + String.valueOf(zzfVarZze2));
            }
            BigInteger order = eCParameterSpec.getOrder();
            BigInteger bigIntegerZza = zzne.zza(bArrZza);
            if (bigIntegerZza.signum() <= 0 || bigIntegerZza.compareTo(order) >= 0) {
                throw new GeneralSecurityException("Invalid private key.");
            }
            if (!zznj.zza(bigIntegerZza, eCParameterSpec).equals(zzzf.zza(eCParameterSpec.getCurve(), zzzh.UNCOMPRESSED, bArrZzb))) {
                throw new GeneralSecurityException("Invalid private key for public key.");
            }
        } else if (zzfVarZze2 == zzkg.zzf.zzd) {
            if (!Arrays.equals(zzaah.zza(bArrZza), bArrZzb)) {
                throw new GeneralSecurityException("Invalid private key for public key.");
            }
        } else {
            throw new IllegalArgumentException("Unable to validate key pair for " + String.valueOf(zzfVarZze2));
        }
        return new zzki(zzkqVar, zzaalVar);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzlj
    /* JADX INFO: renamed from: zzd */
    public final /* synthetic */ zzlg zza() {
        return (zzkg) ((zzlg) this.zza.zza());
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzlj
    /* JADX INFO: renamed from: zze */
    public final /* synthetic */ zzli zzc() {
        return this.zza;
    }

    public final zzaal zzf() {
        return this.zzb;
    }

    private zzki(zzkq zzkqVar, zzaal zzaalVar) {
        this.zza = zzkqVar;
        this.zzb = zzaalVar;
    }
}
