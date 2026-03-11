.class public final Lcom/google/android/gms/internal/firebase-auth-api/zzjq;
.super Ljava/lang/Object;
.source "com.google.firebase:firebase-auth@@24.0.1"


# static fields
.field public static final zza:Lcom/google/android/gms/internal/firebase-auth-api/zzjf;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .line 6
    new-instance v0, Lcom/google/android/gms/internal/firebase-auth-api/zzjp;

    invoke-direct {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzjp;-><init>()V

    .line 7
    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzql;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzqo;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/google/android/gms/internal/firebase-auth-api/zzjf;

    sput-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzjq;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzjf;

    return-void
.end method

.method static synthetic zza()Lcom/google/android/gms/internal/firebase-auth-api/zzjf;
    .locals 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/lang/Exception;
        }
    .end annotation

    .line 1
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzjf;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzjf$zzb;

    move-result-object v0

    const/16 v1, 0x40

    .line 2
    invoke-virtual {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzjf$zzb;->zza(I)Lcom/google/android/gms/internal/firebase-auth-api/zzjf$zzb;

    move-result-object v0

    sget-object v1, Lcom/google/android/gms/internal/firebase-auth-api/zzjf$zza;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzjf$zza;

    .line 3
    invoke-virtual {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzjf$zzb;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzjf$zza;)Lcom/google/android/gms/internal/firebase-auth-api/zzjf$zzb;

    move-result-object v0

    .line 4
    invoke-virtual {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzjf$zzb;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzjf;

    move-result-object v0

    return-object v0
.end method
