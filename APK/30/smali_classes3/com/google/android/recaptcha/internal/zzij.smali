.class public final Lcom/google/android/recaptcha/internal/zzij;
.super Ljava/lang/Object;
.source "com.google.android.recaptcha:recaptcha@@18.6.1"


# instance fields
.field final synthetic zza:Lcom/google/android/recaptcha/internal/zzja;

.field private zzb:Ljava/lang/Long;

.field private final zzc:Lcom/google/android/recaptcha/internal/zzjh;


# direct methods
.method public constructor <init>(Lcom/google/android/recaptcha/internal/zzja;)V
    .locals 0

    .line 1
    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzij;->zza:Lcom/google/android/recaptcha/internal/zzja;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    invoke-static {}, Lcom/google/android/recaptcha/internal/zzjh;->zzb()Lcom/google/android/recaptcha/internal/zzjh;

    move-result-object p1

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzij;->zzc:Lcom/google/android/recaptcha/internal/zzjh;

    return-void
.end method

.method private final zzb()V
    .locals 2

    .line 1
    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzij;->zzb:Ljava/lang/Long;

    if-nez v0, :cond_0

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzij;->zzc:Lcom/google/android/recaptcha/internal/zzjh;

    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzjh;->zzf()Lcom/google/android/recaptcha/internal/zzjh;

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzij;->zzc:Lcom/google/android/recaptcha/internal/zzjh;

    sget-object v1, Ljava/util/concurrent/TimeUnit;->MILLISECONDS:Ljava/util/concurrent/TimeUnit;

    .line 2
    invoke-virtual {v0, v1}, Lcom/google/android/recaptcha/internal/zzjh;->zza(Ljava/util/concurrent/TimeUnit;)J

    move-result-wide v0

    invoke-static {v0, v1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v0

    iput-object v0, p0, Lcom/google/android/recaptcha/internal/zzij;->zzb:Ljava/lang/Long;

    :cond_0
    return-void
.end method


# virtual methods
.method public final zza()Ljava/lang/Long;
    .locals 1

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzij;->zzb:Ljava/lang/Long;

    return-object v0
.end method

.method public final zzlce(Ljava/lang/String;)V
    .locals 2
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .line 1
    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzij;->zza:Lcom/google/android/recaptcha/internal/zzja;

    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzja;->zzq()Lcom/google/android/recaptcha/internal/zzij;

    move-result-object v1

    iget-object v1, v1, Lcom/google/android/recaptcha/internal/zzij;->zzb:Ljava/lang/Long;

    if-nez v1, :cond_1

    invoke-static {v0}, Lcom/google/android/recaptcha/internal/zzja;->zzo(Lcom/google/android/recaptcha/internal/zzja;)Lcom/google/android/recaptcha/internal/zzen;

    move-result-object v0

    if-eqz v0, :cond_0

    .line 2
    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzen;->zza()V

    :cond_0
    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzij;->zza:Lcom/google/android/recaptcha/internal/zzja;

    const/4 v1, 0x0

    .line 3
    invoke-static {v0, v1}, Lcom/google/android/recaptcha/internal/zzja;->zzB(Lcom/google/android/recaptcha/internal/zzja;Lcom/google/android/recaptcha/internal/zzen;)V

    .line 4
    :cond_1
    invoke-direct {p0}, Lcom/google/android/recaptcha/internal/zzij;->zzb()V

    .line 5
    invoke-static {p1}, Lcom/google/android/recaptcha/internal/zzbt;->zza(Ljava/lang/String;)[B

    move-result-object p1

    invoke-static {p1}, Lcom/google/android/recaptcha/internal/zzrc;->zzl([B)Lcom/google/android/recaptcha/internal/zzrc;

    move-result-object p1

    .line 6
    invoke-static {}, Lcom/google/android/recaptcha/internal/zztx;->zzi()Lcom/google/android/recaptcha/internal/zztw;

    move-result-object v0

    invoke-virtual {v0, p1}, Lcom/google/android/recaptcha/internal/zztw;->zzf(Lcom/google/android/recaptcha/internal/zzrc;)Lcom/google/android/recaptcha/internal/zztw;

    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzmx;->zzi()Lcom/google/android/recaptcha/internal/zznd;

    move-result-object p1

    check-cast p1, Lcom/google/android/recaptcha/internal/zztx;

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzij;->zza:Lcom/google/android/recaptcha/internal/zzja;

    invoke-static {v0}, Lcom/google/android/recaptcha/internal/zzja;->zzn(Lcom/google/android/recaptcha/internal/zzja;)Lcom/google/android/recaptcha/internal/zzek;

    move-result-object v0

    .line 7
    invoke-virtual {v0, p1}, Lcom/google/android/recaptcha/internal/zzek;->zze(Lcom/google/android/recaptcha/internal/zztx;)V

    return-void
.end method

.method public final zzlsm(Ljava/lang/String;)V
    .locals 1
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .line 1
    invoke-direct {p0}, Lcom/google/android/recaptcha/internal/zzij;->zzb()V

    .line 2
    invoke-static {}, Lcom/google/android/recaptcha/internal/zztx;->zzi()Lcom/google/android/recaptcha/internal/zztw;

    move-result-object v0

    .line 3
    invoke-static {p1}, Lcom/google/android/recaptcha/internal/zzbt;->zza(Ljava/lang/String;)[B

    move-result-object p1

    invoke-static {p1}, Lcom/google/android/recaptcha/internal/zzrr;->zzi([B)Lcom/google/android/recaptcha/internal/zzrr;

    move-result-object p1

    invoke-virtual {v0, p1}, Lcom/google/android/recaptcha/internal/zztw;->zzq(Lcom/google/android/recaptcha/internal/zzrr;)Lcom/google/android/recaptcha/internal/zztw;

    .line 4
    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzmx;->zzi()Lcom/google/android/recaptcha/internal/zznd;

    move-result-object p1

    .line 5
    check-cast p1, Lcom/google/android/recaptcha/internal/zztx;

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzij;->zza:Lcom/google/android/recaptcha/internal/zzja;

    invoke-static {v0}, Lcom/google/android/recaptcha/internal/zzja;->zzn(Lcom/google/android/recaptcha/internal/zzja;)Lcom/google/android/recaptcha/internal/zzek;

    move-result-object v0

    .line 6
    invoke-virtual {v0, p1}, Lcom/google/android/recaptcha/internal/zzek;->zze(Lcom/google/android/recaptcha/internal/zztx;)V

    return-void
.end method

.method public final zzoid(Ljava/lang/String;)V
    .locals 2
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .line 1
    invoke-direct {p0}, Lcom/google/android/recaptcha/internal/zzij;->zzb()V

    .line 2
    invoke-static {p1}, Lcom/google/android/recaptcha/internal/zzbt;->zza(Ljava/lang/String;)[B

    move-result-object p1

    invoke-static {p1}, Lcom/google/android/recaptcha/internal/zzts;->zzg([B)Lcom/google/android/recaptcha/internal/zzts;

    move-result-object p1

    .line 3
    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzts;->zzi()Lcom/google/android/recaptcha/internal/zztv;

    move-result-object v0

    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zztv;->name()Ljava/lang/String;

    .line 4
    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzts;->zzi()Lcom/google/android/recaptcha/internal/zztv;

    move-result-object v0

    sget-object v1, Lcom/google/android/recaptcha/internal/zztv;->zzb:Lcom/google/android/recaptcha/internal/zztv;

    if-ne v0, v1, :cond_1

    iget-object p1, p0, Lcom/google/android/recaptcha/internal/zzij;->zza:Lcom/google/android/recaptcha/internal/zzja;

    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzja;->zzA()Lkotlinx/coroutines/CompletableDeferred;

    move-result-object p1

    .line 5
    invoke-virtual {p1}, Ljava/lang/Object;->hashCode()I

    iget-object p1, p0, Lcom/google/android/recaptcha/internal/zzij;->zza:Lcom/google/android/recaptcha/internal/zzja;

    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzja;->zzA()Lkotlinx/coroutines/CompletableDeferred;

    move-result-object p1

    .line 6
    sget-object v0, Lkotlin/Unit;->INSTANCE:Lkotlin/Unit;

    invoke-interface {p1, v0}, Lkotlinx/coroutines/CompletableDeferred;->complete(Ljava/lang/Object;)Z

    move-result p1

    if-nez p1, :cond_0

    iget-object p1, p0, Lcom/google/android/recaptcha/internal/zzij;->zza:Lcom/google/android/recaptcha/internal/zzja;

    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzja;->zzA()Lkotlinx/coroutines/CompletableDeferred;

    move-result-object p1

    .line 7
    invoke-virtual {p1}, Ljava/lang/Object;->hashCode()I

    :cond_0
    return-void

    .line 8
    :cond_1
    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzts;->zzi()Lcom/google/android/recaptcha/internal/zztv;

    move-result-object v0

    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zztv;->name()Ljava/lang/String;

    .line 9
    sget v0, Lcom/google/android/recaptcha/internal/zzbd;->zza:I

    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzts;->zzi()Lcom/google/android/recaptcha/internal/zztv;

    move-result-object p1

    invoke-static {p1}, Lcom/google/android/recaptcha/internal/zzbc;->zza(Lcom/google/android/recaptcha/internal/zztv;)Lcom/google/android/recaptcha/internal/zzbd;

    move-result-object p1

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzij;->zza:Lcom/google/android/recaptcha/internal/zzja;

    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzja;->zzA()Lkotlinx/coroutines/CompletableDeferred;

    move-result-object v0

    .line 10
    invoke-virtual {v0}, Ljava/lang/Object;->hashCode()I

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzij;->zza:Lcom/google/android/recaptcha/internal/zzja;

    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzja;->zzA()Lkotlinx/coroutines/CompletableDeferred;

    move-result-object v0

    .line 11
    check-cast p1, Ljava/lang/Throwable;

    invoke-interface {v0, p1}, Lkotlinx/coroutines/CompletableDeferred;->completeExceptionally(Ljava/lang/Throwable;)Z

    return-void
.end method

.method public final zzrp(Ljava/lang/String;)V
    .locals 1
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .line 1
    invoke-direct {p0}, Lcom/google/android/recaptcha/internal/zzij;->zzb()V

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzij;->zza:Lcom/google/android/recaptcha/internal/zzja;

    iget-object v0, v0, Lcom/google/android/recaptcha/internal/zzja;->zzb:Lcom/google/android/recaptcha/internal/zzfo;

    if-nez v0, :cond_0

    const/4 v0, 0x0

    .line 2
    :cond_0
    invoke-interface {v0, p1}, Lcom/google/android/recaptcha/internal/zzfo;->zza(Ljava/lang/String;)V

    return-void
.end method

.method public final zzscd(Ljava/lang/String;)V
    .locals 2
    .annotation runtime Landroid/webkit/JavascriptInterface;
    .end annotation

    .line 1
    invoke-direct {p0}, Lcom/google/android/recaptcha/internal/zzij;->zzb()V

    .line 2
    invoke-static {p1}, Lcom/google/android/recaptcha/internal/zzbt;->zza(Ljava/lang/String;)[B

    move-result-object p1

    invoke-static {p1}, Lcom/google/android/recaptcha/internal/zzsi;->zzi([B)Lcom/google/android/recaptcha/internal/zzsi;

    move-result-object p1

    .line 3
    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zznd;->toString()Ljava/lang/String;

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzij;->zza:Lcom/google/android/recaptcha/internal/zzja;

    invoke-static {v0}, Lcom/google/android/recaptcha/internal/zzja;->zzz(Lcom/google/android/recaptcha/internal/zzja;)Ljava/util/Map;

    move-result-object v0

    .line 4
    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzsi;->zzk()Ljava/lang/String;

    move-result-object v1

    invoke-interface {v0, v1}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    .line 5
    check-cast v0, Lkotlinx/coroutines/CompletableDeferred;

    if-eqz v0, :cond_0

    .line 6
    invoke-interface {v0, p1}, Lkotlinx/coroutines/CompletableDeferred;->complete(Ljava/lang/Object;)Z

    :cond_0
    return-void
.end method
