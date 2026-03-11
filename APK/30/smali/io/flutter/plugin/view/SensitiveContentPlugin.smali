.class public Lio/flutter/plugin/view/SensitiveContentPlugin;
.super Ljava/lang/Object;
.source "SensitiveContentPlugin.java"

# interfaces
.implements Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel$SensitiveContentMethodHandler;


# instance fields
.field private mFlutterActivity:Landroid/app/Activity;

.field private final mFlutterViewId:I

.field private final mSensitiveContentChannel:Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel;


# direct methods
.method public constructor <init>(ILandroid/app/Activity;Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel;)V
    .locals 0

    .line 33
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 34
    iput-object p2, p0, Lio/flutter/plugin/view/SensitiveContentPlugin;->mFlutterActivity:Landroid/app/Activity;

    .line 35
    iput p1, p0, Lio/flutter/plugin/view/SensitiveContentPlugin;->mFlutterViewId:I

    .line 36
    iput-object p3, p0, Lio/flutter/plugin/view/SensitiveContentPlugin;->mSensitiveContentChannel:Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel;

    .line 38
    invoke-virtual {p3, p0}, Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel;->setSensitiveContentMethodHandler(Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel$SensitiveContentMethodHandler;)V

    return-void
.end method

.method private getFlutterViewNotFoundErrorReason()Ljava/lang/String;
    .locals 2

    .line 46
    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "FlutterView with ID "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    iget v1, p0, Lio/flutter/plugin/view/SensitiveContentPlugin;->mFlutterViewId:I

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "not found"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method private getNotSupportedErrorReason()Ljava/lang/String;
    .locals 1

    .line 42
    const-string v0, "isSupported() should be called before attempting to set content sensitivity as it is not supported on this device."

    return-object v0
.end method


# virtual methods
.method public destroy()V
    .locals 2

    .line 124
    iget-object v0, p0, Lio/flutter/plugin/view/SensitiveContentPlugin;->mSensitiveContentChannel:Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel;

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel;->setSensitiveContentMethodHandler(Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel$SensitiveContentMethodHandler;)V

    .line 125
    iput-object v1, p0, Lio/flutter/plugin/view/SensitiveContentPlugin;->mFlutterActivity:Landroid/app/Activity;

    return-void
.end method

.method public getContentSensitivity()I
    .locals 2

    .line 92
    invoke-virtual {p0}, Lio/flutter/plugin/view/SensitiveContentPlugin;->isSupported()Z

    move-result v0

    if-nez v0, :cond_0

    const/4 v0, 0x2

    return v0

    .line 98
    :cond_0
    iget-object v0, p0, Lio/flutter/plugin/view/SensitiveContentPlugin;->mFlutterActivity:Landroid/app/Activity;

    iget v1, p0, Lio/flutter/plugin/view/SensitiveContentPlugin;->mFlutterViewId:I

    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;

    move-result-object v0

    if-eqz v0, :cond_1

    .line 103
    invoke-virtual {v0}, Landroid/view/View;->getContentSensitivity()I

    move-result v0

    return v0

    .line 100
    :cond_1
    new-instance v0, Ljava/lang/IllegalArgumentException;

    invoke-direct {p0}, Lio/flutter/plugin/view/SensitiveContentPlugin;->getFlutterViewNotFoundErrorReason()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method public isSupported()Z
    .locals 2

    .line 114
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x23

    if-lt v0, v1, :cond_0

    const/4 v0, 0x1

    return v0

    :cond_0
    const/4 v0, 0x0

    return v0
.end method

.method public setContentSensitivity(I)V
    .locals 2

    .line 58
    invoke-virtual {p0}, Lio/flutter/plugin/view/SensitiveContentPlugin;->isSupported()Z

    move-result v0

    if-eqz v0, :cond_2

    .line 63
    iget-object v0, p0, Lio/flutter/plugin/view/SensitiveContentPlugin;->mFlutterActivity:Landroid/app/Activity;

    iget v1, p0, Lio/flutter/plugin/view/SensitiveContentPlugin;->mFlutterViewId:I

    invoke-virtual {v0, v1}, Landroid/app/Activity;->findViewById(I)Landroid/view/View;

    move-result-object v0

    if-eqz v0, :cond_1

    .line 68
    invoke-virtual {v0}, Landroid/view/View;->getContentSensitivity()I

    move-result v1

    if-ne v1, p1, :cond_0

    return-void

    .line 76
    :cond_0
    invoke-virtual {v0, p1}, Landroid/view/View;->setContentSensitivity(I)V

    .line 80
    invoke-virtual {v0}, Landroid/view/View;->invalidate()V

    return-void

    .line 65
    :cond_1
    new-instance p1, Ljava/lang/IllegalArgumentException;

    invoke-direct {p0}, Lio/flutter/plugin/view/SensitiveContentPlugin;->getFlutterViewNotFoundErrorReason()Ljava/lang/String;

    move-result-object v0

    invoke-direct {p1, v0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p1

    .line 60
    :cond_2
    new-instance p1, Ljava/lang/IllegalStateException;

    invoke-direct {p0}, Lio/flutter/plugin/view/SensitiveContentPlugin;->getNotSupportedErrorReason()Ljava/lang/String;

    move-result-object v0

    invoke-direct {p1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1
.end method
