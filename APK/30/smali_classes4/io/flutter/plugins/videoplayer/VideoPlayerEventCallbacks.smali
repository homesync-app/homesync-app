.class final Lio/flutter/plugins/videoplayer/VideoPlayerEventCallbacks;
.super Ljava/lang/Object;
.source "VideoPlayerEventCallbacks.java"

# interfaces
.implements Lio/flutter/plugins/videoplayer/VideoPlayerCallbacks;


# instance fields
.field private final eventSink:Lio/flutter/plugins/videoplayer/QueuingEventSink;


# direct methods
.method private constructor <init>(Lio/flutter/plugins/videoplayer/QueuingEventSink;)V
    .locals 0

    .line 41
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 42
    iput-object p1, p0, Lio/flutter/plugins/videoplayer/VideoPlayerEventCallbacks;->eventSink:Lio/flutter/plugins/videoplayer/QueuingEventSink;

    return-void
.end method

.method static bindTo(Lio/flutter/plugin/common/BinaryMessenger;Ljava/lang/String;)Lio/flutter/plugins/videoplayer/VideoPlayerEventCallbacks;
    .locals 3

    .line 17
    new-instance v0, Lio/flutter/plugins/videoplayer/QueuingEventSink;

    invoke-direct {v0}, Lio/flutter/plugins/videoplayer/QueuingEventSink;-><init>()V

    .line 18
    sget-object v1, Lio/flutter/plugins/videoplayer/VideoEventsStreamHandler;->Companion:Lio/flutter/plugins/videoplayer/VideoEventsStreamHandler$Companion;

    new-instance v2, Lio/flutter/plugins/videoplayer/VideoPlayerEventCallbacks$1;

    invoke-direct {v2, v0}, Lio/flutter/plugins/videoplayer/VideoPlayerEventCallbacks$1;-><init>(Lio/flutter/plugins/videoplayer/QueuingEventSink;)V

    invoke-virtual {v1, p0, v2, p1}, Lio/flutter/plugins/videoplayer/VideoEventsStreamHandler$Companion;->register(Lio/flutter/plugin/common/BinaryMessenger;Lio/flutter/plugins/videoplayer/VideoEventsStreamHandler;Ljava/lang/String;)V

    .line 33
    invoke-static {v0}, Lio/flutter/plugins/videoplayer/VideoPlayerEventCallbacks;->withSink(Lio/flutter/plugins/videoplayer/QueuingEventSink;)Lio/flutter/plugins/videoplayer/VideoPlayerEventCallbacks;

    move-result-object p0

    return-object p0
.end method

.method static withSink(Lio/flutter/plugins/videoplayer/QueuingEventSink;)Lio/flutter/plugins/videoplayer/VideoPlayerEventCallbacks;
    .locals 1

    .line 38
    new-instance v0, Lio/flutter/plugins/videoplayer/VideoPlayerEventCallbacks;

    invoke-direct {v0, p0}, Lio/flutter/plugins/videoplayer/VideoPlayerEventCallbacks;-><init>(Lio/flutter/plugins/videoplayer/QueuingEventSink;)V

    return-object v0
.end method


# virtual methods
.method public onAudioTrackChanged(Ljava/lang/String;)V
    .locals 2

    .line 69
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/VideoPlayerEventCallbacks;->eventSink:Lio/flutter/plugins/videoplayer/QueuingEventSink;

    new-instance v1, Lio/flutter/plugins/videoplayer/AudioTrackChangedEvent;

    invoke-direct {v1, p1}, Lio/flutter/plugins/videoplayer/AudioTrackChangedEvent;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, v1}, Lio/flutter/plugins/videoplayer/QueuingEventSink;->success(Lio/flutter/plugins/videoplayer/PlatformVideoEvent;)V

    return-void
.end method

.method public onError(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V
    .locals 1

    .line 59
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/VideoPlayerEventCallbacks;->eventSink:Lio/flutter/plugins/videoplayer/QueuingEventSink;

    invoke-virtual {v0, p1, p2, p3}, Lio/flutter/plugins/videoplayer/QueuingEventSink;->error(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V

    return-void
.end method

.method public onInitialized(IIJI)V
    .locals 10

    .line 48
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/VideoPlayerEventCallbacks;->eventSink:Lio/flutter/plugins/videoplayer/QueuingEventSink;

    new-instance v1, Lio/flutter/plugins/videoplayer/InitializationEvent;

    int-to-long v4, p1

    int-to-long v6, p2

    int-to-long v8, p5

    move-wide v2, p3

    invoke-direct/range {v1 .. v9}, Lio/flutter/plugins/videoplayer/InitializationEvent;-><init>(JJJJ)V

    invoke-virtual {v0, v1}, Lio/flutter/plugins/videoplayer/QueuingEventSink;->success(Lio/flutter/plugins/videoplayer/PlatformVideoEvent;)V

    return-void
.end method

.method public onIsPlayingStateUpdate(Z)V
    .locals 2

    .line 64
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/VideoPlayerEventCallbacks;->eventSink:Lio/flutter/plugins/videoplayer/QueuingEventSink;

    new-instance v1, Lio/flutter/plugins/videoplayer/IsPlayingStateEvent;

    invoke-direct {v1, p1}, Lio/flutter/plugins/videoplayer/IsPlayingStateEvent;-><init>(Z)V

    invoke-virtual {v0, v1}, Lio/flutter/plugins/videoplayer/QueuingEventSink;->success(Lio/flutter/plugins/videoplayer/PlatformVideoEvent;)V

    return-void
.end method

.method public onPlaybackStateChanged(Lio/flutter/plugins/videoplayer/PlatformPlaybackState;)V
    .locals 2

    .line 54
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/VideoPlayerEventCallbacks;->eventSink:Lio/flutter/plugins/videoplayer/QueuingEventSink;

    new-instance v1, Lio/flutter/plugins/videoplayer/PlaybackStateChangeEvent;

    invoke-direct {v1, p1}, Lio/flutter/plugins/videoplayer/PlaybackStateChangeEvent;-><init>(Lio/flutter/plugins/videoplayer/PlatformPlaybackState;)V

    invoke-virtual {v0, v1}, Lio/flutter/plugins/videoplayer/QueuingEventSink;->success(Lio/flutter/plugins/videoplayer/PlatformVideoEvent;)V

    return-void
.end method
