.class public final Lcom/google/android/recaptcha/internal/zzcv;
.super Ljava/lang/Object;
.source "com.google.android.recaptcha:recaptcha@@18.6.1"


# instance fields
.field private final zza:Landroid/app/Application;

.field private final zzb:Lkotlinx/coroutines/sync/Mutex;

.field private zzc:Lcom/google/android/recaptcha/internal/zzdc;

.field private final zzd:Ljava/lang/String;

.field private final zze:Lcom/google/android/recaptcha/internal/zzl;

.field private zzf:Lcom/google/android/recaptcha/internal/zzbi;


# direct methods
.method public constructor <init>(Landroid/app/Application;)V
    .locals 8

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzcv;->zza:Landroid/app/Application;

    const/4 v0, 0x0

    const/4 v1, 0x1

    const/4 v2, 0x0

    invoke-static {v0, v1, v2}, Lkotlinx/coroutines/sync/MutexKt;->Mutex$default(ZILjava/lang/Object;)Lkotlinx/coroutines/sync/Mutex;

    move-result-object v3

    iput-object v3, p0, Lcom/google/android/recaptcha/internal/zzcv;->zzb:Lkotlinx/coroutines/sync/Mutex;

    .line 2
    invoke-static {}, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;

    move-result-object v3

    invoke-virtual {v3}, Ljava/util/UUID;->toString()Ljava/lang/String;

    move-result-object v3

    iput-object v3, p0, Lcom/google/android/recaptcha/internal/zzcv;->zzd:Ljava/lang/String;

    new-instance v3, Lcom/google/android/recaptcha/internal/zzbi;

    .line 3
    invoke-direct {v3}, Lcom/google/android/recaptcha/internal/zzbi;-><init>()V

    move-object v4, v3

    check-cast v4, Lcom/google/android/recaptcha/internal/zzbi;

    iput-object v3, p0, Lcom/google/android/recaptcha/internal/zzcv;->zzf:Lcom/google/android/recaptcha/internal/zzbi;

    new-instance v3, Lcom/google/android/recaptcha/internal/zzl;

    .line 4
    invoke-direct {v3, v2, v1, v2}, Lcom/google/android/recaptcha/internal/zzl;-><init>(Ljava/util/List;ILkotlin/jvm/internal/DefaultConstructorMarker;)V

    iput-object v3, p0, Lcom/google/android/recaptcha/internal/zzcv;->zze:Lcom/google/android/recaptcha/internal/zzl;

    .line 5
    sget v3, Lcom/google/android/recaptcha/internal/zzav;->zza:I

    const/16 v3, 0xd

    new-array v4, v3, [Lcom/google/android/recaptcha/internal/zzaw;

    new-instance v5, Lcom/google/android/recaptcha/internal/zzaz;

    .line 6
    invoke-direct {v5, v2, v1, v2}, Lcom/google/android/recaptcha/internal/zzaz;-><init>(Ljava/util/List;ILkotlin/jvm/internal/DefaultConstructorMarker;)V

    const-class v6, Lcom/google/android/recaptcha/internal/zzaz;

    .line 7
    const-string v6, "com.google.android.recaptcha.internal.zzaz"

    invoke-virtual {v6}, Ljava/lang/String;->hashCode()I

    move-result v6

    new-instance v7, Lcom/google/android/recaptcha/internal/zzaw;

    invoke-direct {v7, v6, v5}, Lcom/google/android/recaptcha/internal/zzaw;-><init>(ILjava/lang/Object;)V

    aput-object v7, v4, v0

    new-instance v5, Lcom/google/android/recaptcha/internal/zzfu;

    invoke-direct {v5}, Lcom/google/android/recaptcha/internal/zzfu;-><init>()V

    const-class v6, Lcom/google/android/recaptcha/internal/zzfu;

    .line 8
    const-string v6, "com.google.android.recaptcha.internal.zzfu"

    invoke-virtual {v6}, Ljava/lang/String;->hashCode()I

    move-result v6

    new-instance v7, Lcom/google/android/recaptcha/internal/zzaw;

    invoke-direct {v7, v6, v5}, Lcom/google/android/recaptcha/internal/zzaw;-><init>(ILjava/lang/Object;)V

    aput-object v7, v4, v1

    new-instance v5, Lcom/google/android/recaptcha/internal/zzbe;

    .line 9
    invoke-direct {v5}, Lcom/google/android/recaptcha/internal/zzbe;-><init>()V

    const-class v6, Lcom/google/android/recaptcha/internal/zzbe;

    .line 10
    const-string v6, "com.google.android.recaptcha.internal.zzbe"

    invoke-virtual {v6}, Ljava/lang/String;->hashCode()I

    move-result v6

    new-instance v7, Lcom/google/android/recaptcha/internal/zzaw;

    invoke-direct {v7, v6, v5}, Lcom/google/android/recaptcha/internal/zzaw;-><init>(ILjava/lang/Object;)V

    const/4 v5, 0x2

    aput-object v7, v4, v5

    new-instance v5, Lcom/google/android/recaptcha/internal/zzjd;

    invoke-direct {v5}, Lcom/google/android/recaptcha/internal/zzjd;-><init>()V

    const-class v6, Lcom/google/android/recaptcha/internal/zzjd;

    .line 11
    const-string v6, "com.google.android.recaptcha.internal.zzjd"

    invoke-virtual {v6}, Ljava/lang/String;->hashCode()I

    move-result v6

    new-instance v7, Lcom/google/android/recaptcha/internal/zzaw;

    invoke-direct {v7, v6, v5}, Lcom/google/android/recaptcha/internal/zzaw;-><init>(ILjava/lang/Object;)V

    const/4 v5, 0x3

    aput-object v7, v4, v5

    new-instance v5, Lcom/google/android/recaptcha/internal/zzbr;

    const-string v6, "https://www.recaptcha.net/recaptcha/api3"

    .line 12
    invoke-direct {v5, v6}, Lcom/google/android/recaptcha/internal/zzbr;-><init>(Ljava/lang/String;)V

    const-class v6, Lcom/google/android/recaptcha/internal/zzbr;

    .line 13
    const-string v6, "com.google.android.recaptcha.internal.zzbr"

    invoke-virtual {v6}, Ljava/lang/String;->hashCode()I

    move-result v6

    new-instance v7, Lcom/google/android/recaptcha/internal/zzaw;

    invoke-direct {v7, v6, v5}, Lcom/google/android/recaptcha/internal/zzaw;-><init>(ILjava/lang/Object;)V

    const/4 v5, 0x4

    aput-object v7, v4, v5

    new-instance v5, Lcom/google/android/recaptcha/internal/zzex;

    .line 14
    invoke-direct {v5, v2, v1, v2}, Lcom/google/android/recaptcha/internal/zzex;-><init>(Lcom/google/android/recaptcha/internal/zzfm;ILkotlin/jvm/internal/DefaultConstructorMarker;)V

    const-class v2, Lcom/google/android/recaptcha/internal/zzex;

    .line 15
    const-string v2, "com.google.android.recaptcha.internal.zzex"

    invoke-virtual {v2}, Ljava/lang/String;->hashCode()I

    move-result v2

    new-instance v6, Lcom/google/android/recaptcha/internal/zzaw;

    invoke-direct {v6, v2, v5}, Lcom/google/android/recaptcha/internal/zzaw;-><init>(ILjava/lang/Object;)V

    const/4 v2, 0x5

    aput-object v6, v4, v2

    new-instance v2, Lcom/google/android/recaptcha/internal/zzfk;

    .line 16
    invoke-direct {v2, v1}, Lcom/google/android/recaptcha/internal/zzfk;-><init>(Z)V

    const-class v1, Lcom/google/android/recaptcha/internal/zzfk;

    .line 17
    const-string v1, "com.google.android.recaptcha.internal.zzfk"

    invoke-virtual {v1}, Ljava/lang/String;->hashCode()I

    move-result v1

    new-instance v5, Lcom/google/android/recaptcha/internal/zzaw;

    invoke-direct {v5, v1, v2}, Lcom/google/android/recaptcha/internal/zzaw;-><init>(ILjava/lang/Object;)V

    const/4 v1, 0x6

    aput-object v5, v4, v1

    const-class v1, Landroid/app/Application;

    .line 18
    invoke-virtual {v1}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/String;->hashCode()I

    move-result v1

    new-instance v2, Lcom/google/android/recaptcha/internal/zzaw;

    invoke-direct {v2, v1, p1}, Lcom/google/android/recaptcha/internal/zzaw;-><init>(ILjava/lang/Object;)V

    const/4 v1, 0x7

    aput-object v2, v4, v1

    new-instance v1, Lcom/google/android/recaptcha/internal/zzbf;

    .line 19
    check-cast p1, Landroid/content/Context;

    invoke-direct {v1, p1}, Lcom/google/android/recaptcha/internal/zzbf;-><init>(Landroid/content/Context;)V

    const-class v2, Lcom/google/android/recaptcha/internal/zzbf;

    .line 20
    const-string v2, "com.google.android.recaptcha.internal.zzbf"

    invoke-virtual {v2}, Ljava/lang/String;->hashCode()I

    move-result v2

    new-instance v5, Lcom/google/android/recaptcha/internal/zzaw;

    invoke-direct {v5, v2, v1}, Lcom/google/android/recaptcha/internal/zzaw;-><init>(ILjava/lang/Object;)V

    const/16 v1, 0x8

    aput-object v5, v4, v1

    new-instance v1, Lcom/google/android/recaptcha/internal/zzfj;

    .line 21
    invoke-direct {v1}, Lcom/google/android/recaptcha/internal/zzfj;-><init>()V

    const-class v2, Lcom/google/android/recaptcha/internal/zzfj;

    .line 22
    const-string v2, "com.google.android.recaptcha.internal.zzfj"

    invoke-virtual {v2}, Ljava/lang/String;->hashCode()I

    move-result v2

    new-instance v5, Lcom/google/android/recaptcha/internal/zzaw;

    invoke-direct {v5, v2, v1}, Lcom/google/android/recaptcha/internal/zzaw;-><init>(ILjava/lang/Object;)V

    const/16 v1, 0x9

    aput-object v5, v4, v1

    new-instance v1, Lcom/google/android/recaptcha/internal/zzbm;

    .line 23
    invoke-direct {v1, p1}, Lcom/google/android/recaptcha/internal/zzbm;-><init>(Landroid/content/Context;)V

    const-class p1, Lcom/google/android/recaptcha/internal/zzaq;

    .line 24
    const-string p1, "com.google.android.recaptcha.internal.zzaq"

    invoke-virtual {p1}, Ljava/lang/String;->hashCode()I

    move-result p1

    new-instance v2, Lcom/google/android/recaptcha/internal/zzaw;

    invoke-direct {v2, p1, v1}, Lcom/google/android/recaptcha/internal/zzaw;-><init>(ILjava/lang/Object;)V

    const/16 p1, 0xa

    aput-object v2, v4, p1

    new-instance p1, Lcom/google/android/recaptcha/internal/zzfa;

    .line 25
    invoke-direct {p1}, Lcom/google/android/recaptcha/internal/zzfa;-><init>()V

    const-class v1, Lcom/google/android/recaptcha/internal/zzey;

    .line 26
    const-string v1, "com.google.android.recaptcha.internal.zzey"

    invoke-virtual {v1}, Ljava/lang/String;->hashCode()I

    move-result v1

    new-instance v2, Lcom/google/android/recaptcha/internal/zzaw;

    invoke-direct {v2, v1, p1}, Lcom/google/android/recaptcha/internal/zzaw;-><init>(ILjava/lang/Object;)V

    const/16 p1, 0xb

    aput-object v2, v4, p1

    new-instance p1, Lcom/google/android/recaptcha/internal/zzff;

    .line 27
    invoke-direct {p1}, Lcom/google/android/recaptcha/internal/zzff;-><init>()V

    const-class v1, Lcom/google/android/recaptcha/internal/zzff;

    .line 28
    const-string v1, "com.google.android.recaptcha.internal.zzff"

    invoke-virtual {v1}, Ljava/lang/String;->hashCode()I

    move-result v1

    new-instance v2, Lcom/google/android/recaptcha/internal/zzaw;

    invoke-direct {v2, v1, p1}, Lcom/google/android/recaptcha/internal/zzaw;-><init>(ILjava/lang/Object;)V

    const/16 p1, 0xc

    aput-object v2, v4, p1

    :goto_0
    if-ge v0, v3, :cond_1

    .line 29
    aget-object p1, v4, v0

    invoke-static {}, Lcom/google/android/recaptcha/internal/zzav;->zzc()Ljava/util/Map;

    move-result-object v1

    .line 30
    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzaw;->zza()I

    move-result v2

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v1, v2}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_0

    invoke-static {}, Lcom/google/android/recaptcha/internal/zzav;->zzc()Ljava/util/Map;

    move-result-object v1

    .line 31
    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzaw;->zza()I

    move-result v2

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v1, v2, p1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    :cond_0
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    :cond_1
    return-void
