.class public final Lcom/google/android/gms/internal/firebase-auth-api/zzjx;
.super Ljava/lang/Object;
.source "com.google.firebase:firebase-auth@@24.0.1"


# static fields
.field private static final zza:Lcom/google/android/gms/internal/firebase-auth-api/zzps;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lcom/google/android/gms/internal/firebase-auth-api/zzps<",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzke;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzbd;",
            ">;"
        }
    .end annotation
.end field

.field private static final zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzps;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lcom/google/android/gms/internal/firebase-auth-api/zzps<",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzkh;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzbg;",
            ">;"
        }
    .end annotation
.end field

.field private static final zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzcd;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lcom/google/android/gms/internal/firebase-auth-api/zzcd<",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzbd;",
            ">;"
        }
    .end annotation
.end field

.field private static final zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzbh;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lcom/google/android/gms/internal/firebase-auth-api/zzbh<",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzbg;",
            ">;"
        }
    .end annotation
.end field

.field private static final zze:Lcom/google/android/gms/internal/firebase-auth-api/zzor;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lcom/google/android/gms/internal/firebase-auth-api/zzor<",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzkb;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method static constructor <clinit>()V
    .locals 4

    .line 20
    new-instance v0, Lcom/google/android/gms/internal/firebase-auth-api/zzka;

    invoke-direct {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzka;-><init>()V

    const-class v1, Lcom/google/android/gms/internal/firebase-auth-api/zzke;

    const-class v2, Lcom/google/android/gms/internal/firebase-auth-api/zzbd;

    .line 21
    invoke-static {v0, v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzps;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzpu;Ljava/lang/Class;Ljava/lang/Class;)Lcom/google/android/gms/internal/firebase-auth-api/zzps;

    move-result-object v0

    sput-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzjx;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzps;

    .line 22
    new-instance v0, Lcom/google/android/gms/internal/firebase-auth-api/zzjz;

    invoke-direct {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzjz;-><init>()V

    const-class v1, Lcom/google/android/gms/internal/firebase-auth-api/zzkh;

    const-class v2, Lcom/google/android/gms/internal/firebase-auth-api/zzbg;

    .line 23
    invoke-static {v0, v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzps;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzpu;Ljava/lang/Class;Ljava/lang/Class;)Lcom/google/android/gms/internal/firebase-auth-api/zzps;

    move-result-object v0

    sput-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzjx;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzps;

    .line 25
    const-class v0, Lcom/google/android/gms/internal/firebase-auth-api/zzbd;

    .line 26
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzvn;->zzf()Lcom/google/android/gms/internal/firebase-auth-api/zzamv;

    move-result-object v1

    .line 27
    const-string v2, "type.googleapis.com/google.crypto.tink.EciesAeadHkdfPrivateKey"

    invoke-static {v2, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzod;->zza(Ljava/lang/String;Ljava/lang/Class;Lcom/google/android/gms/internal/firebase-auth-api/zzamv;)Lcom/google/android/gms/internal/firebase-auth-api/zzcd;

    move-result-object v0

    sput-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzjx;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzcd;

    .line 29
    const-class v0, Lcom/google/android/gms/internal/firebase-auth-api/zzbg;

    sget-object v1, Lcom/google/android/gms/internal/firebase-auth-api/zzwx$zzb;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzwx$zzb;

    .line 30
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzvq;->zzh()Lcom/google/android/gms/internal/firebase-auth-api/zzamv;

    move-result-object v2

    .line 31
    const-string v3, "type.googleapis.com/google.crypto.tink.EciesAeadHkdfPublicKey"

    invoke-static {v3, v0, v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzod;->zza(Ljava/lang/String;Ljava/lang/Class;Lcom/google/android/gms/internal/firebase-auth-api/zzwx$zzb;Lcom/google/android/gms/internal/firebase-auth-api/zzamv;)Lcom/google/android/gms/internal/firebase-auth-api/zzbh;

    move-result-object v0

    sput-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzjx;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzbh;

    .line 32
    new-instance v0, Lcom/google/android/gms/internal/firebase-auth-api/zzkc;

    invoke-direct {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzkc;-><init>()V

    sput-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzjx;->zze:Lcom/google/android/gms/internal/firebase-auth-api/zzor;

    return-void
.end method

.method public static synthetic zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb;Ljava/lang/Integer;)Lcom/google/android/gms/internal/firebase-auth-api/zzke;
    .locals 2

    .line 2
    invoke-virtual {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb;->zzd()Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;

    move-result-object v0

    .line 3
    sget-object v1, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;

    if-ne v0, v1, :cond_0

    .line 4
    sget-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zznj;->zza:Ljava/security/spec/ECParameterSpec;

    goto :goto_0

    .line 5
    :cond_0
    sget-object v1, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;

    if-ne v0, v1, :cond_1

    .line 6
    sget-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zznj;->zzb:Ljava/security/spec/ECParameterSpec;

    goto :goto_0

    .line 7
    :cond_1
    sget-object v1, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;

    if-ne v0, v1, :cond_2

    .line 8
    sget-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zznj;->zzc:Ljava/security/spec/ECParameterSpec;

    .line 10
    :goto_0
    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzzf;->zza(Ljava/security/spec/ECParameterSpec;)Ljava/security/KeyPair;

    move-result-object v0

    .line 11
    invoke-virtual {v0}, Ljava/security/KeyPair;->getPublic()Ljava/security/PublicKey;

    move-result-object v1

    check-cast v1, Ljava/security/interfaces/ECPublicKey;

    .line 12
    invoke-virtual {v0}, Ljava/security/KeyPair;->getPrivate()Ljava/security/PrivateKey;

    move-result-object v0

    check-cast v0, Ljava/security/interfaces/ECPrivateKey;

    .line 14
    invoke-interface {v1}, Ljava/security/interfaces/ECPublicKey;->getW()Ljava/security/spec/ECPoint;

    move-result-object v1

    invoke-static {p0, v1, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkh;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb;Ljava/security/spec/ECPoint;Ljava/lang/Integer;)Lcom/google/android/gms/internal/firebase-auth-api/zzkh;

    move-result-object p0

    .line 16
    invoke-interface {v0}, Ljava/security/interfaces/ECPrivateKey;->getS()Ljava/math/BigInteger;

    move-result-object p1

    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzbf;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzch;

    move-result-object v0

    invoke-static {p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzaam;->zza(Ljava/math/BigInteger;Lcom/google/android/gms/internal/firebase-auth-api/zzch;)Lcom/google/android/gms/internal/firebase-auth-api/zzaam;

    move-result-object p1

    .line 17
    invoke-static {p0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzke;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkh;Lcom/google/android/gms/internal/firebase-auth-api/zzaam;)Lcom/google/android/gms/internal/firebase-auth-api/zzke;

    move-result-object p0

    return-object p0

    .line 9
    :cond_2
    new-instance p0, Ljava/security/GeneralSecurityException;

    invoke-static {v0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p1

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "Unsupported curve type: "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Ljava/security/GeneralSecurityException;-><init>(Ljava/lang/String;)V

    throw p0
.end method

.method static zza()Ljava/lang/String;
    .locals 1

    .line 19
    const-string v0, "type.googleapis.com/google.crypto.tink.EciesAeadHkdfPrivateKey"

    return-object v0
.end method

.method public static zza(Z)V
    .locals 6
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/security/GeneralSecurityException;
        }
    .end annotation

    .line 33
    sget-object p0, Lcom/google/android/gms/internal/firebase-auth-api/zziv$zza;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zziv$zza;

    invoke-virtual {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zziv$zza;->zza()Z

    move-result p0

    if-eqz p0, :cond_0

    .line 35
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzlq;->zza()V

    .line 36
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzox;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzox;

    move-result-object p0

    .line 37
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    .line 39
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;

    .line 40
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;

    .line 41
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;

    .line 42
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;

    .line 43
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    .line 44
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx;->zze()Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    const/16 v3, 0xc

    .line 45
    invoke-virtual {v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zza(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    const/16 v4, 0x10

    .line 46
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zzb(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    .line 47
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zzc(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    sget-object v5, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zza;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zza;

    .line 48
    invoke-virtual {v2, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zza;)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    .line 49
    invoke-virtual {v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzdx;

    move-result-object v2

    .line 50
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzcb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    .line 51
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkb;

    move-result-object v1

    .line 52
    const-string v2, "ECIES_P256_HKDF_HMAC_SHA256_AES128_GCM"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 54
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;

    .line 55
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;

    .line 56
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;

    .line 57
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;

    .line 58
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    .line 59
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx;->zze()Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    .line 60
    invoke-virtual {v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zza(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    .line 61
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zzb(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    .line 62
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zzc(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    sget-object v5, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zza;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zza;

    .line 63
    invoke-virtual {v2, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zza;)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    .line 64
    invoke-virtual {v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzdx;

    move-result-object v2

    .line 65
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzcb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    .line 66
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkb;

    move-result-object v1

    .line 67
    const-string v2, "ECIES_P256_HKDF_HMAC_SHA256_AES128_GCM_RAW"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 69
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;

    .line 70
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;

    .line 71
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;

    .line 72
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;

    .line 73
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    .line 74
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx;->zze()Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    .line 75
    invoke-virtual {v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zza(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    .line 76
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zzb(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    .line 77
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zzc(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    sget-object v5, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zza;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zza;

    .line 78
    invoke-virtual {v2, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zza;)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    .line 79
    invoke-virtual {v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzdx;

    move-result-object v2

    .line 80
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzcb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    .line 81
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkb;

    move-result-object v1

    .line 82
    const-string v2, "ECIES_P256_COMPRESSED_HKDF_HMAC_SHA256_AES128_GCM"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 84
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;

    .line 85
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;

    .line 86
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;

    .line 87
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;

    .line 88
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    .line 89
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx;->zze()Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    .line 90
    invoke-virtual {v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zza(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    .line 91
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zzb(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    .line 92
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zzc(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    sget-object v5, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zza;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zza;

    .line 93
    invoke-virtual {v2, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zza;)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    .line 94
    invoke-virtual {v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzdx;

    move-result-object v2

    .line 95
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzcb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    .line 96
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkb;

    move-result-object v1

    .line 97
    const-string v2, "ECIES_P256_COMPRESSED_HKDF_HMAC_SHA256_AES128_GCM_RAW"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 99
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;

    .line 100
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;

    .line 101
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;

    .line 102
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;

    .line 103
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    .line 104
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx;->zze()Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    .line 105
    invoke-virtual {v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zza(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    .line 106
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zzb(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    .line 107
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zzc(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    sget-object v3, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zza;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zza;

    .line 108
    invoke-virtual {v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zza;)Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;

    move-result-object v2

    .line 109
    invoke-virtual {v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzdx$zzb;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzdx;

    move-result-object v2

    .line 110
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzcb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    .line 111
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkb;

    move-result-object v1

    .line 112
    const-string v2, "ECIES_P256_HKDF_HMAC_SHA256_AES128_GCM_COMPRESSED_WITHOUT_PREFIX"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 114
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;

    .line 115
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;

    .line 116
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;

    .line 117
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;

    .line 118
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    .line 119
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi;->zzf()Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    .line 120
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zza(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    const/16 v3, 0x20

    .line 121
    invoke-virtual {v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zzb(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    .line 122
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zzd(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    .line 123
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zzc(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    sget-object v5, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zza;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zza;

    .line 124
    invoke-virtual {v2, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zza;)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    sget-object v5, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzc;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzc;

    .line 125
    invoke-virtual {v2, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    .line 126
    invoke-virtual {v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzdi;

    move-result-object v2

    .line 127
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzcb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    .line 128
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkb;

    move-result-object v1

    .line 129
    const-string v2, "ECIES_P256_HKDF_HMAC_SHA256_AES128_CTR_HMAC_SHA256"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 131
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;

    .line 132
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;

    .line 133
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;

    .line 134
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;

    .line 135
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    .line 136
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi;->zzf()Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    .line 137
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zza(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    .line 138
    invoke-virtual {v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zzb(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    .line 139
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zzd(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    .line 140
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zzc(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    sget-object v5, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zza;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zza;

    .line 141
    invoke-virtual {v2, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zza;)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    sget-object v5, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzc;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzc;

    .line 142
    invoke-virtual {v2, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    .line 143
    invoke-virtual {v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzdi;

    move-result-object v2

    .line 144
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzcb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    .line 145
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkb;

    move-result-object v1

    .line 146
    const-string v2, "ECIES_P256_HKDF_HMAC_SHA256_AES128_CTR_HMAC_SHA256_RAW"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 148
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;

    .line 149
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;

    .line 150
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;

    .line 151
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;

    .line 152
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    .line 153
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi;->zzf()Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    .line 154
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zza(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    .line 155
    invoke-virtual {v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zzb(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    .line 156
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zzd(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    .line 157
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zzc(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    sget-object v5, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zza;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zza;

    .line 158
    invoke-virtual {v2, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zza;)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    sget-object v5, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzc;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzc;

    .line 159
    invoke-virtual {v2, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    .line 160
    invoke-virtual {v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzdi;

    move-result-object v2

    .line 161
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzcb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    .line 162
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkb;

    move-result-object v1

    .line 163
    const-string v2, "ECIES_P256_COMPRESSED_HKDF_HMAC_SHA256_AES128_CTR_HMAC_SHA256"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 165
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;

    .line 166
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;

    .line 167
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;

    .line 168
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;

    .line 169
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zzd;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    .line 170
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi;->zzf()Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    .line 171
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zza(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    .line 172
    invoke-virtual {v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zzb(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    .line 173
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zzd(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    .line 174
    invoke-virtual {v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zzc(I)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    sget-object v3, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zza;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zza;

    .line 175
    invoke-virtual {v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zza;)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    sget-object v3, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzc;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzc;

    .line 176
    invoke-virtual {v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;

    move-result-object v2

    .line 177
    invoke-virtual {v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzdi$zzb;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzdi;

    move-result-object v2

    .line 178
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzcb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;

    move-result-object v1

    .line 179
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkb$zza;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkb;

    move-result-object v1

    .line 180
    const-string v2, "ECIES_P256_COMPRESSED_HKDF_HMAC_SHA256_AES128_CTR_HMAC_SHA256_RAW"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 181
    invoke-static {v0}, Ljava/util/Collections;->unmodifiableMap(Ljava/util/Map;)Ljava/util/Map;

    move-result-object v0

    .line 182
    invoke-virtual {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzox;->zza(Ljava/util/Map;)V

    .line 183
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzpa;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzpa;

    move-result-object p0

    sget-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzjx;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzps;

    .line 184
    invoke-virtual {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzpa;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzps;)V

    .line 185
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzpa;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzpa;

    move-result-object p0

    sget-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzjx;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzps;

    .line 186
    invoke-virtual {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzpa;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzps;)V

    .line 187
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzop;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzop;

    move-result-object p0

    sget-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzjx;->zze:Lcom/google/android/gms/internal/firebase-auth-api/zzor;

    const-class v1, Lcom/google/android/gms/internal/firebase-auth-api/zzkb;

    invoke-virtual {p0, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzop;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzor;Ljava/lang/Class;)V

    .line 188
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zznq;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zznq;

    move-result-object p0

    sget-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzjx;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzcd;

    const/4 v1, 0x1

    invoke-virtual {p0, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zznq;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzbh;Z)V

    .line 189
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zznq;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zznq;

    move-result-object p0

    sget-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzjx;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzbh;

    const/4 v1, 0x0

    invoke-virtual {p0, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zznq;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzbh;Z)V

    return-void

    .line 34
    :cond_0
    new-instance p0, Ljava/security/GeneralSecurityException;

    const-string v0, "Registering ECIES Hybrid Encryption is not supported in FIPS mode"

    invoke-direct {p0, v0}, Ljava/security/GeneralSecurityException;-><init>(Ljava/lang/String;)V

    throw p0
.end method
