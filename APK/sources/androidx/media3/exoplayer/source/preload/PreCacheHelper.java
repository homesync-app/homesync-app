package androidx.media3.exoplayer.source.preload;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import androidx.credentials.CredentialManager$$ExternalSyntheticLambda0;
import androidx.media3.common.MediaItem;
import androidx.media3.common.TrackSelectionParameters;
import androidx.media3.common.util.Consumer;
import androidx.media3.common.util.Util;
import androidx.media3.datasource.DataSource;
import androidx.media3.datasource.DefaultDataSource;
import androidx.media3.datasource.cache.Cache;
import androidx.media3.datasource.cache.CacheDataSource;
import androidx.media3.exoplayer.DefaultRenderersFactory;
import androidx.media3.exoplayer.RenderersFactory;
import androidx.media3.exoplayer.offline.DefaultDownloaderFactory;
import androidx.media3.exoplayer.offline.DownloadHelper;
import androidx.media3.exoplayer.offline.DownloadRequest;
import androidx.media3.exoplayer.offline.Downloader;
import androidx.media3.exoplayer.offline.DownloaderFactory;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.exoplayer.source.preload.PreCacheHelper;
import androidx.media3.exoplayer.util.ReleasableExecutor;
import com.google.common.base.Preconditions;
import com.google.common.base.Supplier;
import java.io.IOException;
import java.util.concurrent.CancellationException;
import java.util.concurrent.Executor;
import java.util.concurrent.ExecutorService;

/* JADX INFO: loaded from: classes.dex */
public final class PreCacheHelper {
    static final int DEFAULT_MIN_RETRY_COUNT = 5;
    private final Handler applicationHandler = Util.createHandlerForCurrentOrMainLooper();
    private DownloadCallback currentDownloadCallback;
    private final DownloadHelper.Factory downloadHelperFactory;
    private final DownloaderFactory downloaderFactory;
    private final Listener listener;
    private final MediaItem mediaItem;
    private final Handler preCacheHandler;
    private final MediaSource.Factory testMediaSourceFactory;

    public interface Listener {
        default void onDownloadError(MediaItem mediaItem, IOException iOException) {
        }

        default void onPreCacheProgress(MediaItem mediaItem, long j, long j2, float f) {
        }

        default void onPrepareError(MediaItem mediaItem, IOException iOException) {
        }

        default void onPrepared(MediaItem mediaItem, MediaItem mediaItem2) {
        }
    }

    public static final class Factory {
        private final Cache cache;
        private Listener listener;
        private final Looper preCacheLooper;
        private final RenderersFactory renderersFactory;
        private final DataSource.Factory upstreamDataSourceFactory;
        private TrackSelectionParameters trackSelectionParameters = TrackSelectionParameters.DEFAULT;
        private Executor downloadExecutor = new CredentialManager$$ExternalSyntheticLambda0();

        public Factory(Context context, Cache cache, Looper looper) {
            this.cache = cache;
            this.preCacheLooper = looper;
            this.upstreamDataSourceFactory = new DefaultDataSource.Factory(context);
            this.renderersFactory = new DefaultRenderersFactory(context);
        }

        public Factory(Context context, Cache cache, RenderersFactory renderersFactory, Looper looper) {
            this.cache = cache;
            this.preCacheLooper = looper;
            this.upstreamDataSourceFactory = new DefaultDataSource.Factory(context);
            this.renderersFactory = renderersFactory;
        }

        public Factory(Context context, Cache cache, DataSource.Factory factory, Looper looper) {
            this.cache = cache;
            this.preCacheLooper = looper;
            this.upstreamDataSourceFactory = factory;
            this.renderersFactory = new DefaultRenderersFactory(context);
        }

        public Factory(Cache cache, DataSource.Factory factory, RenderersFactory renderersFactory, Looper looper) {
            this.cache = cache;
            this.preCacheLooper = looper;
            this.upstreamDataSourceFactory = factory;
            this.renderersFactory = renderersFactory;
        }

