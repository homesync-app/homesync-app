.class final Lcom/google/android/gms/internal/auth-api/zbbh;
.super Lcom/google/android/gms/internal/auth-api/zbbi;
.source "com.google.android.gms:play-services-auth@@21.4.0"


# instance fields
.field final transient zba:I

.field final transient zbb:I

.field final synthetic zbc:Lcom/google/android/gms/internal/auth-api/zbbi;


# direct methods
.method constructor <init>(Lcom/google/android/gms/internal/auth-api/zbbi;II)V
    .locals 0

    .line 1
    invoke-static {p1}, Ljava/util/Objects;->requireNonNull(Ljava/lang/Object;)Ljava/lang/Object;

    iput-object p1, p0, Lcom/google/android/gms/internal/auth-api/zbbh;->zbc:Lcom/google/android/gms/internal/auth-api/zbbi;

    invoke-direct {p0}, Lcom/google/android/gms/internal/auth-api/zbbi;-><init>()V

    iput p2, p0, Lcom/google/android/gms/internal/auth-api/zbbh;->zba:I

    iput p3, p0, Lcom/google/android/gms/internal/auth-api/zbbh;->zbb:I

    return-void
.end method


# virtual methods
.method public final get(I)Ljava/lang/Object;
    .locals 2

    .line 1
    iget v0, p0, Lcom/google/android/gms/internal/auth-api/zbbh;->zbb:I

    const-string v1, "index"

    invoke-static {p1, v0, v1}, Lcom/google/android/gms/internal/auth-api/zbbc;->zba(IILjava/lang/String;)I

    iget-object v0, p0, Lcom/google/android/gms/internal/auth-api/zbbh;->zbc:Lcom/google/android/gms/internal/auth-api/zbbi;

    iget v1, p0, Lcom/google/android/gms/internal/auth-api/zbbh;->zba:I

    add-int/2addr p1, v1

    .line 2
    invoke-virtual {v0, p1}, Lcom/google/android/gms/internal/auth-api/zbbi;->get(I)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method

.method public final size()I
    .locals 1

    iget v0, p0, Lcom/google/android/gms/internal/auth-api/zbbh;->zbb:I

    return v0
.end method

.method public final bridge synthetic subList(II)Ljava/util/List;
    .locals 0

    .line 1
    invoke-virtual {p0, p1, p2}, Lcom/google/android/gms/internal/auth-api/zbbi;->zbh(II)Lcom/google/android/gms/internal/auth-api/zbbi;

    move-result-object p1

    return-object p1
.end method

.method final zbb()[Ljava/lang/Object;
    .locals 1

    iget-object v0, p0, Lcom/google/android/gms/internal/auth-api/zbbh;->zbc:Lcom/google/android/gms/internal/auth-api/zbbi;

    invoke-virtual {v0}, Lcom/google/android/gms/internal/auth-api/zbbf;->zbb()[Ljava/lang/Object;

    move-result-object v0

    return-object v0
.end method

.method final zbc()I
    .locals 2

    iget-object v0, p0, Lcom/google/android/gms/internal/auth-api/zbbh;->zbc:Lcom/google/android/gms/internal/auth-api/zbbi;

    invoke-virtual {v0}, Lcom/google/android/gms/internal/auth-api/zbbf;->zbc()I

    move-result v0

    iget v1, p0, Lcom/google/android/gms/internal/auth-api/zbbh;->zba:I

    add-int/2addr v0, v1

    return v0
.end method

.method final zbd()I
    .locals 2

    iget-object v0, p0, Lcom/google/android/gms/internal/auth-api/zbbh;->zbc:Lcom/google/android/gms/internal/auth-api/zbbi;

    invoke-virtual {v0}, Lcom/google/android/gms/internal/auth-api/zbbf;->zbc()I

    move-result v0

    iget v1, p0, Lcom/google/android/gms/internal/auth-api/zbbh;->zba:I

    add-int/2addr v0, v1

    iget v1, p0, Lcom/google/android/gms/internal/auth-api/zbbh;->zbb:I

    add-int/2addr v0, v1

    return v0
.end method

.method final zbf()Z
    .locals 1

    const/4 v0, 0x1

    return v0
.end method

.method public final zbh(II)Lcom/google/android/gms/internal/auth-api/zbbi;
    .locals 2

    .line 1
    iget v0, p0, Lcom/google/android/gms/internal/auth-api/zbbh;->zbb:I

    invoke-static {p1, p2, v0}, Lcom/google/android/gms/internal/auth-api/zbbc;->zbc(III)V

    iget v0, p0, Lcom/google/android/gms/internal/auth-api/zbbh;->zba:I

    iget-object v1, p0, Lcom/google/android/gms/internal/auth-api/zbbh;->zbc:Lcom/google/android/gms/internal/auth-api/zbbi;

    add-int/2addr p1, v0

    add-int/2addr p2, v0

    .line 2
    invoke-virtual {v1, p1, p2}, Lcom/google/android/gms/internal/auth-api/zbbi;->zbh(II)Lcom/google/android/gms/internal/auth-api/zbbi;

    move-result-object p1

    return-object p1
.end method
