package io.flutter.plugins.videoplayer.texture;

import android.content.Context;
import android.view.Surface;
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
public final class TextureVideoPlayer extends VideoPlayer implements TextureRegistry.SurfaceProducer.Callback {
    static final /* synthetic */ boolean $assertionsDisabled = false;
    private boolean needsSurface;

    public static TextureVideoPlayer create(final Context context, VideoPlayerCallbacks videoPlayerCallbacks, TextureRegistry.SurfaceProducer surfaceProducer, final VideoAsset videoAsset, VideoPlayerOptions videoPlayerOptions) {
        return new TextureVideoPlayer(videoPlayerCallbacks, surfaceProducer, videoAsset.getMediaItem(), videoPlayerOptions, new VideoPlayer.ExoPlayerProvider() { // from class: io.flutter.plugins.videoplayer.texture.TextureVideoPlayer$$ExternalSyntheticLambda0
            @Override // io.flutter.plugins.videoplayer.VideoPlayer.ExoPlayerProvider
            public final ExoPlayer get() {
                Context context2 = context;
                return new ExoPlayer.Builder(context2).setTrackSelector(new DefaultTrackSelector(context2)).setMediaSourceFactory(videoAsset.getMediaSourceFactory(context2)).build();
            }
        });
    }

    public TextureVideoPlayer(VideoPlayerCallbacks videoPlayerCallbacks, TextureRegistry.SurfaceProducer surfaceProducer, MediaItem mediaItem, VideoPlayerOptions videoPlayerOptions, VideoPlayer.ExoPlayerProvider exoPlayerProvider) {
        super(videoPlayerCallbacks, mediaItem, videoPlayerOptions, surfaceProducer, exoPlayerProvider);
        this.needsSurface = true;
        surfaceProducer.setCallback(this);
        Surface surface = surfaceProducer.getSurface();
        this.exoPlayer.setVideoSurface(surface);
        this.needsSurface = surface == null;
    }

    @Override // io.flutter.plugins.videoplayer.VideoPlayer
    protected ExoPlayerEventListener createExoPlayerEventListener(ExoPlayer exoPlayer, TextureRegistry.SurfaceProducer surfaceProducer) {
        if (surfaceProducer == null) {
            throw new IllegalArgumentException("surfaceProducer cannot be null to create an ExoPlayerEventListener for TextureVideoPlayer.");
        }
        return new TextureExoPlayerEventListener(exoPlayer, this.videoPlayerEvents, surfaceProducer.handlesCropAndRotation());
    }

    @Override // io.flutter.view.TextureRegistry.SurfaceProducer.Callback
    public void onSurfaceAvailable() {
        if (this.needsSurface) {
            this.exoPlayer.setVideoSurface(this.surfaceProducer.getSurface());
            this.needsSurface = false;
        }
    }

    @Override // io.flutter.view.TextureRegistry.SurfaceProducer.Callback
    public void onSurfaceCleanup() {
        this.exoPlayer.setVideoSurface(null);
        this.needsSurface = true;
    }

    @Override // io.flutter.plugins.videoplayer.VideoPlayer
    public void dispose() {
        super.dispose();
        this.surfaceProducer.release();
    }
}
