.class public final Lcom/google/android/recaptcha/internal/zzja;
.super Lcom/google/android/recaptcha/internal/zze;
.source "com.google.android.recaptcha:recaptcha@@18.6.1"


# instance fields
.field public zza:Lkotlinx/coroutines/CompletableDeferred;

.field public zzb:Lcom/google/android/recaptcha/internal/zzfo;

.field private final zzc:Lcom/google/android/recaptcha/internal/zzek;

.field private final zzd:Ljava/util/Map;

.field private final zze:Ljava/util/Map;

.field private zzf:Lcom/google/android/recaptcha/internal/zzsc;

.field private final zzg:Lcom/google/android/recaptcha/internal/zzcb;

.field private final zzh:Lcom/google/android/recaptcha/internal/zzjh;

.field private final zzi:Lcom/google/android/recaptcha/internal/zzij;

.field private final zzj:Lcom/google/android/recaptcha/internal/zzek;

.field private final zzk:Lkotlin/Lazy;

.field private final zzl:Lkotlin/Lazy;

.field private final zzm:Lkotlin/Lazy;

.field private final zzn:Lkotlin/Lazy;

.field private final zzo:Lkotlin/Lazy;

.field private zzp:Lcom/google/android/recaptcha/internal/zzen;

.field private final zzq:Lcom/google/android/recaptcha/internal/zzbi;


