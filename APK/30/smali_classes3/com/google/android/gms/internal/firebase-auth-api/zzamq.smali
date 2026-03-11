.class final Lcom/google/android/gms/internal/firebase-auth-api/zzamq;
.super Ljava/lang/Object;
.source "com.google.firebase:firebase-auth@@24.0.1"

# interfaces
.implements Lcom/google/android/gms/internal/firebase-auth-api/zzanb;


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "<T:",
        "Ljava/lang/Object;",
        ">",
        "Ljava/lang/Object;",
        "Lcom/google/android/gms/internal/firebase-auth-api/zzanb<",
        "TT;>;"
    }
.end annotation


# static fields
.field private static final zza:[I

.field private static final zzb:Lsun/misc/Unsafe;


# instance fields
.field private final zzc:[I

.field private final zzd:[Ljava/lang/Object;

.field private final zze:I

.field private final zzf:I

.field private final zzg:Lcom/google/android/gms/internal/firebase-auth-api/zzamm;

.field private final zzh:Z

.field private final zzi:Z

.field private final zzj:Z

.field private final zzk:[I

.field private final zzl:I

.field private final zzm:I

.field private final zzn:Lcom/google/android/gms/internal/firebase-auth-api/zzamu;

.field private final zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

.field private final zzp:Lcom/google/android/gms/internal/firebase-auth-api/zzanu;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lcom/google/android/gms/internal/firebase-auth-api/zzanu<",
            "**>;"
        }
    .end annotation
.end field

.field private final zzq:Lcom/google/android/gms/internal/firebase-auth-api/zzakw;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lcom/google/android/gms/internal/firebase-auth-api/zzakw<",
            "*>;"
        }
    .end annotation
.end field

.field private final zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    const/4 v0, 0x0

    .line 1446
    new-array v0, v0, [I

    sput-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza:[I

    .line 1447
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzb()Lsun/misc/Unsafe;

    move-result-object v0

    sput-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb:Lsun/misc/Unsafe;

    return-void
.end method

.method private constructor <init>([I[Ljava/lang/Object;IILcom/google/android/gms/internal/firebase-auth-api/zzamm;Z[IIILcom/google/android/gms/internal/firebase-auth-api/zzamu;Lcom/google/android/gms/internal/firebase-auth-api/zzalw;Lcom/google/android/gms/internal/firebase-auth-api/zzanu;Lcom/google/android/gms/internal/firebase-auth-api/zzakw;Lcom/google/android/gms/internal/firebase-auth-api/zzamf;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "([I[",
            "Ljava/lang/Object;",
            "II",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzamm;",
            "Z[III",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzamu;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzalw;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzanu<",
            "**>;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzakw<",
            "*>;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzamf;",
            ")V"
        }
    .end annotation

    .line 1448
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 1449
    iput-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    .line 1450
    iput-object p2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd:[Ljava/lang/Object;

    .line 1451
    iput p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze:I

    .line 1452
    iput p4, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzf:I

    .line 1453
    instance-of p1, p5, Lcom/google/android/gms/internal/firebase-auth-api/zzalf;

    iput-boolean p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzi:Z

    const/4 p1, 0x0

    if-eqz p13, :cond_0

    .line 1454
    invoke-virtual {p13, p5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakw;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzamm;)Z

    move-result p2

    if-eqz p2, :cond_0

    const/4 p2, 0x1

    goto :goto_0

    :cond_0
    move p2, p1

    :goto_0
    iput-boolean p2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzh:Z

    .line 1455
    iput-boolean p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzj:Z

    .line 1456
    iput-object p7, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzk:[I

    .line 1457
    iput p8, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzl:I

    .line 1458
    iput p9, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzm:I

    .line 1459
    iput-object p10, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzn:Lcom/google/android/gms/internal/firebase-auth-api/zzamu;

    .line 1460
    iput-object p11, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    .line 1461
    iput-object p12, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzp:Lcom/google/android/gms/internal/firebase-auth-api/zzanu;

    .line 1462
    iput-object p13, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzq:Lcom/google/android/gms/internal/firebase-auth-api/zzakw;

    .line 1463
    iput-object p5, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzg:Lcom/google/android/gms/internal/firebase-auth-api/zzamm;

    .line 1464
    iput-object p14, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    return-void
.end method

.method private static zza(Ljava/lang/Object;J)D
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<T:",
            "Ljava/lang/Object;",
            ">(TT;J)D"
        }
    .end annotation

    .line 1
    invoke-static {p0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Double;

    invoke-virtual {p0}, Ljava/lang/Double;->doubleValue()D

    move-result-wide p0

    return-wide p0
.end method

.method private final zza(I)I
    .locals 1

    .line 1122
    iget v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze:I

    if-lt p1, v0, :cond_0

    iget v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzf:I

    if-gt p1, v0, :cond_0

    const/4 v0, 0x0

    .line 1123
    invoke-direct {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(II)I

    move-result p1

    return p1

    :cond_0
    const/4 p1, -0x1

    return p1
.end method

.method private final zza(II)I
    .locals 4

    .line 1126
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    array-length v0, v0

    div-int/lit8 v0, v0, 0x3

    add-int/lit8 v0, v0, -0x1

    :goto_0
    if-gt p2, v0, :cond_2

    add-int v1, v0, p2

    ushr-int/lit8 v1, v1, 0x1

    mul-int/lit8 v2, v1, 0x3

    .line 1131
    iget-object v3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v3, v3, v2

    if-ne p1, v3, :cond_0

    return v2

    :cond_0
    if-ge p1, v3, :cond_1

    add-int/lit8 v0, v1, -0x1

    goto :goto_0

    :cond_1
    add-int/lit8 p2, v1, 0x1

    goto :goto_0

    :cond_2
    const/4 p1, -0x1

    return p1
.end method

.method private static zza([BIILcom/google/android/gms/internal/firebase-auth-api/zzaog;Ljava/lang/Class;Lcom/google/android/gms/internal/firebase-auth-api/zzaju;)I
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "([BII",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzaog;",
            "Ljava/lang/Class<",
            "*>;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzaju;",
            ")I"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 3
    sget-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamp;->zza:[I

    invoke-virtual {p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzaog;->ordinal()I

    move-result p3

    aget p3, v0, p3

    packed-switch p3, :pswitch_data_0

    .line 38
    new-instance p0, Ljava/lang/RuntimeException;

    const-string p1, "unsupported field type."

    invoke-direct {p0, p1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw p0

    .line 36
    :pswitch_0
    invoke-static {p0, p1, p5}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzb([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result p0

    return p0

    .line 33
    :pswitch_1
    invoke-static {p0, p1, p5}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result p0

    .line 34
    iget-wide p1, p5, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzb:J

    invoke-static {p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakh;->zza(J)J

    move-result-wide p1

    invoke-static {p1, p2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object p1

    iput-object p1, p5, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzc:Ljava/lang/Object;

    return p0

    .line 30
    :pswitch_2
    invoke-static {p0, p1, p5}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result p0

    .line 31
    iget p1, p5, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    invoke-static {p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakh;->zza(I)I

    move-result p1

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    iput-object p1, p5, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzc:Ljava/lang/Object;

    return p0

    .line 27
    :pswitch_3
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzamx;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzamx;

    move-result-object p3

    invoke-virtual {p3, p4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamx;->zza(Ljava/lang/Class;)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object p3

    .line 28
    invoke-static {p3, p0, p1, p2, p5}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzanb;[BIILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result p0

    return p0

    .line 24
    :pswitch_4
    invoke-static {p0, p1, p5}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result p0

    .line 25
    iget-wide p1, p5, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzb:J

    invoke-static {p1, p2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object p1

    iput-object p1, p5, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzc:Ljava/lang/Object;

    return p0

    .line 21
    :pswitch_5
    invoke-static {p0, p1, p5}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result p0

    .line 22
    iget p1, p5, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    iput-object p1, p5, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzc:Ljava/lang/Object;

    return p0

    .line 18
    :pswitch_6
    invoke-static {p0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzb([BI)F

    move-result p0

    invoke-static {p0}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object p0

    iput-object p0, p5, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzc:Ljava/lang/Object;

    add-int/lit8 p1, p1, 0x4

    return p1

    .line 15
    :pswitch_7
    invoke-static {p0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BI)J

    move-result-wide p2

    invoke-static {p2, p3}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object p0

    iput-object p0, p5, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzc:Ljava/lang/Object;

    add-int/lit8 p1, p1, 0x8

    return p1

    .line 12
    :pswitch_8
    invoke-static {p0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BI)I

    move-result p0

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p0

    iput-object p0, p5, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzc:Ljava/lang/Object;

    add-int/lit8 p1, p1, 0x4

    return p1

    .line 9
    :pswitch_9
    invoke-static {p0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza([BI)D

    move-result-wide p2

    invoke-static {p2, p3}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;

    move-result-object p0

    iput-object p0, p5, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzc:Ljava/lang/Object;

    add-int/lit8 p1, p1, 0x8

    return p1

    .line 7
    :pswitch_a
    invoke-static {p0, p1, p5}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result p0

    return p0

    .line 4
    :pswitch_b
    invoke-static {p0, p1, p5}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result p0

    .line 5
    iget-wide p1, p5, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzb:J

    const-wide/16 p3, 0x0

    cmp-long p1, p1, p3

    if-eqz p1, :cond_0

    const/4 p1, 0x1

    goto :goto_0

    :cond_0
    const/4 p1, 0x0

    :goto_0
    invoke-static {p1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object p1

    iput-object p1, p5, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzc:Ljava/lang/Object;

    return p0

    :pswitch_data_0
    .packed-switch 0x1
        :pswitch_b
        :pswitch_a
        :pswitch_9
        :pswitch_8
        :pswitch_8
        :pswitch_7
        :pswitch_7
        :pswitch_6
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_4
        :pswitch_4
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method static zza(Ljava/lang/Class;Lcom/google/android/gms/internal/firebase-auth-api/zzamk;Lcom/google/android/gms/internal/firebase-auth-api/zzamu;Lcom/google/android/gms/internal/firebase-auth-api/zzalw;Lcom/google/android/gms/internal/firebase-auth-api/zzanu;Lcom/google/android/gms/internal/firebase-auth-api/zzakw;Lcom/google/android/gms/internal/firebase-auth-api/zzamf;)Lcom/google/android/gms/internal/firebase-auth-api/zzamq;
    .locals 32
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<T:",
            "Ljava/lang/Object;",
            ">(",
            "Ljava/lang/Class<",
            "TT;>;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzamk;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzamu;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzalw;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzanu<",
            "**>;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzakw<",
            "*>;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzamf;",
            ")",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzamq<",
            "TT;>;"
        }
    .end annotation

    move-object/from16 v0, p1

    .line 1143
    instance-of v1, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamz;

    if-eqz v1, :cond_35

    .line 1144
    check-cast v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamz;

    .line 1145
    invoke-virtual {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamz;->zzd()Ljava/lang/String;

    move-result-object v1

    .line 1146
    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v2

    const/4 v3, 0x0

    .line 1148
    invoke-virtual {v1, v3}, Ljava/lang/String;->charAt(I)C

    move-result v4

    const v5, 0xd800

    if-lt v4, v5, :cond_0

    const/4 v4, 0x1

    :goto_0
    add-int/lit8 v7, v4, 0x1

    .line 1152
    invoke-virtual {v1, v4}, Ljava/lang/String;->charAt(I)C

    move-result v4

    if-lt v4, v5, :cond_1

    move v4, v7

    goto :goto_0

    :cond_0
    const/4 v7, 0x1

    :cond_1
    add-int/lit8 v4, v7, 0x1

    .line 1155
    invoke-virtual {v1, v7}, Ljava/lang/String;->charAt(I)C

    move-result v7

    if-lt v7, v5, :cond_3

    and-int/lit16 v7, v7, 0x1fff

    const/16 v9, 0xd

    :goto_1
    add-int/lit8 v10, v4, 0x1

    .line 1159
    invoke-virtual {v1, v4}, Ljava/lang/String;->charAt(I)C

    move-result v4

    if-lt v4, v5, :cond_2

    and-int/lit16 v4, v4, 0x1fff

    shl-int/2addr v4, v9

    or-int/2addr v7, v4

    add-int/lit8 v9, v9, 0xd

    move v4, v10

    goto :goto_1

    :cond_2
    shl-int/2addr v4, v9

    or-int/2addr v7, v4

    move v4, v10

    :cond_3
    if-nez v7, :cond_4

    .line 1171
    sget-object v7, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza:[I

    move v9, v3

    move v10, v9

    move v11, v10

    move v12, v11

    move v13, v12

    move/from16 v17, v13

    move-object/from16 v16, v7

    move/from16 v7, v17

    goto/16 :goto_a

    :cond_4
    add-int/lit8 v7, v4, 0x1

    .line 1173
    invoke-virtual {v1, v4}, Ljava/lang/String;->charAt(I)C

    move-result v4

    if-lt v4, v5, :cond_6

    and-int/lit16 v4, v4, 0x1fff

    const/16 v9, 0xd

    :goto_2
    add-int/lit8 v10, v7, 0x1

    .line 1177
    invoke-virtual {v1, v7}, Ljava/lang/String;->charAt(I)C

    move-result v7

    if-lt v7, v5, :cond_5

    and-int/lit16 v7, v7, 0x1fff

    shl-int/2addr v7, v9

    or-int/2addr v4, v7

    add-int/lit8 v9, v9, 0xd

    move v7, v10

    goto :goto_2

    :cond_5
    shl-int/2addr v7, v9

    or-int/2addr v4, v7

    move v7, v10

    :cond_6
    add-int/lit8 v9, v7, 0x1

    .line 1182
    invoke-virtual {v1, v7}, Ljava/lang/String;->charAt(I)C

    move-result v7

    if-lt v7, v5, :cond_8

    and-int/lit16 v7, v7, 0x1fff

    const/16 v10, 0xd

    :goto_3
    add-int/lit8 v11, v9, 0x1

    .line 1186
    invoke-virtual {v1, v9}, Ljava/lang/String;->charAt(I)C

    move-result v9

    if-lt v9, v5, :cond_7

    and-int/lit16 v9, v9, 0x1fff

    shl-int/2addr v9, v10

    or-int/2addr v7, v9

    add-int/lit8 v10, v10, 0xd

    move v9, v11

    goto :goto_3

    :cond_7
    shl-int/2addr v9, v10

    or-int/2addr v7, v9

    move v9, v11

    :cond_8
    add-int/lit8 v10, v9, 0x1

    .line 1191
    invoke-virtual {v1, v9}, Ljava/lang/String;->charAt(I)C

    move-result v9

    if-lt v9, v5, :cond_a

    and-int/lit16 v9, v9, 0x1fff

    const/16 v11, 0xd

    :goto_4
    add-int/lit8 v12, v10, 0x1

    .line 1195
    invoke-virtual {v1, v10}, Ljava/lang/String;->charAt(I)C

    move-result v10

    if-lt v10, v5, :cond_9

    and-int/lit16 v10, v10, 0x1fff

    shl-int/2addr v10, v11

    or-int/2addr v9, v10

    add-int/lit8 v11, v11, 0xd

    move v10, v12

    goto :goto_4

    :cond_9
    shl-int/2addr v10, v11

    or-int/2addr v9, v10

    move v10, v12

    :cond_a
    add-int/lit8 v11, v10, 0x1

    .line 1200
    invoke-virtual {v1, v10}, Ljava/lang/String;->charAt(I)C

    move-result v10

    if-lt v10, v5, :cond_c

    and-int/lit16 v10, v10, 0x1fff

    const/16 v12, 0xd

    :goto_5
    add-int/lit8 v13, v11, 0x1

    .line 1204
    invoke-virtual {v1, v11}, Ljava/lang/String;->charAt(I)C

    move-result v11

    if-lt v11, v5, :cond_b

    and-int/lit16 v11, v11, 0x1fff

    shl-int/2addr v11, v12

    or-int/2addr v10, v11

    add-int/lit8 v12, v12, 0xd

    move v11, v13

    goto :goto_5

    :cond_b
    shl-int/2addr v11, v12

    or-int/2addr v10, v11

    move v11, v13

    :cond_c
    add-int/lit8 v12, v11, 0x1

    .line 1209
    invoke-virtual {v1, v11}, Ljava/lang/String;->charAt(I)C

    move-result v11

    if-lt v11, v5, :cond_e

    and-int/lit16 v11, v11, 0x1fff

    const/16 v13, 0xd

    :goto_6
    add-int/lit8 v14, v12, 0x1

    .line 1213
    invoke-virtual {v1, v12}, Ljava/lang/String;->charAt(I)C

    move-result v12

    if-lt v12, v5, :cond_d

    and-int/lit16 v12, v12, 0x1fff

    shl-int/2addr v12, v13

    or-int/2addr v11, v12

    add-int/lit8 v13, v13, 0xd

    move v12, v14

    goto :goto_6

    :cond_d
    shl-int/2addr v12, v13

    or-int/2addr v11, v12

    move v12, v14

    :cond_e
    add-int/lit8 v13, v12, 0x1

    .line 1218
    invoke-virtual {v1, v12}, Ljava/lang/String;->charAt(I)C

    move-result v12

    if-lt v12, v5, :cond_10

    and-int/lit16 v12, v12, 0x1fff

    const/16 v14, 0xd

    :goto_7
    add-int/lit8 v15, v13, 0x1

    .line 1222
    invoke-virtual {v1, v13}, Ljava/lang/String;->charAt(I)C

    move-result v13

    if-lt v13, v5, :cond_f

    and-int/lit16 v13, v13, 0x1fff

    shl-int/2addr v13, v14

    or-int/2addr v12, v13

    add-int/lit8 v14, v14, 0xd

    move v13, v15

    goto :goto_7

    :cond_f
    shl-int/2addr v13, v14

    or-int/2addr v12, v13

    move v13, v15

    :cond_10
    add-int/lit8 v14, v13, 0x1

    .line 1227
    invoke-virtual {v1, v13}, Ljava/lang/String;->charAt(I)C

    move-result v13

    if-lt v13, v5, :cond_12

    and-int/lit16 v13, v13, 0x1fff

    const/16 v15, 0xd

    :goto_8
    add-int/lit8 v16, v14, 0x1

    .line 1231
    invoke-virtual {v1, v14}, Ljava/lang/String;->charAt(I)C

    move-result v14

    if-lt v14, v5, :cond_11

    and-int/lit16 v14, v14, 0x1fff

    shl-int/2addr v14, v15

    or-int/2addr v13, v14

    add-int/lit8 v15, v15, 0xd

    move/from16 v14, v16

    goto :goto_8

    :cond_11
    shl-int/2addr v14, v15

    or-int/2addr v13, v14

    move/from16 v14, v16

    :cond_12
    add-int/lit8 v15, v14, 0x1

    .line 1236
    invoke-virtual {v1, v14}, Ljava/lang/String;->charAt(I)C

    move-result v14

    if-lt v14, v5, :cond_14

    and-int/lit16 v14, v14, 0x1fff

    const/16 v16, 0xd

    :goto_9
    add-int/lit8 v17, v15, 0x1

    .line 1240
    invoke-virtual {v1, v15}, Ljava/lang/String;->charAt(I)C

    move-result v15

    if-lt v15, v5, :cond_13

    and-int/lit16 v15, v15, 0x1fff

    shl-int v15, v15, v16

    or-int/2addr v14, v15

    add-int/lit8 v16, v16, 0xd

    move/from16 v15, v17

    goto :goto_9

    :cond_13
    shl-int v15, v15, v16

    or-int/2addr v14, v15

    move/from16 v15, v17

    :cond_14
    add-int v16, v14, v12

    add-int v13, v16, v13

    .line 1245
    new-array v13, v13, [I

    shl-int/lit8 v16, v4, 0x1

    add-int v16, v16, v7

    move v7, v12

    move v12, v9

    move v9, v7

    move-object v7, v13

    move v13, v10

    move/from16 v10, v16

    move-object/from16 v16, v7

    move v7, v4

    move/from16 v17, v14

    move v4, v15

    .line 1247
    :goto_a
    sget-object v14, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb:Lsun/misc/Unsafe;

    .line 1248
    invoke-virtual {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamz;->zze()[Ljava/lang/Object;

    move-result-object v15

    .line 1250
    invoke-virtual {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamz;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzamm;

    move-result-object v18

    invoke-virtual/range {v18 .. v18}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v3

    const/16 p1, 0x1

    mul-int/lit8 v6, v11, 0x3

    .line 1251
    new-array v6, v6, [I

    shl-int/lit8 v11, v11, 0x1

    .line 1252
    new-array v11, v11, [Ljava/lang/Object;

    add-int v18, v17, v9

    move/from16 v20, v17

    move/from16 v21, v18

    const/4 v9, 0x0

    const/16 v19, 0x0

    :goto_b
    if-ge v4, v2, :cond_34

    add-int/lit8 v22, v4, 0x1

    .line 1257
    invoke-virtual {v1, v4}, Ljava/lang/String;->charAt(I)C

    move-result v4

    if-lt v4, v5, :cond_16

    and-int/lit16 v4, v4, 0x1fff

    move/from16 v8, v22

    const/16 v22, 0xd

    :goto_c
    add-int/lit8 v24, v8, 0x1

    .line 1261
    invoke-virtual {v1, v8}, Ljava/lang/String;->charAt(I)C

    move-result v8

    if-lt v8, v5, :cond_15

    and-int/lit16 v8, v8, 0x1fff

    shl-int v8, v8, v22

    or-int/2addr v4, v8

    add-int/lit8 v22, v22, 0xd

    move/from16 v8, v24

    goto :goto_c

    :cond_15
    shl-int v8, v8, v22

    or-int/2addr v4, v8

    move/from16 v8, v24

    goto :goto_d

    :cond_16
    move/from16 v8, v22

    :goto_d
    add-int/lit8 v22, v8, 0x1

    .line 1266
    invoke-virtual {v1, v8}, Ljava/lang/String;->charAt(I)C

    move-result v8

    if-lt v8, v5, :cond_18

    and-int/lit16 v8, v8, 0x1fff

    move/from16 v5, v22

    const/16 v22, 0xd

    :goto_e
    add-int/lit8 v25, v5, 0x1

    .line 1270
    invoke-virtual {v1, v5}, Ljava/lang/String;->charAt(I)C

    move-result v5

    move-object/from16 v26, v0

    const v0, 0xd800

    if-lt v5, v0, :cond_17

    and-int/lit16 v0, v5, 0x1fff

    shl-int v0, v0, v22

    or-int/2addr v8, v0

    add-int/lit8 v22, v22, 0xd

    move/from16 v5, v25

    move-object/from16 v0, v26

    goto :goto_e

    :cond_17
    shl-int v0, v5, v22

    or-int/2addr v8, v0

    move/from16 v0, v25

    goto :goto_f

    :cond_18
    move-object/from16 v26, v0

    move/from16 v0, v22

    :goto_f
    and-int/lit16 v5, v8, 0xff

    move/from16 v22, v2

    and-int/lit16 v2, v8, 0x400

    if-eqz v2, :cond_19

    add-int/lit8 v2, v19, 0x1

    .line 1277
    aput v9, v16, v19

    move/from16 v19, v2

    :cond_19
    const/16 v2, 0x33

    move/from16 v28, v4

    if-lt v5, v2, :cond_22

    add-int/lit8 v2, v0, 0x1

    .line 1279
    invoke-virtual {v1, v0}, Ljava/lang/String;->charAt(I)C

    move-result v0

    const v4, 0xd800

    if-lt v0, v4, :cond_1b

    and-int/lit16 v0, v0, 0x1fff

    const/16 v29, 0xd

    :goto_10
    add-int/lit8 v30, v2, 0x1

    .line 1283
    invoke-virtual {v1, v2}, Ljava/lang/String;->charAt(I)C

    move-result v2

    if-lt v2, v4, :cond_1a

    and-int/lit16 v2, v2, 0x1fff

    shl-int v2, v2, v29

    or-int/2addr v0, v2

    add-int/lit8 v29, v29, 0xd

    move/from16 v2, v30

    const v4, 0xd800

    goto :goto_10

    :cond_1a
    shl-int v2, v2, v29

    or-int/2addr v0, v2

    move/from16 v2, v30

    :cond_1b
    add-int/lit8 v4, v5, -0x33

    move/from16 v29, v0

    const/16 v0, 0x9

    if-eq v4, v0, :cond_1e

    const/16 v0, 0x11

    if-ne v4, v0, :cond_1c

    goto :goto_11

    :cond_1c
    const/16 v0, 0xc

    if-ne v4, v0, :cond_1f

    .line 1292
    invoke-virtual/range {v26 .. v26}, Lcom/google/android/gms/internal/firebase-auth-api/zzamz;->zzb()Lcom/google/android/gms/internal/firebase-auth-api/zzamy;

    move-result-object v0

    sget-object v4, Lcom/google/android/gms/internal/firebase-auth-api/zzamy;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzamy;

    invoke-virtual {v0, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamy;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_1d

    and-int/lit16 v0, v8, 0x800

    if-eqz v0, :cond_1f

    .line 1293
    :cond_1d
    div-int/lit8 v0, v9, 0x3

    shl-int/lit8 v0, v0, 0x1

    add-int/lit8 v0, v0, 0x1

    add-int/lit8 v4, v10, 0x1

    aget-object v10, v15, v10

    aput-object v10, v11, v0

    goto :goto_12

    .line 1290
    :cond_1e
    :goto_11
    div-int/lit8 v0, v9, 0x3

    shl-int/lit8 v0, v0, 0x1

    add-int/lit8 v0, v0, 0x1

    add-int/lit8 v4, v10, 0x1

    aget-object v10, v15, v10

    aput-object v10, v11, v0

    :goto_12
    move v10, v4

    :cond_1f
    shl-int/lit8 v0, v29, 0x1

    .line 1295
    aget-object v4, v15, v0

    move/from16 v25, v0

    .line 1296
    instance-of v0, v4, Ljava/lang/reflect/Field;

    if-eqz v0, :cond_20

    .line 1297
    check-cast v4, Ljava/lang/reflect/Field;

    goto :goto_13

    .line 1298
    :cond_20
    check-cast v4, Ljava/lang/String;

    invoke-static {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v4

    .line 1299
    aput-object v4, v15, v25

    :goto_13
    move-object/from16 v30, v6

    move/from16 v29, v7

    .line 1300
    invoke-virtual {v14, v4}, Lsun/misc/Unsafe;->objectFieldOffset(Ljava/lang/reflect/Field;)J

    move-result-wide v6

    long-to-int v0, v6

    add-int/lit8 v4, v25, 0x1

    .line 1302
    aget-object v6, v15, v4

    .line 1303
    instance-of v7, v6, Ljava/lang/reflect/Field;

    if-eqz v7, :cond_21

    .line 1304
    check-cast v6, Ljava/lang/reflect/Field;

    goto :goto_14

    .line 1305
    :cond_21
    check-cast v6, Ljava/lang/String;

    invoke-static {v3, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v6

    .line 1306
    aput-object v6, v15, v4

    .line 1307
    :goto_14
    invoke-virtual {v14, v6}, Lsun/misc/Unsafe;->objectFieldOffset(Ljava/lang/reflect/Field;)J

    move-result-wide v6

    long-to-int v4, v6

    move v6, v10

    move-object v10, v1

    const/4 v1, 0x0

    goto/16 :goto_1d

    :cond_22
    move-object/from16 v30, v6

    move/from16 v29, v7

    add-int/lit8 v2, v10, 0x1

    .line 1310
    aget-object v4, v15, v10

    check-cast v4, Ljava/lang/String;

    invoke-static {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v4

    const/16 v6, 0x31

    const/16 v7, 0x9

    if-eq v5, v7, :cond_2a

    const/16 v7, 0x11

    if-ne v5, v7, :cond_23

    goto :goto_18

    :cond_23
    const/16 v7, 0x1b

    if-eq v5, v7, :cond_29

    if-ne v5, v6, :cond_24

    goto :goto_16

    :cond_24
    const/16 v7, 0xc

    if-eq v5, v7, :cond_27

    const/16 v7, 0x1e

    if-eq v5, v7, :cond_27

    const/16 v7, 0x2c

    if-ne v5, v7, :cond_25

    goto :goto_15

    :cond_25
    const/16 v7, 0x32

    if-ne v5, v7, :cond_2b

    add-int/lit8 v7, v20, 0x1

    .line 1319
    aput v9, v16, v20

    .line 1320
    div-int/lit8 v20, v9, 0x3

    shl-int/lit8 v20, v20, 0x1

    add-int/lit8 v25, v10, 0x2

    aget-object v2, v15, v2

    aput-object v2, v11, v20

    and-int/lit16 v2, v8, 0x800

    if-eqz v2, :cond_26

    add-int/lit8 v20, v20, 0x1

    add-int/lit8 v2, v10, 0x3

    .line 1322
    aget-object v10, v15, v25

    aput-object v10, v11, v20

    move/from16 v20, v7

    goto :goto_19

    :cond_26
    move/from16 v20, v7

    move/from16 v2, v25

    goto :goto_19

    .line 1316
    :cond_27
    :goto_15
    invoke-virtual/range {v26 .. v26}, Lcom/google/android/gms/internal/firebase-auth-api/zzamz;->zzb()Lcom/google/android/gms/internal/firebase-auth-api/zzamy;

    move-result-object v7

    sget-object v6, Lcom/google/android/gms/internal/firebase-auth-api/zzamy;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzamy;

    if-eq v7, v6, :cond_28

    and-int/lit16 v6, v8, 0x800

    if-eqz v6, :cond_2b

    .line 1317
    :cond_28
    div-int/lit8 v6, v9, 0x3

    shl-int/lit8 v6, v6, 0x1

    add-int/lit8 v6, v6, 0x1

    add-int/lit8 v10, v10, 0x2

    aget-object v2, v15, v2

    aput-object v2, v11, v6

    goto :goto_17

    .line 1314
    :cond_29
    :goto_16
    div-int/lit8 v6, v9, 0x3

    shl-int/lit8 v6, v6, 0x1

    add-int/lit8 v6, v6, 0x1

    add-int/lit8 v10, v10, 0x2

    aget-object v2, v15, v2

    aput-object v2, v11, v6

    :goto_17
    move v2, v10

    goto :goto_19

    .line 1312
    :cond_2a
    :goto_18
    div-int/lit8 v6, v9, 0x3

    shl-int/lit8 v6, v6, 0x1

    add-int/lit8 v6, v6, 0x1

    invoke-virtual {v4}, Ljava/lang/reflect/Field;->getType()Ljava/lang/Class;

    move-result-object v7

    aput-object v7, v11, v6

    .line 1323
    :cond_2b
    :goto_19
    invoke-virtual {v14, v4}, Lsun/misc/Unsafe;->objectFieldOffset(Ljava/lang/reflect/Field;)J

    move-result-wide v6

    long-to-int v4, v6

    and-int/lit16 v6, v8, 0x1000

    if-eqz v6, :cond_2f

    const/16 v7, 0x11

    if-gt v5, v7, :cond_2f

    add-int/lit8 v6, v0, 0x1

    .line 1326
    invoke-virtual {v1, v0}, Ljava/lang/String;->charAt(I)C

    move-result v0

    const v7, 0xd800

    if-lt v0, v7, :cond_2d

    and-int/lit16 v0, v0, 0x1fff

    const/16 v10, 0xd

    :goto_1a
    add-int/lit8 v24, v6, 0x1

    .line 1330
    invoke-virtual {v1, v6}, Ljava/lang/String;->charAt(I)C

    move-result v6

    if-lt v6, v7, :cond_2c

    and-int/lit16 v6, v6, 0x1fff

    shl-int/2addr v6, v10

    or-int/2addr v0, v6

    add-int/lit8 v10, v10, 0xd

    move/from16 v6, v24

    goto :goto_1a

    :cond_2c
    shl-int/2addr v6, v10

    or-int/2addr v0, v6

    move/from16 v6, v24

    :cond_2d
    shl-int/lit8 v10, v29, 0x1

    .line 1335
    div-int/lit8 v24, v0, 0x20

    add-int v10, v10, v24

    .line 1336
    aget-object v7, v15, v10

    move/from16 v27, v0

    .line 1337
    instance-of v0, v7, Ljava/lang/reflect/Field;

    if-eqz v0, :cond_2e

    .line 1338
    check-cast v7, Ljava/lang/reflect/Field;

    goto :goto_1b

    .line 1339
    :cond_2e
    check-cast v7, Ljava/lang/String;

    invoke-static {v3, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object v7

    .line 1340
    aput-object v7, v15, v10

    :goto_1b
    move-object v10, v1

    .line 1341
    invoke-virtual {v14, v7}, Lsun/misc/Unsafe;->objectFieldOffset(Ljava/lang/reflect/Field;)J

    move-result-wide v0

    long-to-int v0, v0

    .line 1342
    rem-int/lit8 v1, v27, 0x20

    move/from16 v31, v6

    move v6, v0

    move/from16 v0, v31

    goto :goto_1c

    :cond_2f
    move-object v10, v1

    const v1, 0xfffff

    move v6, v1

    const/4 v1, 0x0

    :goto_1c
    const/16 v7, 0x12

    if-lt v5, v7, :cond_30

    const/16 v7, 0x31

    if-gt v5, v7, :cond_30

    add-int/lit8 v7, v21, 0x1

    .line 1347
    aput v4, v16, v21

    move/from16 v21, v2

    move v2, v0

    move v0, v4

    move v4, v6

    move/from16 v6, v21

    move/from16 v21, v7

    goto :goto_1d

    :cond_30
    move/from16 v31, v2

    move v2, v0

    move v0, v4

    move v4, v6

    move/from16 v6, v31

    :goto_1d
    add-int/lit8 v7, v9, 0x1

    .line 1348
    aput v28, v30, v9

    add-int/lit8 v25, v9, 0x2

    move/from16 v27, v0

    and-int/lit16 v0, v8, 0x200

    if-eqz v0, :cond_31

    const/high16 v0, 0x20000000

    goto :goto_1e

    :cond_31
    const/4 v0, 0x0

    :goto_1e
    move/from16 v28, v0

    and-int/lit16 v0, v8, 0x100

    if-eqz v0, :cond_32

    const/high16 v0, 0x10000000

    goto :goto_1f

    :cond_32
    const/4 v0, 0x0

    :goto_1f
    or-int v0, v28, v0

    and-int/lit16 v8, v8, 0x800

    if-eqz v8, :cond_33

    const/high16 v8, -0x80000000

    goto :goto_20

    :cond_33
    const/4 v8, 0x0

    :goto_20
    or-int/2addr v0, v8

    shl-int/lit8 v5, v5, 0x14

    or-int/2addr v0, v5

    or-int v0, v0, v27

    .line 1354
    aput v0, v30, v7

    add-int/lit8 v9, v9, 0x3

    shl-int/lit8 v0, v1, 0x14

    or-int/2addr v0, v4

    .line 1355
    aput v0, v30, v25

    move v4, v2

    move-object v1, v10

    move/from16 v2, v22

    move-object/from16 v0, v26

    move/from16 v7, v29

    const v5, 0xd800

    move v10, v6

    move-object/from16 v6, v30

    goto/16 :goto_b

    :cond_34
    move-object/from16 v26, v0

    move-object/from16 v30, v6

    .line 1357
    new-instance v9, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;

    .line 1358
    invoke-virtual/range {v26 .. v26}, Lcom/google/android/gms/internal/firebase-auth-api/zzamz;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzamm;

    move-result-object v14

    const/4 v15, 0x0

    move-object/from16 v19, p2

    move-object/from16 v20, p3

    move-object/from16 v21, p4

    move-object/from16 v22, p5

    move-object/from16 v23, p6

    move-object/from16 v10, v30

    invoke-direct/range {v9 .. v23}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;-><init>([I[Ljava/lang/Object;IILcom/google/android/gms/internal/firebase-auth-api/zzamm;Z[IIILcom/google/android/gms/internal/firebase-auth-api/zzamu;Lcom/google/android/gms/internal/firebase-auth-api/zzalw;Lcom/google/android/gms/internal/firebase-auth-api/zzanu;Lcom/google/android/gms/internal/firebase-auth-api/zzakw;Lcom/google/android/gms/internal/firebase-auth-api/zzamf;)V

    return-object v9

    .line 1360
    :cond_35
    check-cast v0, Lcom/google/android/gms/internal/firebase-auth-api/zzano;

    .line 1361
    new-instance v0, Ljava/lang/NoSuchMethodError;

    invoke-direct {v0}, Ljava/lang/NoSuchMethodError;-><init>()V

    throw v0
.end method

.method private final zza(IILjava/util/Map;Lcom/google/android/gms/internal/firebase-auth-api/zzalj;Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanu;Ljava/lang/Object;)Ljava/lang/Object;
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<K:",
            "Ljava/lang/Object;",
            "V:",
            "Ljava/lang/Object;",
            "UT:",
            "Ljava/lang/Object;",
            "UB:",
            "Ljava/lang/Object;",
            ">(II",
            "Ljava/util/Map<",
            "TK;TV;>;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzalj;",
            "TUB;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzanu<",
            "TUT;TUB;>;",
            "Ljava/lang/Object;",
            ")TUB;"
        }
    .end annotation

    .line 1390
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    .line 1391
    invoke-direct {p0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzf(I)Ljava/lang/Object;

    move-result-object p1

    invoke-interface {v0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamf;->zza(Ljava/lang/Object;)Lcom/google/android/gms/internal/firebase-auth-api/zzamd;

    move-result-object p1

    .line 1392
    invoke-interface {p3}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object p3

    invoke-interface {p3}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object p3

    :cond_0
    :goto_0
    invoke-interface {p3}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_2

    .line 1393
    invoke-interface {p3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/util/Map$Entry;

    .line 1394
    invoke-interface {v0}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Integer;

    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I

    move-result v1

    invoke-interface {p4, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzalj;->zza(I)Z

    move-result v1

    if-nez v1, :cond_0

    if-nez p5, :cond_1

    .line 1396
    invoke-virtual {p6, p7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zzc(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p5

    .line 1398
    :cond_1
    invoke-interface {v0}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v1

    invoke-interface {v0}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v2

    invoke-static {p1, v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzame;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzamd;Ljava/lang/Object;Ljava/lang/Object;)I

    move-result v1

    .line 1399
    invoke-static {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;->zzc(I)Lcom/google/android/gms/internal/firebase-auth-api/zzake;

    move-result-object v1

    .line 1400
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzake;->zzb()Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    move-result-object v2

    .line 1401
    :try_start_0
    invoke-interface {v0}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v3

    invoke-interface {v0}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v0

    invoke-static {v2, p1, v3, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzame;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzakn;Lcom/google/android/gms/internal/firebase-auth-api/zzamd;Ljava/lang/Object;Ljava/lang/Object;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 1405
    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzake;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    move-result-object v0

    invoke-virtual {p6, p5, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zza(Ljava/lang/Object;ILcom/google/android/gms/internal/firebase-auth-api/zzajv;)V

    .line 1406
    invoke-interface {p3}, Ljava/util/Iterator;->remove()V

    goto :goto_0

    :catch_0
    move-exception p1

    .line 1404
    new-instance p2, Ljava/lang/RuntimeException;

    invoke-direct {p2, p1}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/Throwable;)V

    throw p2

    :cond_2
    return-object p5
.end method

.method private final zza(Ljava/lang/Object;I)Ljava/lang/Object;
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;I)",
            "Ljava/lang/Object;"
        }
    .end annotation

    .line 1410
    invoke-direct {p0, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v0

    .line 1411
    invoke-direct {p0, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(I)I

    move-result v1

    const v2, 0xfffff

    and-int/2addr v1, v2

    int-to-long v1, v1

    .line 1414
    invoke-direct {p0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result p2

    if-nez p2, :cond_0

    .line 1415
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zza()Ljava/lang/Object;

    move-result-object p1

    return-object p1

    .line 1416
    :cond_0
    sget-object p2, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb:Lsun/misc/Unsafe;

    invoke-virtual {p2, p1, v1, v2}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object p1

    .line 1417
    invoke-static {p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzg(Ljava/lang/Object;)Z

    move-result p2

    if-eqz p2, :cond_1

    return-object p1

    .line 1419
    :cond_1
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zza()Ljava/lang/Object;

    move-result-object p2

    if-eqz p1, :cond_2

    .line 1421
    invoke-interface {v0, p2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zza(Ljava/lang/Object;Ljava/lang/Object;)V

    :cond_2
    return-object p2
.end method

.method private final zza(Ljava/lang/Object;II)Ljava/lang/Object;
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;II)",
            "Ljava/lang/Object;"
        }
    .end annotation

    .line 1423
    invoke-direct {p0, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v0

    .line 1424
    invoke-direct {p0, p1, p2, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result p2

    if-nez p2, :cond_0

    .line 1425
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zza()Ljava/lang/Object;

    move-result-object p1

    return-object p1

    .line 1426
    :cond_0
    sget-object p2, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb:Lsun/misc/Unsafe;

    invoke-direct {p0, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(I)I

    move-result p3

    const v1, 0xfffff

    and-int/2addr p3, v1

    int-to-long v1, p3

    .line 1428
    invoke-virtual {p2, p1, v1, v2}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object p1

    .line 1429
    invoke-static {p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzg(Ljava/lang/Object;)Z

    move-result p2

    if-eqz p2, :cond_1

    return-object p1

    .line 1431
    :cond_1
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zza()Ljava/lang/Object;

    move-result-object p2

    if-eqz p1, :cond_2

    .line 1433
    invoke-interface {v0, p2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zza(Ljava/lang/Object;Ljava/lang/Object;)V

    :cond_2
    return-object p2
.end method

.method private final zza(Ljava/lang/Object;ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanu;Ljava/lang/Object;)Ljava/lang/Object;
    .locals 9
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<UT:",
            "Ljava/lang/Object;",
            "UB:",
            "Ljava/lang/Object;",
            ">(",
            "Ljava/lang/Object;",
            "ITUB;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzanu<",
            "TUT;TUB;>;",
            "Ljava/lang/Object;",
            ")TUB;"
        }
    .end annotation

    .line 1375
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v3, v0, p2

    .line 1377
    invoke-direct {p0, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(I)I

    move-result v0

    const v1, 0xfffff

    and-int/2addr v0, v1

    int-to-long v0, v0

    .line 1380
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object p1

    if-nez p1, :cond_0

    goto :goto_0

    .line 1383
    :cond_0
    invoke-direct {p0, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(I)Lcom/google/android/gms/internal/firebase-auth-api/zzalj;

    move-result-object v5

    if-nez v5, :cond_1

    :goto_0
    return-object p3

    .line 1386
    :cond_1
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    invoke-interface {v0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamf;->zze(Ljava/lang/Object;)Ljava/util/Map;

    move-result-object v4

    move-object v1, p0

    move v2, p2

    move-object v6, p3

    move-object v7, p4

    move-object v8, p5

    .line 1388
    invoke-direct/range {v1 .. v8}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(IILjava/util/Map;Lcom/google/android/gms/internal/firebase-auth-api/zzalj;Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanu;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method

.method private static zza(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/reflect/Field;
    .locals 6
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/Class<",
            "*>;",
            "Ljava/lang/String;",
            ")",
            "Ljava/lang/reflect/Field;"
        }
    .end annotation

    .line 1436
    :try_start_0
    invoke-virtual {p0, p1}, Ljava/lang/Class;->getDeclaredField(Ljava/lang/String;)Ljava/lang/reflect/Field;

    move-result-object p0
    :try_end_0
    .catch Ljava/lang/NoSuchFieldException; {:try_start_0 .. :try_end_0} :catch_0

    return-object p0

    :catch_0
    move-exception v0

    .line 1438
    invoke-virtual {p0}, Ljava/lang/Class;->getDeclaredFields()[Ljava/lang/reflect/Field;

    move-result-object v1

    .line 1439
    array-length v2, v1

    const/4 v3, 0x0

    :goto_0
    if-ge v3, v2, :cond_1

    aget-object v4, v1, v3

    .line 1440
    invoke-virtual {v4}, Ljava/lang/reflect/Field;->getName()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {p1, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v5

    if-eqz v5, :cond_0

    return-object v4

    :cond_0
    add-int/lit8 v3, v3, 0x1

    goto :goto_0

    .line 1443
    :cond_1
    new-instance v2, Ljava/lang/RuntimeException;

    .line 1444
    invoke-virtual {p0}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object p0

    .line 1445
    invoke-static {v1}, Ljava/util/Arrays;->toString([Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    new-instance v3, Ljava/lang/StringBuilder;

    const-string v4, "Field "

    invoke-direct {v3, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v3, " for "

    invoke-virtual {p1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    const-string p1, " not found. Known fields are "

    invoke-virtual {p0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {v2, p0, v0}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw v2
.end method

.method private static zza(ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 2164
    instance-of v0, p1, Ljava/lang/String;

    if-eqz v0, :cond_0

    .line 2165
    check-cast p1, Ljava/lang/String;

    invoke-interface {p2, p0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(ILjava/lang/String;)V

    return-void

    .line 2166
    :cond_0
    check-cast p1, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    invoke-interface {p2, p0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(ILcom/google/android/gms/internal/firebase-auth-api/zzajv;)V

    return-void
.end method

.method private static zza(Lcom/google/android/gms/internal/firebase-auth-api/zzanu;Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<UT:",
            "Ljava/lang/Object;",
            "UB:",
            "Ljava/lang/Object;",
            ">(",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzanu<",
            "TUT;TUB;>;TT;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzaol;",
            ")V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 2955
    invoke-virtual {p0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zzd(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    invoke-virtual {p0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zzb(Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;)V

    return-void
.end method

.method private final zza(Lcom/google/android/gms/internal/firebase-auth-api/zzaol;ILjava/lang/Object;I)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<K:",
            "Ljava/lang/Object;",
            "V:",
            "Ljava/lang/Object;",
            ">(",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzaol;",
            "I",
            "Ljava/lang/Object;",
            "I)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    if-eqz p3, :cond_0

    .line 2159
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    .line 2160
    invoke-direct {p0, p4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzf(I)Ljava/lang/Object;

    move-result-object p4

    invoke-interface {v0, p4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamf;->zza(Ljava/lang/Object;)Lcom/google/android/gms/internal/firebase-auth-api/zzamd;

    move-result-object p4

    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    .line 2161
    invoke-interface {v0, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamf;->zzd(Ljava/lang/Object;)Ljava/util/Map;

    move-result-object p3

    .line 2162
    invoke-interface {p1, p2, p4, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(ILcom/google/android/gms/internal/firebase-auth-api/zzamd;Ljava/util/Map;)V

    :cond_0
    return-void
.end method

.method private final zza(Ljava/lang/Object;IILjava/lang/Object;)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;II",
            "Ljava/lang/Object;",
            ")V"
        }
    .end annotation

    .line 2153
    sget-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb:Lsun/misc/Unsafe;

    invoke-direct {p0, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(I)I

    move-result v1

    const v2, 0xfffff

    and-int/2addr v1, v2

    int-to-long v1, v1

    .line 2155
    invoke-virtual {v0, p1, v1, v2, p4}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 2156
    invoke-direct {p0, p1, p2, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    return-void
.end method

.method private final zza(Ljava/lang/Object;ILcom/google/android/gms/internal/firebase-auth-api/zzanc;)V
    .locals 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 2124
    invoke-static {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzg(I)Z

    move-result v0

    const v1, 0xfffff

    if-eqz v0, :cond_0

    and-int/2addr p2, v1

    int-to-long v0, p2

    .line 2127
    invoke-interface {p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzr()Ljava/lang/String;

    move-result-object p2

    invoke-static {p1, v0, v1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    return-void

    .line 2128
    :cond_0
    iget-boolean v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzi:Z

    if-eqz v0, :cond_1

    and-int/2addr p2, v1

    int-to-long v0, p2

    .line 2131
    invoke-interface {p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzq()Ljava/lang/String;

    move-result-object p2

    invoke-static {p1, v0, v1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    return-void

    :cond_1
    and-int/2addr p2, v1

    int-to-long v0, p2

    .line 2134
    invoke-interface {p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzp()Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    move-result-object p2

    invoke-static {p1, v0, v1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    return-void
.end method

.method private final zza(Ljava/lang/Object;ILjava/lang/Object;)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;I",
            "Ljava/lang/Object;",
            ")V"
        }
    .end annotation

    .line 2148
    sget-object v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb:Lsun/misc/Unsafe;

    invoke-direct {p0, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(I)I

    move-result v1

    const v2, 0xfffff

    and-int/2addr v1, v2

    int-to-long v1, v1

    .line 2150
    invoke-virtual {v0, p1, v1, v2, p3}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 2151
    invoke-direct {p0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    return-void
.end method

.method private final zza(Ljava/lang/Object;Ljava/lang/Object;I)V
    .locals 5
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;TT;I)V"
        }
    .end annotation

    .line 2065
    invoke-direct {p0, p2, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v0

    if-nez v0, :cond_0

    return-void

    .line 2067
    :cond_0
    invoke-direct {p0, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(I)I

    move-result v0

    const v1, 0xfffff

    and-int/2addr v0, v1

    int-to-long v0, v0

    .line 2070
    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb:Lsun/misc/Unsafe;

    invoke-virtual {v2, p2, v0, v1}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v3

    if-eqz v3, :cond_4

    .line 2076
    invoke-direct {p0, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object p2

    .line 2077
    invoke-direct {p0, p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v4

    if-nez v4, :cond_2

    .line 2078
    invoke-static {v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzg(Ljava/lang/Object;)Z

    move-result v4

    if-nez v4, :cond_1

    .line 2079
    invoke-virtual {v2, p1, v0, v1, v3}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    goto :goto_0

    .line 2080
    :cond_1
    invoke-interface {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zza()Ljava/lang/Object;

    move-result-object v4

    .line 2081
    invoke-interface {p2, v4, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zza(Ljava/lang/Object;Ljava/lang/Object;)V

    .line 2082
    invoke-virtual {v2, p1, v0, v1, v4}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 2083
    :goto_0
    invoke-direct {p0, p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    return-void

    .line 2085
    :cond_2
    invoke-virtual {v2, p1, v0, v1}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object p3

    .line 2086
    invoke-static {p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzg(Ljava/lang/Object;)Z

    move-result v4

    if-nez v4, :cond_3

    .line 2087
    invoke-interface {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zza()Ljava/lang/Object;

    move-result-object v4

    .line 2088
    invoke-interface {p2, v4, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zza(Ljava/lang/Object;Ljava/lang/Object;)V

    .line 2089
    invoke-virtual {v2, p1, v0, v1, v4}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    move-object p3, v4

    .line 2091
    :cond_3
    invoke-interface {p2, p3, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zza(Ljava/lang/Object;Ljava/lang/Object;)V

    return-void

    .line 2072
    :cond_4
    new-instance p1, Ljava/lang/IllegalStateException;

    .line 2074
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget p3, v0, p3

    .line 2075
    invoke-static {p2}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p2

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "Source subfield "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p3

    const-string v0, " is present but null: "

    invoke-virtual {p3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p3

    invoke-virtual {p3, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p2

    invoke-direct {p1, p2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method private final zza(Ljava/lang/Object;IIII)Z
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;IIII)Z"
        }
    .end annotation

    const v0, 0xfffff

    if-ne p3, v0, :cond_0

    .line 3093
    invoke-direct {p0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result p1

    return p1

    :cond_0
    and-int p1, p4, p5

    if-eqz p1, :cond_1

    const/4 p1, 0x1

    return p1

    :cond_1
    const/4 p1, 0x0

    return p1
.end method

.method private static zza(Ljava/lang/Object;ILcom/google/android/gms/internal/firebase-auth-api/zzanb;)Z
    .locals 2

    const v0, 0xfffff

    and-int/2addr p1, v0

    int-to-long v0, p1

    .line 3163
    invoke-static {p0, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object p0

    .line 3164
    invoke-interface {p2, p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zze(Ljava/lang/Object;)Z

    move-result p0

    return p0
.end method

.method private static zzb(Ljava/lang/Object;J)F
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<T:",
            "Ljava/lang/Object;",
            ">(TT;J)F"
        }
    .end annotation

    .line 2
    invoke-static {p0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Float;

    invoke-virtual {p0}, Ljava/lang/Float;->floatValue()F

    move-result p0

    return p0
.end method

.method private final zzb(I)I
    .locals 1

    .line 1125
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    add-int/lit8 p1, p1, 0x2

    aget p1, v0, p1

    return p1
.end method

.method private final zzb(Ljava/lang/Object;I)V
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;I)V"
        }
    .end annotation

    .line 2136
    invoke-direct {p0, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(I)I

    move-result p2

    const v0, 0xfffff

    and-int/2addr v0, p2

    int-to-long v0, v0

    const-wide/32 v2, 0xfffff

    cmp-long v2, v0, v2

    if-nez v2, :cond_0

    return-void

    :cond_0
    ushr-int/lit8 p2, p2, 0x14

    const/4 v2, 0x1

    shl-int p2, v2, p2

    .line 2142
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v2

    or-int/2addr p2, v2

    .line 2143
    invoke-static {p1, v0, v1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JI)V

    return-void
.end method

.method private final zzb(Ljava/lang/Object;II)V
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;II)V"
        }
    .end annotation

    .line 2145
    invoke-direct {p0, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(I)I

    move-result p3

    const v0, 0xfffff

    and-int/2addr p3, v0

    int-to-long v0, p3

    .line 2146
    invoke-static {p1, v0, v1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JI)V

    return-void
.end method

.method private final zzb(Ljava/lang/Object;Ljava/lang/Object;I)V
    .locals 6
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;TT;I)V"
        }
    .end annotation

    .line 2094
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v0, v0, p3

    .line 2096
    invoke-direct {p0, p2, v0, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v1

    if-nez v1, :cond_0

    return-void

    .line 2098
    :cond_0
    invoke-direct {p0, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(I)I

    move-result v1

    const v2, 0xfffff

    and-int/2addr v1, v2

    int-to-long v1, v1

    .line 2101
    sget-object v3, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb:Lsun/misc/Unsafe;

    invoke-virtual {v3, p2, v1, v2}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v4

    if-eqz v4, :cond_4

    .line 2107
    invoke-direct {p0, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object p2

    .line 2108
    invoke-direct {p0, p1, v0, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-nez v5, :cond_2

    .line 2109
    invoke-static {v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzg(Ljava/lang/Object;)Z

    move-result v5

    if-nez v5, :cond_1

    .line 2110
    invoke-virtual {v3, p1, v1, v2, v4}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    goto :goto_0

    .line 2111
    :cond_1
    invoke-interface {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zza()Ljava/lang/Object;

    move-result-object v5

    .line 2112
    invoke-interface {p2, v5, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zza(Ljava/lang/Object;Ljava/lang/Object;)V

    .line 2113
    invoke-virtual {v3, p1, v1, v2, v5}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 2114
    :goto_0
    invoke-direct {p0, p1, v0, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    return-void

    .line 2116
    :cond_2
    invoke-virtual {v3, p1, v1, v2}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object p3

    .line 2117
    invoke-static {p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzg(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_3

    .line 2118
    invoke-interface {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zza()Ljava/lang/Object;

    move-result-object v0

    .line 2119
    invoke-interface {p2, v0, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zza(Ljava/lang/Object;Ljava/lang/Object;)V

    .line 2120
    invoke-virtual {v3, p1, v1, v2, v0}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    move-object p3, v0

    .line 2122
    :cond_3
    invoke-interface {p2, p3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zza(Ljava/lang/Object;Ljava/lang/Object;)V

    return-void

    .line 2103
    :cond_4
    new-instance p1, Ljava/lang/IllegalStateException;

    .line 2105
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget p3, v0, p3

    .line 2106
    invoke-static {p2}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p2

    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "Source subfield "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p3

    const-string v0, " is present but null: "

    invoke-virtual {p3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p3

    invoke-virtual {p3, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p2

    invoke-direct {p1, p2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method private final zzc(I)I
    .locals 1

    .line 1140
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    add-int/lit8 p1, p1, 0x1

    aget p1, v0, p1

    return p1
.end method

.method private static zzc(Ljava/lang/Object;J)I
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<T:",
            "Ljava/lang/Object;",
            ">(TT;J)I"
        }
    .end annotation

    .line 467
    invoke-static {p0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Integer;

    invoke-virtual {p0}, Ljava/lang/Integer;->intValue()I

    move-result p0

    return p0
.end method

.method static zzc(Ljava/lang/Object;)Lcom/google/android/gms/internal/firebase-auth-api/zzanx;
    .locals 2

    .line 1369
    check-cast p0, Lcom/google/android/gms/internal/firebase-auth-api/zzalf;

    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzalf;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzanx;

    .line 1370
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzanx;->zzc()Lcom/google/android/gms/internal/firebase-auth-api/zzanx;

    move-result-object v1

    if-ne v0, v1, :cond_0

    .line 1371
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzanx;->zzd()Lcom/google/android/gms/internal/firebase-auth-api/zzanx;

    move-result-object v0

    .line 1372
    iput-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzalf;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzanx;

    :cond_0
    return-object v0
.end method

.method private final zzc(Ljava/lang/Object;I)Z
    .locals 7
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;I)Z"
        }
    .end annotation

    .line 3056
    invoke-direct {p0, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(I)I

    move-result v0

    const v1, 0xfffff

    and-int v2, v0, v1

    int-to-long v2, v2

    const-wide/32 v4, 0xfffff

    cmp-long v4, v2, v4

    const/4 v5, 0x0

    const/4 v6, 0x1

    if-nez v4, :cond_14

    .line 3059
    invoke-direct {p0, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(I)I

    move-result p2

    and-int v0, p2, v1

    int-to-long v0, v0

    const/high16 v2, 0xff00000

    and-int/2addr p2, v2

    ushr-int/lit8 p2, p2, 0x14

    const-wide/16 v2, 0x0

    packed-switch p2, :pswitch_data_0

    .line 3089
    new-instance p1, Ljava/lang/IllegalArgumentException;

    invoke-direct {p1}, Ljava/lang/IllegalArgumentException;-><init>()V

    throw p1

    .line 3088
    :pswitch_0
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object p1

    if-eqz p1, :cond_0

    return v6

    :cond_0
    return v5

    .line 3087
    :pswitch_1
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide p1

    cmp-long p1, p1, v2

    if-eqz p1, :cond_1

    return v6

    :cond_1
    return v5

    .line 3086
    :pswitch_2
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result p1

    if-eqz p1, :cond_2

    return v6

    :cond_2
    return v5

    .line 3085
    :pswitch_3
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide p1

    cmp-long p1, p1, v2

    if-eqz p1, :cond_3

    return v6

    :cond_3
    return v5

    .line 3084
    :pswitch_4
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result p1

    if-eqz p1, :cond_4

    return v6

    :cond_4
    return v5

    .line 3083
    :pswitch_5
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result p1

    if-eqz p1, :cond_5

    return v6

    :cond_5
    return v5

    .line 3082
    :pswitch_6
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result p1

    if-eqz p1, :cond_6

    return v6

    :cond_6
    return v5

    .line 3081
    :pswitch_7
    sget-object p2, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object p1

    invoke-virtual {p2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-nez p1, :cond_7

    return v6

    :cond_7
    return v5

    .line 3080
    :pswitch_8
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object p1

    if-eqz p1, :cond_8

    return v6

    :cond_8
    return v5

    .line 3074
    :pswitch_9
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object p1

    .line 3075
    instance-of p2, p1, Ljava/lang/String;

    if-eqz p2, :cond_a

    .line 3076
    check-cast p1, Ljava/lang/String;

    invoke-virtual {p1}, Ljava/lang/String;->isEmpty()Z

    move-result p1

    if-nez p1, :cond_9

    return v6

    :cond_9
    return v5

    .line 3077
    :cond_a
    instance-of p2, p1, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    if-eqz p2, :cond_c

    .line 3078
    sget-object p2, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    invoke-virtual {p2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-nez p1, :cond_b

    return v6

    :cond_b
    return v5

    .line 3079
    :cond_c
    new-instance p1, Ljava/lang/IllegalArgumentException;

    invoke-direct {p1}, Ljava/lang/IllegalArgumentException;-><init>()V

    throw p1

    .line 3073
    :pswitch_a
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzh(Ljava/lang/Object;J)Z

    move-result p1

    return p1

    .line 3072
    :pswitch_b
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result p1

    if-eqz p1, :cond_d

    return v6

    :cond_d
    return v5

    .line 3071
    :pswitch_c
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide p1

    cmp-long p1, p1, v2

    if-eqz p1, :cond_e

    return v6

    :cond_e
    return v5

    .line 3070
    :pswitch_d
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result p1

    if-eqz p1, :cond_f

    return v6

    :cond_f
    return v5

    .line 3069
    :pswitch_e
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide p1

    cmp-long p1, p1, v2

    if-eqz p1, :cond_10

    return v6

    :cond_10
    return v5

    .line 3068
    :pswitch_f
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide p1

    cmp-long p1, p1, v2

    if-eqz p1, :cond_11

    return v6

    :cond_11
    return v5

    .line 3067
    :pswitch_10
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzb(Ljava/lang/Object;J)F

    move-result p1

    invoke-static {p1}, Ljava/lang/Float;->floatToRawIntBits(F)I

    move-result p1

    if-eqz p1, :cond_12

    return v6

    :cond_12
    return v5

    .line 3066
    :pswitch_11
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;J)D

    move-result-wide p1

    invoke-static {p1, p2}, Ljava/lang/Double;->doubleToRawLongBits(D)J

    move-result-wide p1

    cmp-long p1, p1, v2

    if-eqz p1, :cond_13

    return v6

    :cond_13
    return v5

    :cond_14
    ushr-int/lit8 p2, v0, 0x14

    shl-int p2, v6, p2

    .line 3091
    invoke-static {p1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result p1

    and-int/2addr p1, p2

    if-eqz p1, :cond_15

    return v6

    :cond_15
    return v5

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_11
        :pswitch_10
        :pswitch_f
        :pswitch_e
        :pswitch_d
        :pswitch_c
        :pswitch_b
        :pswitch_a
        :pswitch_9
        :pswitch_8
        :pswitch_7
        :pswitch_6
        :pswitch_5
        :pswitch_4
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method private final zzc(Ljava/lang/Object;II)Z
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;II)Z"
        }
    .end annotation

    .line 3170
    invoke-direct {p0, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(I)I

    move-result p3

    const v0, 0xfffff

    and-int/2addr p3, v0

    int-to-long v0, p3

    .line 3171
    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result p1

    if-ne p1, p2, :cond_0

    const/4 p1, 0x1

    return p1

    :cond_0
    const/4 p1, 0x0

    return p1
.end method

.method private final zzc(Ljava/lang/Object;Ljava/lang/Object;I)Z
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;TT;I)Z"
        }
    .end annotation

    .line 2957
    invoke-direct {p0, p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result p1

    invoke-direct {p0, p2, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result p2

    if-ne p1, p2, :cond_0

    const/4 p1, 0x1

    return p1

    :cond_0
    const/4 p1, 0x0

    return p1
.end method

.method private static zzd(Ljava/lang/Object;J)J
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<T:",
            "Ljava/lang/Object;",
            ">(TT;J)J"
        }
    .end annotation

    .line 1141
    invoke-static {p0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Long;

    invoke-virtual {p0}, Ljava/lang/Long;->longValue()J

    move-result-wide p0

    return-wide p0
.end method

.method private final zzd(I)Lcom/google/android/gms/internal/firebase-auth-api/zzalj;
    .locals 1

    .line 1142
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd:[Ljava/lang/Object;

    div-int/lit8 p1, p1, 0x3

    shl-int/lit8 p1, p1, 0x1

    add-int/lit8 p1, p1, 0x1

    aget-object p1, v0, p1

    check-cast p1, Lcom/google/android/gms/internal/firebase-auth-api/zzalj;

    return-object p1
.end method

.method private final zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;
    .locals 3

    .line 1362
    div-int/lit8 p1, p1, 0x3

    shl-int/lit8 p1, p1, 0x1

    .line 1363
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd:[Ljava/lang/Object;

    aget-object v0, v0, p1

    check-cast v0, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    if-eqz v0, :cond_0

    return-object v0

    .line 1366
    :cond_0
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzamx;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzamx;

    move-result-object v0

    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd:[Ljava/lang/Object;

    add-int/lit8 v2, p1, 0x1

    aget-object v1, v1, v2

    check-cast v1, Ljava/lang/Class;

    invoke-virtual {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamx;->zza(Ljava/lang/Class;)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v0

    .line 1367
    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd:[Ljava/lang/Object;

    aput-object v0, v1, p1

    return-object v0
.end method

.method private static zze(Ljava/lang/Object;J)Z
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<T:",
            "Ljava/lang/Object;",
            ">(TT;J)Z"
        }
    .end annotation

    .line 3172
    invoke-static {p0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/Boolean;

    invoke-virtual {p0}, Ljava/lang/Boolean;->booleanValue()Z

    move-result p0

    return p0
.end method

.method private final zzf(I)Ljava/lang/Object;
    .locals 1

    .line 1409
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd:[Ljava/lang/Object;

    div-int/lit8 p1, p1, 0x3

    shl-int/lit8 p1, p1, 0x1

    aget-object p1, v0, p1

    return-object p1
.end method

.method private static zzf(Ljava/lang/Object;)V
    .locals 3

    .line 1466
    invoke-static {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzg(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    return-void

    .line 1467
    :cond_0
    new-instance v0, Ljava/lang/IllegalArgumentException;

    invoke-static {p0}, Ljava/lang/String;->valueOf(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p0

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "Mutating immutable message: "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-direct {v0, p0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method private static zzg(I)Z
    .locals 1

    const/high16 v0, 0x20000000

    and-int/2addr p0, v0

    if-eqz p0, :cond_0

    const/4 p0, 0x1

    return p0

    :cond_0
    const/4 p0, 0x0

    return p0
.end method

.method private static zzg(Ljava/lang/Object;)Z
    .locals 1

    if-nez p0, :cond_0

    const/4 p0, 0x0

    return p0

    .line 3167
    :cond_0
    instance-of v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzalf;

    if-eqz v0, :cond_1

    .line 3168
    check-cast p0, Lcom/google/android/gms/internal/firebase-auth-api/zzalf;

    invoke-virtual {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzalf;->zzw()Z

    move-result p0

    return p0

    :cond_1
    const/4 p0, 0x1

    return p0
.end method


# virtual methods
.method public final zza(Ljava/lang/Object;)I
    .locals 17
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;)I"
        }
    .end annotation

    move-object/from16 v0, p0

    move-object/from16 v1, p1

    .line 41
    sget-object v6, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb:Lsun/misc/Unsafe;

    const/4 v7, 0x0

    const v8, 0xfffff

    move v2, v7

    move v4, v2

    move v9, v4

    move v3, v8

    .line 44
    :goto_0
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    array-length v5, v5

    if-ge v2, v5, :cond_9

    .line 45
    invoke-direct {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(I)I

    move-result v5

    const/high16 v10, 0xff00000

    and-int/2addr v10, v5

    ushr-int/lit8 v10, v10, 0x14

    .line 50
    iget-object v11, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v11, v2

    add-int/lit8 v13, v2, 0x2

    .line 53
    aget v11, v11, v13

    and-int v13, v11, v8

    const/16 v14, 0x11

    const/4 v15, 0x1

    if-gt v10, v14, :cond_2

    if-eq v13, v3, :cond_1

    if-ne v13, v8, :cond_0

    move v3, v7

    goto :goto_1

    :cond_0
    int-to-long v3, v13

    .line 60
    invoke-virtual {v6, v1, v3, v4}, Lsun/misc/Unsafe;->getInt(Ljava/lang/Object;J)I

    move-result v3

    :goto_1
    move v4, v3

    move v3, v13

    :cond_1
    ushr-int/lit8 v11, v11, 0x14

    shl-int v11, v15, v11

    goto :goto_2

    :cond_2
    move v11, v7

    :goto_2
    and-int/2addr v5, v8

    int-to-long v13, v5

    .line 65
    sget-object v5, Lcom/google/android/gms/internal/firebase-auth-api/zzalc;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzalc;

    .line 66
    invoke-virtual {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzalc;->zza()I

    move-result v5

    if-lt v10, v5, :cond_3

    sget-object v5, Lcom/google/android/gms/internal/firebase-auth-api/zzalc;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzalc;

    .line 67
    invoke-virtual {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzalc;->zza()I

    move-result v5

    :cond_3
    const/4 v5, 0x0

    move/from16 v16, v9

    const-wide/16 v8, 0x0

    packed-switch v10, :pswitch_data_0

    goto/16 :goto_7

    .line 334
    :pswitch_0
    invoke-direct {v0, v1, v12, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_8

    .line 336
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Lcom/google/android/gms/internal/firebase-auth-api/zzamm;

    .line 337
    invoke-direct {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v8

    .line 338
    invoke-static {v12, v5, v8}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(ILcom/google/android/gms/internal/firebase-auth-api/zzamm;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)I

    move-result v5

    goto/16 :goto_4

    .line 332
    :pswitch_1
    invoke-direct {v0, v1, v12, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_8

    .line 333
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(Ljava/lang/Object;J)J

    move-result-wide v8

    invoke-static {v12, v8, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzd(IJ)I

    move-result v5

    goto/16 :goto_4

    .line 330
    :pswitch_2
    invoke-direct {v0, v1, v12, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_8

    .line 331
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v5

    invoke-static {v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zze(II)I

    move-result v5

    goto/16 :goto_4

    .line 328
    :pswitch_3
    invoke-direct {v0, v1, v12, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_8

    .line 329
    invoke-static {v12, v8, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzc(IJ)I

    move-result v5

    goto/16 :goto_4

    .line 326
    :pswitch_4
    invoke-direct {v0, v1, v12, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_8

    .line 327
    invoke-static {v12, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzd(II)I

    move-result v5

    goto/16 :goto_4

    .line 324
    :pswitch_5
    invoke-direct {v0, v1, v12, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_8

    .line 325
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v5

    invoke-static {v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(II)I

    move-result v5

    goto/16 :goto_4

    .line 322
    :pswitch_6
    invoke-direct {v0, v1, v12, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_8

    .line 323
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v5

    invoke-static {v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzf(II)I

    move-result v5

    goto/16 :goto_4

    .line 318
    :pswitch_7
    invoke-direct {v0, v1, v12, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_8

    .line 320
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    .line 321
    invoke-static {v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(ILcom/google/android/gms/internal/firebase-auth-api/zzajv;)I

    move-result v5

    goto/16 :goto_4

    .line 314
    :pswitch_8
    invoke-direct {v0, v1, v12, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_8

    .line 315
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    .line 316
    invoke-direct {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v8

    invoke-static {v12, v5, v8}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)I

    move-result v5

    goto/16 :goto_4

    .line 308
    :pswitch_9
    invoke-direct {v0, v1, v12, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_8

    .line 309
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    .line 310
    instance-of v8, v5, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    if-eqz v8, :cond_4

    .line 311
    check-cast v5, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    invoke-static {v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(ILcom/google/android/gms/internal/firebase-auth-api/zzajv;)I

    move-result v5

    goto/16 :goto_4

    .line 312
    :cond_4
    check-cast v5, Ljava/lang/String;

    invoke-static {v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(ILjava/lang/String;)I

    move-result v5

    goto/16 :goto_4

    .line 306
    :pswitch_a
    invoke-direct {v0, v1, v12, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_8

    .line 307
    invoke-static {v12, v15}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(IZ)I

    move-result v5

    goto/16 :goto_4

    .line 304
    :pswitch_b
    invoke-direct {v0, v1, v12, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_8

    .line 305
    invoke-static {v12, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(II)I

    move-result v5

    goto/16 :goto_4

    .line 302
    :pswitch_c
    invoke-direct {v0, v1, v12, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_8

    .line 303
    invoke-static {v12, v8, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(IJ)I

    move-result v5

    goto/16 :goto_4

    .line 300
    :pswitch_d
    invoke-direct {v0, v1, v12, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_8

    .line 301
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v5

    invoke-static {v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzc(II)I

    move-result v5

    goto/16 :goto_4

    .line 298
    :pswitch_e
    invoke-direct {v0, v1, v12, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_8

    .line 299
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(Ljava/lang/Object;J)J

    move-result-wide v8

    invoke-static {v12, v8, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zze(IJ)I

    move-result v5

    goto/16 :goto_4

    .line 296
    :pswitch_f
    invoke-direct {v0, v1, v12, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_8

    .line 297
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(Ljava/lang/Object;J)J

    move-result-wide v8

    invoke-static {v12, v8, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(IJ)I

    move-result v5

    goto/16 :goto_4

    .line 294
    :pswitch_10
    invoke-direct {v0, v1, v12, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v8

    if-eqz v8, :cond_8

    .line 295
    invoke-static {v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(IF)I

    move-result v5

    goto/16 :goto_4

    .line 292
    :pswitch_11
    invoke-direct {v0, v1, v12, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_8

    const-wide/16 v8, 0x0

    .line 293
    invoke-static {v12, v8, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(ID)I

    move-result v5

    goto/16 :goto_4

    .line 288
    :pswitch_12
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    .line 289
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    invoke-direct {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzf(I)Ljava/lang/Object;

    move-result-object v9

    .line 290
    invoke-interface {v5, v12, v8, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzamf;->zza(ILjava/lang/Object;Ljava/lang/Object;)I

    move-result v5

    goto/16 :goto_4

    .line 284
    :pswitch_13
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 285
    invoke-direct {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v8

    .line 286
    invoke-static {v12, v5, v8}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)I

    move-result v5

    goto/16 :goto_4

    .line 277
    :pswitch_14
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 278
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzh(Ljava/util/List;)I

    move-result v5

    if-lez v5, :cond_8

    .line 281
    invoke-static {v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(I)I

    move-result v8

    .line 282
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzi(I)I

    move-result v9

    goto/16 :goto_3

    .line 270
    :pswitch_15
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 271
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzg(Ljava/util/List;)I

    move-result v5

    if-lez v5, :cond_8

    .line 274
    invoke-static {v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(I)I

    move-result v8

    .line 275
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzi(I)I

    move-result v9

    goto/16 :goto_3

    .line 263
    :pswitch_16
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 264
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzd(Ljava/util/List;)I

    move-result v5

    if-lez v5, :cond_8

    .line 267
    invoke-static {v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(I)I

    move-result v8

    .line 268
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzi(I)I

    move-result v9

    goto/16 :goto_3

    .line 256
    :pswitch_17
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 257
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzc(Ljava/util/List;)I

    move-result v5

    if-lez v5, :cond_8

    .line 260
    invoke-static {v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(I)I

    move-result v8

    .line 261
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzi(I)I

    move-result v9

    goto/16 :goto_3

    .line 249
    :pswitch_18
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 250
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzb(Ljava/util/List;)I

    move-result v5

    if-lez v5, :cond_8

    .line 253
    invoke-static {v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(I)I

    move-result v8

    .line 254
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzi(I)I

    move-result v9

    goto/16 :goto_3

    .line 242
    :pswitch_19
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 243
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzi(Ljava/util/List;)I

    move-result v5

    if-lez v5, :cond_8

    .line 246
    invoke-static {v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(I)I

    move-result v8

    .line 247
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzi(I)I

    move-result v9

    goto/16 :goto_3

    .line 235
    :pswitch_1a
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 236
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(Ljava/util/List;)I

    move-result v5

    if-lez v5, :cond_8

    .line 239
    invoke-static {v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(I)I

    move-result v8

    .line 240
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzi(I)I

    move-result v9

    goto/16 :goto_3

    .line 228
    :pswitch_1b
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 229
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzc(Ljava/util/List;)I

    move-result v5

    if-lez v5, :cond_8

    .line 232
    invoke-static {v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(I)I

    move-result v8

    .line 233
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzi(I)I

    move-result v9

    goto/16 :goto_3

    .line 221
    :pswitch_1c
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 222
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzd(Ljava/util/List;)I

    move-result v5

    if-lez v5, :cond_8

    .line 225
    invoke-static {v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(I)I

    move-result v8

    .line 226
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzi(I)I

    move-result v9

    goto :goto_3

    .line 214
    :pswitch_1d
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 215
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zze(Ljava/util/List;)I

    move-result v5

    if-lez v5, :cond_8

    .line 218
    invoke-static {v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(I)I

    move-result v8

    .line 219
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzi(I)I

    move-result v9

    goto :goto_3

    .line 207
    :pswitch_1e
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 208
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzj(Ljava/util/List;)I

    move-result v5

    if-lez v5, :cond_8

    .line 211
    invoke-static {v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(I)I

    move-result v8

    .line 212
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzi(I)I

    move-result v9

    goto :goto_3

    .line 200
    :pswitch_1f
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 201
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzf(Ljava/util/List;)I

    move-result v5

    if-lez v5, :cond_8

    .line 204
    invoke-static {v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(I)I

    move-result v8

    .line 205
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzi(I)I

    move-result v9

    goto :goto_3

    .line 193
    :pswitch_20
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 194
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzc(Ljava/util/List;)I

    move-result v5

    if-lez v5, :cond_8

    .line 197
    invoke-static {v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(I)I

    move-result v8

    .line 198
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzi(I)I

    move-result v9

    goto :goto_3

    .line 186
    :pswitch_21
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 187
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzd(Ljava/util/List;)I

    move-result v5

    if-lez v5, :cond_8

    .line 190
    invoke-static {v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(I)I

    move-result v8

    .line 191
    invoke-static {v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzi(I)I

    move-result v9

    :goto_3
    add-int/2addr v8, v9

    add-int/2addr v8, v5

    add-int v9, v16, v8

    goto/16 :goto_8

    .line 182
    :pswitch_22
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 183
    invoke-static {v12, v5, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzh(ILjava/util/List;Z)I

    move-result v5

    goto/16 :goto_4

    .line 178
    :pswitch_23
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 179
    invoke-static {v12, v5, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzg(ILjava/util/List;Z)I

    move-result v5

    goto/16 :goto_4

    .line 174
    :pswitch_24
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 175
    invoke-static {v12, v5, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzd(ILjava/util/List;Z)I

    move-result v5

    goto/16 :goto_4

    .line 170
    :pswitch_25
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 171
    invoke-static {v12, v5, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzc(ILjava/util/List;Z)I

    move-result v5

    goto/16 :goto_4

    .line 166
    :pswitch_26
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 167
    invoke-static {v12, v5, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzb(ILjava/util/List;Z)I

    move-result v5

    goto/16 :goto_4

    .line 162
    :pswitch_27
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 163
    invoke-static {v12, v5, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzi(ILjava/util/List;Z)I

    move-result v5

    goto/16 :goto_4

    .line 158
    :pswitch_28
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 159
    invoke-static {v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(ILjava/util/List;)I

    move-result v5

    goto/16 :goto_4

    .line 154
    :pswitch_29
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    invoke-direct {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v8

    .line 155
    invoke-static {v12, v5, v8}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzb(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)I

    move-result v5

    goto :goto_4

    .line 151
    :pswitch_2a
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    invoke-static {v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzb(ILjava/util/List;)I

    move-result v5

    goto :goto_4

    .line 147
    :pswitch_2b
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 148
    invoke-static {v12, v5, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(ILjava/util/List;Z)I

    move-result v5

    goto :goto_4

    .line 143
    :pswitch_2c
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 144
    invoke-static {v12, v5, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzc(ILjava/util/List;Z)I

    move-result v5

    goto :goto_4

    .line 139
    :pswitch_2d
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 140
    invoke-static {v12, v5, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzd(ILjava/util/List;Z)I

    move-result v5

    goto :goto_4

    .line 135
    :pswitch_2e
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 136
    invoke-static {v12, v5, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zze(ILjava/util/List;Z)I

    move-result v5

    goto :goto_4

    .line 131
    :pswitch_2f
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 132
    invoke-static {v12, v5, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzj(ILjava/util/List;Z)I

    move-result v5

    goto :goto_4

    .line 127
    :pswitch_30
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 128
    invoke-static {v12, v5, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzf(ILjava/util/List;Z)I

    move-result v5

    goto :goto_4

    .line 123
    :pswitch_31
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 124
    invoke-static {v12, v5, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzc(ILjava/util/List;Z)I

    move-result v5

    goto :goto_4

    .line 119
    :pswitch_32
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 120
    invoke-static {v12, v5, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzd(ILjava/util/List;Z)I

    move-result v5

    :goto_4
    add-int v9, v16, v5

    goto/16 :goto_8

    :pswitch_33
    move v5, v11

    .line 113
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_8

    .line 115
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Lcom/google/android/gms/internal/firebase-auth-api/zzamm;

    .line 116
    invoke-direct {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v8

    .line 117
    invoke-static {v12, v5, v8}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(ILcom/google/android/gms/internal/firebase-auth-api/zzamm;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)I

    move-result v5

    goto :goto_4

    :pswitch_34
    move v5, v11

    .line 111
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_6

    .line 112
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getLong(Ljava/lang/Object;J)J

    move-result-wide v8

    invoke-static {v12, v8, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzd(IJ)I

    move-result v0

    goto/16 :goto_5

    :pswitch_35
    move v5, v11

    .line 109
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_6

    .line 110
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getInt(Ljava/lang/Object;J)I

    move-result v0

    invoke-static {v12, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zze(II)I

    move-result v0

    goto/16 :goto_5

    :pswitch_36
    move v5, v11

    .line 107
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_7

    .line 108
    invoke-static {v12, v8, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzc(IJ)I

    move-result v0

    goto/16 :goto_6

    :pswitch_37
    move v5, v11

    .line 105
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_7

    .line 106
    invoke-static {v12, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzd(II)I

    move-result v0

    goto/16 :goto_6

    :pswitch_38
    move v5, v11

    .line 103
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_6

    .line 104
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getInt(Ljava/lang/Object;J)I

    move-result v0

    invoke-static {v12, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(II)I

    move-result v0

    goto/16 :goto_5

    :pswitch_39
    move v5, v11

    .line 101
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_6

    .line 102
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getInt(Ljava/lang/Object;J)I

    move-result v0

    invoke-static {v12, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzf(II)I

    move-result v0

    goto/16 :goto_5

    :pswitch_3a
    move v5, v11

    .line 97
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_6

    .line 98
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    .line 99
    invoke-static {v12, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(ILcom/google/android/gms/internal/firebase-auth-api/zzajv;)I

    move-result v0

    goto/16 :goto_5

    :pswitch_3b
    move v5, v11

    .line 93
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_8

    .line 94
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    .line 95
    invoke-direct {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v8

    invoke-static {v12, v5, v8}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)I

    move-result v5

    goto/16 :goto_4

    :pswitch_3c
    move v5, v11

    .line 87
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_6

    .line 88
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v0

    .line 89
    instance-of v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    if-eqz v5, :cond_5

    .line 90
    check-cast v0, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    invoke-static {v12, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(ILcom/google/android/gms/internal/firebase-auth-api/zzajv;)I

    move-result v0

    goto :goto_5

    .line 91
    :cond_5
    check-cast v0, Ljava/lang/String;

    invoke-static {v12, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(ILjava/lang/String;)I

    move-result v0

    goto :goto_5

    :pswitch_3d
    move v5, v11

    .line 85
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_7

    .line 86
    invoke-static {v12, v15}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(IZ)I

    move-result v0

    goto/16 :goto_6

    :pswitch_3e
    move v5, v11

    .line 83
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_7

    .line 84
    invoke-static {v12, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(II)I

    move-result v0

    goto :goto_6

    :pswitch_3f
    move v5, v11

    .line 81
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_7

    .line 82
    invoke-static {v12, v8, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(IJ)I

    move-result v0

    goto :goto_6

    :pswitch_40
    move v5, v11

    .line 79
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_6

    .line 80
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getInt(Ljava/lang/Object;J)I

    move-result v0

    invoke-static {v12, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzc(II)I

    move-result v0

    goto :goto_5

    :pswitch_41
    move v5, v11

    .line 77
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_6

    .line 78
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getLong(Ljava/lang/Object;J)J

    move-result-wide v8

    invoke-static {v12, v8, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zze(IJ)I

    move-result v0

    goto :goto_5

    :pswitch_42
    move v5, v11

    .line 75
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_6

    .line 76
    invoke-virtual {v6, v1, v13, v14}, Lsun/misc/Unsafe;->getLong(Ljava/lang/Object;J)J

    move-result-wide v8

    invoke-static {v12, v8, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(IJ)I

    move-result v0

    :goto_5
    add-int v9, v16, v0

    move-object/from16 v0, p0

    goto :goto_8

    :cond_6
    move-object/from16 v0, p0

    goto :goto_7

    :pswitch_43
    move v8, v5

    move v5, v11

    .line 73
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_7

    .line 74
    invoke-static {v12, v8}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(IF)I

    move-result v0

    :goto_6
    add-int v9, v16, v0

    move-object/from16 v0, p0

    move-object/from16 v1, p1

    goto :goto_8

    :cond_7
    move-object/from16 v0, p0

    move-object/from16 v1, p1

    goto :goto_7

    :pswitch_44
    move v5, v11

    .line 71
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_8

    const-wide/16 v8, 0x0

    .line 72
    invoke-static {v12, v8, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(ID)I

    move-result v5

    goto/16 :goto_4

    :cond_8
    :goto_7
    move/from16 v9, v16

    :goto_8
    add-int/lit8 v2, v2, 0x3

    const v8, 0xfffff

    goto/16 :goto_0

    :cond_9
    move/from16 v16, v9

    .line 340
    iget-object v2, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzp:Lcom/google/android/gms/internal/firebase-auth-api/zzanu;

    .line 341
    invoke-virtual {v2, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zzd(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    .line 342
    invoke-virtual {v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zza(Ljava/lang/Object;)I

    move-result v2

    add-int v9, v16, v2

    .line 344
    iget-boolean v2, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzh:Z

    if-eqz v2, :cond_c

    .line 345
    iget-object v2, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzq:Lcom/google/android/gms/internal/firebase-auth-api/zzakw;

    invoke-virtual {v2, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakw;->zza(Ljava/lang/Object;)Lcom/google/android/gms/internal/firebase-auth-api/zzakx;

    move-result-object v1

    .line 347
    iget-object v2, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzakx;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzang;

    invoke-virtual {v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzang;->zzb()I

    move-result v2

    move v3, v7

    :goto_9
    if-ge v7, v2, :cond_a

    .line 349
    iget-object v4, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzakx;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzang;

    invoke-virtual {v4, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzang;->zza(I)Ljava/util/Map$Entry;

    move-result-object v4

    .line 350
    invoke-interface {v4}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Lcom/google/android/gms/internal/firebase-auth-api/zzakz;

    invoke-interface {v4}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v4

    invoke-static {v5, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzakx;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzakz;Ljava/lang/Object;)I

    move-result v4

    add-int/2addr v3, v4

    add-int/lit8 v7, v7, 0x1

    goto :goto_9

    .line 352
    :cond_a
    iget-object v1, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzakx;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzang;

    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzang;->zzc()Ljava/lang/Iterable;

    move-result-object v1

    invoke-interface {v1}, Ljava/lang/Iterable;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :goto_a
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_b

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/util/Map$Entry;

    .line 353
    invoke-interface {v2}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Lcom/google/android/gms/internal/firebase-auth-api/zzakz;

    invoke-interface {v2}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v2

    invoke-static {v4, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakx;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzakz;Ljava/lang/Object;)I

    move-result v2

    add-int/2addr v3, v2

    goto :goto_a

    :cond_b
    add-int/2addr v9, v3

    :cond_c
    return v9

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_44
        :pswitch_43
        :pswitch_42
        :pswitch_41
        :pswitch_40
        :pswitch_3f
        :pswitch_3e
        :pswitch_3d
        :pswitch_3c
        :pswitch_3b
        :pswitch_3a
        :pswitch_39
        :pswitch_38
        :pswitch_37
        :pswitch_36
        :pswitch_35
        :pswitch_34
        :pswitch_33
        :pswitch_32
        :pswitch_31
        :pswitch_30
        :pswitch_2f
        :pswitch_2e
        :pswitch_2d
        :pswitch_2c
        :pswitch_2b
        :pswitch_2a
        :pswitch_29
        :pswitch_28
        :pswitch_27
        :pswitch_26
        :pswitch_25
        :pswitch_24
        :pswitch_23
        :pswitch_22
        :pswitch_21
        :pswitch_20
        :pswitch_1f
        :pswitch_1e
        :pswitch_1d
        :pswitch_1c
        :pswitch_1b
        :pswitch_1a
        :pswitch_19
        :pswitch_18
        :pswitch_17
        :pswitch_16
        :pswitch_15
        :pswitch_14
        :pswitch_13
        :pswitch_12
        :pswitch_11
        :pswitch_10
        :pswitch_f
        :pswitch_e
        :pswitch_d
        :pswitch_c
        :pswitch_b
        :pswitch_a
        :pswitch_9
        :pswitch_8
        :pswitch_7
        :pswitch_6
        :pswitch_5
        :pswitch_4
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method final zza(Ljava/lang/Object;[BIIILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I
    .locals 32
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;[BIII",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzaju;",
            ")I"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    move-object/from16 v0, p0

    move-object/from16 v2, p1

    move-object/from16 v3, p2

    move/from16 v5, p4

    move-object/from16 v6, p6

    .line 468
    invoke-static {v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzf(Ljava/lang/Object;)V

    .line 469
    sget-object v1, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb:Lsun/misc/Unsafe;

    move/from16 v4, p3

    const/4 v7, -0x1

    const/4 v8, 0x0

    const v9, 0xfffff

    const/4 v14, 0x0

    const/4 v15, 0x0

    :goto_0
    if-ge v4, v5, :cond_77

    add-int/lit8 v15, v4, 0x1

    .line 476
    aget-byte v4, v3, v4

    if-gez v4, :cond_0

    .line 478
    invoke-static {v4, v3, v15, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza(I[BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v15

    .line 479
    iget v4, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    :cond_0
    move/from16 v29, v15

    move v15, v4

    move/from16 v4, v29

    ushr-int/lit8 v12, v15, 0x3

    const v16, 0xfffff

    and-int/lit8 v11, v15, 0x7

    const/4 v13, 0x3

    if-le v12, v7, :cond_2

    .line 483
    div-int/2addr v8, v13

    .line 484
    iget v7, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze:I

    if-lt v12, v7, :cond_1

    iget v7, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzf:I

    if-gt v12, v7, :cond_1

    .line 485
    invoke-direct {v0, v12, v8}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(II)I

    move-result v7

    goto :goto_1

    :cond_1
    const/4 v7, -0x1

    goto :goto_1

    .line 488
    :cond_2
    invoke-direct {v0, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(I)I

    move-result v7

    :goto_1
    const/4 v8, -0x1

    if-ne v7, v8, :cond_3

    move/from16 v10, p5

    move-object/from16 v19, v1

    move-object v1, v3

    move v3, v4

    move/from16 v17, v8

    move/from16 v27, v9

    move v8, v12

    move/from16 v18, v14

    const/4 v9, 0x0

    move-object v12, v2

    move-object v14, v6

    goto/16 :goto_4b

    .line 492
    :cond_3
    iget-object v8, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    add-int/lit8 v18, v7, 0x1

    aget v13, v8, v18

    const/high16 v18, 0xff00000

    and-int v18, v13, v18

    ushr-int/lit8 v3, v18, 0x14

    move/from16 v18, v4

    and-int v4, v13, v16

    int-to-long v4, v4

    move-wide/from16 v19, v4

    .line 499
    const-string v5, ""

    const-wide/16 v21, 0x0

    const/16 v25, 0x1

    const/16 v4, 0x11

    if-gt v3, v4, :cond_16

    add-int/lit8 v4, v7, 0x2

    .line 500
    aget v4, v8, v4

    ushr-int/lit8 v8, v4, 0x14

    shl-int v23, v25, v8

    and-int v4, v4, v16

    if-eq v4, v9, :cond_6

    move/from16 v8, v16

    if-eq v9, v8, :cond_4

    int-to-long v8, v9

    .line 505
    invoke-virtual {v1, v2, v8, v9, v14}, Lsun/misc/Unsafe;->putInt(Ljava/lang/Object;JI)V

    const v8, 0xfffff

    :cond_4
    if-ne v4, v8, :cond_5

    const/4 v14, 0x0

    goto :goto_2

    :cond_5
    int-to-long v8, v4

    .line 509
    invoke-virtual {v1, v2, v8, v9}, Lsun/misc/Unsafe;->getInt(Ljava/lang/Object;J)I

    move-result v8

    move v14, v8

    :goto_2
    move/from16 v27, v14

    move v14, v4

    goto :goto_3

    :cond_6
    move/from16 v27, v14

    move v14, v9

    :goto_3
    packed-switch v3, :pswitch_data_0

    move-object/from16 p3, v2

    move-object v2, v1

    move-object/from16 v1, p3

    move v8, v7

    move/from16 p3, v14

    move/from16 v9, v18

    const/16 v17, -0x1

    :goto_4
    move-object/from16 v7, p2

    move/from16 v18, v15

    move-object v15, v6

    goto/16 :goto_18

    :pswitch_0
    const/4 v3, 0x3

    if-ne v11, v3, :cond_7

    .line 603
    invoke-direct {v0, v2, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;I)Ljava/lang/Object;

    move-result-object v3

    shl-int/lit8 v4, v12, 0x3

    or-int/lit8 v8, v4, 0x4

    .line 606
    invoke-direct {v0, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v4

    move-object/from16 v5, p2

    move-object v9, v6

    move v13, v7

    move/from16 v6, v18

    const/16 v17, -0x1

    move/from16 v7, p4

    .line 607
    invoke-static/range {v3 .. v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza(Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;[BIIILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v4

    move-object v7, v5

    .line 608
    invoke-direct {v0, v2, v13, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;ILjava/lang/Object;)V

    or-int v3, v27, v23

    goto/16 :goto_5

    :cond_7
    const/16 v17, -0x1

    move-object/from16 p3, v2

    move-object v2, v1

    move-object/from16 v1, p3

    move v8, v7

    move/from16 p3, v14

    move/from16 v9, v18

    goto :goto_4

    :pswitch_1
    move-object v9, v6

    move v13, v7

    move/from16 v4, v18

    const/16 v17, -0x1

    move-object/from16 v7, p2

    if-nez v11, :cond_8

    .line 596
    invoke-static {v7, v4, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v8

    .line 597
    iget-wide v3, v9, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzb:J

    .line 598
    invoke-static {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzakh;->zza(J)J

    move-result-wide v5

    move-wide/from16 v3, v19

    .line 599
    invoke-virtual/range {v1 .. v6}, Lsun/misc/Unsafe;->putLong(Ljava/lang/Object;JJ)V

    move-object/from16 v29, v2

    move-object v2, v1

    move-object/from16 v1, v29

    or-int v3, v27, v23

    move-object v4, v2

    move-object v2, v1

    move-object v1, v4

    move/from16 v5, p4

    move v4, v8

    goto :goto_6

    :cond_8
    move-object/from16 v29, v2

    move-object v2, v1

    move-object/from16 v1, v29

    goto :goto_7

    :pswitch_2
    move-object v4, v2

    move-object v2, v1

    move-object v1, v4

    move-object v9, v6

    move v13, v7

    move/from16 v4, v18

    move-wide/from16 v5, v19

    const/16 v17, -0x1

    move-object/from16 v7, p2

    if-nez v11, :cond_9

    .line 589
    invoke-static {v7, v4, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v4

    .line 590
    iget v3, v9, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    .line 591
    invoke-static {v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakh;->zza(I)I

    move-result v3

    .line 592
    invoke-virtual {v2, v1, v5, v6, v3}, Lsun/misc/Unsafe;->putInt(Ljava/lang/Object;JI)V

    or-int v3, v27, v23

    move-object v5, v2

    move-object v2, v1

    move-object v1, v5

    :goto_5
    move/from16 v5, p4

    :goto_6
    move-object v6, v9

    move v8, v13

    goto/16 :goto_a

    :cond_9
    :goto_7
    move v8, v13

    goto/16 :goto_b

    :pswitch_3
    move-object v4, v2

    move-object v2, v1

    move-object v1, v4

    move-object v9, v6

    move v8, v7

    move/from16 v4, v18

    move-wide/from16 v5, v19

    const/16 v17, -0x1

    move-object/from16 v7, p2

    if-nez v11, :cond_c

    .line 577
    invoke-static {v7, v4, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v4

    .line 578
    iget v3, v9, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    .line 579
    invoke-direct {v0, v8}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(I)Lcom/google/android/gms/internal/firebase-auth-api/zzalj;

    move-result-object v11

    const/high16 v18, -0x80000000

    and-int v13, v13, v18

    if-eqz v13, :cond_b

    if-eqz v11, :cond_b

    .line 583
    invoke-interface {v11, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzalj;->zza(I)Z

    move-result v11

    if-eqz v11, :cond_a

    goto :goto_8

    .line 586
    :cond_a
    invoke-static {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;)Lcom/google/android/gms/internal/firebase-auth-api/zzanx;

    move-result-object v5

    move/from16 p3, v4

    int-to-long v3, v3

    invoke-static {v3, v4}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v3

    invoke-virtual {v5, v15, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanx;->zza(ILjava/lang/Object;)V

    move-object v3, v2

    move-object v2, v1

    move-object v1, v3

    move/from16 v4, p3

    move/from16 v5, p4

    move-object v3, v7

    move-object v6, v9

    move v7, v12

    move v9, v14

    move/from16 v14, v27

    goto/16 :goto_0

    :cond_b
    :goto_8
    move/from16 p3, v4

    .line 584
    invoke-virtual {v2, v1, v5, v6, v3}, Lsun/misc/Unsafe;->putInt(Ljava/lang/Object;JI)V

    or-int v3, v27, v23

    move-object v4, v2

    move-object v2, v1

    move-object v1, v4

    move/from16 v4, p3

    goto :goto_9

    :pswitch_4
    move-object v3, v2

    move-object v2, v1

    move-object v1, v3

    move-object v9, v6

    move v8, v7

    move/from16 v4, v18

    move-wide/from16 v5, v19

    const/4 v3, 0x2

    const/16 v17, -0x1

    move-object/from16 v7, p2

    if-ne v11, v3, :cond_c

    .line 572
    invoke-static {v7, v4, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v4

    .line 573
    iget-object v3, v9, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzc:Ljava/lang/Object;

    invoke-virtual {v2, v1, v5, v6, v3}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    or-int v3, v27, v23

    move-object v5, v2

    move-object v2, v1

    move-object v1, v5

    :goto_9
    move/from16 v5, p4

    move-object v6, v9

    :goto_a
    move v9, v14

    move v14, v3

    move-object v3, v7

    goto :goto_c

    :cond_c
    :goto_b
    move/from16 p3, v14

    move/from16 v18, v15

    move-object v15, v9

    goto/16 :goto_12

    :pswitch_5
    move-object v3, v2

    move-object v2, v1

    move-object v1, v3

    move-object v9, v6

    move v8, v7

    move/from16 v4, v18

    const/4 v3, 0x2

    const/16 v17, -0x1

    move-object/from16 v7, p2

    if-ne v11, v3, :cond_d

    move-object v5, v1

    .line 564
    invoke-direct {v0, v5, v8}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;I)Ljava/lang/Object;

    move-result-object v1

    move-object v3, v2

    .line 566
    invoke-direct {v0, v8}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v2

    move-object v6, v9

    move-object v9, v3

    move-object v3, v7

    move-object v7, v5

    move/from16 v5, p4

    .line 567
    invoke-static/range {v1 .. v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza(Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;[BIILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v4

    move-object v2, v3

    move-object v3, v1

    move-object v1, v2

    move-object v2, v6

    .line 568
    invoke-direct {v0, v7, v8, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;ILjava/lang/Object;)V

    or-int v3, v27, v23

    move v5, v3

    move-object v3, v1

    move-object v1, v9

    move v9, v14

    move v14, v5

    move/from16 v5, p4

    move-object v2, v7

    :goto_c
    move v7, v12

    goto/16 :goto_0

    :cond_d
    move-object/from16 v29, v7

    move-object v7, v1

    move-object/from16 v1, v29

    move-object/from16 v29, v9

    move-object v9, v2

    move-object/from16 v2, v29

    move-object/from16 p3, v7

    move-object v7, v1

    move-object/from16 v1, p3

    move/from16 p3, v14

    move/from16 v18, v15

    goto/16 :goto_11

    :pswitch_6
    move-object v9, v1

    move v8, v7

    move/from16 p3, v14

    move/from16 v4, v18

    const/4 v3, 0x2

    const/16 v17, -0x1

    move-object/from16 v1, p2

    move-object v7, v2

    move-object v2, v6

    move/from16 v18, v15

    move-wide/from16 v14, v19

    if-ne v11, v3, :cond_12

    .line 547
    invoke-static {v13}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzg(I)Z

    move-result v3

    if-eqz v3, :cond_e

    .line 548
    invoke-static {v1, v4, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzb([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v3

    :goto_d
    move v4, v3

    goto :goto_e

    .line 550
    :cond_e
    invoke-static {v1, v4, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v3

    .line 551
    iget v4, v2, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-ltz v4, :cond_10

    if-nez v4, :cond_f

    .line 555
    iput-object v5, v2, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzc:Ljava/lang/Object;

    goto :goto_d

    .line 557
    :cond_f
    new-instance v5, Ljava/lang/String;

    sget-object v6, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza:Ljava/nio/charset/Charset;

    invoke-direct {v5, v1, v3, v4, v6}, Ljava/lang/String;-><init>([BIILjava/nio/charset/Charset;)V

    iput-object v5, v2, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzc:Ljava/lang/Object;

    add-int/2addr v3, v4

    goto :goto_d

    .line 560
    :goto_e
    iget-object v3, v2, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzc:Ljava/lang/Object;

    invoke-virtual {v9, v7, v14, v15, v3}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    goto :goto_10

    .line 553
    :cond_10
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzf()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    :pswitch_7
    move-object v9, v1

    move v8, v7

    move/from16 p3, v14

    move/from16 v4, v18

    const/16 v17, -0x1

    move-object/from16 v1, p2

    move-object v7, v2

    move-object v2, v6

    move/from16 v18, v15

    move-wide/from16 v14, v19

    if-nez v11, :cond_12

    .line 542
    invoke-static {v1, v4, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v4

    .line 543
    iget-wide v5, v2, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzb:J

    cmp-long v3, v5, v21

    if-eqz v3, :cond_11

    move/from16 v3, v25

    goto :goto_f

    :cond_11
    const/4 v3, 0x0

    :goto_f
    invoke-static {v7, v14, v15, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;JZ)V

    goto :goto_10

    :pswitch_8
    move-object v9, v1

    move v8, v7

    move/from16 p3, v14

    move/from16 v4, v18

    const/4 v3, 0x5

    const/16 v17, -0x1

    move-object/from16 v1, p2

    move-object v7, v2

    move-object v2, v6

    move/from16 v18, v15

    move-wide/from16 v14, v19

    if-ne v11, v3, :cond_12

    .line 537
    invoke-static {v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BI)I

    move-result v3

    invoke-virtual {v9, v7, v14, v15, v3}, Lsun/misc/Unsafe;->putInt(Ljava/lang/Object;JI)V

    add-int/lit8 v4, v4, 0x4

    :goto_10
    or-int v14, v27, v23

    move/from16 v5, p4

    move-object v3, v1

    move-object v6, v2

    move-object v2, v7

    move-object v1, v9

    move v7, v12

    goto/16 :goto_14

    :cond_12
    move-object v15, v7

    move-object v7, v1

    move-object v1, v15

    :goto_11
    move-object v15, v2

    move-object v2, v9

    :goto_12
    move v9, v4

    goto/16 :goto_18

    :pswitch_9
    move-object v9, v1

    move v8, v7

    move/from16 p3, v14

    move/from16 v4, v18

    move/from16 v3, v25

    const/16 v17, -0x1

    move-object/from16 v1, p2

    move-object v7, v2

    move-object v2, v6

    move/from16 v18, v15

    move-wide/from16 v14, v19

    if-ne v11, v3, :cond_13

    .line 532
    invoke-static {v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BI)J

    move-result-wide v5

    move-object/from16 v29, v7

    move-object v7, v1

    move-object v1, v9

    move v9, v4

    move-wide v3, v14

    move-object v15, v2

    move-object/from16 v2, v29

    invoke-virtual/range {v1 .. v6}, Lsun/misc/Unsafe;->putLong(Ljava/lang/Object;JJ)V

    add-int/lit8 v4, v9, 0x8

    or-int v14, v27, v23

    goto/16 :goto_17

    :cond_13
    move-object v15, v2

    move-object v2, v7

    move-object v7, v1

    move-object v1, v9

    move v9, v4

    goto/16 :goto_15

    :pswitch_a
    move v8, v7

    move/from16 p3, v14

    move/from16 v9, v18

    move-wide/from16 v3, v19

    const/16 v17, -0x1

    move-object/from16 v7, p2

    move/from16 v18, v15

    move-object v15, v6

    if-nez v11, :cond_14

    .line 527
    invoke-static {v7, v9, v15}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v5

    .line 528
    iget v6, v15, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    invoke-virtual {v1, v2, v3, v4, v6}, Lsun/misc/Unsafe;->putInt(Ljava/lang/Object;JI)V

    or-int v14, v27, v23

    move/from16 v9, p3

    move v4, v5

    move-object v3, v7

    move v7, v12

    move-object v6, v15

    move/from16 v15, v18

    :goto_13
    move/from16 v5, p4

    goto/16 :goto_0

    :pswitch_b
    move v8, v7

    move/from16 p3, v14

    move/from16 v9, v18

    move-wide/from16 v3, v19

    const/16 v17, -0x1

    move-object/from16 v7, p2

    move/from16 v18, v15

    move-object v15, v6

    if-nez v11, :cond_14

    .line 522
    invoke-static {v7, v9, v15}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v9

    .line 523
    iget-wide v5, v15, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzb:J

    invoke-virtual/range {v1 .. v6}, Lsun/misc/Unsafe;->putLong(Ljava/lang/Object;JJ)V

    move-object/from16 v29, v2

    move-object v2, v1

    move-object/from16 v1, v29

    or-int v14, v27, v23

    move-object v3, v2

    move-object v2, v1

    move-object v1, v3

    move/from16 v5, p4

    move-object v3, v7

    move v4, v9

    move v7, v12

    move-object v6, v15

    :goto_14
    move/from16 v15, v18

    move/from16 v9, p3

    goto/16 :goto_0

    :cond_14
    :goto_15
    move-object/from16 v29, v2

    move-object v2, v1

    move-object/from16 v1, v29

    goto/16 :goto_18

    :pswitch_c
    move-object/from16 p3, v2

    move-object v2, v1

    move-object/from16 v1, p3

    move v8, v7

    move/from16 p3, v14

    move/from16 v9, v18

    move-wide/from16 v3, v19

    const/4 v5, 0x5

    const/16 v17, -0x1

    move-object/from16 v7, p2

    move/from16 v18, v15

    move-object v15, v6

    if-ne v11, v5, :cond_15

    .line 517
    invoke-static {v7, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzb([BI)F

    move-result v5

    invoke-static {v1, v3, v4, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JF)V

    add-int/lit8 v4, v9, 0x4

    goto :goto_16

    :pswitch_d
    move-object/from16 p3, v2

    move-object v2, v1

    move-object/from16 v1, p3

    move v8, v7

    move/from16 p3, v14

    move/from16 v9, v18

    move-wide/from16 v3, v19

    move/from16 v5, v25

    const/16 v17, -0x1

    move-object/from16 v7, p2

    move/from16 v18, v15

    move-object v15, v6

    if-ne v11, v5, :cond_15

    .line 512
    invoke-static {v7, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza([BI)D

    move-result-wide v5

    invoke-static {v1, v3, v4, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JD)V

    add-int/lit8 v4, v9, 0x8

    :goto_16
    or-int v14, v27, v23

    move-object v3, v2

    move-object v2, v1

    move-object v1, v3

    :goto_17
    move/from16 v9, p3

    move/from16 v5, p4

    move-object v3, v7

    move v7, v12

    move-object v6, v15

    move/from16 v15, v18

    goto/16 :goto_0

    :cond_15
    :goto_18
    move/from16 v10, p5

    move-object/from16 v19, v2

    move v3, v9

    move-object v14, v15

    move/from16 v15, v18

    move/from16 v18, v27

    move/from16 v27, p3

    move v9, v8

    move v8, v12

    move-object v12, v1

    move-object v1, v7

    goto/16 :goto_4b

    :cond_16
    move-object v4, v2

    move-object v2, v1

    move-object v1, v4

    move v4, v7

    const/16 v17, -0x1

    move/from16 v29, v15

    move-object v15, v6

    move-wide/from16 v6, v19

    move-object/from16 v20, v8

    move/from16 v19, v18

    move/from16 v18, v29

    const/16 v8, 0x1b

    if-ne v3, v8, :cond_1a

    const/4 v8, 0x2

    if-ne v11, v8, :cond_19

    .line 613
    invoke-virtual {v2, v1, v6, v7}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;

    .line 614
    invoke-interface {v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;->zzc()Z

    move-result v5

    if-nez v5, :cond_18

    .line 615
    invoke-interface {v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;->size()I

    move-result v5

    if-nez v5, :cond_17

    const/16 v5, 0xa

    goto :goto_19

    :cond_17
    shl-int/lit8 v5, v5, 0x1

    .line 618
    :goto_19
    invoke-interface {v3, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;->zza(I)Lcom/google/android/gms/internal/firebase-auth-api/zzalm;

    move-result-object v3

    .line 619
    invoke-virtual {v2, v1, v6, v7, v3}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    :cond_18
    move-object v6, v3

    .line 621
    invoke-direct {v0, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v1

    move-object/from16 v8, p1

    move-object/from16 v3, p2

    move/from16 v5, p4

    move v13, v4

    move-object v7, v15

    move/from16 v4, v19

    move-object v15, v2

    move/from16 v2, v18

    .line 622
    invoke-static/range {v1 .. v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzb(Lcom/google/android/gms/internal/firebase-auth-api/zzanb;I[BIILcom/google/android/gms/internal/firebase-auth-api/zzalm;Lcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v4

    move v1, v2

    move-object v2, v15

    move v15, v1

    move-object v1, v2

    move-object/from16 v6, p6

    move-object v2, v8

    move v7, v12

    move v8, v13

    goto/16 :goto_0

    :cond_19
    move-object v8, v1

    move v1, v12

    move-object v12, v8

    move v8, v1

    move-object/from16 v1, p2

    move-object/from16 v5, p6

    move/from16 v27, v9

    move/from16 v15, v18

    move v9, v4

    move/from16 v18, v14

    move/from16 v14, v19

    move/from16 v4, p4

    move-object/from16 v19, v2

    goto/16 :goto_40

    :cond_1a
    move-object v8, v1

    move-object v15, v2

    move v2, v4

    move/from16 v4, v19

    const/16 v1, 0x31

    if-gt v3, v1, :cond_5c

    move/from16 v19, v12

    int-to-long v12, v13

    .line 628
    sget-object v1, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb:Lsun/misc/Unsafe;

    invoke-virtual {v1, v8, v6, v7}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v20

    move/from16 v23, v4

    move-object/from16 v4, v20

    check-cast v4, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;

    .line 629
    invoke-interface {v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;->zzc()Z

    move-result v20

    if-nez v20, :cond_1b

    .line 630
    invoke-interface {v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;->size()I

    move-result v20

    move/from16 v27, v9

    const/16 v25, 0x1

    shl-int/lit8 v9, v20, 0x1

    .line 631
    invoke-interface {v4, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;->zza(I)Lcom/google/android/gms/internal/firebase-auth-api/zzalm;

    move-result-object v4

    .line 632
    invoke-virtual {v1, v8, v6, v7, v4}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    goto :goto_1a

    :cond_1b
    move/from16 v27, v9

    :goto_1a
    move-object v6, v4

    packed-switch v3, :pswitch_data_1

    move/from16 v4, p4

    move-object/from16 v1, p6

    move v9, v2

    move-object v12, v8

    move/from16 v8, v19

    move-object/from16 v2, p2

    :goto_1b
    move-object/from16 v19, v15

    move/from16 v15, v18

    move/from16 v18, v14

    move/from16 v14, v23

    goto/16 :goto_3b

    :pswitch_e
    const/4 v3, 0x3

    if-ne v11, v3, :cond_1c

    .line 955
    invoke-direct {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v1

    move-object/from16 v3, p2

    move/from16 v5, p4

    move-object/from16 v7, p6

    move v9, v2

    move/from16 v2, v18

    move/from16 v4, v23

    .line 956
    invoke-static/range {v1 .. v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzanb;I[BIILcom/google/android/gms/internal/firebase-auth-api/zzalm;Lcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v1

    move-object v12, v8

    move/from16 v18, v14

    move/from16 v8, v19

    move v14, v4

    move v4, v5

    move-object/from16 v19, v15

    move v15, v2

    move-object v2, v3

    move v3, v1

    move-object v1, v7

    goto/16 :goto_3c

    :cond_1c
    move v9, v2

    move-object/from16 v2, p2

    move/from16 v4, p4

    move-object/from16 v1, p6

    move-object v12, v8

    move/from16 v8, v19

    goto :goto_1b

    :pswitch_f
    move-object/from16 v3, p2

    move/from16 v5, p4

    move v9, v2

    move-object v1, v6

    move/from16 v2, v18

    move/from16 v4, v23

    const/4 v7, 0x2

    move-object/from16 v6, p6

    if-ne v11, v7, :cond_1f

    .line 930
    check-cast v1, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;

    .line 931
    invoke-static {v3, v4, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v7

    .line 932
    iget v11, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    add-int/2addr v11, v7

    :goto_1c
    if-ge v7, v11, :cond_1d

    .line 934
    invoke-static {v3, v7, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v7

    .line 935
    iget-wide v12, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzb:J

    invoke-static {v12, v13}, Lcom/google/android/gms/internal/firebase-auth-api/zzakh;->zza(J)J

    move-result-wide v12

    invoke-virtual {v1, v12, v13}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zza(J)V

    goto :goto_1c

    :cond_1d
    if-ne v7, v11, :cond_1e

    goto/16 :goto_20

    .line 937
    :cond_1e
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzj()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    :cond_1f
    if-nez v11, :cond_24

    .line 942
    check-cast v1, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;

    .line 943
    invoke-static {v3, v4, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v7

    .line 944
    iget-wide v11, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzb:J

    invoke-static {v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzakh;->zza(J)J

    move-result-wide v11

    invoke-virtual {v1, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zza(J)V

    :goto_1d
    if-ge v7, v5, :cond_23

    .line 946
    invoke-static {v3, v7, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v11

    .line 947
    iget v12, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-ne v2, v12, :cond_23

    .line 948
    invoke-static {v3, v11, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v7

    .line 949
    iget-wide v11, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzb:J

    invoke-static {v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzakh;->zza(J)J

    move-result-wide v11

    invoke-virtual {v1, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zza(J)V

    goto :goto_1d

    :pswitch_10
    move-object/from16 v3, p2

    move/from16 v5, p4

    move v9, v2

    move-object v1, v6

    move/from16 v2, v18

    move/from16 v4, v23

    const/4 v7, 0x2

    move-object/from16 v6, p6

    if-ne v11, v7, :cond_22

    .line 905
    check-cast v1, Lcom/google/android/gms/internal/firebase-auth-api/zzali;

    .line 906
    invoke-static {v3, v4, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v7

    .line 907
    iget v11, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    add-int/2addr v11, v7

    :goto_1e
    if-ge v7, v11, :cond_20

    .line 909
    invoke-static {v3, v7, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v7

    .line 910
    iget v12, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    invoke-static {v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzakh;->zza(I)I

    move-result v12

    invoke-virtual {v1, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzc(I)V

    goto :goto_1e

    :cond_20
    if-ne v7, v11, :cond_21

    goto :goto_20

    .line 912
    :cond_21
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzj()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    :cond_22
    if-nez v11, :cond_24

    .line 917
    check-cast v1, Lcom/google/android/gms/internal/firebase-auth-api/zzali;

    .line 918
    invoke-static {v3, v4, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v7

    .line 919
    iget v11, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    invoke-static {v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzakh;->zza(I)I

    move-result v11

    invoke-virtual {v1, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzc(I)V

    :goto_1f
    if-ge v7, v5, :cond_23

    .line 921
    invoke-static {v3, v7, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v11

    .line 922
    iget v12, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-ne v2, v12, :cond_23

    .line 923
    invoke-static {v3, v11, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v7

    .line 924
    iget v11, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    invoke-static {v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzakh;->zza(I)I

    move-result v11

    invoke-virtual {v1, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzc(I)V

    goto :goto_1f

    :cond_23
    :goto_20
    move-object v1, v6

    move-object v12, v8

    move/from16 v18, v14

    move/from16 v8, v19

    move v14, v4

    move v4, v5

    move-object/from16 v19, v15

    move v15, v2

    move-object v2, v3

    move v3, v7

    goto/16 :goto_3c

    :cond_24
    move-object v1, v6

    move-object v12, v8

    move/from16 v18, v14

    move/from16 v8, v19

    move v14, v4

    move v4, v5

    move-object/from16 v19, v15

    move v15, v2

    move-object v2, v3

    goto/16 :goto_3b

    :pswitch_11
    move-object/from16 v3, p2

    move/from16 v5, p4

    move v9, v2

    move-object v1, v6

    move/from16 v2, v18

    move/from16 v4, v23

    const/4 v7, 0x2

    move-object/from16 v6, p6

    if-ne v11, v7, :cond_25

    .line 896
    invoke-static {v3, v4, v1, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza([BILcom/google/android/gms/internal/firebase-auth-api/zzalm;Lcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v7

    move/from16 v18, v2

    move-object v12, v3

    move/from16 v23, v4

    move v13, v5

    move v11, v7

    move-object v5, v1

    :goto_21
    move-object v7, v6

    goto :goto_22

    :cond_25
    if-nez v11, :cond_26

    move/from16 v29, v5

    move-object v5, v1

    move v1, v2

    move-object v2, v3

    move v3, v4

    move/from16 v4, v29

    .line 898
    invoke-static/range {v1 .. v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza(I[BIILcom/google/android/gms/internal/firebase-auth-api/zzalm;Lcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v7

    move/from16 v18, v1

    move-object v12, v2

    move/from16 v23, v3

    move v13, v4

    move v1, v7

    move v11, v1

    goto :goto_21

    .line 900
    :goto_22
    invoke-direct {v0, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(I)Lcom/google/android/gms/internal/firebase-auth-api/zzalj;

    move-result-object v4

    move-object v6, v5

    const/4 v5, 0x0

    move-object v1, v6

    iget-object v6, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzp:Lcom/google/android/gms/internal/firebase-auth-api/zzanu;

    move-object v3, v1

    move-object v1, v8

    move/from16 v2, v19

    .line 901
    invoke-static/range {v1 .. v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(Ljava/lang/Object;ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzalj;Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanu;)Ljava/lang/Object;

    move v8, v2

    move-object v1, v7

    move v3, v11

    move-object v2, v12

    move v4, v13

    move-object/from16 v19, v15

    move/from16 v15, v18

    move-object/from16 v12, p1

    move/from16 v18, v14

    move/from16 v14, v23

    goto/16 :goto_3c

    :cond_26
    move/from16 v8, v19

    move-object/from16 v12, p1

    move-object v1, v6

    move/from16 v18, v14

    move-object/from16 v19, v15

    move v15, v2

    move-object v2, v3

    move v14, v4

    move v4, v5

    goto/16 :goto_3b

    :pswitch_12
    move-object/from16 v12, p2

    move/from16 v13, p4

    move-object/from16 v7, p6

    move v9, v2

    move-object v5, v6

    move/from16 v1, v18

    move/from16 v8, v19

    move/from16 v4, v23

    const/4 v3, 0x2

    if-ne v11, v3, :cond_2e

    .line 869
    invoke-static {v12, v4, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v2

    .line 870
    iget v3, v7, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-ltz v3, :cond_2d

    .line 873
    array-length v6, v12

    sub-int/2addr v6, v2

    if-gt v3, v6, :cond_2c

    if-nez v3, :cond_27

    .line 876
    sget-object v3, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    invoke-interface {v5, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;->add(Ljava/lang/Object;)Z

    goto :goto_24

    .line 877
    :cond_27
    invoke-static {v12, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;->zza([BII)Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    move-result-object v6

    invoke-interface {v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;->add(Ljava/lang/Object;)Z

    :goto_23
    add-int/2addr v2, v3

    :goto_24
    if-ge v2, v13, :cond_2b

    .line 880
    invoke-static {v12, v2, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v3

    .line 881
    iget v6, v7, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-ne v1, v6, :cond_2b

    .line 882
    invoke-static {v12, v3, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v2

    .line 883
    iget v3, v7, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-ltz v3, :cond_2a

    .line 886
    array-length v6, v12

    sub-int/2addr v6, v2

    if-gt v3, v6, :cond_29

    if-nez v3, :cond_28

    .line 889
    sget-object v3, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    invoke-interface {v5, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;->add(Ljava/lang/Object;)Z

    goto :goto_24

    .line 890
    :cond_28
    invoke-static {v12, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;->zza([BII)Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    move-result-object v6

    invoke-interface {v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;->add(Ljava/lang/Object;)Z

    goto :goto_23

    .line 887
    :cond_29
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzj()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    .line 885
    :cond_2a
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzf()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    :cond_2b
    move v3, v2

    move-object v2, v12

    move/from16 v18, v14

    move-object/from16 v19, v15

    move-object/from16 v12, p1

    move v15, v1

    move v14, v4

    move-object v1, v7

    move v4, v13

    goto/16 :goto_3c

    .line 874
    :cond_2c
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzj()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    .line 872
    :cond_2d
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzf()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    :cond_2e
    move-object v2, v12

    move/from16 v18, v14

    move-object/from16 v19, v15

    move-object/from16 v12, p1

    move v15, v1

    move v14, v4

    move-object v1, v7

    goto :goto_25

    :pswitch_13
    move-object/from16 v12, p2

    move/from16 v13, p4

    move-object/from16 v7, p6

    move v9, v2

    move-object v5, v6

    move/from16 v1, v18

    move/from16 v8, v19

    move/from16 v4, v23

    const/4 v3, 0x2

    if-ne v11, v3, :cond_2f

    move v2, v1

    .line 864
    invoke-direct {v0, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v1

    move-object v6, v5

    move-object v3, v12

    move v5, v13

    .line 865
    invoke-static/range {v1 .. v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzb(Lcom/google/android/gms/internal/firebase-auth-api/zzanb;I[BIILcom/google/android/gms/internal/firebase-auth-api/zzalm;Lcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v1

    move-object v6, v3

    move v3, v1

    move v1, v2

    move-object v2, v6

    move-object v6, v7

    move-object/from16 v12, p1

    move/from16 v18, v14

    move-object/from16 v19, v15

    move v15, v1

    move v14, v4

    move v4, v5

    move-object v1, v6

    goto/16 :goto_3c

    :cond_2f
    move-object v6, v7

    move-object v2, v12

    move/from16 v18, v14

    move-object/from16 v19, v15

    move-object/from16 v12, p1

    move v15, v1

    move v14, v4

    move-object v1, v6

    :goto_25
    move v4, v13

    goto/16 :goto_3b

    :pswitch_14
    move/from16 v4, p4

    move v9, v2

    move/from16 v1, v18

    move/from16 v7, v23

    const/4 v3, 0x2

    move-object/from16 v2, p2

    move-object/from16 v29, v6

    move-object/from16 v6, p6

    move-wide/from16 v30, v12

    move-object/from16 v13, v29

    move-object v12, v8

    move/from16 v8, v19

    move-wide/from16 v18, v30

    if-ne v11, v3, :cond_3b

    const-wide/32 v23, 0x20000000

    and-long v18, v18, v23

    cmp-long v3, v18, v21

    if-nez v3, :cond_34

    .line 808
    invoke-static {v2, v7, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v3

    .line 809
    iget v11, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-ltz v11, :cond_33

    if-nez v11, :cond_30

    .line 813
    invoke-interface {v13, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;->add(Ljava/lang/Object;)Z

    move/from16 v18, v14

    move-object/from16 v19, v15

    goto :goto_27

    :cond_30
    move/from16 v18, v14

    .line 814
    new-instance v14, Ljava/lang/String;

    move-object/from16 v19, v15

    sget-object v15, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza:Ljava/nio/charset/Charset;

    invoke-direct {v14, v2, v3, v11, v15}, Ljava/lang/String;-><init>([BIILjava/nio/charset/Charset;)V

    .line 815
    invoke-interface {v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;->add(Ljava/lang/Object;)Z

    :goto_26
    add-int/2addr v3, v11

    :goto_27
    if-ge v3, v4, :cond_4c

    .line 818
    invoke-static {v2, v3, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v11

    .line 819
    iget v14, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-ne v1, v14, :cond_4c

    .line 820
    invoke-static {v2, v11, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v3

    .line 821
    iget v11, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-ltz v11, :cond_32

    if-nez v11, :cond_31

    .line 825
    invoke-interface {v13, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;->add(Ljava/lang/Object;)Z

    goto :goto_27

    .line 826
    :cond_31
    new-instance v14, Ljava/lang/String;

    sget-object v15, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza:Ljava/nio/charset/Charset;

    invoke-direct {v14, v2, v3, v11, v15}, Ljava/lang/String;-><init>([BIILjava/nio/charset/Charset;)V

    .line 827
    invoke-interface {v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;->add(Ljava/lang/Object;)Z

    goto :goto_26

    .line 823
    :cond_32
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzf()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    .line 811
    :cond_33
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzf()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    :cond_34
    move/from16 v18, v14

    move-object/from16 v19, v15

    .line 834
    invoke-static {v2, v7, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v3

    .line 835
    iget v11, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-ltz v11, :cond_3a

    if-nez v11, :cond_35

    .line 839
    invoke-interface {v13, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;->add(Ljava/lang/Object;)Z

    goto :goto_29

    :cond_35
    add-int v14, v3, v11

    .line 840
    invoke-static {v2, v3, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzaoa;->zzc([BII)Z

    move-result v15

    if-eqz v15, :cond_39

    .line 842
    new-instance v15, Ljava/lang/String;

    move/from16 p3, v14

    sget-object v14, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza:Ljava/nio/charset/Charset;

    invoke-direct {v15, v2, v3, v11, v14}, Ljava/lang/String;-><init>([BIILjava/nio/charset/Charset;)V

    .line 843
    invoke-interface {v13, v15}, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;->add(Ljava/lang/Object;)Z

    :goto_28
    move/from16 v3, p3

    :goto_29
    if-ge v3, v4, :cond_4c

    .line 846
    invoke-static {v2, v3, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v11

    .line 847
    iget v14, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-ne v1, v14, :cond_4c

    .line 848
    invoke-static {v2, v11, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v3

    .line 849
    iget v11, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-ltz v11, :cond_38

    if-nez v11, :cond_36

    .line 853
    invoke-interface {v13, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;->add(Ljava/lang/Object;)Z

    goto :goto_29

    :cond_36
    add-int v14, v3, v11

    .line 854
    invoke-static {v2, v3, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzaoa;->zzc([BII)Z

    move-result v15

    if-eqz v15, :cond_37

    .line 856
    new-instance v15, Ljava/lang/String;

    move/from16 p3, v14

    sget-object v14, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza:Ljava/nio/charset/Charset;

    invoke-direct {v15, v2, v3, v11, v14}, Ljava/lang/String;-><init>([BIILjava/nio/charset/Charset;)V

    .line 857
    invoke-interface {v13, v15}, Lcom/google/android/gms/internal/firebase-auth-api/zzalm;->add(Ljava/lang/Object;)Z

    goto :goto_28

    .line 855
    :cond_37
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzd()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    .line 851
    :cond_38
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzf()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    .line 841
    :cond_39
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzd()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    .line 837
    :cond_3a
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzf()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    :cond_3b
    move/from16 v18, v14

    move-object/from16 v19, v15

    :cond_3c
    move v15, v1

    move-object v1, v6

    move v14, v7

    goto/16 :goto_3b

    :pswitch_15
    move/from16 v4, p4

    move v9, v2

    move-object v13, v6

    move-object v12, v8

    move/from16 v1, v18

    move/from16 v8, v19

    move/from16 v7, v23

    const/4 v3, 0x2

    move-object/from16 v2, p2

    move-object/from16 v6, p6

    move/from16 v18, v14

    move-object/from16 v19, v15

    if-ne v11, v3, :cond_40

    .line 781
    move-object v3, v13

    check-cast v3, Lcom/google/android/gms/internal/firebase-auth-api/zzajt;

    .line 782
    invoke-static {v2, v7, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v5

    .line 783
    iget v11, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    add-int/2addr v11, v5

    :goto_2a
    if-ge v5, v11, :cond_3e

    .line 785
    invoke-static {v2, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v5

    .line 786
    iget-wide v13, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzb:J

    cmp-long v13, v13, v21

    if-eqz v13, :cond_3d

    const/4 v13, 0x1

    goto :goto_2b

    :cond_3d
    const/4 v13, 0x0

    :goto_2b
    invoke-virtual {v3, v13}, Lcom/google/android/gms/internal/firebase-auth-api/zzajt;->zza(Z)V

    goto :goto_2a

    :cond_3e
    if-ne v5, v11, :cond_3f

    goto/16 :goto_33

    .line 788
    :cond_3f
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzj()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    :cond_40
    if-nez v11, :cond_3c

    .line 793
    move-object v3, v13

    check-cast v3, Lcom/google/android/gms/internal/firebase-auth-api/zzajt;

    .line 794
    invoke-static {v2, v7, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v5

    .line 795
    iget-wide v13, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzb:J

    cmp-long v11, v13, v21

    if-eqz v11, :cond_41

    const/4 v11, 0x1

    goto :goto_2c

    :cond_41
    const/4 v11, 0x0

    :goto_2c
    invoke-virtual {v3, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzajt;->zza(Z)V

    :goto_2d
    if-ge v5, v4, :cond_4b

    .line 797
    invoke-static {v2, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v11

    .line 798
    iget v13, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-ne v1, v13, :cond_4b

    .line 799
    invoke-static {v2, v11, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v5

    .line 800
    iget-wide v13, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzb:J

    cmp-long v11, v13, v21

    if-eqz v11, :cond_42

    const/4 v11, 0x1

    goto :goto_2e

    :cond_42
    const/4 v11, 0x0

    :goto_2e
    invoke-virtual {v3, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzajt;->zza(Z)V

    goto :goto_2d

    :pswitch_16
    move/from16 v4, p4

    move v9, v2

    move-object v13, v6

    move-object v12, v8

    move/from16 v1, v18

    move/from16 v8, v19

    move/from16 v7, v23

    const/4 v3, 0x2

    move-object/from16 v2, p2

    move-object/from16 v6, p6

    move/from16 v18, v14

    move-object/from16 v19, v15

    if-ne v11, v3, :cond_46

    .line 752
    move-object v3, v13

    check-cast v3, Lcom/google/android/gms/internal/firebase-auth-api/zzali;

    .line 753
    invoke-static {v2, v7, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v5

    .line 754
    iget v11, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    add-int v13, v5, v11

    .line 756
    array-length v14, v2

    if-gt v13, v14, :cond_45

    .line 758
    invoke-virtual {v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->size()I

    move-result v14

    div-int/lit8 v11, v11, 0x4

    add-int/2addr v14, v11

    invoke-virtual {v3, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzd(I)V

    :goto_2f
    if-ge v5, v13, :cond_43

    .line 760
    invoke-static {v2, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BI)I

    move-result v11

    invoke-virtual {v3, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzc(I)V

    add-int/lit8 v5, v5, 0x4

    goto :goto_2f

    :cond_43
    if-ne v5, v13, :cond_44

    goto/16 :goto_33

    .line 763
    :cond_44
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzj()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    .line 757
    :cond_45
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzj()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    :cond_46
    const/4 v3, 0x5

    if-ne v11, v3, :cond_3c

    .line 768
    move-object v3, v13

    check-cast v3, Lcom/google/android/gms/internal/firebase-auth-api/zzali;

    .line 769
    invoke-static {v2, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BI)I

    move-result v5

    invoke-virtual {v3, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzc(I)V

    add-int/lit8 v5, v7, 0x4

    :goto_30
    if-ge v5, v4, :cond_4b

    .line 772
    invoke-static {v2, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v11

    .line 773
    iget v13, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-ne v1, v13, :cond_4b

    .line 774
    invoke-static {v2, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BI)I

    move-result v5

    invoke-virtual {v3, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzc(I)V

    add-int/lit8 v5, v11, 0x4

    goto :goto_30

    :pswitch_17
    move/from16 v4, p4

    move v9, v2

    move-object v13, v6

    move-object v12, v8

    move/from16 v1, v18

    move/from16 v8, v19

    move/from16 v7, v23

    const/4 v3, 0x2

    move-object/from16 v2, p2

    move-object/from16 v6, p6

    move/from16 v18, v14

    move-object/from16 v19, v15

    if-ne v11, v3, :cond_4a

    .line 723
    move-object v3, v13

    check-cast v3, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;

    .line 724
    invoke-static {v2, v7, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v5

    .line 725
    iget v11, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    add-int v13, v5, v11

    .line 727
    array-length v14, v2

    if-gt v13, v14, :cond_49

    .line 729
    invoke-virtual {v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->size()I

    move-result v14

    div-int/lit8 v11, v11, 0x8

    add-int/2addr v14, v11

    invoke-virtual {v3, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zzc(I)V

    :goto_31
    if-ge v5, v13, :cond_47

    .line 731
    invoke-static {v2, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BI)J

    move-result-wide v14

    invoke-virtual {v3, v14, v15}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zza(J)V

    add-int/lit8 v5, v5, 0x8

    goto :goto_31

    :cond_47
    if-ne v5, v13, :cond_48

    goto :goto_33

    .line 734
    :cond_48
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzj()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    .line 728
    :cond_49
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzj()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    :cond_4a
    const/4 v3, 0x1

    if-ne v11, v3, :cond_3c

    .line 739
    move-object v3, v13

    check-cast v3, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;

    .line 740
    invoke-static {v2, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BI)J

    move-result-wide v13

    invoke-virtual {v3, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zza(J)V

    add-int/lit8 v5, v7, 0x8

    :goto_32
    if-ge v5, v4, :cond_4b

    .line 743
    invoke-static {v2, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v11

    .line 744
    iget v13, v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-ne v1, v13, :cond_4b

    .line 745
    invoke-static {v2, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BI)J

    move-result-wide v13

    invoke-virtual {v3, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zza(J)V

    add-int/lit8 v5, v11, 0x8

    goto :goto_32

    :cond_4b
    :goto_33
    move v15, v1

    move v3, v5

    goto :goto_34

    :pswitch_18
    move/from16 v4, p4

    move v9, v2

    move-object v13, v6

    move-object v12, v8

    move/from16 v1, v18

    move/from16 v8, v19

    move/from16 v7, v23

    const/4 v3, 0x2

    move-object/from16 v2, p2

    move-object/from16 v6, p6

    move/from16 v18, v14

    move-object/from16 v19, v15

    if-ne v11, v3, :cond_4d

    .line 718
    invoke-static {v2, v7, v13, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza([BILcom/google/android/gms/internal/firebase-auth-api/zzalm;Lcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v3

    :cond_4c
    move v15, v1

    :goto_34
    move-object v1, v6

    move v14, v7

    goto/16 :goto_3c

    :cond_4d
    if-nez v11, :cond_3c

    move v3, v7

    move-object v5, v13

    .line 720
    invoke-static/range {v1 .. v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza(I[BIILcom/google/android/gms/internal/firebase-auth-api/zzalm;Lcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v5

    move v15, v1

    move v14, v3

    move-object v1, v6

    move v3, v5

    goto/16 :goto_3c

    :pswitch_19
    move/from16 v4, p4

    move-object/from16 v1, p6

    move v9, v2

    move-object v5, v6

    move-object v12, v8

    move/from16 v8, v19

    const/4 v3, 0x2

    move-object/from16 v2, p2

    move-object/from16 v19, v15

    move/from16 v15, v18

    move/from16 v18, v14

    move/from16 v14, v23

    if-ne v11, v3, :cond_50

    .line 694
    move-object v6, v5

    check-cast v6, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;

    .line 695
    invoke-static {v2, v14, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v3

    .line 696
    iget v5, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    add-int/2addr v5, v3

    :goto_35
    if-ge v3, v5, :cond_4e

    .line 698
    invoke-static {v2, v3, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v3

    .line 699
    iget-wide v10, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzb:J

    invoke-virtual {v6, v10, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zza(J)V

    goto :goto_35

    :cond_4e
    if-ne v3, v5, :cond_4f

    goto/16 :goto_3c

    .line 701
    :cond_4f
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzj()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    :cond_50
    if-nez v11, :cond_59

    .line 706
    move-object v6, v5

    check-cast v6, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;

    .line 707
    invoke-static {v2, v14, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v3

    .line 708
    iget-wide v10, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzb:J

    invoke-virtual {v6, v10, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zza(J)V

    :goto_36
    if-ge v3, v4, :cond_5a

    .line 710
    invoke-static {v2, v3, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v5

    .line 711
    iget v7, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-ne v15, v7, :cond_5a

    .line 712
    invoke-static {v2, v5, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v3

    .line 713
    iget-wide v10, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzb:J

    invoke-virtual {v6, v10, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zza(J)V

    goto :goto_36

    :pswitch_1a
    move/from16 v4, p4

    move-object/from16 v1, p6

    move v9, v2

    move-object v5, v6

    move-object v12, v8

    move/from16 v8, v19

    const/4 v3, 0x2

    move-object/from16 v2, p2

    move-object/from16 v19, v15

    move/from16 v15, v18

    move/from16 v18, v14

    move/from16 v14, v23

    if-ne v11, v3, :cond_54

    .line 665
    move-object v6, v5

    check-cast v6, Lcom/google/android/gms/internal/firebase-auth-api/zzald;

    .line 666
    invoke-static {v2, v14, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v3

    .line 667
    iget v5, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    add-int v7, v3, v5

    .line 669
    array-length v10, v2

    if-gt v7, v10, :cond_53

    .line 671
    invoke-virtual {v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzald;->size()I

    move-result v10

    div-int/lit8 v5, v5, 0x4

    add-int/2addr v10, v5

    invoke-virtual {v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzald;->zzc(I)V

    :goto_37
    if-ge v3, v7, :cond_51

    .line 673
    invoke-static {v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzb([BI)F

    move-result v5

    invoke-virtual {v6, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzald;->zza(F)V

    add-int/lit8 v3, v3, 0x4

    goto :goto_37

    :cond_51
    if-ne v3, v7, :cond_52

    goto/16 :goto_3c

    .line 676
    :cond_52
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzj()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    .line 670
    :cond_53
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzj()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    :cond_54
    const/4 v3, 0x5

    if-ne v11, v3, :cond_59

    .line 681
    move-object v6, v5

    check-cast v6, Lcom/google/android/gms/internal/firebase-auth-api/zzald;

    .line 682
    invoke-static {v2, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzb([BI)F

    move-result v3

    invoke-virtual {v6, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzald;->zza(F)V

    add-int/lit8 v3, v14, 0x4

    :goto_38
    if-ge v3, v4, :cond_5a

    .line 685
    invoke-static {v2, v3, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v5

    .line 686
    iget v7, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-ne v15, v7, :cond_5a

    .line 687
    invoke-static {v2, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzb([BI)F

    move-result v3

    invoke-virtual {v6, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzald;->zza(F)V

    add-int/lit8 v3, v5, 0x4

    goto :goto_38

    :pswitch_1b
    move/from16 v4, p4

    move-object/from16 v1, p6

    move v9, v2

    move-object v5, v6

    move-object v12, v8

    move/from16 v8, v19

    const/4 v3, 0x2

    move-object/from16 v2, p2

    move-object/from16 v19, v15

    move/from16 v15, v18

    move/from16 v18, v14

    move/from16 v14, v23

    if-ne v11, v3, :cond_58

    .line 636
    move-object v6, v5

    check-cast v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaks;

    .line 637
    invoke-static {v2, v14, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v3

    .line 638
    iget v5, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    add-int v7, v3, v5

    .line 640
    array-length v10, v2

    if-gt v7, v10, :cond_57

    .line 642
    invoke-virtual {v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzaks;->size()I

    move-result v10

    div-int/lit8 v5, v5, 0x8

    add-int/2addr v10, v5

    invoke-virtual {v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzaks;->zzc(I)V

    :goto_39
    if-ge v3, v7, :cond_55

    .line 644
    invoke-static {v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza([BI)D

    move-result-wide v10

    invoke-virtual {v6, v10, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzaks;->zza(D)V

    add-int/lit8 v3, v3, 0x8

    goto :goto_39

    :cond_55
    if-ne v3, v7, :cond_56

    goto :goto_3c

    .line 647
    :cond_56
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzj()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    .line 641
    :cond_57
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzj()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    :cond_58
    const/4 v3, 0x1

    if-ne v11, v3, :cond_59

    .line 652
    move-object v6, v5

    check-cast v6, Lcom/google/android/gms/internal/firebase-auth-api/zzaks;

    .line 653
    invoke-static {v2, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza([BI)D

    move-result-wide v10

    invoke-virtual {v6, v10, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzaks;->zza(D)V

    add-int/lit8 v3, v14, 0x8

    :goto_3a
    if-ge v3, v4, :cond_5a

    .line 656
    invoke-static {v2, v3, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v5

    .line 657
    iget v7, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-ne v15, v7, :cond_5a

    .line 658
    invoke-static {v2, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza([BI)D

    move-result-wide v10

    invoke-virtual {v6, v10, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzaks;->zza(D)V

    add-int/lit8 v3, v5, 0x8

    goto :goto_3a

    :cond_59
    :goto_3b
    move v3, v14

    :cond_5a
    :goto_3c
    if-ne v3, v14, :cond_5b

    move/from16 v10, p5

    move-object v14, v1

    move-object v1, v2

    goto/16 :goto_4b

    :cond_5b
    move-object v6, v1

    move v5, v4

    move v7, v8

    move v8, v9

    move/from16 v14, v18

    move-object/from16 v1, v19

    move/from16 v9, v27

    move v4, v3

    move-object v3, v2

    move-object v2, v12

    goto/16 :goto_0

    :cond_5c
    move v1, v12

    move-object v12, v8

    move v8, v1

    move-object/from16 v1, p6

    move/from16 v27, v9

    move-object/from16 v19, v15

    move/from16 v15, v18

    move v9, v2

    move/from16 v18, v14

    move-object/from16 v2, p2

    move v14, v4

    move/from16 v4, p4

    const/16 v10, 0x32

    if-ne v3, v10, :cond_68

    const/4 v10, 0x2

    if-ne v11, v10, :cond_67

    .line 964
    sget-object v3, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb:Lsun/misc/Unsafe;

    .line 965
    invoke-direct {v0, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzf(I)Ljava/lang/Object;

    move-result-object v5

    .line 966
    invoke-virtual {v3, v12, v6, v7}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v10

    .line 967
    iget-object v11, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    invoke-interface {v11, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzamf;->zzf(Ljava/lang/Object;)Z

    move-result v11

    if-eqz v11, :cond_5d

    .line 969
    iget-object v11, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    invoke-interface {v11, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamf;->zzb(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v11

    .line 970
    iget-object v13, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    invoke-interface {v13, v11, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzamf;->zza(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 971
    invoke-virtual {v3, v12, v6, v7, v11}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    move-object v10, v11

    .line 972
    :cond_5d
    iget-object v3, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    .line 973
    invoke-interface {v3, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamf;->zza(Ljava/lang/Object;)Lcom/google/android/gms/internal/firebase-auth-api/zzamd;

    move-result-object v7

    iget-object v3, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    .line 974
    invoke-interface {v3, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzamf;->zze(Ljava/lang/Object;)Ljava/util/Map;

    move-result-object v10

    .line 976
    invoke-static {v2, v14, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v3

    .line 977
    iget v5, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-ltz v5, :cond_66

    sub-int v6, v4, v3

    if-gt v5, v6, :cond_66

    add-int v11, v3, v5

    .line 981
    iget-object v5, v7, Lcom/google/android/gms/internal/firebase-auth-api/zzamd;->zzb:Ljava/lang/Object;

    .line 982
    iget-object v6, v7, Lcom/google/android/gms/internal/firebase-auth-api/zzamd;->zzd:Ljava/lang/Object;

    move-object v13, v5

    :goto_3d
    if-ge v3, v11, :cond_63

    add-int/lit8 v5, v3, 0x1

    .line 984
    aget-byte v3, v2, v3

    if-gez v3, :cond_5e

    .line 986
    invoke-static {v3, v2, v5, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza(I[BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v5

    .line 987
    iget v3, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    :cond_5e
    ushr-int/lit8 v1, v3, 0x3

    and-int/lit8 v2, v3, 0x7

    const/4 v4, 0x1

    if-eq v1, v4, :cond_61

    const/4 v4, 0x2

    if-eq v1, v4, :cond_60

    :cond_5f
    move-object/from16 v1, p2

    move/from16 v4, p4

    move v2, v5

    move-object/from16 v5, p6

    goto :goto_3e

    .line 996
    :cond_60
    iget-object v1, v7, Lcom/google/android/gms/internal/firebase-auth-api/zzamd;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzaog;

    invoke-virtual {v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzaog;->zza()I

    move-result v1

    if-ne v2, v1, :cond_5f

    move/from16 v26, v4

    .line 997
    iget-object v4, v7, Lcom/google/android/gms/internal/firebase-auth-api/zzamd;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzaog;

    iget-object v1, v7, Lcom/google/android/gms/internal/firebase-auth-api/zzamd;->zzd:Ljava/lang/Object;

    .line 998
    invoke-virtual {v1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v1

    move/from16 v3, p4

    move-object/from16 v6, p6

    move v2, v5

    move-object v5, v1

    move-object/from16 v1, p2

    .line 999
    invoke-static/range {v1 .. v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza([BIILcom/google/android/gms/internal/firebase-auth-api/zzaog;Ljava/lang/Class;Lcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v2

    move-object v1, v6

    .line 1000
    iget-object v6, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzc:Ljava/lang/Object;

    move/from16 v4, p4

    move v3, v2

    move-object/from16 v2, p2

    goto :goto_3d

    :cond_61
    move-object/from16 v1, p6

    .line 991
    iget-object v4, v7, Lcom/google/android/gms/internal/firebase-auth-api/zzamd;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzaog;

    invoke-virtual {v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzaog;->zza()I

    move-result v4

    if-ne v2, v4, :cond_62

    .line 992
    iget-object v4, v7, Lcom/google/android/gms/internal/firebase-auth-api/zzamd;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzaog;

    move v2, v5

    const/4 v5, 0x0

    move/from16 v3, p4

    move-object v13, v6

    move-object v6, v1

    move-object/from16 v1, p2

    .line 993
    invoke-static/range {v1 .. v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza([BIILcom/google/android/gms/internal/firebase-auth-api/zzaog;Ljava/lang/Class;Lcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v2

    move v4, v3

    move-object v5, v6

    .line 994
    iget-object v3, v5, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzc:Ljava/lang/Object;

    move-object v6, v13

    move-object v13, v3

    move v3, v2

    goto :goto_3f

    :cond_62
    move/from16 v4, p4

    move v2, v5

    move-object v5, v1

    move-object/from16 v1, p2

    .line 1002
    :goto_3e
    invoke-static {v3, v1, v2, v4, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza(I[BIILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v3

    :goto_3f
    move-object v2, v1

    move-object v1, v5

    goto :goto_3d

    :cond_63
    move-object v5, v1

    move-object v1, v2

    if-ne v3, v11, :cond_65

    .line 1006
    invoke-interface {v10, v13, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    if-ne v11, v14, :cond_64

    move/from16 v10, p5

    move-object v14, v5

    move v3, v11

    goto/16 :goto_4b

    :cond_64
    move-object v3, v1

    move-object v6, v5

    move v7, v8

    move v8, v9

    move-object v2, v12

    move/from16 v14, v18

    move-object/from16 v1, v19

    move/from16 v9, v27

    move v5, v4

    move v4, v11

    goto/16 :goto_0

    .line 1005
    :cond_65
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzg()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    .line 979
    :cond_66
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzj()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    :cond_67
    move-object v5, v1

    move-object v1, v2

    :goto_40
    move/from16 v10, p5

    move v3, v14

    move-object v14, v5

    goto/16 :goto_4b

    :cond_68
    move-object v1, v2

    .line 1014
    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb:Lsun/misc/Unsafe;

    add-int/lit8 v10, v9, 0x2

    .line 1015
    aget v10, v20, v10

    const v16, 0xfffff

    and-int v10, v10, v16

    move/from16 v20, v3

    int-to-long v3, v10

    packed-switch v20, :pswitch_data_2

    :cond_69
    move/from16 v20, v9

    move v9, v14

    move-object/from16 v14, p6

    goto/16 :goto_49

    :pswitch_1c
    const/4 v10, 0x3

    if-ne v11, v10, :cond_69

    .line 1087
    invoke-direct {v0, v12, v8, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;II)Ljava/lang/Object;

    move-result-object v1

    and-int/lit8 v2, v15, -0x8

    or-int/lit8 v6, v2, 0x4

    .line 1090
    invoke-direct {v0, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v2

    move-object/from16 v3, p2

    move/from16 v5, p4

    move-object/from16 v7, p6

    move v4, v14

    .line 1091
    invoke-static/range {v1 .. v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza(Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;[BIIILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v2

    move-object v5, v3

    move-object v3, v1

    move-object v1, v5

    move-object v5, v7

    .line 1092
    invoke-direct {v0, v12, v8, v9, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IILjava/lang/Object;)V

    move v4, v2

    goto :goto_41

    :pswitch_1d
    move-object/from16 v5, p6

    if-nez v11, :cond_6c

    .line 1083
    invoke-static {v1, v14, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v10

    move/from16 p3, v10

    .line 1084
    iget-wide v10, v5, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzb:J

    invoke-static {v10, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzakh;->zza(J)J

    move-result-wide v10

    invoke-static {v10, v11}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v10

    invoke-virtual {v2, v12, v6, v7, v10}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1085
    invoke-virtual {v2, v12, v3, v4, v8}, Lsun/misc/Unsafe;->putInt(Ljava/lang/Object;JI)V

    move/from16 v4, p3

    :goto_41
    move/from16 v20, v9

    goto :goto_44

    :pswitch_1e
    move-object/from16 v5, p6

    if-nez v11, :cond_6c

    .line 1079
    invoke-static {v1, v14, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v10

    .line 1080
    iget v11, v5, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    invoke-static {v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzakh;->zza(I)I

    move-result v11

    invoke-static {v11}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v11

    invoke-virtual {v2, v12, v6, v7, v11}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1081
    invoke-virtual {v2, v12, v3, v4, v8}, Lsun/misc/Unsafe;->putInt(Ljava/lang/Object;JI)V

    goto :goto_43

    :pswitch_1f
    move-object/from16 v5, p6

    if-nez v11, :cond_6c

    .line 1070
    invoke-static {v1, v14, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v10

    .line 1071
    iget v11, v5, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    .line 1072
    invoke-direct {v0, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(I)Lcom/google/android/gms/internal/firebase-auth-api/zzalj;

    move-result-object v13

    if-eqz v13, :cond_6b

    .line 1073
    invoke-interface {v13, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzalj;->zza(I)Z

    move-result v13

    if-eqz v13, :cond_6a

    goto :goto_42

    .line 1076
    :cond_6a
    invoke-static {v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;)Lcom/google/android/gms/internal/firebase-auth-api/zzanx;

    move-result-object v2

    int-to-long v3, v11

    invoke-static {v3, v4}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v3

    invoke-virtual {v2, v15, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanx;->zza(ILjava/lang/Object;)V

    goto :goto_43

    .line 1074
    :cond_6b
    :goto_42
    invoke-static {v11}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v11

    invoke-virtual {v2, v12, v6, v7, v11}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1075
    invoke-virtual {v2, v12, v3, v4, v8}, Lsun/misc/Unsafe;->putInt(Ljava/lang/Object;JI)V

    goto :goto_43

    :pswitch_20
    move-object/from16 v5, p6

    const/4 v10, 0x2

    if-ne v11, v10, :cond_6c

    .line 1066
    invoke-static {v1, v14, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v10

    .line 1067
    iget-object v11, v5, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzc:Ljava/lang/Object;

    invoke-virtual {v2, v12, v6, v7, v11}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1068
    invoke-virtual {v2, v12, v3, v4, v8}, Lsun/misc/Unsafe;->putInt(Ljava/lang/Object;JI)V

    :goto_43
    move/from16 v20, v9

    move v4, v10

    :goto_44
    move v9, v14

    move-object v14, v5

    goto/16 :goto_4a

    :cond_6c
    move/from16 v20, v9

    move v9, v14

    move-object v14, v5

    goto/16 :goto_49

    :pswitch_21
    move-object/from16 v5, p6

    const/4 v10, 0x2

    if-ne v11, v10, :cond_6d

    .line 1059
    invoke-direct {v0, v12, v8, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;II)Ljava/lang/Object;

    move-result-object v1

    .line 1061
    invoke-direct {v0, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v2

    move-object/from16 v3, p2

    move-object v6, v5

    move v4, v14

    move/from16 v5, p4

    .line 1062
    invoke-static/range {v1 .. v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza(Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;[BIILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v2

    move-object v14, v3

    move-object v3, v1

    move-object v1, v14

    move-object v14, v6

    .line 1063
    invoke-direct {v0, v12, v8, v9, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IILjava/lang/Object;)V

    move/from16 v20, v9

    move v9, v4

    move v4, v2

    goto/16 :goto_4a

    :cond_6d
    move v4, v14

    move-object v14, v5

    move/from16 v20, v9

    move v9, v4

    goto/16 :goto_49

    :pswitch_22
    move/from16 v20, v9

    move v9, v14

    const/4 v10, 0x2

    move-object/from16 v14, p6

    if-ne v11, v10, :cond_72

    .line 1046
    invoke-static {v1, v9, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v10

    .line 1047
    iget v11, v14, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    if-nez v11, :cond_6e

    .line 1049
    invoke-virtual {v2, v12, v6, v7, v5}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    goto :goto_46

    :cond_6e
    const/high16 v5, 0x20000000

    and-int/2addr v5, v13

    if-eqz v5, :cond_70

    add-int v5, v10, v11

    .line 1051
    invoke-static {v1, v10, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaoa;->zzc([BII)Z

    move-result v5

    if-eqz v5, :cond_6f

    goto :goto_45

    .line 1052
    :cond_6f
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzd()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    .line 1053
    :cond_70
    :goto_45
    new-instance v5, Ljava/lang/String;

    sget-object v13, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza:Ljava/nio/charset/Charset;

    invoke-direct {v5, v1, v10, v11, v13}, Ljava/lang/String;-><init>([BIILjava/nio/charset/Charset;)V

    .line 1054
    invoke-virtual {v2, v12, v6, v7, v5}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    add-int/2addr v10, v11

    .line 1056
    :goto_46
    invoke-virtual {v2, v12, v3, v4, v8}, Lsun/misc/Unsafe;->putInt(Ljava/lang/Object;JI)V

    move v4, v10

    goto/16 :goto_4a

    :pswitch_23
    move/from16 v20, v9

    move v9, v14

    move-object/from16 v14, p6

    if-nez v11, :cond_72

    .line 1042
    invoke-static {v1, v9, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v5

    .line 1043
    iget-wide v10, v14, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzb:J

    cmp-long v10, v10, v21

    if-eqz v10, :cond_71

    const/16 v28, 0x1

    goto :goto_47

    :cond_71
    const/16 v28, 0x0

    :goto_47
    invoke-static/range {v28 .. v28}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v10

    invoke-virtual {v2, v12, v6, v7, v10}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1044
    invoke-virtual {v2, v12, v3, v4, v8}, Lsun/misc/Unsafe;->putInt(Ljava/lang/Object;JI)V

    goto/16 :goto_48

    :pswitch_24
    move/from16 v20, v9

    move v9, v14

    const/4 v5, 0x5

    move-object/from16 v14, p6

    if-ne v11, v5, :cond_72

    .line 1038
    invoke-static {v1, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BI)I

    move-result v5

    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    invoke-virtual {v2, v12, v6, v7, v5}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    add-int/lit8 v5, v9, 0x4

    .line 1040
    invoke-virtual {v2, v12, v3, v4, v8}, Lsun/misc/Unsafe;->putInt(Ljava/lang/Object;JI)V

    goto/16 :goto_48

    :pswitch_25
    move/from16 v20, v9

    move v9, v14

    const/4 v5, 0x1

    move-object/from16 v14, p6

    if-ne v11, v5, :cond_72

    .line 1034
    invoke-static {v1, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BI)J

    move-result-wide v10

    invoke-static {v10, v11}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v5

    invoke-virtual {v2, v12, v6, v7, v5}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    add-int/lit8 v5, v9, 0x8

    .line 1036
    invoke-virtual {v2, v12, v3, v4, v8}, Lsun/misc/Unsafe;->putInt(Ljava/lang/Object;JI)V

    goto :goto_48

    :pswitch_26
    move/from16 v20, v9

    move v9, v14

    move-object/from16 v14, p6

    if-nez v11, :cond_72

    .line 1030
    invoke-static {v1, v9, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzc([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v5

    .line 1031
    iget v10, v14, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zza:I

    invoke-static {v10}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v10

    invoke-virtual {v2, v12, v6, v7, v10}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1032
    invoke-virtual {v2, v12, v3, v4, v8}, Lsun/misc/Unsafe;->putInt(Ljava/lang/Object;JI)V

    goto :goto_48

    :pswitch_27
    move/from16 v20, v9

    move v9, v14

    move-object/from16 v14, p6

    if-nez v11, :cond_72

    .line 1026
    invoke-static {v1, v9, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzd([BILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v5

    .line 1027
    iget-wide v10, v14, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzb:J

    invoke-static {v10, v11}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v10

    invoke-virtual {v2, v12, v6, v7, v10}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1028
    invoke-virtual {v2, v12, v3, v4, v8}, Lsun/misc/Unsafe;->putInt(Ljava/lang/Object;JI)V

    goto :goto_48

    :pswitch_28
    move/from16 v20, v9

    move v9, v14

    const/4 v5, 0x5

    move-object/from16 v14, p6

    if-ne v11, v5, :cond_72

    .line 1022
    invoke-static {v1, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zzb([BI)F

    move-result v5

    invoke-static {v5}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v5

    invoke-virtual {v2, v12, v6, v7, v5}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    add-int/lit8 v5, v9, 0x4

    .line 1024
    invoke-virtual {v2, v12, v3, v4, v8}, Lsun/misc/Unsafe;->putInt(Ljava/lang/Object;JI)V

    goto :goto_48

    :pswitch_29
    move/from16 v20, v9

    move v9, v14

    const/4 v5, 0x1

    move-object/from16 v14, p6

    if-ne v11, v5, :cond_72

    .line 1018
    invoke-static {v1, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza([BI)D

    move-result-wide v10

    invoke-static {v10, v11}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;

    move-result-object v5

    invoke-virtual {v2, v12, v6, v7, v5}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    add-int/lit8 v5, v9, 0x8

    .line 1020
    invoke-virtual {v2, v12, v3, v4, v8}, Lsun/misc/Unsafe;->putInt(Ljava/lang/Object;JI)V

    :goto_48
    move v4, v5

    goto :goto_4a

    :cond_72
    :goto_49
    move v4, v9

    :goto_4a
    move/from16 v10, p5

    if-ne v4, v9, :cond_76

    move v3, v4

    move/from16 v9, v20

    :goto_4b
    if-ne v15, v10, :cond_74

    if-nez v10, :cond_73

    goto :goto_4c

    :cond_73
    move/from16 v13, p4

    move v6, v3

    move-object/from16 v1, v19

    move/from16 v14, v18

    move/from16 v9, v27

    goto/16 :goto_4d

    .line 1097
    :cond_74
    :goto_4c
    iget-boolean v2, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzh:Z

    if-eqz v2, :cond_75

    iget-object v2, v14, Lcom/google/android/gms/internal/firebase-auth-api/zzaju;->zzd:Lcom/google/android/gms/internal/firebase-auth-api/zzaku;

    .line 1098
    sget-object v4, Lcom/google/android/gms/internal/firebase-auth-api/zzaku;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzaku;

    if-eq v2, v4, :cond_75

    .line 1100
    iget-object v6, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzg:Lcom/google/android/gms/internal/firebase-auth-api/zzamm;

    iget-object v7, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzp:Lcom/google/android/gms/internal/firebase-auth-api/zzanu;

    move/from16 v4, p4

    move-object v2, v1

    move v11, v8

    move-object v5, v12

    move-object v8, v14

    move v1, v15

    .line 1101
    invoke-static/range {v1 .. v8}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza(I[BIILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzamm;Lcom/google/android/gms/internal/firebase-auth-api/zzanu;Lcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v3

    move-object/from16 v6, p6

    move v4, v3

    move-object v2, v5

    move v8, v9

    move v7, v11

    move/from16 v14, v18

    move-object/from16 v1, v19

    move/from16 v9, v27

    move-object/from16 v3, p2

    goto/16 :goto_13

    :cond_75
    move v11, v8

    move v1, v15

    .line 1103
    invoke-static {v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;)Lcom/google/android/gms/internal/firebase-auth-api/zzanx;

    move-result-object v5

    move-object/from16 v2, p2

    move/from16 v4, p4

    move-object/from16 v6, p6

    .line 1104
    invoke-static/range {v1 .. v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzajr;->zza(I[BIILcom/google/android/gms/internal/firebase-auth-api/zzanx;Lcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    move-result v3

    move v15, v1

    move v5, v4

    move v8, v9

    move v7, v11

    move-object v2, v12

    move/from16 v14, v18

    move-object/from16 v1, v19

    move/from16 v9, v27

    move v4, v3

    move-object/from16 v3, p2

    goto/16 :goto_0

    :cond_76
    move v11, v8

    move v1, v15

    move-object/from16 v3, p2

    move/from16 v5, p4

    move-object/from16 v6, p6

    move v7, v11

    move-object v2, v12

    move/from16 v14, v18

    move-object/from16 v1, v19

    move/from16 v8, v20

    move/from16 v9, v27

    goto/16 :goto_0

    :cond_77
    move/from16 v10, p5

    move-object v12, v2

    move v13, v5

    move/from16 v27, v9

    move/from16 v18, v14

    move v6, v4

    :goto_4d
    const v8, 0xfffff

    if-eq v9, v8, :cond_78

    int-to-long v2, v9

    .line 1107
    invoke-virtual {v1, v12, v2, v3, v14}, Lsun/misc/Unsafe;->putInt(Ljava/lang/Object;JI)V

    .line 1109
    :cond_78
    iget v1, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzl:I

    const/4 v2, 0x0

    move v7, v1

    move-object v3, v2

    :goto_4e
    iget v1, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzm:I

    if-ge v7, v1, :cond_79

    .line 1110
    iget-object v1, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzk:[I

    aget v2, v1, v7

    iget-object v4, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzp:Lcom/google/android/gms/internal/firebase-auth-api/zzanu;

    move-object/from16 v5, p1

    move-object v1, v12

    .line 1111
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanu;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    move-object v3, v2

    check-cast v3, Lcom/google/android/gms/internal/firebase-auth-api/zzanx;

    add-int/lit8 v7, v7, 0x1

    goto :goto_4e

    :cond_79
    move-object v1, v12

    if-eqz v3, :cond_7a

    .line 1114
    iget-object v2, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzp:Lcom/google/android/gms/internal/firebase-auth-api/zzanu;

    .line 1115
    invoke-virtual {v2, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zzb(Ljava/lang/Object;Ljava/lang/Object;)V

    :cond_7a
    if-nez v10, :cond_7c

    if-ne v6, v13, :cond_7b

    goto :goto_4f

    .line 1118
    :cond_7b
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzg()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    :cond_7c
    if-gt v6, v13, :cond_7d

    if-ne v15, v10, :cond_7d

    :goto_4f
    return v6

    .line 1120
    :cond_7d
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzall;->zzg()Lcom/google/android/gms/internal/firebase-auth-api/zzall;

    move-result-object v1

    throw v1

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_d
        :pswitch_c
        :pswitch_b
        :pswitch_b
        :pswitch_a
        :pswitch_9
        :pswitch_8
        :pswitch_7
        :pswitch_6
        :pswitch_5
        :pswitch_4
        :pswitch_a
        :pswitch_3
        :pswitch_8
        :pswitch_9
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch

    :pswitch_data_1
    .packed-switch 0x12
        :pswitch_1b
        :pswitch_1a
        :pswitch_19
        :pswitch_19
        :pswitch_18
        :pswitch_17
        :pswitch_16
        :pswitch_15
        :pswitch_14
        :pswitch_13
        :pswitch_12
        :pswitch_18
        :pswitch_11
        :pswitch_16
        :pswitch_17
        :pswitch_10
        :pswitch_f
        :pswitch_1b
        :pswitch_1a
        :pswitch_19
        :pswitch_19
        :pswitch_18
        :pswitch_17
        :pswitch_16
        :pswitch_15
        :pswitch_18
        :pswitch_11
        :pswitch_16
        :pswitch_17
        :pswitch_10
        :pswitch_f
        :pswitch_e
    .end packed-switch

    :pswitch_data_2
    .packed-switch 0x33
        :pswitch_29
        :pswitch_28
        :pswitch_27
        :pswitch_27
        :pswitch_26
        :pswitch_25
        :pswitch_24
        :pswitch_23
        :pswitch_22
        :pswitch_21
        :pswitch_20
        :pswitch_26
        :pswitch_1f
        :pswitch_24
        :pswitch_25
        :pswitch_1e
        :pswitch_1d
        :pswitch_1c
    .end packed-switch
.end method

.method public final zza()Ljava/lang/Object;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()TT;"
        }
    .end annotation

    .line 1435
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzn:Lcom/google/android/gms/internal/firebase-auth-api/zzamu;

    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzg:Lcom/google/android/gms/internal/firebase-auth-api/zzamm;

    invoke-interface {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamu;->zza(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    return-object v0
.end method

.method public final zza(Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanc;Lcom/google/android/gms/internal/firebase-auth-api/zzaku;)V
    .locals 18
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzanc;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzaku;",
            ")V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    move-object/from16 v1, p0

    move-object/from16 v4, p3

    .line 1589
    invoke-virtual {v4}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    .line 1590
    invoke-static/range {p1 .. p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzf(Ljava/lang/Object;)V

    .line 1591
    iget-object v5, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzp:Lcom/google/android/gms/internal/firebase-auth-api/zzanu;

    iget-object v0, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzq:Lcom/google/android/gms/internal/firebase-auth-api/zzakw;

    const/4 v6, 0x0

    const/4 v7, 0x0

    .line 1594
    :goto_0
    :try_start_0
    invoke-interface/range {p2 .. p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzc()I

    move-result v2

    .line 1595
    invoke-direct {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(I)I

    move-result v3
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_7

    const/4 v9, 0x0

    if-gez v3, :cond_9

    const v3, 0x7fffffff

    if-ne v2, v3, :cond_2

    .line 1598
    iget v0, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzl:I

    move-object v4, v6

    :goto_1
    iget v2, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzm:I

    if-ge v0, v2, :cond_0

    .line 1599
    iget-object v2, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzk:[I

    aget v3, v2, v0

    move-object/from16 v6, p1

    move-object/from16 v2, p1

    .line 1600
    invoke-direct/range {v1 .. v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanu;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    move-object v10, v1

    move-object v1, v2

    add-int/lit8 v0, v0, 0x1

    move-object v1, v10

    goto :goto_1

    :cond_0
    move-object v10, v1

    move-object/from16 v1, p1

    if-eqz v4, :cond_1

    .line 1603
    invoke-virtual {v5, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zzb(Ljava/lang/Object;Ljava/lang/Object;)V

    :cond_1
    :goto_2
    move-object v1, v10

    goto/16 :goto_12

    :cond_2
    move-object v10, v1

    move-object/from16 v1, p1

    .line 1605
    :try_start_1
    iget-boolean v3, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzh:Z

    if-nez v3, :cond_3

    const/4 v3, 0x0

    goto :goto_3

    .line 1607
    :cond_3
    iget-object v3, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzg:Lcom/google/android/gms/internal/firebase-auth-api/zzamm;

    invoke-virtual {v0, v4, v3, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakw;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzaku;Lcom/google/android/gms/internal/firebase-auth-api/zzamm;I)Ljava/lang/Object;

    move-result-object v2

    move-object v3, v2

    :goto_3
    if-eqz v3, :cond_5

    if-nez v7, :cond_4

    .line 1610
    invoke-virtual {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakw;->zzb(Ljava/lang/Object;)Lcom/google/android/gms/internal/firebase-auth-api/zzakx;

    move-result-object v7
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_6

    :cond_4
    move-object v2, v7

    move-object v7, v5

    move-object v5, v2

    move-object/from16 v2, p2

    .line 1612
    :try_start_2
    invoke-virtual/range {v0 .. v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzakw;->zza(Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanc;Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzaku;Lcom/google/android/gms/internal/firebase-auth-api/zzakx;Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanu;)Ljava/lang/Object;

    move-result-object v6
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    move-object v11, v7

    move-object v7, v5

    move-object v5, v11

    move-object v12, v0

    move-object v0, v2

    move-object v11, v4

    move-object v2, v1

    goto/16 :goto_a

    :catchall_0
    move-exception v0

    move-object v2, v1

    move-object v5, v7

    goto/16 :goto_14

    :cond_5
    move-object v12, v0

    move-object v2, v1

    move-object v11, v4

    move-object/from16 v0, p2

    .line 1614
    :try_start_3
    invoke-virtual {v5, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzanc;)Z
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_2

    if-nez v6, :cond_6

    .line 1616
    :try_start_4
    invoke-virtual {v5, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zzc(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v6
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_1

    goto :goto_4

    :catchall_1
    move-exception v0

    goto/16 :goto_14

    .line 1617
    :cond_6
    :goto_4
    :try_start_5
    invoke-virtual {v5, v6, v0, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zza(Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanc;I)Z

    move-result v1
    :try_end_5
    .catchall {:try_start_5 .. :try_end_5} :catchall_2

    if-nez v1, :cond_8

    .line 1618
    iget v0, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzl:I

    move-object v4, v6

    :goto_5
    iget v1, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzm:I

    if-ge v0, v1, :cond_7

    .line 1619
    iget-object v1, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzk:[I

    aget v3, v1, v0

    move-object/from16 v6, p1

    move-object v1, v10

    .line 1620
    invoke-direct/range {v1 .. v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanu;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    move-object v1, v2

    add-int/lit8 v0, v0, 0x1

    goto :goto_5

    :cond_7
    move-object v1, v2

    if-eqz v4, :cond_1

    .line 1623
    invoke-virtual {v5, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zzb(Ljava/lang/Object;Ljava/lang/Object;)V

    goto :goto_2

    :cond_8
    move-object v1, v2

    goto/16 :goto_a

    :catchall_2
    move-exception v0

    move-object v1, v2

    goto/16 :goto_14

    :cond_9
    move-object v12, v0

    move-object v10, v1

    move-object v11, v4

    move-object/from16 v1, p1

    move-object/from16 v0, p2

    .line 1625
    :try_start_6
    invoke-direct {v10, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(I)I

    move-result v4
    :try_end_6
    .catchall {:try_start_6 .. :try_end_6} :catchall_6

    const/high16 v13, 0xff00000

    and-int/2addr v13, v4

    ushr-int/lit8 v13, v13, 0x14

    const v14, 0xfffff

    packed-switch v13, :pswitch_data_0

    if-nez v6, :cond_11

    .line 2033
    :try_start_7
    invoke-virtual {v5, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zzc(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v6

    goto/16 :goto_d

    .line 2026
    :pswitch_0
    invoke-direct {v10, v1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;II)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Lcom/google/android/gms/internal/firebase-auth-api/zzamm;

    .line 2028
    invoke-direct {v10, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v13

    .line 2029
    invoke-interface {v0, v4, v13, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zza(Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;Lcom/google/android/gms/internal/firebase-auth-api/zzaku;)V

    .line 2030
    invoke-direct {v10, v1, v2, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IILjava/lang/Object;)V

    goto/16 :goto_a

    :pswitch_1
    and-int/2addr v4, v14

    int-to-long v13, v4

    .line 2021
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzn()J

    move-result-wide v15

    invoke-static/range {v15 .. v16}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v4

    .line 2022
    invoke-static {v1, v13, v14, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 2023
    invoke-direct {v10, v1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    goto/16 :goto_a

    :pswitch_2
    and-int/2addr v4, v14

    int-to-long v13, v4

    .line 2015
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzi()I

    move-result v4

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v4

    .line 2016
    invoke-static {v1, v13, v14, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 2017
    invoke-direct {v10, v1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    goto/16 :goto_a

    :pswitch_3
    and-int/2addr v4, v14

    int-to-long v13, v4

    .line 2009
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzm()J

    move-result-wide v15

    invoke-static/range {v15 .. v16}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v4

    .line 2010
    invoke-static {v1, v13, v14, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 2011
    invoke-direct {v10, v1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    goto/16 :goto_a

    :pswitch_4
    and-int/2addr v4, v14

    int-to-long v13, v4

    .line 2003
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzh()I

    move-result v4

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v4

    .line 2004
    invoke-static {v1, v13, v14, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 2005
    invoke-direct {v10, v1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    goto/16 :goto_a

    .line 1991
    :pswitch_5
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zze()I

    move-result v13

    .line 1992
    invoke-direct {v10, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(I)Lcom/google/android/gms/internal/firebase-auth-api/zzalj;

    move-result-object v15

    if-eqz v15, :cond_b

    .line 1993
    invoke-interface {v15, v13}, Lcom/google/android/gms/internal/firebase-auth-api/zzalj;->zza(I)Z

    move-result v15

    if-eqz v15, :cond_a

    goto :goto_6

    .line 1999
    :cond_a
    invoke-static {v1, v2, v13, v6, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(Ljava/lang/Object;IILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanu;)Ljava/lang/Object;

    move-result-object v6

    goto/16 :goto_a

    :cond_b
    :goto_6
    and-int/2addr v4, v14

    int-to-long v14, v4

    .line 1996
    invoke-static {v13}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v4

    invoke-static {v1, v14, v15, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1997
    invoke-direct {v10, v1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    goto/16 :goto_a

    :pswitch_6
    and-int/2addr v4, v14

    int-to-long v13, v4

    .line 1987
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzj()I

    move-result v4

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v4

    .line 1988
    invoke-static {v1, v13, v14, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1989
    invoke-direct {v10, v1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    goto/16 :goto_a

    :pswitch_7
    and-int/2addr v4, v14

    int-to-long v13, v4

    .line 1982
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzp()Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    move-result-object v4

    invoke-static {v1, v13, v14, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1983
    invoke-direct {v10, v1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    goto/16 :goto_a

    .line 1974
    :pswitch_8
    invoke-direct {v10, v1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;II)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Lcom/google/android/gms/internal/firebase-auth-api/zzamm;

    .line 1976
    invoke-direct {v10, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v13

    .line 1977
    invoke-interface {v0, v4, v13, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzb(Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;Lcom/google/android/gms/internal/firebase-auth-api/zzaku;)V

    .line 1978
    invoke-direct {v10, v1, v2, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IILjava/lang/Object;)V

    goto/16 :goto_a

    .line 1970
    :pswitch_9
    invoke-direct {v10, v1, v4, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;ILcom/google/android/gms/internal/firebase-auth-api/zzanc;)V

    .line 1971
    invoke-direct {v10, v1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    goto/16 :goto_a

    :pswitch_a
    and-int/2addr v4, v14

    int-to-long v13, v4

    .line 1966
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzs()Z

    move-result v4

    invoke-static {v4}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v4

    .line 1967
    invoke-static {v1, v13, v14, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1968
    invoke-direct {v10, v1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    goto/16 :goto_a

    :pswitch_b
    and-int/2addr v4, v14

    int-to-long v13, v4

    .line 1960
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzf()I

    move-result v4

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v4

    .line 1961
    invoke-static {v1, v13, v14, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1962
    invoke-direct {v10, v1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    goto/16 :goto_a

    :pswitch_c
    and-int/2addr v4, v14

    int-to-long v13, v4

    .line 1954
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzk()J

    move-result-wide v15

    invoke-static/range {v15 .. v16}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v4

    .line 1955
    invoke-static {v1, v13, v14, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1956
    invoke-direct {v10, v1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    goto/16 :goto_a

    :pswitch_d
    and-int/2addr v4, v14

    int-to-long v13, v4

    .line 1948
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzg()I

    move-result v4

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v4

    .line 1949
    invoke-static {v1, v13, v14, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1950
    invoke-direct {v10, v1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    goto/16 :goto_a

    :pswitch_e
    and-int/2addr v4, v14

    int-to-long v13, v4

    .line 1942
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzo()J

    move-result-wide v15

    invoke-static/range {v15 .. v16}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v4

    .line 1943
    invoke-static {v1, v13, v14, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1944
    invoke-direct {v10, v1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    goto/16 :goto_a

    :pswitch_f
    and-int/2addr v4, v14

    int-to-long v13, v4

    .line 1936
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzl()J

    move-result-wide v15

    invoke-static/range {v15 .. v16}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v4

    .line 1937
    invoke-static {v1, v13, v14, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1938
    invoke-direct {v10, v1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    goto/16 :goto_a

    :pswitch_10
    and-int/2addr v4, v14

    int-to-long v13, v4

    .line 1930
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzb()F

    move-result v4

    invoke-static {v4}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object v4

    .line 1931
    invoke-static {v1, v13, v14, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1932
    invoke-direct {v10, v1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    goto/16 :goto_a

    :pswitch_11
    and-int/2addr v4, v14

    int-to-long v13, v4

    .line 1924
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zza()D

    move-result-wide v15

    invoke-static/range {v15 .. v16}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;

    move-result-object v4

    .line 1925
    invoke-static {v1, v13, v14, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1926
    invoke-direct {v10, v1, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    goto/16 :goto_a

    .line 1904
    :pswitch_12
    invoke-direct {v10, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzf(I)Ljava/lang/Object;

    move-result-object v2

    .line 1905
    invoke-direct {v10, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(I)I

    move-result v3

    and-int/2addr v3, v14

    int-to-long v3, v3

    .line 1908
    invoke-static {v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v13

    if-nez v13, :cond_c

    .line 1910
    iget-object v13, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    invoke-interface {v13, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamf;->zzb(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v13

    .line 1911
    invoke-static {v1, v3, v4, v13}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    goto :goto_7

    .line 1912
    :cond_c
    iget-object v14, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    invoke-interface {v14, v13}, Lcom/google/android/gms/internal/firebase-auth-api/zzamf;->zzf(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_d

    .line 1914
    iget-object v14, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    invoke-interface {v14, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamf;->zzb(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v14

    .line 1915
    iget-object v15, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    invoke-interface {v15, v14, v13}, Lcom/google/android/gms/internal/firebase-auth-api/zzamf;->zza(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1916
    invoke-static {v1, v3, v4, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    move-object v13, v14

    .line 1917
    :cond_d
    :goto_7
    iget-object v3, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    .line 1918
    invoke-interface {v3, v13}, Lcom/google/android/gms/internal/firebase-auth-api/zzamf;->zze(Ljava/lang/Object;)Ljava/util/Map;

    move-result-object v3

    iget-object v4, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    .line 1919
    invoke-interface {v4, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamf;->zza(Ljava/lang/Object;)Lcom/google/android/gms/internal/firebase-auth-api/zzamd;

    move-result-object v2

    .line 1920
    invoke-interface {v0, v3, v2, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zza(Ljava/util/Map;Lcom/google/android/gms/internal/firebase-auth-api/zzamd;Lcom/google/android/gms/internal/firebase-auth-api/zzaku;)V

    goto/16 :goto_a

    :pswitch_13
    and-int v2, v4, v14

    int-to-long v13, v2

    .line 1898
    invoke-direct {v10, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v2

    .line 1900
    iget-object v3, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    .line 1901
    invoke-interface {v3, v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v3

    .line 1902
    invoke-interface {v0, v3, v2, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zza(Ljava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;Lcom/google/android/gms/internal/firebase-auth-api/zzaku;)V

    goto/16 :goto_a

    .line 1890
    :pswitch_14
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1892
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1893
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzm(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1885
    :pswitch_15
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1887
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1888
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzl(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1880
    :pswitch_16
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1882
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1883
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzk(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1875
    :pswitch_17
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1877
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1878
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzj(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1867
    :pswitch_18
    iget-object v13, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int/2addr v4, v14

    int-to-long v14, v4

    .line 1869
    invoke-interface {v13, v1, v14, v15}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v4

    .line 1870
    invoke-interface {v0, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzd(Ljava/util/List;)V

    move-object v13, v4

    .line 1872
    invoke-direct {v10, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(I)Lcom/google/android/gms/internal/firebase-auth-api/zzalj;

    move-result-object v4
    :try_end_7
    .catch Lcom/google/android/gms/internal/firebase-auth-api/zzalo; {:try_start_7 .. :try_end_7} :catch_1
    .catchall {:try_start_7 .. :try_end_7} :catchall_6

    move-object v3, v6

    move-object v6, v5

    move-object v5, v3

    move-object v3, v13

    .line 1873
    :try_start_8
    invoke-static/range {v1 .. v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(Ljava/lang/Object;ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzalj;Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanu;)Ljava/lang/Object;

    move-result-object v2
    :try_end_8
    .catch Lcom/google/android/gms/internal/firebase-auth-api/zzalo; {:try_start_8 .. :try_end_8} :catch_0
    .catchall {:try_start_8 .. :try_end_8} :catchall_3

    move-object v5, v6

    goto/16 :goto_8

    .line 1862
    :pswitch_19
    :try_start_9
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1864
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1865
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzp(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1857
    :pswitch_1a
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1859
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1860
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zza(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1852
    :pswitch_1b
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1854
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1855
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zze(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1847
    :pswitch_1c
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1849
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1850
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzf(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1842
    :pswitch_1d
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1844
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1845
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzh(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1837
    :pswitch_1e
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1839
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1840
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzq(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1832
    :pswitch_1f
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1834
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1835
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzi(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1827
    :pswitch_20
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1829
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1830
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzg(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1822
    :pswitch_21
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1824
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1825
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzc(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1817
    :pswitch_22
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1819
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1820
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzm(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1812
    :pswitch_23
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1814
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1815
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzl(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1807
    :pswitch_24
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1809
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1810
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzk(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1802
    :pswitch_25
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1804
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1805
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzj(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1794
    :pswitch_26
    iget-object v13, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int/2addr v4, v14

    int-to-long v14, v4

    .line 1796
    invoke-interface {v13, v1, v14, v15}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v4

    .line 1797
    invoke-interface {v0, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzd(Ljava/util/List;)V

    move-object v13, v4

    .line 1799
    invoke-direct {v10, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(I)Lcom/google/android/gms/internal/firebase-auth-api/zzalj;

    move-result-object v4
    :try_end_9
    .catch Lcom/google/android/gms/internal/firebase-auth-api/zzalo; {:try_start_9 .. :try_end_9} :catch_1
    .catchall {:try_start_9 .. :try_end_9} :catchall_6

    move-object v3, v6

    move-object v6, v5

    move-object v5, v3

    move-object v3, v13

    .line 1800
    :try_start_a
    invoke-static/range {v1 .. v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(Ljava/lang/Object;ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzalj;Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanu;)Ljava/lang/Object;

    move-result-object v2
    :try_end_a
    .catch Lcom/google/android/gms/internal/firebase-auth-api/zzalo; {:try_start_a .. :try_end_a} :catch_0
    .catchall {:try_start_a .. :try_end_a} :catchall_3

    move-object v5, v6

    :goto_8
    move-object v6, v2

    goto/16 :goto_a

    :catchall_3
    move-exception v0

    move-object/from16 v17, v6

    move-object v6, v5

    move-object/from16 v5, v17

    goto/16 :goto_13

    :catch_0
    move-object/from16 v17, v6

    move-object v6, v5

    move-object/from16 v5, v17

    goto/16 :goto_c

    .line 1789
    :pswitch_27
    :try_start_b
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1791
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1792
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzp(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1784
    :pswitch_28
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1786
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1787
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzb(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1775
    :pswitch_29
    invoke-direct {v10, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v2

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1780
    iget-object v13, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    .line 1781
    invoke-interface {v13, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v3

    .line 1782
    invoke-interface {v0, v3, v2, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzb(Ljava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;Lcom/google/android/gms/internal/firebase-auth-api/zzaku;)V

    goto/16 :goto_a

    .line 1765
    :pswitch_2a
    invoke-static {v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzg(I)Z

    move-result v2

    if-eqz v2, :cond_e

    .line 1766
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1768
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1769
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzo(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1770
    :cond_e
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1772
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzn(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1759
    :pswitch_2b
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1761
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1762
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zza(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1754
    :pswitch_2c
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1756
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1757
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zze(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1749
    :pswitch_2d
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1751
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1752
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzf(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1744
    :pswitch_2e
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1746
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1747
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzh(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1739
    :pswitch_2f
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1741
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1742
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzq(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1734
    :pswitch_30
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1736
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1737
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzi(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1729
    :pswitch_31
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1731
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1732
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzg(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1724
    :pswitch_32
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    and-int v3, v4, v14

    int-to-long v3, v3

    .line 1726
    invoke-interface {v2, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;J)Ljava/util/List;

    move-result-object v2

    .line 1727
    invoke-interface {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzc(Ljava/util/List;)V

    goto/16 :goto_a

    .line 1718
    :pswitch_33
    invoke-direct {v10, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/google/android/gms/internal/firebase-auth-api/zzamm;

    .line 1720
    invoke-direct {v10, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v4

    .line 1721
    invoke-interface {v0, v2, v4, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zza(Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;Lcom/google/android/gms/internal/firebase-auth-api/zzaku;)V

    .line 1722
    invoke-direct {v10, v1, v3, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;ILjava/lang/Object;)V

    goto/16 :goto_a

    :pswitch_34
    and-int v2, v4, v14

    int-to-long v13, v2

    .line 1715
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzn()J

    move-result-wide v8

    invoke-static {v1, v13, v14, v8, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JJ)V

    .line 1716
    invoke-direct {v10, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto/16 :goto_a

    :pswitch_35
    and-int/2addr v4, v14

    int-to-long v8, v4

    .line 1710
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzi()I

    move-result v4

    invoke-static {v1, v8, v9, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JI)V

    .line 1711
    invoke-direct {v10, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto/16 :goto_a

    :pswitch_36
    and-int/2addr v4, v14

    int-to-long v8, v4

    .line 1705
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzm()J

    move-result-wide v13

    invoke-static {v1, v8, v9, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JJ)V

    .line 1706
    invoke-direct {v10, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto/16 :goto_a

    :pswitch_37
    and-int/2addr v4, v14

    int-to-long v8, v4

    .line 1700
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzh()I

    move-result v4

    invoke-static {v1, v8, v9, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JI)V

    .line 1701
    invoke-direct {v10, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto/16 :goto_a

    :pswitch_38
    move v8, v2

    .line 1688
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zze()I

    move-result v9

    .line 1689
    invoke-direct {v10, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(I)Lcom/google/android/gms/internal/firebase-auth-api/zzalj;

    move-result-object v13

    if-eqz v13, :cond_10

    .line 1690
    invoke-interface {v13, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzalj;->zza(I)Z

    move-result v13

    if-eqz v13, :cond_f

    goto :goto_9

    .line 1696
    :cond_f
    invoke-static {v1, v8, v9, v6, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(Ljava/lang/Object;IILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanu;)Ljava/lang/Object;

    move-result-object v6

    goto/16 :goto_a

    :cond_10
    :goto_9
    and-int/2addr v4, v14

    int-to-long v13, v4

    .line 1693
    invoke-static {v1, v13, v14, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JI)V

    .line 1694
    invoke-direct {v10, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto/16 :goto_a

    :pswitch_39
    and-int/2addr v4, v14

    int-to-long v8, v4

    .line 1685
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzj()I

    move-result v4

    invoke-static {v1, v8, v9, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JI)V

    .line 1686
    invoke-direct {v10, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto/16 :goto_a

    :pswitch_3a
    and-int/2addr v4, v14

    int-to-long v8, v4

    .line 1680
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzp()Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    move-result-object v4

    invoke-static {v1, v8, v9, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1681
    invoke-direct {v10, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto/16 :goto_a

    .line 1672
    :pswitch_3b
    invoke-direct {v10, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;I)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Lcom/google/android/gms/internal/firebase-auth-api/zzamm;

    .line 1674
    invoke-direct {v10, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v8

    .line 1675
    invoke-interface {v0, v4, v8, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzb(Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;Lcom/google/android/gms/internal/firebase-auth-api/zzaku;)V

    .line 1676
    invoke-direct {v10, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;ILjava/lang/Object;)V

    goto/16 :goto_a

    .line 1669
    :pswitch_3c
    invoke-direct {v10, v1, v4, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;ILcom/google/android/gms/internal/firebase-auth-api/zzanc;)V

    .line 1670
    invoke-direct {v10, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto :goto_a

    :pswitch_3d
    and-int/2addr v4, v14

    int-to-long v8, v4

    .line 1666
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzs()Z

    move-result v4

    invoke-static {v1, v8, v9, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;JZ)V

    .line 1667
    invoke-direct {v10, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto :goto_a

    :pswitch_3e
    and-int/2addr v4, v14

    int-to-long v8, v4

    .line 1661
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzf()I

    move-result v4

    invoke-static {v1, v8, v9, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JI)V

    .line 1662
    invoke-direct {v10, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto :goto_a

    :pswitch_3f
    and-int/2addr v4, v14

    int-to-long v8, v4

    .line 1656
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzk()J

    move-result-wide v13

    invoke-static {v1, v8, v9, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JJ)V

    .line 1657
    invoke-direct {v10, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto :goto_a

    :pswitch_40
    and-int/2addr v4, v14

    int-to-long v8, v4

    .line 1651
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzg()I

    move-result v4

    invoke-static {v1, v8, v9, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JI)V

    .line 1652
    invoke-direct {v10, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto :goto_a

    :pswitch_41
    and-int/2addr v4, v14

    int-to-long v8, v4

    .line 1646
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzo()J

    move-result-wide v13

    invoke-static {v1, v8, v9, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JJ)V

    .line 1647
    invoke-direct {v10, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto :goto_a

    :pswitch_42
    and-int/2addr v4, v14

    int-to-long v8, v4

    .line 1641
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzl()J

    move-result-wide v13

    invoke-static {v1, v8, v9, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JJ)V

    .line 1642
    invoke-direct {v10, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto :goto_a

    :pswitch_43
    and-int/2addr v4, v14

    int-to-long v8, v4

    .line 1636
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zzb()F

    move-result v4

    invoke-static {v1, v8, v9, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JF)V

    .line 1637
    invoke-direct {v10, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto :goto_a

    :pswitch_44
    and-int/2addr v4, v14

    int-to-long v8, v4

    .line 1631
    invoke-interface {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanc;->zza()D

    move-result-wide v13

    invoke-static {v1, v8, v9, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JD)V

    .line 1632
    invoke-direct {v10, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V
    :try_end_b
    .catch Lcom/google/android/gms/internal/firebase-auth-api/zzalo; {:try_start_b .. :try_end_b} :catch_1
    .catchall {:try_start_b .. :try_end_b} :catchall_6

    :goto_a
    move-object v1, v10

    :goto_b
    move-object v4, v11

    move-object v0, v12

    goto/16 :goto_0

    :catch_1
    :goto_c
    move-object v3, v1

    move-object v1, v10

    goto :goto_10

    :cond_11
    :goto_d
    const/4 v2, 0x0

    .line 2034
    :try_start_c
    invoke-virtual {v5, v6, v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zza(Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanc;I)Z

    move-result v2
    :try_end_c
    .catch Lcom/google/android/gms/internal/firebase-auth-api/zzalo; {:try_start_c .. :try_end_c} :catch_1
    .catchall {:try_start_c .. :try_end_c} :catchall_4

    if-nez v2, :cond_13

    .line 2035
    iget v0, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzl:I

    move-object v4, v6

    :goto_e
    iget v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzm:I

    if-ge v0, v2, :cond_12

    .line 2036
    iget-object v2, v10, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzk:[I

    aget v3, v2, v0

    move-object/from16 v6, p1

    move-object v2, v1

    move-object v1, v10

    .line 2037
    invoke-direct/range {v1 .. v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanu;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    move-object v3, v2

    add-int/lit8 v0, v0, 0x1

    move-object v1, v3

    goto :goto_e

    :cond_12
    move-object v3, v1

    move-object v1, v10

    if-eqz v4, :cond_16

    .line 2040
    invoke-virtual {v5, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zzb(Ljava/lang/Object;Ljava/lang/Object;)V

    goto :goto_12

    :cond_13
    move-object v3, v1

    goto :goto_a

    :catchall_4
    move-exception v0

    move-object v3, v1

    move-object v1, v10

    :goto_f
    move-object v2, v3

    goto :goto_15

    .line 2044
    :goto_10
    :try_start_d
    invoke-virtual {v5, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzanc;)Z

    if-nez v6, :cond_14

    .line 2046
    invoke-virtual {v5, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zzc(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    move-object v6, v4

    :cond_14
    const/4 v2, 0x0

    .line 2047
    invoke-virtual {v5, v6, v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zza(Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanc;I)Z

    move-result v2
    :try_end_d
    .catchall {:try_start_d .. :try_end_d} :catchall_5

    if-nez v2, :cond_17

    .line 2048
    iget v0, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzl:I

    move-object v4, v6

    :goto_11
    iget v2, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzm:I

    if-ge v0, v2, :cond_15

    .line 2049
    iget-object v2, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzk:[I

    aget v2, v2, v0

    move-object/from16 v6, p1

    move-object/from16 v17, v3

    move v3, v2

    move-object/from16 v2, v17

    .line 2050
    invoke-direct/range {v1 .. v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanu;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    add-int/lit8 v0, v0, 0x1

    move-object v3, v2

    goto :goto_11

    :cond_15
    move-object v2, v3

    if-eqz v4, :cond_16

    .line 2053
    invoke-virtual {v5, v2, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zzb(Ljava/lang/Object;Ljava/lang/Object;)V

    :cond_16
    :goto_12
    return-void

    :cond_17
    move-object v2, v3

    goto :goto_b

    :catchall_5
    move-exception v0

    goto :goto_f

    :catchall_6
    move-exception v0

    :goto_13
    move-object v2, v1

    :goto_14
    move-object v1, v10

    goto :goto_15

    :catchall_7
    move-exception v0

    move-object/from16 v2, p1

    .line 2056
    :goto_15
    iget v3, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzl:I

    move v7, v3

    move-object v4, v6

    :goto_16
    iget v3, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzm:I

    if-ge v7, v3, :cond_18

    .line 2057
    iget-object v3, v1, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzk:[I

    aget v3, v3, v7

    move-object/from16 v6, p1

    .line 2058
    invoke-direct/range {v1 .. v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanu;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    move-object v1, v2

    add-int/lit8 v7, v7, 0x1

    move-object/from16 v1, p0

    goto :goto_16

    :cond_18
    move-object v1, v2

    if-eqz v4, :cond_19

    .line 2061
    invoke-virtual {v5, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zzb(Ljava/lang/Object;Ljava/lang/Object;)V

    .line 2062
    :cond_19
    throw v0

    nop

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_44
        :pswitch_43
        :pswitch_42
        :pswitch_41
        :pswitch_40
        :pswitch_3f
        :pswitch_3e
        :pswitch_3d
        :pswitch_3c
        :pswitch_3b
        :pswitch_3a
        :pswitch_39
        :pswitch_38
        :pswitch_37
        :pswitch_36
        :pswitch_35
        :pswitch_34
        :pswitch_33
        :pswitch_32
        :pswitch_31
        :pswitch_30
        :pswitch_2f
        :pswitch_2e
        :pswitch_2d
        :pswitch_2c
        :pswitch_2b
        :pswitch_2a
        :pswitch_29
        :pswitch_28
        :pswitch_27
        :pswitch_26
        :pswitch_25
        :pswitch_24
        :pswitch_23
        :pswitch_22
        :pswitch_21
        :pswitch_20
        :pswitch_1f
        :pswitch_1e
        :pswitch_1d
        :pswitch_1c
        :pswitch_1b
        :pswitch_1a
        :pswitch_19
        :pswitch_18
        :pswitch_17
        :pswitch_16
        :pswitch_15
        :pswitch_14
        :pswitch_13
        :pswitch_12
        :pswitch_11
        :pswitch_10
        :pswitch_f
        :pswitch_e
        :pswitch_d
        :pswitch_c
        :pswitch_b
        :pswitch_a
        :pswitch_9
        :pswitch_8
        :pswitch_7
        :pswitch_6
        :pswitch_5
        :pswitch_4
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method public final zza(Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;)V
    .locals 20
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzaol;",
            ")V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    move-object/from16 v0, p0

    move-object/from16 v1, p1

    move-object/from16 v6, p2

    .line 2168
    invoke-interface {v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza()I

    move-result v2

    const/4 v3, 0x2

    const/high16 v7, 0xff00000

    const/4 v9, 0x1

    const/4 v10, 0x0

    const v11, 0xfffff

    if-ne v2, v3, :cond_7

    .line 2170
    iget-object v2, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzp:Lcom/google/android/gms/internal/firebase-auth-api/zzanu;

    invoke-static {v2, v1, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzanu;Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;)V

    .line 2173
    iget-boolean v2, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzh:Z

    if-eqz v2, :cond_0

    .line 2174
    iget-object v2, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzq:Lcom/google/android/gms/internal/firebase-auth-api/zzakw;

    invoke-virtual {v2, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakw;->zza(Ljava/lang/Object;)Lcom/google/android/gms/internal/firebase-auth-api/zzakx;

    move-result-object v2

    .line 2176
    iget-object v3, v2, Lcom/google/android/gms/internal/firebase-auth-api/zzakx;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzang;

    invoke-virtual {v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzang;->isEmpty()Z

    move-result v3

    if-nez v3, :cond_0

    .line 2178
    invoke-virtual {v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakx;->zzc()Ljava/util/Iterator;

    move-result-object v2

    .line 2179
    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/util/Map$Entry;

    goto :goto_0

    :cond_0
    const/4 v2, 0x0

    const/4 v3, 0x0

    .line 2180
    :goto_0
    iget-object v4, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    array-length v4, v4

    add-int/lit8 v4, v4, -0x3

    :goto_1
    if-ltz v4, :cond_4

    .line 2181
    invoke-direct {v0, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(I)I

    move-result v5

    .line 2183
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    :goto_2
    if-eqz v3, :cond_2

    .line 2185
    iget-object v13, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzq:Lcom/google/android/gms/internal/firebase-auth-api/zzakw;

    invoke-virtual {v13, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakw;->zza(Ljava/util/Map$Entry;)I

    move-result v13

    if-le v13, v12, :cond_2

    .line 2186
    iget-object v13, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzq:Lcom/google/android/gms/internal/firebase-auth-api/zzakw;

    invoke-virtual {v13, v6, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakw;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Ljava/util/Map$Entry;)V

    .line 2187
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_1

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/util/Map$Entry;

    goto :goto_2

    :cond_1
    const/4 v3, 0x0

    goto :goto_2

    :cond_2
    and-int v13, v5, v7

    ushr-int/lit8 v13, v13, 0x14

    packed-switch v13, :pswitch_data_0

    goto/16 :goto_3

    .line 2615
    :pswitch_0
    invoke-direct {v0, v1, v12, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2618
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    .line 2619
    invoke-direct {v0, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v13

    .line 2620
    invoke-interface {v6, v12, v5, v13}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)V

    goto/16 :goto_3

    .line 2611
    :pswitch_1
    invoke-direct {v0, v1, v12, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2614
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(Ljava/lang/Object;J)J

    move-result-wide v13

    invoke-interface {v6, v12, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzd(IJ)V

    goto/16 :goto_3

    .line 2607
    :pswitch_2
    invoke-direct {v0, v1, v12, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2610
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v5

    invoke-interface {v6, v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zze(II)V

    goto/16 :goto_3

    .line 2603
    :pswitch_3
    invoke-direct {v0, v1, v12, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2606
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(Ljava/lang/Object;J)J

    move-result-wide v13

    invoke-interface {v6, v12, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzc(IJ)V

    goto/16 :goto_3

    .line 2599
    :pswitch_4
    invoke-direct {v0, v1, v12, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2602
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v5

    invoke-interface {v6, v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzd(II)V

    goto/16 :goto_3

    .line 2595
    :pswitch_5
    invoke-direct {v0, v1, v12, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2598
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v5

    invoke-interface {v6, v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(II)V

    goto/16 :goto_3

    .line 2591
    :pswitch_6
    invoke-direct {v0, v1, v12, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2594
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v5

    invoke-interface {v6, v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzf(II)V

    goto/16 :goto_3

    .line 2586
    :pswitch_7
    invoke-direct {v0, v1, v12, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2589
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    .line 2590
    invoke-interface {v6, v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(ILcom/google/android/gms/internal/firebase-auth-api/zzajv;)V

    goto/16 :goto_3

    .line 2580
    :pswitch_8
    invoke-direct {v0, v1, v12, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2583
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    .line 2584
    invoke-direct {v0, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v13

    invoke-interface {v6, v12, v5, v13}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzb(ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)V

    goto/16 :goto_3

    .line 2576
    :pswitch_9
    invoke-direct {v0, v1, v12, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2579
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    invoke-static {v12, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;)V

    goto/16 :goto_3

    .line 2572
    :pswitch_a
    invoke-direct {v0, v1, v12, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2575
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(Ljava/lang/Object;J)Z

    move-result v5

    invoke-interface {v6, v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(IZ)V

    goto/16 :goto_3

    .line 2568
    :pswitch_b
    invoke-direct {v0, v1, v12, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2571
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v5

    invoke-interface {v6, v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzb(II)V

    goto/16 :goto_3

    .line 2564
    :pswitch_c
    invoke-direct {v0, v1, v12, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2567
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(Ljava/lang/Object;J)J

    move-result-wide v13

    invoke-interface {v6, v12, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(IJ)V

    goto/16 :goto_3

    .line 2560
    :pswitch_d
    invoke-direct {v0, v1, v12, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2563
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v5

    invoke-interface {v6, v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzc(II)V

    goto/16 :goto_3

    .line 2556
    :pswitch_e
    invoke-direct {v0, v1, v12, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2559
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(Ljava/lang/Object;J)J

    move-result-wide v13

    invoke-interface {v6, v12, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zze(IJ)V

    goto/16 :goto_3

    .line 2552
    :pswitch_f
    invoke-direct {v0, v1, v12, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2555
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(Ljava/lang/Object;J)J

    move-result-wide v13

    invoke-interface {v6, v12, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzb(IJ)V

    goto/16 :goto_3

    .line 2548
    :pswitch_10
    invoke-direct {v0, v1, v12, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2551
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;J)F

    move-result v5

    invoke-interface {v6, v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(IF)V

    goto/16 :goto_3

    .line 2544
    :pswitch_11
    invoke-direct {v0, v1, v12, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2547
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;J)D

    move-result-wide v13

    invoke-interface {v6, v12, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(ID)V

    goto/16 :goto_3

    :pswitch_12
    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2542
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    invoke-direct {v0, v6, v12, v5, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzaol;ILjava/lang/Object;I)V

    goto/16 :goto_3

    .line 2533
    :pswitch_13
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2536
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2537
    invoke-direct {v0, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v13

    .line 2538
    invoke-static {v12, v5, v6, v13}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)V

    goto/16 :goto_3

    .line 2525
    :pswitch_14
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2528
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2529
    invoke-static {v12, v5, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzl(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2517
    :pswitch_15
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2520
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2521
    invoke-static {v12, v5, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzk(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2509
    :pswitch_16
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2512
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2513
    invoke-static {v12, v5, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzj(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2501
    :pswitch_17
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2504
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2505
    invoke-static {v12, v5, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzi(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2493
    :pswitch_18
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2496
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2497
    invoke-static {v12, v5, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzc(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2485
    :pswitch_19
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2488
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2489
    invoke-static {v12, v5, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzm(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2477
    :pswitch_1a
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2480
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2481
    invoke-static {v12, v5, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2469
    :pswitch_1b
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2472
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2473
    invoke-static {v12, v5, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzd(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2461
    :pswitch_1c
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2464
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2465
    invoke-static {v12, v5, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zze(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2453
    :pswitch_1d
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2456
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2457
    invoke-static {v12, v5, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzg(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2445
    :pswitch_1e
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2448
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2449
    invoke-static {v12, v5, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzn(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2437
    :pswitch_1f
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2440
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2441
    invoke-static {v12, v5, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzh(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2429
    :pswitch_20
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2432
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2433
    invoke-static {v12, v5, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzf(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2421
    :pswitch_21
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2424
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2425
    invoke-static {v12, v5, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzb(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2413
    :pswitch_22
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2416
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2417
    invoke-static {v12, v5, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzl(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2405
    :pswitch_23
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2408
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2409
    invoke-static {v12, v5, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzk(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2397
    :pswitch_24
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2400
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2401
    invoke-static {v12, v5, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzj(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2389
    :pswitch_25
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2392
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2393
    invoke-static {v12, v5, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzi(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2381
    :pswitch_26
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2384
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2385
    invoke-static {v12, v5, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzc(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2373
    :pswitch_27
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2376
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2377
    invoke-static {v12, v5, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzm(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2365
    :pswitch_28
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2368
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2369
    invoke-static {v12, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;)V

    goto/16 :goto_3

    .line 2356
    :pswitch_29
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2359
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2360
    invoke-direct {v0, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v13

    .line 2361
    invoke-static {v12, v5, v6, v13}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzb(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)V

    goto/16 :goto_3

    .line 2348
    :pswitch_2a
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2351
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2352
    invoke-static {v12, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzb(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;)V

    goto/16 :goto_3

    .line 2340
    :pswitch_2b
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2343
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2344
    invoke-static {v12, v5, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2332
    :pswitch_2c
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2335
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2336
    invoke-static {v12, v5, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzd(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2324
    :pswitch_2d
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2327
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2328
    invoke-static {v12, v5, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zze(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2316
    :pswitch_2e
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2319
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2320
    invoke-static {v12, v5, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzg(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2308
    :pswitch_2f
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2311
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2312
    invoke-static {v12, v5, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzn(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2300
    :pswitch_30
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2303
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2304
    invoke-static {v12, v5, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzh(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2292
    :pswitch_31
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2295
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2296
    invoke-static {v12, v5, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzf(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2284
    :pswitch_32
    iget-object v12, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v12, v12, v4

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2287
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/List;

    .line 2288
    invoke-static {v12, v5, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzb(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_3

    .line 2276
    :pswitch_33
    invoke-direct {v0, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2279
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    .line 2280
    invoke-direct {v0, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v13

    .line 2281
    invoke-interface {v6, v12, v5, v13}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)V

    goto/16 :goto_3

    .line 2271
    :pswitch_34
    invoke-direct {v0, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2274
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v13

    .line 2275
    invoke-interface {v6, v12, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzd(IJ)V

    goto/16 :goto_3

    .line 2266
    :pswitch_35
    invoke-direct {v0, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2269
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v5

    .line 2270
    invoke-interface {v6, v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zze(II)V

    goto/16 :goto_3

    .line 2261
    :pswitch_36
    invoke-direct {v0, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2264
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v13

    .line 2265
    invoke-interface {v6, v12, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzc(IJ)V

    goto/16 :goto_3

    .line 2256
    :pswitch_37
    invoke-direct {v0, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2259
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v5

    .line 2260
    invoke-interface {v6, v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzd(II)V

    goto/16 :goto_3

    .line 2251
    :pswitch_38
    invoke-direct {v0, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2254
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v5

    .line 2255
    invoke-interface {v6, v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(II)V

    goto/16 :goto_3

    .line 2246
    :pswitch_39
    invoke-direct {v0, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2249
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v5

    .line 2250
    invoke-interface {v6, v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzf(II)V

    goto/16 :goto_3

    .line 2241
    :pswitch_3a
    invoke-direct {v0, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2244
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    .line 2245
    invoke-interface {v6, v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(ILcom/google/android/gms/internal/firebase-auth-api/zzajv;)V

    goto/16 :goto_3

    .line 2235
    :pswitch_3b
    invoke-direct {v0, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2238
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    .line 2239
    invoke-direct {v0, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v13

    invoke-interface {v6, v12, v5, v13}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzb(ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)V

    goto/16 :goto_3

    .line 2231
    :pswitch_3c
    invoke-direct {v0, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2234
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    invoke-static {v12, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;)V

    goto/16 :goto_3

    .line 2226
    :pswitch_3d
    invoke-direct {v0, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2229
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzh(Ljava/lang/Object;J)Z

    move-result v5

    .line 2230
    invoke-interface {v6, v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(IZ)V

    goto/16 :goto_3

    .line 2221
    :pswitch_3e
    invoke-direct {v0, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2224
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v5

    .line 2225
    invoke-interface {v6, v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzb(II)V

    goto :goto_3

    .line 2216
    :pswitch_3f
    invoke-direct {v0, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2219
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v13

    .line 2220
    invoke-interface {v6, v12, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(IJ)V

    goto :goto_3

    .line 2211
    :pswitch_40
    invoke-direct {v0, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2214
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v5

    .line 2215
    invoke-interface {v6, v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzc(II)V

    goto :goto_3

    .line 2206
    :pswitch_41
    invoke-direct {v0, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2209
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v13

    .line 2210
    invoke-interface {v6, v12, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zze(IJ)V

    goto :goto_3

    .line 2201
    :pswitch_42
    invoke-direct {v0, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2204
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v13

    .line 2205
    invoke-interface {v6, v12, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzb(IJ)V

    goto :goto_3

    .line 2196
    :pswitch_43
    invoke-direct {v0, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2199
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzb(Ljava/lang/Object;J)F

    move-result v5

    .line 2200
    invoke-interface {v6, v12, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(IF)V

    goto :goto_3

    .line 2191
    :pswitch_44
    invoke-direct {v0, v1, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v13

    if-eqz v13, :cond_3

    and-int/2addr v5, v11

    int-to-long v13, v5

    .line 2194
    invoke-static {v1, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;J)D

    move-result-wide v13

    .line 2195
    invoke-interface {v6, v12, v13, v14}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(ID)V

    :cond_3
    :goto_3
    add-int/lit8 v4, v4, -0x3

    goto/16 :goto_1

    :cond_4
    :goto_4
    if-eqz v3, :cond_6

    .line 2623
    iget-object v1, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzq:Lcom/google/android/gms/internal/firebase-auth-api/zzakw;

    invoke-virtual {v1, v6, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakw;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Ljava/util/Map$Entry;)V

    .line 2624
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_5

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/util/Map$Entry;

    move-object v3, v1

    goto :goto_4

    :cond_5
    const/4 v3, 0x0

    goto :goto_4

    :cond_6
    return-void

    .line 2629
    :cond_7
    iget-boolean v2, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzh:Z

    if-eqz v2, :cond_8

    .line 2630
    iget-object v2, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzq:Lcom/google/android/gms/internal/firebase-auth-api/zzakw;

    invoke-virtual {v2, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakw;->zza(Ljava/lang/Object;)Lcom/google/android/gms/internal/firebase-auth-api/zzakx;

    move-result-object v2

    .line 2632
    iget-object v3, v2, Lcom/google/android/gms/internal/firebase-auth-api/zzakx;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzang;

    invoke-virtual {v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzang;->isEmpty()Z

    move-result v3

    if-nez v3, :cond_8

    .line 2634
    invoke-virtual {v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakx;->zzd()Ljava/util/Iterator;

    move-result-object v2

    .line 2635
    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/util/Map$Entry;

    move-object v12, v2

    goto :goto_5

    :cond_8
    const/4 v3, 0x0

    const/4 v12, 0x0

    .line 2638
    :goto_5
    iget-object v2, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    array-length v13, v2

    .line 2639
    sget-object v14, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb:Lsun/misc/Unsafe;

    move v2, v10

    move v5, v2

    move v4, v11

    :goto_6
    if-ge v2, v13, :cond_11

    .line 2641
    invoke-direct {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(I)I

    move-result v15

    move/from16 v16, v7

    .line 2643
    iget-object v7, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v8, v7, v2

    and-int v17, v15, v16

    ushr-int/lit8 v10, v17, 0x14

    move/from16 v17, v9

    const/16 v9, 0x11

    if-gt v10, v9, :cond_b

    add-int/lit8 v9, v2, 0x2

    .line 2650
    aget v7, v7, v9

    and-int v9, v7, v11

    if-eq v9, v4, :cond_a

    if-ne v9, v11, :cond_9

    const/4 v5, 0x0

    goto :goto_7

    :cond_9
    int-to-long v4, v9

    .line 2656
    invoke-virtual {v14, v1, v4, v5}, Lsun/misc/Unsafe;->getInt(Ljava/lang/Object;J)I

    move-result v4

    move v5, v4

    :goto_7
    move v4, v9

    :cond_a
    ushr-int/lit8 v7, v7, 0x14

    shl-int v7, v17, v7

    move/from16 v19, v7

    move-object v7, v3

    move v3, v4

    move v4, v5

    move/from16 v5, v19

    goto :goto_8

    :cond_b
    move-object v7, v3

    move v3, v4

    move v4, v5

    const/4 v5, 0x0

    :goto_8
    if-eqz v7, :cond_d

    .line 2658
    iget-object v9, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzq:Lcom/google/android/gms/internal/firebase-auth-api/zzakw;

    invoke-virtual {v9, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzakw;->zza(Ljava/util/Map$Entry;)I

    move-result v9

    if-gt v9, v8, :cond_d

    .line 2659
    iget-object v9, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzq:Lcom/google/android/gms/internal/firebase-auth-api/zzakw;

    invoke-virtual {v9, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzakw;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Ljava/util/Map$Entry;)V

    .line 2660
    invoke-interface {v12}, Ljava/util/Iterator;->hasNext()Z

    move-result v7

    if-eqz v7, :cond_c

    invoke-interface {v12}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v7

    check-cast v7, Ljava/util/Map$Entry;

    goto :goto_8

    :cond_c
    const/4 v7, 0x0

    goto :goto_8

    :cond_d
    and-int v9, v15, v11

    move-object/from16 v18, v12

    int-to-long v11, v9

    packed-switch v10, :pswitch_data_1

    :cond_e
    :goto_9
    move/from16 v9, v17

    :goto_a
    const/4 v10, 0x0

    goto/16 :goto_c

    .line 2945
    :pswitch_45
    invoke-direct {v0, v1, v8, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_e

    .line 2947
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    invoke-direct {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v9

    .line 2948
    invoke-interface {v6, v8, v5, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)V

    goto :goto_9

    .line 2943
    :pswitch_46
    invoke-direct {v0, v1, v8, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_e

    .line 2944
    invoke-static {v1, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(Ljava/lang/Object;J)J

    move-result-wide v9

    invoke-interface {v6, v8, v9, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzd(IJ)V

    goto :goto_9

    .line 2941
    :pswitch_47
    invoke-direct {v0, v1, v8, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_e

    .line 2942
    invoke-static {v1, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v5

    invoke-interface {v6, v8, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zze(II)V

    goto :goto_9

    .line 2939
    :pswitch_48
    invoke-direct {v0, v1, v8, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_e

    .line 2940
    invoke-static {v1, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(Ljava/lang/Object;J)J

    move-result-wide v9

    invoke-interface {v6, v8, v9, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzc(IJ)V

    goto :goto_9

    .line 2937
    :pswitch_49
    invoke-direct {v0, v1, v8, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_e

    .line 2938
    invoke-static {v1, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v5

    invoke-interface {v6, v8, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzd(II)V

    goto :goto_9

    .line 2935
    :pswitch_4a
    invoke-direct {v0, v1, v8, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_e

    .line 2936
    invoke-static {v1, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v5

    invoke-interface {v6, v8, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(II)V

    goto :goto_9

    .line 2933
    :pswitch_4b
    invoke-direct {v0, v1, v8, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_e

    .line 2934
    invoke-static {v1, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v5

    invoke-interface {v6, v8, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzf(II)V

    goto :goto_9

    .line 2931
    :pswitch_4c
    invoke-direct {v0, v1, v8, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_e

    .line 2932
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    invoke-interface {v6, v8, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(ILcom/google/android/gms/internal/firebase-auth-api/zzajv;)V

    goto :goto_9

    .line 2927
    :pswitch_4d
    invoke-direct {v0, v1, v8, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_e

    .line 2928
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    .line 2929
    invoke-direct {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v9

    invoke-interface {v6, v8, v5, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzb(ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)V

    goto/16 :goto_9

    .line 2925
    :pswitch_4e
    invoke-direct {v0, v1, v8, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_e

    .line 2926
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    invoke-static {v8, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;)V

    goto/16 :goto_9

    .line 2923
    :pswitch_4f
    invoke-direct {v0, v1, v8, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_e

    .line 2924
    invoke-static {v1, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(Ljava/lang/Object;J)Z

    move-result v5

    invoke-interface {v6, v8, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(IZ)V

    goto/16 :goto_9

    .line 2921
    :pswitch_50
    invoke-direct {v0, v1, v8, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_e

    .line 2922
    invoke-static {v1, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v5

    invoke-interface {v6, v8, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzb(II)V

    goto/16 :goto_9

    .line 2919
    :pswitch_51
    invoke-direct {v0, v1, v8, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_e

    .line 2920
    invoke-static {v1, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(Ljava/lang/Object;J)J

    move-result-wide v9

    invoke-interface {v6, v8, v9, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(IJ)V

    goto/16 :goto_9

    .line 2917
    :pswitch_52
    invoke-direct {v0, v1, v8, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_e

    .line 2918
    invoke-static {v1, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v5

    invoke-interface {v6, v8, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzc(II)V

    goto/16 :goto_9

    .line 2915
    :pswitch_53
    invoke-direct {v0, v1, v8, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_e

    .line 2916
    invoke-static {v1, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(Ljava/lang/Object;J)J

    move-result-wide v9

    invoke-interface {v6, v8, v9, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zze(IJ)V

    goto/16 :goto_9

    .line 2913
    :pswitch_54
    invoke-direct {v0, v1, v8, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_e

    .line 2914
    invoke-static {v1, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(Ljava/lang/Object;J)J

    move-result-wide v9

    invoke-interface {v6, v8, v9, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzb(IJ)V

    goto/16 :goto_9

    .line 2911
    :pswitch_55
    invoke-direct {v0, v1, v8, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_e

    .line 2912
    invoke-static {v1, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;J)F

    move-result v5

    invoke-interface {v6, v8, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(IF)V

    goto/16 :goto_9

    .line 2909
    :pswitch_56
    invoke-direct {v0, v1, v8, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v5

    if-eqz v5, :cond_e

    .line 2910
    invoke-static {v1, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;J)D

    move-result-wide v9

    invoke-interface {v6, v8, v9, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(ID)V

    goto/16 :goto_9

    .line 2907
    :pswitch_57
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    invoke-direct {v0, v6, v8, v5, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzaol;ILjava/lang/Object;I)V

    goto/16 :goto_9

    .line 2901
    :pswitch_58
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2903
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2904
    invoke-direct {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v9

    .line 2905
    invoke-static {v5, v8, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)V

    goto/16 :goto_9

    .line 2895
    :pswitch_59
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2896
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    move/from16 v9, v17

    .line 2897
    invoke-static {v5, v8, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzl(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_a

    :pswitch_5a
    move/from16 v9, v17

    .line 2889
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2890
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2891
    invoke-static {v5, v8, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzk(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_a

    :pswitch_5b
    move/from16 v9, v17

    .line 2883
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2884
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2885
    invoke-static {v5, v8, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzj(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_a

    :pswitch_5c
    move/from16 v9, v17

    .line 2877
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2878
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2879
    invoke-static {v5, v8, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzi(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_a

    :pswitch_5d
    move/from16 v9, v17

    .line 2871
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2872
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2873
    invoke-static {v5, v8, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzc(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_a

    :pswitch_5e
    move/from16 v9, v17

    .line 2865
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2866
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2867
    invoke-static {v5, v8, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzm(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_a

    :pswitch_5f
    move/from16 v9, v17

    .line 2859
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2860
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2861
    invoke-static {v5, v8, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_a

    :pswitch_60
    move/from16 v9, v17

    .line 2853
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2854
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2855
    invoke-static {v5, v8, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzd(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_a

    :pswitch_61
    move/from16 v9, v17

    .line 2847
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2848
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2849
    invoke-static {v5, v8, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zze(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_a

    :pswitch_62
    move/from16 v9, v17

    .line 2841
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2842
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2843
    invoke-static {v5, v8, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzg(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_a

    :pswitch_63
    move/from16 v9, v17

    .line 2835
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2836
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2837
    invoke-static {v5, v8, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzn(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_a

    :pswitch_64
    move/from16 v9, v17

    .line 2829
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2830
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2831
    invoke-static {v5, v8, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzh(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_a

    :pswitch_65
    move/from16 v9, v17

    .line 2823
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2824
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2825
    invoke-static {v5, v8, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzf(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_a

    :pswitch_66
    move/from16 v9, v17

    .line 2817
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2818
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2819
    invoke-static {v5, v8, v6, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzb(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_a

    :pswitch_67
    move/from16 v9, v17

    .line 2811
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2812
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    const/4 v10, 0x0

    .line 2813
    invoke-static {v5, v8, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzl(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_c

    :pswitch_68
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2805
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2806
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2807
    invoke-static {v5, v8, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzk(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_c

    :pswitch_69
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2799
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2800
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2801
    invoke-static {v5, v8, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzj(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_c

    :pswitch_6a
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2793
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2794
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2795
    invoke-static {v5, v8, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzi(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_c

    :pswitch_6b
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2787
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2788
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2789
    invoke-static {v5, v8, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzc(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_c

    :pswitch_6c
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2781
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2782
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2783
    invoke-static {v5, v8, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzm(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_c

    :pswitch_6d
    move/from16 v9, v17

    .line 2775
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2776
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2777
    invoke-static {v5, v8, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;)V

    goto/16 :goto_a

    :pswitch_6e
    move/from16 v9, v17

    .line 2767
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2769
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2770
    invoke-direct {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v10

    .line 2771
    invoke-static {v5, v8, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzb(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)V

    goto/16 :goto_a

    :pswitch_6f
    move/from16 v9, v17

    .line 2761
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2762
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2763
    invoke-static {v5, v8, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzb(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;)V

    goto/16 :goto_a

    :pswitch_70
    move/from16 v9, v17

    .line 2755
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2756
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    const/4 v10, 0x0

    .line 2757
    invoke-static {v5, v8, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_c

    :pswitch_71
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2749
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2750
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2751
    invoke-static {v5, v8, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzd(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_c

    :pswitch_72
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2743
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2744
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2745
    invoke-static {v5, v8, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zze(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_c

    :pswitch_73
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2737
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2738
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2739
    invoke-static {v5, v8, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzg(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_c

    :pswitch_74
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2731
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2732
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2733
    invoke-static {v5, v8, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzn(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_c

    :pswitch_75
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2725
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2726
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2727
    invoke-static {v5, v8, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzh(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_c

    :pswitch_76
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2719
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2720
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2721
    invoke-static {v5, v8, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzf(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_c

    :pswitch_77
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2713
    iget-object v5, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v2

    .line 2714
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/util/List;

    .line 2715
    invoke-static {v5, v8, v6, v10}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zzb(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Z)V

    goto/16 :goto_c

    :pswitch_78
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2707
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_10

    .line 2709
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    invoke-direct {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v11

    .line 2710
    invoke-interface {v6, v8, v5, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)V

    goto/16 :goto_c

    :pswitch_79
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2705
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_f

    .line 2706
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getLong(Ljava/lang/Object;J)J

    move-result-wide v11

    invoke-interface {v6, v8, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzd(IJ)V

    goto/16 :goto_b

    :pswitch_7a
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2703
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_f

    .line 2704
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getInt(Ljava/lang/Object;J)I

    move-result v0

    invoke-interface {v6, v8, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zze(II)V

    goto/16 :goto_b

    :pswitch_7b
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2701
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_f

    .line 2702
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getLong(Ljava/lang/Object;J)J

    move-result-wide v11

    invoke-interface {v6, v8, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzc(IJ)V

    goto/16 :goto_b

    :pswitch_7c
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2699
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_f

    .line 2700
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getInt(Ljava/lang/Object;J)I

    move-result v0

    invoke-interface {v6, v8, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzd(II)V

    goto/16 :goto_b

    :pswitch_7d
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2697
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_f

    .line 2698
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getInt(Ljava/lang/Object;J)I

    move-result v0

    invoke-interface {v6, v8, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(II)V

    goto/16 :goto_b

    :pswitch_7e
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2695
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_f

    .line 2696
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getInt(Ljava/lang/Object;J)I

    move-result v0

    invoke-interface {v6, v8, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzf(II)V

    goto/16 :goto_b

    :pswitch_7f
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2693
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_f

    .line 2694
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    invoke-interface {v6, v8, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(ILcom/google/android/gms/internal/firebase-auth-api/zzajv;)V

    goto/16 :goto_b

    :pswitch_80
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2689
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_10

    .line 2690
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    .line 2691
    invoke-direct {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v11

    invoke-interface {v6, v8, v5, v11}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzb(ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)V

    goto/16 :goto_c

    :pswitch_81
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2687
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_f

    .line 2688
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v0

    invoke-static {v8, v0, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;)V

    goto/16 :goto_b

    :pswitch_82
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2683
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_f

    .line 2685
    invoke-static {v1, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzh(Ljava/lang/Object;J)Z

    move-result v0

    .line 2686
    invoke-interface {v6, v8, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(IZ)V

    goto :goto_b

    :pswitch_83
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2681
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_f

    .line 2682
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getInt(Ljava/lang/Object;J)I

    move-result v0

    invoke-interface {v6, v8, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzb(II)V

    goto :goto_b

    :pswitch_84
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2679
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_f

    .line 2680
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getLong(Ljava/lang/Object;J)J

    move-result-wide v11

    invoke-interface {v6, v8, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(IJ)V

    goto :goto_b

    :pswitch_85
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2677
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_f

    .line 2678
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getInt(Ljava/lang/Object;J)I

    move-result v0

    invoke-interface {v6, v8, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzc(II)V

    goto :goto_b

    :pswitch_86
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2675
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_f

    .line 2676
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getLong(Ljava/lang/Object;J)J

    move-result-wide v11

    invoke-interface {v6, v8, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zze(IJ)V

    goto :goto_b

    :pswitch_87
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2673
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_f

    .line 2674
    invoke-virtual {v14, v1, v11, v12}, Lsun/misc/Unsafe;->getLong(Ljava/lang/Object;J)J

    move-result-wide v11

    invoke-interface {v6, v8, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zzb(IJ)V

    goto :goto_b

    :pswitch_88
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2669
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_f

    .line 2671
    invoke-static {v1, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzb(Ljava/lang/Object;J)F

    move-result v0

    .line 2672
    invoke-interface {v6, v8, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(IF)V

    :cond_f
    :goto_b
    move-object/from16 v0, p0

    goto :goto_c

    :pswitch_89
    move/from16 v9, v17

    const/4 v10, 0x0

    .line 2665
    invoke-direct/range {v0 .. v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result v5

    if-eqz v5, :cond_10

    .line 2667
    invoke-static {v1, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;J)D

    move-result-wide v11

    .line 2668
    invoke-interface {v6, v8, v11, v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzaol;->zza(ID)V

    :cond_10
    :goto_c
    add-int/lit8 v2, v2, 0x3

    move v5, v4

    move-object/from16 v12, v18

    const v11, 0xfffff

    move v4, v3

    move-object v3, v7

    move/from16 v7, v16

    goto/16 :goto_6

    :cond_11
    move-object/from16 v18, v12

    :goto_d
    if-eqz v3, :cond_13

    .line 2951
    iget-object v2, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzq:Lcom/google/android/gms/internal/firebase-auth-api/zzakw;

    invoke-virtual {v2, v6, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakw;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzaol;Ljava/util/Map$Entry;)V

    .line 2952
    invoke-interface/range {v18 .. v18}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_12

    invoke-interface/range {v18 .. v18}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/util/Map$Entry;

    move-object v3, v2

    goto :goto_d

    :cond_12
    const/4 v3, 0x0

    goto :goto_d

    .line 2953
    :cond_13
    iget-object v2, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzp:Lcom/google/android/gms/internal/firebase-auth-api/zzanu;

    invoke-static {v2, v1, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzanu;Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;)V

    return-void

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_44
        :pswitch_43
        :pswitch_42
        :pswitch_41
        :pswitch_40
        :pswitch_3f
        :pswitch_3e
        :pswitch_3d
        :pswitch_3c
        :pswitch_3b
        :pswitch_3a
        :pswitch_39
        :pswitch_38
        :pswitch_37
        :pswitch_36
        :pswitch_35
        :pswitch_34
        :pswitch_33
        :pswitch_32
        :pswitch_31
        :pswitch_30
        :pswitch_2f
        :pswitch_2e
        :pswitch_2d
        :pswitch_2c
        :pswitch_2b
        :pswitch_2a
        :pswitch_29
        :pswitch_28
        :pswitch_27
        :pswitch_26
        :pswitch_25
        :pswitch_24
        :pswitch_23
        :pswitch_22
        :pswitch_21
        :pswitch_20
        :pswitch_1f
        :pswitch_1e
        :pswitch_1d
        :pswitch_1c
        :pswitch_1b
        :pswitch_1a
        :pswitch_19
        :pswitch_18
        :pswitch_17
        :pswitch_16
        :pswitch_15
        :pswitch_14
        :pswitch_13
        :pswitch_12
        :pswitch_11
        :pswitch_10
        :pswitch_f
        :pswitch_e
        :pswitch_d
        :pswitch_c
        :pswitch_b
        :pswitch_a
        :pswitch_9
        :pswitch_8
        :pswitch_7
        :pswitch_6
        :pswitch_5
        :pswitch_4
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch

    :pswitch_data_1
    .packed-switch 0x0
        :pswitch_89
        :pswitch_88
        :pswitch_87
        :pswitch_86
        :pswitch_85
        :pswitch_84
        :pswitch_83
        :pswitch_82
        :pswitch_81
        :pswitch_80
        :pswitch_7f
        :pswitch_7e
        :pswitch_7d
        :pswitch_7c
        :pswitch_7b
        :pswitch_7a
        :pswitch_79
        :pswitch_78
        :pswitch_77
        :pswitch_76
        :pswitch_75
        :pswitch_74
        :pswitch_73
        :pswitch_72
        :pswitch_71
        :pswitch_70
        :pswitch_6f
        :pswitch_6e
        :pswitch_6d
        :pswitch_6c
        :pswitch_6b
        :pswitch_6a
        :pswitch_69
        :pswitch_68
        :pswitch_67
        :pswitch_66
        :pswitch_65
        :pswitch_64
        :pswitch_63
        :pswitch_62
        :pswitch_61
        :pswitch_60
        :pswitch_5f
        :pswitch_5e
        :pswitch_5d
        :pswitch_5c
        :pswitch_5b
        :pswitch_5a
        :pswitch_59
        :pswitch_58
        :pswitch_57
        :pswitch_56
        :pswitch_55
        :pswitch_54
        :pswitch_53
        :pswitch_52
        :pswitch_51
        :pswitch_50
        :pswitch_4f
        :pswitch_4e
        :pswitch_4d
        :pswitch_4c
        :pswitch_4b
        :pswitch_4a
        :pswitch_49
        :pswitch_48
        :pswitch_47
        :pswitch_46
        :pswitch_45
    .end packed-switch
.end method

.method public final zza(Ljava/lang/Object;Ljava/lang/Object;)V
    .locals 6
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;TT;)V"
        }
    .end annotation

    .line 1503
    invoke-static {p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzf(Ljava/lang/Object;)V

    .line 1505
    invoke-virtual {p2}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    const/4 v0, 0x0

    .line 1506
    :goto_0
    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    array-length v1, v1

    if-ge v0, v1, :cond_1

    .line 1508
    invoke-direct {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(I)I

    move-result v1

    const v2, 0xfffff

    and-int/2addr v2, v1

    int-to-long v2, v2

    .line 1513
    iget-object v4, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v4, v4, v0

    const/high16 v5, 0xff00000

    and-int/2addr v1, v5

    ushr-int/lit8 v1, v1, 0x14

    packed-switch v1, :pswitch_data_0

    goto/16 :goto_1

    .line 1582
    :pswitch_0
    invoke-direct {p0, p1, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;Ljava/lang/Object;I)V

    goto/16 :goto_1

    .line 1579
    :pswitch_1
    invoke-direct {p0, p2, v4, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 1580
    invoke-static {p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v1

    invoke-static {p1, v2, v3, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1581
    invoke-direct {p0, p1, v4, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    goto/16 :goto_1

    .line 1577
    :pswitch_2
    invoke-direct {p0, p1, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;Ljava/lang/Object;I)V

    goto/16 :goto_1

    .line 1574
    :pswitch_3
    invoke-direct {p0, p2, v4, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 1575
    invoke-static {p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v1

    invoke-static {p1, v2, v3, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1576
    invoke-direct {p0, p1, v4, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;II)V

    goto/16 :goto_1

    .line 1572
    :pswitch_4
    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    invoke-static {v1, p1, p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzamf;Ljava/lang/Object;Ljava/lang/Object;J)V

    goto/16 :goto_1

    .line 1570
    :pswitch_5
    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    invoke-interface {v1, p1, p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zza(Ljava/lang/Object;Ljava/lang/Object;J)V

    goto/16 :goto_1

    .line 1568
    :pswitch_6
    invoke-direct {p0, p1, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;Ljava/lang/Object;I)V

    goto/16 :goto_1

    .line 1565
    :pswitch_7
    invoke-direct {p0, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 1566
    invoke-static {p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v4

    invoke-static {p1, v2, v3, v4, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JJ)V

    .line 1567
    invoke-direct {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto/16 :goto_1

    .line 1562
    :pswitch_8
    invoke-direct {p0, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 1563
    invoke-static {p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v1

    invoke-static {p1, v2, v3, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JI)V

    .line 1564
    invoke-direct {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto/16 :goto_1

    .line 1559
    :pswitch_9
    invoke-direct {p0, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 1560
    invoke-static {p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v4

    invoke-static {p1, v2, v3, v4, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JJ)V

    .line 1561
    invoke-direct {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto/16 :goto_1

    .line 1556
    :pswitch_a
    invoke-direct {p0, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 1557
    invoke-static {p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v1

    invoke-static {p1, v2, v3, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JI)V

    .line 1558
    invoke-direct {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto/16 :goto_1

    .line 1553
    :pswitch_b
    invoke-direct {p0, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 1554
    invoke-static {p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v1

    invoke-static {p1, v2, v3, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JI)V

    .line 1555
    invoke-direct {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto/16 :goto_1

    .line 1550
    :pswitch_c
    invoke-direct {p0, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 1551
    invoke-static {p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v1

    invoke-static {p1, v2, v3, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JI)V

    .line 1552
    invoke-direct {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto/16 :goto_1

    .line 1547
    :pswitch_d
    invoke-direct {p0, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 1548
    invoke-static {p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v1

    invoke-static {p1, v2, v3, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1549
    invoke-direct {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto/16 :goto_1

    .line 1545
    :pswitch_e
    invoke-direct {p0, p1, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;Ljava/lang/Object;I)V

    goto/16 :goto_1

    .line 1542
    :pswitch_f
    invoke-direct {p0, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 1543
    invoke-static {p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v1

    invoke-static {p1, v2, v3, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JLjava/lang/Object;)V

    .line 1544
    invoke-direct {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto/16 :goto_1

    .line 1539
    :pswitch_10
    invoke-direct {p0, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 1540
    invoke-static {p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzh(Ljava/lang/Object;J)Z

    move-result v1

    invoke-static {p1, v2, v3, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;JZ)V

    .line 1541
    invoke-direct {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto/16 :goto_1

    .line 1536
    :pswitch_11
    invoke-direct {p0, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 1537
    invoke-static {p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v1

    invoke-static {p1, v2, v3, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JI)V

    .line 1538
    invoke-direct {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto :goto_1

    .line 1533
    :pswitch_12
    invoke-direct {p0, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 1534
    invoke-static {p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v4

    invoke-static {p1, v2, v3, v4, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JJ)V

    .line 1535
    invoke-direct {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto :goto_1

    .line 1530
    :pswitch_13
    invoke-direct {p0, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 1531
    invoke-static {p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v1

    invoke-static {p1, v2, v3, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JI)V

    .line 1532
    invoke-direct {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto :goto_1

    .line 1527
    :pswitch_14
    invoke-direct {p0, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 1528
    invoke-static {p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v4

    invoke-static {p1, v2, v3, v4, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JJ)V

    .line 1529
    invoke-direct {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto :goto_1

    .line 1524
    :pswitch_15
    invoke-direct {p0, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 1525
    invoke-static {p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v4

    invoke-static {p1, v2, v3, v4, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JJ)V

    .line 1526
    invoke-direct {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto :goto_1

    .line 1521
    :pswitch_16
    invoke-direct {p0, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 1522
    invoke-static {p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzb(Ljava/lang/Object;J)F

    move-result v1

    invoke-static {p1, v2, v3, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JF)V

    .line 1523
    invoke-direct {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    goto :goto_1

    .line 1518
    :pswitch_17
    invoke-direct {p0, p2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 1519
    invoke-static {p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;J)D

    move-result-wide v4

    invoke-static {p1, v2, v3, v4, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;JD)V

    .line 1520
    invoke-direct {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;I)V

    :cond_0
    :goto_1
    add-int/lit8 v0, v0, 0x3

    goto/16 :goto_0

    .line 1584
    :cond_1
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzp:Lcom/google/android/gms/internal/firebase-auth-api/zzanu;

    invoke-static {v0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzanu;Ljava/lang/Object;Ljava/lang/Object;)V

    .line 1585
    iget-boolean v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzh:Z

    if-eqz v0, :cond_2

    .line 1586
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzq:Lcom/google/android/gms/internal/firebase-auth-api/zzakw;

    invoke-static {v0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzakw;Ljava/lang/Object;Ljava/lang/Object;)V

    :cond_2
    return-void

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_17
        :pswitch_16
        :pswitch_15
        :pswitch_14
        :pswitch_13
        :pswitch_12
        :pswitch_11
        :pswitch_10
        :pswitch_f
        :pswitch_e
        :pswitch_d
        :pswitch_c
        :pswitch_b
        :pswitch_a
        :pswitch_9
        :pswitch_8
        :pswitch_7
        :pswitch_6
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_5
        :pswitch_4
        :pswitch_3
        :pswitch_3
        :pswitch_3
        :pswitch_3
        :pswitch_3
        :pswitch_3
        :pswitch_3
        :pswitch_3
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method public final zza(Ljava/lang/Object;[BIILcom/google/android/gms/internal/firebase-auth-api/zzaju;)V
    .locals 7
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;[BII",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzaju;",
            ")V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/4 v5, 0x0

    move-object v0, p0

    move-object v1, p1

    move-object v2, p2

    move v3, p3

    move v4, p4

    move-object v6, p5

    .line 2063
    invoke-virtual/range {v0 .. v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;[BIIILcom/google/android/gms/internal/firebase-auth-api/zzaju;)I

    return-void
.end method

.method public final zzb(Ljava/lang/Object;)I
    .locals 8
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;)I"
        }
    .end annotation

    .line 359
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    array-length v0, v0

    const/4 v1, 0x0

    move v2, v1

    :goto_0
    if-ge v1, v0, :cond_2

    .line 361
    invoke-direct {p0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(I)I

    move-result v3

    .line 363
    iget-object v4, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v4, v4, v1

    const v5, 0xfffff

    and-int/2addr v5, v3

    int-to-long v5, v5

    const/high16 v7, 0xff00000

    and-int/2addr v3, v7

    ushr-int/lit8 v3, v3, 0x14

    const/16 v7, 0x25

    packed-switch v3, :pswitch_data_0

    goto/16 :goto_3

    .line 459
    :pswitch_0
    invoke-direct {p0, p1, v4, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v3

    if-eqz v3, :cond_1

    .line 460
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v3

    mul-int/lit8 v2, v2, 0x35

    .line 461
    invoke-virtual {v3}, Ljava/lang/Object;->hashCode()I

    move-result v3

    goto/16 :goto_2

    .line 457
    :pswitch_1
    invoke-direct {p0, p1, v4, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v3

    if-eqz v3, :cond_1

    mul-int/lit8 v2, v2, 0x35

    .line 458
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(Ljava/lang/Object;J)J

    move-result-wide v3

    invoke-static {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza(J)I

    move-result v3

    goto/16 :goto_2

    .line 455
    :pswitch_2
    invoke-direct {p0, p1, v4, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v3

    if-eqz v3, :cond_1

    mul-int/lit8 v2, v2, 0x35

    .line 456
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v3

    goto/16 :goto_2

    .line 453
    :pswitch_3
    invoke-direct {p0, p1, v4, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v3

    if-eqz v3, :cond_1

    mul-int/lit8 v2, v2, 0x35

    .line 454
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(Ljava/lang/Object;J)J

    move-result-wide v3

    invoke-static {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza(J)I

    move-result v3

    goto/16 :goto_2

    .line 451
    :pswitch_4
    invoke-direct {p0, p1, v4, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v3

    if-eqz v3, :cond_1

    mul-int/lit8 v2, v2, 0x35

    .line 452
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v3

    goto/16 :goto_2

    .line 449
    :pswitch_5
    invoke-direct {p0, p1, v4, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v3

    if-eqz v3, :cond_1

    mul-int/lit8 v2, v2, 0x35

    .line 450
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v3

    goto/16 :goto_2

    .line 447
    :pswitch_6
    invoke-direct {p0, p1, v4, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v3

    if-eqz v3, :cond_1

    mul-int/lit8 v2, v2, 0x35

    .line 448
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v3

    goto/16 :goto_2

    .line 445
    :pswitch_7
    invoke-direct {p0, p1, v4, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v3

    if-eqz v3, :cond_1

    mul-int/lit8 v2, v2, 0x35

    .line 446
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/Object;->hashCode()I

    move-result v3

    goto/16 :goto_2

    .line 441
    :pswitch_8
    invoke-direct {p0, p1, v4, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v3

    if-eqz v3, :cond_1

    .line 442
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v3

    mul-int/lit8 v2, v2, 0x35

    .line 443
    invoke-virtual {v3}, Ljava/lang/Object;->hashCode()I

    move-result v3

    goto/16 :goto_2

    .line 438
    :pswitch_9
    invoke-direct {p0, p1, v4, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v3

    if-eqz v3, :cond_1

    mul-int/lit8 v2, v2, 0x35

    .line 440
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/String;

    invoke-virtual {v3}, Ljava/lang/String;->hashCode()I

    move-result v3

    goto/16 :goto_2

    .line 436
    :pswitch_a
    invoke-direct {p0, p1, v4, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v3

    if-eqz v3, :cond_1

    mul-int/lit8 v2, v2, 0x35

    .line 437
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(Ljava/lang/Object;J)Z

    move-result v3

    invoke-static {v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza(Z)I

    move-result v3

    goto/16 :goto_2

    .line 434
    :pswitch_b
    invoke-direct {p0, p1, v4, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v3

    if-eqz v3, :cond_1

    mul-int/lit8 v2, v2, 0x35

    .line 435
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v3

    goto/16 :goto_2

    .line 432
    :pswitch_c
    invoke-direct {p0, p1, v4, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v3

    if-eqz v3, :cond_1

    mul-int/lit8 v2, v2, 0x35

    .line 433
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(Ljava/lang/Object;J)J

    move-result-wide v3

    invoke-static {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza(J)I

    move-result v3

    goto/16 :goto_2

    .line 430
    :pswitch_d
    invoke-direct {p0, p1, v4, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v3

    if-eqz v3, :cond_1

    mul-int/lit8 v2, v2, 0x35

    .line 431
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;J)I

    move-result v3

    goto/16 :goto_2

    .line 428
    :pswitch_e
    invoke-direct {p0, p1, v4, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v3

    if-eqz v3, :cond_1

    mul-int/lit8 v2, v2, 0x35

    .line 429
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(Ljava/lang/Object;J)J

    move-result-wide v3

    invoke-static {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza(J)I

    move-result v3

    goto/16 :goto_2

    .line 426
    :pswitch_f
    invoke-direct {p0, p1, v4, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v3

    if-eqz v3, :cond_1

    mul-int/lit8 v2, v2, 0x35

    .line 427
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzd(Ljava/lang/Object;J)J

    move-result-wide v3

    invoke-static {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza(J)I

    move-result v3

    goto/16 :goto_2

    .line 424
    :pswitch_10
    invoke-direct {p0, p1, v4, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v3

    if-eqz v3, :cond_1

    mul-int/lit8 v2, v2, 0x35

    .line 425
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(Ljava/lang/Object;J)F

    move-result v3

    invoke-static {v3}, Ljava/lang/Float;->floatToIntBits(F)I

    move-result v3

    goto/16 :goto_2

    .line 421
    :pswitch_11
    invoke-direct {p0, p1, v4, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v3

    if-eqz v3, :cond_1

    mul-int/lit8 v2, v2, 0x35

    .line 423
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;J)D

    move-result-wide v3

    invoke-static {v3, v4}, Ljava/lang/Double;->doubleToLongBits(D)J

    move-result-wide v3

    invoke-static {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza(J)I

    move-result v3

    goto/16 :goto_2

    :pswitch_12
    mul-int/lit8 v2, v2, 0x35

    .line 419
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/Object;->hashCode()I

    move-result v3

    goto/16 :goto_2

    :pswitch_13
    mul-int/lit8 v2, v2, 0x35

    .line 417
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/Object;->hashCode()I

    move-result v3

    goto/16 :goto_2

    .line 412
    :pswitch_14
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v3

    if-eqz v3, :cond_0

    .line 414
    invoke-virtual {v3}, Ljava/lang/Object;->hashCode()I

    move-result v7

    goto :goto_1

    :pswitch_15
    mul-int/lit8 v2, v2, 0x35

    .line 409
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v3

    invoke-static {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza(J)I

    move-result v3

    goto/16 :goto_2

    :pswitch_16
    mul-int/lit8 v2, v2, 0x35

    .line 407
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v3

    goto/16 :goto_2

    :pswitch_17
    mul-int/lit8 v2, v2, 0x35

    .line 405
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v3

    invoke-static {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza(J)I

    move-result v3

    goto/16 :goto_2

    :pswitch_18
    mul-int/lit8 v2, v2, 0x35

    .line 403
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v3

    goto/16 :goto_2

    :pswitch_19
    mul-int/lit8 v2, v2, 0x35

    .line 401
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v3

    goto/16 :goto_2

    :pswitch_1a
    mul-int/lit8 v2, v2, 0x35

    .line 399
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v3

    goto/16 :goto_2

    :pswitch_1b
    mul-int/lit8 v2, v2, 0x35

    .line 397
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/Object;->hashCode()I

    move-result v3

    goto/16 :goto_2

    .line 392
    :pswitch_1c
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v3

    if-eqz v3, :cond_0

    .line 394
    invoke-virtual {v3}, Ljava/lang/Object;->hashCode()I

    move-result v7

    :cond_0
    :goto_1
    mul-int/lit8 v2, v2, 0x35

    add-int/2addr v2, v7

    goto :goto_3

    :pswitch_1d
    mul-int/lit8 v2, v2, 0x35

    .line 389
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/String;

    invoke-virtual {v3}, Ljava/lang/String;->hashCode()I

    move-result v3

    goto :goto_2

    :pswitch_1e
    mul-int/lit8 v2, v2, 0x35

    .line 387
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzh(Ljava/lang/Object;J)Z

    move-result v3

    invoke-static {v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza(Z)I

    move-result v3

    goto :goto_2

    :pswitch_1f
    mul-int/lit8 v2, v2, 0x35

    .line 385
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v3

    goto :goto_2

    :pswitch_20
    mul-int/lit8 v2, v2, 0x35

    .line 383
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v3

    invoke-static {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza(J)I

    move-result v3

    goto :goto_2

    :pswitch_21
    mul-int/lit8 v2, v2, 0x35

    .line 381
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v3

    goto :goto_2

    :pswitch_22
    mul-int/lit8 v2, v2, 0x35

    .line 379
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v3

    invoke-static {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza(J)I

    move-result v3

    goto :goto_2

    :pswitch_23
    mul-int/lit8 v2, v2, 0x35

    .line 377
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v3

    invoke-static {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza(J)I

    move-result v3

    goto :goto_2

    :pswitch_24
    mul-int/lit8 v2, v2, 0x35

    .line 375
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzb(Ljava/lang/Object;J)F

    move-result v3

    invoke-static {v3}, Ljava/lang/Float;->floatToIntBits(F)I

    move-result v3

    goto :goto_2

    :pswitch_25
    mul-int/lit8 v2, v2, 0x35

    .line 372
    invoke-static {p1, v5, v6}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;J)D

    move-result-wide v3

    invoke-static {v3, v4}, Ljava/lang/Double;->doubleToLongBits(D)J

    move-result-wide v3

    .line 373
    invoke-static {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza(J)I

    move-result v3

    :goto_2
    add-int/2addr v2, v3

    :cond_1
    :goto_3
    add-int/lit8 v1, v1, 0x3

    goto/16 :goto_0

    :cond_2
    mul-int/lit8 v2, v2, 0x35

    .line 463
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzp:Lcom/google/android/gms/internal/firebase-auth-api/zzanu;

    invoke-virtual {v0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zzd(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->hashCode()I

    move-result v0

    add-int/2addr v2, v0

    .line 464
    iget-boolean v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzh:Z

    if-eqz v0, :cond_3

    mul-int/lit8 v2, v2, 0x35

    .line 465
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzq:Lcom/google/android/gms/internal/firebase-auth-api/zzakw;

    invoke-virtual {v0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakw;->zza(Ljava/lang/Object;)Lcom/google/android/gms/internal/firebase-auth-api/zzakx;

    move-result-object p1

    invoke-virtual {p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakx;->hashCode()I

    move-result p1

    add-int/2addr v2, p1

    :cond_3
    return v2

    nop

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_25
        :pswitch_24
        :pswitch_23
        :pswitch_22
        :pswitch_21
        :pswitch_20
        :pswitch_1f
        :pswitch_1e
        :pswitch_1d
        :pswitch_1c
        :pswitch_1b
        :pswitch_1a
        :pswitch_19
        :pswitch_18
        :pswitch_17
        :pswitch_16
        :pswitch_15
        :pswitch_14
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_13
        :pswitch_12
        :pswitch_11
        :pswitch_10
        :pswitch_f
        :pswitch_e
        :pswitch_d
        :pswitch_c
        :pswitch_b
        :pswitch_a
        :pswitch_9
        :pswitch_8
        :pswitch_7
        :pswitch_6
        :pswitch_5
        :pswitch_4
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method public final zzb(Ljava/lang/Object;Ljava/lang/Object;)Z
    .locals 9
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;TT;)Z"
        }
    .end annotation

    .line 2958
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    array-length v0, v0

    const/4 v1, 0x0

    move v2, v1

    :goto_0
    const/4 v3, 0x1

    if-ge v2, v0, :cond_3

    .line 2961
    invoke-direct {p0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(I)I

    move-result v4

    const v5, 0xfffff

    and-int v6, v4, v5

    int-to-long v6, v6

    const/high16 v8, 0xff00000

    and-int/2addr v4, v8

    ushr-int/lit8 v4, v4, 0x14

    packed-switch v4, :pswitch_data_0

    goto/16 :goto_2

    .line 3035
    :pswitch_0
    invoke-direct {p0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb(I)I

    move-result v4

    and-int/2addr v4, v5

    int-to-long v4, v4

    .line 3036
    invoke-static {p1, v4, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v8

    .line 3037
    invoke-static {p2, v4, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v4

    if-ne v8, v4, :cond_0

    .line 3039
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v4

    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    .line 3040
    invoke-static {v4, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v4

    if-nez v4, :cond_1

    goto/16 :goto_1

    .line 3032
    :pswitch_1
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v3

    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v4

    .line 3033
    invoke-static {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v3

    goto/16 :goto_2

    .line 3029
    :pswitch_2
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v3

    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v4

    .line 3030
    invoke-static {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v3

    goto/16 :goto_2

    .line 3024
    :pswitch_3
    invoke-direct {p0, p1, p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;Ljava/lang/Object;I)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 3025
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v4

    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    .line 3026
    invoke-static {v4, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v4

    if-nez v4, :cond_1

    goto/16 :goto_1

    .line 3021
    :pswitch_4
    invoke-direct {p0, p1, p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;Ljava/lang/Object;I)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 3022
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v4

    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v6

    cmp-long v4, v4, v6

    if-eqz v4, :cond_1

    goto/16 :goto_1

    .line 3018
    :pswitch_5
    invoke-direct {p0, p1, p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;Ljava/lang/Object;I)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 3019
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v4

    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v5

    if-eq v4, v5, :cond_1

    goto/16 :goto_1

    .line 3015
    :pswitch_6
    invoke-direct {p0, p1, p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;Ljava/lang/Object;I)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 3016
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v4

    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v6

    cmp-long v4, v4, v6

    if-eqz v4, :cond_1

    goto/16 :goto_1

    .line 3012
    :pswitch_7
    invoke-direct {p0, p1, p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;Ljava/lang/Object;I)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 3013
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v4

    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v5

    if-eq v4, v5, :cond_1

    goto/16 :goto_1

    .line 3009
    :pswitch_8
    invoke-direct {p0, p1, p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;Ljava/lang/Object;I)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 3010
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v4

    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v5

    if-eq v4, v5, :cond_1

    goto/16 :goto_1

    .line 3006
    :pswitch_9
    invoke-direct {p0, p1, p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;Ljava/lang/Object;I)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 3007
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v4

    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v5

    if-eq v4, v5, :cond_1

    goto/16 :goto_1

    .line 3002
    :pswitch_a
    invoke-direct {p0, p1, p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;Ljava/lang/Object;I)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 3003
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v4

    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    .line 3004
    invoke-static {v4, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v4

    if-nez v4, :cond_1

    goto/16 :goto_1

    .line 2998
    :pswitch_b
    invoke-direct {p0, p1, p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;Ljava/lang/Object;I)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 2999
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v4

    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    .line 3000
    invoke-static {v4, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v4

    if-nez v4, :cond_1

    goto/16 :goto_1

    .line 2994
    :pswitch_c
    invoke-direct {p0, p1, p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;Ljava/lang/Object;I)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 2995
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v4

    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    .line 2996
    invoke-static {v4, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzand;->zza(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v4

    if-nez v4, :cond_1

    goto/16 :goto_1

    .line 2991
    :pswitch_d
    invoke-direct {p0, p1, p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;Ljava/lang/Object;I)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 2992
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzh(Ljava/lang/Object;J)Z

    move-result v4

    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzh(Ljava/lang/Object;J)Z

    move-result v5

    if-eq v4, v5, :cond_1

    goto/16 :goto_1

    .line 2988
    :pswitch_e
    invoke-direct {p0, p1, p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;Ljava/lang/Object;I)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 2989
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v4

    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v5

    if-eq v4, v5, :cond_1

    goto/16 :goto_1

    .line 2985
    :pswitch_f
    invoke-direct {p0, p1, p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;Ljava/lang/Object;I)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 2986
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v4

    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v6

    cmp-long v4, v4, v6

    if-eqz v4, :cond_1

    goto :goto_1

    .line 2982
    :pswitch_10
    invoke-direct {p0, p1, p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;Ljava/lang/Object;I)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 2983
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v4

    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzc(Ljava/lang/Object;J)I

    move-result v5

    if-eq v4, v5, :cond_1

    goto :goto_1

    .line 2979
    :pswitch_11
    invoke-direct {p0, p1, p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;Ljava/lang/Object;I)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 2980
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v4

    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v6

    cmp-long v4, v4, v6

    if-eqz v4, :cond_1

    goto :goto_1

    .line 2976
    :pswitch_12
    invoke-direct {p0, p1, p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;Ljava/lang/Object;I)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 2977
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v4

    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzd(Ljava/lang/Object;J)J

    move-result-wide v6

    cmp-long v4, v4, v6

    if-eqz v4, :cond_1

    goto :goto_1

    .line 2972
    :pswitch_13
    invoke-direct {p0, p1, p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;Ljava/lang/Object;I)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 2973
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzb(Ljava/lang/Object;J)F

    move-result v4

    invoke-static {v4}, Ljava/lang/Float;->floatToIntBits(F)I

    move-result v4

    .line 2974
    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zzb(Ljava/lang/Object;J)F

    move-result v5

    invoke-static {v5}, Ljava/lang/Float;->floatToIntBits(F)I

    move-result v5

    if-eq v4, v5, :cond_1

    goto :goto_1

    .line 2968
    :pswitch_14
    invoke-direct {p0, p1, p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;Ljava/lang/Object;I)Z

    move-result v4

    if-eqz v4, :cond_0

    .line 2969
    invoke-static {p1, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;J)D

    move-result-wide v4

    invoke-static {v4, v5}, Ljava/lang/Double;->doubleToLongBits(D)J

    move-result-wide v4

    .line 2970
    invoke-static {p2, v6, v7}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zza(Ljava/lang/Object;J)D

    move-result-wide v6

    invoke-static {v6, v7}, Ljava/lang/Double;->doubleToLongBits(D)J

    move-result-wide v6

    cmp-long v4, v4, v6

    if-eqz v4, :cond_1

    :cond_0
    :goto_1
    move v3, v1

    :cond_1
    :goto_2
    if-nez v3, :cond_2

    return v1

    :cond_2
    add-int/lit8 v2, v2, 0x3

    goto/16 :goto_0

    .line 3046
    :cond_3
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzp:Lcom/google/android/gms/internal/firebase-auth-api/zzanu;

    invoke-virtual {v0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zzd(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    .line 3047
    iget-object v2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzp:Lcom/google/android/gms/internal/firebase-auth-api/zzanu;

    invoke-virtual {v2, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zzd(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    .line 3048
    invoke-virtual {v0, v2}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_4

    return v1

    .line 3050
    :cond_4
    iget-boolean v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzh:Z

    if-eqz v0, :cond_5

    .line 3051
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzq:Lcom/google/android/gms/internal/firebase-auth-api/zzakw;

    invoke-virtual {v0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakw;->zza(Ljava/lang/Object;)Lcom/google/android/gms/internal/firebase-auth-api/zzakx;

    move-result-object p1

    .line 3052
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzq:Lcom/google/android/gms/internal/firebase-auth-api/zzakw;

    invoke-virtual {v0, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakw;->zza(Ljava/lang/Object;)Lcom/google/android/gms/internal/firebase-auth-api/zzakx;

    move-result-object p2

    .line 3053
    invoke-virtual {p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakx;->equals(Ljava/lang/Object;)Z

    move-result p1

    return p1

    :cond_5
    return v3

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_14
        :pswitch_13
        :pswitch_12
        :pswitch_11
        :pswitch_10
        :pswitch_f
        :pswitch_e
        :pswitch_d
        :pswitch_c
        :pswitch_b
        :pswitch_a
        :pswitch_9
        :pswitch_8
        :pswitch_7
        :pswitch_6
        :pswitch_5
        :pswitch_4
        :pswitch_3
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_2
        :pswitch_1
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_0
    .end packed-switch
.end method

.method public final zzd(Ljava/lang/Object;)V
    .locals 7
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;)V"
        }
    .end annotation

    .line 1469
    invoke-static {p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzg(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_0

    goto/16 :goto_2

    .line 1471
    :cond_0
    instance-of v0, p1, Lcom/google/android/gms/internal/firebase-auth-api/zzalf;

    const/4 v1, 0x0

    if-eqz v0, :cond_1

    .line 1472
    move-object v0, p1

    check-cast v0, Lcom/google/android/gms/internal/firebase-auth-api/zzalf;

    const v2, 0x7fffffff

    .line 1474
    invoke-virtual {v0, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzajm;->zzb(I)V

    .line 1476
    iput v1, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzalf;->zza:I

    .line 1477
    invoke-virtual {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzalf;->zzu()V

    .line 1478
    :cond_1
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    array-length v0, v0

    :goto_0
    if-ge v1, v0, :cond_5

    .line 1480
    invoke-direct {p0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(I)I

    move-result v2

    const v3, 0xfffff

    and-int/2addr v3, v2

    int-to-long v3, v3

    const/high16 v5, 0xff00000

    and-int/2addr v2, v5

    ushr-int/lit8 v2, v2, 0x14

    const/16 v5, 0x9

    if-eq v2, v5, :cond_3

    const/16 v5, 0x3c

    if-eq v2, v5, :cond_2

    const/16 v5, 0x44

    if-eq v2, v5, :cond_2

    packed-switch v2, :pswitch_data_0

    goto :goto_1

    .line 1495
    :pswitch_0
    sget-object v2, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb:Lsun/misc/Unsafe;

    invoke-virtual {v2, p1, v3, v4}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v5

    if-eqz v5, :cond_4

    .line 1497
    iget-object v6, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    invoke-interface {v6, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamf;->zzc(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v5

    invoke-virtual {v2, p1, v3, v4, v5}, Lsun/misc/Unsafe;->putObject(Ljava/lang/Object;JLjava/lang/Object;)V

    goto :goto_1

    .line 1493
    :pswitch_1
    iget-object v2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzo:Lcom/google/android/gms/internal/firebase-auth-api/zzalw;

    invoke-interface {v2, p1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzalw;->zzb(Ljava/lang/Object;J)V

    goto :goto_1

    .line 1490
    :cond_2
    iget-object v2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v2, v2, v1

    .line 1491
    invoke-direct {p0, p1, v2, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result v2

    if-eqz v2, :cond_4

    .line 1492
    invoke-direct {p0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v2

    sget-object v5, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb:Lsun/misc/Unsafe;

    invoke-virtual {v5, p1, v3, v4}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v3

    invoke-interface {v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zzd(Ljava/lang/Object;)V

    goto :goto_1

    .line 1487
    :cond_3
    :pswitch_2
    invoke-direct {p0, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;I)Z

    move-result v2

    if-eqz v2, :cond_4

    .line 1488
    invoke-direct {p0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v2

    sget-object v5, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb:Lsun/misc/Unsafe;

    invoke-virtual {v5, p1, v3, v4}, Lsun/misc/Unsafe;->getObject(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v3

    invoke-interface {v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zzd(Ljava/lang/Object;)V

    :cond_4
    :goto_1
    add-int/lit8 v1, v1, 0x3

    goto :goto_0

    .line 1499
    :cond_5
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzp:Lcom/google/android/gms/internal/firebase-auth-api/zzanu;

    invoke-virtual {v0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzanu;->zzf(Ljava/lang/Object;)V

    .line 1500
    iget-boolean v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzh:Z

    if-eqz v0, :cond_6

    .line 1501
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzq:Lcom/google/android/gms/internal/firebase-auth-api/zzakw;

    invoke-virtual {v0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakw;->zzc(Ljava/lang/Object;)V

    :cond_6
    :goto_2
    return-void

    nop

    :pswitch_data_0
    .packed-switch 0x11
        :pswitch_2
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method public final zze(Ljava/lang/Object;)Z
    .locals 14
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;)Z"
        }
    .end annotation

    const v0, 0xfffff

    const/4 v1, 0x0

    move v3, v0

    move v2, v1

    move v4, v2

    .line 3097
    :goto_0
    iget v5, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzl:I

    const/4 v6, 0x1

    if-ge v2, v5, :cond_c

    .line 3098
    iget-object v5, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzk:[I

    aget v9, v5, v2

    .line 3100
    iget-object v5, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    aget v5, v5, v9

    .line 3102
    invoke-direct {p0, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(I)I

    move-result v13

    .line 3103
    iget-object v7, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc:[I

    add-int/lit8 v8, v9, 0x2

    aget v7, v7, v8

    and-int v8, v7, v0

    ushr-int/lit8 v7, v7, 0x14

    shl-int v12, v6, v7

    if-eq v8, v3, :cond_1

    if-eq v8, v0, :cond_0

    .line 3109
    sget-object v3, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzb:Lsun/misc/Unsafe;

    int-to-long v6, v8

    invoke-virtual {v3, p1, v6, v7}, Lsun/misc/Unsafe;->getInt(Ljava/lang/Object;J)I

    move-result v4

    :cond_0
    move v11, v4

    move v10, v8

    goto :goto_1

    :cond_1
    move v10, v3

    move v11, v4

    :goto_1
    const/high16 v3, 0x10000000

    and-int/2addr v3, v13

    if-eqz v3, :cond_2

    move-object v7, p0

    move-object v8, p1

    .line 3113
    invoke-direct/range {v7 .. v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result p1

    if-nez p1, :cond_3

    return v1

    :cond_2
    move-object v7, p0

    move-object v8, p1

    :cond_3
    const/high16 p1, 0xff00000

    and-int/2addr p1, v13

    ushr-int/lit8 p1, p1, 0x14

    const/16 v3, 0x9

    if-eq p1, v3, :cond_a

    const/16 v3, 0x11

    if-eq p1, v3, :cond_a

    const/16 v3, 0x1b

    if-eq p1, v3, :cond_8

    const/16 v3, 0x3c

    if-eq p1, v3, :cond_7

    const/16 v3, 0x44

    if-eq p1, v3, :cond_7

    const/16 v3, 0x31

    if-eq p1, v3, :cond_8

    const/16 v3, 0x32

    if-eq p1, v3, :cond_4

    goto/16 :goto_3

    .line 3139
    :cond_4
    iget-object p1, v7, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    and-int v3, v13, v0

    int-to-long v3, v3

    .line 3141
    invoke-static {v8, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object v3

    invoke-interface {p1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamf;->zzd(Ljava/lang/Object;)Ljava/util/Map;

    move-result-object p1

    .line 3142
    invoke-interface {p1}, Ljava/util/Map;->isEmpty()Z

    move-result v3

    if-nez v3, :cond_b

    .line 3143
    invoke-direct {p0, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzf(I)Ljava/lang/Object;

    move-result-object v3

    .line 3144
    iget-object v4, v7, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzr:Lcom/google/android/gms/internal/firebase-auth-api/zzamf;

    invoke-interface {v4, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzamf;->zza(Ljava/lang/Object;)Lcom/google/android/gms/internal/firebase-auth-api/zzamd;

    move-result-object v3

    .line 3145
    iget-object v3, v3, Lcom/google/android/gms/internal/firebase-auth-api/zzamd;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzaog;

    invoke-virtual {v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzaog;->zzb()Lcom/google/android/gms/internal/firebase-auth-api/zzaoj;

    move-result-object v3

    sget-object v4, Lcom/google/android/gms/internal/firebase-auth-api/zzaoj;->zzi:Lcom/google/android/gms/internal/firebase-auth-api/zzaoj;

    if-ne v3, v4, :cond_b

    .line 3147
    invoke-interface {p1}, Ljava/util/Map;->values()Ljava/util/Collection;

    move-result-object p1

    invoke-interface {p1}, Ljava/util/Collection;->iterator()Ljava/util/Iterator;

    move-result-object p1

    const/4 v3, 0x0

    :cond_5
    invoke-interface {p1}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-eqz v4, :cond_b

    invoke-interface {p1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v4

    if-nez v3, :cond_6

    .line 3149
    invoke-static {}, Lcom/google/android/gms/internal/firebase-auth-api/zzamx;->zza()Lcom/google/android/gms/internal/firebase-auth-api/zzamx;

    move-result-object v3

    invoke-virtual {v4}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v5

    invoke-virtual {v3, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzamx;->zza(Ljava/lang/Class;)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v3

    .line 3150
    :cond_6
    invoke-interface {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zze(Ljava/lang/Object;)Z

    move-result v4

    if-nez v4, :cond_5

    return v1

    .line 3135
    :cond_7
    invoke-direct {p0, v8, v5, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzc(Ljava/lang/Object;II)Z

    move-result p1

    if-eqz p1, :cond_b

    .line 3136
    invoke-direct {p0, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object p1

    invoke-static {v8, v13, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;ILcom/google/android/gms/internal/firebase-auth-api/zzanb;)Z

    move-result p1

    if-nez p1, :cond_b

    return v1

    :cond_8
    and-int p1, v13, v0

    int-to-long v3, p1

    .line 3124
    invoke-static {v8, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzanz;->zze(Ljava/lang/Object;J)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/util/List;

    .line 3125
    invoke-interface {p1}, Ljava/util/List;->isEmpty()Z

    move-result v3

    if-nez v3, :cond_b

    .line 3126
    invoke-direct {p0, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object v3

    move v4, v1

    .line 3127
    :goto_2
    invoke-interface {p1}, Ljava/util/List;->size()I

    move-result v5

    if-ge v4, v5, :cond_b

    .line 3128
    invoke-interface {p1, v4}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v5

    .line 3129
    invoke-interface {v3, v5}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zze(Ljava/lang/Object;)Z

    move-result v5

    if-nez v5, :cond_9

    return v1

    :cond_9
    add-int/lit8 v4, v4, 0x1

    goto :goto_2

    .line 3118
    :cond_a
    invoke-direct/range {v7 .. v12}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;IIII)Z

    move-result p1

    if-eqz p1, :cond_b

    .line 3119
    invoke-direct {p0, v9}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zze(I)Lcom/google/android/gms/internal/firebase-auth-api/zzanb;

    move-result-object p1

    invoke-static {v8, v13, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zza(Ljava/lang/Object;ILcom/google/android/gms/internal/firebase-auth-api/zzanb;)Z

    move-result p1

    if-nez p1, :cond_b

    return v1

    :cond_b
    :goto_3
    add-int/lit8 v2, v2, 0x1

    move-object p1, v8

    move v3, v10

    move v4, v11

    goto/16 :goto_0

    :cond_c
    move-object v7, p0

    move-object v8, p1

    .line 3157
    iget-boolean p1, v7, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzh:Z

    if-eqz p1, :cond_d

    .line 3158
    iget-object p1, v7, Lcom/google/android/gms/internal/firebase-auth-api/zzamq;->zzq:Lcom/google/android/gms/internal/firebase-auth-api/zzakw;

    invoke-virtual {p1, v8}, Lcom/google/android/gms/internal/firebase-auth-api/zzakw;->zza(Ljava/lang/Object;)Lcom/google/android/gms/internal/firebase-auth-api/zzakx;

    move-result-object p1

    invoke-virtual {p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakx;->zzg()Z

    move-result p1

    if-nez p1, :cond_d

    return v1

    :cond_d
    return v6
.end method
