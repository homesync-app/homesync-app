package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzfc;
import com.google.android.gms.internal.p002firebaseauthapi.zzwx;
import java.security.GeneralSecurityException;
import javax.annotation.Nullable;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzfg {
    private static final zzaaj zza;
    private static final zzph<zzfc, zzqe> zzb;
    private static final zzpd<zzqe> zzc;
    private static final zznx<zzfd, zzqb> zzd;
    private static final zznt<zzqb> zze;

    /* JADX INFO: Access modifiers changed from: private */
    public static zzfd zzb(zzqb zzqbVar, @Nullable zzch zzchVar) throws GeneralSecurityException {
        if (!zzqbVar.zzf().equals("type.googleapis.com/google.crypto.tink.KmsEnvelopeAeadKey")) {
            throw new IllegalArgumentException("Wrong type URL in call to LegacyKmsEnvelopeAeadProtoSerialization.parseKey");
        }
        try {
            zzxt zzxtVarZza = zzxt.zza(zzqbVar.zzd(), zzaku.zza());
            if (zzxtVarZza.zza() == 0) {
                return zzfd.zza(zza(zzxtVarZza.zzd(), zzqbVar.zzb()), zzqbVar.zze());
            }
            throw new GeneralSecurityException("KmsEnvelopeAeadKeys are only accepted with version 0, got " + String.valueOf(zzxtVarZza));
        } catch (zzall e) {
            throw new GeneralSecurityException("Parsing KmsEnvelopeAeadKey failed: ", e);
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static zzfc zzb(zzqe zzqeVar) throws GeneralSecurityException {
        if (!zzqeVar.zza().zzf().equals("type.googleapis.com/google.crypto.tink.KmsEnvelopeAeadKey")) {
            throw new IllegalArgumentException("Wrong type URL in call to LegacyKmsEnvelopeAeadProtoSerialization.parseParameters: " + zzqeVar.zza().zzf());
        }
        try {
            return zza(zzxw.zza(zzqeVar.zza().zze(), zzaku.zza()), zzqeVar.zza().zzd());
        } catch (zzall e) {
            throw new GeneralSecurityException("Parsing KmsEnvelopeAeadKeyFormat failed: ", e);
        }
    }

    private static zzfc zza(zzxw zzxwVar, zzxz zzxzVar) throws GeneralSecurityException {
        zzfc.zza zzaVar;
        zzfc.zzc zzcVar;
        zzcb zzcbVarZza = zzcj.zza(((zzxb) ((zzalf) zzxb.zza().zza(zzxwVar.zza().zzf()).zza(zzxwVar.zza().zze()).zza(zzxz.RAW).zze())).zzk());
        if (zzcbVarZza instanceof zzdx) {
            zzaVar = zzfc.zza.zza;
        } else if (zzcbVarZza instanceof zzem) {
            zzaVar = zzfc.zza.zzc;
        } else if (zzcbVarZza instanceof zzge) {
            zzaVar = zzfc.zza.zzb;
        } else if (zzcbVarZza instanceof zzdi) {
            zzaVar = zzfc.zza.zzd;
        } else if (zzcbVarZza instanceof zzdq) {
            zzaVar = zzfc.zza.zze;
        } else if (zzcbVarZza instanceof zzeg) {
            zzaVar = zzfc.zza.zzf;
        } else {
            throw new GeneralSecurityException("Unsupported DEK parameters when parsing " + String.valueOf(zzcbVarZza));
        }
        zzfc.zzb zzbVar = new zzfc.zzb();
        int i = zzfj.zza[zzxzVar.ordinal()];
        if (i == 1) {
            zzcVar = zzfc.zzc.zza;
        } else if (i == 2) {
            zzcVar = zzfc.zzc.zzb;
        } else {
            throw new GeneralSecurityException("Unable to parse OutputPrefixType: " + zzxzVar.zza());
        }
        return zzbVar.zza(zzcVar).zza(zzxwVar.zze()).zza((zzcy) zzcbVarZza).zza(zzaVar).zza();
    }

    private static zzxw zzb(zzfc zzfcVar) throws GeneralSecurityException {
        try {
            return (zzxw) ((zzalf) zzxw.zzb().zza(zzfcVar.zzd()).zza(zzxb.zza(zzcj.zza(zzfcVar.zzb()), zzaku.zza())).zze());
        } catch (zzall e) {
            throw new GeneralSecurityException("Parsing KmsEnvelopeAeadKeyFormat failed: ", e);
        }
    }

    private static zzxz zza(zzfc.zzc zzcVar) throws GeneralSecurityException {
        if (zzfc.zzc.zza.equals(zzcVar)) {
            return zzxz.TINK;
        }
        if (zzfc.zzc.zzb.equals(zzcVar)) {
            return zzxz.RAW;
        }
        throw new GeneralSecurityException("Unable to serialize variant: " + String.valueOf(zzcVar));
    }

    static {
        zzaaj zzaajVarZzb = zzqn.zzb("type.googleapis.com/google.crypto.tink.KmsEnvelopeAeadKey");
        zza = zzaajVarZzb;
        zzb = zzph.zza(new zzpj() { // from class: com.google.android.gms.internal.firebase-auth-api.zzff
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzpj
            public final zzqf zza(zzcb zzcbVar) {
                zzfc zzfcVar = (zzfc) zzcbVar;
                return zzqe.zzb((zzxb) ((zzalf) zzxb.zza().zza("type.googleapis.com/google.crypto.tink.KmsEnvelopeAeadKey").zza(zzfg.zzb(zzfcVar).zzj()).zza(zzfg.zza(zzfcVar.zzc())).zze()));
            }
        }, zzfc.class, zzqe.class);
        zzc = zzpd.zza(new zzpf() { // from class: com.google.android.gms.internal.firebase-auth-api.zzfi
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zzpf
            public final zzcb zza(zzqf zzqfVar) {
                return zzfg.zzb((zzqe) zzqfVar);
            }
        }, zzaajVarZzb, zzqe.class);
        zzd = zznx.zza(new zznz() { // from class: com.google.android.gms.internal.firebase-auth-api.zzfh
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zznz
            public final zzqf zza(zzbi zzbiVar, zzch zzchVar) {
                zzfd zzfdVar = (zzfd) zzbiVar;
                return zzqb.zza("type.googleapis.com/google.crypto.tink.KmsEnvelopeAeadKey", ((zzxt) ((zzalf) zzxt.zzb().zza(zzfg.zzb((zzfc) ((zzcy) zzfdVar.zza()))).zze())).zzj(), zzwx.zzb.REMOTE, zzfg.zza(((zzfc) ((zzcy) zzfdVar.zza())).zzc()), zzfdVar.zzb());
            }
        }, zzfd.class, zzqb.class);
        zze = zznt.zza(new zznv() { // from class: com.google.android.gms.internal.firebase-auth-api.zzfk
            @Override // com.google.android.gms.internal.p002firebaseauthapi.zznv
            public final zzbi zza(zzqf zzqfVar, zzch zzchVar) {
                return zzfg.zzb((zzqb) zzqfVar, zzchVar);
            }
        }, zzaajVarZzb, zzqb.class);
    }

    public static void zza() throws GeneralSecurityException {
        zzoz zzozVarZza = zzoz.zza();
        zzozVarZza.zza(zzb);
        zzozVarZza.zza(zzc);
        zzozVarZza.zza(zzd);
        zzozVarZza.zza(zze);
    }
}