# direct methods
.method public constructor <init>(Lcom/google/android/recaptcha/internal/zzek;Lcom/google/android/recaptcha/internal/zzbi;)V
    .locals 1

    .line 1
    invoke-direct {p0}, Lcom/google/android/recaptcha/internal/zze;-><init>()V

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzja;->zzc:Lcom/google/android/recaptcha/internal/zzek;

    iput-object p2, p0, Lcom/google/android/recaptcha/internal/zzja;->zzq:Lcom/google/android/recaptcha/internal/zzbi;

    invoke-static {}, Lcom/google/android/recaptcha/internal/zzjb;->zza()Ljava/util/Map;

    move-result-object p2

    iput-object p2, p0, Lcom/google/android/recaptcha/internal/zzja;->zzd:Ljava/util/Map;

    new-instance p2, Ljava/util/LinkedHashMap;

    .line 2
    invoke-direct {p2}, Ljava/util/LinkedHashMap;-><init>()V

    check-cast p2, Ljava/util/Map;

    iput-object p2, p0, Lcom/google/android/recaptcha/internal/zzja;->zze:Ljava/util/Map;

    new-instance p2, Lcom/google/android/recaptcha/internal/zzcb;

    sget-object v0, Lcom/google/android/recaptcha/internal/zzje;->zza:Lcom/google/android/recaptcha/internal/zzje;

    .line 3
    invoke-direct {p2, v0}, Lcom/google/android/recaptcha/internal/zzcb;-><init>(Ljava/lang/Object;)V

    iput-object p2, p0, Lcom/google/android/recaptcha/internal/zzja;->zzg:Lcom/google/android/recaptcha/internal/zzcb;

    invoke-static {}, Lcom/google/android/recaptcha/internal/zzjh;->zzc()Lcom/google/android/recaptcha/internal/zzjh;

    move-result-object p2

    iput-object p2, p0, Lcom/google/android/recaptcha/internal/zzja;->zzh:Lcom/google/android/recaptcha/internal/zzjh;

    new-instance p2, Lcom/google/android/recaptcha/internal/zzij;

    .line 4
    invoke-direct {p2, p0}, Lcom/google/android/recaptcha/internal/zzij;-><init>(Lcom/google/android/recaptcha/internal/zzja;)V

    iput-object p2, p0, Lcom/google/android/recaptcha/internal/zzja;->zzi:Lcom/google/android/recaptcha/internal/zzij;

    .line 5
    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzek;->zza()Lcom/google/android/recaptcha/internal/zzek;

    move-result-object p2

    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzek;->zzd()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {p2, p1}, Lcom/google/android/recaptcha/internal/zzek;->zzc(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zzek;

    iput-object p2, p0, Lcom/google/android/recaptcha/internal/zzja;->zzj:Lcom/google/android/recaptcha/internal/zzek;

    .line 6
    sget p1, Lcom/google/android/recaptcha/internal/zzav;->zza:I

    .line 7
    sget-object p1, Lcom/google/android/recaptcha/internal/zzis;->zza:Lcom/google/android/recaptcha/internal/zzis;

    check-cast p1, Lkotlin/jvm/functions/Function0;

    invoke-static {p1}, Lkotlin/LazyKt;->lazy(Lkotlin/jvm/functions/Function0;)Lkotlin/Lazy;

    move-result-object p1

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzja;->zzk:Lkotlin/Lazy;

    .line 8
    sget-object p1, Lcom/google/android/recaptcha/internal/zzit;->zza:Lcom/google/android/recaptcha/internal/zzit;

    check-cast p1, Lkotlin/jvm/functions/Function0;

    invoke-static {p1}, Lkotlin/LazyKt;->lazy(Lkotlin/jvm/functions/Function0;)Lkotlin/Lazy;

    move-result-object p1

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzja;->zzl:Lkotlin/Lazy;

    .line 9
    sget-object p1, Lcom/google/android/recaptcha/internal/zziu;->zza:Lcom/google/android/recaptcha/internal/zziu;

    check-cast p1, Lkotlin/jvm/functions/Function0;

    invoke-static {p1}, Lkotlin/LazyKt;->lazy(Lkotlin/jvm/functions/Function0;)Lkotlin/Lazy;

    move-result-object p1

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzja;->zzm:Lkotlin/Lazy;

    .line 10
    sget-object p1, Lcom/google/android/recaptcha/internal/zziv;->zza:Lcom/google/android/recaptcha/internal/zziv;

    check-cast p1, Lkotlin/jvm/functions/Function0;

    invoke-static {p1}, Lkotlin/LazyKt;->lazy(Lkotlin/jvm/functions/Function0;)Lkotlin/Lazy;

    move-result-object p1

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzja;->zzn:Lkotlin/Lazy;

    .line 11
    sget-object p1, Lcom/google/android/recaptcha/internal/zziw;->zza:Lcom/google/android/recaptcha/internal/zziw;

    check-cast p1, Lkotlin/jvm/functions/Function0;

    invoke-static {p1}, Lkotlin/LazyKt;->lazy(Lkotlin/jvm/functions/Function0;)Lkotlin/Lazy;

    move-result-object p1

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzja;->zzo:Lkotlin/Lazy;

    return-void
.end method

.method public static final synthetic zzB(Lcom/google/android/recaptcha/internal/zzja;Lcom/google/android/recaptcha/internal/zzen;)V
    .locals 0

    const/4 p1, 0x0

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzja;->zzp:Lcom/google/android/recaptcha/internal/zzen;

    return-void
.end method

.method private final zzD()Landroid/app/Application;
    .locals 1

    .line 1
    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzja;->zzo:Lkotlin/Lazy;

    invoke-interface {v0}, Lkotlin/Lazy;->getValue()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/app/Application;

    return-object v0
.end method

.method private final zzE(Lcom/google/android/recaptcha/internal/zzsc;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
    .locals 7

    instance-of v0, p2, Lcom/google/android/recaptcha/internal/zzim;

    if-eqz v0, :cond_0

    move-object v0, p2

    check-cast v0, Lcom/google/android/recaptcha/internal/zzim;

    .line 1
    iget v1, v0, Lcom/google/android/recaptcha/internal/zzim;->zzc:I

    const/high16 v2, -0x80000000

    and-int v3, v1, v2

    if-eqz v3, :cond_0

    sub-int/2addr v1, v2

    iput v1, v0, Lcom/google/android/recaptcha/internal/zzim;->zzc:I

    goto :goto_0

    .line 3
    :cond_0
    new-instance v0, Lcom/google/android/recaptcha/internal/zzim;

    invoke-direct {v0, p0, p2}, Lcom/google/android/recaptcha/internal/zzim;-><init>(Lcom/google/android/recaptcha/internal/zzja;Lkotlin/coroutines/Continuation;)V

    .line 1
    :goto_0
    iget-object p2, v0, Lcom/google/android/recaptcha/internal/zzim;->zza:Ljava/lang/Object;

    invoke-static {}, Lkotlin/coroutines/intrinsics/IntrinsicsKt;->getCOROUTINE_SUSPENDED()Ljava/lang/Object;

    move-result-object v1

    iget v2, v0, Lcom/google/android/recaptcha/internal/zzim;->zzc:I

    const/4 v3, 0x1

    if-eqz v2, :cond_2

    if-ne v2, v3, :cond_1

    iget-object p1, v0, Lcom/google/android/recaptcha/internal/zzim;->zzd:Lcom/google/android/recaptcha/internal/zzja;

    move-object v0, p1

    check-cast v0, Lcom/google/android/recaptcha/internal/zzja;

    :try_start_0
    invoke-static {p2}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V
    :try_end_0
    .catch Lcom/google/android/recaptcha/internal/zzbd; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_1

    :catch_0
    move-exception v0

    move-object p2, v0

    goto :goto_2

    .line 3
    :cond_1
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string p2, "call to \'resume\' before \'invoke\' with coroutine"

    .line 1
    invoke-direct {p1, p2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1

    :cond_2
    invoke-static {p2}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V

    :try_start_1
    iget-object p2, p0, Lcom/google/android/recaptcha/internal/zzja;->zzn:Lkotlin/Lazy;

    .line 2
    invoke-interface {p2}, Lkotlin/Lazy;->getValue()Ljava/lang/Object;

    move-result-object p2

    check-cast p2, Lcom/google/android/recaptcha/internal/zzff;

    iget-object v2, p0, Lcom/google/android/recaptcha/internal/zzja;->zzj:Lcom/google/android/recaptcha/internal/zzek;

    iput-object p0, v0, Lcom/google/android/recaptcha/internal/zzim;->zzd:Lcom/google/android/recaptcha/internal/zzja;

    iput v3, v0, Lcom/google/android/recaptcha/internal/zzim;->zzc:I

    .line 3
    invoke-virtual {p2, p1, v2, v0}, Lcom/google/android/recaptcha/internal/zzff;->zzd(Lcom/google/android/recaptcha/internal/zzsc;Lcom/google/android/recaptcha/internal/zzek;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object p2
    :try_end_1
    .catch Lcom/google/android/recaptcha/internal/zzbd; {:try_start_1 .. :try_end_1} :catch_1

    if-ne p2, v1, :cond_3

    return-object v1

    :cond_3
    move-object p1, p0

    .line 1
    :goto_1
    :try_start_2
    check-cast p2, Ljava/lang/String;

    .line 4
    iget-object v0, p1, Lcom/google/android/recaptcha/internal/zzja;->zzq:Lcom/google/android/recaptcha/internal/zzbi;

    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzbi;->zzb()Lkotlinx/coroutines/CoroutineScope;

    move-result-object v1

    new-instance v0, Lcom/google/android/recaptcha/internal/zzin;

    const/4 v2, 0x0

    invoke-direct {v0, p1, p2, v2}, Lcom/google/android/recaptcha/internal/zzin;-><init>(Lcom/google/android/recaptcha/internal/zzja;Ljava/lang/String;Lkotlin/coroutines/Continuation;)V

    move-object v4, v0

    check-cast v4, Lkotlin/jvm/functions/Function2;

    const/4 v5, 0x3

    const/4 v6, 0x0

    const/4 v2, 0x0

    const/4 v3, 0x0

    invoke-static/range {v1 .. v6}, Lkotlinx/coroutines/BuildersKt;->launch$default(Lkotlinx/coroutines/CoroutineScope;Lkotlin/coroutines/CoroutineContext;Lkotlinx/coroutines/CoroutineStart;Lkotlin/jvm/functions/Function2;ILjava/lang/Object;)Lkotlinx/coroutines/Job;
    :try_end_2
    .catch Lcom/google/android/recaptcha/internal/zzbd; {:try_start_2 .. :try_end_2} :catch_0

    goto :goto_3

    :catch_1
    move-exception v0

    move-object p1, v0

    move-object p2, p1

    move-object p1, p0

    .line 5
    :goto_2
    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzja;->zzA()Lkotlinx/coroutines/CompletableDeferred;

    move-result-object p1

    check-cast p2, Ljava/lang/Throwable;

    invoke-interface {p1, p2}, Lkotlinx/coroutines/CompletableDeferred;->completeExceptionally(Ljava/lang/Throwable;)Z

    .line 6
    :goto_3
    sget-object p1, Lkotlin/Unit;->INSTANCE:Lkotlin/Unit;

    return-object p1
.end method

.method private final zzF(Ljava/lang/String;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
    .locals 8

    instance-of v0, p2, Lcom/google/android/recaptcha/internal/zzio;

    if-eqz v0, :cond_0

    move-object v0, p2

    check-cast v0, Lcom/google/android/recaptcha/internal/zzio;

    .line 1
    iget v1, v0, Lcom/google/android/recaptcha/internal/zzio;->zzc:I

    const/high16 v2, -0x80000000

    and-int v3, v1, v2

    if-eqz v3, :cond_0

    sub-int/2addr v1, v2

    iput v1, v0, Lcom/google/android/recaptcha/internal/zzio;->zzc:I

    goto :goto_0

    .line 5
    :cond_0
    new-instance v0, Lcom/google/android/recaptcha/internal/zzio;

    invoke-direct {v0, p0, p2}, Lcom/google/android/recaptcha/internal/zzio;-><init>(Lcom/google/android/recaptcha/internal/zzja;Lkotlin/coroutines/Continuation;)V

    .line 1
    :goto_0
    iget-object p2, v0, Lcom/google/android/recaptcha/internal/zzio;->zza:Ljava/lang/Object;

    invoke-static {}, Lkotlin/coroutines/intrinsics/IntrinsicsKt;->getCOROUTINE_SUSPENDED()Ljava/lang/Object;

    move-result-object v1

    iget v2, v0, Lcom/google/android/recaptcha/internal/zzio;->zzc:I

    const/4 v3, 0x1

    if-eqz v2, :cond_2

    if-ne v2, v3, :cond_1

    iget-object p1, v0, Lcom/google/android/recaptcha/internal/zzio;->zzf:Ljava/lang/String;

    move-object v1, p1

    check-cast v1, Ljava/lang/String;

    iget-object v1, v0, Lcom/google/android/recaptcha/internal/zzio;->zze:Ljava/lang/String;

    move-object v2, v1

    check-cast v2, Ljava/lang/String;

    iget-object v2, v0, Lcom/google/android/recaptcha/internal/zzio;->zzd:Lcom/google/android/recaptcha/internal/zzja;

    move-object v0, v2

    check-cast v0, Lcom/google/android/recaptcha/internal/zzja;

    :try_start_0
    invoke-static {p2}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    move-object v3, p1

    move-object v4, v1

    move-object p1, v2

    goto :goto_1

    :catch_0
    move-exception v0

    move-object p1, v0

    goto :goto_2

    .line 5
    :cond_1
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string p2, "call to \'resume\' before \'invoke\' with coroutine"

    .line 1
    invoke-direct {p1, p2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1

    :cond_2
    invoke-static {p2}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V

    iget-object p2, p0, Lcom/google/android/recaptcha/internal/zzja;->zzj:Lcom/google/android/recaptcha/internal/zzek;

    const/16 v2, 0x1a

    .line 2
    invoke-virtual {p2, v2}, Lcom/google/android/recaptcha/internal/zzek;->zzf(I)Lcom/google/android/recaptcha/internal/zzen;

    move-result-object p2

    iput-object p2, p0, Lcom/google/android/recaptcha/internal/zzja;->zzp:Lcom/google/android/recaptcha/internal/zzen;

    :try_start_1
    iget-object p2, p0, Lcom/google/android/recaptcha/internal/zzja;->zzl:Lkotlin/Lazy;

    .line 3
    invoke-interface {p2}, Lkotlin/Lazy;->getValue()Ljava/lang/Object;

    move-result-object p2

    check-cast p2, Lcom/google/android/recaptcha/internal/zzbr;

    .line 4
    invoke-virtual {p2}, Lcom/google/android/recaptcha/internal/zzbr;->zza()Ljava/lang/String;

    move-result-object p2

    iput-object p0, v0, Lcom/google/android/recaptcha/internal/zzio;->zzd:Lcom/google/android/recaptcha/internal/zzja;

    iput-object p1, v0, Lcom/google/android/recaptcha/internal/zzio;->zze:Ljava/lang/String;

    iput-object p2, v0, Lcom/google/android/recaptcha/internal/zzio;->zzf:Ljava/lang/String;

    iput v3, v0, Lcom/google/android/recaptcha/internal/zzio;->zzc:I

    .line 5
    invoke-virtual {p0, v0}, Lcom/google/android/recaptcha/internal/zzja;->zzw(Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object v0
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_2

    if-eq v0, v1, :cond_3

    move-object v4, p1

    move-object v3, p2

    move-object p2, v0

    move-object p1, p0

    :goto_1
    :try_start_2
    move-object v2, p2

    check-cast v2, Landroid/webkit/WebView;

    const-string v5, "text/html"

    const-string v6, "utf-8"

    const/4 v7, 0x0

    invoke-virtual/range {v2 .. v7}, Landroid/webkit/WebView;->loadDataWithBaseURL(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_1

    goto :goto_3

    :catch_1
    move-exception v0

    move-object p2, v0

    move-object v2, p1

    move-object p1, p2

    goto :goto_2

    :cond_3
    return-object v1

    :catch_2
    move-exception v0

    move-object p1, v0

    move-object v2, p0

    .line 6
    :goto_2
    new-instance p2, Lcom/google/android/recaptcha/internal/zzbd;

    sget-object v0, Lcom/google/android/recaptcha/internal/zzbb;->zzb:Lcom/google/android/recaptcha/internal/zzbb;

    sget-object v1, Lcom/google/android/recaptcha/internal/zzba;->zzU:Lcom/google/android/recaptcha/internal/zzba;

    .line 7
    invoke-virtual {p1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object p1

    .line 8
    invoke-direct {p2, v0, v1, p1}, Lcom/google/android/recaptcha/internal/zzbd;-><init>(Lcom/google/android/recaptcha/internal/zzbb;Lcom/google/android/recaptcha/internal/zzba;Ljava/lang/String;)V

    .line 9
    iget-object p1, v2, Lcom/google/android/recaptcha/internal/zzja;->zzp:Lcom/google/android/recaptcha/internal/zzen;

    if-eqz p1, :cond_4

    invoke-virtual {p1, p2}, Lcom/google/android/recaptcha/internal/zzen;->zzb(Lcom/google/android/recaptcha/internal/zzbd;)V

    :cond_4
    const/4 p1, 0x0

    .line 10
    iput-object p1, v2, Lcom/google/android/recaptcha/internal/zzja;->zzp:Lcom/google/android/recaptcha/internal/zzen;

    .line 11
    invoke-virtual {v2}, Lcom/google/android/recaptcha/internal/zzja;->zzA()Lkotlinx/coroutines/CompletableDeferred;

    move-result-object p1

    check-cast p2, Ljava/lang/Throwable;

    invoke-interface {p1, p2}, Lkotlinx/coroutines/CompletableDeferred;->completeExceptionally(Ljava/lang/Throwable;)Z

    .line 12
    :goto_3
    sget-object p1, Lkotlin/Unit;->INSTANCE:Lkotlin/Unit;

    return-object p1
.end method

.method private final zzG(Ljava/lang/String;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
    .locals 8

    instance-of v0, p2, Lcom/google/android/recaptcha/internal/zzix;

    if-eqz v0, :cond_0

    move-object v0, p2

    check-cast v0, Lcom/google/android/recaptcha/internal/zzix;

    .line 1
    iget v1, v0, Lcom/google/android/recaptcha/internal/zzix;->zzc:I

    const/high16 v2, -0x80000000

    and-int v3, v1, v2

    if-eqz v3, :cond_0

    sub-int/2addr v1, v2

    iput v1, v0, Lcom/google/android/recaptcha/internal/zzix;->zzc:I

    goto :goto_0

    :cond_0
    new-instance v0, Lcom/google/android/recaptcha/internal/zzix;

    invoke-direct {v0, p0, p2}, Lcom/google/android/recaptcha/internal/zzix;-><init>(Lcom/google/android/recaptcha/internal/zzja;Lkotlin/coroutines/Continuation;)V

    :goto_0
    iget-object p2, v0, Lcom/google/android/recaptcha/internal/zzix;->zza:Ljava/lang/Object;

    invoke-static {}, Lkotlin/coroutines/intrinsics/IntrinsicsKt;->getCOROUTINE_SUSPENDED()Ljava/lang/Object;

    move-result-object v1

    iget v2, v0, Lcom/google/android/recaptcha/internal/zzix;->zzc:I

    const/4 v3, 0x2

    const/4 v4, 0x1

    if-eqz v2, :cond_3

    if-eq v2, v4, :cond_2

    if-ne v2, v3, :cond_1

    .line 11
    iget-object p1, v0, Lcom/google/android/recaptcha/internal/zzix;->zze:Ljava/lang/String;

    .line 1
    move-object v1, p1

    check-cast v1, Ljava/lang/String;

    iget-object v0, v0, Lcom/google/android/recaptcha/internal/zzix;->zzd:Lcom/google/android/recaptcha/internal/zzja;

    move-object v1, v0

    check-cast v1, Lcom/google/android/recaptcha/internal/zzja;

    invoke-static {p2}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V

    goto :goto_2

    :cond_1
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string p2, "call to \'resume\' before \'invoke\' with coroutine"

    invoke-direct {p1, p2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1

    :cond_2
    iget-object p1, v0, Lcom/google/android/recaptcha/internal/zzix;->zze:Ljava/lang/String;

    move-object v2, p1

    check-cast v2, Ljava/lang/String;

    iget-object v2, v0, Lcom/google/android/recaptcha/internal/zzix;->zzd:Lcom/google/android/recaptcha/internal/zzja;

    move-object v5, v2

    check-cast v5, Lcom/google/android/recaptcha/internal/zzja;

    invoke-static {p2}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V

    goto :goto_1

    :cond_3
    invoke-static {p2}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V

    iget-object p2, p0, Lcom/google/android/recaptcha/internal/zzja;->zzg:Lcom/google/android/recaptcha/internal/zzcb;

    const/4 v2, 0x3

    new-array v2, v2, [Lcom/google/android/recaptcha/internal/zzje;

    const/4 v5, 0x0

    sget-object v6, Lcom/google/android/recaptcha/internal/zzje;->zzd:Lcom/google/android/recaptcha/internal/zzje;

    aput-object v6, v2, v5

    sget-object v5, Lcom/google/android/recaptcha/internal/zzje;->zzc:Lcom/google/android/recaptcha/internal/zzje;

    aput-object v5, v2, v4

    sget-object v5, Lcom/google/android/recaptcha/internal/zzje;->zzb:Lcom/google/android/recaptcha/internal/zzje;

    aput-object v5, v2, v3

    iput-object p0, v0, Lcom/google/android/recaptcha/internal/zzix;->zzd:Lcom/google/android/recaptcha/internal/zzja;

    iput-object p1, v0, Lcom/google/android/recaptcha/internal/zzix;->zze:Ljava/lang/String;

    iput v4, v0, Lcom/google/android/recaptcha/internal/zzix;->zzc:I

    .line 2
    invoke-virtual {p2, v2, v0}, Lcom/google/android/recaptcha/internal/zzcb;->zzb([Ljava/lang/Object;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object p2

    if-eq p2, v1, :cond_6

    move-object v2, p0

    .line 3
    :goto_1
    check-cast p2, Ljava/lang/Boolean;

    invoke-virtual {p2}, Ljava/lang/Boolean;->booleanValue()Z

    move-result p2

    if-eqz p2, :cond_4

    .line 4
    sget-object p1, Lkotlin/Unit;->INSTANCE:Lkotlin/Unit;

    return-object p1

    .line 5
    :cond_4
    iget-object p2, v2, Lcom/google/android/recaptcha/internal/zzja;->zzg:Lcom/google/android/recaptcha/internal/zzcb;

    sget-object v5, Lcom/google/android/recaptcha/internal/zzje;->zzb:Lcom/google/android/recaptcha/internal/zzje;

    iput-object v2, v0, Lcom/google/android/recaptcha/internal/zzix;->zzd:Lcom/google/android/recaptcha/internal/zzja;

    iput-object p1, v0, Lcom/google/android/recaptcha/internal/zzix;->zze:Ljava/lang/String;

    iput v3, v0, Lcom/google/android/recaptcha/internal/zzix;->zzc:I

    invoke-virtual {p2, v5, v0}, Lcom/google/android/recaptcha/internal/zzcb;->zzc(Ljava/lang/Object;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object p2

    if-ne p2, v1, :cond_5

    goto :goto_3

    :cond_5
    move-object v0, v2

    :goto_2
    const/4 p2, 0x0

    .line 6
    invoke-static {p2, v4, p2}, Lkotlinx/coroutines/CompletableDeferredKt;->CompletableDeferred$default(Lkotlinx/coroutines/Job;ILjava/lang/Object;)Lkotlinx/coroutines/CompletableDeferred;

    move-result-object v1

    iput-object v1, v0, Lcom/google/android/recaptcha/internal/zzja;->zza:Lkotlinx/coroutines/CompletableDeferred;

    .line 7
    iget-object v1, v0, Lcom/google/android/recaptcha/internal/zzja;->zzj:Lcom/google/android/recaptcha/internal/zzek;

    .line 8
    invoke-virtual {v1, p1}, Lcom/google/android/recaptcha/internal/zzek;->zzc(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zzek;

    const/16 p1, 0x2a

    .line 9
    invoke-virtual {v1, p1}, Lcom/google/android/recaptcha/internal/zzek;->zzf(I)Lcom/google/android/recaptcha/internal/zzen;

    move-result-object p1

    .line 10
    iget-object v1, v0, Lcom/google/android/recaptcha/internal/zzja;->zzq:Lcom/google/android/recaptcha/internal/zzbi;

    invoke-virtual {v1}, Lcom/google/android/recaptcha/internal/zzbi;->zza()Lkotlinx/coroutines/CoroutineScope;

    move-result-object v2

    new-instance v1, Lcom/google/android/recaptcha/internal/zziz;

    invoke-direct {v1, v0, p1, p2}, Lcom/google/android/recaptcha/internal/zziz;-><init>(Lcom/google/android/recaptcha/internal/zzja;Lcom/google/android/recaptcha/internal/zzen;Lkotlin/coroutines/Continuation;)V

    move-object v5, v1

    check-cast v5, Lkotlin/jvm/functions/Function2;

    const/4 v6, 0x3

    const/4 v7, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    invoke-static/range {v2 .. v7}, Lkotlinx/coroutines/BuildersKt;->launch$default(Lkotlinx/coroutines/CoroutineScope;Lkotlin/coroutines/CoroutineContext;Lkotlinx/coroutines/CoroutineStart;Lkotlin/jvm/functions/Function2;ILjava/lang/Object;)Lkotlinx/coroutines/Job;

    .line 11
    sget-object p1, Lkotlin/Unit;->INSTANCE:Lkotlin/Unit;

    return-object p1

    :cond_6
    :goto_3
    return-object v1
.end method

.method public static final synthetic zzn(Lcom/google/android/recaptcha/internal/zzja;)Lcom/google/android/recaptcha/internal/zzek;
    .locals 0

    iget-object p0, p0, Lcom/google/android/recaptcha/internal/zzja;->zzj:Lcom/google/android/recaptcha/internal/zzek;

    return-object p0
.end method

.method public static final synthetic zzo(Lcom/google/android/recaptcha/internal/zzja;)Lcom/google/android/recaptcha/internal/zzen;
    .locals 0

    iget-object p0, p0, Lcom/google/android/recaptcha/internal/zzja;->zzp:Lcom/google/android/recaptcha/internal/zzen;

    return-object p0
.end method

.method public static final synthetic zzp(Lcom/google/android/recaptcha/internal/zzja;)Lcom/google/android/recaptcha/internal/zzfk;
    .locals 0

    .line 1
    iget-object p0, p0, Lcom/google/android/recaptcha/internal/zzja;->zzm:Lkotlin/Lazy;

    invoke-interface {p0}, Lkotlin/Lazy;->getValue()Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Lcom/google/android/recaptcha/internal/zzfk;

    return-object p0
.end method

.method public static final synthetic zzr(Lcom/google/android/recaptcha/internal/zzja;)Lcom/google/android/recaptcha/internal/zzjh;
    .locals 0

    .line 1
    iget-object p0, p0, Lcom/google/android/recaptcha/internal/zzja;->zzh:Lcom/google/android/recaptcha/internal/zzjh;

    return-object p0
.end method

.method public static final synthetic zzs(Lcom/google/android/recaptcha/internal/zzja;)Lcom/google/android/recaptcha/internal/zzsc;
    .locals 0

    .line 1
    iget-object p0, p0, Lcom/google/android/recaptcha/internal/zzja;->zzf:Lcom/google/android/recaptcha/internal/zzsc;

    return-object p0
.end method

.method public static final synthetic zzt(Lcom/google/android/recaptcha/internal/zzja;Lcom/google/android/recaptcha/internal/zzsc;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
    .locals 0

    .line 1
    invoke-direct {p0, p1, p2}, Lcom/google/android/recaptcha/internal/zzja;->zzE(Lcom/google/android/recaptcha/internal/zzsc;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object p0

    return-object p0
.end method

.method public static final synthetic zzu(Lcom/google/android/recaptcha/internal/zzja;Ljava/lang/String;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
    .locals 0

    .line 1
    invoke-direct {p0, p1, p2}, Lcom/google/android/recaptcha/internal/zzja;->zzF(Ljava/lang/String;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object p0

    return-object p0
.end method

.method public static final synthetic zzv(Lcom/google/android/recaptcha/internal/zzja;Ljava/lang/String;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
    .locals 0

    const/4 p1, 0x0

    .line 1
    invoke-direct {p0, p1, p2}, Lcom/google/android/recaptcha/internal/zzja;->zzG(Ljava/lang/String;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object p0

    return-object p0
.end method

.method public static final synthetic zzy(Lcom/google/android/recaptcha/internal/zzja;)Ljava/util/Map;
    .locals 0

    iget-object p0, p0, Lcom/google/android/recaptcha/internal/zzja;->zzd:Ljava/util/Map;

    return-object p0
.end method

.method public static final synthetic zzz(Lcom/google/android/recaptcha/internal/zzja;)Ljava/util/Map;
    .locals 0

    iget-object p0, p0, Lcom/google/android/recaptcha/internal/zzja;->zze:Ljava/util/Map;

    return-object p0
.end method


# virtual methods
.method public final zzA()Lkotlinx/coroutines/CompletableDeferred;
    .locals 1

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzja;->zza:Lkotlinx/coroutines/CompletableDeferred;

    if-eqz v0, :cond_0

    return-object v0

    :cond_0
    const/4 v0, 0x0

    return-object v0
.end method

.method public final zzC(Lcom/google/android/recaptcha/internal/zzsc;Lcom/google/android/recaptcha/internal/zzcg;Landroid/webkit/WebView;)Lcom/google/android/recaptcha/internal/zzft;
    .locals 2

    .line 1
    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzja;->zzq:Lcom/google/android/recaptcha/internal/zzbi;

    new-instance v1, Lcom/google/android/recaptcha/internal/zzfw;

    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzbi;->zzb()Lkotlinx/coroutines/CoroutineScope;

    move-result-object v0

    invoke-direct {v1, p3, v0}, Lcom/google/android/recaptcha/internal/zzfw;-><init>(Landroid/webkit/WebView;Lkotlinx/coroutines/CoroutineScope;)V

    new-instance p3, Lcom/google/android/recaptcha/internal/zzhy;

    .line 2
    invoke-direct {p3}, Lcom/google/android/recaptcha/internal/zzhy;-><init>()V

    .line 3
    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzsc;->zzP()Ljava/util/List;

    move-result-object p1

    check-cast p1, Ljava/util/Collection;

    invoke-static {p1}, Lkotlin/collections/CollectionsKt;->toLongArray(Ljava/util/Collection;)[J

    move-result-object p1

    .line 4
    invoke-virtual {p3, p1}, Lcom/google/android/recaptcha/internal/zzhy;->zzb([J)V

    new-instance p1, Lcom/google/android/recaptcha/internal/zzgf;

    .line 5
    move-object v0, v1

    check-cast v0, Lcom/google/android/recaptcha/internal/zzfw;

    new-instance v0, Lcom/google/android/recaptcha/internal/zzbo;

    invoke-direct {v0}, Lcom/google/android/recaptcha/internal/zzbo;-><init>()V

    .line 6
    invoke-direct {p1, v1, p2, v0}, Lcom/google/android/recaptcha/internal/zzgf;-><init>(Lcom/google/android/recaptcha/internal/zzfw;Lcom/google/android/recaptcha/internal/zzcg;Lcom/google/android/recaptcha/internal/zzbo;)V

    new-instance p2, Lcom/google/android/recaptcha/internal/zzhw;

    invoke-direct {p2}, Lcom/google/android/recaptcha/internal/zzhw;-><init>()V

    new-instance v0, Lcom/google/android/recaptcha/internal/zzhz;

    invoke-direct {v0, p3, p2}, Lcom/google/android/recaptcha/internal/zzhz;-><init>(Lcom/google/android/recaptcha/internal/zzhy;Lcom/google/android/recaptcha/internal/zzhw;)V

    const/4 p2, 0x3

    .line 7
    invoke-direct {p0}, Lcom/google/android/recaptcha/internal/zzja;->zzD()Landroid/app/Application;

    move-result-object p3

    .line 8
    invoke-virtual {p1, p2, p3}, Lcom/google/android/recaptcha/internal/zzgf;->zze(ILjava/lang/Object;)V

    const/4 p2, 0x5

    .line 9
    invoke-static {}, Lcom/google/android/recaptcha/internal/zzig;->zza()Ljava/lang/reflect/Method;

    move-result-object p3

    .line 10
    invoke-virtual {p1, p2, p3}, Lcom/google/android/recaptcha/internal/zzgf;->zze(ILjava/lang/Object;)V

    new-instance p2, Lcom/google/android/recaptcha/internal/zzia;

    .line 11
    invoke-direct {p0}, Lcom/google/android/recaptcha/internal/zzja;->zzD()Landroid/app/Application;

    move-result-object p3

    check-cast p3, Landroid/content/Context;

    invoke-direct {p2, p3}, Lcom/google/android/recaptcha/internal/zzia;-><init>(Landroid/content/Context;)V

    const/4 p3, 0x6

    .line 12
    invoke-virtual {p1, p3, p2}, Lcom/google/android/recaptcha/internal/zzgf;->zze(ILjava/lang/Object;)V

    new-instance p2, Lcom/google/android/recaptcha/internal/zzic;

    invoke-direct {p2}, Lcom/google/android/recaptcha/internal/zzic;-><init>()V

    const/4 p3, 0x7

    .line 13
    invoke-virtual {p1, p3, p2}, Lcom/google/android/recaptcha/internal/zzgf;->zze(ILjava/lang/Object;)V

    new-instance p2, Lcom/google/android/recaptcha/internal/zzii;

    .line 14
    invoke-direct {p0}, Lcom/google/android/recaptcha/internal/zzja;->zzD()Landroid/app/Application;

    move-result-object p3

    check-cast p3, Landroid/content/Context;

    invoke-direct {p2, p3}, Lcom/google/android/recaptcha/internal/zzii;-><init>(Landroid/content/Context;)V

    const/16 p3, 0x8

    .line 15
    invoke-virtual {p1, p3, p2}, Lcom/google/android/recaptcha/internal/zzgf;->zze(ILjava/lang/Object;)V

    new-instance p2, Lcom/google/android/recaptcha/internal/zzid;

    .line 16
    invoke-direct {p0}, Lcom/google/android/recaptcha/internal/zzja;->zzD()Landroid/app/Application;

    move-result-object p3

    check-cast p3, Landroid/content/Context;

    invoke-direct {p2, p3}, Lcom/google/android/recaptcha/internal/zzid;-><init>(Landroid/content/Context;)V

    const/16 p3, 0x9

    .line 17
    invoke-virtual {p1, p3, p2}, Lcom/google/android/recaptcha/internal/zzgf;->zze(ILjava/lang/Object;)V

    new-instance p2, Lcom/google/android/recaptcha/internal/zzib;

    .line 18
    invoke-direct {p0}, Lcom/google/android/recaptcha/internal/zzja;->zzD()Landroid/app/Application;

    move-result-object p3

    check-cast p3, Landroid/content/Context;

    invoke-direct {p2, p3}, Lcom/google/android/recaptcha/internal/zzib;-><init>(Landroid/content/Context;)V

    const/16 p3, 0xa

    .line 19
    invoke-virtual {p1, p3, p2}, Lcom/google/android/recaptcha/internal/zzgf;->zze(ILjava/lang/Object;)V

    iget-object p2, p0, Lcom/google/android/recaptcha/internal/zzja;->zzq:Lcom/google/android/recaptcha/internal/zzbi;

    new-instance p3, Lcom/google/android/recaptcha/internal/zzft;

    .line 20
    invoke-virtual {p2}, Lcom/google/android/recaptcha/internal/zzbi;->zzd()Lkotlinx/coroutines/CoroutineScope;

    move-result-object p2

    check-cast v0, Lcom/google/android/recaptcha/internal/zzhx;

    .line 21
    invoke-static {}, Lcom/google/android/recaptcha/internal/zzfn;->zza()Ljava/util/Map;

    move-result-object v1

    invoke-direct {p3, p2, p1, v0, v1}, Lcom/google/android/recaptcha/internal/zzft;-><init>(Lkotlinx/coroutines/CoroutineScope;Lcom/google/android/recaptcha/internal/zzgf;Lcom/google/android/recaptcha/internal/zzhx;Ljava/util/Map;)V

    return-object p3
.end method

.method protected final zza(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zzen;
    .locals 1

    .line 1
    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzja;->zzc:Lcom/google/android/recaptcha/internal/zzek;

    invoke-virtual {v0, p1}, Lcom/google/android/recaptcha/internal/zzek;->zzc(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zzek;

    const/16 p1, 0x21

    .line 2
    invoke-virtual {v0, p1}, Lcom/google/android/recaptcha/internal/zzek;->zzf(I)Lcom/google/android/recaptcha/internal/zzen;

    move-result-object p1

    return-object p1
.end method

.method protected final zzb()Lcom/google/android/recaptcha/internal/zzen;
    .locals 2

    .line 1
    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzja;->zzc:Lcom/google/android/recaptcha/internal/zzek;

    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzek;->zzd()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/google/android/recaptcha/internal/zzek;->zzc(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zzek;

    const/16 v1, 0x20

    .line 2
    invoke-virtual {v0, v1}, Lcom/google/android/recaptcha/internal/zzek;->zzf(I)Lcom/google/android/recaptcha/internal/zzen;

    move-result-object v0

    return-object v0
.end method

.method protected final zzd(Ljava/lang/String;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
    .locals 0

    .line 1
    invoke-static {}, Lcom/google/android/recaptcha/internal/zzsi;->zzf()Lcom/google/android/recaptcha/internal/zzsh;

    move-result-object p2

    invoke-virtual {p2, p1}, Lcom/google/android/recaptcha/internal/zzsh;->zze(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zzsh;

    invoke-virtual {p2}, Lcom/google/android/recaptcha/internal/zzmx;->zzi()Lcom/google/android/recaptcha/internal/zznd;

    move-result-object p1

    return-object p1
.end method

.method protected final zzf(Ljava/lang/String;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
    .locals 17

    move-object/from16 v1, p0

    move-object/from16 v0, p2

    instance-of v2, v0, Lcom/google/android/recaptcha/internal/zzip;

    if-eqz v2, :cond_0

    move-object v2, v0

    check-cast v2, Lcom/google/android/recaptcha/internal/zzip;

    .line 1
    iget v3, v2, Lcom/google/android/recaptcha/internal/zzip;->zzc:I

    const/high16 v4, -0x80000000

    and-int v5, v3, v4

    if-eqz v5, :cond_0

    sub-int/2addr v3, v4

    iput v3, v2, Lcom/google/android/recaptcha/internal/zzip;->zzc:I

    goto :goto_0

    :cond_0
    new-instance v2, Lcom/google/android/recaptcha/internal/zzip;

    invoke-direct {v2, v1, v0}, Lcom/google/android/recaptcha/internal/zzip;-><init>(Lcom/google/android/recaptcha/internal/zzja;Lkotlin/coroutines/Continuation;)V

    :goto_0
    iget-object v0, v2, Lcom/google/android/recaptcha/internal/zzip;->zza:Ljava/lang/Object;

    invoke-static {}, Lkotlin/coroutines/intrinsics/IntrinsicsKt;->getCOROUTINE_SUSPENDED()Ljava/lang/Object;

    move-result-object v3

    iget v4, v2, Lcom/google/android/recaptcha/internal/zzip;->zzc:I

    const/4 v5, 0x5

    const/4 v6, 0x4

    const/4 v7, 0x3

    const/4 v8, 0x2

    const/4 v9, 0x1

    const/4 v10, 0x0

    if-eqz v4, :cond_6

    if-eq v4, v9, :cond_5

    if-eq v4, v8, :cond_4

    if-eq v4, v7, :cond_3

    if-eq v4, v6, :cond_2

    if-ne v4, v5, :cond_1

    .line 25
    iget-object v3, v2, Lcom/google/android/recaptcha/internal/zzip;->zze:Ljava/lang/String;

    .line 1
    move-object v4, v3

    check-cast v4, Ljava/lang/String;

    iget-object v2, v2, Lcom/google/android/recaptcha/internal/zzip;->zzd:Lcom/google/android/recaptcha/internal/zzja;

    move-object v4, v2

    check-cast v4, Lcom/google/android/recaptcha/internal/zzja;

    :try_start_0
    invoke-static {v0}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto/16 :goto_5

    :catch_0
    move-exception v0

    goto/16 :goto_6

    :cond_1
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v2, "call to \'resume\' before \'invoke\' with coroutine"

    invoke-direct {v0, v2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_2
    iget-object v4, v2, Lcom/google/android/recaptcha/internal/zzip;->zze:Ljava/lang/String;

    move-object v6, v4

    check-cast v6, Ljava/lang/String;

    iget-object v6, v2, Lcom/google/android/recaptcha/internal/zzip;->zzd:Lcom/google/android/recaptcha/internal/zzja;

    move-object v7, v6

    check-cast v7, Lcom/google/android/recaptcha/internal/zzja;

    :try_start_1
    invoke-static {v0}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    goto/16 :goto_4

    :catch_1
    move-exception v0

    move-object v3, v4

    move-object v2, v6

    goto/16 :goto_6

    :cond_3
    iget-object v4, v2, Lcom/google/android/recaptcha/internal/zzip;->zze:Ljava/lang/String;

    move-object v7, v4

    check-cast v7, Ljava/lang/String;

    iget-object v7, v2, Lcom/google/android/recaptcha/internal/zzip;->zzd:Lcom/google/android/recaptcha/internal/zzja;

    move-object v8, v7

    check-cast v8, Lcom/google/android/recaptcha/internal/zzja;

    invoke-static {v0}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V

    goto/16 :goto_3

    :cond_4
    iget-object v4, v2, Lcom/google/android/recaptcha/internal/zzip;->zze:Ljava/lang/String;

    move-object v8, v4

    check-cast v8, Ljava/lang/String;

    iget-object v8, v2, Lcom/google/android/recaptcha/internal/zzip;->zzd:Lcom/google/android/recaptcha/internal/zzja;

    move-object v11, v8

    check-cast v11, Lcom/google/android/recaptcha/internal/zzja;

    invoke-static {v0}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V

    goto :goto_2

    :cond_5
    iget-object v4, v2, Lcom/google/android/recaptcha/internal/zzip;->zze:Ljava/lang/String;

    move-object v11, v4

    check-cast v11, Ljava/lang/String;

    iget-object v11, v2, Lcom/google/android/recaptcha/internal/zzip;->zzd:Lcom/google/android/recaptcha/internal/zzja;

    move-object v12, v11

    check-cast v12, Lcom/google/android/recaptcha/internal/zzja;

    invoke-static {v0}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V

    goto :goto_1

    :cond_6
    invoke-static {v0}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V

    iget-object v0, v1, Lcom/google/android/recaptcha/internal/zzja;->zzg:Lcom/google/android/recaptcha/internal/zzcb;

    sget-object v4, Lcom/google/android/recaptcha/internal/zzje;->zzd:Lcom/google/android/recaptcha/internal/zzje;

    iput-object v1, v2, Lcom/google/android/recaptcha/internal/zzip;->zzd:Lcom/google/android/recaptcha/internal/zzja;

    move-object/from16 v11, p1

    iput-object v11, v2, Lcom/google/android/recaptcha/internal/zzip;->zze:Ljava/lang/String;

    iput v9, v2, Lcom/google/android/recaptcha/internal/zzip;->zzc:I

    .line 2
    invoke-virtual {v0, v4, v2}, Lcom/google/android/recaptcha/internal/zzcb;->zza(Ljava/lang/Object;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object v0

    if-eq v0, v3, :cond_a

    move-object v4, v11

    move-object v11, v1

    :goto_1
    check-cast v0, Ljava/lang/Boolean;

    invoke-virtual {v0}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v0

    if-eqz v0, :cond_7

    .line 3
    new-instance v0, Lcom/google/android/recaptcha/internal/zzbd;

    sget-object v2, Lcom/google/android/recaptcha/internal/zzbb;->zzb:Lcom/google/android/recaptcha/internal/zzbb;

    sget-object v3, Lcom/google/android/recaptcha/internal/zzba;->zzav:Lcom/google/android/recaptcha/internal/zzba;

    .line 4
    invoke-direct {v0, v2, v3, v10}, Lcom/google/android/recaptcha/internal/zzbd;-><init>(Lcom/google/android/recaptcha/internal/zzbb;Lcom/google/android/recaptcha/internal/zzba;Ljava/lang/String;)V

    .line 5
    sget-object v2, Lkotlin/Result;->Companion:Lkotlin/Result$Companion;

    check-cast v0, Ljava/lang/Throwable;

    invoke-static {v0}, Lkotlin/ResultKt;->createFailure(Ljava/lang/Throwable;)Ljava/lang/Object;

    move-result-object v0

    invoke-static {v0}, Lkotlin/Result;->constructor-impl(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    return-object v0

    .line 6
    :cond_7
    iget-object v0, v11, Lcom/google/android/recaptcha/internal/zzja;->zzg:Lcom/google/android/recaptcha/internal/zzcb;

    sget-object v12, Lcom/google/android/recaptcha/internal/zzje;->zzc:Lcom/google/android/recaptcha/internal/zzje;

    iput-object v11, v2, Lcom/google/android/recaptcha/internal/zzip;->zzd:Lcom/google/android/recaptcha/internal/zzja;

    iput-object v4, v2, Lcom/google/android/recaptcha/internal/zzip;->zze:Ljava/lang/String;

    iput v8, v2, Lcom/google/android/recaptcha/internal/zzip;->zzc:I

    invoke-virtual {v0, v12, v2}, Lcom/google/android/recaptcha/internal/zzcb;->zza(Ljava/lang/Object;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object v0

    if-eq v0, v3, :cond_a

    move-object v8, v11

    :goto_2
    check-cast v0, Ljava/lang/Boolean;

    invoke-virtual {v0}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v0

    if-nez v0, :cond_8

    iput-object v8, v2, Lcom/google/android/recaptcha/internal/zzip;->zzd:Lcom/google/android/recaptcha/internal/zzja;

    iput-object v4, v2, Lcom/google/android/recaptcha/internal/zzip;->zze:Ljava/lang/String;

    iput v7, v2, Lcom/google/android/recaptcha/internal/zzip;->zzc:I

    .line 7
    invoke-direct {v8, v4, v2}, Lcom/google/android/recaptcha/internal/zzja;->zzG(Ljava/lang/String;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object v0

    if-eq v0, v3, :cond_a

    :cond_8
    move-object v7, v8

    .line 8
    :goto_3
    :try_start_2
    invoke-virtual {v7}, Lcom/google/android/recaptcha/internal/zzja;->zzA()Lkotlinx/coroutines/CompletableDeferred;

    move-result-object v0

    iput-object v7, v2, Lcom/google/android/recaptcha/internal/zzip;->zzd:Lcom/google/android/recaptcha/internal/zzja;

    iput-object v4, v2, Lcom/google/android/recaptcha/internal/zzip;->zze:Ljava/lang/String;

    iput v6, v2, Lcom/google/android/recaptcha/internal/zzip;->zzc:I

    invoke-interface {v0, v2}, Lkotlinx/coroutines/CompletableDeferred;->await(Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object v0
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_2

    if-eq v0, v3, :cond_a

    move-object v6, v7

    .line 9
    :goto_4
    :try_start_3
    invoke-static {v10, v9, v10}, Lkotlinx/coroutines/CompletableDeferredKt;->CompletableDeferred$default(Lkotlinx/coroutines/Job;ILjava/lang/Object;)Lkotlinx/coroutines/CompletableDeferred;

    move-result-object v0

    .line 10
    iget-object v7, v6, Lcom/google/android/recaptcha/internal/zzja;->zze:Ljava/util/Map;

    invoke-interface {v7, v4, v0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 11
    invoke-static {}, Lcom/google/android/recaptcha/internal/zztq;->zzf()Lcom/google/android/recaptcha/internal/zztp;

    move-result-object v7

    invoke-virtual {v7, v4}, Lcom/google/android/recaptcha/internal/zztp;->zze(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zztp;

    invoke-virtual {v7}, Lcom/google/android/recaptcha/internal/zzmx;->zzi()Lcom/google/android/recaptcha/internal/zznd;

    move-result-object v7

    check-cast v7, Lcom/google/android/recaptcha/internal/zztq;

    invoke-virtual {v7}, Lcom/google/android/recaptcha/internal/zzko;->zzd()[B

    move-result-object v7

    .line 12
    invoke-static {}, Lcom/google/android/recaptcha/internal/zzkh;->zzh()Lcom/google/android/recaptcha/internal/zzkh;

    move-result-object v8

    array-length v9, v7

    const/4 v11, 0x0

    .line 13
    invoke-virtual {v8, v7, v11, v9}, Lcom/google/android/recaptcha/internal/zzkh;->zzi([BII)Ljava/lang/String;

    move-result-object v7

    .line 14
    iget-object v8, v6, Lcom/google/android/recaptcha/internal/zzja;->zzq:Lcom/google/android/recaptcha/internal/zzbi;

    invoke-virtual {v8}, Lcom/google/android/recaptcha/internal/zzbi;->zzb()Lkotlinx/coroutines/CoroutineScope;

    move-result-object v11

    new-instance v8, Lcom/google/android/recaptcha/internal/zziq;

    invoke-direct {v8, v6, v7, v10}, Lcom/google/android/recaptcha/internal/zziq;-><init>(Lcom/google/android/recaptcha/internal/zzja;Ljava/lang/String;Lkotlin/coroutines/Continuation;)V

    move-object v14, v8

    check-cast v14, Lkotlin/jvm/functions/Function2;

    const/4 v15, 0x3

    const/16 v16, 0x0

    const/4 v12, 0x0

    const/4 v13, 0x0

    invoke-static/range {v11 .. v16}, Lkotlinx/coroutines/BuildersKt;->launch$default(Lkotlinx/coroutines/CoroutineScope;Lkotlin/coroutines/CoroutineContext;Lkotlinx/coroutines/CoroutineStart;Lkotlin/jvm/functions/Function2;ILjava/lang/Object;)Lkotlinx/coroutines/Job;

    iput-object v6, v2, Lcom/google/android/recaptcha/internal/zzip;->zzd:Lcom/google/android/recaptcha/internal/zzja;

    iput-object v4, v2, Lcom/google/android/recaptcha/internal/zzip;->zze:Ljava/lang/String;

    iput v5, v2, Lcom/google/android/recaptcha/internal/zzip;->zzc:I

    .line 15
    invoke-interface {v0, v2}, Lkotlinx/coroutines/CompletableDeferred;->await(Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object v0
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_1

    if-eq v0, v3, :cond_a

    move-object v3, v4

    move-object v2, v6

    .line 1
    :goto_5
    :try_start_4
    check-cast v0, Lcom/google/android/recaptcha/internal/zzsi;

    .line 16
    invoke-static {}, Lcom/google/android/recaptcha/internal/zzsi;->zzf()Lcom/google/android/recaptcha/internal/zzsh;

    move-result-object v4

    .line 17
    invoke-virtual {v4, v3}, Lcom/google/android/recaptcha/internal/zzsh;->zze(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zzsh;

    .line 18
    invoke-static {}, Lcom/google/android/recaptcha/internal/zzsm;->zzf()Lcom/google/android/recaptcha/internal/zzsl;

    move-result-object v5

    .line 19
    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzsi;->zzl()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Lcom/google/android/recaptcha/internal/zzsl;->zze(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zzsl;

    .line 20
    invoke-virtual {v4, v5}, Lcom/google/android/recaptcha/internal/zzsh;->zzq(Lcom/google/android/recaptcha/internal/zzsl;)Lcom/google/android/recaptcha/internal/zzsh;

    .line 21
    invoke-static {}, Lcom/google/android/recaptcha/internal/zzsk;->zzf()Lcom/google/android/recaptcha/internal/zzsj;

    move-result-object v5

    .line 22
    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzsi;->zzj()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Lcom/google/android/recaptcha/internal/zzsj;->zze(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zzsj;

    .line 23
    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzsi;->zzM()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v5, v0}, Lcom/google/android/recaptcha/internal/zzsj;->zzf(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zzsj;

    .line 24
    invoke-virtual {v4, v5}, Lcom/google/android/recaptcha/internal/zzsh;->zzr(Lcom/google/android/recaptcha/internal/zzsj;)Lcom/google/android/recaptcha/internal/zzsh;

    .line 25
    sget-object v0, Lkotlin/Result;->Companion:Lkotlin/Result$Companion;

    invoke-virtual {v4}, Lcom/google/android/recaptcha/internal/zzmx;->zzi()Lcom/google/android/recaptcha/internal/zznd;

    move-result-object v0

    invoke-static {v0}, Lkotlin/Result;->constructor-impl(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_0

    return-object v0

    :catch_2
    move-exception v0

    move-object v3, v4

    move-object v2, v7

    .line 26
    :goto_6
    new-instance v4, Lcom/google/android/recaptcha/internal/zzbd;

    sget-object v5, Lcom/google/android/recaptcha/internal/zzbb;->zzb:Lcom/google/android/recaptcha/internal/zzbb;

    sget-object v6, Lcom/google/android/recaptcha/internal/zzba;->zzW:Lcom/google/android/recaptcha/internal/zzba;

    .line 27
    invoke-virtual {v0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v7

    .line 26
    invoke-direct {v4, v5, v6, v7}, Lcom/google/android/recaptcha/internal/zzbd;-><init>(Lcom/google/android/recaptcha/internal/zzbb;Lcom/google/android/recaptcha/internal/zzba;Ljava/lang/String;)V

    .line 28
    invoke-static {v0, v4}, Lcom/google/android/recaptcha/internal/zzf;->zza(Ljava/lang/Exception;Lcom/google/android/recaptcha/internal/zzbd;)Lcom/google/android/recaptcha/internal/zzbd;

    move-result-object v0

    .line 29
    iget-object v2, v2, Lcom/google/android/recaptcha/internal/zzja;->zze:Ljava/util/Map;

    .line 30
    invoke-interface {v2, v3}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lkotlinx/coroutines/CompletableDeferred;

    if-eqz v2, :cond_9

    .line 29
    move-object v3, v0

    check-cast v3, Ljava/lang/Throwable;

    invoke-interface {v2, v3}, Lkotlinx/coroutines/CompletableDeferred;->completeExceptionally(Ljava/lang/Throwable;)Z

    move-result v2

    invoke-static {v2}, Lkotlin/coroutines/jvm/internal/Boxing;->boxBoolean(Z)Ljava/lang/Boolean;

    .line 31
    :cond_9
    sget-object v2, Lkotlin/Result;->Companion:Lkotlin/Result$Companion;

    check-cast v0, Ljava/lang/Throwable;

    invoke-static {v0}, Lkotlin/ResultKt;->createFailure(Ljava/lang/Throwable;)Ljava/lang/Object;

    move-result-object v0

    invoke-static {v0}, Lkotlin/Result;->constructor-impl(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    return-object v0

    :cond_a
    return-object v3
.end method

.method protected final zzg(Lcom/google/android/recaptcha/internal/zzbd;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
    .locals 1

    .line 1
    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzbd;->zza()Lcom/google/android/recaptcha/internal/zzba;

    move-result-object p2

    sget-object v0, Lcom/google/android/recaptcha/internal/zzba;->zzb:Lcom/google/android/recaptcha/internal/zzba;

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p2

    if-eqz p2, :cond_1

    iget-object p2, p0, Lcom/google/android/recaptcha/internal/zzja;->zzp:Lcom/google/android/recaptcha/internal/zzen;

    if-eqz p2, :cond_0

    .line 2
    invoke-virtual {p2, p1}, Lcom/google/android/recaptcha/internal/zzen;->zzb(Lcom/google/android/recaptcha/internal/zzbd;)V

    :cond_0
    const/4 p1, 0x0

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzja;->zzp:Lcom/google/android/recaptcha/internal/zzen;

    .line 3
    :cond_1
    sget-object p1, Lkotlin/Unit;->INSTANCE:Lkotlin/Unit;

    return-object p1
.end method

.method protected final zzh(Lcom/google/android/recaptcha/internal/zzsc;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
    .locals 5

    instance-of v0, p2, Lcom/google/android/recaptcha/internal/zzir;

    if-eqz v0, :cond_0

    move-object v0, p2

    check-cast v0, Lcom/google/android/recaptcha/internal/zzir;

    .line 1
    iget v1, v0, Lcom/google/android/recaptcha/internal/zzir;->zzc:I

    const/high16 v2, -0x80000000

    and-int v3, v1, v2

    if-eqz v3, :cond_0

    sub-int/2addr v1, v2

    iput v1, v0, Lcom/google/android/recaptcha/internal/zzir;->zzc:I

    goto :goto_0

    :cond_0
    new-instance v0, Lcom/google/android/recaptcha/internal/zzir;

    invoke-direct {v0, p0, p2}, Lcom/google/android/recaptcha/internal/zzir;-><init>(Lcom/google/android/recaptcha/internal/zzja;Lkotlin/coroutines/Continuation;)V

    :goto_0
    iget-object p2, v0, Lcom/google/android/recaptcha/internal/zzir;->zza:Ljava/lang/Object;

    invoke-static {}, Lkotlin/coroutines/intrinsics/IntrinsicsKt;->getCOROUTINE_SUSPENDED()Ljava/lang/Object;

    move-result-object v1

    iget v2, v0, Lcom/google/android/recaptcha/internal/zzir;->zzc:I

    const/4 v3, 0x2

    const/4 v4, 0x1

    if-eqz v2, :cond_3

    if-eq v2, v4, :cond_2

    if-ne v2, v3, :cond_1

    invoke-static {p2}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V

    goto :goto_1

    :cond_1
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string p2, "call to \'resume\' before \'invoke\' with coroutine"

    invoke-direct {p1, p2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1

    :cond_2
    invoke-static {p2}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V

    goto :goto_3

    :cond_3
    invoke-static {p2}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V

    .line 2
    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzsc;->zzT()Z

    move-result p2

    if-eqz p2, :cond_5

    .line 3
    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzsc;->zzR()Z

    move-result p2

    if-eqz p2, :cond_5

    .line 4
    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzsc;->zzQ()Z

    move-result p2

    if-nez p2, :cond_4

    goto :goto_2

    .line 6
    :cond_4
    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzja;->zzf:Lcom/google/android/recaptcha/internal/zzsc;

    iget-object p1, p0, Lcom/google/android/recaptcha/internal/zzja;->zzc:Lcom/google/android/recaptcha/internal/zzek;

    .line 9
    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzek;->zzd()Ljava/lang/String;

    move-result-object p1

    iput v3, v0, Lcom/google/android/recaptcha/internal/zzir;->zzc:I

    invoke-direct {p0, p1, v0}, Lcom/google/android/recaptcha/internal/zzja;->zzG(Ljava/lang/String;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object p1

    if-eq p1, v1, :cond_6

    .line 10
    :goto_1
    sget-object p1, Lkotlin/Result;->Companion:Lkotlin/Result$Companion;

    sget-object p1, Lkotlin/Unit;->INSTANCE:Lkotlin/Unit;

    invoke-static {p1}, Lkotlin/Result;->constructor-impl(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    return-object p1

    .line 4
    :cond_5
    :goto_2
    iget-object p1, p0, Lcom/google/android/recaptcha/internal/zzja;->zzg:Lcom/google/android/recaptcha/internal/zzcb;

    sget-object p2, Lcom/google/android/recaptcha/internal/zzje;->zzd:Lcom/google/android/recaptcha/internal/zzje;

    iput v4, v0, Lcom/google/android/recaptcha/internal/zzir;->zzc:I

    .line 5
    invoke-virtual {p1, p2, v0}, Lcom/google/android/recaptcha/internal/zzcb;->zzc(Ljava/lang/Object;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object p1

    if-ne p1, v1, :cond_7

    :cond_6
    return-object v1

    .line 6
    :cond_7
    :goto_3
    sget-object p1, Lkotlin/Result;->Companion:Lkotlin/Result$Companion;

    .line 7
    new-instance p1, Lcom/google/android/recaptcha/internal/zzbd;

    sget-object p2, Lcom/google/android/recaptcha/internal/zzbb;->zzb:Lcom/google/android/recaptcha/internal/zzbb;

    sget-object v0, Lcom/google/android/recaptcha/internal/zzba;->zzav:Lcom/google/android/recaptcha/internal/zzba;

    const/4 v1, 0x0

    .line 8
    invoke-direct {p1, p2, v0, v1}, Lcom/google/android/recaptcha/internal/zzbd;-><init>(Lcom/google/android/recaptcha/internal/zzbb;Lcom/google/android/recaptcha/internal/zzba;Ljava/lang/String;)V

    .line 7
    check-cast p1, Ljava/lang/Throwable;

    .line 6
    invoke-static {p1}, Lkotlin/ResultKt;->createFailure(Ljava/lang/Throwable;)Ljava/lang/Object;

    move-result-object p1

    invoke-static {p1}, Lkotlin/Result;->constructor-impl(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method

.method protected final zzi(Ljava/lang/String;JLjava/lang/Exception;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
    .locals 0

    .line 1
    invoke-virtual {p4}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    iget-object p2, p0, Lcom/google/android/recaptcha/internal/zzja;->zze:Ljava/util/Map;

    .line 2
    invoke-interface {p2, p1}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Lkotlinx/coroutines/CompletableDeferred;

    if-eqz p1, :cond_0

    .line 3
    check-cast p4, Ljava/lang/Throwable;

    invoke-interface {p1, p4}, Lkotlinx/coroutines/CompletableDeferred;->completeExceptionally(Ljava/lang/Throwable;)Z

    move-result p1

    invoke-static {p1}, Lkotlin/coroutines/jvm/internal/Boxing;->boxBoolean(Z)Ljava/lang/Boolean;

    .line 4
    :cond_0
    sget-object p1, Lkotlin/Unit;->INSTANCE:Lkotlin/Unit;

    return-object p1
.end method

.method protected final zzj(Ljava/lang/Exception;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
    .locals 3

    .line 1
    iget-object p2, p0, Lcom/google/android/recaptcha/internal/zzja;->zzi:Lcom/google/android/recaptcha/internal/zzij;

    invoke-virtual {p2}, Lcom/google/android/recaptcha/internal/zzij;->zza()Ljava/lang/Long;

    move-result-object p2

    .line 2
    instance-of v0, p1, Lkotlinx/coroutines/TimeoutCancellationException;

    if-nez v0, :cond_0

    goto :goto_0

    :cond_0
    if-nez p2, :cond_1

    .line 6
    new-instance p1, Lcom/google/android/recaptcha/internal/zzbd;

    sget-object p2, Lcom/google/android/recaptcha/internal/zzbb;->zzc:Lcom/google/android/recaptcha/internal/zzbb;

    sget-object v0, Lcom/google/android/recaptcha/internal/zzba;->zzH:Lcom/google/android/recaptcha/internal/zzba;

    const/4 v1, 0x0

    .line 7
    invoke-direct {p1, p2, v0, v1}, Lcom/google/android/recaptcha/internal/zzbd;-><init>(Lcom/google/android/recaptcha/internal/zzbb;Lcom/google/android/recaptcha/internal/zzba;Ljava/lang/String;)V

    return-object p1

    .line 3
    :cond_1
    :goto_0
    new-instance p2, Lcom/google/android/recaptcha/internal/zzbd;

    sget-object v0, Lcom/google/android/recaptcha/internal/zzbb;->zzb:Lcom/google/android/recaptcha/internal/zzbb;

    sget-object v1, Lcom/google/android/recaptcha/internal/zzba;->zzV:Lcom/google/android/recaptcha/internal/zzba;

    .line 4
    invoke-virtual {p1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object v2

    .line 3
    invoke-direct {p2, v0, v1, v2}, Lcom/google/android/recaptcha/internal/zzbd;-><init>(Lcom/google/android/recaptcha/internal/zzbb;Lcom/google/android/recaptcha/internal/zzba;Ljava/lang/String;)V

    .line 5
    invoke-static {p1, p2}, Lcom/google/android/recaptcha/internal/zzf;->zza(Ljava/lang/Exception;Lcom/google/android/recaptcha/internal/zzbd;)Lcom/google/android/recaptcha/internal/zzbd;

    move-result-object p1

    return-object p1
.end method

.method public final zzm()Lcom/google/android/recaptcha/internal/zzcb;
    .locals 1

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzja;->zzg:Lcom/google/android/recaptcha/internal/zzcb;

    return-object v0
.end method

.method public final zzq()Lcom/google/android/recaptcha/internal/zzij;
    .locals 1

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzja;->zzi:Lcom/google/android/recaptcha/internal/zzij;

    return-object v0
.end method

.method public final zzw(Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
    .locals 5

    .line 1
    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzja;->zzk:Lkotlin/Lazy;

    invoke-interface {v0}, Lkotlin/Lazy;->getValue()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/google/android/recaptcha/internal/zzjd;

    .line 2
    invoke-direct {p0}, Lcom/google/android/recaptcha/internal/zzja;->zzD()Landroid/app/Application;

    move-result-object v1

    check-cast v1, Landroid/content/Context;

    iget-object v2, p0, Lcom/google/android/recaptcha/internal/zzja;->zzq:Lcom/google/android/recaptcha/internal/zzbi;

    .line 3
    invoke-virtual {v2}, Lcom/google/android/recaptcha/internal/zzbi;->zzb()Lkotlinx/coroutines/CoroutineScope;

    move-result-object v2

    invoke-interface {v2}, Lkotlinx/coroutines/CoroutineScope;->getCoroutineContext()Lkotlin/coroutines/CoroutineContext;

    move-result-object v2

    new-instance v3, Lcom/google/android/recaptcha/internal/zzjc;

    const/4 v4, 0x0

    invoke-direct {v3, v0, v1, v4}, Lcom/google/android/recaptcha/internal/zzjc;-><init>(Lcom/google/android/recaptcha/internal/zzjd;Landroid/content/Context;Lkotlin/coroutines/Continuation;)V

    check-cast v3, Lkotlin/jvm/functions/Function2;

    invoke-static {v2, v3, p1}, Lkotlinx/coroutines/BuildersKt;->withContext(Lkotlin/coroutines/CoroutineContext;Lkotlin/jvm/functions/Function2;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method

.method public final zzx(Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
    .locals 3

    .line 1
    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzja;->zzq:Lcom/google/android/recaptcha/internal/zzbi;

    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzbi;->zzb()Lkotlinx/coroutines/CoroutineScope;

    move-result-object v0

    invoke-interface {v0}, Lkotlinx/coroutines/CoroutineScope;->getCoroutineContext()Lkotlin/coroutines/CoroutineContext;

    move-result-object v0

    new-instance v1, Lcom/google/android/recaptcha/internal/zzil;

    const/4 v2, 0x0

    invoke-direct {v1, p0, v2}, Lcom/google/android/recaptcha/internal/zzil;-><init>(Lcom/google/android/recaptcha/internal/zzja;Lkotlin/coroutines/Continuation;)V

    check-cast v1, Lkotlin/jvm/functions/Function2;

    invoke-static {v0, v1, p1}, Lkotlinx/coroutines/BuildersKt;->withContext(Lkotlin/coroutines/CoroutineContext;Lkotlin/jvm/functions/Function2;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object p1

    invoke-static {}, Lkotlin/coroutines/intrinsics/IntrinsicsKt;->getCOROUTINE_SUSPENDED()Ljava/lang/Object;

    move-result-object v0

    if-ne p1, v0, :cond_0

    return-object p1

    :cond_0
    sget-object p1, Lkotlin/Unit;->INSTANCE:Lkotlin/Unit;

    return-object p1
.end method
