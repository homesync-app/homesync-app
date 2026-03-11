package io.flutter.plugins.videoplayer;

import androidx.media3.common.AudioAttributes;
import androidx.media3.common.Format;
import androidx.media3.common.MediaItem;
import androidx.media3.common.PlaybackParameters;
import androidx.media3.common.TrackSelectionOverride;
import androidx.media3.common.Tracks;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector;
import io.flutter.view.TextureRegistry;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes4.dex */
public abstract class VideoPlayer implements VideoPlayerInstanceApi {
    private DisposeHandler disposeHandler;
    protected ExoPlayer exoPlayer;
    protected final TextureRegistry.SurfaceProducer surfaceProducer;
    protected DefaultTrackSelector trackSelector;
    protected final VideoPlayerCallbacks videoPlayerEvents;

    public interface DisposeHandler {
        void onDispose();
    }

    public interface ExoPlayerProvider {
        ExoPlayer get();
    }

    protected abstract ExoPlayerEventListener createExoPlayerEventListener(ExoPlayer exoPlayer, TextureRegistry.SurfaceProducer surfaceProducer);

    public VideoPlayer(VideoPlayerCallbacks videoPlayerCallbacks, MediaItem mediaItem, VideoPlayerOptions videoPlayerOptions, TextureRegistry.SurfaceProducer surfaceProducer, ExoPlayerProvider exoPlayerProvider) {
        this.videoPlayerEvents = videoPlayerCallbacks;
        this.surfaceProducer = surfaceProducer;
        ExoPlayer exoPlayer = exoPlayerProvider.get();
        this.exoPlayer = exoPlayer;
        if (exoPlayer.getTrackSelector() instanceof DefaultTrackSelector) {
            this.trackSelector = (DefaultTrackSelector) this.exoPlayer.getTrackSelector();
        }
        this.exoPlayer.setMediaItem(mediaItem);
        this.exoPlayer.prepare();
        ExoPlayer exoPlayer2 = this.exoPlayer;
        exoPlayer2.addListener(createExoPlayerEventListener(exoPlayer2, surfaceProducer));
        setAudioAttributes(this.exoPlayer, videoPlayerOptions.mixWithOthers);
    }

    public void setDisposeHandler(DisposeHandler disposeHandler) {
        this.disposeHandler = disposeHandler;
    }

    private static void setAudioAttributes(ExoPlayer exoPlayer, boolean z) {
        exoPlayer.setAudioAttributes(new AudioAttributes.Builder().setContentType(3).build(), !z);
    }

    @Override // io.flutter.plugins.videoplayer.VideoPlayerInstanceApi
    public void play() {
        this.exoPlayer.play();
    }

    @Override // io.flutter.plugins.videoplayer.VideoPlayerInstanceApi
    public void pause() {
        this.exoPlayer.pause();
    }

    @Override // io.flutter.plugins.videoplayer.VideoPlayerInstanceApi
    public void setLooping(boolean z) {
        this.exoPlayer.setRepeatMode(z ? 2 : 0);
    }

    @Override // io.flutter.plugins.videoplayer.VideoPlayerInstanceApi
    public void setVolume(double d) {
        this.exoPlayer.setVolume((float) Math.max(0.0d, Math.min(1.0d, d)));
    }

    @Override // io.flutter.plugins.videoplayer.VideoPlayerInstanceApi
    public void setPlaybackSpeed(double d) {
        this.exoPlayer.setPlaybackParameters(new PlaybackParameters((float) d));
    }

    @Override // io.flutter.plugins.videoplayer.VideoPlayerInstanceApi
    public long getCurrentPosition() {
        return this.exoPlayer.getCurrentPosition();
    }

    @Override // io.flutter.plugins.videoplayer.VideoPlayerInstanceApi
    public long getBufferedPosition() {
        return this.exoPlayer.getBufferedPosition();
    }

