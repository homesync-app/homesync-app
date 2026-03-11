package androidx.media3.exoplayer;

import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import androidx.media3.common.C;
import androidx.media3.common.MediaItem;
import androidx.media3.common.Timeline;
import androidx.media3.common.util.Clock;
import androidx.media3.common.util.HandlerWrapper;
import androidx.media3.exoplayer.LoadingInfo;
import androidx.media3.exoplayer.analytics.PlayerId;
import androidx.media3.exoplayer.source.MediaPeriod;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.exoplayer.source.TrackGroupArray;
import androidx.media3.exoplayer.upstream.Allocator;
import androidx.media3.exoplayer.upstream.DefaultAllocator;
import com.google.common.base.Preconditions;
import com.google.common.util.concurrent.FutureCallback;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.common.util.concurrent.MoreExecutors;
import com.google.common.util.concurrent.SettableFuture;
import java.io.IOException;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Deque;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/* JADX INFO: loaded from: classes.dex */
public final class MetadataRetrieverInternal implements AutoCloseable {
    private final Clock clock;
    private final MediaItem mediaItem;
    private final MediaSource.Factory mediaSourceFactory;
    private SettableFuture<InternalResult> preparationFuture;
    private boolean released;
    private RetrievalTask retrievalTask;
    private final Object lock = new Object();
    private final List<ListenableFuture<?>> allFutures = new ArrayList();

    public MetadataRetrieverInternal(MediaItem mediaItem, MediaSource.Factory factory, Clock clock) {
        this.mediaItem = mediaItem;
        this.mediaSourceFactory = factory;
        this.clock = clock;
    }

    public ListenableFuture<TrackGroupArray> retrieveTrackGroups() {
        synchronized (this.lock) {
            if (this.released) {
                return Futures.immediateFailedFuture(new IllegalStateException("Retriever is released."));
            }
            startPreparation();
            final SettableFuture settableFutureCreate = SettableFuture.create();
            this.allFutures.add(settableFutureCreate);
            Futures.addCallback((ListenableFuture) Preconditions.checkNotNull(this.preparationFuture), new FutureCallback<InternalResult>() { // from class: androidx.media3.exoplayer.MetadataRetrieverInternal.1
                @Override // com.google.common.util.concurrent.FutureCallback
                public void onSuccess(InternalResult internalResult) {
                    settableFutureCreate.set(internalResult.trackGroups);
                }

                @Override // com.google.common.util.concurrent.FutureCallback
                public void onFailure(Throwable th) {
                    settableFutureCreate.setException(th);
                }
            }, MoreExecutors.directExecutor());
            return settableFutureCreate;
        }
    }

    public ListenableFuture<Timeline> retrieveTimeline() {
        synchronized (this.lock) {
            if (this.released) {
                return Futures.immediateFailedFuture(new IllegalStateException("Retriever is released."));
            }
            startPreparation();
            final SettableFuture settableFutureCreate = SettableFuture.create();
            this.allFutures.add(settableFutureCreate);
            Futures.addCallback((ListenableFuture) Preconditions.checkNotNull(this.preparationFuture), new FutureCallback<InternalResult>() { // from class: androidx.media3.exoplayer.MetadataRetrieverInternal.2
                @Override // com.google.common.util.concurrent.FutureCallback
                public void onSuccess(InternalResult internalResult) {
                    settableFutureCreate.set(internalResult.timeline);
                }

                @Override // com.google.common.util.concurrent.FutureCallback
                public void onFailure(Throwable th) {
                    settableFutureCreate.setException(th);
                }
            }, MoreExecutors.directExecutor());
            return settableFutureCreate;
        }
    }

