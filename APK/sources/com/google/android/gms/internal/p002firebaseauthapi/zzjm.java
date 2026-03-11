package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzjm implements zzpz<zzbe, zzbe> {
    private static final zzjm zza = new zzjm();
    private static final zzps<zzof, zzbe> zzb = zzps.zza(new zzpu() { // from class: com.google.android.gms.internal.firebase-auth-api.zzjl
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzpu
        public final Object zza(zzbi zzbiVar) {
            return zzjv.zza((zzof) zzbiVar);
        }
    }, zzof.class, zzbe.class);

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzpz
    public final Class<zzbe> zza() {
        return zzbe.class;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzpz
    public final Class<zzbe> zzb() {
        return zzbe.class;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzpz
    public final /* synthetic */ zzbe zza(zzob zzobVar, zzok zzokVar, zzqc<zzbe> zzqcVar) throws GeneralSecurityException {
        zzoo zzooVarZza;
        zzoo zzooVarZza2;
        zzaaj zzaajVarZzc;
        zzpn zzpnVar = new zzpn();
        for (int i = 0; i < zzobVar.zza(); i++) {
            zzoa zzoaVarZza = zzobVar.zza(i);
            if (zzoaVarZza.zzc().equals(zzbk.zza)) {
                zzbe zzbeVarZza = zzqcVar.zza(zzoaVarZza);
                zzbi zzbiVarZzb = zzoaVarZza.zzb();
                if (zzbiVarZzb instanceof zzjk) {
                    zzaajVarZzc = ((zzjk) zzbiVarZzb).zze();
                } else if (zzbiVarZzb instanceof zzof) {
                    zzaajVarZzc = ((zzof) zzbiVarZzb).zzc();
                } else {
                    throw new GeneralSecurityException("Cannot get output prefix for key of class " + zzbiVarZzb.getClass().getName() + " with parameters " + String.valueOf(zzbiVarZzb.zza()));
                }
                zzpnVar.zza(zzaajVarZzc, new zzjo(zzbeVarZza, zzoaVarZza.zza()));
            }
        }
        if (!zzokVar.zza()) {
            zzol zzolVarZza = zzow.zzb().zza();
            zzooVarZza = zzolVarZza.zza(zzobVar, zzokVar, "daead", "encrypt");
            zzooVarZza2 = zzolVarZza.zza(zzobVar, zzokVar, "daead", "decrypt");
        } else {
            zzooVarZza = zzon.zza;
            zzooVarZza2 = zzon.zza;
        }
        return new zzjn(new zzjo(zzqcVar.zza(zzobVar.zzc()), zzobVar.zzc().zza()), zzpnVar.zza(), zzooVarZza, zzooVarZza2);
    }

    zzjm() {
    }

    public static void zzc() throws GeneralSecurityException {
        zzpa.zza().zza(zza);
        zzpa.zza().zza(zzb);
    }
}
