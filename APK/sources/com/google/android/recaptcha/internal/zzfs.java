package com.google.android.recaptcha.internal;

import kotlin.Unit;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.jvm.internal.SuspendLambda;
import kotlin.jvm.functions.Function2;
import kotlinx.coroutines.CoroutineScope;

/* JADX INFO: compiled from: com.google.android.recaptcha:recaptcha@@18.6.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zzfs extends SuspendLambda implements Function2 {
    Object zza;
    Object zzb;
    int zzc;
    final /* synthetic */ zzgd zzd;
    final /* synthetic */ zzft zze;
    final /* synthetic */ String zzf;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    zzfs(zzgd zzgdVar, zzft zzftVar, String str, Continuation continuation) {
        super(2, continuation);
        this.zzd = zzgdVar;
        this.zze = zzftVar;
        this.zzf = str;
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Continuation create(Object obj, Continuation continuation) {
        return new zzfs(this.zzd, this.zze, this.zzf, continuation);
    }

    @Override // kotlin.jvm.functions.Function2
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return ((zzfs) create((CoroutineScope) obj, (Continuation) obj2)).invokeSuspend(Unit.INSTANCE);
    }

    /* JADX WARN: Code restructure failed: missing block: B:17:0x0086, code lost:
    
        if (r7.zze.zzh(r8, r7.zzd, r7) != r0) goto L19;
     */
    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final java.lang.Object invokeSuspend(java.lang.Object r8) {
        /*
            r7 = this;
            java.lang.Object r0 = kotlin.coroutines.intrinsics.IntrinsicsKt.getCOROUTINE_SUSPENDED()
            int r1 = r7.zzc
            r2 = 1
            if (r1 == 0) goto L1c
            if (r1 == r2) goto L10
            kotlin.ResultKt.throwOnFailure(r8)
            goto L89
        L10:
            java.lang.Object r1 = r7.zzb
            com.google.android.recaptcha.internal.zzjh r1 = (com.google.android.recaptcha.internal.zzjh) r1
            java.lang.Object r2 = r7.zza
            com.google.android.recaptcha.internal.zzub r2 = (com.google.android.recaptcha.internal.zzub) r2
            kotlin.ResultKt.throwOnFailure(r8)     // Catch: java.lang.Exception -> L72
            goto L62
        L1c:
            kotlin.ResultKt.throwOnFailure(r8)
            com.google.android.recaptcha.internal.zzgd r8 = r7.zzd
            com.google.android.recaptcha.internal.zzbn r1 = new com.google.android.recaptcha.internal.zzbn
            r1.<init>()
            r8.zza = r1
            java.lang.String r8 = r7.zzf     // Catch: java.lang.Exception -> L72
            com.google.android.recaptcha.internal.zzkh r1 = com.google.android.recaptcha.internal.zzkh.zzh()     // Catch: java.lang.Exception -> L72
            java.lang.CharSequence r8 = (java.lang.CharSequence) r8     // Catch: java.lang.Exception -> L72
            byte[] r8 = r1.zzj(r8)     // Catch: java.lang.Exception -> L72
            com.google.android.recaptcha.internal.zzub r8 = com.google.android.recaptcha.internal.zzub.zzi(r8)     // Catch: java.lang.Exception -> L72
            r8.zzf()     // Catch: java.lang.Exception -> L72
            com.google.android.recaptcha.internal.zzft r1 = r7.zze     // Catch: java.lang.Exception -> L72
            com.google.android.recaptcha.internal.zzhx r1 = com.google.android.recaptcha.internal.zzft.zzb(r1)     // Catch: java.lang.Exception -> L72
            com.google.android.recaptcha.internal.zztz r1 = r1.zza(r8)     // Catch: java.lang.Exception -> L72
            com.google.android.recaptcha.internal.zzjh r3 = com.google.android.recaptcha.internal.zzjh.zzb()     // Catch: java.lang.Exception -> L72
            com.google.android.recaptcha.internal.zzft r4 = r7.zze     // Catch: java.lang.Exception -> L72
            java.util.List r1 = r1.zzi()     // Catch: java.lang.Exception -> L72
            com.google.android.recaptcha.internal.zzgd r5 = r7.zzd     // Catch: java.lang.Exception -> L72
            r6 = r7
            kotlin.coroutines.Continuation r6 = (kotlin.coroutines.Continuation) r6     // Catch: java.lang.Exception -> L72
            r7.zza = r8     // Catch: java.lang.Exception -> L72
            r7.zzb = r3     // Catch: java.lang.Exception -> L72
            r7.zzc = r2     // Catch: java.lang.Exception -> L72
            java.lang.Object r1 = com.google.android.recaptcha.internal.zzft.zzc(r4, r1, r5, r6)     // Catch: java.lang.Exception -> L72
            if (r1 == r0) goto L88
            r2 = r8
            r1 = r3
        L62:
            r1.zzf()     // Catch: java.lang.Exception -> L72
            java.util.concurrent.TimeUnit r8 = java.util.concurrent.TimeUnit.MICROSECONDS     // Catch: java.lang.Exception -> L72
            long r3 = r1.zza(r8)     // Catch: java.lang.Exception -> L72
            kotlin.coroutines.jvm.internal.Boxing.boxLong(r3)     // Catch: java.lang.Exception -> L72
            r2.zzf()     // Catch: java.lang.Exception -> L72
            goto L89
        L72:
            r8 = move-exception
            com.google.android.recaptcha.internal.zzft r1 = r7.zze
            com.google.android.recaptcha.internal.zzgd r2 = r7.zzd
            r3 = r7
            kotlin.coroutines.Continuation r3 = (kotlin.coroutines.Continuation) r3
            r4 = 0
            r7.zza = r4
            r7.zzb = r4
            r4 = 2
            r7.zzc = r4
            java.lang.Object r8 = com.google.android.recaptcha.internal.zzft.zzd(r1, r8, r2, r3)
            if (r8 != r0) goto L89
        L88:
            return r0
        L89:
            kotlin.Unit r8 = kotlin.Unit.INSTANCE
            return r8
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.recaptcha.internal.zzfs.invokeSuspend(java.lang.Object):java.lang.Object");
    }
}