    public ListenableFuture<Long> retrieveDurationUs() {
        synchronized (this.lock) {
            if (this.released) {
                return Futures.immediateFailedFuture(new IllegalStateException("Retriever is released."));
            }
            ListenableFuture<Timeline> listenableFutureRetrieveTimeline = retrieveTimeline();
            final SettableFuture settableFutureCreate = SettableFuture.create();
            this.allFutures.add(settableFutureCreate);
            Futures.addCallback(listenableFutureRetrieveTimeline, new FutureCallback<Timeline>() { // from class: androidx.media3.exoplayer.MetadataRetrieverInternal.3
                @Override // com.google.common.util.concurrent.FutureCallback
                public void onSuccess(Timeline timeline) {
                    if (timeline.isEmpty()) {
                        settableFutureCreate.set(Long.valueOf(C.TIME_UNSET));
                    } else {
                        settableFutureCreate.set(Long.valueOf(timeline.getWindow(0, new Timeline.Window()).getDurationUs()));
                    }
                }

                @Override // com.google.common.util.concurrent.FutureCallback
                public void onFailure(Throwable th) {
                    settableFutureCreate.setException(th);
                }
            }, MoreExecutors.directExecutor());
            return settableFutureCreate;
        }
    }

    @Override // java.lang.AutoCloseable
    public void close() {
        synchronized (this.lock) {
            if (this.released) {
                return;
            }
            this.released = true;
            Futures.whenAllComplete(this.allFutures).run(new Runnable() { // from class: androidx.media3.exoplayer.MetadataRetrieverInternal$$ExternalSyntheticLambda0
                @Override // java.lang.Runnable
                public final void run() {
                    this.f$0.m195xe88b021d();
                }
            }, MoreExecutors.directExecutor());
        }
    }

    /* JADX INFO: renamed from: lambda$close$0$androidx-media3-exoplayer-MetadataRetrieverInternal, reason: not valid java name */
    /* synthetic */ void m195xe88b021d() {
        synchronized (this.lock) {
            RetrievalTask retrievalTask = this.retrievalTask;
            if (retrievalTask != null) {
                retrievalTask.release();
            }
        }
    }

    private void startPreparation() {
        if (this.preparationFuture == null) {
            this.preparationFuture = SettableFuture.create();
            RetrievalTask retrievalTask = new RetrievalTask(this.mediaSourceFactory, this.mediaItem, this.clock, new RetrievalTask.OnPreparedListener() { // from class: androidx.media3.exoplayer.MetadataRetrieverInternal$$ExternalSyntheticLambda1
                @Override // androidx.media3.exoplayer.MetadataRetrieverInternal.RetrievalTask.OnPreparedListener
                public final void onPrepared(TrackGroupArray trackGroupArray, Timeline timeline) {
                    this.f$0.m196x26d3b195(trackGroupArray, timeline);
                }
            }, new RetrievalTask.OnFailureListener() { // from class: androidx.media3.exoplayer.MetadataRetrieverInternal$$ExternalSyntheticLambda2
                @Override // androidx.media3.exoplayer.MetadataRetrieverInternal.RetrievalTask.OnFailureListener
                public final void onFailure(Exception exc) {
                    this.f$0.m197xb40e6316(exc);
                }
            });
            this.retrievalTask = retrievalTask;
            retrievalTask.queueRetrieval();
        }
    }

    /* JADX INFO: renamed from: lambda$startPreparation$1$androidx-media3-exoplayer-MetadataRetrieverInternal, reason: not valid java name */
    /* synthetic */ void m196x26d3b195(TrackGroupArray trackGroupArray, Timeline timeline) {
        synchronized (this.lock) {
            ((SettableFuture) Preconditions.checkNotNull(this.preparationFuture)).set(new InternalResult(trackGroupArray, timeline));
        }
    }

    /* JADX INFO: renamed from: lambda$startPreparation$2$androidx-media3-exoplayer-MetadataRetrieverInternal, reason: not valid java name */
    /* synthetic */ void m197xb40e6316(Exception exc) {
        synchronized (this.lock) {
            ((SettableFuture) Preconditions.checkNotNull(this.preparationFuture)).setException(exc);
        }
    }

    private static final class InternalResult {
        public final Timeline timeline;
        public final TrackGroupArray trackGroups;

