package com.google.android.gms.tasks;

import java.util.Objects;

/* JADX INFO: compiled from: com.google.android.gms:play-services-tasks@@18.4.0 */
/* JADX INFO: loaded from: classes3.dex */
final class zzs implements OnTokenCanceledListener {
    final /* synthetic */ TaskCompletionSource zza;

    zzs(TaskCompletionSource taskCompletionSource) {
        Objects.requireNonNull(taskCompletionSource);
        this.zza = taskCompletionSource;
    }

    @Override // com.google.android.gms.tasks.OnTokenCanceledListener
    public final void onCanceled() {
        this.zza.zza().zze();
    }
}
