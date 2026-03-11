package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzfc;
import java.security.GeneralSecurityException;
import javax.annotation.Nullable;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzfd extends zzcw {
    private final zzfc zza;
    private final zzaaj zzb;

    @Nullable
    private final Integer zzc;

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcw, com.google.android.gms.internal.p002firebaseauthapi.zzbi
    public final /* synthetic */ zzcb zza() {
        return (zzfc) zza();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcw
    /* JADX INFO: renamed from: zzc */
    public final /* synthetic */ zzcy zza() {
        return this.zza;
    }

    public static zzfd zza(zzfc zzfcVar, @Nullable Integer num) throws GeneralSecurityException {
        zzaaj zzaajVarZzb;
        if (zzfcVar.zzc() == zzfc.zzc.zzb) {
            if (num != null) {
                throw new GeneralSecurityException("For given Variant NO_PREFIX the value of idRequirement must be null");
            }
            zzaajVarZzb = zzpe.zza;
        } else {
            if (zzfcVar.zzc() != zzfc.zzc.zza) {
                throw new GeneralSecurityException("Unknown Variant: " + String.valueOf(zzfcVar.zzc()));
            }
            if (num == null) {
                throw new GeneralSecurityException("For given Variant TINK the value of idRequirement must be non-null");
            }
            zzaajVarZzb = zzpe.zzb(num.intValue());
        }
        return new zzfd(zzfcVar, zzaajVarZzb, num);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcw
    public final zzaaj zzd() {
        return this.zzb;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbi
    public final Integer zzb() {
        return this.zzc;
    }

    private zzfd(zzfc zzfcVar, zzaaj zzaajVar, @Nullable Integer num) {
        this.zza = zzfcVar;
        this.zzb = zzaajVar;
        this.zzc = num;
    }
}
