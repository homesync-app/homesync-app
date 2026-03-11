.class Lio/flutter/plugins/videoplayer/platformview/PlatformVideoView$1;
.super Ljava/lang/Object;
.source "PlatformVideoView.java"

# interfaces
.implements Landroid/view/SurfaceHolder$Callback;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lio/flutter/plugins/videoplayer/platformview/PlatformVideoView;->setupSurfaceWithCallback(Landroidx/media3/exoplayer/ExoPlayer;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lio/flutter/plugins/videoplayer/platformview/PlatformVideoView;

.field final synthetic val$exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;


# direct methods
.method constructor <init>(Lio/flutter/plugins/videoplayer/platformview/PlatformVideoView;Landroidx/media3/exoplayer/ExoPlayer;)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010,
            0x1010
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

    .line 57
    iput-object p1, p0, Lio/flutter/plugins/videoplayer/platformview/PlatformVideoView$1;->this$0:Lio/flutter/plugins/videoplayer/platformview/PlatformVideoView;

    iput-object p2, p0, Lio/flutter/plugins/videoplayer/platformview/PlatformVideoView$1;->val$exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public surfaceChanged(Landroid/view/SurfaceHolder;III)V
    .locals 0

    return-void
.end method

.method public surfaceCreated(Landroid/view/SurfaceHolder;)V
    .locals 2

    .line 60
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/platformview/PlatformVideoView$1;->val$exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-interface {p1}, Landroid/view/SurfaceHolder;->getSurface()Landroid/view/Surface;

    move-result-object p1

    invoke-interface {v0, p1}, Landroidx/media3/exoplayer/ExoPlayer;->setVideoSurface(Landroid/view/Surface;)V

    .line 62
    iget-object p1, p0, Lio/flutter/plugins/videoplayer/platformview/PlatformVideoView$1;->val$exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    const-wide/16 v0, 0x1

    invoke-interface {p1, v0, v1}, Landroidx/media3/exoplayer/ExoPlayer;->seekTo(J)V

    return-void
.end method

.method public surfaceDestroyed(Landroid/view/SurfaceHolder;)V
    .locals 1

    .line 73
    iget-object p1, p0, Lio/flutter/plugins/videoplayer/platformview/PlatformVideoView$1;->val$exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    const/4 v0, 0x0

    invoke-interface {p1, v0}, Landroidx/media3/exoplayer/ExoPlayer;->setVideoSurface(Landroid/view/Surface;)V

    return-void
.end method