        public Factory setTrackSelectionParameters(TrackSelectionParameters trackSelectionParameters) {
            this.trackSelectionParameters = trackSelectionParameters;
            return this;
        }

        public Factory setDownloadExecutor(Executor executor) {
            this.downloadExecutor = executor;
            return this;
        }

        public Factory setListener(Listener listener) {
            this.listener = listener;
            return this;
        }

        public PreCacheHelper create(MediaItem mediaItem) {
            CacheDataSource.Factory cache = new CacheDataSource.Factory().setUpstreamDataSourceFactory(this.upstreamDataSourceFactory).setCache(this.cache);
            return new PreCacheHelper(mediaItem, null, new DownloadHelper.Factory().setDataSourceFactory(cache).setRenderersFactory(this.renderersFactory).setTrackSelectionParameters(this.trackSelectionParameters), new DefaultDownloaderFactory(cache, this.downloadExecutor), this.preCacheLooper, this.listener);
        }
    }

    PreCacheHelper(MediaItem mediaItem, MediaSource.Factory factory, DownloadHelper.Factory factory2, DownloaderFactory downloaderFactory, Looper looper, Listener listener) {
        this.mediaItem = mediaItem;
        this.testMediaSourceFactory = factory;
        this.downloadHelperFactory = factory2;
        this.downloaderFactory = downloaderFactory;
        this.listener = listener;
        this.preCacheHandler = Util.createHandler(looper, null);
    }

    public void preCache(final long j, final long j2) {
        this.preCacheHandler.post(new Runnable() { // from class: androidx.media3.exoplayer.source.preload.PreCacheHelper$$ExternalSyntheticLambda1
            @Override // java.lang.Runnable
            public final void run() throws Throwable {
                this.f$0.m304xada346dd(j, j2);
            }
        });
    }

    /* JADX INFO: renamed from: lambda$preCache$0$androidx-media3-exoplayer-source-preload-PreCacheHelper, reason: not valid java name */
    /* synthetic */ void m304xada346dd(long j, long j2) throws Throwable {
        DownloadCallback downloadCallback = this.currentDownloadCallback;
        if (downloadCallback == null || !downloadCallback.isReusable(j, j2)) {
            DownloadCallback downloadCallback2 = this.currentDownloadCallback;
            if (downloadCallback2 != null) {
                downloadCallback2.cancel(false);
            }
            this.currentDownloadCallback = new DownloadCallback(j, j2);
        }
    }

    public void stop() {
        this.preCacheHandler.post(new Runnable() { // from class: androidx.media3.exoplayer.source.preload.PreCacheHelper$$ExternalSyntheticLambda0
            @Override // java.lang.Runnable
            public final void run() throws Throwable {
                this.f$0.m306x5a429201();
            }
        });
    }

    /* JADX INFO: renamed from: lambda$stop$1$androidx-media3-exoplayer-source-preload-PreCacheHelper, reason: not valid java name */
    /* synthetic */ void m306x5a429201() throws Throwable {
        DownloadCallback downloadCallback = this.currentDownloadCallback;
        if (downloadCallback != null) {
            downloadCallback.cancel(false);
        }
    }

    public void release(final boolean z) {
        this.preCacheHandler.post(new Runnable() { // from class: androidx.media3.exoplayer.source.preload.PreCacheHelper$$ExternalSyntheticLambda2
            @Override // java.lang.Runnable
            public final void run() throws Throwable {
                this.f$0.m305x4e6cbcad(z);
            }
        });
    }

    /* JADX INFO: renamed from: lambda$release$2$androidx-media3-exoplayer-source-preload-PreCacheHelper, reason: not valid java name */
    /* synthetic */ void m305x4e6cbcad(boolean z) throws Throwable {
        DownloadCallback downloadCallback = this.currentDownloadCallback;
        if (downloadCallback != null) {
            downloadCallback.cancel(z);
            this.currentDownloadCallback = null;
        }
        this.preCacheHandler.removeCallbacksAndMessages(null);
    }

