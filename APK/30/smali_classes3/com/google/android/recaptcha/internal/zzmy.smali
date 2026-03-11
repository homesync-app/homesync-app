.class public final Lcom/google/android/recaptcha/internal/zzmy;
.super Lcom/google/android/recaptcha/internal/zzkq;
.source "com.google.android.recaptcha:recaptcha@@18.6.1"


# instance fields
.field private final zza:Lcom/google/android/recaptcha/internal/zznd;


# direct methods
.method public constructor <init>(Lcom/google/android/recaptcha/internal/zznd;)V
    .locals 0

    invoke-direct {p0}, Lcom/google/android/recaptcha/internal/zzkq;-><init>()V

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzmy;->zza:Lcom/google/android/recaptcha/internal/zznd;

    return-void
.end method


# virtual methods
.method public final bridge synthetic zza([BIILcom/google/android/recaptcha/internal/zzmo;)Lcom/google/android/recaptcha/internal/zzoi;
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/google/android/recaptcha/internal/zznn;
        }
    .end annotation

    .line 1
    iget-object p2, p0, Lcom/google/android/recaptcha/internal/zzmy;->zza:Lcom/google/android/recaptcha/internal/zznd;

    const/4 v0, 0x0

    invoke-static {p2, p1, v0, p3, p4}, Lcom/google/android/recaptcha/internal/zznd;->zzt(Lcom/google/android/recaptcha/internal/zznd;[BIILcom/google/android/recaptcha/internal/zzmo;)Lcom/google/android/recaptcha/internal/zznd;

    move-result-object p1

    return-object p1
.end method
