package androidx.media3.common;

import com.google.common.collect.ImmutableList;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class PlayerTransferState {
    private final int currentMediaItemIndex;
    private final long currentPosition;
    private final ImmutableList<MediaItem> mediaItems;
    private final boolean playWhenReady;
    private final PlaybackParameters playbackParameters;
    private final int repeatMode;
    private final boolean shuffleModeEnabled;
    private final TrackSelectionParameters trackSelectionParameters;

    public static final class Builder {
        private int currentMediaItemIndex;
        private long currentPosition;
        private ImmutableList<MediaItem> mediaItems;
        private boolean playWhenReady;
        private PlaybackParameters playbackParameters;
        private int repeatMode;
        private boolean shuffleModeEnabled;
        private TrackSelectionParameters trackSelectionParameters;

        public Builder() {
            this.playWhenReady = false;
            this.repeatMode = 0;
            this.shuffleModeEnabled = false;
            this.currentMediaItemIndex = 0;
            this.currentPosition = 0L;
            this.mediaItems = ImmutableList.of();
            this.playbackParameters = PlaybackParameters.DEFAULT;
            this.trackSelectionParameters = TrackSelectionParameters.DEFAULT;
        }

        private Builder(PlayerTransferState playerTransferState) {
            this.playWhenReady = playerTransferState.playWhenReady;
            this.repeatMode = playerTransferState.repeatMode;
            this.shuffleModeEnabled = playerTransferState.shuffleModeEnabled;
            this.currentMediaItemIndex = playerTransferState.currentMediaItemIndex;
            this.currentPosition = playerTransferState.currentPosition;
            this.mediaItems = playerTransferState.mediaItems;
            this.playbackParameters = playerTransferState.playbackParameters;
            this.trackSelectionParameters = playerTransferState.trackSelectionParameters;
        }

        public Builder setPlayWhenReady(boolean z) {
            this.playWhenReady = z;
            return this;
        }

        public Builder setRepeatMode(int i) {
            this.repeatMode = i;
            return this;
        }

        public Builder setShuffleModeEnabled(boolean z) {
            this.shuffleModeEnabled = z;
            return this;
        }

        public Builder setCurrentMediaItemIndex(int i) {
            this.currentMediaItemIndex = i;
            return this;
        }

        public Builder setCurrentPosition(long j) {
            this.currentPosition = j;
            return this;
        }

        public Builder setMediaItems(List<MediaItem> list) {
            this.mediaItems = ImmutableList.copyOf((Collection) list);
            return this;
        }

        public Builder setPlaybackParameters(PlaybackParameters playbackParameters) {
            this.playbackParameters = (PlaybackParameters) Objects.requireNonNull(playbackParameters);
            return this;
        }

        public Builder setTrackSelectionParameters(TrackSelectionParameters trackSelectionParameters) {
            this.trackSelectionParameters = (TrackSelectionParameters) Objects.requireNonNull(trackSelectionParameters);
            return this;
        }

        public PlayerTransferState build() {
            return new PlayerTransferState(this);
        }
    }

    private PlayerTransferState(Builder builder) {
        this.playWhenReady = builder.playWhenReady;
        this.repeatMode = builder.repeatMode;
        this.shuffleModeEnabled = builder.shuffleModeEnabled;
        this.currentMediaItemIndex = builder.currentMediaItemIndex;
        this.currentPosition = builder.currentPosition;
        this.mediaItems = builder.mediaItems;
        this.playbackParameters = builder.playbackParameters;
        this.trackSelectionParameters = builder.trackSelectionParameters;
    }

    public static PlayerTransferState fromPlayer(Player player) {
        return builderFromPlayer(player).build();
    }

    public static Builder builderFromPlayer(Player player) {
        Objects.requireNonNull(player);
        ArrayList arrayList = new ArrayList();
        for (int i = 0; i < player.getMediaItemCount(); i++) {
            arrayList.add(player.getMediaItemAt(i));
        }
        return new Builder().setPlayWhenReady(player.getPlayWhenReady()).setRepeatMode(player.getRepeatMode()).setShuffleModeEnabled(player.getShuffleModeEnabled()).setCurrentMediaItemIndex(player.getCurrentMediaItemIndex()).setCurrentPosition(player.getCurrentPosition()).setMediaItems(arrayList).setPlaybackParameters(player.getPlaybackParameters()).setTrackSelectionParameters(player.getTrackSelectionParameters());
    }

    public void setToPlayer(Player player) {
        Objects.requireNonNull(player);
        if (player.getAvailableCommands().contains(1)) {
            player.setPlayWhenReady(this.playWhenReady);
        }
        if (player.getAvailableCommands().contains(15)) {
            player.setRepeatMode(this.repeatMode);
        }
        if (player.getAvailableCommands().contains(14)) {
            player.setShuffleModeEnabled(this.shuffleModeEnabled);
        }
        if (player.getAvailableCommands().contains(31)) {
            player.setMediaItems(this.mediaItems, this.currentMediaItemIndex, this.currentPosition);
        }
        if (player.getAvailableCommands().contains(13)) {
            player.setPlaybackParameters(this.playbackParameters);
        }
        if (player.getAvailableCommands().contains(29)) {
            player.setTrackSelectionParameters(this.trackSelectionParameters);
        }
    }

    public Builder buildUpon() {
        return new Builder();
    }

    public boolean getPlayWhenReady() {
        return this.playWhenReady;
    }

    public int getRepeatMode() {
        return this.repeatMode;
    }

    public boolean getShuffleModeEnabled() {
        return this.shuffleModeEnabled;
    }

    public int getCurrentMediaItemIndex() {
        return this.currentMediaItemIndex;
    }

    public long getCurrentPosition() {
        return this.currentPosition;
    }

    public ImmutableList<MediaItem> getMediaItems() {
        return this.mediaItems;
    }

    public PlaybackParameters getPlaybackParameters() {
        return this.playbackParameters;
    }

    public TrackSelectionParameters getTrackSelectionParameters() {
        return this.trackSelectionParameters;
    }

    public boolean equals(Object obj) {
        if (obj != null && getClass() == obj.getClass()) {
            PlayerTransferState playerTransferState = (PlayerTransferState) obj;
            if (this.playWhenReady == playerTransferState.playWhenReady && this.repeatMode == playerTransferState.repeatMode && this.shuffleModeEnabled == playerTransferState.shuffleModeEnabled && this.currentMediaItemIndex == playerTransferState.currentMediaItemIndex && this.currentPosition == playerTransferState.currentPosition && Objects.equals(this.mediaItems, playerTransferState.mediaItems) && Objects.equals(this.playbackParameters, playerTransferState.playbackParameters) && Objects.equals(this.trackSelectionParameters, playerTransferState.trackSelectionParameters)) {
                return true;
            }
        }
        return false;
    }

    public int hashCode() {
        return Objects.hash(Boolean.valueOf(this.playWhenReady), Integer.valueOf(this.repeatMode), Boolean.valueOf(this.shuffleModeEnabled), Integer.valueOf(this.currentMediaItemIndex), Long.valueOf(this.currentPosition), this.mediaItems, this.playbackParameters, this.trackSelectionParameters);
    }
}
