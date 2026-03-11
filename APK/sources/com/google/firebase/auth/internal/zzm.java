package com.google.firebase.auth.internal;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zzm extends zzi {
    private String zza;
    private String zzb;
    private String zzc;

    @Override // com.google.firebase.auth.internal.zzi
    public final zzi zza(String str) {
        this.zzb = str;
        return this;
    }

    @Override // com.google.firebase.auth.internal.zzi
    public final zzi zzb(String str) {
        this.zzc = str;
        return this;
    }

    @Override // com.google.firebase.auth.internal.zzi
    public final zzi zzc(String str) {
        this.zza = str;
        return this;
    }

    @Override // com.google.firebase.auth.internal.zzi
    public final zzj zza() {
        return new zzn(this.zza, this.zzb, this.zzc);
    }

    zzm() {
    }
}
