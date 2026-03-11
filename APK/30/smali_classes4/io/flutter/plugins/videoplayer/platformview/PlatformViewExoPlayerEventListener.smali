.class public final Lio/flutter/plugins/videoplayer/platformview/PlatformViewExoPlayerEventListener;
.super Lio/flutter/plugins/videoplayer/ExoPlayerEventListener;
.source "PlatformViewExoPlayerEventListener.java"


# direct methods
.method public constructor <init>(Landroidx/media3/exoplayer/ExoPlayer;Lio/flutter/plugins/videoplayer/VideoPlayerCallbacks;)V
    .locals 0

    .line 19
    invoke-direct {p0, p1, p2}, Lio/flutter/plugins/videoplayer/ExoPlayerEventListener;-><init>(Landroidx/media3/exoplayer/ExoPlayer;Lio/flutter/plugins/videoplayer/VideoPlayerCallbacks;)V

    return-void
.end method


# virtual methods
.method protected sendInitialized()V
    .locals 8

    .line 27
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/platformview/PlatformViewExoPlayerEventListener;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-interface {v0}, Landroidx/media3/exoplayer/ExoPlayer;->getVideoFormat()Landroidx/media3/common/Format;

    move-result-object v0

    .line 29
    invoke-static {v0}, Ljava/util/Objects;->requireNonNull(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Landroidx/media3/common/Format;

    iget v1, v1, Landroidx/media3/common/Format;->rotationDegrees:I

    invoke-static {v1}, Lio/flutter/plugins/videoplayer/ExoPlayerEventListener$RotationDegrees;->fromDegrees(I)Lio/flutter/plugins/videoplayer/ExoPlayerEventListener$RotationDegrees;

    move-result-object v1

    .line 30
    iget v2, v0, Landroidx/media3/common/Format;->width:I

    .line 31
    iget v3, v0, Landroidx/media3/common/Format;->height:I

    .line 35
    sget-object v4, Lio/flutter/plugins/videoplayer/ExoPlayerEventListener$RotationDegrees;->ROTATE_90:Lio/flutter/plugins/videoplayer/ExoPlayerEventListener$RotationDegrees;

    if-eq v1, v4, :cond_0

    sget-object v4, Lio/flutter/plugins/videoplayer/ExoPlayerEventListener$RotationDegrees;->ROTATE_270:Lio/flutter/plugins/videoplayer/ExoPlayerEventListener$RotationDegrees;

    if-ne v1, v4, :cond_1

    .line 37
    :cond_0
    iget v2, v0, Landroidx/media3/common/Format;->height:I

    .line 38
    iget v3, v0, Landroidx/media3/common/Format;->width:I

    const/4 v0, 0x0

    .line 40
    invoke-static {v0}, Lio/flutter/plugins/videoplayer/ExoPlayerEventListener$RotationDegrees;->fromDegrees(I)Lio/flutter/plugins/videoplayer/ExoPlayerEventListener$RotationDegrees;

    move-result-object v1

    :cond_1
    move v4, v3

    move v3, v2

    .line 43
    iget-object v2, p0, Lio/flutter/plugins/videoplayer/platformview/PlatformViewExoPlayerEventListener;->events:Lio/flutter/plugins/videoplayer/VideoPlayerCallbacks;

    iget-object v0, p0, Lio/flutter/plugins/videoplayer/platformview/PlatformViewExoPlayerEventListener;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-interface {v0}, Landroidx/media3/exoplayer/ExoPlayer;->getDuration()J

    move-result-wide v5

    invoke-virtual {v1}, Lio/flutter/plugins/videoplayer/ExoPlayerEventListener$RotationDegrees;->getDegrees()I

    move-result v7

    invoke-interface/range {v2 .. v7}, Lio/flutter/plugins/videoplayer/VideoPlayerCallbacks;->onInitialized(IIJI)V

    return-void
.end method
