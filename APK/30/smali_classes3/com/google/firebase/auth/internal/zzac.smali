.class public final Lcom/google/firebase/auth/internal/zzac;
.super Lcom/google/firebase/auth/FirebaseAuthSettings;
.source "com.google.firebase:firebase-auth@@24.0.1"


# instance fields
.field private zza:Ljava/lang/String;

.field private zzb:Ljava/lang/String;

.field private zzc:Z

.field private zzd:Z


# direct methods
.method public constructor <init>()V
    .locals 1

    .line 3
    invoke-direct {p0}, Lcom/google/firebase/auth/FirebaseAuthSettings;-><init>()V

    const/4 v0, 0x0

    .line 4
    iput-boolean v0, p0, Lcom/google/firebase/auth/internal/zzac;->zzc:Z

    .line 5
    iput-boolean v0, p0, Lcom/google/firebase/auth/internal/zzac;->zzd:Z

    return-void
.end method


# virtual methods
.method public final forceRecaptchaFlowForTesting(Z)V
    .locals 0

    .line 7
    iput-boolean p1, p0, Lcom/google/firebase/auth/internal/zzac;->zzd:Z

    return-void
.end method

.method public final setAppVerificationDisabledForTesting(Z)V
    .locals 0

    .line 9
    iput-boolean p1, p0, Lcom/google/firebase/auth/internal/zzac;->zzc:Z

    return-void
.end method

.method public final setAutoRetrievedSmsCodeForPhoneNumber(Ljava/lang/String;Ljava/lang/String;)V
    .locals 0

    .line 11
    iput-object p1, p0, Lcom/google/firebase/auth/internal/zzac;->zza:Ljava/lang/String;

    .line 12
    iput-object p2, p0, Lcom/google/firebase/auth/internal/zzac;->zzb:Ljava/lang/String;

    return-void
.end method

.method public final zza()Ljava/lang/String;
    .locals 1

    .line 1
    iget-object v0, p0, Lcom/google/firebase/auth/internal/zzac;->zza:Ljava/lang/String;

    return-object v0
.end method

.method public final zzb()Ljava/lang/String;
    .locals 1

    .line 2
    iget-object v0, p0, Lcom/google/firebase/auth/internal/zzac;->zzb:Ljava/lang/String;

    return-object v0
.end method

.method public final zzc()Z
    .locals 1

    .line 14
    iget-boolean v0, p0, Lcom/google/firebase/auth/internal/zzac;->zzd:Z

    return v0
.end method

.method public final zzd()Z
    .locals 1

    .line 15
    iget-object v0, p0, Lcom/google/firebase/auth/internal/zzac;->zza:Ljava/lang/String;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/google/firebase/auth/internal/zzac;->zzb:Ljava/lang/String;

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    return v0

    :cond_0
    const/4 v0, 0x0

    return v0
.end method

.method public final zze()Z
    .locals 1

    .line 16
    iget-boolean v0, p0, Lcom/google/firebase/auth/internal/zzac;->zzc:Z

    return v0
.end method
