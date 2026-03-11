.class final Lcom/google/android/gms/internal/firebase-auth-api/zzy;
.super Lcom/google/android/gms/internal/firebase-auth-api/zzaa;
.source "com.google.firebase:firebase-auth@@24.0.1"


# instance fields
.field private final synthetic zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzf;


# direct methods
.method constructor <init>(Lcom/google/android/gms/internal/firebase-auth-api/zzt;Ljava/lang/CharSequence;Lcom/google/android/gms/internal/firebase-auth-api/zzf;)V
    .locals 0

    .line 3
    iput-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzy;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzf;

    invoke-direct {p0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;-><init>(Lcom/google/android/gms/internal/firebase-auth-api/zzt;Ljava/lang/CharSequence;)V

    return-void
.end method


# virtual methods
.method final zza(I)I
    .locals 0

    add-int/lit8 p1, p1, 0x1

    return p1
.end method

.method final zzb(I)I
    .locals 2

    .line 2
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzy;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzf;

    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzy;->zza:Ljava/lang/CharSequence;

    invoke-virtual {v0, v1, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzf;->zza(Ljava/lang/CharSequence;I)I

    move-result p1

    return p1
.end method