        public InternalResult(TrackGroupArray trackGroupArray, Timeline timeline) {
            this.trackGroups = trackGroupArray;
            this.timeline = timeline;
        }
    }

    public static final class RetrievalTask {
        private static final int MESSAGE_CHECK_FOR_FAILURE = 2;
        private static final int MESSAGE_CONTINUE_LOADING = 3;
        private static final int MESSAGE_PREPARE_SOURCE = 1;
        private static final int MESSAGE_RELEASE = 4;
        private static final SharedWorkerThread SHARED_WORKER_THREAD = new SharedWorkerThread();
        private final MediaItem mediaItem;
        private final MediaSource.Factory mediaSourceFactory;
        private final HandlerWrapper mediaSourceHandler;
        private final OnFailureListener onFailureListener;
        private final OnPreparedListener onPreparedListener;
        private boolean sentReleaseMessage;

        public interface OnFailureListener {
            void onFailure(Exception exc);
        }

        public interface OnPreparedListener {
            void onPrepared(TrackGroupArray trackGroupArray, Timeline timeline);
        }

        public RetrievalTask(MediaSource.Factory factory, MediaItem mediaItem, Clock clock, OnPreparedListener onPreparedListener, OnFailureListener onFailureListener) {
            this.mediaSourceFactory = factory;
            this.mediaItem = mediaItem;
            this.onPreparedListener = onPreparedListener;
            this.onFailureListener = onFailureListener;
            this.mediaSourceHandler = clock.createHandler(SHARED_WORKER_THREAD.addWorker(), new MediaSourceHandlerCallback());
        }

        public void queueRetrieval() {
            SHARED_WORKER_THREAD.startRetrieval(this);
        }

        public void start() {
            this.mediaSourceHandler.obtainMessage(1, this.mediaItem).sendToTarget();
        }

        public synchronized void release() {
            if (!this.sentReleaseMessage) {
                this.sentReleaseMessage = true;
                this.mediaSourceHandler.obtainMessage(4).sendToTarget();
            }
        }

        private final class MediaSourceHandlerCallback implements Handler.Callback {
            private static final int ERROR_POLL_INTERVAL_MS = 100;
            private MediaPeriod mediaPeriod;
            private MediaSource mediaSource;
            private final MediaSourceCaller mediaSourceCaller = new MediaSourceCaller();
            private boolean released;
            private Timeline timeline;

            public MediaSourceHandlerCallback() {
            }

            @Override // android.os.Handler.Callback
            public boolean handleMessage(Message message) {
                if (this.released) {
                    return true;
                }
                int i = message.what;
                if (i == 1) {
                    MediaSource mediaSourceCreateMediaSource = RetrievalTask.this.mediaSourceFactory.createMediaSource((MediaItem) message.obj);
                    this.mediaSource = mediaSourceCreateMediaSource;
                    mediaSourceCreateMediaSource.prepareSource(this.mediaSourceCaller, null, PlayerId.UNSET);
                    RetrievalTask.this.mediaSourceHandler.sendEmptyMessage(2);
                    return true;
                }
                if (i == 2) {
                    try {
                        MediaPeriod mediaPeriod = this.mediaPeriod;
                        if (mediaPeriod == null) {
                            ((MediaSource) Preconditions.checkNotNull(this.mediaSource)).maybeThrowSourceInfoRefreshError();
                        } else {
                            mediaPeriod.maybeThrowPrepareError();
                        }
                        RetrievalTask.this.mediaSourceHandler.sendEmptyMessageDelayed(2, 100);
                    } catch (IOException e) {
                        RetrievalTask.this.onFailureListener.onFailure(e);
                        RetrievalTask.this.release();
                    }
                    return true;
                }
                if (i == 3) {
                    ((MediaPeriod) Preconditions.checkNotNull(this.mediaPeriod)).continueLoading(new LoadingInfo.Builder().setPlaybackPositionUs(0L).build());
                    return true;
                }
                if (i != 4) {
                    return false;
                }
                if (this.mediaPeriod != null) {
                    ((MediaSource) Preconditions.checkNotNull(this.mediaSource)).releasePeriod(this.mediaPeriod);
                }
                MediaSource mediaSource = this.mediaSource;
                if (mediaSource != null) {
                    mediaSource.releaseSource(this.mediaSourceCaller);
                }
                RetrievalTask.this.mediaSourceHandler.removeCallbacksAndMessages(null);
                RetrievalTask.SHARED_WORKER_THREAD.removeWorker();
                this.released = true;
                return true;
            }

