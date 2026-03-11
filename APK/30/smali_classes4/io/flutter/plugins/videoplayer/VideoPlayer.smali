.class public abstract Lio/flutter/plugins/videoplayer/VideoPlayer;
.super Ljava/lang/Object;
.source "VideoPlayer.java"

# interfaces
.implements Lio/flutter/plugins/videoplayer/VideoPlayerInstanceApi;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/videoplayer/VideoPlayer$ExoPlayerProvider;,
        Lio/flutter/plugins/videoplayer/VideoPlayer$DisposeHandler;
    }
.end annotation


# instance fields
.field private disposeHandler:Lio/flutter/plugins/videoplayer/VideoPlayer$DisposeHandler;

.field protected exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

.field protected final surfaceProducer:Lio/flutter/view/TextureRegistry$SurfaceProducer;

.field protected trackSelector:Landroidx/media3/exoplayer/trackselection/DefaultTrackSelector;

.field protected final videoPlayerEvents:Lio/flutter/plugins/videoplayer/VideoPlayerCallbacks;


# direct methods
.method public constructor <init>(Lio/flutter/plugins/videoplayer/VideoPlayerCallbacks;Landroidx/media3/common/MediaItem;Lio/flutter/plugins/videoplayer/VideoPlayerOptions;Lio/flutter/view/TextureRegistry$SurfaceProducer;Lio/flutter/plugins/videoplayer/VideoPlayer$ExoPlayerProvider;)V
    .locals 0

    .line 66
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 67
    iput-object p1, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->videoPlayerEvents:Lio/flutter/plugins/videoplayer/VideoPlayerCallbacks;

    .line 68
    iput-object p4, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->surfaceProducer:Lio/flutter/view/TextureRegistry$SurfaceProducer;

    .line 69
    invoke-interface {p5}, Lio/flutter/plugins/videoplayer/VideoPlayer$ExoPlayerProvider;->get()Landroidx/media3/exoplayer/ExoPlayer;

    move-result-object p1

    iput-object p1, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    .line 72
    invoke-interface {p1}, Landroidx/media3/exoplayer/ExoPlayer;->getTrackSelector()Landroidx/media3/exoplayer/trackselection/TrackSelector;

    move-result-object p1

    instance-of p1, p1, Landroidx/media3/exoplayer/trackselection/DefaultTrackSelector;

    if-eqz p1, :cond_0

    .line 73
    iget-object p1, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-interface {p1}, Landroidx/media3/exoplayer/ExoPlayer;->getTrackSelector()Landroidx/media3/exoplayer/trackselection/TrackSelector;

    move-result-object p1

    check-cast p1, Landroidx/media3/exoplayer/trackselection/DefaultTrackSelector;

    iput-object p1, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->trackSelector:Landroidx/media3/exoplayer/trackselection/DefaultTrackSelector;

    .line 76
    :cond_0
    iget-object p1, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-interface {p1, p2}, Landroidx/media3/exoplayer/ExoPlayer;->setMediaItem(Landroidx/media3/common/MediaItem;)V

    .line 77
    iget-object p1, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-interface {p1}, Landroidx/media3/exoplayer/ExoPlayer;->prepare()V

    .line 78
    iget-object p1, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-virtual {p0, p1, p4}, Lio/flutter/plugins/videoplayer/VideoPlayer;->createExoPlayerEventListener(Landroidx/media3/exoplayer/ExoPlayer;Lio/flutter/view/TextureRegistry$SurfaceProducer;)Lio/flutter/plugins/videoplayer/ExoPlayerEventListener;

    move-result-object p2

    invoke-interface {p1, p2}, Landroidx/media3/exoplayer/ExoPlayer;->addListener(Landroidx/media3/common/Player$Listener;)V

    .line 79
    iget-object p1, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    iget-boolean p2, p3, Lio/flutter/plugins/videoplayer/VideoPlayerOptions;->mixWithOthers:Z

    invoke-static {p1, p2}, Lio/flutter/plugins/videoplayer/VideoPlayer;->setAudioAttributes(Landroidx/media3/exoplayer/ExoPlayer;Z)V

    return-void
