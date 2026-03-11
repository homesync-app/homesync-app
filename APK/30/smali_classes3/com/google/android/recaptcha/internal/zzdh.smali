.class final Lcom/google/android/recaptcha/internal/zzdh;
.super Lkotlin/coroutines/jvm/internal/SuspendLambda;
.source "com.google.android.recaptcha:recaptcha@@18.6.1"

# interfaces
.implements Lkotlin/jvm/functions/Function2;


# instance fields
.field zza:I

.field final synthetic zzb:Lcom/google/android/recaptcha/internal/zzdt;


# direct methods
.method constructor <init>(Lcom/google/android/recaptcha/internal/zzdt;Lkotlin/coroutines/Continuation;)V
    .locals 0

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzdh;->zzb:Lcom/google/android/recaptcha/internal/zzdt;

    const/4 p1, 0x2

    invoke-direct {p0, p1, p2}, Lkotlin/coroutines/jvm/internal/SuspendLambda;-><init>(ILkotlin/coroutines/Continuation;)V

    return-void
.end method


# virtual methods
.method public final create(Ljava/lang/Object;Lkotlin/coroutines/Continuation;)Lkotlin/coroutines/Continuation;
    .locals 1

    new-instance p1, Lcom/google/android/recaptcha/internal/zzdh;

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzdh;->zzb:Lcom/google/android/recaptcha/internal/zzdt;

    invoke-direct {p1, v0, p2}, Lcom/google/android/recaptcha/internal/zzdh;-><init>(Lcom/google/android/recaptcha/internal/zzdt;Lkotlin/coroutines/Continuation;)V

    check-cast p1, Lkotlin/coroutines/Continuation;

    return-object p1
.end method

