.class public Lcom/benjaminabel/vibration/VibrationPlugin;
.super Ljava/lang/Object;
.source "VibrationPlugin.java"

# interfaces
.implements Lio/flutter/embedding/engine/plugins/FlutterPlugin;


# static fields
.field private static final CHANNEL:Ljava/lang/String; = "vibration"


# instance fields
.field private methodChannel:Lio/flutter/plugin/common/MethodChannel;


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 14
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private getLegacyVibrator(Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;)Landroid/os/Vibrator;
    .locals 1

    .line 34
    invoke-virtual {p1}, Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;->getApplicationContext()Landroid/content/Context;

    move-result-object p1

    .line 36
    const-class v0, Landroid/os/Vibrator;

    invoke-static {p1, v0}, Landroidx/core/content/ContextCompat;->getSystemService(Landroid/content/Context;Ljava/lang/Class;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/os/Vibrator;

    if-eqz v0, :cond_0

    return-object v0

    .line 42
    :cond_0
    const-string v0, "vibrator"

    invoke-virtual {p1, v0}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Landroid/os/Vibrator;

    return-object p1
.end method


# virtual methods
.method public getVibrator(Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;)Landroid/os/Vibrator;
    .locals 2

    .line 19
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1f

    if-ge v0, v1, :cond_0

    .line 20
    invoke-direct {p0, p1}, Lcom/benjaminabel/vibration/VibrationPlugin;->getLegacyVibrator(Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;)Landroid/os/Vibrator;

    move-result-object p1

    return-object p1

    .line 23
    :cond_0
    :try_start_0
    invoke-virtual {p1}, Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;->getApplicationContext()Landroid/content/Context;

    move-result-object v0

    const-string v1, "vibrator_manager"

    invoke-virtual {v0, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/os/VibratorManager;

    .line 25
    invoke-virtual {v0}, Landroid/os/VibratorManager;->getDefaultVibrator()Landroid/os/Vibrator;

    move-result-object p1
    :try_end_0
    .catch Ljava/lang/NoSuchMethodError; {:try_start_0 .. :try_end_0} :catch_0
    .catch Ljava/lang/NoClassDefFoundError; {:try_start_0 .. :try_end_0} :catch_0

    return-object p1

    .line 27
    :catch_0
    invoke-direct {p0, p1}, Lcom/benjaminabel/vibration/VibrationPlugin;->getLegacyVibrator(Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;)Landroid/os/Vibrator;

    move-result-object p1

    return-object p1
.end method

.method public onAttachedToEngine(Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;)V
    .locals 3

    .line 47
    invoke-virtual {p0, p1}, Lcom/benjaminabel/vibration/VibrationPlugin;->getVibrator(Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;)Landroid/os/Vibrator;

    move-result-object v0

    .line 48
    new-instance v1, Lcom/benjaminabel/vibration/VibrationMethodChannelHandler;

    new-instance v2, Lcom/benjaminabel/vibration/Vibration;

    invoke-direct {v2, v0}, Lcom/benjaminabel/vibration/Vibration;-><init>(Landroid/os/Vibrator;)V

    invoke-direct {v1, v2}, Lcom/benjaminabel/vibration/VibrationMethodChannelHandler;-><init>(Lcom/benjaminabel/vibration/Vibration;)V

    .line 50
    new-instance v0, Lio/flutter/plugin/common/MethodChannel;

    invoke-virtual {p1}, Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;->getBinaryMessenger()Lio/flutter/plugin/common/BinaryMessenger;

    move-result-object p1

    const-string v2, "vibration"

    invoke-direct {v0, p1, v2}, Lio/flutter/plugin/common/MethodChannel;-><init>(Lio/flutter/plugin/common/BinaryMessenger;Ljava/lang/String;)V

    iput-object v0, p0, Lcom/benjaminabel/vibration/VibrationPlugin;->methodChannel:Lio/flutter/plugin/common/MethodChannel;

    .line 51
    invoke-virtual {v0, v1}, Lio/flutter/plugin/common/MethodChannel;->setMethodCallHandler(Lio/flutter/plugin/common/MethodChannel$MethodCallHandler;)V

    return-void
.end method

.method public onDetachedFromEngine(Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;)V
    .locals 1

    .line 56
    iget-object p1, p0, Lcom/benjaminabel/vibration/VibrationPlugin;->methodChannel:Lio/flutter/plugin/common/MethodChannel;

    const/4 v0, 0x0

    invoke-virtual {p1, v0}, Lio/flutter/plugin/common/MethodChannel;->setMethodCallHandler(Lio/flutter/plugin/common/MethodChannel$MethodCallHandler;)V

    .line 57
    iput-object v0, p0, Lcom/benjaminabel/vibration/VibrationPlugin;->methodChannel:Lio/flutter/plugin/common/MethodChannel;

    return-void
.end method
