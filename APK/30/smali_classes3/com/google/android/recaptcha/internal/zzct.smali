.class final Lcom/google/android/recaptcha/internal/zzct;
.super Lkotlin/coroutines/jvm/internal/SuspendLambda;
.source "com.google.android.recaptcha:recaptcha@@18.6.1"

# interfaces
.implements Lkotlin/jvm/functions/Function2;


# instance fields
.field zza:Ljava/lang/Object;

.field zzb:I

.field synthetic zzc:Ljava/lang/Object;

.field final synthetic zzd:Lcom/google/android/recaptcha/internal/zzcv;

.field final synthetic zze:Ljava/lang/String;

.field final synthetic zzf:J

.field final synthetic zzg:Lcom/google/android/recaptcha/internal/zzcn;

.field final synthetic zzh:Lcom/google/android/recaptcha/internal/zzch;

.field final synthetic zzi:Lcom/google/android/recaptcha/internal/zzbi;


# direct methods
.method constructor <init>(Lcom/google/android/recaptcha/internal/zzcv;Ljava/lang/String;JLcom/google/android/recaptcha/internal/zzcn;Lcom/google/android/recaptcha/internal/zzbi;Lcom/google/android/recaptcha/internal/zzch;Lkotlin/coroutines/Continuation;)V
    .locals 0

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzct;->zzd:Lcom/google/android/recaptcha/internal/zzcv;

    iput-object p2, p0, Lcom/google/android/recaptcha/internal/zzct;->zze:Ljava/lang/String;

    iput-wide p3, p0, Lcom/google/android/recaptcha/internal/zzct;->zzf:J

    iput-object p5, p0, Lcom/google/android/recaptcha/internal/zzct;->zzg:Lcom/google/android/recaptcha/internal/zzcn;

    iput-object p6, p0, Lcom/google/android/recaptcha/internal/zzct;->zzi:Lcom/google/android/recaptcha/internal/zzbi;

    iput-object p7, p0, Lcom/google/android/recaptcha/internal/zzct;->zzh:Lcom/google/android/recaptcha/internal/zzch;

    const/4 p1, 0x2

    invoke-direct {p0, p1, p8}, Lkotlin/coroutines/jvm/internal/SuspendLambda;-><init>(ILkotlin/coroutines/Continuation;)V

    return-void
.end method


# virtual methods
.method public final create(Ljava/lang/Object;Lkotlin/coroutines/Continuation;)Lkotlin/coroutines/Continuation;
    .locals 9

    new-instance v0, Lcom/google/android/recaptcha/internal/zzct;

    iget-object v1, p0, Lcom/google/android/recaptcha/internal/zzct;->zzd:Lcom/google/android/recaptcha/internal/zzcv;

    iget-object v2, p0, Lcom/google/android/recaptcha/internal/zzct;->zze:Ljava/lang/String;

    iget-wide v3, p0, Lcom/google/android/recaptcha/internal/zzct;->zzf:J

    iget-object v5, p0, Lcom/google/android/recaptcha/internal/zzct;->zzg:Lcom/google/android/recaptcha/internal/zzcn;

    iget-object v6, p0, Lcom/google/android/recaptcha/internal/zzct;->zzi:Lcom/google/android/recaptcha/internal/zzbi;

    iget-object v7, p0, Lcom/google/android/recaptcha/internal/zzct;->zzh:Lcom/google/android/recaptcha/internal/zzch;

    move-object v8, p2

    invoke-direct/range {v0 .. v8}, Lcom/google/android/recaptcha/internal/zzct;-><init>(Lcom/google/android/recaptcha/internal/zzcv;Ljava/lang/String;JLcom/google/android/recaptcha/internal/zzcn;Lcom/google/android/recaptcha/internal/zzbi;Lcom/google/android/recaptcha/internal/zzch;Lkotlin/coroutines/Continuation;)V

    iput-object p1, v0, Lcom/google/android/recaptcha/internal/zzct;->zzc:Ljava/lang/Object;

    check-cast v0, Lkotlin/coroutines/Continuation;

    return-object v0
.end method

