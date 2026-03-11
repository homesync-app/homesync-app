.class public final Lio/flutter/plugins/videoplayer/texture/TextureExoPlayerEventListener;
.super Lio/flutter/plugins/videoplayer/ExoPlayerEventListener;
.source "TextureExoPlayerEventListener.java"


# instance fields
.field private final surfaceProducerHandlesCropAndRotation:Z


# direct methods
.method public constructor <init>(Landroidx/media3/exoplayer/ExoPlayer;Lio/flutter/plugins/videoplayer/VideoPlayerCallbacks;Z)V
    .locals 0

    .line 23
    invoke-direct {p0, p1, p2}, Lio/flutter/plugins/videoplayer/ExoPlayerEventListener;-><init>(Landroidx/media3/exoplayer/ExoPlayer;Lio/flutter/plugins/videoplayer/VideoPlayerCallbacks;)V

    .line 24
    iput-boolean p3, p0, Lio/flutter/plugins/videoplayer/texture/TextureExoPlayerEventListener;->surfaceProducerHandlesCropAndRotation:Z

    return-void
.end method

.method private getRotationCorrectionFromFormat(Landroidx/media3/exoplayer/ExoPlayer;)I
    .locals 0

    .line 59
    invoke-interface {p1}, Landroidx/media3/exoplayer/ExoPlayer;->getVideoFormat()Landroidx/media3/common/Format;

    move-result-object p1

    invoke-static {p1}, Ljava/util/Objects;->requireNonNull(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Landroidx/media3/common/Format;

    .line 60
    iget p1, p1, Landroidx/media3/common/Format;->rotationDegrees:I

    return p1
.end method


# virtual methods
.method protected sendInitialized()V
    .locals 8

    .line 29
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/texture/TextureExoPlayerEventListener;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-interface {v0}, Landroidx/media3/exoplayer/ExoPlayer;->getVideoSize()Landroidx/media3/common/VideoSize;

    move-result-object v0

    .line 30
    sget-object v1, Lio/flutter/plugins/videoplayer/ExoPlayerEventListener$RotationDegrees;->ROTATE_0:Lio/flutter/plugins/videoplayer/ExoPlayerEventListener$RotationDegrees;

    .line 31
    iget v3, v0, Landroidx/media3/common/VideoSize;->width:I

    .line 32
    iget v4, v0, Landroidx/media3/common/VideoSize;->height:I

    if-eqz v3, :cond_0

    if-eqz v4, :cond_0

    .line 36
    iget-boolean v0, p0, Lio/flutter/plugins/videoplayer/texture/TextureExoPlayerEventListener;->surfaceProducerHandlesCropAndRotation:Z

    if-nez v0, :cond_0

    .line 40
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/texture/TextureExoPlayerEventListener;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-direct {p0, v0}, Lio/flutter/plugins/videoplayer/texture/TextureExoPlayerEventListener;->getRotationCorrectionFromFormat(Landroidx/media3/exoplayer/ExoPlayer;)I

    move-result v0

    .line 43
    :try_start_0
    invoke-static {v0}, Lio/flutter/plugins/videoplayer/ExoPlayerEventListener$RotationDegrees;->fromDegrees(I)Lio/flutter/plugins/videoplayer/ExoPlayerEventListener$RotationDegrees;

    move-result-object v1
    :try_end_0
    .catch Ljava/lang/IllegalArgumentException; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    .line 47
    :catch_0
    sget-object v1, Lio/flutter/plugins/videoplayer/ExoPlayerEventListener$RotationDegrees;->ROTATE_0:Lio/flutter/plugins/videoplayer/ExoPlayerEventListener$RotationDegrees;

    .line 51
    :cond_0
    :goto_0
    iget-object v2, p0, Lio/flutter/plugins/videoplayer/texture/TextureExoPlayerEventListener;->events:Lio/flutter/plugins/videoplayer/VideoPlayerCallbacks;

    iget-object v0, p0, Lio/flutter/plugins/videoplayer/texture/TextureExoPlayerEventListener;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-interface {v0}, Landroidx/media3/exoplayer/ExoPlayer;->getDuration()J

    move-result-wide v5

    invoke-virtual {v1}, Lio/flutter/plugins/videoplayer/ExoPlayerEventListener$RotationDegrees;->getDegrees()I

    move-result v7

    invoke-interface/range {v2 .. v7}, Lio/flutter/plugins/videoplayer/VideoPlayerCallbacks;->onInitialized(IIJI)V

    return-void
.end method
