.class public final Lcom/google/android/recaptcha/internal/zzqc;
.super Ljava/lang/Object;
.source "com.google.android.recaptcha:recaptcha@@18.6.1"


# static fields
.field protected static final zza:Ljava/nio/charset/Charset;


# instance fields
.field protected zzb:[I

.field protected zzc:[I

.field private final zzd:[I

.field private zze:[B

.field private zzf:[B

.field private zzg:I


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .line 1
    sget-object v0, Ljava/nio/charset/StandardCharsets;->UTF_16:Ljava/nio/charset/Charset;

    sput-object v0, Lcom/google/android/recaptcha/internal/zzqc;->zza:Ljava/nio/charset/Charset;

    return-void
.end method

.method protected constructor <init>()V
    .locals 4

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const v0, 0x66513c8

    const v1, 0x14275b8e

    const v2, 0x1e77469f

    const v3, 0x4c275a94    # 4.38708E7f

    filled-new-array {v2, v3, v0, v1}, [I

    move-result-object v0

    iput-object v0, p0, Lcom/google/android/recaptcha/internal/zzqc;->zzd:[I

    return-void
.end method

.method protected constructor <init>([B[B)V
    .locals 5

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const v0, 0x66513c8

    const v1, 0x14275b8e

    const v2, 0x1e77469f

    const v3, 0x4c275a94    # 4.38708E7f

    filled-new-array {v2, v3, v0, v1}, [I

    move-result-object v0

    iput-object v0, p0, Lcom/google/android/recaptcha/internal/zzqc;->zzd:[I

    array-length v0, p1

    const/16 v1, 0x20

    if-ne v0, v1, :cond_3

    .line 2
    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzqc;->zze:[B

    const/4 p1, 0x1

    iput p1, p0, Lcom/google/android/recaptcha/internal/zzqc;->zzg:I

    iput-object p2, p0, Lcom/google/android/recaptcha/internal/zzqc;->zzf:[B

    const/16 p1, 0x10

    new-array p2, p1, [I

    iput-object p2, p0, Lcom/google/android/recaptcha/internal/zzqc;->zzb:[I

    const/4 p2, 0x0

    move v0, p2

    :goto_0
    const/4 v1, 0x4

    if-ge v0, v1, :cond_0

    iget-object v1, p0, Lcom/google/android/recaptcha/internal/zzqc;->zzb:[I

    iget-object v2, p0, Lcom/google/android/recaptcha/internal/zzqc;->zzd:[I

    .line 3
    aget v2, v2, v0

    const v3, 0x7f073efa

    invoke-static {v2, v3}, Lcom/google/android/recaptcha/internal/zzqc;->zza(II)I

    move-result v2

    aput v2, v1, v0

    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    :cond_0
    move v0, v1

    :goto_1
    const/16 v2, 0xc

    if-ge v0, v2, :cond_1

    iget-object v2, p0, Lcom/google/android/recaptcha/internal/zzqc;->zzb:[I

    iget-object v3, p0, Lcom/google/android/recaptcha/internal/zzqc;->zze:[B

    add-int/lit8 v4, v0, -0x4

    mul-int/2addr v4, v1

    .line 4
    invoke-static {v3, v4}, Lcom/google/android/recaptcha/internal/zzqc;->zzg([BI)I

    move-result v3

    aput v3, v2, v0

    add-int/lit8 v0, v0, 0x1

    goto :goto_1

    :cond_1
    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzqc;->zzb:[I

    iget v3, p0, Lcom/google/android/recaptcha/internal/zzqc;->zzg:I

    .line 5
    aput v3, v0, v2

    const/16 v0, 0xd

    :goto_2
    if-ge v0, p1, :cond_2

    iget-object v2, p0, Lcom/google/android/recaptcha/internal/zzqc;->zzb:[I

    iget-object v3, p0, Lcom/google/android/recaptcha/internal/zzqc;->zzf:[B

    add-int/lit8 v4, v0, -0xd

    mul-int/2addr v4, v1

    .line 6
    invoke-static {v3, v4}, Lcom/google/android/recaptcha/internal/zzqc;->zzg([BI)I

    move-result v3

    aput v3, v2, v0

    add-int/lit8 v0, v0, 0x1

    goto :goto_2

    :cond_2
    new-array v0, p1, [I

    iput-object v0, p0, Lcom/google/android/recaptcha/internal/zzqc;->zzc:[I

    iget-object v1, p0, Lcom/google/android/recaptcha/internal/zzqc;->zzb:[I

    .line 7
    array-length v2, v1

    invoke-static {v1, p2, v0, p2, p1}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    return-void

    .line 1
    :cond_3
    new-instance p1, Ljava/lang/IllegalArgumentException;

    .line 2
    invoke-direct {p1}, Ljava/lang/IllegalArgumentException;-><init>()V

    throw p1
.end method

.method protected static zza(II)I
    .locals 1

    rem-int/lit8 v0, p0, 0x2

    if-nez v0, :cond_0

    not-int v0, p1

    and-int/2addr v0, p0

    not-int p0, p0

    and-int/2addr p0, p1

    or-int/2addr p0, v0

    return p0

    :cond_0
    or-int v0, p0, p1

    and-int/2addr p0, p1

    sub-int/2addr v0, p0

    return v0
.end method

.method public static zze(Ljava/lang/String;[BLcom/google/android/recaptcha/internal/zzqd;)Ljava/lang/String;
    .locals 4

    const/4 p2, 0x0

    .line 1
    invoke-static {p0, p2}, Landroid/util/Base64;->decode(Ljava/lang/String;I)[B

    move-result-object p0

    const/16 v0, 0xc

    new-array v1, v0, [B

    .line 2
    array-length v2, p0

    add-int/lit8 v2, v2, -0xc

    new-array v3, v2, [B

    .line 3
    invoke-static {p0, p2, v1, p2, v0}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 4
    invoke-static {p0, v0, v3, p2, v2}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    new-instance p0, Lcom/google/android/recaptcha/internal/zzqc;

    .line 5
    invoke-direct {p0, p1, v1}, Lcom/google/android/recaptcha/internal/zzqc;-><init>([B[B)V

    .line 6
    invoke-virtual {p0, v3}, Lcom/google/android/recaptcha/internal/zzqc;->zzd([B)[B

    move-result-object p0

    new-instance p1, Ljava/lang/String;

    sget-object p2, Lcom/google/android/recaptcha/internal/zzqc;->zza:Ljava/nio/charset/Charset;

    invoke-direct {p1, p0, p2}, Ljava/lang/String;-><init>([BLjava/nio/charset/Charset;)V

    return-object p1
.end method

.method public static zzf(Ljava/lang/String;[BLcom/google/android/recaptcha/internal/zzqd;)Ljava/lang/String;
    .locals 3

    const/16 p2, 0xc

    .line 1
    new-array v0, p2, [B

    new-instance v1, Ljava/security/SecureRandom;

    invoke-direct {v1}, Ljava/security/SecureRandom;-><init>()V

    invoke-virtual {v1, v0}, Ljava/security/SecureRandom;->nextBytes([B)V

    new-instance v1, Lcom/google/android/recaptcha/internal/zzqc;

    .line 2
    invoke-direct {v1, p1, v0}, Lcom/google/android/recaptcha/internal/zzqc;-><init>([B[B)V

    sget-object p1, Lcom/google/android/recaptcha/internal/zzqc;->zza:Ljava/nio/charset/Charset;

    .line 3
    invoke-virtual {p0, p1}, Ljava/lang/String;->getBytes(Ljava/nio/charset/Charset;)[B

    move-result-object p0

    invoke-virtual {v1, p0}, Lcom/google/android/recaptcha/internal/zzqc;->zzd([B)[B

    move-result-object p0

    array-length p1, p0

    add-int/lit8 v1, p1, 0xc

    .line 4
    new-array v1, v1, [B

    const/4 v2, 0x0

    .line 5
    invoke-static {v0, v2, v1, v2, p2}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 6
    invoke-static {p0, v2, v1, p2, p1}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    const/4 p0, 0x2

    .line 7
    invoke-static {v1, p0}, Landroid/util/Base64;->encodeToString([BI)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private static final zzg([BI)I
    .locals 3

    .line 1
    aget-byte v0, p0, p1

    and-int/lit16 v0, v0, 0xff

    add-int/lit8 v1, p1, 0x1

    aget-byte v1, p0, v1

    and-int/lit16 v1, v1, 0xff

    add-int/lit8 v2, p1, 0x2

    aget-byte v2, p0, v2

    and-int/lit16 v2, v2, 0xff

    add-int/lit8 p1, p1, 0x3

    aget-byte p0, p0, p1

    and-int/lit16 p0, p0, 0xff

    shl-int/lit8 p1, v1, 0x8

    or-int/2addr p1, v0

    shl-int/lit8 v0, v2, 0x10

    or-int/2addr p1, v0

    shl-int/lit8 p0, p0, 0x18

    or-int/2addr p0, p1

    return p0
.end method


# virtual methods
.method protected final zzb(IIII)V
    .locals 1

    const/16 v0, 0x10

    .line 1
    invoke-virtual {p0, p1, p2, p4, v0}, Lcom/google/android/recaptcha/internal/zzqc;->zzc(IIII)V

    const/16 v0, 0xc

    .line 2
    invoke-virtual {p0, p3, p4, p2, v0}, Lcom/google/android/recaptcha/internal/zzqc;->zzc(IIII)V

    const/16 v0, 0x8

    .line 3
    invoke-virtual {p0, p1, p2, p4, v0}, Lcom/google/android/recaptcha/internal/zzqc;->zzc(IIII)V

    const/4 p1, 0x7

    .line 4
    invoke-virtual {p0, p3, p4, p2, p1}, Lcom/google/android/recaptcha/internal/zzqc;->zzc(IIII)V

    return-void
.end method

.method protected final zzc(IIII)V
    .locals 2

    .line 1
    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzqc;->zzb:[I

    aget v1, v0, p1

    aget p2, v0, p2

    add-int/2addr v1, p2

    aput v1, v0, p1

    .line 2
    aget p1, v0, p3

    invoke-static {p1, v1}, Lcom/google/android/recaptcha/internal/zzqc;->zza(II)I

    move-result p1

    aput p1, v0, p3

    rsub-int/lit8 p2, p4, 0x20

    ushr-int p2, p1, p2

    shl-int/2addr p1, p4

    or-int/2addr p1, p2

    .line 3
    aput p1, v0, p3

    return-void
.end method

.method protected final zzd([B)[B
    .locals 16

    move-object/from16 v0, p0

    move-object/from16 v1, p1

    .line 1
    iget v2, v0, Lcom/google/android/recaptcha/internal/zzqc;->zzg:I

    const/4 v3, 0x1

    if-ne v2, v3, :cond_4

    .line 2
    array-length v2, v1

    new-array v4, v2, [B

    const/4 v5, 0x0

    move v6, v5

    :goto_0
    if-lez v2, :cond_3

    iget-object v7, v0, Lcom/google/android/recaptcha/internal/zzqc;->zzc:[I

    iget-object v8, v0, Lcom/google/android/recaptcha/internal/zzqc;->zzb:[I

    .line 3
    array-length v9, v7

    const/16 v9, 0x10

    invoke-static {v7, v5, v8, v5, v9}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    iget-object v7, v0, Lcom/google/android/recaptcha/internal/zzqc;->zzb:[I

    iget v8, v0, Lcom/google/android/recaptcha/internal/zzqc;->zzg:I

    const/16 v10, 0xc

    .line 4
    aput v8, v7, v10

    move v7, v5

    :goto_1
    const/4 v8, 0x3

    const/16 v11, 0xa

    if-ge v7, v11, :cond_0

    const/4 v12, 0x4

    const/16 v13, 0x8

    .line 5
    invoke-virtual {v0, v5, v12, v13, v10}, Lcom/google/android/recaptcha/internal/zzqc;->zzb(IIII)V

    const/4 v14, 0x5

    const/16 v15, 0x9

    const/16 v9, 0xd

    .line 6
    invoke-virtual {v0, v3, v14, v15, v9}, Lcom/google/android/recaptcha/internal/zzqc;->zzb(IIII)V

    const/4 v12, 0x2

    const/4 v15, 0x6

    const/16 v9, 0xe

    .line 7
    invoke-virtual {v0, v12, v15, v11, v9}, Lcom/google/android/recaptcha/internal/zzqc;->zzb(IIII)V

    const/4 v9, 0x7

    const/16 v12, 0xb

    const/16 v13, 0xf

    .line 8
    invoke-virtual {v0, v8, v9, v12, v13}, Lcom/google/android/recaptcha/internal/zzqc;->zzb(IIII)V

    .line 9
    invoke-virtual {v0, v5, v14, v11, v13}, Lcom/google/android/recaptcha/internal/zzqc;->zzb(IIII)V

    .line 10
    invoke-virtual {v0, v3, v15, v12, v10}, Lcom/google/android/recaptcha/internal/zzqc;->zzb(IIII)V

    const/16 v11, 0xd

    const/4 v12, 0x2

    const/16 v13, 0x8

    .line 11
    invoke-virtual {v0, v12, v9, v13, v11}, Lcom/google/android/recaptcha/internal/zzqc;->zzb(IIII)V

    const/16 v9, 0xe

    const/16 v11, 0x9

    const/4 v12, 0x4

    .line 12
    invoke-virtual {v0, v8, v12, v11, v9}, Lcom/google/android/recaptcha/internal/zzqc;->zzb(IIII)V

    add-int/lit8 v7, v7, 0x1

    const/16 v9, 0x10

    goto :goto_1

    :cond_0
    const/16 v7, 0x40

    new-array v9, v7, [B

    move v10, v5

    const/16 v11, 0x10

    :goto_2
    if-ge v10, v11, :cond_1

    iget-object v12, v0, Lcom/google/android/recaptcha/internal/zzqc;->zzb:[I

    .line 13
    aget v12, v12, v10

    mul-int/lit8 v13, v10, 0x4

    and-int/lit16 v14, v12, 0xff

    int-to-byte v14, v14

    .line 14
    aput-byte v14, v9, v13

    shr-int/lit8 v14, v12, 0x8

    add-int/lit8 v15, v13, 0x1

    and-int/lit16 v14, v14, 0xff

    int-to-byte v14, v14

    .line 15
    aput-byte v14, v9, v15

    shr-int/lit8 v14, v12, 0x10

    add-int/lit8 v15, v13, 0x2

    and-int/lit16 v14, v14, 0xff

    int-to-byte v14, v14

    .line 16
    aput-byte v14, v9, v15

    shr-int/lit8 v12, v12, 0x18

    add-int/2addr v13, v8

    and-int/lit16 v12, v12, 0xff

    int-to-byte v12, v12

    .line 17
    aput-byte v12, v9, v13

    add-int/lit8 v10, v10, 0x1

    goto :goto_2

    :cond_1
    move v8, v5

    .line 18
    :goto_3
    invoke-static {v7, v2}, Ljava/lang/Math;->min(II)I

    move-result v10

    if-ge v8, v10, :cond_2

    add-int v10, v6, v8

    .line 19
    aget-byte v11, v9, v8

    aget-byte v12, v1, v10

    invoke-static {v11, v12}, Lcom/google/android/recaptcha/internal/zzqc;->zza(II)I

    move-result v11

    int-to-byte v11, v11

    aput-byte v11, v4, v10

    add-int/lit8 v8, v8, 0x1

    goto :goto_3

    :cond_2
    iget v7, v0, Lcom/google/android/recaptcha/internal/zzqc;->zzg:I

    add-int/2addr v7, v3

    iput v7, v0, Lcom/google/android/recaptcha/internal/zzqc;->zzg:I

    add-int/lit8 v2, v2, -0x40

    add-int/lit8 v6, v6, 0x40

    goto/16 :goto_0

    :cond_3
    return-object v4

    .line 1
    :cond_4
    new-instance v1, Ljava/lang/IllegalStateException;

    invoke-direct {v1}, Ljava/lang/IllegalStateException;-><init>()V

    throw v1
.end method