.end method

.method public static final synthetic zza(Lcom/google/android/recaptcha/internal/zzcv;Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zzdc;
    .locals 2

    .line 1
    iget-object p0, p0, Lcom/google/android/recaptcha/internal/zzcv;->zzc:Lcom/google/android/recaptcha/internal/zzdc;

    const/4 v0, 0x0

    if-eqz p0, :cond_1

    invoke-virtual {p0}, Lcom/google/android/recaptcha/internal/zzdc;->zzd()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1, p1}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_0

    return-object p0

    .line 2
    :cond_0
    new-instance p0, Lcom/google/android/recaptcha/internal/zzbd;

    sget-object p1, Lcom/google/android/recaptcha/internal/zzbb;->zzd:Lcom/google/android/recaptcha/internal/zzbb;

    sget-object v1, Lcom/google/android/recaptcha/internal/zzba;->zzam:Lcom/google/android/recaptcha/internal/zzba;

    .line 3
    invoke-direct {p0, p1, v1, v0}, Lcom/google/android/recaptcha/internal/zzbd;-><init>(Lcom/google/android/recaptcha/internal/zzbb;Lcom/google/android/recaptcha/internal/zzba;Ljava/lang/String;)V

    .line 2
    throw p0

    :cond_1
    return-object v0
.end method

