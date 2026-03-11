package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zzagr extends zzaih {
    private String zza;
    private String zzb;
    private String zzc;
    private zzahg zzd;
    private String zze;

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaih
    public final zzaih zza(String str) {
        if (str == null) {
            throw new NullPointerException("Null idToken");
        }
        this.zze = str;
        return this;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaih
    public final zzaih zzb(String str) {
        if (str == null) {
            throw new NullPointerException("Null providerId");
        }
        this.zza = str;
        return this;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaih
    public final zzaih zzc(String str) {
        this.zzb = str;
        return this;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaih
    public final zzaih zzd(String str) {
        if (str == null) {
            throw new NullPointerException("Null token");
        }
        this.zzc = str;
        return this;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaih
    public final zzaih zza(zzahg zzahgVar) {
        if (zzahgVar == null) {
            throw new NullPointerException("Null tokenType");
        }
        this.zzd = zzahgVar;
        return this;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaih
    public final zzaie zza() {
        if (this.zza == null || this.zzc == null || this.zzd == null || this.zze == null) {
            StringBuilder sb = new StringBuilder();
            if (this.zza == null) {
                sb.append(" providerId");
            }
            if (this.zzc == null) {
                sb.append(" token");
            }
            if (this.zzd == null) {
                sb.append(" tokenType");
            }
            if (this.zze == null) {
                sb.append(" idToken");
            }
            throw new IllegalStateException("Missing required properties:" + String.valueOf(sb));
        }
        return new zzago(this.zza, this.zzb, this.zzc, this.zzd, this.zze);
    }

    zzagr() {
    }
}
