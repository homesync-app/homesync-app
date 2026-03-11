.class public final Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;
.super Ljava/lang/Object;
.source "com.google.firebase:firebase-auth@@24.0.1"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/google/android/gms/internal/firebase-auth-api/zzfc;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "zzb"
.end annotation


# instance fields
.field private zza:Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzc;
    .annotation runtime Ljavax/annotation/Nullable;
    .end annotation
.end field

.field private zzb:Ljava/lang/String;
    .annotation runtime Ljavax/annotation/Nullable;
    .end annotation
.end field

.field private zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;
    .annotation runtime Ljavax/annotation/Nullable;
    .end annotation
.end field

.field private zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzcy;
    .annotation runtime Ljavax/annotation/Nullable;
    .end annotation
.end field


# direct methods
.method private constructor <init>()V
    .locals 0

    .line 37
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method synthetic constructor <init>(Lcom/google/android/gms/internal/firebase-auth-api/zzfe;)V
    .locals 0

    invoke-direct {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;-><init>()V

    return-void
.end method


# virtual methods
.method public final zza(Lcom/google/android/gms/internal/firebase-auth-api/zzcy;)Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;
    .locals 0

    .line 1
    iput-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzcy;

    return-object p0
.end method

.method public final zza(Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;)Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;
    .locals 0

    .line 3
    iput-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;

    return-object p0
.end method

.method public final zza(Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;
    .locals 0

    .line 7
    iput-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzc;

    return-object p0
.end method

.method public final zza(Ljava/lang/String;)Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;
    .locals 0

    .line 5
    iput-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;->zzb:Ljava/lang/String;

    return-object p0
.end method

.method public final zza()Lcom/google/android/gms/internal/firebase-auth-api/zzfc;
    .locals 7
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/security/GeneralSecurityException;
        }
    .end annotation

    .line 9
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzc;

    if-nez v0, :cond_0

    .line 10
    sget-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzc;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzc;

    iput-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzc;

    .line 11
    :cond_0
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;->zzb:Ljava/lang/String;

    if-eqz v0, :cond_a

    .line 13
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;

    if-eqz v0, :cond_9

    .line 15
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzcy;

    if-eqz v0, :cond_8

    .line 17
    invoke-virtual {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzcb;->zza()Z

    move-result v0

    if-nez v0, :cond_7

    .line 19
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;

    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzcy;

    .line 20
    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;

    invoke-virtual {v0, v2}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_1

    instance-of v2, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzdx;

    if-eqz v2, :cond_1

    goto :goto_0

    .line 22
    :cond_1
    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;

    invoke-virtual {v0, v2}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_2

    instance-of v2, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzem;

    if-eqz v2, :cond_2

    goto :goto_0

    .line 24
    :cond_2
    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;

    invoke-virtual {v0, v2}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_3

    instance-of v2, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzge;

    if-eqz v2, :cond_3

    goto :goto_0

    .line 26
    :cond_3
    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;

    invoke-virtual {v0, v2}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_4

    instance-of v2, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzdi;

    if-eqz v2, :cond_4

    goto :goto_0

    .line 28
    :cond_4
    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;->zze:Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;

    invoke-virtual {v0, v2}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_5

    instance-of v2, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzdq;

    if-eqz v2, :cond_5

    goto :goto_0

    .line 30
    :cond_5
    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;->zzf:Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;

    invoke-virtual {v0, v2}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_6

    instance-of v0, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzeg;

    if-eqz v0, :cond_6

    .line 36
    :goto_0
    new-instance v1, Lcom/google/android/gms/internal/firebase-auth-api/zzfc;

    iget-object v2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzc;

    iget-object v3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;->zzb:Ljava/lang/String;

    iget-object v4, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;

    iget-object v5, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzcy;

    const/4 v6, 0x0

    invoke-direct/range {v1 .. v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzfc;-><init>(Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzc;Ljava/lang/String;Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;Lcom/google/android/gms/internal/firebase-auth-api/zzcy;Lcom/google/android/gms/internal/firebase-auth-api/zzfe;)V

    return-object v1

    .line 34
    :cond_6
    new-instance v0, Ljava/security/GeneralSecurityException;

    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;

    .line 35
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zza;->toString()Ljava/lang/String;

    move-result-object v1

    iget-object v2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzfc$zzb;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzcy;

    invoke-static {v2}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v2

    new-instance v3, Ljava/lang/StringBuilder;

    const-string v4, "Cannot use parsing strategy "

    invoke-direct {v3, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v3, " when new keys are picked according to "

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "."

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/security/GeneralSecurityException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 18
    :cond_7
    new-instance v0, Ljava/security/GeneralSecurityException;

    const-string v1, "dekParametersForNewKeys must not have ID Requirements"

    invoke-direct {v0, v1}, Ljava/security/GeneralSecurityException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 16
    :cond_8
    new-instance v0, Ljava/security/GeneralSecurityException;

    const-string v1, "dekParametersForNewKeys must be set"

    invoke-direct {v0, v1}, Ljava/security/GeneralSecurityException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 14
    :cond_9
    new-instance v0, Ljava/security/GeneralSecurityException;

    const-string v1, "dekParsingStrategy must be set"

    invoke-direct {v0, v1}, Ljava/security/GeneralSecurityException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 12
    :cond_a
    new-instance v0, Ljava/security/GeneralSecurityException;

    const-string v1, "kekUri must be set"

    invoke-direct {v0, v1}, Ljava/security/GeneralSecurityException;-><init>(Ljava/lang/String;)V

    throw v0
.end method
