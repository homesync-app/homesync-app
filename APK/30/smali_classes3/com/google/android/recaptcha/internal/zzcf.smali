.class public final Lcom/google/android/recaptcha/internal/zzcf;
.super Ljava/lang/Object;
.source "com.google.android.recaptcha:recaptcha@@18.6.1"


# direct methods
.method public static final zza(Ljava/lang/String;Lcom/google/android/recaptcha/internal/zzle;)Ljava/lang/String;
    .locals 2

    .line 1
    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzle;->zzl()[B

    move-result-object p1

    new-instance v0, Lcom/google/android/recaptcha/internal/zzqd;

    invoke-direct {v0}, Lcom/google/android/recaptcha/internal/zzqd;-><init>()V

    move-object v1, v0

    check-cast v1, Lcom/google/android/recaptcha/internal/zzqd;

    invoke-static {p0, p1, v0}, Lcom/google/android/recaptcha/internal/zzqc;->zzf(Ljava/lang/String;[BLcom/google/android/recaptcha/internal/zzqd;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method
