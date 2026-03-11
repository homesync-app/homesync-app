.class public final Lcom/google/android/gms/internal/firebase-auth-api/zzmg;
.super Ljava/lang/Object;
.source "com.google.firebase:firebase-auth@@24.0.1"


# static fields
.field private static final zza:Lcom/google/android/gms/internal/firebase-auth-api/zzps;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lcom/google/android/gms/internal/firebase-auth-api/zzps<",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzki;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzbd;",
            ">;"
        }
    .end annotation
.end field

.field private static final zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzps;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lcom/google/android/gms/internal/firebase-auth-api/zzps<",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzkq;",
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
            "Lcom/google/android/gms/internal/firebase-auth-api/zzkg;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method static constructor <clinit>()V
    .locals 4

    .line 55
    new-instance v0, Lcom/google/android/gms/internal/firebase-auth-api/zzmj;

    invoke-direct {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzmj;-><init>()V

    const-class v1, Lcom/google/android/gms/internal/firebase-auth-api/zzki;

    const-class v2, Lcom/google/android/gms/internal/firebase-auth-api/zzbd;

    .line 56
    invoke-static {v0, v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzps;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzpu;Ljava/lang/Class;Ljava/lang/Class;)Lcom/google/android/gms/internal/firebase-auth-api/zzps;

    move-result-object v0

    sput-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzmg;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzps;

    .line 57
    new-instance v0, Lcom/google/android/gms/internal/firebase-auth-api/zzmi;

    invoke-direct {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzmi;-><init>()V

    const-class v1, Lcom/google/android/gms/internal/firebase-auth-api/zzkq;

    const-class v2, Lcom/google/android/gms/internal/firebase-auth-api/zzbg;

    .line 58
    invoke-static {v0, v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzps;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzpu;Ljava/lang/Class;Ljava/lang/Class;)Lcom/google/android/gms/internal/firebase-auth-api/zzps;

    move-result-object v0

    sput-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzmg;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzps;

    .line 60
    const-class v0, Lcom/google/android/gms/internal/firebase-auth-api/zzbd;

    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzwr;->zzf()Lcom/google/android/gms/internal/firebase-auth-api/zzamv;

    move-result-object v1

    .line 61
    const-string v2, "type.googleapis.com/google.crypto.tink.HpkePrivateKey"

    invoke-static {v2, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzod;->zza(Ljava/lang/String;Ljava/lang/Class;Lcom/google/android/gms/internal/firebase-auth-api/zzamv;)Lcom/google/android/gms/internal/firebase-auth-api/zzcd;

    move-result-object v0

    sput-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzmg;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzcd;

    .line 63
    const-class v0, Lcom/google/android/gms/internal/firebase-auth-api/zzbg;

    sget-object v1, Lcom/google/android/gms/internal/firebase-auth-api/zzwx$zzb;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzwx$zzb;

    .line 64
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzwu;->zzg()Lcom/google/android/gms/internal/firebase-auth-api/zzamv;

    move-result-object v2

    .line 65
    const-string v3, "type.googleapis.com/google.crypto.tink.HpkePublicKey"

    invoke-static {v3, v0, v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzod;->zza(Ljava/lang/String;Ljava/lang/Class;Lcom/google/android/gms/internal/firebase-auth-api/zzwx$zzb;Lcom/google/android/gms/internal/firebase-auth-api/zzamv;)Lcom/google/android/gms/internal/firebase-auth-api/zzbh;

    move-result-object v0

    sput-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzmg;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzbh;

    .line 66
    new-instance v0, Lcom/google/android/gms/internal/firebase-auth-api/zzml;

    invoke-direct {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzml;-><init>()V

    sput-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzmg;->zze:Lcom/google/android/gms/internal/firebase-auth-api/zzor;

    return-void
.end method

.method public static synthetic zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg;Ljava/lang/Integer;)Lcom/google/android/gms/internal/firebase-auth-api/zzki;
    .locals 9

    .line 2
    invoke-virtual {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zze()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    move-result-object v0

    sget-object v1, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    invoke-virtual {v0, v1}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 3
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzaah;->zza()[B

    move-result-object v0

    .line 4
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzbf;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzch;

    move-result-object v1

    invoke-static {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzaal;->zza([BLcom/google/android/gms/internal/firebase-auth-api/zzch;)Lcom/google/android/gms/internal/firebase-auth-api/zzaal;

    move-result-object v1

    .line 5
    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzaah;->zza([B)[B

    move-result-object v0

    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzaaj;->zza([B)Lcom/google/android/gms/internal/firebase-auth-api/zzaaj;

    move-result-object v0

    goto/16 :goto_2

    .line 6
    :cond_0
    invoke-virtual {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zze()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    move-result-object v0

    sget-object v1, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    invoke-virtual {v0, v1}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_2

    .line 7
    invoke-virtual {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zze()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    move-result-object v0

    sget-object v1, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    invoke-virtual {v0, v1}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_2

    .line 8
    invoke-virtual {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zze()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    move-result-object v0

    sget-object v1, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    invoke-virtual {v0, v1}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    goto :goto_0

    .line 51
    :cond_1
    new-instance p0, Ljava/security/GeneralSecurityException;

    const-string p1, "Unknown KEM ID"

    invoke-direct {p0, p1}, Ljava/security/GeneralSecurityException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 9
    :cond_2
    :goto_0
    invoke-virtual {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zze()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    move-result-object v0

    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzmk;->zzc(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzzi;

    move-result-object v0

    .line 11
    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzzf;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzzi;)Ljava/security/spec/ECParameterSpec;

    move-result-object v1

    invoke-static {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzzf;->zza(Ljava/security/spec/ECParameterSpec;)Ljava/security/KeyPair;

    move-result-object v1

    .line 13
    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzzh;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzzh;

    .line 14
    invoke-virtual {v1}, Ljava/security/KeyPair;->getPublic()Ljava/security/PublicKey;

    move-result-object v3

    check-cast v3, Ljava/security/interfaces/ECPublicKey;

    invoke-interface {v3}, Ljava/security/interfaces/ECPublicKey;->getW()Ljava/security/spec/ECPoint;

    move-result-object v3

    .line 16
    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzzf;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzzi;)Ljava/security/spec/ECParameterSpec;

    move-result-object v0

    invoke-virtual {v0}, Ljava/security/spec/ECParameterSpec;->getCurve()Ljava/security/spec/EllipticCurve;

    move-result-object v0

    .line 17
    invoke-static {v3, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zznj;->zza(Ljava/security/spec/ECPoint;Ljava/security/spec/EllipticCurve;)V

    .line 18
    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzzf;->zza(Ljava/security/spec/EllipticCurve;)I

    move-result v0

    .line 19
    invoke-virtual {v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzzh;->ordinal()I

    move-result v4

    const/4 v5, 0x1

    const/4 v6, 0x0

    if-eqz v4, :cond_8

    const/4 v7, 0x2

    if-eq v4, v5, :cond_6

    if-ne v4, v7, :cond_5

    mul-int/lit8 v2, v0, 0x2

    .line 27
    new-array v4, v2, [B

    .line 28
    invoke-virtual {v3}, Ljava/security/spec/ECPoint;->getAffineX()Ljava/math/BigInteger;

    move-result-object v5

    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzne;->zza(Ljava/math/BigInteger;)[B

    move-result-object v5

    .line 29
    array-length v7, v5

    if-le v7, v0, :cond_3

    .line 30
    array-length v7, v5

    sub-int/2addr v7, v0

    array-length v8, v5

    invoke-static {v5, v7, v8}, Ljava/util/Arrays;->copyOfRange([BII)[B

    move-result-object v5

    .line 31
    :cond_3
    invoke-virtual {v3}, Ljava/security/spec/ECPoint;->getAffineY()Ljava/math/BigInteger;

    move-result-object v3

    invoke-static {v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzne;->zza(Ljava/math/BigInteger;)[B

    move-result-object v3

    .line 32
    array-length v7, v3

    if-le v7, v0, :cond_4

    .line 33
    array-length v7, v3

    sub-int/2addr v7, v0

    array-length v8, v3

    invoke-static {v3, v7, v8}, Ljava/util/Arrays;->copyOfRange([BII)[B

    move-result-object v3

    .line 34
    :cond_4
    array-length v7, v3

    sub-int/2addr v2, v7

    array-length v7, v3

    invoke-static {v3, v6, v4, v2, v7}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 35
    array-length v2, v5

    sub-int/2addr v0, v2

    array-length v2, v5

    invoke-static {v5, v6, v4, v0, v2}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    goto :goto_1

    .line 42
    :cond_5
    new-instance p0, Ljava/security/GeneralSecurityException;

    invoke-static {v2}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p1

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "invalid format:"

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Ljava/security/GeneralSecurityException;-><init>(Ljava/lang/String;)V

    throw p0

    :cond_6
    add-int/2addr v0, v5

    .line 37
    new-array v4, v0, [B

    .line 38
    invoke-virtual {v3}, Ljava/security/spec/ECPoint;->getAffineX()Ljava/math/BigInteger;

    move-result-object v2

    invoke-static {v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzne;->zza(Ljava/math/BigInteger;)[B

    move-result-object v2

    .line 39
    array-length v5, v2

    sub-int/2addr v0, v5

    array-length v5, v2

    invoke-static {v2, v6, v4, v0, v5}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 40
    invoke-virtual {v3}, Ljava/security/spec/ECPoint;->getAffineY()Ljava/math/BigInteger;

    move-result-object v0

    invoke-virtual {v0, v6}, Ljava/math/BigInteger;->testBit(I)Z

    move-result v0

    if-eqz v0, :cond_7

    const/4 v7, 0x3

    :cond_7
    int-to-byte v0, v7

    aput-byte v0, v4, v6

    goto :goto_1

    :cond_8
    mul-int/lit8 v2, v0, 0x2

    add-int/2addr v2, v5

    .line 20
    new-array v4, v2, [B

    .line 21
    invoke-virtual {v3}, Ljava/security/spec/ECPoint;->getAffineX()Ljava/math/BigInteger;

    move-result-object v7

    invoke-static {v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzne;->zza(Ljava/math/BigInteger;)[B

    move-result-object v7

    .line 22
    invoke-virtual {v3}, Ljava/security/spec/ECPoint;->getAffineY()Ljava/math/BigInteger;

    move-result-object v3

    invoke-static {v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzne;->zza(Ljava/math/BigInteger;)[B

    move-result-object v3

    .line 23
    array-length v8, v3

    sub-int/2addr v2, v8

    array-length v8, v3

    invoke-static {v3, v6, v4, v2, v8}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    add-int/2addr v0, v5

    .line 24
    array-length v2, v7

    sub-int/2addr v0, v2

    array-length v2, v7

    invoke-static {v7, v6, v4, v0, v2}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    const/4 v0, 0x4

    .line 25
    aput-byte v0, v4, v6

    .line 43
    :goto_1
    invoke-static {v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzaaj;->zza([B)Lcom/google/android/gms/internal/firebase-auth-api/zzaaj;

    move-result-object v0

    .line 45
    invoke-virtual {v1}, Ljava/security/KeyPair;->getPrivate()Ljava/security/PrivateKey;

    move-result-object v1

    check-cast v1, Ljava/security/interfaces/ECPrivateKey;

    invoke-interface {v1}, Ljava/security/interfaces/ECPrivateKey;->getS()Ljava/math/BigInteger;

    move-result-object v1

    .line 46
    invoke-virtual {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zze()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    move-result-object v2

    invoke-static {v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzmk;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)I

    move-result v2

    .line 47
    invoke-static {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzne;->zza(Ljava/math/BigInteger;I)[B

    move-result-object v1

    .line 48
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzbf;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzch;

    move-result-object v2

    .line 49
    invoke-static {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzaal;->zza([BLcom/google/android/gms/internal/firebase-auth-api/zzch;)Lcom/google/android/gms/internal/firebase-auth-api/zzaal;

    move-result-object v1

    .line 52
    :goto_2
    invoke-static {p0, v0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkq;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg;Lcom/google/android/gms/internal/firebase-auth-api/zzaaj;Ljava/lang/Integer;)Lcom/google/android/gms/internal/firebase-auth-api/zzkq;

    move-result-object p0

    .line 53
    invoke-static {p0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzki;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkq;Lcom/google/android/gms/internal/firebase-auth-api/zzaal;)Lcom/google/android/gms/internal/firebase-auth-api/zzki;

    move-result-object p0

    return-object p0
.end method

.method public static zza(Z)V
    .locals 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/security/GeneralSecurityException;
        }
    .end annotation

    .line 67
    sget-object p0, Lcom/google/android/gms/internal/firebase-auth-api/zziv$zza;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zziv$zza;

    invoke-virtual {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zziv$zza;->zza()Z

    move-result p0

    if-eqz p0, :cond_0

    .line 69
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkl;->zza()V

    .line 70
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzox;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzox;

    move-result-object p0

    .line 71
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    .line 73
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    .line 74
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    .line 75
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    .line 76
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    .line 77
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    .line 78
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    move-result-object v1

    .line 79
    const-string v2, "DHKEM_X25519_HKDF_SHA256_HKDF_SHA256_AES_128_GCM"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 81
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    .line 82
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    .line 83
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    .line 84
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    .line 85
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    .line 86
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    move-result-object v1

    .line 87
    const-string v2, "DHKEM_X25519_HKDF_SHA256_HKDF_SHA256_AES_128_GCM_RAW"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 89
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    .line 90
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    .line 91
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    .line 92
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    .line 93
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    .line 94
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    move-result-object v1

    .line 95
    const-string v2, "DHKEM_X25519_HKDF_SHA256_HKDF_SHA256_AES_256_GCM"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 97
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    .line 98
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    .line 99
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    .line 100
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    .line 101
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    .line 102
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    move-result-object v1

    .line 103
    const-string v2, "DHKEM_X25519_HKDF_SHA256_HKDF_SHA256_AES_256_GCM_RAW"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 105
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    .line 106
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    .line 107
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    .line 108
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    .line 109
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    .line 110
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    move-result-object v1

    .line 111
    const-string v2, "DHKEM_X25519_HKDF_SHA256_HKDF_SHA256_CHACHA20_POLY1305"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 113
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    .line 114
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    .line 115
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    .line 116
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    .line 117
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    .line 118
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    move-result-object v1

    .line 119
    const-string v2, "DHKEM_X25519_HKDF_SHA256_HKDF_SHA256_CHACHA20_POLY1305_RAW"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 121
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    .line 122
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    .line 123
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    .line 124
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    .line 125
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    .line 126
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    move-result-object v1

    .line 127
    const-string v2, "DHKEM_P256_HKDF_SHA256_HKDF_SHA256_AES_128_GCM"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 129
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    .line 130
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    .line 131
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    .line 132
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    .line 133
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    .line 134
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    move-result-object v1

    .line 135
    const-string v2, "DHKEM_P256_HKDF_SHA256_HKDF_SHA256_AES_128_GCM_RAW"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 137
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    .line 138
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    .line 139
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    .line 140
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    .line 141
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    .line 142
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    move-result-object v1

    .line 143
    const-string v2, "DHKEM_P256_HKDF_SHA256_HKDF_SHA256_AES_256_GCM"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 145
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    .line 146
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    .line 147
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    .line 148
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    .line 149
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    .line 150
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    move-result-object v1

    .line 151
    const-string v2, "DHKEM_P256_HKDF_SHA256_HKDF_SHA256_AES_256_GCM_RAW"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 153
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    .line 154
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    .line 155
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    .line 156
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    .line 157
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    .line 158
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    move-result-object v1

    .line 159
    const-string v2, "DHKEM_P384_HKDF_SHA384_HKDF_SHA384_AES_128_GCM"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 161
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    .line 162
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    .line 163
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    .line 164
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    .line 165
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    .line 166
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    move-result-object v1

    .line 167
    const-string v2, "DHKEM_P384_HKDF_SHA384_HKDF_SHA384_AES_128_GCM_RAW"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 169
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    .line 170
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    .line 171
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    .line 172
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    .line 173
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    .line 174
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    move-result-object v1

    .line 175
    const-string v2, "DHKEM_P384_HKDF_SHA384_HKDF_SHA384_AES_256_GCM"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 177
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    .line 178
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    .line 179
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    .line 180
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    .line 181
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    .line 182
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    move-result-object v1

    .line 183
    const-string v2, "DHKEM_P384_HKDF_SHA384_HKDF_SHA384_AES_256_GCM_RAW"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 185
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    .line 186
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    .line 187
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    .line 188
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    .line 189
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    .line 190
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    move-result-object v1

    .line 191
    const-string v2, "DHKEM_P521_HKDF_SHA512_HKDF_SHA512_AES_128_GCM"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 193
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    .line 194
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    .line 195
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    .line 196
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    .line 197
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    .line 198
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    move-result-object v1

    .line 199
    const-string v2, "DHKEM_P521_HKDF_SHA512_HKDF_SHA512_AES_128_GCM_RAW"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 201
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    .line 202
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    .line 203
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    .line 204
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    .line 205
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    .line 206
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    move-result-object v1

    .line 207
    const-string v2, "DHKEM_P521_HKDF_SHA512_HKDF_SHA512_AES_256_GCM"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 209
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;

    .line 210
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zze;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;

    .line 211
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzf;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;

    .line 212
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzc;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;

    .line 213
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzb;)Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;

    move-result-object v1

    .line 214
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzkg$zzd;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    move-result-object v1

    .line 215
    const-string v2, "DHKEM_P521_HKDF_SHA512_HKDF_SHA512_AES_256_GCM_RAW"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 216
    invoke-static {v0}, Ljava/util/Collections;->unmodifiableMap(Ljava/util/Map;)Ljava/util/Map;

    move-result-object v0

    .line 217
    invoke-virtual {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzox;->zza(Ljava/util/Map;)V

    .line 218
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzpa;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzpa;

    move-result-object p0

    sget-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzmg;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzps;

    .line 219
    invoke-virtual {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzpa;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzps;)V

    .line 220
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzpa;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzpa;

    move-result-object p0

    sget-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzmg;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzps;

    .line 221
    invoke-virtual {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzpa;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzps;)V

    .line 222
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzop;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzop;

    move-result-object p0

    sget-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzmg;->zze:Lcom/google/android/gms/internal/firebase-auth-api/zzor;

    const-class v1, Lcom/google/android/gms/internal/firebase-auth-api/zzkg;

    invoke-virtual {p0, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzop;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzor;Ljava/lang/Class;)V

    .line 223
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zznq;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zznq;

    move-result-object p0

    sget-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzmg;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzcd;

    const/4 v1, 0x1

    invoke-virtual {p0, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zznq;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzbh;Z)V

    .line 224
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zznq;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zznq;

    move-result-object p0

    sget-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzmg;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzbh;

    const/4 v1, 0x0

    .line 225
    invoke-virtual {p0, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zznq;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzbh;Z)V

    return-void

    .line 68
    :cond_0
    new-instance p0, Ljava/security/GeneralSecurityException;

    const-string v0, "Registering HPKE Hybrid Encryption is not supported in FIPS mode"

    invoke-direct {p0, v0}, Ljava/security/GeneralSecurityException;-><init>(Ljava/lang/String;)V

    throw p0
.end method
