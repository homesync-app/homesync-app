package io.flutter.plugins.videoplayer.platformview;

import android.content.Context;
import androidx.media3.common.MediaItem;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector;
import io.flutter.plugins.videoplayer.ExoPlayerEventListener;
import io.flutter.plugins.videoplayer.VideoAsset;
import io.flutter.plugins.videoplayer.VideoPlayer;
import io.flutter.plugins.videoplayer.VideoPlayerCallbacks;
import io.flutter.plugins.videoplayer.VideoPlayerOptions;
import io.flutter.view.TextureRegistry;

/* JADX INFO: loaded from: classes4.dex */
public class PlatformViewVideoPlayer extends VideoPlayer {
    public PlatformViewVideoPlayer(VideoPlayerCallbacks videoPlayerCallbacks, MediaItem mediaItem, VideoPlayerOptions videoPlayerOptions, VideoPlayer.ExoPlayerProvider exoPlayerProvider) {
        super(videoPlayerCallbacks, mediaItem, videoPlayerOptions, null, exoPlayerProvider);
    }

    public static PlatformViewVideoPlayer create(final Context context, VideoPlayerCallbacks videoPlayerCallbacks, final VideoAsset videoAsset, VideoPlayerOptions videoPlayerOptions) {
        return new PlatformViewVideoPlayer(videoPlayerCallbacks, videoAsset.getMediaItem(), videoPlayerOptions, new VideoPlayer.ExoPlayerProvider() { // from class: io.flutter.plugins.videoplayer.platformview.PlatformViewVideoPlayer$$ExternalSyntheticLambda0
            @Override // io.flutter.plugins.videoplayer.VideoPlayer.ExoPlayerProvider
            public final ExoPlayer get() {
                Context context2 = context;
                return new ExoPlayer.Builder(context2).setTrackSelector(new DefaultTrackSelector(context2)).setMediaSourceFactory(videoAsset.getMediaSourceFactory(context2)).build();
            }
        });
    }

    @Override // io.flutter.plugins.videoplayer.VideoPlayer
    protected ExoPlayerEventListener createExoPlayerEventListener(ExoPlayer exoPlayer, TextureRegistry.SurfaceProducer surfaceProducer) {
        return new PlatformViewExoPlayerEventListener(exoPlayer, this.videoPlayerEvents);
    }
}