.end method

.method private static setAudioAttributes(Landroidx/media3/exoplayer/ExoPlayer;Z)V
    .locals 2

    .line 91
    new-instance v0, Landroidx/media3/common/AudioAttributes$Builder;

    invoke-direct {v0}, Landroidx/media3/common/AudioAttributes$Builder;-><init>()V

    const/4 v1, 0x3

    .line 92
    invoke-virtual {v0, v1}, Landroidx/media3/common/AudioAttributes$Builder;->setContentType(I)Landroidx/media3/common/AudioAttributes$Builder;

    move-result-object v0

    invoke-virtual {v0}, Landroidx/media3/common/AudioAttributes$Builder;->build()Landroidx/media3/common/AudioAttributes;

    move-result-object v0

    xor-int/lit8 p1, p1, 0x1

    .line 91
    invoke-interface {p0, v0, p1}, Landroidx/media3/exoplayer/ExoPlayer;->setAudioAttributes(Landroidx/media3/common/AudioAttributes;Z)V

    return-void
.end method


# virtual methods
.method protected abstract createExoPlayerEventListener(Landroidx/media3/exoplayer/ExoPlayer;Lio/flutter/view/TextureRegistry$SurfaceProducer;)Lio/flutter/plugins/videoplayer/ExoPlayerEventListener;
.end method

.method public dispose()V
    .locals 1

    .line 237
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->disposeHandler:Lio/flutter/plugins/videoplayer/VideoPlayer$DisposeHandler;

    if-eqz v0, :cond_0

    .line 238
    invoke-interface {v0}, Lio/flutter/plugins/videoplayer/VideoPlayer$DisposeHandler;->onDispose()V

    .line 240
    :cond_0
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-interface {v0}, Landroidx/media3/exoplayer/ExoPlayer;->release()V

    return-void
.end method

