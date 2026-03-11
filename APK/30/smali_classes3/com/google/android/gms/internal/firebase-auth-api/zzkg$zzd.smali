.class public final Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;
.super Ljava/lang/Object;
.source "com.google.firebase:firebase-auth@@24.0.1"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/google/android/gms/internal/firebase-auth-api/zzkg;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "zzd"
.end annotation


# instance fields
.field private zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

.field private zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

.field private zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

.field private zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;


# direct methods
.method private constructor <init>()V
    .locals 1

    .line 18
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const/4 v0, 0x0

    .line 19
    iput-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    .line 20
    iput-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    .line 21
    iput-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    .line 22
    sget-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    iput-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    return-void
.end method

.method synthetic constructor <init>(Lcom/google/android/gms/internal/firebase-auth-api/zzkj;)V
    .locals 0

    invoke-direct {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;-><init>()V

    return-void
.end method


# virtual methods
.method public final zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;
    .locals 0

    .line 1
    iput-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    return-object p0
.end method

.method public final zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;
    .locals 0

    .line 3
    iput-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    return-object p0
.end method

.method public final zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;
    .locals 0

    .line 7
    iput-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    return-object p0
.end method

.method public final zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;
    .locals 0

    .line 5
    iput-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    return-object p0
.end method

.method public final zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkg;
    .locals 7
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/security/GeneralSecurityException;
        }
    .end annotation

    .line 9
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    if-eqz v0, :cond_3

    .line 11
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    if-eqz v0, :cond_2

    .line 13
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    if-eqz v0, :cond_1

    .line 15
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    if-eqz v0, :cond_0

    .line 17
    new-instance v1, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    iget-object v2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    iget-object v3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    iget-object v4, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    iget-object v5, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    const/4 v6, 0x0

    invoke-direct/range {v1 .. v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;-><init>(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;Lcom/google/android/gms/internal/firebase-auth-api/zzkj;)V

    return-object v1

    .line 16
    :cond_0
    new-instance v0, Ljava/security/GeneralSecurityException;

    const-string v1, "HPKE variant is not set"

    invoke-direct {v0, v1}, Ljava/security/GeneralSecurityException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 14
    :cond_1
    new-instance v0, Ljava/security/GeneralSecurityException;

    const-string v1, "HPKE AEAD parameter is not set"

    invoke-direct {v0, v1}, Ljava/security/GeneralSecurityException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 12
    :cond_2
    new-instance v0, Ljava/security/GeneralSecurityException;

    const-string v1, "HPKE KDF parameter is not set"

    invoke-direct {v0, v1}, Ljava/security/GeneralSecurityException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 10
    :cond_3
    new-instance v0, Ljava/security/GeneralSecurityException;

    const-string v1, "HPKE KEM parameter is not set"

    invoke-direct {v0, v1}, Ljava/security/GeneralSecurityException;-><init>(Ljava/lang/String;)V

    throw v0
.end method
