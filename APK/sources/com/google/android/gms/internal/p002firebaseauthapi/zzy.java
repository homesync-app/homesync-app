package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zzy extends zzaa {
    private final /* synthetic */ zzf zzb;

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaa
    final int zza(int i) {
        return i + 1;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzaa
    final int zzb(int i) {
        return this.zzb.zza(this.zza, i);
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    zzy(zzt zztVar, CharSequence charSequence, zzf zzfVar) {
        super(zztVar, charSequence);
        this.zzb = zzfVar;
    }
}
