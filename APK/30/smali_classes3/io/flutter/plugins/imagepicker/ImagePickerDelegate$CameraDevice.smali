.class public final enum Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;
.super Ljava/lang/Enum;
.source "ImagePickerDelegate.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/imagepicker/ImagePickerDelegate;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x4019
    name = "CameraDevice"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Enum<",
        "Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;",
        ">;"
    }
.end annotation


# static fields
.field private static final synthetic $VALUES:[Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;

.field public static final enum FRONT:Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;

.field public static final enum REAR:Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;


# direct methods
.method private static synthetic $values()[Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;
    .locals 2

    .line 90
    sget-object v0, Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;->REAR:Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;

    sget-object v1, Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;->FRONT:Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;

    filled-new-array {v0, v1}, [Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;

    move-result-object v0

    return-object v0
.end method

.method static constructor <clinit>()V
    .locals 3

    .line 91
    new-instance v0, Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;

    const-string v1, "REAR"

    const/4 v2, 0x0

    invoke-direct {v0, v1, v2}, Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;-><init>(Ljava/lang/String;I)V

    sput-object v0, Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;->REAR:Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;

    .line 92
    new-instance v0, Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;

    const-string v1, "FRONT"

    const/4 v2, 0x1

    invoke-direct {v0, v1, v2}, Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;-><init>(Ljava/lang/String;I)V

    sput-object v0, Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;->FRONT:Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;

    .line 90
    invoke-static {}, Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;->$values()[Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;

    move-result-object v0

    sput-object v0, Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;->$VALUES:[Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;

    return-void
.end method

.method private constructor <init>(Ljava/lang/String;I)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x1000,
            0x1000
        }
        names = {
            null,
            null
        }
    .end annotation

    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 90
    invoke-direct {p0, p1, p2}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    return-void
.end method

.method public static valueOf(Ljava/lang/String;)Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;
    .locals 1
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8000
        }
        names = {
            null
        }
    .end annotation

    .line 90
    const-class v0, Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;

    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    move-result-object p0

    check-cast p0, Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;

    return-object p0
.end method

.method public static values()[Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;
    .locals 1

    .line 90
    sget-object v0, Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;->$VALUES:[Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;

    invoke-virtual {v0}, [Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;->clone()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Lio/flutter/plugins/imagepicker/ImagePickerDelegate$CameraDevice;

    return-object v0
.end method
