.class abstract Lcom/google/android/gms/internal/firebase-auth-api/zzaa;
.super Lcom/google/android/gms/internal/firebase-auth-api/zzd;
.source "com.google.firebase:firebase-auth@@24.0.1"


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "Lcom/google/android/gms/internal/firebase-auth-api/zzd<",
        "Ljava/lang/String;",
        ">;"
    }
.end annotation


# instance fields
.field final zza:Ljava/lang/CharSequence;

.field private final zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzf;

.field private final zzc:Z

.field private zzd:I

.field private zze:I


# direct methods
.method constructor <init>(Lcom/google/android/gms/internal/firebase-auth-api/zzt;Ljava/lang/CharSequence;)V
    .locals 2

    .line 28
    invoke-direct {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzd;-><init>()V

    const/4 v0, 0x0

    .line 29
    iput v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zzd:I

    .line 30
    invoke-static {p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzt;->zzb(Lcom/google/android/gms/internal/firebase-auth-api/zzt;)Lcom/google/android/gms/internal/firebase-auth-api/zzf;

    move-result-object v1

    iput-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzf;

    .line 33
    iput-boolean v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zzc:Z

    .line 34
    invoke-static {p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzt;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzt;)I

    move-result p1

    iput p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zze:I

    .line 35
    iput-object p2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zza:Ljava/lang/CharSequence;

    return-void
.end method


# virtual methods
.method abstract zza(I)I
.end method

.method protected final synthetic zza()Ljava/lang/Object;
    .locals 6

    .line 2
    iget v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zzd:I

    .line 3
    :cond_0
    :goto_0
    iget v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zzd:I

    const/4 v2, -0x1

    if-eq v1, v2, :cond_7

    .line 5
    invoke-virtual {p0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zzb(I)I

    move-result v1

    if-ne v1, v2, :cond_1

    .line 7
    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zza:Ljava/lang/CharSequence;

    invoke-interface {v1}, Ljava/lang/CharSequence;->length()I

    move-result v1

    .line 8
    iput v2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zzd:I

    goto :goto_1

    .line 10
    :cond_1
    invoke-virtual {p0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zza(I)I

    move-result v3

    iput v3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zzd:I

    .line 11
    :goto_1
    iget v3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zzd:I

    if-ne v3, v0, :cond_2

    add-int/lit8 v3, v3, 0x1

    .line 12
    iput v3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zzd:I

    .line 13
    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zza:Ljava/lang/CharSequence;

    invoke-interface {v1}, Ljava/lang/CharSequence;->length()I

    move-result v1

    if-le v3, v1, :cond_0

    .line 14
    iput v2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zzd:I

    goto :goto_0

    :cond_2
    :goto_2
    if-ge v0, v1, :cond_3

    .line 15
    iget-object v3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzf;

    iget-object v4, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zza:Ljava/lang/CharSequence;

    invoke-interface {v4, v0}, Ljava/lang/CharSequence;->charAt(I)C

    move-result v4

    invoke-virtual {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzf;->zza(C)Z

    move-result v3

    if-eqz v3, :cond_3

    add-int/lit8 v0, v0, 0x1

    goto :goto_2

    :cond_3
    :goto_3
    if-le v1, v0, :cond_4

    .line 17
    iget-object v3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzf;

    iget-object v4, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zza:Ljava/lang/CharSequence;

    add-int/lit8 v5, v1, -0x1

    invoke-interface {v4, v5}, Ljava/lang/CharSequence;->charAt(I)C

    move-result v4

    invoke-virtual {v3, v4}, Lcom/google/android/gms/internal/firebase-auth-api/zzf;->zza(C)Z

    move-result v3

    if-eqz v3, :cond_4

    add-int/lit8 v1, v1, -0x1

    goto :goto_3

    .line 19
    :cond_4
    iget v3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zze:I

    const/4 v4, 0x1

    if-ne v3, v4, :cond_5

    .line 20
    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zza:Ljava/lang/CharSequence;

    invoke-interface {v1}, Ljava/lang/CharSequence;->length()I

    move-result v1

    .line 21
    iput v2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zzd:I

    :goto_4
    if-le v1, v0, :cond_6

    .line 22
    iget-object v2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzf;

    iget-object v3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zza:Ljava/lang/CharSequence;

    add-int/lit8 v4, v1, -0x1

    invoke-interface {v3, v4}, Ljava/lang/CharSequence;->charAt(I)C

    move-result v3

    invoke-virtual {v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzf;->zza(C)Z

    move-result v2

    if-eqz v2, :cond_6

    add-int/lit8 v1, v1, -0x1

    goto :goto_4

    :cond_5
    sub-int/2addr v3, v4

    .line 24
    iput v3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zze:I

    .line 25
    :cond_6
    iget-object v2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzaa;->zza:Ljava/lang/CharSequence;

    invoke-interface {v2, v0, v1}, Ljava/lang/CharSequence;->subSequence(II)Ljava/lang/CharSequence;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0

    .line 26
    :cond_7
    invoke-virtual {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzd;->zzb()Ljava/lang/Object;

    const/4 v0, 0x0

    return-object v0
.end method

.method abstract zzb(I)I
.end method
