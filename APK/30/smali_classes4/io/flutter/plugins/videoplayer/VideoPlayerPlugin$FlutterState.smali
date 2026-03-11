.class final Lio/flutter/plugins/videoplayer/VideoPlayerPlugin$FlutterState;
.super Ljava/lang/Object;
.source "VideoPlayerPlugin.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/videoplayer/VideoPlayerPlugin;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1a
    name = "FlutterState"
.end annotation


# instance fields
.field final applicationContext:Landroid/content/Context;

.field final binaryMessenger:Lio/flutter/plugin/common/BinaryMessenger;

.field final keyForAsset:Lio/flutter/plugins/videoplayer/VideoPlayerPlugin$KeyForAssetFn;

.field final keyForAssetAndPackageName:Lio/flutter/plugins/videoplayer/VideoPlayerPlugin$KeyForAssetAndPackageName;

.field final textureRegistry:Lio/flutter/view/TextureRegistry;


# direct methods
.method constructor <init>(Landroid/content/Context;Lio/flutter/plugin/common/BinaryMessenger;Lio/flutter/plugins/videoplayer/VideoPlayerPlugin$KeyForAssetFn;Lio/flutter/plugins/videoplayer/VideoPlayerPlugin$KeyForAssetAndPackageName;Lio/flutter/view/TextureRegistry;)V
    .locals 0

    .line 215
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 216
    iput-object p1, p0, Lio/flutter/plugins/videoplayer/VideoPlayerPlugin$FlutterState;->applicationContext:Landroid/content/Context;

    .line 217
    iput-object p2, p0, Lio/flutter/plugins/videoplayer/VideoPlayerPlugin$FlutterState;->binaryMessenger:Lio/flutter/plugin/common/BinaryMessenger;

    .line 218
    iput-object p3, p0, Lio/flutter/plugins/videoplayer/VideoPlayerPlugin$FlutterState;->keyForAsset:Lio/flutter/plugins/videoplayer/VideoPlayerPlugin$KeyForAssetFn;

    .line 219
    iput-object p4, p0, Lio/flutter/plugins/videoplayer/VideoPlayerPlugin$FlutterState;->keyForAssetAndPackageName:Lio/flutter/plugins/videoplayer/VideoPlayerPlugin$KeyForAssetAndPackageName;

    .line 220
    iput-object p5, p0, Lio/flutter/plugins/videoplayer/VideoPlayerPlugin$FlutterState;->textureRegistry:Lio/flutter/view/TextureRegistry;

    return-void
.end method


# virtual methods
.method startListening(Lio/flutter/plugins/videoplayer/VideoPlayerPlugin;Lio/flutter/plugin/common/BinaryMessenger;)V
    .locals 1

    .line 224
    sget-object v0, Lio/flutter/plugins/videoplayer/AndroidVideoPlayerApi;->Companion:Lio/flutter/plugins/videoplayer/AndroidVideoPlayerApi$Companion;

    invoke-virtual {v0, p2, p1}, Lio/flutter/plugins/videoplayer/AndroidVideoPlayerApi$Companion;->setUp(Lio/flutter/plugin/common/BinaryMessenger;Lio/flutter/plugins/videoplayer/AndroidVideoPlayerApi;)V

    return-void
.end method

.method stopListening(Lio/flutter/plugin/common/BinaryMessenger;)V
    .locals 2

    .line 228
    sget-object v0, Lio/flutter/plugins/videoplayer/AndroidVideoPlayerApi;->Companion:Lio/flutter/plugins/videoplayer/AndroidVideoPlayerApi$Companion;

    const/4 v1, 0x0

    invoke-virtual {v0, p1, v1}, Lio/flutter/plugins/videoplayer/AndroidVideoPlayerApi$Companion;->setUp(Lio/flutter/plugin/common/BinaryMessenger;Lio/flutter/plugins/videoplayer/AndroidVideoPlayerApi;)V

    return-void
.end method
