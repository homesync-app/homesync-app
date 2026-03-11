package com.google.android.recaptcha.internal;

import java.util.concurrent.Executors;
import kotlinx.coroutines.BuildersKt__Builders_commonKt;
import kotlinx.coroutines.CoroutineScope;
import kotlinx.coroutines.CoroutineScopeKt;
import kotlinx.coroutines.Dispatchers;
import kotlinx.coroutines.ExecutorsKt;

/* JADX INFO: compiled from: com.google.android.recaptcha:recaptcha@@18.6.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzbi {
    private final CoroutineScope zza = CoroutineScopeKt.MainScope();
    private final CoroutineScope zzb;
    private final CoroutineScope zzc;
    private final CoroutineScope zzd;

    public zzbi() {
        CoroutineScope CoroutineScope = CoroutineScopeKt.CoroutineScope(ExecutorsKt.from(Executors.newSingleThreadExecutor()));
        BuildersKt__Builders_commonKt.launch$default(CoroutineScope, null, null, new zzbh(null), 3, null);
        this.zzb = CoroutineScope;
        this.zzc = CoroutineScopeKt.CoroutineScope(Dispatchers.getIO());
        CoroutineScope CoroutineScope2 = CoroutineScopeKt.CoroutineScope(ExecutorsKt.from(Executors.newSingleThreadExecutor()));
        BuildersKt__Builders_commonKt.launch$default(CoroutineScope2, null, null, new zzbg(null), 3, null);
        this.zzd = CoroutineScope2;
    }

    public final CoroutineScope zza() {
        return this.zzc;
    }

    public final CoroutineScope zzb() {
        return this.zza;
    }

    public final CoroutineScope zzc() {
        return this.zzd;
    }

    public final CoroutineScope zzd() {
        return this.zzb;
    }
}