.method public final bridge synthetic invoke(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    .locals 0

    check-cast p1, Lcom/google/android/recaptcha/internal/zzek;

    check-cast p2, Lkotlin/coroutines/Continuation;

    .line 1
    invoke-virtual {p0, p1, p2}, Lcom/google/android/recaptcha/internal/zzct;->create(Ljava/lang/Object;Lkotlin/coroutines/Continuation;)Lkotlin/coroutines/Continuation;

    move-result-object p1

    check-cast p1, Lcom/google/android/recaptcha/internal/zzct;

    sget-object p2, Lkotlin/Unit;->INSTANCE:Lkotlin/Unit;

    invoke-virtual {p1, p2}, Lcom/google/android/recaptcha/internal/zzct;->invokeSuspend(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method

.method public final invokeSuspend(Ljava/lang/Object;)Ljava/lang/Object;
    .locals 6

    .line 1
    invoke-static {}, Lkotlin/coroutines/intrinsics/IntrinsicsKt;->getCOROUTINE_SUSPENDED()Ljava/lang/Object;

    move-result-object v0

    iget v1, p0, Lcom/google/android/recaptcha/internal/zzct;->zzb:I

    if-eqz v1, :cond_0

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzct;->zza:Ljava/lang/Object;

    check-cast v0, Lcom/google/android/recaptcha/internal/zzcn;

    iget-object v1, p0, Lcom/google/android/recaptcha/internal/zzct;->zzc:Ljava/lang/Object;

    check-cast v1, Lcom/google/android/recaptcha/internal/zzek;

    invoke-static {p1}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V

    goto :goto_0

    :cond_0
    invoke-static {p1}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V

    iget-object p1, p0, Lcom/google/android/recaptcha/internal/zzct;->zzc:Ljava/lang/Object;

    move-object v1, p1

    check-cast v1, Lcom/google/android/recaptcha/internal/zzek;

    iget-object p1, p0, Lcom/google/android/recaptcha/internal/zzct;->zzd:Lcom/google/android/recaptcha/internal/zzcv;

    iget-object v2, p0, Lcom/google/android/recaptcha/internal/zzct;->zze:Ljava/lang/String;

    .line 2
    invoke-static {p1, v2}, Lcom/google/android/recaptcha/internal/zzcv;->zza(Lcom/google/android/recaptcha/internal/zzcv;Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zzdc;

    move-result-object p1

    if-eqz p1, :cond_1

    return-object p1

    :cond_1
    iget-object p1, p0, Lcom/google/android/recaptcha/internal/zzct;->zzd:Lcom/google/android/recaptcha/internal/zzcv;

    iget-wide v2, p0, Lcom/google/android/recaptcha/internal/zzct;->zzf:J

    .line 3
    invoke-static {p1, v2, v3}, Lcom/google/android/recaptcha/internal/zzcv;->zzc(Lcom/google/android/recaptcha/internal/zzcv;J)V

    iget-object p1, p0, Lcom/google/android/recaptcha/internal/zzct;->zzg:Lcom/google/android/recaptcha/internal/zzcn;

    if-nez p1, :cond_2

    iget-object p1, p0, Lcom/google/android/recaptcha/internal/zzct;->zzd:Lcom/google/android/recaptcha/internal/zzcv;

    iget-object v2, p0, Lcom/google/android/recaptcha/internal/zzct;->zze:Ljava/lang/String;

    iget-object v3, p0, Lcom/google/android/recaptcha/internal/zzct;->zzi:Lcom/google/android/recaptcha/internal/zzbi;

    iget-object v4, p0, Lcom/google/android/recaptcha/internal/zzct;->zzh:Lcom/google/android/recaptcha/internal/zzch;

    .line 4
    invoke-static {p1, v2, v3, v4, v1}, Lcom/google/android/recaptcha/internal/zzcv;->zze(Lcom/google/android/recaptcha/internal/zzcv;Ljava/lang/String;Lcom/google/android/recaptcha/internal/zzbi;Lcom/google/android/recaptcha/internal/zzch;Lcom/google/android/recaptcha/internal/zzek;)Lcom/google/android/recaptcha/internal/zzcn;

    move-result-object p1

    :cond_2
    iget-wide v2, p0, Lcom/google/android/recaptcha/internal/zzct;->zzf:J

    .line 5
    move-object v4, p0

    check-cast v4, Lkotlin/coroutines/Continuation;

    iput-object v1, p0, Lcom/google/android/recaptcha/internal/zzct;->zzc:Ljava/lang/Object;

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzct;->zza:Ljava/lang/Object;

    const/4 v5, 0x1

    iput v5, p0, Lcom/google/android/recaptcha/internal/zzct;->zzb:I

    invoke-interface {p1, v2, v3, v4}, Lcom/google/android/recaptcha/internal/zzcn;->zzb(JLkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object v2

    if-ne v2, v0, :cond_3

    return-object v0

    :cond_3
    move-object v0, p1

    .line 1
    :goto_0
    iget-object p1, p0, Lcom/google/android/recaptcha/internal/zzct;->zze:Ljava/lang/String;

    iget-object v2, p0, Lcom/google/android/recaptcha/internal/zzct;->zzi:Lcom/google/android/recaptcha/internal/zzbi;

    .line 6
    new-instance v3, Lcom/google/android/recaptcha/internal/zzdc;

    invoke-direct {v3, v0, p1, v2, v1}, Lcom/google/android/recaptcha/internal/zzdc;-><init>(Lcom/google/android/recaptcha/internal/zzcn;Ljava/lang/String;Lcom/google/android/recaptcha/internal/zzbi;Lcom/google/android/recaptcha/internal/zzek;)V

    iget-object p1, p0, Lcom/google/android/recaptcha/internal/zzct;->zzd:Lcom/google/android/recaptcha/internal/zzcv;

    .line 7
    invoke-static {p1, v3}, Lcom/google/android/recaptcha/internal/zzcv;->zzb(Lcom/google/android/recaptcha/internal/zzcv;Lcom/google/android/recaptcha/internal/zzdc;)V

    return-object v3
.end method
