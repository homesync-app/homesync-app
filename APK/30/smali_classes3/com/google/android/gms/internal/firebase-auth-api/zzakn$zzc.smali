.class final Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;
.super Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;
.source "com.google.firebase:firebase-auth@@24.0.1"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/google/android/gms/internal/firebase-auth-api/zzakn;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1a
    name = "zzc"
.end annotation


# instance fields
.field private final zzf:Ljava/io/OutputStream;


# direct methods
.method constructor <init>(Ljava/io/OutputStream;I)V
    .locals 0

    .line 1
    invoke-direct {p0, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;-><init>(I)V

    if-eqz p1, :cond_0

    .line 4
    iput-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzf:Ljava/io/OutputStream;

    return-void

    .line 3
    :cond_0
    new-instance p1, Ljava/lang/NullPointerException;

    const-string p2, "out"

    invoke-direct {p1, p2}, Ljava/lang/NullPointerException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method private final zzc([BII)V
    .locals 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 19
    iget v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzc:I

    iget v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    sub-int/2addr v0, v1

    if-lt v0, p3, :cond_0

    .line 20
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzb:[B

    iget v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    invoke-static {p1, p2, v0, v1, p3}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 21
    iget p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    add-int/2addr p1, p3

    iput p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    goto :goto_0

    .line 23
    :cond_0
    iget v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzc:I

    iget v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    sub-int/2addr v0, v1

    .line 24
    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzb:[B

    iget v2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    invoke-static {p1, p2, v1, v2, v0}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    add-int/2addr p2, v0

    sub-int/2addr p3, v0

    .line 27
    iget v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzc:I

    iput v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    .line 28
    iget v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zze:I

    add-int/2addr v1, v0

    iput v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zze:I

    .line 29
    invoke-direct {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zze()V

    .line 30
    iget v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzc:I

    if-gt p3, v0, :cond_1

    .line 31
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzb:[B

    const/4 v1, 0x0

    invoke-static {p1, p2, v0, v1, p3}, Ljava/lang/System;->arraycopy(Ljava/lang/Object;ILjava/lang/Object;II)V

    .line 32
    iput p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    goto :goto_0

    .line 33
    :cond_1
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzf:Ljava/io/OutputStream;

    invoke-virtual {v0, p1, p2, p3}, Ljava/io/OutputStream;->write([BII)V

    .line 34
    :goto_0
    iget p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zze:I

    add-int/2addr p1, p3

    iput p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zze:I

    return-void
.end method

.method private final zze()V
    .locals 4
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 6
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzf:Ljava/io/OutputStream;

    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzb:[B

    iget v2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    const/4 v3, 0x0

    invoke-virtual {v0, v1, v3, v2}, Ljava/io/OutputStream;->write([BII)V

    .line 7
    iput v3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    return-void
.end method

.method private final zzp(I)V
    .locals 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 12
    iget v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzc:I

    iget v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    sub-int/2addr v0, v1

    if-ge v0, p1, :cond_0

    .line 13
    invoke-direct {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zze()V

    :cond_0
    return-void
.end method


# virtual methods
.method public final zza(B)V
    .locals 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 15
    iget v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    iget v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzc:I

    if-ne v0, v1, :cond_0

    .line 16
    invoke-direct {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zze()V

    .line 17
    :cond_0
    invoke-virtual {p0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzb(B)V

    return-void
.end method

.method public final zza([BII)V
    .locals 0
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 74
    invoke-direct {p0, p1, p2, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzc([BII)V

    return-void
.end method

.method public final zzb(ILcom/google/android/gms/internal/firebase-auth-api/zzamm;)V
    .locals 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/4 v0, 0x1

    const/4 v1, 0x3

    .line 79
    invoke-virtual {p0, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    const/4 v2, 0x2

    .line 80
    invoke-virtual {p0, v2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzk(II)V

    .line 82
    invoke-virtual {p0, v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    .line 83
    invoke-virtual {p0, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(Lcom/google/android/gms/internal/firebase-auth-api/zzamm;)V

    const/4 p1, 0x4

    .line 84
    invoke-virtual {p0, v0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    return-void
.end method

.method public final zzb(ILjava/lang/String;)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/4 v0, 0x2

    .line 91
    invoke-virtual {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    .line 92
    invoke-virtual {p0, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(Ljava/lang/String;)V

    return-void
.end method

.method public final zzb(IZ)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/16 v0, 0xb

    .line 36
    invoke-direct {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzp(I)V

    const/4 v0, 0x0

    .line 37
    invoke-virtual {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzl(II)V

    int-to-byte p1, p2

    .line 38
    invoke-virtual {p0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzb(B)V

    return-void
.end method

.method public final zzb(Lcom/google/android/gms/internal/firebase-auth-api/zzajv;)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 46
    invoke-virtual {p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;->zzb()I

    move-result v0

    invoke-virtual {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 47
    invoke-virtual {p1, p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzajw;)V

    return-void
.end method

.method public final zzb(Lcom/google/android/gms/internal/firebase-auth-api/zzamm;)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 76
    invoke-interface {p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzamm;->zzl()I

    move-result v0

    invoke-virtual {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 77
    invoke-interface {p1, p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzamm;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzakn;)V

    return-void
.end method

.method public final zzb(Ljava/lang/String;)V
    .locals 6
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 94
    :try_start_0
    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v0

    mul-int/lit8 v0, v0, 0x3

    .line 95
    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzi(I)I

    move-result v1

    add-int v2, v1, v0

    .line 96
    iget v3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzc:I

    if-le v2, v3, :cond_0

    .line 97
    new-array v1, v0, [B

    const/4 v2, 0x0

    .line 98
    invoke-static {p1, v1, v2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzaoa;->zza(Ljava/lang/String;[BII)I

    move-result v0

    .line 99
    invoke-virtual {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 100
    invoke-virtual {p0, v1, v2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzajw;->zza([BII)V

    return-void

    .line 102
    :cond_0
    iget v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzc:I

    iget v3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    sub-int/2addr v0, v3

    if-le v2, v0, :cond_1

    .line 103
    invoke-direct {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zze()V

    .line 104
    :cond_1
    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v0

    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzi(I)I

    move-result v0

    .line 105
    iget v2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I
    :try_end_0
    .catch Lcom/google/android/gms/internal/firebase-auth-api/zzaod; {:try_start_0 .. :try_end_0} :catch_2

    if-ne v0, v1, :cond_2

    add-int v1, v2, v0

    .line 107
    :try_start_1
    iput v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    .line 108
    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzb:[B

    iget v3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    iget v4, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzc:I

    iget v5, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    sub-int/2addr v4, v5

    invoke-static {p1, v1, v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzaoa;->zza(Ljava/lang/String;[BII)I

    move-result v1

    .line 109
    iput v2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    sub-int v3, v1, v2

    sub-int/2addr v3, v0

    .line 111
    invoke-virtual {p0, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzo(I)V

    .line 112
    iput v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    goto :goto_0

    .line 114
    :cond_2
    invoke-static {p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzaoa;->zza(Ljava/lang/String;)I

    move-result v3

    .line 115
    invoke-virtual {p0, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzo(I)V

    .line 116
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzb:[B

    iget v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    invoke-static {p1, v0, v1, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzaoa;->zza(Ljava/lang/String;[BII)I

    move-result v0

    iput v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    .line 117
    :goto_0
    iget v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zze:I

    add-int/2addr v0, v3

    iput v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zze:I
    :try_end_1
    .catch Lcom/google/android/gms/internal/firebase-auth-api/zzaod; {:try_start_1 .. :try_end_1} :catch_1
    .catch Ljava/lang/ArrayIndexOutOfBoundsException; {:try_start_1 .. :try_end_1} :catch_0

    return-void

    :catch_0
    move-exception v0

    .line 124
    :try_start_2
    new-instance v1, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzd;

    invoke-direct {v1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzd;-><init>(Ljava/lang/Throwable;)V

    throw v1

    :catch_1
    move-exception v0

    .line 120
    iget v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zze:I

    iget v3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    sub-int/2addr v3, v2

    sub-int/2addr v1, v3

    iput v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zze:I

    .line 121
    iput v2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    .line 122
    throw v0
    :try_end_2
    .catch Lcom/google/android/gms/internal/firebase-auth-api/zzaod; {:try_start_2 .. :try_end_2} :catch_2

    :catch_2
    move-exception v0

    .line 126
    invoke-virtual {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(Ljava/lang/String;Lcom/google/android/gms/internal/firebase-auth-api/zzaod;)V

    return-void
.end method

.method public final zzb([BII)V
    .locals 0
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 40
    invoke-virtual {p0, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    const/4 p2, 0x0

    .line 41
    invoke-direct {p0, p1, p2, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzc([BII)V

    return-void
.end method

.method public final zzc()V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 9
    iget v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzd:I

    if-lez v0, :cond_0

    .line 10
    invoke-direct {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zze()V

    :cond_0
    return-void
.end method

.method public final zzc(ILcom/google/android/gms/internal/firebase-auth-api/zzajv;)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/4 v0, 0x2

    .line 43
    invoke-virtual {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    .line 44
    invoke-virtual {p0, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(Lcom/google/android/gms/internal/firebase-auth-api/zzajv;)V

    return-void
.end method

.method public final zzd(ILcom/google/android/gms/internal/firebase-auth-api/zzajv;)V
    .locals 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/4 v0, 0x1

    const/4 v1, 0x3

    .line 86
    invoke-virtual {p0, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    const/4 v2, 0x2

    .line 87
    invoke-virtual {p0, v2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzk(II)V

    .line 88
    invoke-virtual {p0, v1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzc(ILcom/google/android/gms/internal/firebase-auth-api/zzajv;)V

    const/4 p1, 0x4

    .line 89
    invoke-virtual {p0, v0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    return-void
.end method

.method public final zzf(IJ)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/16 v0, 0x12

    .line 56
    invoke-direct {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzp(I)V

    const/4 v0, 0x1

    .line 57
    invoke-virtual {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzl(II)V

    .line 58
    invoke-virtual {p0, p2, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzi(J)V

    return-void
.end method

.method public final zzf(J)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/16 v0, 0x8

    .line 60
    invoke-direct {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzp(I)V

    .line 61
    invoke-virtual {p0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzi(J)V

    return-void
.end method

.method public final zzg(II)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/16 v0, 0xe

    .line 49
    invoke-direct {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzp(I)V

    const/4 v0, 0x5

    .line 50
    invoke-virtual {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzl(II)V

    .line 51
    invoke-virtual {p0, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzn(I)V

    return-void
.end method

.method public final zzh(II)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/16 v0, 0x14

    .line 63
    invoke-direct {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzp(I)V

    const/4 v0, 0x0

    .line 64
    invoke-virtual {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzl(II)V

    if-ltz p2, :cond_0

    .line 67
    invoke-virtual {p0, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzo(I)V

    return-void

    :cond_0
    int-to-long p1, p2

    .line 68
    invoke-virtual {p0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzj(J)V

    return-void
.end method

.method public final zzh(IJ)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/16 v0, 0x14

    .line 139
    invoke-direct {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzp(I)V

    const/4 v0, 0x0

    .line 140
    invoke-virtual {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzl(II)V

    .line 141
    invoke-virtual {p0, p2, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzj(J)V

    return-void
.end method

.method public final zzh(J)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/16 v0, 0xa

    .line 143
    invoke-direct {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzp(I)V

    .line 144
    invoke-virtual {p0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzj(J)V

    return-void
.end method

.method public final zzj(I)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/4 v0, 0x4

    .line 53
    invoke-direct {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzp(I)V

    .line 54
    invoke-virtual {p0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzn(I)V

    return-void
.end method

.method public final zzj(II)V
    .locals 0
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    shl-int/lit8 p1, p1, 0x3

    or-int/2addr p1, p2

    .line 130
    invoke-virtual {p0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    return-void
.end method

.method public final zzk(I)V
    .locals 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    if-ltz p1, :cond_0

    .line 71
    invoke-virtual {p0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    return-void

    :cond_0
    int-to-long v0, p1

    .line 72
    invoke-virtual {p0, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(J)V

    return-void
.end method

.method public final zzk(II)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/16 v0, 0x14

    .line 132
    invoke-direct {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzp(I)V

    const/4 v0, 0x0

    .line 133
    invoke-virtual {p0, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzl(II)V

    .line 134
    invoke-virtual {p0, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzo(I)V

    return-void
.end method

.method public final zzm(I)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/4 v0, 0x5

    .line 136
    invoke-direct {p0, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzc;->zzp(I)V

    .line 137
    invoke-virtual {p0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn$zzb;->zzo(I)V

    return-void
.end method
