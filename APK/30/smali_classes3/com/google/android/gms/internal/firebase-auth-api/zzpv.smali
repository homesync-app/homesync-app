.class public final synthetic Lcom/google/android/gms/internal/firebase-auth-api/zzpv;
.super Ljava/lang/Object;
.source "com.google.firebase:firebase-auth@@24.0.1"

# interfaces
.implements Lcom/google/android/gms/internal/firebase-auth-api/zzqc;


# instance fields
.field private synthetic zza:Lcom/google/android/gms/internal/firebase-auth-api/zzpw;

.field private synthetic zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzpz;


# direct methods
.method public synthetic constructor <init>(Lcom/google/android/gms/internal/firebase-auth-api/zzpw;Lcom/google/android/gms/internal/firebase-auth-api/zzpz;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzpv;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzpw;

    iput-object p2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzpv;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzpz;

    return-void
.end method


# virtual methods
.method public final zza(Lcom/google/android/gms/internal/firebase-auth-api/zzoa;)Ljava/lang/Object;
    .locals 2

    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzpv;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzpw;

    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzpv;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzpz;

    invoke-static {v0, v1, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzpw;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzpw;Lcom/google/android/gms/internal/firebase-auth-api/zzpz;Lcom/google/android/gms/internal/firebase-auth-api/zzoa;)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method
