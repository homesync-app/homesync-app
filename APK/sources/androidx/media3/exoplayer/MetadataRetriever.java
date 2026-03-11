package androidx.media3.exoplayer;

import android.content.Context;
import androidx.media3.common.MediaItem;
import androidx.media3.common.Timeline;
import androidx.media3.common.util.Clock;
import androidx.media3.exoplayer.MetadataRetrieverInternal;
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.exoplayer.source.TrackGroupArray;
import androidx.media3.extractor.DefaultExtractorsFactory;
import com.google.common.base.Preconditions;
import com.google.common.util.concurrent.ListenableFuture;

/* JADX INFO: loaded from: classes.dex */
@Deprecated
public final class MetadataRetriever implements AutoCloseable {
    public static final int DEFAULT_MAXIMUM_PARALLEL_RETRIEVALS = 5;
    private final MetadataRetrieverInternal internalRetriever;

    public static final class Builder {
        private Clock clock;
        private final Context context;
        private final MediaItem mediaItem;
        private MediaSource.Factory mediaSourceFactory;

        public Builder(Context context, MediaItem mediaItem) {
            this.context = context != null ? context.getApplicationContext() : null;
            this.mediaItem = (MediaItem) Preconditions.checkNotNull(mediaItem);
            this.clock = Clock.DEFAULT;
        }

        public Builder setMediaSourceFactory(MediaSource.Factory factory) {
            this.mediaSourceFactory = (MediaSource.Factory) Preconditions.checkNotNull(factory);
            return this;
        }

        public Builder setClock(Clock clock) {
            this.clock = (Clock) Preconditions.checkNotNull(clock);
            return this;
        }

        public MetadataRetriever build() {
            if (this.mediaSourceFactory == null) {
                Preconditions.checkState(this.context != null, "Context must be provided if MediaSource.Factory is not set.");
                this.mediaSourceFactory = new DefaultMediaSourceFactory(this.context, new DefaultExtractorsFactory().setMp4ExtractorFlags(260));
            }
            return new MetadataRetriever(new MetadataRetrieverInternal(this.mediaItem, (MediaSource.Factory) Preconditions.checkNotNull(this.mediaSourceFactory), this.clock));
        }
    }

    private MetadataRetriever(MetadataRetrieverInternal metadataRetrieverInternal) {
        this.internalRetriever = metadataRetrieverInternal;
    }

    public ListenableFuture<TrackGroupArray> retrieveTrackGroups() {
        return this.internalRetriever.retrieveTrackGroups();
    }

    public ListenableFuture<Timeline> retrieveTimeline() {
        return this.internalRetriever.retrieveTimeline();
    }

    public ListenableFuture<Long> retrieveDurationUs() {
        return this.internalRetriever.retrieveDurationUs();
    }

    @Deprecated
    public static ListenableFuture<TrackGroupArray> retrieveMetadata(Context context, MediaItem mediaItem) {
        return retrieveMetadata(context, mediaItem, Clock.DEFAULT);
    }

    @Deprecated
    public static ListenableFuture<TrackGroupArray> retrieveMetadata(MediaSource.Factory factory, MediaItem mediaItem) {
        return retrieveMetadata(factory, mediaItem, Clock.DEFAULT);
    }

    static ListenableFuture<TrackGroupArray> retrieveMetadata(Context context, MediaItem mediaItem, Clock clock) {
        MetadataRetriever metadataRetrieverBuild = new Builder(context, mediaItem).setClock(clock).build();
        try {
            ListenableFuture<TrackGroupArray> listenableFutureRetrieveTrackGroups = metadataRetrieverBuild.retrieveTrackGroups();
            if (metadataRetrieverBuild != null) {
                metadataRetrieverBuild.close();
            }
            return listenableFutureRetrieveTrackGroups;
        } catch (Throwable th) {
            if (metadataRetrieverBuild != null) {
                try {
                    metadataRetrieverBuild.close();
                } catch (Throwable th2) {
                    th.addSuppressed(th2);
                }
            }
            throw th;
        }
    }

    private static ListenableFuture<TrackGroupArray> retrieveMetadata(MediaSource.Factory factory, MediaItem mediaItem, Clock clock) {
        MetadataRetriever metadataRetrieverBuild = new Builder(null, mediaItem).setMediaSourceFactory(factory).setClock(clock).build();
        try {
            ListenableFuture<TrackGroupArray> listenableFutureRetrieveTrackGroups = metadataRetrieverBuild.retrieveTrackGroups();
            if (metadataRetrieverBuild != null) {
                metadataRetrieverBuild.close();
            }
            return listenableFutureRetrieveTrackGroups;
        } catch (Throwable th) {
            if (metadataRetrieverBuild != null) {
                try {
                    metadataRetrieverBuild.close();
                } catch (Throwable th2) {
                    th.addSuppressed(th2);
                }
            }
            throw th;
        }
    }

    public static void setMaximumParallelRetrievals(int i) {
        Preconditions.checkArgument(i >= 1);
        MetadataRetrieverInternal.SharedWorkerThread.MAX_PARALLEL_RETRIEVALS.set(i);
    }

    @Override // java.lang.AutoCloseable
    public void close() {
        this.internalRetriever.close();
    }
}
