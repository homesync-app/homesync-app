.class public final synthetic Lcom/google/android/gms/internal/firebase-auth-api/zzbl;
.super Ljava/lang/Object;
.source "com.google.firebase:firebase-auth@@24.0.1"

# interfaces
.implements Lcom/google/android/gms/internal/firebase-auth-api/zzbu;


# instance fields
.field private synthetic zza:Lcom/google/android/gms/internal/firebase-auth-api/zzbm;

.field private synthetic zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzok;


# direct methods
.method public synthetic constructor <init>(Lcom/google/android/gms/internal/firebase-auth-api/zzbm;Lcom/google/android/gms/internal/firebase-auth-api/zzok;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzbl;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzbm;

    iput-object p2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzbl;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzok;

    return-void
.end method


# virtual methods
.method public final zza(Lcom/google/android/gms/internal/firebase-auth-api/zzbs;)V
    .locals 5

    .line 1
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzbl;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzbm;

    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzbl;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzok;

    .line 2
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzow;->zzb()Lcom/google/android/gms/internal/firebase-auth-api/zzow;

    move-result-object v2

    invoke-virtual {v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzow;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzol;

    move-result-object v2

    .line 3
    const-string v3, "keyset_handle"

    const-string v4, "get_key"

    .line 4
    invoke-interface {v2, v0, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzol;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzob;Lcom/google/android/gms/internal/firebase-auth-api/zzok;Ljava/lang/String;Ljava/lang/String;)Lcom/google/android/gms/internal/firebase-auth-api/zzoo;

    move-result-object v0

    .line 5
    invoke-virtual {p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzbs;->zza()I

    move-result p1

    invoke-interface {v0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzoo;->zza(I)V

    return-void
.end method
