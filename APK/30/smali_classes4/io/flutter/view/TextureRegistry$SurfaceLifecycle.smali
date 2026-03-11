.class public final enum Lio/flutter/view/TextureRegistry$SurfaceLifecycle;
.super Ljava/lang/Enum;
.source "TextureRegistry.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/view/TextureRegistry;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x4019
    name = "SurfaceLifecycle"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Enum<",
        "Lio/flutter/view/TextureRegistry$SurfaceLifecycle;",
        ">;"
    }
.end annotation


# static fields
.field private static final synthetic $VALUES:[Lio/flutter/view/TextureRegistry$SurfaceLifecycle;

.field public static final enum manual:Lio/flutter/view/TextureRegistry$SurfaceLifecycle;

.field public static final enum resetInBackground:Lio/flutter/view/TextureRegistry$SurfaceLifecycle;


# direct methods
.method private static synthetic $values()[Lio/flutter/view/TextureRegistry$SurfaceLifecycle;
    .locals 2

    .line 35
    sget-object v0, Lio/flutter/view/TextureRegistry$SurfaceLifecycle;->manual:Lio/flutter/view/TextureRegistry$SurfaceLifecycle;

    sget-object v1, Lio/flutter/view/TextureRegistry$SurfaceLifecycle;->resetInBackground:Lio/flutter/view/TextureRegistry$SurfaceLifecycle;

    filled-new-array {v0, v1}, [Lio/flutter/view/TextureRegistry$SurfaceLifecycle;

    move-result-object v0

    return-object v0
.end method

.method static constructor <clinit>()V
    .locals 3

    .line 48
    new-instance v0, Lio/flutter/view/TextureRegistry$SurfaceLifecycle;

    const-string v1, "manual"

    const/4 v2, 0x0

    invoke-direct {v0, v1, v2}, Lio/flutter/view/TextureRegistry$SurfaceLifecycle;-><init>(Ljava/lang/String;I)V

    sput-object v0, Lio/flutter/view/TextureRegistry$SurfaceLifecycle;->manual:Lio/flutter/view/TextureRegistry$SurfaceLifecycle;

    .line 61
    new-instance v0, Lio/flutter/view/TextureRegistry$SurfaceLifecycle;

    const-string v1, "resetInBackground"

    const/4 v2, 0x1

    invoke-direct {v0, v1, v2}, Lio/flutter/view/TextureRegistry$SurfaceLifecycle;-><init>(Ljava/lang/String;I)V

    sput-object v0, Lio/flutter/view/TextureRegistry$SurfaceLifecycle;->resetInBackground:Lio/flutter/view/TextureRegistry$SurfaceLifecycle;

    .line 35
    invoke-static {}, Lio/flutter/view/TextureRegistry$SurfaceLifecycle;->$values()[Lio/flutter/view/TextureRegistry$SurfaceLifecycle;

    move-result-object v0

    sput-object v0, Lio/flutter/view/TextureRegistry$SurfaceLifecycle;->$VALUES:[Lio/flutter/view/TextureRegistry$SurfaceLifecycle;

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

    .line 35
    invoke-direct {p0, p1, p2}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    return-void
.end method

.method public static valueOf(Ljava/lang/String;)Lio/flutter/view/TextureRegistry$SurfaceLifecycle;
    .locals 1
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8000
        }
        names = {
            null
        }
    .end annotation

    .line 35
    const-class v0, Lio/flutter/view/TextureRegistry$SurfaceLifecycle;

    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    move-result-object p0

    check-cast p0, Lio/flutter/view/TextureRegistry$SurfaceLifecycle;

    return-object p0
.end method

.method public static values()[Lio/flutter/view/TextureRegistry$SurfaceLifecycle;
    .locals 1

    .line 35
    sget-object v0, Lio/flutter/view/TextureRegistry$SurfaceLifecycle;->$VALUES:[Lio/flutter/view/TextureRegistry$SurfaceLifecycle;

    invoke-virtual {v0}, [Lio/flutter/view/TextureRegistry$SurfaceLifecycle;->clone()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Lio/flutter/view/TextureRegistry$SurfaceLifecycle;

    return-object v0
.end method
