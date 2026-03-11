package com.google.android.gms.internal.measurement;

import java.util.Objects;

/* JADX INFO: compiled from: com.google.android.gms:play-services-measurement-sdk-api@@23.0.0 */
/* JADX INFO: loaded from: classes3.dex */
final class zzdu extends zzcw {
    final /* synthetic */ Runnable zza;

    zzdu(zzdv zzdvVar, Runnable runnable) {
        this.zza = runnable;
        Objects.requireNonNull(zzdvVar);
    }

    @Override // com.google.android.gms.internal.measurement.zzcx
    public final void zze() {
        this.zza.run();
    }
}
