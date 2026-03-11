package io.flutter.plugins.videoplayer;

/* JADX INFO: loaded from: classes4.dex */
public interface VideoPlayerCallbacks {
    void onAudioTrackChanged(String str);

    void onError(String str, String str2, Object obj);

    void onInitialized(int i, int i2, long j, int i3);

    void onIsPlayingStateUpdate(boolean z);

    void onPlaybackStateChanged(PlatformPlaybackState platformPlaybackState);
}
