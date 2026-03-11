.class public final Lcom/google/android/recaptcha/internal/zzsv;
.super Lcom/google/android/recaptcha/internal/zzmx;
.source "com.google.android.recaptcha:recaptcha@@18.6.1"

# interfaces
.implements Lcom/google/android/recaptcha/internal/zzoj;


# direct methods
.method private constructor <init>()V
    .locals 1

    const/4 v0, 0x0

    throw v0
.end method

.method synthetic constructor <init>(Lcom/google/android/recaptcha/internal/zzta;)V
    .locals 0

    .line 1
    invoke-static {}, Lcom/google/android/recaptcha/internal/zzsx;->zzg()Lcom/google/android/recaptcha/internal/zzsx;

    move-result-object p1

    invoke-direct {p0, p1}, Lcom/google/android/recaptcha/internal/zzmx;-><init>(Lcom/google/android/recaptcha/internal/zznd;)V

    return-void
.end method


# virtual methods
.method public final zze(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zzsv;
    .locals 1

    .line 1
    invoke-virtual {p0}, Lcom/google/android/recaptcha/internal/zzmx;->zzn()V

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzsv;->zza:Lcom/google/android/recaptcha/internal/zznd;

    .line 2
    check-cast v0, Lcom/google/android/recaptcha/internal/zzsx;

    invoke-static {v0, p1}, Lcom/google/android/recaptcha/internal/zzsx;->zzi(Lcom/google/android/recaptcha/internal/zzsx;Ljava/lang/String;)V

    return-object p0
.end method

.method public final zzf(Ljava/lang/String;)Lcom/google/android/recaptcha/internal/zzsv;
    .locals 1

    .line 1
    invoke-virtual {p0}, Lcom/google/android/recaptcha/internal/zzmx;->zzn()V

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzsv;->zza:Lcom/google/android/recaptcha/internal/zznd;

    .line 2
    check-cast v0, Lcom/google/android/recaptcha/internal/zzsx;

    invoke-static {v0, p1}, Lcom/google/android/recaptcha/internal/zzsx;->zzj(Lcom/google/android/recaptcha/internal/zzsx;Ljava/lang/String;)V

    return-object p0
.end method

.method public final zzq(I)Lcom/google/android/recaptcha/internal/zzsv;
    .locals 1

    .line 1
    invoke-virtual {p0}, Lcom/google/android/recaptcha/internal/zzmx;->zzn()V

    iget-object p1, p0, Lcom/google/android/recaptcha/internal/zzsv;->zza:Lcom/google/android/recaptcha/internal/zznd;

    .line 2
    check-cast p1, Lcom/google/android/recaptcha/internal/zzsx;

    const/4 v0, 0x3

    invoke-static {p1, v0}, Lcom/google/android/recaptcha/internal/zzsx;->zzk(Lcom/google/android/recaptcha/internal/zzsx;I)V

    return-object p0
.end method
