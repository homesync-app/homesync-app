.class public final synthetic Lcom/google/android/gms/internal/firebase-auth-api/zzpc;
.super Ljava/lang/Object;
.source "com.google.firebase:firebase-auth@@24.0.1"

# interfaces
.implements Lcom/google/android/gms/internal/firebase-auth-api/zzqo;


# direct methods
.method public synthetic constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public final zza()Ljava/lang/Object;
    .locals 4

    .line 1
    new-instance v0, Lcom/google/android/gms/internal/firebase-auth-api/zzoz;

    invoke-direct {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzoz;-><init>()V

    .line 2
    new-instance v1, Lcom/google/android/gms/internal/firebase-auth-api/zzpb;

    invoke-direct {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzpb;-><init>()V

    const-class v2, Lcom/google/android/gms/internal/firebase-auth-api/zzof;

    const-class v3, Lcom/google/android/gms/internal/firebase-auth-api/zzqb;

    .line 3
    invoke-static {v1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zznx;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zznz;Ljava/lang/Class;Ljava/lang/Class;)Lcom/google/android/gms/internal/firebase-auth-api/zznx;

    move-result-object v1

    .line 4
    invoke-virtual {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzoz;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zznx;)V

    return-object v0
.end method
