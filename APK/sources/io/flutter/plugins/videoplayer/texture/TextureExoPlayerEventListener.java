package io.flutter.plugins.videoplayer.texture;

import androidx.media3.common.Format;
import androidx.media3.common.VideoSize;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugins.videoplayer.ExoPlayerEventListener;
import io.flutter.plugins.videoplayer.VideoPlayerCallbacks;
import java.util.Objects;

/* JADX INFO: loaded from: classes4.dex */
public final class TextureExoPlayerEventListener extends ExoPlayerEventListener {
    private final boolean surfaceProducerHandlesCropAndRotation;

    public TextureExoPlayerEventListener(ExoPlayer exoPlayer, VideoPlayerCallbacks videoPlayerCallbacks, boolean z) {
        super(exoPlayer, videoPlayerCallbacks);
        this.surfaceProducerHandlesCropAndRotation = z;
    }

    @Override // io.flutter.plugins.videoplayer.ExoPlayerEventListener
    protected void sendInitialized() {
        VideoSize videoSize = this.exoPlayer.getVideoSize();
        ExoPlayerEventListener.RotationDegrees rotationDegreesFromDegrees = ExoPlayerEventListener.RotationDegrees.ROTATE_0;
        int i = videoSize.width;
        int i2 = videoSize.height;
        if (i != 0 && i2 != 0 && !this.surfaceProducerHandlesCropAndRotation) {
            try {
                rotationDegreesFromDegrees = ExoPlayerEventListener.RotationDegrees.fromDegrees(getRotationCorrectionFromFormat(this.exoPlayer));
            } catch (IllegalArgumentException unused) {
                rotationDegreesFromDegrees = ExoPlayerEventListener.RotationDegrees.ROTATE_0;
            }
        }
        this.events.onInitialized(i, i2, this.exoPlayer.getDuration(), rotationDegreesFromDegrees.getDegrees());
    }

    private int getRotationCorrectionFromFormat(ExoPlayer exoPlayer) {
        return ((Format) Objects.requireNonNull(exoPlayer.getVideoFormat())).rotationDegrees;
    }
}