            private final class MediaSourceCaller implements MediaSource.MediaSourceCaller {
                private boolean mediaPeriodCreated;
                private final MediaPeriodCallback mediaPeriodCallback = new MediaPeriodCallback();
                private final Allocator allocator = new DefaultAllocator(true, 65536);

                public MediaSourceCaller() {
                }

                @Override // androidx.media3.exoplayer.source.MediaSource.MediaSourceCaller
                public void onSourceInfoRefreshed(MediaSource mediaSource, Timeline timeline) {
                    MediaSourceHandlerCallback.this.timeline = timeline;
                    if (this.mediaPeriodCreated) {
                        return;
                    }
                    this.mediaPeriodCreated = true;
                    MediaSourceHandlerCallback.this.mediaPeriod = mediaSource.createPeriod(new MediaSource.MediaPeriodId(timeline.getUidOfPeriod(0)), this.allocator, 0L);
                    MediaSourceHandlerCallback.this.mediaPeriod.prepare(this.mediaPeriodCallback, 0L);
                }

                private final class MediaPeriodCallback implements MediaPeriod.Callback {
                    private MediaPeriodCallback() {
                    }

                    @Override // androidx.media3.exoplayer.source.MediaPeriod.Callback
                    public void onPrepared(MediaPeriod mediaPeriod) {
                        RetrievalTask.this.onPreparedListener.onPrepared(mediaPeriod.getTrackGroups(), (Timeline) Preconditions.checkNotNull(MediaSourceHandlerCallback.this.timeline));
                        RetrievalTask.this.release();
                    }

                    @Override // androidx.media3.exoplayer.source.SequenceableLoader.Callback
                    public void onContinueLoadingRequested(MediaPeriod mediaPeriod) {
                        RetrievalTask.this.mediaSourceHandler.obtainMessage(3).sendToTarget();
                    }
                }
            }
        }
    }

    public static final class SharedWorkerThread {
        public static final AtomicInteger MAX_PARALLEL_RETRIEVALS = new AtomicInteger(5);
        private HandlerThread mediaSourceThread;
        private final Deque<RetrievalTask> pendingRetrievals;
        private int referenceCount;

        private SharedWorkerThread() {
            this.pendingRetrievals = new ArrayDeque();
        }

        public synchronized Looper addWorker() {
            if (this.mediaSourceThread == null) {
                Preconditions.checkState(this.referenceCount == 0);
                HandlerThread handlerThread = new HandlerThread("ExoPlayer:MetadataRetriever");
                this.mediaSourceThread = handlerThread;
                handlerThread.start();
            }
            this.referenceCount++;
            return ((HandlerThread) Preconditions.checkNotNull(this.mediaSourceThread)).getLooper();
        }

        public synchronized void startRetrieval(RetrievalTask retrievalTask) {
            this.pendingRetrievals.addLast(retrievalTask);
            maybeStartNewRetrieval();
        }

        public synchronized void removeWorker() {
            int i = this.referenceCount - 1;
            this.referenceCount = i;
            if (i == 0) {
                ((HandlerThread) Preconditions.checkNotNull(this.mediaSourceThread)).quit();
                this.mediaSourceThread = null;
                this.pendingRetrievals.clear();
            } else {
                maybeStartNewRetrieval();
            }
        }

        private void maybeStartNewRetrieval() {
            if (!this.pendingRetrievals.isEmpty() && this.referenceCount - this.pendingRetrievals.size() < MAX_PARALLEL_RETRIEVALS.get()) {
                this.pendingRetrievals.removeFirst().start();
            }
        }
    }
}
