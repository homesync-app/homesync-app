package io.flutter.plugins.videoplayer;

import io.flutter.plugin.common.BinaryMessenger;

/* JADX INFO: loaded from: classes4.dex */
final class VideoPlayerEventCallbacks implements VideoPlayerCallbacks {
    private final QueuingEventSink eventSink;

    static VideoPlayerEventCallbacks bindTo(BinaryMessenger binaryMessenger, String str) {
        final QueuingEventSink queuingEventSink = new QueuingEventSink();
        VideoEventsStreamHandler.INSTANCE.register(binaryMessenger, new VideoEventsStreamHandler() { // from class: io.flutter.plugins.videoplayer.VideoPlayerEventCallbacks.1
            @Override // io.flutter.plugins.videoplayer.VideoEventsStreamHandler, io.flutter.plugins.videoplayer.MessagesPigeonEventChannelWrapper
            public void onListen(Object obj, PigeonEventSink<PlatformVideoEvent> pigeonEventSink) {
                queuingEventSink.setDelegate(pigeonEventSink);
            }

            @Override // io.flutter.plugins.videoplayer.VideoEventsStreamHandler, io.flutter.plugins.videoplayer.MessagesPigeonEventChannelWrapper
            public void onCancel(Object obj) {
                queuingEventSink.setDelegate(null);
            }
        }, str);
        return withSink(queuingEventSink);
    }

    static VideoPlayerEventCallbacks withSink(QueuingEventSink queuingEventSink) {
        return new VideoPlayerEventCallbacks(queuingEventSink);
    }

    private VideoPlayerEventCallbacks(QueuingEventSink queuingEventSink) {
        this.eventSink = queuingEventSink;
    }

    @Override // io.flutter.plugins.videoplayer.VideoPlayerCallbacks
    public void onInitialized(int i, int i2, long j, int i3) {
        this.eventSink.success(new InitializationEvent(j, i, i2, i3));
    }

    @Override // io.flutter.plugins.videoplayer.VideoPlayerCallbacks
    public void onPlaybackStateChanged(PlatformPlaybackState platformPlaybackState) {
        this.eventSink.success(new PlaybackStateChangeEvent(platformPlaybackState));
    }

    @Override // io.flutter.plugins.videoplayer.VideoPlayerCallbacks
    public void onError(String str, String str2, Object obj) {
        this.eventSink.error(str, str2, obj);
    }

    @Override // io.flutter.plugins.videoplayer.VideoPlayerCallbacks
    public void onIsPlayingStateUpdate(boolean z) {
        this.eventSink.success(new IsPlayingStateEvent(z));
    }

    @Override // io.flutter.plugins.videoplayer.VideoPlayerCallbacks
    public void onAudioTrackChanged(String str) {
        this.eventSink.success(new AudioTrackChangedEvent(str));
    }
}
