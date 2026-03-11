package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.firebase.auth.internal.zzao;
import java.util.Objects;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zzaaw implements zzafv<zzajh> {
    private final /* synthetic */ zzael zza;
    private final /* synthetic */ zzaar zzb;

    zzaaw(zzaar zzaarVar, zzael zzaelVar) {
        this.zza = zzaelVar;
        Objects.requireNonNull(zzaarVar);
        this.zzb = zzaarVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzafs
    public final void zza(String str) {
        this.zza.zza(zzao.zza(str));
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzafv
    public final /* synthetic */ void zza(zzajh zzajhVar) {
        zzajh zzajhVar2 = zzajhVar;
        if (zzajhVar2.zzf()) {
            this.zza.zza(new zzaas(zzajhVar2.zzc(), zzajhVar2.zze(), null));
        } else {
            this.zzb.zza(new zzahv(zzajhVar2.zzd(), zzajhVar2.zzb(), Long.valueOf(zzajhVar2.zza()), "Bearer"), null, null, false, null, this.zza, this);
        }
    }
}
