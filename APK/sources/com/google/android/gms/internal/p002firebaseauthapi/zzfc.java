package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import java.util.Objects;
import javax.annotation.Nullable;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzfc extends zzcy {
    private final zzc zza;
    private final String zzb;
    private final zza zzc;
    private final zzcy zzd;

    public final int hashCode() {
        return Objects.hash(zzfc.class, this.zzb, this.zzc, this.zzd, this.zza);
    }

    /* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
    public static class zzb {

        @Nullable
        private zzc zza;

        @Nullable
        private String zzb;

        @Nullable
        private zza zzc;

        @Nullable
        private zzcy zzd;

        public final zzb zza(zzcy zzcyVar) {
            this.zzd = zzcyVar;
            return this;
        }

        public final zzb zza(zza zzaVar) {
            this.zzc = zzaVar;
            return this;
        }

        public final zzb zza(String str) {
            this.zzb = str;
            return this;
        }

        public final zzb zza(zzc zzcVar) {
            this.zza = zzcVar;
            return this;
        }

        public final zzfc zza() throws GeneralSecurityException {
            if (this.zza == null) {
                this.zza = zzc.zzb;
            }
            if (this.zzb == null) {
                throw new GeneralSecurityException("kekUri must be set");
            }
            if (this.zzc == null) {
                throw new GeneralSecurityException("dekParsingStrategy must be set");
            }
            zzcy zzcyVar = this.zzd;
            if (zzcyVar == null) {
                throw new GeneralSecurityException("dekParametersForNewKeys must be set");
            }
            if (zzcyVar.zza()) {
                throw new GeneralSecurityException("dekParametersForNewKeys must not have ID Requirements");
            }
            zza zzaVar = this.zzc;
            zzcy zzcyVar2 = this.zzd;
            if ((!zzaVar.equals(zza.zza) || !(zzcyVar2 instanceof zzdx)) && ((!zzaVar.equals(zza.zzc) || !(zzcyVar2 instanceof zzem)) && ((!zzaVar.equals(zza.zzb) || !(zzcyVar2 instanceof zzge)) && ((!zzaVar.equals(zza.zzd) || !(zzcyVar2 instanceof zzdi)) && ((!zzaVar.equals(zza.zze) || !(zzcyVar2 instanceof zzdq)) && (!zzaVar.equals(zza.zzf) || !(zzcyVar2 instanceof zzeg))))))) {
                throw new GeneralSecurityException("Cannot use parsing strategy " + this.zzc.toString() + " when new keys are picked according to " + String.valueOf(this.zzd) + ".");
            }
            return new zzfc(this.zza, this.zzb, this.zzc, this.zzd);
        }

        private zzb() {
        }
    }

    public final zzcy zzb() {
        return this.zzd;
    }

    /* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
    public static final class zzc {
        public static final zzc zza = new zzc("TINK");
        public static final zzc zzb = new zzc("NO_PREFIX");
        private final String zzc;

        public final String toString() {
            return this.zzc;
        }

        private zzc(String str) {
            this.zzc = str;
        }
    }

    public final zzc zzc() {
        return this.zza;
    }

    public final String zzd() {
        return this.zzb;
    }

    public final String toString() {
        return "LegacyKmsEnvelopeAead Parameters (kekUri: " + this.zzb + ", dekParsingStrategy: " + String.valueOf(this.zzc) + ", dekParametersForNewKeys: " + String.valueOf(this.zzd) + ", variant: " + String.valueOf(this.zza) + ")";
    }

    private zzfc(zzc zzcVar, String str, zza zzaVar, zzcy zzcyVar) {
        this.zza = zzcVar;
        this.zzb = str;
        this.zzc = zzaVar;
        this.zzd = zzcyVar;
    }

    /* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
    public static final class zza {
        public static final zza zza = new zza("ASSUME_AES_GCM");
        public static final zza zzb = new zza("ASSUME_XCHACHA20POLY1305");
        public static final zza zzc = new zza("ASSUME_CHACHA20POLY1305");
        public static final zza zzd = new zza("ASSUME_AES_CTR_HMAC");
        public static final zza zze = new zza("ASSUME_AES_EAX");
        public static final zza zzf = new zza("ASSUME_AES_GCM_SIV");
        private final String zzg;

        public final String toString() {
            return this.zzg;
        }

        private zza(String str) {
            this.zzg = str;
        }
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof zzfc)) {
            return false;
        }
        zzfc zzfcVar = (zzfc) obj;
        return zzfcVar.zzc.equals(this.zzc) && zzfcVar.zzd.equals(this.zzd) && zzfcVar.zzb.equals(this.zzb) && zzfcVar.zza.equals(this.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcb
    public final boolean zza() {
        return this.zza != zzc.zzb;
    }
}