.method public static final synthetic zzb(Lcom/google/android/recaptcha/internal/zzcv;Lcom/google/android/recaptcha/internal/zzdc;)V
    .locals 0

    .line 1
    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzcv;->zzc:Lcom/google/android/recaptcha/internal/zzdc;

    return-void
.end method

.method public static final synthetic zzc(Lcom/google/android/recaptcha/internal/zzcv;J)V
    .locals 2

    const-wide/16 v0, 0x1388

    cmp-long p1, p1, v0

    const/4 p2, 0x0

    if-ltz p1, :cond_1

    .line 1
    iget-object p0, p0, Lcom/google/android/recaptcha/internal/zzcv;->zza:Landroid/app/Application;

    .line 3
    check-cast p0, Landroid/content/Context;

    const-string p1, "android.permission.INTERNET"

    invoke-static {p0, p1}, Landroidx/core/content/ContextCompat;->checkSelfPermission(Landroid/content/Context;Ljava/lang/String;)I

    move-result p0

    if-nez p0, :cond_0

    return-void

    .line 4
    :cond_0
    new-instance p0, Lcom/google/android/recaptcha/internal/zzbd;

    sget-object p1, Lcom/google/android/recaptcha/internal/zzbb;->zzc:Lcom/google/android/recaptcha/internal/zzbb;

    sget-object v0, Lcom/google/android/recaptcha/internal/zzba;->zzao:Lcom/google/android/recaptcha/internal/zzba;

    .line 5
    invoke-direct {p0, p1, v0, p2}, Lcom/google/android/recaptcha/internal/zzbd;-><init>(Lcom/google/android/recaptcha/internal/zzbb;Lcom/google/android/recaptcha/internal/zzba;Ljava/lang/String;)V

    .line 4
    throw p0

    .line 1
    :cond_1
    new-instance p0, Lcom/google/android/recaptcha/internal/zzbd;

    sget-object p1, Lcom/google/android/recaptcha/internal/zzbb;->zzj:Lcom/google/android/recaptcha/internal/zzbb;

    sget-object v0, Lcom/google/android/recaptcha/internal/zzba;->zzI:Lcom/google/android/recaptcha/internal/zzba;

    .line 2
    invoke-direct {p0, p1, v0, p2}, Lcom/google/android/recaptcha/internal/zzbd;-><init>(Lcom/google/android/recaptcha/internal/zzbb;Lcom/google/android/recaptcha/internal/zzba;Ljava/lang/String;)V

    .line 1
    throw p0
