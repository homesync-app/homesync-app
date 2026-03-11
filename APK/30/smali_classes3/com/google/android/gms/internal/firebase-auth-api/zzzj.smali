.class public final Lcom/google/android/gms/internal/firebase-auth-api/zzzj;
.super Ljava/lang/Object;
.source "com.google.firebase:firebase-auth@@24.0.1"


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "<T_WRAPPER::",
        "Lcom/google/android/gms/internal/firebase-auth-api/zzzp<",
        "TJcePrimitiveT;>;JcePrimitiveT:",
        "Ljava/lang/Object;",
        ">",
        "Ljava/lang/Object;"
    }
.end annotation


# static fields
.field public static final zza:Lcom/google/android/gms/internal/firebase-auth-api/zzzj;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lcom/google/android/gms/internal/firebase-auth-api/zzzj<",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzzs;",
            "Ljavax/crypto/Cipher;",
            ">;"
        }
    .end annotation
.end field

.field public static final zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzzj;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lcom/google/android/gms/internal/firebase-auth-api/zzzj<",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzzw;",
            "Ljavax/crypto/Mac;",
            ">;"
        }
    .end annotation
.end field

.field public static final zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzzj;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lcom/google/android/gms/internal/firebase-auth-api/zzzj<",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzzr;",
            "Ljavax/crypto/KeyAgreement;",
            ">;"
        }
    .end annotation
.end field

.field public static final zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzzj;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lcom/google/android/gms/internal/firebase-auth-api/zzzj<",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzzt;",
            "Ljava/security/KeyPairGenerator;",
            ">;"
        }
    .end annotation
.end field

.field public static final zze:Lcom/google/android/gms/internal/firebase-auth-api/zzzj;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lcom/google/android/gms/internal/firebase-auth-api/zzzj<",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzzu;",
            "Ljava/security/KeyFactory;",
            ">;"
        }
    .end annotation
.end field


# instance fields
.field private final zzf:Lcom/google/android/gms/internal/firebase-auth-api/zzzn;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lcom/google/android/gms/internal/firebase-auth-api/zzzn<",
            "TJcePrimitiveT;>;"
        }
    .end annotation
.end field


# direct methods
.method static constructor <clinit>()V
    .locals 2

    .line 9
    new-instance v0, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;

    new-instance v1, Lcom/google/android/gms/internal/firebase-auth-api/zzzs;

    invoke-direct {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzzs;-><init>()V

    invoke-direct {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;-><init>(Lcom/google/android/gms/internal/firebase-auth-api/zzzp;)V

    sput-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzzj;

    .line 10
    new-instance v0, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;

    new-instance v1, Lcom/google/android/gms/internal/firebase-auth-api/zzzw;

    invoke-direct {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzzw;-><init>()V

    invoke-direct {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;-><init>(Lcom/google/android/gms/internal/firebase-auth-api/zzzp;)V

    sput-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzzj;

    .line 11
    new-instance v0, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;

    new-instance v1, Lcom/google/android/gms/internal/firebase-auth-api/zzzy;

    invoke-direct {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzzy;-><init>()V

    invoke-direct {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;-><init>(Lcom/google/android/gms/internal/firebase-auth-api/zzzp;)V

    .line 12
    new-instance v0, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;

    new-instance v1, Lcom/google/android/gms/internal/firebase-auth-api/zzzv;

    invoke-direct {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzzv;-><init>()V

    invoke-direct {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;-><init>(Lcom/google/android/gms/internal/firebase-auth-api/zzzp;)V

    .line 13
    new-instance v0, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;

    new-instance v1, Lcom/google/android/gms/internal/firebase-auth-api/zzzr;

    invoke-direct {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzzr;-><init>()V

    invoke-direct {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;-><init>(Lcom/google/android/gms/internal/firebase-auth-api/zzzp;)V

    sput-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzzj;

    .line 14
    new-instance v0, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;

    new-instance v1, Lcom/google/android/gms/internal/firebase-auth-api/zzzt;

    invoke-direct {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzzt;-><init>()V

    invoke-direct {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;-><init>(Lcom/google/android/gms/internal/firebase-auth-api/zzzp;)V

    sput-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzzj;

    .line 15
    new-instance v0, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;

    new-instance v1, Lcom/google/android/gms/internal/firebase-auth-api/zzzu;

    invoke-direct {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzzu;-><init>()V

    invoke-direct {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;-><init>(Lcom/google/android/gms/internal/firebase-auth-api/zzzp;)V

    sput-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;->zze:Lcom/google/android/gms/internal/firebase-auth-api/zzzj;

    return-void
.end method

.method private constructor <init>(Lcom/google/android/gms/internal/firebase-auth-api/zzzp;)V
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT_WRAPPER;)V"
        }
    .end annotation

    .line 16
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 17
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zziv;->zzb()Z

    move-result v0

    const/4 v1, 0x0

    if-eqz v0, :cond_0

    .line 18
    new-instance v0, Lcom/google/android/gms/internal/firebase-auth-api/zzzo;

    invoke-direct {v0, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzzo;-><init>(Lcom/google/android/gms/internal/firebase-auth-api/zzzp;Lcom/google/android/gms/internal/firebase-auth-api/zzzq;)V

    iput-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;->zzf:Lcom/google/android/gms/internal/firebase-auth-api/zzzn;

    return-void

    .line 19
    :cond_0
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzaaf;->zza()Z

    move-result v0

    if-eqz v0, :cond_1

    .line 20
    new-instance v0, Lcom/google/android/gms/internal/firebase-auth-api/zzzm;

    invoke-direct {v0, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzzm;-><init>(Lcom/google/android/gms/internal/firebase-auth-api/zzzp;Lcom/google/android/gms/internal/firebase-auth-api/zzzq;)V

    iput-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;->zzf:Lcom/google/android/gms/internal/firebase-auth-api/zzzn;

    return-void

    .line 21
    :cond_1
    new-instance v0, Lcom/google/android/gms/internal/firebase-auth-api/zzzl;

    invoke-direct {v0, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzzl;-><init>(Lcom/google/android/gms/internal/firebase-auth-api/zzzp;Lcom/google/android/gms/internal/firebase-auth-api/zzzq;)V

    iput-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;->zzf:Lcom/google/android/gms/internal/firebase-auth-api/zzzn;

    return-void
.end method

.method public static varargs zza([Ljava/lang/String;)Ljava/util/List;
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "([",
            "Ljava/lang/String;",
            ")",
            "Ljava/util/List<",
            "Ljava/security/Provider;",
            ">;"
        }
    .end annotation

    .line 2
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    .line 3
    array-length v1, p0

    const/4 v2, 0x0

    :goto_0
    if-ge v2, v1, :cond_1

    aget-object v3, p0, v2

    .line 4
    invoke-static {v3}, Ljava/security/Security;->getProvider(Ljava/lang/String;)Ljava/security/Provider;

    move-result-object v3

    if-eqz v3, :cond_0

    .line 6
    invoke-interface {v0, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    :cond_0
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    :cond_1
    return-object v0
.end method


# virtual methods
.method public final zza(Ljava/lang/String;)Ljava/lang/Object;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/String;",
            ")TJcePrimitiveT;"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/security/GeneralSecurityException;
        }
    .end annotation

    .line 1
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzzj;->zzf:Lcom/google/android/gms/internal/firebase-auth-api/zzzn;

    invoke-interface {v0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzzn;->zza(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method
