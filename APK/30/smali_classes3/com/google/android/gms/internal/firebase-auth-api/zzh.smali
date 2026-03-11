.class final Lcom/google/android/gms/internal/firebase-auth-api/zzh;
.super Lcom/google/android/gms/internal/firebase-auth-api/zzi;
.source "com.google.firebase:firebase-auth@@24.0.1"


# instance fields
.field private final zza:C


# direct methods
.method constructor <init>(C)V
    .locals 0

    .line 11
    invoke-direct {p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzi;-><init>()V

    .line 12
    iput-char p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzh;->zza:C

    return-void
.end method


# virtual methods
.method public final toString()Ljava/lang/String;
    .locals 7

    .line 1
    iget-char v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzh;->zza:C

    const/4 v1, 0x6

    .line 4
    new-array v1, v1, [C

    const/16 v2, 0x5c

    const/4 v3, 0x0

    aput-char v2, v1, v3

    const/4 v2, 0x1

    const/16 v4, 0x75

    aput-char v4, v1, v2

    const/4 v2, 0x2

    aput-char v3, v1, v2

    const/4 v2, 0x3

    aput-char v3, v1, v2

    const/4 v2, 0x4

    aput-char v3, v1, v2

    const/4 v4, 0x5

    aput-char v3, v1, v4

    :goto_0
    if-ge v3, v2, :cond_0

    rsub-int/lit8 v4, v3, 0x5

    and-int/lit8 v5, v0, 0xf

    .line 6
    const-string v6, "0123456789ABCDEF"

    invoke-virtual {v6, v5}, Ljava/lang/String;->charAt(I)C

    move-result v5

    aput-char v5, v1, v4

    shr-int/2addr v0, v2

    int-to-char v0, v0

    add-int/lit8 v3, v3, 0x1

    goto :goto_0

    .line 9
    :cond_0
    invoke-static {v1}, Ljava/lang/String;->copyValueOf([C)Ljava/lang/String;

    move-result-object v0

    .line 10
    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "CharMatcher.is(\'"

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "\')"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public final zza(C)Z
    .locals 1

    .line 14
    iget-char v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzh;->zza:C

    if-ne p1, v0, :cond_0

    const/4 p1, 0x1

    return p1

    :cond_0
    const/4 p1, 0x0

    return p1
.end method
