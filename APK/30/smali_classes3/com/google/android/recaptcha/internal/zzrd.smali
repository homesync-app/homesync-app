.class public final Lcom/google/android/recaptcha/internal/zzrd;
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

.method synthetic constructor <init>(Lcom/google/android/recaptcha/internal/zzre;)V
    .locals 0

    .line 1
    invoke-static {}, Lcom/google/android/recaptcha/internal/zzrf;->zzj()Lcom/google/android/recaptcha/internal/zzrf;

    move-result-object p1

    invoke-direct {p0, p1}, Lcom/google/android/recaptcha/internal/zzmx;-><init>(Lcom/google/android/recaptcha/internal/zznd;)V

    return-void
.end method


# virtual methods
.method public final zze()I
    .locals 1

    .line 1
    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzrd;->zza:Lcom/google/android/recaptcha/internal/zznd;

    check-cast v0, Lcom/google/android/recaptcha/internal/zzrf;

    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzrf;->zzf()I

    move-result v0

    return v0
.end method

.method public final zzf()I
    .locals 1

    .line 1
    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzrd;->zza:Lcom/google/android/recaptcha/internal/zznd;

    check-cast v0, Lcom/google/android/recaptcha/internal/zzrf;

    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzrf;->zzg()I

    move-result v0

    return v0
.end method

.method public final zzq(Lcom/google/android/recaptcha/internal/zzrc;)Lcom/google/android/recaptcha/internal/zzrd;
    .locals 1

    .line 1
    invoke-virtual {p0}, Lcom/google/android/recaptcha/internal/zzmx;->zzn()V

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzrd;->zza:Lcom/google/android/recaptcha/internal/zznd;

    .line 2
    check-cast v0, Lcom/google/android/recaptcha/internal/zzrf;

    invoke-static {v0, p1}, Lcom/google/android/recaptcha/internal/zzrf;->zzM(Lcom/google/android/recaptcha/internal/zzrf;Lcom/google/android/recaptcha/internal/zzrc;)V

    return-object p0
.end method

.method public final zzr(Lcom/google/android/recaptcha/internal/zzrr;)Lcom/google/android/recaptcha/internal/zzrd;
    .locals 1

    .line 1
    invoke-virtual {p0}, Lcom/google/android/recaptcha/internal/zzmx;->zzn()V

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzrd;->zza:Lcom/google/android/recaptcha/internal/zznd;

    .line 2
    check-cast v0, Lcom/google/android/recaptcha/internal/zzrf;

    invoke-static {v0, p1}, Lcom/google/android/recaptcha/internal/zzrf;->zzN(Lcom/google/android/recaptcha/internal/zzrf;Lcom/google/android/recaptcha/internal/zzrr;)V

    return-object p0
.end method