.method public getAudioTracks()Lio/flutter/plugins/videoplayer/NativeAudioTrackData;
    .locals 22

    .line 150
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    move-object/from16 v1, p0

    .line 153
    iget-object v2, v1, Lio/flutter/plugins/videoplayer/VideoPlayer;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-interface {v2}, Landroidx/media3/exoplayer/ExoPlayer;->getCurrentTracks()Landroidx/media3/common/Tracks;

    move-result-object v2

    const/4 v4, 0x0

    .line 156
    :goto_0
    invoke-virtual {v2}, Landroidx/media3/common/Tracks;->getGroups()Lcom/google/common/collect/ImmutableList;

    move-result-object v5

    invoke-virtual {v5}, Lcom/google/common/collect/ImmutableList;->size()I

    move-result v5

    if-ge v4, v5, :cond_5

    .line 157
    invoke-virtual {v2}, Landroidx/media3/common/Tracks;->getGroups()Lcom/google/common/collect/ImmutableList;

    move-result-object v5

    invoke-virtual {v5, v4}, Lcom/google/common/collect/ImmutableList;->get(I)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Landroidx/media3/common/Tracks$Group;

    .line 160
    invoke-virtual {v5}, Landroidx/media3/common/Tracks$Group;->getType()I

    move-result v6

    const/4 v7, 0x1

    if-ne v6, v7, :cond_4

    const/4 v6, 0x0

    .line 161
    :goto_1
    iget v7, v5, Landroidx/media3/common/Tracks$Group;->length:I

    if-ge v6, v7, :cond_4

    .line 162
    invoke-virtual {v5, v6}, Landroidx/media3/common/Tracks$Group;->getTrackFormat(I)Landroidx/media3/common/Format;

    move-result-object v7

    .line 163
    invoke-virtual {v5, v6}, Landroidx/media3/common/Tracks$Group;->isTrackSelected(I)Z

    move-result v15

    .line 166
    new-instance v8, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;

    int-to-long v9, v4

    int-to-long v11, v6

    iget-object v13, v7, Landroidx/media3/common/Format;->label:Ljava/lang/String;

    iget-object v14, v7, Landroidx/media3/common/Format;->language:Ljava/lang/String;

    .line 173
    iget v3, v7, Landroidx/media3/common/Format;->bitrate:I

    const/4 v1, -0x1

    const/16 v16, 0x0

    if-eq v3, v1, :cond_0

    iget v3, v7, Landroidx/media3/common/Format;->bitrate:I

    move-object/from16 v20, v2

    int-to-long v1, v3

    invoke-static {v1, v2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v1

    goto :goto_2

    :cond_0
    move-object/from16 v20, v2

    move-object/from16 v1, v16

    .line 174
    :goto_2
    iget v2, v7, Landroidx/media3/common/Format;->sampleRate:I

    const/4 v3, -0x1

    if-eq v2, v3, :cond_1

    iget v2, v7, Landroidx/media3/common/Format;->sampleRate:I

    move/from16 v21, v4

    int-to-long v3, v2

    invoke-static {v3, v4}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v2

    goto :goto_3

    :cond_1
    move/from16 v21, v4

    move-object/from16 v2, v16

    .line 175
    :goto_3
    iget v3, v7, Landroidx/media3/common/Format;->channelCount:I

    const/4 v4, -0x1

    if-eq v3, v4, :cond_2

    iget v3, v7, Landroidx/media3/common/Format;->channelCount:I

    int-to-long v3, v3

    invoke-static {v3, v4}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v3

    move-object/from16 v18, v3

    goto :goto_4

    :cond_2
    move-object/from16 v18, v16

    .line 176
    :goto_4
    iget-object v3, v7, Landroidx/media3/common/Format;->codecs:Ljava/lang/String;

    if-eqz v3, :cond_3

    iget-object v3, v7, Landroidx/media3/common/Format;->codecs:Ljava/lang/String;

    move-object/from16 v19, v3

    move-object/from16 v16, v1

    move-object/from16 v17, v2

    goto :goto_5

    :cond_3
    move-object/from16 v19, v16

    move-object/from16 v17, v2

    move-object/from16 v16, v1

    :goto_5
    invoke-direct/range {v8 .. v19}, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;-><init>(JJLjava/lang/String;Ljava/lang/String;ZLjava/lang/Long;Ljava/lang/Long;Ljava/lang/Long;Ljava/lang/String;)V

    .line 178
    invoke-interface {v0, v8}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    add-int/lit8 v6, v6, 0x1

    move-object/from16 v1, p0

    move-object/from16 v2, v20

    move/from16 v4, v21

    goto :goto_1

    :cond_4
    move-object/from16 v20, v2

    move/from16 v21, v4

    add-int/lit8 v4, v21, 0x1

    move-object/from16 v1, p0

    move-object/from16 v2, v20

    goto/16 :goto_0

    .line 182
    :cond_5
    new-instance v1, Lio/flutter/plugins/videoplayer/NativeAudioTrackData;

    invoke-direct {v1, v0}, Lio/flutter/plugins/videoplayer/NativeAudioTrackData;-><init>(Ljava/util/List;)V

    return-object v1
.end method

.method public getBufferedPosition()J
    .locals 2

    .line 133
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-interface {v0}, Landroidx/media3/exoplayer/ExoPlayer;->getBufferedPosition()J

    move-result-wide v0

    return-wide v0
.end method

.method public getCurrentPosition()J
    .locals 2

    .line 128
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-interface {v0}, Landroidx/media3/exoplayer/ExoPlayer;->getCurrentPosition()J

    move-result-wide v0

    return-wide v0
.end method

.method public getExoPlayer()Landroidx/media3/exoplayer/ExoPlayer;
    .locals 1

    .line 143
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    return-object v0
.end method

.method public pause()V
    .locals 1

    .line 103
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-interface {v0}, Landroidx/media3/exoplayer/ExoPlayer;->pause()V

    return-void
.end method

.method public play()V
    .locals 1

    .line 98
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-interface {v0}, Landroidx/media3/exoplayer/ExoPlayer;->play()V

    return-void
.end method

.method public seekTo(J)V
    .locals 1

    .line 138
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-interface {v0, p1, p2}, Landroidx/media3/exoplayer/ExoPlayer;->seekTo(J)V

    return-void
.end method

.method public selectAudioTrack(JJ)V
    .locals 7

    .line 189
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->trackSelector:Landroidx/media3/exoplayer/trackselection/DefaultTrackSelector;

    if-eqz v0, :cond_3

    .line 194
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-interface {v0}, Landroidx/media3/exoplayer/ExoPlayer;->getCurrentTracks()Landroidx/media3/common/Tracks;

    move-result-object v0

    const-wide/16 v1, 0x0

    cmp-long v3, p1, v1

    .line 196
    const-string v4, ")"

    if-ltz v3, :cond_2

    invoke-virtual {v0}, Landroidx/media3/common/Tracks;->getGroups()Lcom/google/common/collect/ImmutableList;

    move-result-object v3

    invoke-virtual {v3}, Lcom/google/common/collect/ImmutableList;->size()I

    move-result v3

    int-to-long v5, v3

    cmp-long v3, p1, v5

    if-gez v3, :cond_2

    .line 205
    invoke-virtual {v0}, Landroidx/media3/common/Tracks;->getGroups()Lcom/google/common/collect/ImmutableList;

    move-result-object v0

    long-to-int v3, p1

    invoke-virtual {v0, v3}, Lcom/google/common/collect/ImmutableList;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroidx/media3/common/Tracks$Group;

    .line 208
    invoke-virtual {v0}, Landroidx/media3/common/Tracks$Group;->getType()I

    move-result v3

    const/4 v5, 0x1

    if-ne v3, v5, :cond_1

    cmp-long p1, p3, v1

    if-ltz p1, :cond_0

    long-to-int p1, p3

    .line 218
    iget p2, v0, Landroidx/media3/common/Tracks$Group;->length:I

    if-ge p1, p2, :cond_0

    .line 228
    invoke-virtual {v0}, Landroidx/media3/common/Tracks$Group;->getMediaTrackGroup()Landroidx/media3/common/TrackGroup;

    move-result-object p2

    .line 229
    new-instance p3, Landroidx/media3/common/TrackSelectionOverride;

    invoke-direct {p3, p2, p1}, Landroidx/media3/common/TrackSelectionOverride;-><init>(Landroidx/media3/common/TrackGroup;I)V

    .line 232
    iget-object p1, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->trackSelector:Landroidx/media3/exoplayer/trackselection/DefaultTrackSelector;

    .line 233
    invoke-virtual {p1}, Landroidx/media3/exoplayer/trackselection/DefaultTrackSelector;->buildUponParameters()Landroidx/media3/exoplayer/trackselection/DefaultTrackSelector$Parameters$Builder;

    move-result-object p2

    invoke-virtual {p2, p3}, Landroidx/media3/exoplayer/trackselection/DefaultTrackSelector$Parameters$Builder;->setOverrideForType(Landroidx/media3/common/TrackSelectionOverride;)Landroidx/media3/exoplayer/trackselection/DefaultTrackSelector$Parameters$Builder;

    move-result-object p2

    invoke-virtual {p2}, Landroidx/media3/exoplayer/trackselection/DefaultTrackSelector$Parameters$Builder;->build()Landroidx/media3/exoplayer/trackselection/DefaultTrackSelector$Parameters;

    move-result-object p2

    .line 232
    invoke-virtual {p1, p2}, Landroidx/media3/exoplayer/trackselection/DefaultTrackSelector;->setParameters(Landroidx/media3/common/TrackSelectionParameters;)V

    return-void

    .line 219
    :cond_0
    new-instance p1, Ljava/lang/IllegalArgumentException;

    new-instance p2, Ljava/lang/StringBuilder;

    const-string v1, "Cannot select audio track: trackIndex "

    invoke-direct {p2, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p2, p3, p4}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object p2

    const-string p3, " is out of bounds (available tracks in group: "

    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    iget p3, v0, Landroidx/media3/common/Tracks$Group;->length:I

    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p2

    invoke-direct {p1, p2}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p1

    .line 209
    :cond_1
    new-instance p3, Ljava/lang/IllegalArgumentException;

    new-instance p4, Ljava/lang/StringBuilder;

    const-string v1, "Cannot select audio track: group at index "

    invoke-direct {p4, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p4, p1, p2}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string p2, " is not an audio track (type: "

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    .line 213
    invoke-virtual {v0}, Landroidx/media3/common/Tracks$Group;->getType()I

    move-result p2

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p3, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p3

    .line 197
    :cond_2
    new-instance p3, Ljava/lang/IllegalArgumentException;

    new-instance p4, Ljava/lang/StringBuilder;

    const-string v1, "Cannot select audio track: groupIndex "

    invoke-direct {p4, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p4, p1, p2}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string p2, " is out of bounds (available groups: "

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    .line 201
    invoke-virtual {v0}, Landroidx/media3/common/Tracks;->getGroups()Lcom/google/common/collect/ImmutableList;

    move-result-object p2

    invoke-virtual {p2}, Lcom/google/common/collect/ImmutableList;->size()I

    move-result p2

    invoke-virtual {p1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p3, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p3

    .line 190
    :cond_3
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string p2, "Cannot select audio track: track selector is null"

    invoke-direct {p1, p2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method public setDisposeHandler(Lio/flutter/plugins/videoplayer/VideoPlayer$DisposeHandler;)V
    .locals 0

    .line 83
    iput-object p1, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->disposeHandler:Lio/flutter/plugins/videoplayer/VideoPlayer$DisposeHandler;

    return-void
.end method

.method public setLooping(Z)V
    .locals 1

    .line 108
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    if-eqz p1, :cond_0

    const/4 p1, 0x2

    goto :goto_0

    :cond_0
    const/4 p1, 0x0

    :goto_0
    invoke-interface {v0, p1}, Landroidx/media3/exoplayer/ExoPlayer;->setRepeatMode(I)V

    return-void
.end method

.method public setPlaybackSpeed(D)V
    .locals 1

    .line 121
    new-instance v0, Landroidx/media3/common/PlaybackParameters;

    double-to-float p1, p1

    invoke-direct {v0, p1}, Landroidx/media3/common/PlaybackParameters;-><init>(F)V

    .line 123
    iget-object p1, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-interface {p1, v0}, Landroidx/media3/exoplayer/ExoPlayer;->setPlaybackParameters(Landroidx/media3/common/PlaybackParameters;)V

    return-void
.end method

.method public setVolume(D)V
    .locals 2

    const-wide/high16 v0, 0x3ff0000000000000L    # 1.0

    .line 113
    invoke-static {v0, v1, p1, p2}, Ljava/lang/Math;->min(DD)D

    move-result-wide p1

    const-wide/16 v0, 0x0

    invoke-static {v0, v1, p1, p2}, Ljava/lang/Math;->max(DD)D

    move-result-wide p1

    double-to-float p1, p1

    .line 114
    iget-object p2, p0, Lio/flutter/plugins/videoplayer/VideoPlayer;->exoPlayer:Landroidx/media3/exoplayer/ExoPlayer;

    invoke-interface {p2, p1}, Landroidx/media3/exoplayer/ExoPlayer;->setVolume(F)V

    return-void
.end method
