package com.google.android.recaptcha.internal;

import kotlin.ResultKt;
import kotlin.Unit;
import kotlin.coroutines.Continuation;
import kotlin.coroutines.intrinsics.IntrinsicsKt;
import kotlin.coroutines.jvm.internal.Boxing;
import kotlin.coroutines.jvm.internal.SuspendLambda;
import kotlin.jvm.functions.Function1;
import kotlinx.coroutines.CompletableDeferred;

/* JADX INFO: compiled from: com.google.android.recaptcha:recaptcha@@18.6.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zzea extends SuspendLambda implements Function1 {
    Object zza;
    int zzb;
    final /* synthetic */ zzec zzc;
    final /* synthetic */ long zzd;
    final /* synthetic */ CompletableDeferred zze;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    zzea(zzec zzecVar, long j, CompletableDeferred completableDeferred, Continuation continuation) {
        super(1, continuation);
        this.zzc = zzecVar;
        this.zzd = j;
        this.zze = completableDeferred;
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Continuation create(Continuation continuation) {
        return new zzea(this.zzc, this.zzd, this.zze, continuation);
    }

    @Override // kotlin.jvm.functions.Function1
    public final /* bridge */ /* synthetic */ Object invoke(Object obj) {
        return ((zzea) create((Continuation) obj)).invokeSuspend(Unit.INSTANCE);
    }

    @Override // kotlin.coroutines.jvm.internal.BaseContinuationImpl
    public final Object invokeSuspend(Object obj) throws zzbd {
        zzen zzenVar;
        zzbd e;
        zzen zzenVar2;
        Object coroutine_suspended = IntrinsicsKt.getCOROUTINE_SUSPENDED();
        int i = this.zzb;
        if (i == 0) {
            ResultKt.throwOnFailure(obj);
            zzen zzenVarZzf = this.zzc.zzb.zzf(41);
            try {
                this.zza = zzenVarZzf;
                this.zzb = 1;
                Object objZzo = this.zzc.zza.zzo(this.zzd, this);
                if (objZzo != coroutine_suspended) {
                    zzenVar2 = zzenVarZzf;
                    obj = objZzo;
                }
                return coroutine_suspended;
            } catch (zzbd e2) {
                zzenVar = zzenVarZzf;
                e = e2;
                this.zzc.zzd = e;
                zzenVar.zzb(e);
                throw e;
            }
        }
        if (i != 1) {
            zzenVar = (zzen) this.zza;
            try {
                ResultKt.throwOnFailure(obj);
                zzenVar.zza();
                this.zzc.zzf = zzcm.zzb;
                return Boxing.boxBoolean(this.zze.complete(Unit.INSTANCE));
            } catch (zzbd e3) {
                e = e3;
                this.zzc.zzd = e;
                zzenVar.zzb(e);
                throw e;
            }
        }
        zzenVar2 = (zzen) this.zza;
        try {
            ResultKt.throwOnFailure(obj);
        } catch (zzbd e4) {
            e = e4;
            zzenVar = zzenVar2;
            this.zzc.zzd = e;
            zzenVar.zzb(e);
            throw e;
        }
        zzsc zzscVar = (zzsc) obj;
        this.zzc.zze = zzscVar;
        this.zza = zzenVar2;
        this.zzb = 2;
        if (this.zzc.zza.zzn(zzscVar, this.zzd, this) != coroutine_suspended) {
            zzenVar = zzenVar2;
            zzenVar.zza();
            this.zzc.zzf = zzcm.zzb;
            return Boxing.boxBoolean(this.zze.complete(Unit.INSTANCE));
        }
        return coroutine_suspended;
    }
}