.method public final bridge synthetic invoke(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    .locals 0

    check-cast p1, Lkotlinx/coroutines/CoroutineScope;

    check-cast p2, Lkotlin/coroutines/Continuation;

    .line 1
    invoke-virtual {p0, p1, p2}, Lcom/google/android/recaptcha/internal/zzdh;->create(Ljava/lang/Object;Lkotlin/coroutines/Continuation;)Lkotlin/coroutines/Continuation;

    move-result-object p1

    check-cast p1, Lcom/google/android/recaptcha/internal/zzdh;

    sget-object p2, Lkotlin/Unit;->INSTANCE:Lkotlin/Unit;

    invoke-virtual {p1, p2}, Lcom/google/android/recaptcha/internal/zzdh;->invokeSuspend(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method

.method public final invokeSuspend(Ljava/lang/Object;)Ljava/lang/Object;
    .locals 7

    .line 1
    invoke-static {}, Lkotlin/coroutines/intrinsics/IntrinsicsKt;->getCOROUTINE_SUSPENDED()Ljava/lang/Object;

    move-result-object v0

    iget v1, p0, Lcom/google/android/recaptcha/internal/zzdh;->zza:I

    invoke-static {p1}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V

    if-eqz v1, :cond_0

    return-object p1

    :cond_0
    new-instance p1, Lcom/google/android/recaptcha/internal/zzbs;

    .line 2
    invoke-static {}, Lcom/google/android/gms/common/GoogleApiAvailabilityLight;->getInstance()Lcom/google/android/gms/common/GoogleApiAvailabilityLight;

    move-result-object v1

    invoke-direct {p1, v1}, Lcom/google/android/recaptcha/internal/zzbs;-><init>(Lcom/google/android/gms/common/GoogleApiAvailabilityLight;)V

    iget-object v1, p0, Lcom/google/android/recaptcha/internal/zzdh;->zzb:Lcom/google/android/recaptcha/internal/zzdt;

    .line 3
    invoke-static {v1}, Lcom/google/android/recaptcha/internal/zzdt;->zza(Lcom/google/android/recaptcha/internal/zzdt;)Landroid/app/Application;

    move-result-object v1

    check-cast v1, Landroid/content/Context;

    invoke-virtual {p1, v1}, Lcom/google/android/recaptcha/internal/zzbs;->zza(Landroid/content/Context;)I

    move-result p1

    iget-object v1, p0, Lcom/google/android/recaptcha/internal/zzdh;->zzb:Lcom/google/android/recaptcha/internal/zzdt;

    invoke-static {v1}, Lcom/google/android/recaptcha/internal/zzdt;->zzp(Lcom/google/android/recaptcha/internal/zzdt;)Ljava/lang/String;

    move-result-object v2

    .line 4
    invoke-static {v1}, Lcom/google/android/recaptcha/internal/zzdt;->zza(Lcom/google/android/recaptcha/internal/zzdt;)Landroid/app/Application;

    move-result-object v1

    invoke-virtual {v1}, Landroid/app/Application;->getPackageName()Ljava/lang/String;

    move-result-object v1

    iget-object v3, p0, Lcom/google/android/recaptcha/internal/zzdh;->zzb:Lcom/google/android/recaptcha/internal/zzdt;

    invoke-static {v3}, Lcom/google/android/recaptcha/internal/zzdt;->zze(Lcom/google/android/recaptcha/internal/zzdt;)Lcom/google/android/recaptcha/internal/zzek;

    move-result-object v3

    .line 5
    invoke-virtual {v3}, Lcom/google/android/recaptcha/internal/zzek;->zzd()Ljava/lang/String;

    move-result-object v3

    iget-object v4, p0, Lcom/google/android/recaptcha/internal/zzdh;->zzb:Lcom/google/android/recaptcha/internal/zzdt;

    .line 6
    invoke-static {v4}, Lcom/google/android/recaptcha/internal/zzdt;->zzc(Lcom/google/android/recaptcha/internal/zzdt;)Lcom/google/android/recaptcha/internal/zzbf;

    move-result-object v4

    sget v5, Landroid/os/Build$VERSION;->SDK_INT:I

    .line 7
    invoke-virtual {v4}, Lcom/google/android/recaptcha/internal/zzbf;->zza()Ljava/lang/String;

    move-result-object v4

    .line 8
    invoke-static {}, Lcom/google/android/recaptcha/internal/zzto;->zzf()Lcom/google/android/recaptcha/internal/zztn;

    move-result-object v6

    .line 9
    invoke-virtual {v6, v2}, Lcom/google/android/recaptcha/internal/zztn;->zzt(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zztn;

    .line 10
    invoke-virtual {v6, v1}, Lcom/google/android/recaptcha/internal/zztn;->zzq(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zztn;

    .line 11
    invoke-virtual {v6, p1}, Lcom/google/android/recaptcha/internal/zztn;->zzu(I)Lcom/google/android/recaptcha/internal/zztn;

    const-string p1, "18.6.1"

    .line 12
    invoke-virtual {v6, p1}, Lcom/google/android/recaptcha/internal/zztn;->zzr(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zztn;

    .line 13
    invoke-virtual {v6, v3}, Lcom/google/android/recaptcha/internal/zztn;->zzs(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zztn;

    .line 14
    invoke-static {v5}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v6, p1}, Lcom/google/android/recaptcha/internal/zztn;->zzf(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zztn;

    .line 15
    invoke-virtual {v6, v4}, Lcom/google/android/recaptcha/internal/zztn;->zze(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zztn;

    .line 16
    invoke-virtual {v6}, Lcom/google/android/recaptcha/internal/zzmx;->zzi()Lcom/google/android/recaptcha/internal/zznd;

    move-result-object p1

    check-cast p1, Lcom/google/android/recaptcha/internal/zzto;

    iget-object v1, p0, Lcom/google/android/recaptcha/internal/zzdh;->zzb:Lcom/google/android/recaptcha/internal/zzdt;

    .line 17
    invoke-static {v1}, Lcom/google/android/recaptcha/internal/zzdt;->zzg(Lcom/google/android/recaptcha/internal/zzdt;)Lcom/google/android/recaptcha/internal/zzff;

    move-result-object v2

    invoke-static {v1}, Lcom/google/android/recaptcha/internal/zzdt;->zzd(Lcom/google/android/recaptcha/internal/zzdt;)Lcom/google/android/recaptcha/internal/zzbr;

    move-result-object v1

    invoke-virtual {v1}, Lcom/google/android/recaptcha/internal/zzbr;->zzb()Ljava/lang/String;

    move-result-object v1

    move-object v3, p0

    check-cast v3, Lkotlin/coroutines/Continuation;

    const/4 v4, 0x1

    iput v4, p0, Lcom/google/android/recaptcha/internal/zzdh;->zza:I

    invoke-virtual {v2, v1, p1, v3}, Lcom/google/android/recaptcha/internal/zzff;->zzc(Ljava/lang/String;Lcom/google/android/recaptcha/internal/zzto;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object p1

    if-ne p1, v0, :cond_1

    return-object v0

    :cond_1
    return-object p1
.end method