    private static final class ReleasableSingleThreadExecutor implements ReleasableExecutor {
        private final ExecutorService executor;
        private final Runnable releaseRunnable;

        private ReleasableSingleThreadExecutor(Runnable runnable) {
            this.executor = Util.newSingleThreadExecutor("PreCacheHelper:Loader");
            this.releaseRunnable = runnable;
        }

        @Override // androidx.media3.exoplayer.util.ReleasableExecutor
        public void release() {
            execute(this.releaseRunnable);
            this.executor.shutdown();
        }

        @Override // java.util.concurrent.Executor
        public void execute(Runnable runnable) {
            this.executor.execute(runnable);
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    static final class ReleasableExecutorSupplier implements Supplier<ReleasableExecutor> {
        private DownloadCallback downloadCallback;
        private int executorCount;
        private final Handler preCacheHandler;

        private ReleasableExecutorSupplier(Handler handler) {
            this.preCacheHandler = handler;
        }

        public void setDownloadCallback(DownloadCallback downloadCallback) {
            this.downloadCallback = downloadCallback;
        }

        @Override // com.google.common.base.Supplier
        public ReleasableExecutor get() {
            synchronized (this) {
                this.executorCount++;
            }
            return new ReleasableSingleThreadExecutor(new Runnable() { // from class: androidx.media3.exoplayer.source.preload.PreCacheHelper$ReleasableExecutorSupplier$$ExternalSyntheticLambda1
                @Override // java.lang.Runnable
                public final void run() {
                    this.f$0.onExecutorReleased();
                }
            });
        }

        /* JADX INFO: Access modifiers changed from: private */
        public void onExecutorReleased() {
            synchronized (this) {
                Preconditions.checkState(this.executorCount > 0);
                this.executorCount--;
                if (wereExecutorsReleased()) {
                    this.preCacheHandler.post(new Runnable() { // from class: androidx.media3.exoplayer.source.preload.PreCacheHelper$ReleasableExecutorSupplier$$ExternalSyntheticLambda0
                        @Override // java.lang.Runnable
                        public final void run() {
                            this.f$0.m315x3edeb64e();
                        }
                    });
                }
            }
        }

        /* JADX INFO: renamed from: lambda$onExecutorReleased$0$androidx-media3-exoplayer-source-preload-PreCacheHelper$ReleasableExecutorSupplier, reason: not valid java name */
        /* synthetic */ void m315x3edeb64e() {
            Preconditions.checkState(wereExecutorsReleased());
            DownloadCallback downloadCallback = this.downloadCallback;
            if (downloadCallback != null) {
                downloadCallback.maybeSubmitPendingDownloadRequest();
            }
        }

        public boolean wereExecutorsReleased() {
            boolean z;
            synchronized (this) {
                z = this.executorCount == 0;
            }
            return z;
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    final class DownloadCallback implements DownloadHelper.Callback {
        private final DownloadHelper downloadHelper;
        private Downloader downloader;
        private Task downloaderTask;
        private final long durationMs;
        private boolean isCanceled;
        private boolean isPreparationOngoing;
        private final Object lock;
        private DownloadRequest pendingDownloadRequest;
        private final ReleasableExecutorSupplier releasableExecutorSupplier;
        private final long startPositionMs;

        public DownloadCallback(long j, long j2) {
            Preconditions.checkState(Looper.myLooper() == PreCacheHelper.this.preCacheHandler.getLooper());
            this.lock = new Object();
            this.startPositionMs = j;
            this.durationMs = j2;
            if (PreCacheHelper.this.testMediaSourceFactory != null) {
                this.releasableExecutorSupplier = null;
                this.downloadHelper = PreCacheHelper.this.downloadHelperFactory.create(PreCacheHelper.this.testMediaSourceFactory.createMediaSource(PreCacheHelper.this.mediaItem));
            } else {
                ReleasableExecutorSupplier releasableExecutorSupplier = new ReleasableExecutorSupplier(PreCacheHelper.this.preCacheHandler);
                this.releasableExecutorSupplier = releasableExecutorSupplier;
                PreCacheHelper.this.downloadHelperFactory.setLoadExecutor(releasableExecutorSupplier);
                this.downloadHelper = PreCacheHelper.this.downloadHelperFactory.create(PreCacheHelper.this.mediaItem);
                releasableExecutorSupplier.setDownloadCallback(this);
            }
            this.isPreparationOngoing = true;
            this.downloadHelper.prepare(this);
        }

        @Override // androidx.media3.exoplayer.offline.DownloadHelper.Callback
        public void onPrepared(DownloadHelper downloadHelper, boolean z) {
            Preconditions.checkState(Looper.myLooper() == PreCacheHelper.this.preCacheHandler.getLooper());
            Preconditions.checkState(downloadHelper == this.downloadHelper);
            this.isPreparationOngoing = false;
            DownloadRequest downloadRequest = downloadHelper.getDownloadRequest(null, this.startPositionMs, this.durationMs);
            this.downloadHelper.release();
            final MediaItem mediaItem = downloadRequest.toMediaItem(PreCacheHelper.this.mediaItem.buildUpon());
            notifyListeners(new Consumer() { // from class: androidx.media3.exoplayer.source.preload.PreCacheHelper$DownloadCallback$$ExternalSyntheticLambda1
                @Override // androidx.media3.common.util.Consumer
                public final void accept(Object obj) {
                    this.f$0.m313x2cdaea77(mediaItem, (PreCacheHelper.Listener) obj);
                }
            });
            this.pendingDownloadRequest = downloadRequest;
            ReleasableExecutorSupplier releasableExecutorSupplier = this.releasableExecutorSupplier;
            if (releasableExecutorSupplier == null || releasableExecutorSupplier.wereExecutorsReleased()) {
                maybeSubmitPendingDownloadRequest();
            }
        }

        /* JADX INFO: renamed from: lambda$onPrepared$0$androidx-media3-exoplayer-source-preload-PreCacheHelper$DownloadCallback, reason: not valid java name */
        /* synthetic */ void m313x2cdaea77(MediaItem mediaItem, Listener listener) {
            listener.onPrepared(PreCacheHelper.this.mediaItem, mediaItem);
        }

        @Override // androidx.media3.exoplayer.offline.DownloadHelper.Callback
        public void onPrepareError(DownloadHelper downloadHelper, final IOException iOException) {
            Preconditions.checkState(Looper.myLooper() == PreCacheHelper.this.preCacheHandler.getLooper());
            Preconditions.checkState(downloadHelper == this.downloadHelper);
            this.isPreparationOngoing = false;
            this.downloadHelper.release();
            notifyListeners(new Consumer() { // from class: androidx.media3.exoplayer.source.preload.PreCacheHelper$DownloadCallback$$ExternalSyntheticLambda4
                @Override // androidx.media3.common.util.Consumer
                public final void accept(Object obj) {
                    this.f$0.m312x987b4a12(iOException, (PreCacheHelper.Listener) obj);
                }
            });
        }

        /* JADX INFO: renamed from: lambda$onPrepareError$1$androidx-media3-exoplayer-source-preload-PreCacheHelper$DownloadCallback, reason: not valid java name */
        /* synthetic */ void m312x987b4a12(IOException iOException, Listener listener) {
            listener.onPrepareError(PreCacheHelper.this.mediaItem, iOException);
        }

        public void maybeSubmitPendingDownloadRequest() {
            Preconditions.checkState(Looper.myLooper() == PreCacheHelper.this.preCacheHandler.getLooper());
            if (this.pendingDownloadRequest != null) {
                this.downloader = PreCacheHelper.this.downloaderFactory.createDownloader(this.pendingDownloadRequest);
                Task task = new Task(this.downloader, false, 5, this);
                this.downloaderTask = task;
                task.start();
                this.pendingDownloadRequest = null;
            }
        }

        public void onDownloadStopped(final Task task) {
            PreCacheHelper.this.preCacheHandler.post(new Runnable() { // from class: androidx.media3.exoplayer.source.preload.PreCacheHelper$DownloadCallback$$ExternalSyntheticLambda6
                @Override // java.lang.Runnable
                public final void run() {
                    this.f$0.m311xa2e2ff64(task);
                }
            });
        }

        /* JADX INFO: renamed from: lambda$onDownloadStopped$3$androidx-media3-exoplayer-source-preload-PreCacheHelper$DownloadCallback, reason: not valid java name */
        /* synthetic */ void m311xa2e2ff64(Task task) {
            if (task != this.downloaderTask) {
                return;
            }
            this.downloaderTask = null;
            final IOException iOException = task.finalException;
            if (task.isRemove || iOException == null) {
                return;
            }
            notifyListeners(new Consumer() { // from class: androidx.media3.exoplayer.source.preload.PreCacheHelper$DownloadCallback$$ExternalSyntheticLambda0
                @Override // androidx.media3.common.util.Consumer
                public final void accept(Object obj) {
                    this.f$0.m310x88720645(iOException, (PreCacheHelper.Listener) obj);
                }
            });
        }

        /* JADX INFO: renamed from: lambda$onDownloadStopped$2$androidx-media3-exoplayer-source-preload-PreCacheHelper$DownloadCallback, reason: not valid java name */
        /* synthetic */ void m310x88720645(IOException iOException, Listener listener) {
            listener.onDownloadError(PreCacheHelper.this.mediaItem, iOException);
        }

        public void onDownloadProgress(final Task task) {
            PreCacheHelper.this.preCacheHandler.post(new Runnable() { // from class: androidx.media3.exoplayer.source.preload.PreCacheHelper$DownloadCallback$$ExternalSyntheticLambda3
                @Override // java.lang.Runnable
                public final void run() {
                    this.f$0.m309x5419627a(task);
                }
            });
        }

        /* JADX INFO: renamed from: lambda$onDownloadProgress$5$androidx-media3-exoplayer-source-preload-PreCacheHelper$DownloadCallback, reason: not valid java name */
        /* synthetic */ void m309x5419627a(final Task task) {
            if (task != this.downloaderTask) {
                return;
            }
            notifyListeners(new Consumer() { // from class: androidx.media3.exoplayer.source.preload.PreCacheHelper$DownloadCallback$$ExternalSyntheticLambda5
                @Override // androidx.media3.common.util.Consumer
                public final void accept(Object obj) {
                    this.f$0.m308x39a8695b(task, (PreCacheHelper.Listener) obj);
                }
            });
        }

        /* JADX INFO: renamed from: lambda$onDownloadProgress$4$androidx-media3-exoplayer-source-preload-PreCacheHelper$DownloadCallback, reason: not valid java name */
        /* synthetic */ void m308x39a8695b(Task task, Listener listener) {
            listener.onPreCacheProgress(PreCacheHelper.this.mediaItem, task.contentLength, task.bytesDownloaded, task.percentDownloaded);
        }

        public void cancel(boolean z) throws Throwable {
            Preconditions.checkState(Looper.myLooper() == PreCacheHelper.this.preCacheHandler.getLooper());
            synchronized (this.lock) {
                try {
                    this.isCanceled = true;
                } catch (Throwable th) {
                    th = th;
                    while (true) {
                        try {
                            throw th;
                        } catch (Throwable th2) {
                            th = th2;
                        }
                    }
                }
            }
            this.pendingDownloadRequest = null;
            this.downloadHelper.release();
            Task task = this.downloaderTask;
            if (task == null || !task.isRemove) {
                Task task2 = this.downloaderTask;
                if (task2 != null) {
                    task2.cancel();
                }
                if (z && this.downloader != null) {
                    Task task3 = new Task(this.downloader, true, 5, this);
                    this.downloaderTask = task3;
                    task3.start();
                }
            }
        }

        public boolean isReusable(long j, long j2) {
            Task task;
            boolean z = true;
            Preconditions.checkState(Looper.myLooper() == PreCacheHelper.this.preCacheHandler.getLooper());
            synchronized (this.lock) {
                if (this.isCanceled || j != this.startPositionMs || j2 != this.durationMs || (!this.isPreparationOngoing && ((task = this.downloaderTask) == null || task.isRemove))) {
                    z = false;
                }
            }
            return z;
        }

        private void notifyListeners(final Consumer<Listener> consumer) {
            PreCacheHelper.this.applicationHandler.post(new Runnable() { // from class: androidx.media3.exoplayer.source.preload.PreCacheHelper$DownloadCallback$$ExternalSyntheticLambda2
                @Override // java.lang.Runnable
                public final void run() {
                    this.f$0.m307x97097351(consumer);
                }
            });
        }

        /* JADX INFO: renamed from: lambda$notifyListeners$6$androidx-media3-exoplayer-source-preload-PreCacheHelper$DownloadCallback, reason: not valid java name */
        /* synthetic */ void m307x97097351(Consumer consumer) {
            synchronized (this.lock) {
                if (this.isCanceled) {
                    return;
                }
                if (PreCacheHelper.this.listener != null) {
                    consumer.accept(PreCacheHelper.this.listener);
                }
            }
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    static class Task extends Thread implements Downloader.ProgressListener {
        private volatile long bytesDownloaded;
        private volatile long contentLength;
        private DownloadCallback downloadCallback;
        private final Downloader downloader;
        private volatile IOException finalException;
        private volatile boolean isCanceled;
        private final boolean isRemove;
        private final int minRetryCount;
        private volatile float percentDownloaded;

        private Task(Downloader downloader, boolean z, int i, DownloadCallback downloadCallback) {
            this.downloader = downloader;
            this.isRemove = z;
            this.minRetryCount = i;
            this.downloadCallback = downloadCallback;
            this.contentLength = -1L;
        }

        public void cancel() {
            this.downloadCallback = null;
            if (this.isCanceled) {
                return;
            }
            this.isCanceled = true;
            this.downloader.cancel();
            interrupt();
        }

        @Override // java.lang.Thread, java.lang.Runnable
        public void run() {
            try {
                try {
                    if (this.isRemove) {
                        this.downloader.remove();
                    } else {
                        long j = -1;
                        int i = 0;
                        while (!this.isCanceled) {
                            try {
                                this.downloader.download(this);
                                break;
                            } catch (IOException e) {
                                if (!this.isCanceled) {
                                    if (this.bytesDownloaded != j) {
                                        j = this.bytesDownloaded;
                                        i = 0;
                                    }
                                    i++;
                                    if (i > this.minRetryCount) {
                                        throw e;
                                    }
                                    Thread.sleep(getRetryDelayMillis(i));
                                }
                            }
                        }
                    }
                } catch (InterruptedException unused) {
                    Thread.currentThread().interrupt();
                } catch (CancellationException unused2) {
                }
            } catch (IOException e2) {
                this.finalException = e2;
            }
            DownloadCallback downloadCallback = this.downloadCallback;
            if (downloadCallback != null) {
                downloadCallback.onDownloadStopped(this);
            }
        }

        @Override // androidx.media3.exoplayer.offline.Downloader.ProgressListener
        public void onProgress(long j, long j2, float f) {
            this.contentLength = j;
            this.bytesDownloaded = j2;
            this.percentDownloaded = f;
            DownloadCallback downloadCallback = this.downloadCallback;
            if (downloadCallback != null) {
                downloadCallback.onDownloadProgress(this);
            }
        }

        private static int getRetryDelayMillis(int i) {
            return Math.min((i - 1) * 1000, 5000);
        }
    }
}