    @Override // io.flutter.plugins.videoplayer.VideoPlayerInstanceApi
    public void seekTo(long j) {
        this.exoPlayer.seekTo(j);
    }

    public ExoPlayer getExoPlayer() {
        return this.exoPlayer;
    }

    @Override // io.flutter.plugins.videoplayer.VideoPlayerInstanceApi
    public NativeAudioTrackData getAudioTracks() {
        Tracks tracks;
        Long lValueOf;
        int i;
        Long lValueOf2;
        String str;
        Long l;
        Long l2;
        ArrayList arrayList = new ArrayList();
        Tracks currentTracks = this.exoPlayer.getCurrentTracks();
        int i2 = 0;
        while (i2 < currentTracks.getGroups().size()) {
            Tracks.Group group = currentTracks.getGroups().get(i2);
            if (group.getType() == 1) {
                int i3 = 0;
                while (i3 < group.length) {
                    Format trackFormat = group.getTrackFormat(i3);
                    boolean zIsTrackSelected = group.isTrackSelected(i3);
                    long j = i2;
                    long j2 = i3;
                    String str2 = trackFormat.label;
                    String str3 = trackFormat.language;
                    if (trackFormat.bitrate != -1) {
                        tracks = currentTracks;
                        lValueOf = Long.valueOf(trackFormat.bitrate);
                    } else {
                        tracks = currentTracks;
                        lValueOf = null;
                    }
                    if (trackFormat.sampleRate != -1) {
                        i = i2;
                        lValueOf2 = Long.valueOf(trackFormat.sampleRate);
                    } else {
                        i = i2;
                        lValueOf2 = null;
                    }
                    Long lValueOf3 = trackFormat.channelCount != -1 ? Long.valueOf(trackFormat.channelCount) : null;
                    if (trackFormat.codecs != null) {
                        str = trackFormat.codecs;
                        l2 = lValueOf;
                        l = lValueOf2;
                    } else {
                        str = null;
                        l = lValueOf2;
                        l2 = lValueOf;
                    }
                    arrayList.add(new ExoPlayerAudioTrackData(j, j2, str2, str3, zIsTrackSelected, l2, l, lValueOf3, str));
                    i3++;
                    currentTracks = tracks;
                    i2 = i;
                }
            }
            i2++;
            currentTracks = currentTracks;
        }
        return new NativeAudioTrackData(arrayList);
    }

    @Override // io.flutter.plugins.videoplayer.VideoPlayerInstanceApi
    public void selectAudioTrack(long j, long j2) {
        int i;
        if (this.trackSelector == null) {
            throw new IllegalStateException("Cannot select audio track: track selector is null");
        }
        Tracks currentTracks = this.exoPlayer.getCurrentTracks();
        if (j < 0 || j >= currentTracks.getGroups().size()) {
            throw new IllegalArgumentException("Cannot select audio track: groupIndex " + j + " is out of bounds (available groups: " + currentTracks.getGroups().size() + ")");
        }
        Tracks.Group group = currentTracks.getGroups().get((int) j);
        if (group.getType() != 1) {
            throw new IllegalArgumentException("Cannot select audio track: group at index " + j + " is not an audio track (type: " + group.getType() + ")");
        }
        if (j2 < 0 || (i = (int) j2) >= group.length) {
            throw new IllegalArgumentException("Cannot select audio track: trackIndex " + j2 + " is out of bounds (available tracks in group: " + group.length + ")");
        }
        TrackSelectionOverride trackSelectionOverride = new TrackSelectionOverride(group.getMediaTrackGroup(), i);
        DefaultTrackSelector defaultTrackSelector = this.trackSelector;
        defaultTrackSelector.setParameters(defaultTrackSelector.buildUponParameters().setOverrideForType(trackSelectionOverride).build());
    }

    public void dispose() {
        DisposeHandler disposeHandler = this.disposeHandler;
        if (disposeHandler != null) {
            disposeHandler.onDispose();
        }
        this.exoPlayer.release();
    }
}