.end method

.method public static final synthetic zze(Lcom/google/android/recaptcha/internal/zzcv;Ljava/lang/String;Lcom/google/android/recaptcha/internal/zzbi;Lcom/google/android/recaptcha/internal/zzch;Lcom/google/android/recaptcha/internal/zzek;)Lcom/google/android/recaptcha/internal/zzcn;
    .locals 1

    .line 1
    iget-object p0, p0, Lcom/google/android/recaptcha/internal/zzcv;->zze:Lcom/google/android/recaptcha/internal/zzl;

    new-instance v0, Lcom/google/android/recaptcha/internal/zzdt;

    invoke-direct {v0, p1, p2, p4, p0}, Lcom/google/android/recaptcha/internal/zzdt;-><init>(Ljava/lang/String;Lcom/google/android/recaptcha/internal/zzbi;Lcom/google/android/recaptcha/internal/zzek;Lcom/google/android/recaptcha/internal/zzl;)V

    sget-object p0, Lcom/google/android/recaptcha/internal/zzch;->zza:Lcom/google/android/recaptcha/internal/zzch;

    .line 2
    invoke-static {p3, p0}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_0

    new-instance p0, Lcom/google/android/recaptcha/internal/zzef;

    .line 3
    invoke-direct {p0, v0}, Lcom/google/android/recaptcha/internal/zzef;-><init>(Lcom/google/android/recaptcha/internal/zzdt;)V

    check-cast p0, Lcom/google/android/recaptcha/internal/zzcn;

    return-object p0

    :cond_0
    new-instance p0, Lcom/google/android/recaptcha/internal/zzec;

    new-instance p1, Lcom/google/android/recaptcha/internal/zzbo;

    invoke-direct {p1}, Lcom/google/android/recaptcha/internal/zzbo;-><init>()V

    .line 4
    invoke-direct {p0, v0, p2, p4, p1}, Lcom/google/android/recaptcha/internal/zzec;-><init>(Lcom/google/android/recaptcha/internal/zzdt;Lcom/google/android/recaptcha/internal/zzbi;Lcom/google/android/recaptcha/internal/zzek;Lcom/google/android/recaptcha/internal/zzbo;)V

    .line 5
    check-cast p0, Lcom/google/android/recaptcha/internal/zzcn;

    return-object p0
.end method

