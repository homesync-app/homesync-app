.class final Lcom/google/firebase/auth/internal/zzm;
.super Lcom/google/firebase/auth/internal/zzi;
.source "com.google.firebase:firebase-auth@@24.0.1"


# instance fields
.field private zza:Ljava/lang/String;

.field private zzb:Ljava/lang/String;

.field private zzc:Ljava/lang/String;


# direct methods
.method constructor <init>()V
    .locals 0

    .line 8
    invoke-direct {p0}, Lcom/google/firebase/auth/internal/zzi;-><init>()V

    return-void
.end method


# virtual methods
.method public final zza(Ljava/lang/String;)Lcom/google/firebase/auth/internal/zzi;
    .locals 0

    .line 1
    iput-object p1, p0, Lcom/google/firebase/auth/internal/zzm;->zzb:Ljava/lang/String;

    return-object p0
.end method

.method public final zza()Lcom/google/firebase/auth/internal/zzj;
    .locals 5

    .line 7
    new-instance v0, Lcom/google/firebase/auth/internal/zzn;

    iget-object v1, p0, Lcom/google/firebase/auth/internal/zzm;->zza:Ljava/lang/String;

    iget-object v2, p0, Lcom/google/firebase/auth/internal/zzm;->zzb:Ljava/lang/String;

    iget-object v3, p0, Lcom/google/firebase/auth/internal/zzm;->zzc:Ljava/lang/String;

    const/4 v4, 0x0

    invoke-direct {v0, v1, v2, v3, v4}, Lcom/google/firebase/auth/internal/zzn;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Lcom/google/firebase/auth/internal/zzp;)V

    return-object v0
.end method

.method public final zzb(Ljava/lang/String;)Lcom/google/firebase/auth/internal/zzi;
    .locals 0

    .line 3
    iput-object p1, p0, Lcom/google/firebase/auth/internal/zzm;->zzc:Ljava/lang/String;

    return-object p0
.end method

.method public final zzc(Ljava/lang/String;)Lcom/google/firebase/auth/internal/zzi;
    .locals 0

    .line 5
    iput-object p1, p0, Lcom/google/firebase/auth/internal/zzm;->zza:Ljava/lang/String;

    return-object p0
.end method
