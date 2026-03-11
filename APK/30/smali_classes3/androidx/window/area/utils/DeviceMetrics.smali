.class public final Landroidx/window/area/utils/DeviceMetrics;
.super Ljava/lang/Object;
.source "DeviceMetrics.kt"


# annotations
.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000*\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000e\n\u0002\u0008\u0002\n\u0002\u0018\u0002\n\u0002\u0008\u0007\n\u0002\u0010\u000b\n\u0002\u0008\u0002\n\u0002\u0010\u0008\n\u0002\u0008\u0002\u0008\u0001\u0018\u00002\u00020\u0001B\u001d\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0006\u0010\u0004\u001a\u00020\u0003\u0012\u0006\u0010\u0005\u001a\u00020\u0006\u00a2\u0006\u0002\u0010\u0007J\u0013\u0010\r\u001a\u00020\u000e2\u0008\u0010\u000f\u001a\u0004\u0018\u00010\u0001H\u0096\u0002J\u0008\u0010\u0010\u001a\u00020\u0011H\u0016J\u0008\u0010\u0012\u001a\u00020\u0003H\u0016R\u0011\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0008\u0010\tR\u0011\u0010\u0004\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\n\u0010\tR\u0011\u0010\u0005\u001a\u00020\u0006\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u000b\u0010\u000c\u00a8\u0006\u0013"
    }
    d2 = {
        "Landroidx/window/area/utils/DeviceMetrics;",
        "",
        "manufacturer",
        "",
        "model",
        "rearDisplayMetrics",
        "Landroid/util/DisplayMetrics;",
        "(Ljava/lang/String;Ljava/lang/String;Landroid/util/DisplayMetrics;)V",
        "getManufacturer",
        "()Ljava/lang/String;",
        "getModel",
        "getRearDisplayMetrics",
        "()Landroid/util/DisplayMetrics;",
        "equals",
        "",
        "other",
        "hashCode",
        "",
        "toString",
        "window_release"
    }
    k = 0x1
    mv = {
        0x1,
        0x8,
        0x0
    }
    xi = 0x30
.end annotation


# instance fields
.field private final manufacturer:Ljava/lang/String;

.field private final model:Ljava/lang/String;

.field private final rearDisplayMetrics:Landroid/util/DisplayMetrics;


# direct methods
.method public constructor <init>(Ljava/lang/String;Ljava/lang/String;Landroid/util/DisplayMetrics;)V
    .locals 1

    const-string v0, "manufacturer"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "model"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "rearDisplayMetrics"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 26
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 28
    iput-object p1, p0, Landroidx/window/area/utils/DeviceMetrics;->manufacturer:Ljava/lang/String;

    .line 29
    iput-object p2, p0, Landroidx/window/area/utils/DeviceMetrics;->model:Ljava/lang/String;

    .line 30
    iput-object p3, p0, Landroidx/window/area/utils/DeviceMetrics;->rearDisplayMetrics:Landroid/util/DisplayMetrics;

    return-void
.end method


# virtual methods
.method public equals(Ljava/lang/Object;)Z
    .locals 2

    .line 33
    instance-of v0, p1, Landroidx/window/area/utils/DeviceMetrics;

    if-eqz v0, :cond_0

    .line 34
    iget-object v0, p0, Landroidx/window/area/utils/DeviceMetrics;->manufacturer:Ljava/lang/String;

    check-cast p1, Landroidx/window/area/utils/DeviceMetrics;

    iget-object v1, p1, Landroidx/window/area/utils/DeviceMetrics;->manufacturer:Ljava/lang/String;

    invoke-static {v0, v1}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 35
    iget-object v0, p0, Landroidx/window/area/utils/DeviceMetrics;->model:Ljava/lang/String;

    iget-object v1, p1, Landroidx/window/area/utils/DeviceMetrics;->model:Ljava/lang/String;

    invoke-static {v0, v1}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 36
    iget-object v0, p0, Landroidx/window/area/utils/DeviceMetrics;->rearDisplayMetrics:Landroid/util/DisplayMetrics;

    iget-object p1, p1, Landroidx/window/area/utils/DeviceMetrics;->rearDisplayMetrics:Landroid/util/DisplayMetrics;

    invoke-virtual {v0, p1}, Landroid/util/DisplayMetrics;->equals(Landroid/util/DisplayMetrics;)Z

    move-result p1

    if-eqz p1, :cond_0

    const/4 p1, 0x1

    return p1

    :cond_0
    const/4 p1, 0x0

    return p1
.end method

.method public final getManufacturer()Ljava/lang/String;
    .locals 1

    .line 28
    iget-object v0, p0, Landroidx/window/area/utils/DeviceMetrics;->manufacturer:Ljava/lang/String;

    return-object v0
.end method

.method public final getModel()Ljava/lang/String;
    .locals 1

    .line 29
    iget-object v0, p0, Landroidx/window/area/utils/DeviceMetrics;->model:Ljava/lang/String;

    return-object v0
.end method

.method public final getRearDisplayMetrics()Landroid/util/DisplayMetrics;
    .locals 1

    .line 30
    iget-object v0, p0, Landroidx/window/area/utils/DeviceMetrics;->rearDisplayMetrics:Landroid/util/DisplayMetrics;

    return-object v0
.end method

.method public hashCode()I
    .locals 2

    .line 40
    iget-object v0, p0, Landroidx/window/area/utils/DeviceMetrics;->manufacturer:Ljava/lang/String;

    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I

    move-result v0

    mul-int/lit8 v0, v0, 0x1f

    .line 41
    iget-object v1, p0, Landroidx/window/area/utils/DeviceMetrics;->model:Ljava/lang/String;

    invoke-virtual {v1}, Ljava/lang/String;->hashCode()I

    move-result v1

    add-int/2addr v0, v1

    mul-int/lit8 v0, v0, 0x1f

    .line 42
    iget-object v1, p0, Landroidx/window/area/utils/DeviceMetrics;->rearDisplayMetrics:Landroid/util/DisplayMetrics;

    invoke-virtual {v1}, Landroid/util/DisplayMetrics;->hashCode()I

    move-result v1

    add-int/2addr v0, v1

    return v0
.end method

.method public toString()Ljava/lang/String;
    .locals 2

    .line 47
    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "DeviceMetrics{ Manufacturer: "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget-object v1, p0, Landroidx/window/area/utils/DeviceMetrics;->manufacturer:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", model: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Landroidx/window/area/utils/DeviceMetrics;->model:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", Rear display metrics: "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    .line 48
    iget-object v1, p0, Landroidx/window/area/utils/DeviceMetrics;->rearDisplayMetrics:Landroid/util/DisplayMetrics;

    .line 47
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    .line 48
    const-string v1, " }"

    .line 47
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