.method public static synthetic zzf(Lcom/google/android/recaptcha/internal/zzcv;Ljava/lang/String;Lcom/google/android/recaptcha/internal/zzcn;Lcom/google/android/recaptcha/internal/zzbi;Lkotlin/coroutines/Continuation;ILjava/lang/Object;)Ljava/lang/Object;
    .locals 10
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/google/android/gms/common/api/ApiException;,
            Lcom/google/android/recaptcha/RecaptchaException;
        }
    .end annotation

    .line 1
    iget-object v5, p0, Lcom/google/android/recaptcha/internal/zzcv;->zzf:Lcom/google/android/recaptcha/internal/zzbi;

    sget-object v6, Lcom/google/android/recaptcha/internal/zzch;->zzb:Lcom/google/android/recaptcha/internal/zzch;

    const/4 v8, 0x2

    const/4 v9, 0x0

    const-wide/16 v2, 0x0

    const/4 v4, 0x0

    move-object v0, p0

    move-object v1, p1

    move-object v7, p4

    invoke-static/range {v0 .. v9}, Lcom/google/android/recaptcha/internal/zzcv;->zzh(Lcom/google/android/recaptcha/internal/zzcv;Ljava/lang/String;JLcom/google/android/recaptcha/internal/zzcn;Lcom/google/android/recaptcha/internal/zzbi;Lcom/google/android/recaptcha/internal/zzch;Lkotlin/coroutines/Continuation;ILjava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    return-object p0
.end method

.method public static synthetic zzh(Lcom/google/android/recaptcha/internal/zzcv;Ljava/lang/String;JLcom/google/android/recaptcha/internal/zzcn;Lcom/google/android/recaptcha/internal/zzbi;Lcom/google/android/recaptcha/internal/zzch;Lkotlin/coroutines/Continuation;ILjava/lang/Object;)Ljava/lang/Object;
    .locals 8
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lkotlinx/coroutines/TimeoutCancellationException;,
            Lcom/google/android/gms/common/api/ApiException;,
            Lcom/google/android/recaptcha/RecaptchaException;
        }
    .end annotation

    and-int/lit8 p4, p8, 0x8

    if-eqz p4, :cond_0

    .line 1
    iget-object p5, p0, Lcom/google/android/recaptcha/internal/zzcv;->zzf:Lcom/google/android/recaptcha/internal/zzbi;

    :cond_0
    move-object v5, p5

    and-int/lit8 p4, p8, 0x10

    if-eqz p4, :cond_1

    sget-object p6, Lcom/google/android/recaptcha/internal/zzch;->zza:Lcom/google/android/recaptcha/internal/zzch;

    :cond_1
    move-object v6, p6

    and-int/lit8 p4, p8, 0x2

    if-eqz p4, :cond_2

    const-wide/16 p2, 0x2710

    :cond_2
    move-wide v2, p2

    const/4 v4, 0x0

    move-object v0, p0

    move-object v1, p1

    move-object v7, p7

    invoke-virtual/range {v0 .. v7}, Lcom/google/android/recaptcha/internal/zzcv;->zzg(Ljava/lang/String;JLcom/google/android/recaptcha/internal/zzcn;Lcom/google/android/recaptcha/internal/zzbi;Lcom/google/android/recaptcha/internal/zzch;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object p0

    return-object p0
.end method

.method public static final synthetic zzi(Lcom/google/android/recaptcha/internal/zzcv;Ljava/lang/String;ILkotlin/jvm/functions/Function2;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
    .locals 0

    const/4 p1, 0x0

    const/4 p2, 0x0

    .line 1
    invoke-direct {p0, p1, p2, p1, p4}, Lcom/google/android/recaptcha/internal/zzcv;->zzj(Ljava/lang/String;ILkotlin/jvm/functions/Function2;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object p0

    return-object p0
.end method

.method private final zzj(Ljava/lang/String;ILkotlin/jvm/functions/Function2;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
    .locals 5

    instance-of v0, p4, Lcom/google/android/recaptcha/internal/zzcu;

    if-eqz v0, :cond_0

    move-object v0, p4

    check-cast v0, Lcom/google/android/recaptcha/internal/zzcu;

    iget v1, v0, Lcom/google/android/recaptcha/internal/zzcu;->zzc:I

    const/high16 v2, -0x80000000

    and-int v3, v1, v2

    if-eqz v3, :cond_0

    sub-int/2addr v1, v2

    iput v1, v0, Lcom/google/android/recaptcha/internal/zzcu;->zzc:I

    goto :goto_0

    .line 1
    :cond_0
    new-instance v0, Lcom/google/android/recaptcha/internal/zzcu;

    invoke-direct {v0, p0, p4}, Lcom/google/android/recaptcha/internal/zzcu;-><init>(Lcom/google/android/recaptcha/internal/zzcv;Lkotlin/coroutines/Continuation;)V

    .line 0
    :goto_0
    iget-object p4, v0, Lcom/google/android/recaptcha/internal/zzcu;->zza:Ljava/lang/Object;

    .line 1
    invoke-static {}, Lkotlin/coroutines/intrinsics/IntrinsicsKt;->getCOROUTINE_SUSPENDED()Ljava/lang/Object;

    move-result-object v1

    iget v2, v0, Lcom/google/android/recaptcha/internal/zzcu;->zzc:I

    const/4 v3, 0x1

    if-eqz v2, :cond_2

    if-ne v2, v3, :cond_1

    iget-object p1, v0, Lcom/google/android/recaptcha/internal/zzcu;->zzd:Lcom/google/android/recaptcha/internal/zzen;

    move-object p2, p1

    check-cast p2, Lcom/google/android/recaptcha/internal/zzen;

    :try_start_0
    invoke-static {p4}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V
    :try_end_0
    .catch Lcom/google/android/recaptcha/internal/zzbd; {:try_start_0 .. :try_end_0} :catch_1
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_1

    :catch_0
    move-exception p2

    goto :goto_2

    :catch_1
    move-exception p2

    goto :goto_3

    :cond_1
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string p2, "call to \'resume\' before \'invoke\' with coroutine"

    invoke-direct {p1, p2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1

    :cond_2
    invoke-static {p4}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V

    iget-object p4, p0, Lcom/google/android/recaptcha/internal/zzcv;->zzf:Lcom/google/android/recaptcha/internal/zzbi;

    .line 2
    invoke-direct {p0, p1, p4, p2}, Lcom/google/android/recaptcha/internal/zzcv;->zzk(Ljava/lang/String;Lcom/google/android/recaptcha/internal/zzbi;I)Lcom/google/android/recaptcha/internal/zzek;

    move-result-object p1

    const/4 p2, 0x6

    .line 3
    invoke-virtual {p1, p2}, Lcom/google/android/recaptcha/internal/zzek;->zzf(I)Lcom/google/android/recaptcha/internal/zzen;

    move-result-object p2

    .line 4
    :try_start_1
    iput-object p2, v0, Lcom/google/android/recaptcha/internal/zzcu;->zzd:Lcom/google/android/recaptcha/internal/zzen;

    iput v3, v0, Lcom/google/android/recaptcha/internal/zzcu;->zzc:I

    invoke-interface {p3, p1, v0}, Lkotlin/jvm/functions/Function2;->invoke(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p4
    :try_end_1
    .catch Lcom/google/android/recaptcha/internal/zzbd; {:try_start_1 .. :try_end_1} :catch_3
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_2

    if-eq p4, v1, :cond_3

    move-object p1, p2

    .line 5
    :goto_1
    :try_start_2
    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzen;->zza()V
    :try_end_2
    .catch Lcom/google/android/recaptcha/internal/zzbd; {:try_start_2 .. :try_end_2} :catch_1
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_0

    return-object p4

    :cond_3
    return-object v1

    :catch_2
    move-exception p1

    move-object v4, p2

    move-object p2, p1

    move-object p1, v4

    .line 6
    :goto_2
    new-instance p3, Lcom/google/android/recaptcha/internal/zzbd;

    sget-object p4, Lcom/google/android/recaptcha/internal/zzbb;->zzb:Lcom/google/android/recaptcha/internal/zzbb;

    sget-object v0, Lcom/google/android/recaptcha/internal/zzba;->zza:Lcom/google/android/recaptcha/internal/zzba;

    .line 7
    invoke-virtual {p2}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object p2

    invoke-direct {p3, p4, v0, p2}, Lcom/google/android/recaptcha/internal/zzbd;-><init>(Lcom/google/android/recaptcha/internal/zzbb;Lcom/google/android/recaptcha/internal/zzba;Ljava/lang/String;)V

    .line 8
    invoke-virtual {p1, p3}, Lcom/google/android/recaptcha/internal/zzen;->zzb(Lcom/google/android/recaptcha/internal/zzbd;)V

    .line 9
    invoke-virtual {p3}, Lcom/google/android/recaptcha/internal/zzbd;->zzc()Lcom/google/android/recaptcha/RecaptchaException;

    move-result-object p1

    throw p1

    :catch_3
    move-exception p1

    move-object v4, p2

    move-object p2, p1

    move-object p1, v4

    .line 10
    :goto_3
    invoke-virtual {p1, p2}, Lcom/google/android/recaptcha/internal/zzen;->zzb(Lcom/google/android/recaptcha/internal/zzbd;)V

    .line 11
    invoke-virtual {p2}, Lcom/google/android/recaptcha/internal/zzbd;->zzc()Lcom/google/android/recaptcha/RecaptchaException;

    move-result-object p1

    throw p1
.end method

.method private final zzk(Ljava/lang/String;Lcom/google/android/recaptcha/internal/zzbi;I)Lcom/google/android/recaptcha/internal/zzek;
    .locals 9

    .line 1
    invoke-static {}, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;

    move-result-object v0

    invoke-virtual {v0}, Ljava/util/UUID;->toString()Ljava/lang/String;

    move-result-object v4

    .line 2
    sget v0, Lcom/google/android/recaptcha/internal/zzav;->zza:I

    .line 3
    sget-object v0, Lcom/google/android/recaptcha/internal/zzcr;->zza:Lcom/google/android/recaptcha/internal/zzcr;

    check-cast v0, Lkotlin/jvm/functions/Function0;

    .line 2
    invoke-static {v0}, Lkotlin/LazyKt;->lazy(Lkotlin/jvm/functions/Function0;)Lkotlin/Lazy;

    move-result-object v0

    new-instance v1, Lcom/google/android/recaptcha/internal/zzes;

    iget-object v2, p0, Lcom/google/android/recaptcha/internal/zzcv;->zza:Landroid/app/Application;

    .line 4
    check-cast v2, Landroid/content/Context;

    new-instance v3, Lcom/google/android/recaptcha/internal/zzeu;

    .line 5
    invoke-interface {v0}, Lkotlin/Lazy;->getValue()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/google/android/recaptcha/internal/zzbr;

    .line 6
    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzbr;->zzc()Ljava/lang/String;

    move-result-object v0

    invoke-direct {v3, v0}, Lcom/google/android/recaptcha/internal/zzeu;-><init>(Ljava/lang/String;)V

    check-cast v3, Lcom/google/android/recaptcha/internal/zzet;

    .line 7
    invoke-virtual {p2}, Lcom/google/android/recaptcha/internal/zzbi;->zza()Lkotlinx/coroutines/CoroutineScope;

    move-result-object p2

    .line 8
    invoke-direct {v1, v2, v3, p2}, Lcom/google/android/recaptcha/internal/zzes;-><init>(Landroid/content/Context;Lcom/google/android/recaptcha/internal/zzet;Lkotlinx/coroutines/CoroutineScope;)V

    iget-object p2, p0, Lcom/google/android/recaptcha/internal/zzcv;->zza:Landroid/app/Application;

    .line 9
    move-object v6, p2

    check-cast v6, Landroid/content/Context;

    .line 10
    move-object v7, v1

    check-cast v7, Lcom/google/android/recaptcha/internal/zzeo;

    iget-object v3, p0, Lcom/google/android/recaptcha/internal/zzcv;->zzd:Ljava/lang/String;

    new-instance v1, Lcom/google/android/recaptcha/internal/zzek;

    const/4 v8, 0x0

    move-object v2, p1

    move v5, p3

    invoke-direct/range {v1 .. v8}, Lcom/google/android/recaptcha/internal/zzek;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILandroid/content/Context;Lcom/google/android/recaptcha/internal/zzeo;Lkotlin/jvm/internal/DefaultConstructorMarker;)V

    .line 11
    invoke-virtual {v1, v4}, Lcom/google/android/recaptcha/internal/zzek;->zzc(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zzek;

    return-object v1
.end method


# virtual methods
.method public final zzd()Lcom/google/android/recaptcha/internal/zzbi;
    .locals 1

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzcv;->zzf:Lcom/google/android/recaptcha/internal/zzbi;

    return-object v0
.end method

.method public final zzg(Ljava/lang/String;JLcom/google/android/recaptcha/internal/zzcn;Lcom/google/android/recaptcha/internal/zzbi;Lcom/google/android/recaptcha/internal/zzch;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;
    .locals 16
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lkotlinx/coroutines/TimeoutCancellationException;,
            Lcom/google/android/gms/common/api/ApiException;,
            Lcom/google/android/recaptcha/RecaptchaException;
        }
    .end annotation

    move-object/from16 v1, p0

    move-object/from16 v0, p7

    instance-of v2, v0, Lcom/google/android/recaptcha/internal/zzcs;

    if-eqz v2, :cond_0

    move-object v2, v0

    check-cast v2, Lcom/google/android/recaptcha/internal/zzcs;

    iget v3, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzg:I

    const/high16 v4, -0x80000000

    and-int v5, v3, v4

    if-eqz v5, :cond_0

    sub-int/2addr v3, v4

    iput v3, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzg:I

    goto :goto_0

    .line 1
    :cond_0
    new-instance v2, Lcom/google/android/recaptcha/internal/zzcs;

    invoke-direct {v2, v1, v0}, Lcom/google/android/recaptcha/internal/zzcs;-><init>(Lcom/google/android/recaptcha/internal/zzcv;Lkotlin/coroutines/Continuation;)V

    .line 0
    :goto_0
    iget-object v0, v2, Lcom/google/android/recaptcha/internal/zzcs;->zze:Ljava/lang/Object;

    .line 1
    invoke-static {}, Lkotlin/coroutines/intrinsics/IntrinsicsKt;->getCOROUTINE_SUSPENDED()Ljava/lang/Object;

    move-result-object v3

    iget v4, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzg:I

    const/4 v5, 0x1

    const/4 v6, 0x2

    const/4 v12, 0x0

    if-eqz v4, :cond_3

    if-eq v4, v5, :cond_2

    if-ne v4, v6, :cond_1

    iget-object v2, v2, Lcom/google/android/recaptcha/internal/zzcs;->zza:Ljava/lang/Object;

    check-cast v2, Lkotlinx/coroutines/sync/Mutex;

    :try_start_0
    invoke-static {v0}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto/16 :goto_3

    :catchall_0
    move-exception v0

    goto/16 :goto_4

    :cond_1
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v2, "call to \'resume\' before \'invoke\' with coroutine"

    invoke-direct {v0, v2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_2
    iget-wide v4, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzd:J

    iget-object v7, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzc:Ljava/lang/Object;

    check-cast v7, Lkotlinx/coroutines/sync/Mutex;

    iget-object v8, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzi:Lcom/google/android/recaptcha/internal/zzch;

    move-object v9, v8

    check-cast v9, Lcom/google/android/recaptcha/internal/zzch;

    iget-object v9, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzj:Lcom/google/android/recaptcha/internal/zzbi;

    move-object v10, v9

    check-cast v10, Lcom/google/android/recaptcha/internal/zzbi;

    iget-object v10, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzb:Ljava/lang/Object;

    move-object v10, v12

    check-cast v10, Lcom/google/android/recaptcha/internal/zzcn;

    iget-object v10, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzh:Ljava/lang/String;

    move-object v11, v10

    check-cast v11, Ljava/lang/String;

    iget-object v11, v2, Lcom/google/android/recaptcha/internal/zzcs;->zza:Ljava/lang/Object;

    check-cast v11, Lcom/google/android/recaptcha/internal/zzcv;

    invoke-static {v0}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V

    move-object v14, v8

    move-object v13, v9

    move-object v9, v10

    move-object v8, v11

    move-wide v10, v4

    move-object v4, v7

    goto :goto_1

    :cond_3
    invoke-static {v0}, Lkotlin/ResultKt;->throwOnFailure(Ljava/lang/Object;)V

    iget-object v0, v1, Lcom/google/android/recaptcha/internal/zzcv;->zzb:Lkotlinx/coroutines/sync/Mutex;

    .line 2
    iput-object v1, v2, Lcom/google/android/recaptcha/internal/zzcs;->zza:Ljava/lang/Object;

    move-object/from16 v4, p1

    iput-object v4, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzh:Ljava/lang/String;

    iput-object v12, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzb:Ljava/lang/Object;

    move-object/from16 v7, p5

    iput-object v7, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzj:Lcom/google/android/recaptcha/internal/zzbi;

    move-object/from16 v8, p6

    iput-object v8, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzi:Lcom/google/android/recaptcha/internal/zzch;

    iput-object v0, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzc:Ljava/lang/Object;

    move-wide/from16 v9, p2

    iput-wide v9, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzd:J

    iput v5, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzg:I

    invoke-interface {v0, v12, v2}, Lkotlinx/coroutines/sync/Mutex;->lock(Ljava/lang/Object;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object v5

    if-eq v5, v3, :cond_6

    move-object v13, v7

    move-object v14, v8

    move-wide v10, v9

    move-object v8, v1

    move-object v9, v4

    move-object v4, v0

    :goto_1
    :try_start_1
    sget-object v0, Lcom/google/android/recaptcha/internal/zzch;->zza:Lcom/google/android/recaptcha/internal/zzch;

    .line 3
    invoke-static {v14, v0}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_4

    const/4 v0, 0x3

    goto :goto_2

    .line 6
    :cond_4
    sget-object v0, Lcom/google/android/recaptcha/internal/zzch;->zzb:Lcom/google/android/recaptcha/internal/zzch;

    .line 4
    invoke-static {v14, v0}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_5

    const/4 v0, 0x4

    goto :goto_2

    :cond_5
    move v0, v6

    .line 5
    :goto_2
    new-instance v7, Lcom/google/android/recaptcha/internal/zzct;

    const/4 v15, 0x0

    invoke-direct/range {v7 .. v15}, Lcom/google/android/recaptcha/internal/zzct;-><init>(Lcom/google/android/recaptcha/internal/zzcv;Ljava/lang/String;JLcom/google/android/recaptcha/internal/zzcn;Lcom/google/android/recaptcha/internal/zzbi;Lcom/google/android/recaptcha/internal/zzch;Lkotlin/coroutines/Continuation;)V

    check-cast v7, Lkotlin/jvm/functions/Function2;

    iput-object v4, v2, Lcom/google/android/recaptcha/internal/zzcs;->zza:Ljava/lang/Object;

    iput-object v12, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzh:Ljava/lang/String;

    iput-object v12, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzb:Ljava/lang/Object;

    iput-object v12, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzj:Lcom/google/android/recaptcha/internal/zzbi;

    iput-object v12, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzi:Lcom/google/android/recaptcha/internal/zzch;

    iput-object v12, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzc:Ljava/lang/Object;

    iput v6, v2, Lcom/google/android/recaptcha/internal/zzcs;->zzg:I

    invoke-direct {v8, v9, v0, v7, v2}, Lcom/google/android/recaptcha/internal/zzcv;->zzj(Ljava/lang/String;ILkotlin/jvm/functions/Function2;Lkotlin/coroutines/Continuation;)Ljava/lang/Object;

    move-result-object v0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    if-eq v0, v3, :cond_6

    move-object v2, v4

    .line 1
    :goto_3
    :try_start_2
    check-cast v0, Lcom/google/android/recaptcha/internal/zzdc;
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    .line 6
    invoke-interface {v2, v12}, Lkotlinx/coroutines/sync/Mutex;->unlock(Ljava/lang/Object;)V

    return-object v0

    :catchall_1
    move-exception v0

    move-object v2, v4

    :goto_4
    invoke-interface {v2, v12}, Lkotlinx/coroutines/sync/Mutex;->unlock(Ljava/lang/Object;)V

    throw v0

    :cond_6
    return-object v3
.end method
