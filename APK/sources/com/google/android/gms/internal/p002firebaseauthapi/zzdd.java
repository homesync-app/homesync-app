package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzdi;
import java.security.GeneralSecurityException;
import javax.annotation.Nullable;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzdd extends zzcw {
    private final zzdi zza;
    private final zzaal zzb;
    private final zzaal zzc;
    private final zzaaj zzd;

    @Nullable
    private final Integer zze;

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcw, com.google.android.gms.internal.p002firebaseauthapi.zzbi
    public final /* synthetic */ zzcb zza() {
        return (zzdi) zza();
    }

    /* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
    public static class zza {

        @Nullable
        private zzdi zza;

        @Nullable
        private zzaal zzb;

        @Nullable
        private zzaal zzc;

        @Nullable
        private Integer zzd;

        public final zza zza(zzaal zzaalVar) {
            this.zzb = zzaalVar;
            return this;
        }

        public final zza zzb(zzaal zzaalVar) {
            this.zzc = zzaalVar;
            return this;
        }

        public final zza zza(@Nullable Integer num) {
            this.zzd = num;
            return this;
        }

        public final zza zza(zzdi zzdiVar) {
            this.zza = zzdiVar;
            return this;
        }

        public final zzdd zza() throws GeneralSecurityException {
            zzaaj zzaajVarZzb;
            zzdi zzdiVar = this.zza;
            if (zzdiVar == null) {
                throw new GeneralSecurityException("Cannot build without parameters");
            }
            if (this.zzb == null || this.zzc == null) {
                throw new GeneralSecurityException("Cannot build without key material");
            }
            if (zzdiVar.zzb() != this.zzb.zza()) {
                throw new GeneralSecurityException("AES key size mismatch");
            }
            if (this.zza.zzc() != this.zzc.zza()) {
                throw new GeneralSecurityException("HMAC key size mismatch");
            }
            if (this.zza.zza() && this.zzd == null) {
                throw new GeneralSecurityException("Cannot create key without ID requirement with parameters with ID requirement");
            }
            if (!this.zza.zza() && this.zzd != null) {
                throw new GeneralSecurityException("Cannot create key with ID requirement with parameters without ID requirement");
            }
            if (this.zza.zzh() == zzdi.zzc.zzc) {
                zzaajVarZzb = zzpe.zza;
            } else if (this.zza.zzh() == zzdi.zzc.zzb) {
                zzaajVarZzb = zzpe.zza(this.zzd.intValue());
            } else if (this.zza.zzh() == zzdi.zzc.zza) {
                zzaajVarZzb = zzpe.zzb(this.zzd.intValue());
            } else {
                throw new IllegalStateException("Unknown AesCtrHmacAeadParameters.Variant: " + String.valueOf(this.zza.zzh()));
            }
            return new zzdd(this.zza, this.zzb, this.zzc, zzaajVarZzb, this.zzd);
        }

        private zza() {
            this.zza = null;
            this.zzb = null;
            this.zzc = null;
            this.zzd = null;
        }
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcw
    /* JADX INFO: renamed from: zzc */
    public final /* synthetic */ zzcy zza() {
        return this.zza;
    }

    public static zza zze() {
        return new zza();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcw
    public final zzaaj zzd() {
        return this.zzd;
    }

    public final zzaal zzf() {
        return this.zzb;
    }

    public final zzaal zzg() {
        return this.zzc;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzbi
    @Nullable
    public final Integer zzb() {
        return this.zze;
    }

    private zzdd(zzdi zzdiVar, zzaal zzaalVar, zzaal zzaalVar2, zzaaj zzaajVar, @Nullable Integer num) {
        this.zza = zzdiVar;
        this.zzb = zzaalVar;
        this.zzc = zzaalVar2;
        this.zzd = zzaajVar;
        this.zze = num;
    }
}
