package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzkg;
import java.security.GeneralSecurityException;
import java.security.spec.EllipticCurve;
import javax.annotation.Nullable;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzkq extends zzli {
    private final zzkg zza;
    private final zzaaj zzb;
    private final zzaaj zzc;

    @Nullable
    private final Integer zzd;

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzli, com.google.android.gms.internal.p002firebaseauthapi.zzbi
    public final /* synthetic */ zzcb zza() {
        return (zzkg) zza();
    }

    public static zzkq zza(zzkg zzkgVar, zzaaj zzaajVar, @Nullable Integer num) throws GeneralSecurityException {
        EllipticCurve curve;
        zzaaj zzaajVarZzb;
        zzkg.zze zzeVarZzf = zzkgVar.zzf();
        if (!zzeVarZzf.equals(zzkg.zze.zzc) && num == null) {
            throw new GeneralSecurityException("'idRequirement' must be non-null for " + String.valueOf(zzeVarZzf) + " variant.");
        }
        if (zzeVarZzf.equals(zzkg.zze.zzc) && num != null) {
            throw new GeneralSecurityException("'idRequirement' must be null for NO_PREFIX variant.");
        }
        zzkg.zzf zzfVarZze = zzkgVar.zze();
        int iZza = zzaajVar.zza();
        String str = "Encoded public key byte length for " + String.valueOf(zzfVarZze) + " must be %d, not " + iZza;
        if (zzfVarZze == zzkg.zzf.zza) {
            if (iZza != 65) {
                throw new GeneralSecurityException(String.format(str, 65));
            }
        } else if (zzfVarZze == zzkg.zzf.zzb) {
            if (iZza != 97) {
                throw new GeneralSecurityException(String.format(str, 97));
            }
        } else if (zzfVarZze == zzkg.zzf.zzc) {
            if (iZza != 133) {
                throw new GeneralSecurityException(String.format(str, 133));
            }
        } else {
            if (zzfVarZze != zzkg.zzf.zzd) {
                throw new GeneralSecurityException("Unable to validate public key length for " + String.valueOf(zzfVarZze));
            }
            if (iZza != 32) {
                throw new GeneralSecurityException(String.format(str, 32));
            }
        }
        if (zzfVarZze == zzkg.zzf.zza || zzfVarZze == zzkg.zzf.zzb || zzfVarZze == zzkg.zzf.zzc) {
            if (zzfVarZze == zzkg.zzf.zza) {
                curve = zznj.zza.getCurve();
            } else if (zzfVarZze == zzkg.zzf.zzb) {
                curve = zznj.zzb.getCurve();
            } else {
                if (zzfVarZze != zzkg.zzf.zzc) {
                    throw new IllegalArgumentException("Unable to determine NIST curve type for " + String.valueOf(zzfVarZze));
                }
                curve = zznj.zzc.getCurve();
            }
            zznj.zza(zzzf.zza(curve, zzzh.UNCOMPRESSED, zzaajVar.zzb()), curve);
        }
        zzkg.zze zzeVarZzf2 = zzkgVar.zzf();
        if (zzeVarZzf2 == zzkg.zze.zzc) {
            zzaajVarZzb = zzpe.zza;
        } else {
            if (num == null) {
                throw new IllegalStateException("idRequirement must be non-null for HpkeParameters.Variant " + String.valueOf(zzeVarZzf2));
            }
            if (zzeVarZzf2 == zzkg.zze.zzb) {
                zzaajVarZzb = zzpe.zza(num.intValue());
            } else {
                if (zzeVarZzf2 != zzkg.zze.zza) {
                    throw new IllegalStateException("Unknown HpkeParameters.Variant: " + String.valueOf(zzeVarZzf2));
                }
                zzaajVarZzb = zzpe.zzb(num.intValue());
            }
        }
        return new zzkq(zzkgVar, zzaajVar, zzaajVarZzb, num);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzli
    /* JADX INFO: renamed from: zzc */
    public final /* synthetic */ zzlg zza() {
        return this.zza;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzli
    public final zzaaj zzd() {
        return this.zzc;
    }

    public final zzaaj zze() {
        return this.zzb;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbi
    @Nullable
    public final Integer zzb() {
        return this.zzd;
    }

    private zzkq(zzkg zzkgVar, zzaaj zzaajVar, zzaaj zzaajVar2, @Nullable Integer num) {
        this.zza = zzkgVar;
        this.zzb = zzaajVar;
        this.zzc = zzaajVar2;
        this.zzd = num;
    }
}
