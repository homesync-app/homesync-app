package io.flutter.plugins.videoplayer;

import androidx.media3.common.PlaybackException;
import androidx.media3.common.Player;
import androidx.media3.common.Tracks;
import androidx.media3.exoplayer.ExoPlayer;
import com.google.common.collect.UnmodifiableIterator;

/* JADX INFO: loaded from: classes4.dex */
public abstract class ExoPlayerEventListener implements Player.Listener {
    protected final VideoPlayerCallbacks events;
    protected final ExoPlayer exoPlayer;
    private boolean isInitialized = false;

    protected abstract void sendInitialized();

    protected enum RotationDegrees {
        ROTATE_0(0),
        ROTATE_90(90),
        ROTATE_180(180),
        ROTATE_270(270);

        private final int degrees;

        RotationDegrees(int i) {
            this.degrees = i;
        }

        public static RotationDegrees fromDegrees(int i) {
            for (RotationDegrees rotationDegrees : values()) {
                if (rotationDegrees.degrees == i) {
                    return rotationDegrees;
                }
            }
            throw new IllegalArgumentException("Invalid rotation degrees specified: " + i);
        }

        public int getDegrees() {
            return this.degrees;
        }
    }

    public ExoPlayerEventListener(ExoPlayer exoPlayer, VideoPlayerCallbacks videoPlayerCallbacks) {
        this.exoPlayer = exoPlayer;
        this.events = videoPlayerCallbacks;
    }

    @Override // androidx.media3.common.Player.Listener
    public void onPlaybackStateChanged(int i) {
        PlatformPlaybackState platformPlaybackState = PlatformPlaybackState.UNKNOWN;
        if (i == 1) {
            platformPlaybackState = PlatformPlaybackState.IDLE;
        } else if (i == 2) {
            platformPlaybackState = PlatformPlaybackState.BUFFERING;
        } else if (i == 3) {
            platformPlaybackState = PlatformPlaybackState.READY;
            if (!this.isInitialized) {
                this.isInitialized = true;
                sendInitialized();
            }
        } else if (i == 4) {
            platformPlaybackState = PlatformPlaybackState.ENDED;
        }
        this.events.onPlaybackStateChanged(platformPlaybackState);
    }

    @Override // androidx.media3.common.Player.Listener
    public void onPlayerError(PlaybackException playbackException) {
        if (playbackException.errorCode == 1002) {
            this.exoPlayer.seekToDefaultPosition();
            this.exoPlayer.prepare();
        } else {
            this.events.onError("VideoError", "Video player had error " + playbackException, null);
        }
    }

    @Override // androidx.media3.common.Player.Listener
    public void onIsPlayingChanged(boolean z) {
        this.events.onIsPlayingStateUpdate(z);
    }

    @Override // androidx.media3.common.Player.Listener
    public void onTracksChanged(Tracks tracks) {
        this.events.onAudioTrackChanged(findSelectedAudioTrackId(tracks));
    }

    private String findSelectedAudioTrackId(Tracks tracks) {
        UnmodifiableIterator<Tracks.Group> it = tracks.getGroups().iterator();
        int i = 0;
        while (it.hasNext()) {
            Tracks.Group next = it.next();
            if (next.getType() == 1 && next.isSelected()) {
                for (int i2 = 0; i2 < next.length; i2++) {
                    if (next.isTrackSelected(i2)) {
                        return i + "_" + i2;
                    }
                }
            }
            i++;
        }
        return null;
    }
}
