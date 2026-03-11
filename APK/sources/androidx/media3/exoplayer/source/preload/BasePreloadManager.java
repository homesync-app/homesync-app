package androidx.media3.exoplayer.source.preload;

import android.os.Handler;
import android.os.Looper;
import androidx.media3.common.MediaItem;
import androidx.media3.common.util.ListenerSet;
import androidx.media3.common.util.Util;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.exoplayer.source.preload.RankingDataComparator;
import com.google.common.base.Preconditions;
import com.google.common.base.Predicate;
import com.google.common.base.Supplier;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public abstract class BasePreloadManager<T, PreloadStatusT> {
    private final Handler applicationHandler;
    private int indexForSourceHolderToClear;
    private int indexForSourceHolderToPreload;
    private final ListenerSet<PreloadManagerListener> listeners;
    private final Object lock = new Object();
    private final MediaSource.Factory mediaSourceFactory;
    private final BasePreloadManager<T, PreloadStatusT>.MediaSourceHolderMap mediaSourceHolderMap;
    protected final RankingDataComparator<T> rankingDataComparator;
    private final List<BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder> sourceHolderPriorityList;
    private final TargetPreloadStatusControl<T, PreloadStatusT> targetPreloadStatusControl;
    private PreloadStatusT targetPreloadStatusOfCurrentPreloadingSource;

    protected abstract BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder createMediaSourceHolder(MediaItem mediaItem, MediaSource mediaSource, T t);

    protected abstract void preloadMediaSourceHolderInternal(BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder mediaSourceHolder, PreloadStatusT preloadstatust);

    protected void releaseInternal() {
    }

    protected boolean shouldStartPreloadingNextSource() {
        return true;
    }

    protected static abstract class BuilderBase<T, PreloadStatusT> {
        protected Supplier<MediaSource.Factory> mediaSourceFactorySupplier;
        protected RankingDataComparator<T> rankingDataComparator;
        protected final TargetPreloadStatusControl<T, PreloadStatusT> targetPreloadStatusControl;

        public abstract BasePreloadManager<T, PreloadStatusT> build();

        public BuilderBase(RankingDataComparator<T> rankingDataComparator, TargetPreloadStatusControl<T, PreloadStatusT> targetPreloadStatusControl, Supplier<MediaSource.Factory> supplier) {
            this.rankingDataComparator = rankingDataComparator;
            this.targetPreloadStatusControl = targetPreloadStatusControl;
            this.mediaSourceFactorySupplier = supplier;
        }
    }

    protected BasePreloadManager(RankingDataComparator<T> rankingDataComparator, TargetPreloadStatusControl<T, PreloadStatusT> targetPreloadStatusControl, MediaSource.Factory factory) {
        Handler handlerCreateHandlerForCurrentOrMainLooper = Util.createHandlerForCurrentOrMainLooper();
        this.applicationHandler = handlerCreateHandlerForCurrentOrMainLooper;
        this.rankingDataComparator = rankingDataComparator;
        this.targetPreloadStatusControl = targetPreloadStatusControl;
        this.mediaSourceFactory = factory;
        this.listeners = new ListenerSet<>(handlerCreateHandlerForCurrentOrMainLooper.getLooper());
        this.mediaSourceHolderMap = new MediaSourceHolderMap();
        rankingDataComparator.setInvalidationListener(new RankingDataComparator.InvalidationListener() { // from class: androidx.media3.exoplayer.source.preload.BasePreloadManager$$ExternalSyntheticLambda2
            @Override // androidx.media3.exoplayer.source.preload.RankingDataComparator.InvalidationListener
            public final void onRankingDataComparatorInvalidated() {
                this.f$0.invalidate();
            }
        });
        this.sourceHolderPriorityList = new ArrayList();
    }

    public void addListener(PreloadManagerListener preloadManagerListener) {
        this.listeners.add(preloadManagerListener);
    }

    public void removeListener(PreloadManagerListener preloadManagerListener) {
        verifyApplicationThread();
        this.listeners.remove(preloadManagerListener);
    }

    public void clearListeners() {
        verifyApplicationThread();
        this.listeners.clear();
    }

    public final int getSourceCount() {
        return this.mediaSourceHolderMap.size();
    }

    public final void addMediaItems(List<MediaItem> list, List<T> list2) {
        Preconditions.checkArgument(list.size() == list2.size());
        for (int i = 0; i < list.size(); i++) {
            add(list.get(i), list2.get(i));
        }
        invalidate();
    }

    public final void add(MediaItem mediaItem, T t) {
        add(this.mediaSourceFactory.createMediaSource(mediaItem), t);
    }

    public final void addMediaSources(List<MediaSource> list, List<T> list2) {
        Preconditions.checkArgument(list.size() == list2.size());
        for (int i = 0; i < list.size(); i++) {
            add(list.get(i), list2.get(i));
        }
        invalidate();
    }

    public final void add(MediaSource mediaSource, T t) {
        BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder mediaSourceHolderCreateMediaSourceHolder = createMediaSourceHolder(mediaSource.getMediaItem(), mediaSource, t);
        this.mediaSourceHolderMap.put(mediaSourceHolderCreateMediaSourceHolder.mediaItem, mediaSourceHolderCreateMediaSourceHolder.getMediaSource(), mediaSourceHolderCreateMediaSourceHolder);
    }

    public final void invalidate() {
        synchronized (this.lock) {
            resetSourceHolderPriorityList();
            while (this.indexForSourceHolderToPreload < this.sourceHolderPriorityList.size() && !maybeStartPreloadingNextSourceHolder()) {
                this.indexForSourceHolderToPreload++;
            }
        }
    }

    private void resetSourceHolderPriorityList() {
        this.sourceHolderPriorityList.clear();
        this.sourceHolderPriorityList.addAll(this.mediaSourceHolderMap.values());
        Collections.sort(this.sourceHolderPriorityList);
        this.indexForSourceHolderToPreload = 0;
        this.indexForSourceHolderToClear = this.sourceHolderPriorityList.size() - 1;
    }

    public final MediaSource getMediaSource(MediaItem mediaItem) {
        if (this.mediaSourceHolderMap.containsKey(mediaItem)) {
            return ((MediaSourceHolder) Preconditions.checkNotNull(this.mediaSourceHolderMap.get(mediaItem))).getMediaSource();
        }
        return null;
    }

    public final boolean remove(MediaItem mediaItem) {
        BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder mediaSourceHolder = this.mediaSourceHolderMap.get(mediaItem);
        if (mediaSourceHolder == null) {
            return false;
        }
        releaseMediaSourceHolderInternal(mediaSourceHolder);
        this.mediaSourceHolderMap.remove(mediaItem);
        if (!isCurrentlyPreloading(mediaSourceHolder)) {
            return true;
        }
        maybeAdvanceToNextMediaSourceHolder();
        return true;
    }

    public final void removeMediaItems(List<MediaItem> list) {
        BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder currentlyPreloadingMediaSourceHolder;
        for (MediaItem mediaItem : list) {
            BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder mediaSourceHolder = this.mediaSourceHolderMap.get(mediaItem);
            if (mediaSourceHolder != null) {
                releaseMediaSourceHolderInternal(mediaSourceHolder);
                this.mediaSourceHolderMap.remove(mediaItem);
            }
        }
        synchronized (this.lock) {
            currentlyPreloadingMediaSourceHolder = getCurrentlyPreloadingMediaSourceHolder();
        }
        if (currentlyPreloadingMediaSourceHolder == null || !currentlyPreloadingMediaSourceHolder.isReleased()) {
            return;
        }
        maybeAdvanceToNextMediaSourceHolder();
    }

    public final boolean remove(MediaSource mediaSource) {
        BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder mediaSourceHolder = this.mediaSourceHolderMap.get(mediaSource);
        if (mediaSourceHolder == null) {
            return false;
        }
        releaseMediaSourceHolderInternal(mediaSourceHolder);
        this.mediaSourceHolderMap.remove(mediaSource);
        if (!isCurrentlyPreloading(mediaSourceHolder)) {
            return true;
        }
        maybeAdvanceToNextMediaSourceHolder();
        return true;
    }

    public final void removeMediaSources(List<MediaSource> list) {
        BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder currentlyPreloadingMediaSourceHolder;
        for (MediaSource mediaSource : list) {
            BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder mediaSourceHolder = this.mediaSourceHolderMap.get(mediaSource);
            if (mediaSourceHolder != null) {
                releaseMediaSourceHolderInternal(mediaSourceHolder);
                this.mediaSourceHolderMap.remove(mediaSource);
            }
        }
        synchronized (this.lock) {
            currentlyPreloadingMediaSourceHolder = getCurrentlyPreloadingMediaSourceHolder();
        }
        if (currentlyPreloadingMediaSourceHolder == null || !currentlyPreloadingMediaSourceHolder.isReleased()) {
            return;
        }
        maybeAdvanceToNextMediaSourceHolder();
    }

    public final void reset() {
        Iterator<BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder> it = this.mediaSourceHolderMap.values().iterator();
        while (it.hasNext()) {
            releaseMediaSourceHolderInternal(it.next());
        }
        this.mediaSourceHolderMap.clear();
        synchronized (this.lock) {
            resetSourceHolderPriorityList();
            this.targetPreloadStatusOfCurrentPreloadingSource = null;
        }
    }

    public final void release() {
        reset();
        releaseInternal();
        clearListeners();
    }

    protected final void onCompleted(final MediaSource mediaSource, final Predicate<PreloadStatusT> predicate) {
        this.applicationHandler.post(new Runnable() { // from class: androidx.media3.exoplayer.source.preload.BasePreloadManager$$ExternalSyntheticLambda1
            @Override // java.lang.Runnable
            public final void run() {
                this.f$0.m297x3eecb679(mediaSource, predicate);
            }
        });
    }

    /* JADX INFO: renamed from: lambda$onCompleted$1$androidx-media3-exoplayer-source-preload-BasePreloadManager, reason: not valid java name */
    /* synthetic */ void m297x3eecb679(MediaSource mediaSource, Predicate predicate) {
        PreloadStatusT targetPreloadStatusIfCurrentlyPreloading = getTargetPreloadStatusIfCurrentlyPreloading(mediaSource);
        if (targetPreloadStatusIfCurrentlyPreloading == null) {
            return;
        }
        final MediaSourceHolder mediaSourceHolder = (MediaSourceHolder) Preconditions.checkNotNull(this.mediaSourceHolderMap.get(mediaSource));
        if (predicate.apply(targetPreloadStatusIfCurrentlyPreloading)) {
            this.listeners.sendEvent(new ListenerSet.Event() { // from class: androidx.media3.exoplayer.source.preload.BasePreloadManager$$ExternalSyntheticLambda7
                @Override // androidx.media3.common.util.ListenerSet.Event
                public final void invoke(Object obj) {
                    ((PreloadManagerListener) obj).onCompleted(mediaSourceHolder.mediaItem);
                }
            });
            maybeAdvanceToNextMediaSourceHolder();
        }
    }

    protected final void onCompleted(final MediaItem mediaItem, final Predicate<PreloadStatusT> predicate) {
        this.applicationHandler.post(new Runnable() { // from class: androidx.media3.exoplayer.source.preload.BasePreloadManager$$ExternalSyntheticLambda10
            @Override // java.lang.Runnable
            public final void run() {
                this.f$0.m298xb3d7f77b(mediaItem, predicate);
            }
        });
    }

    /* JADX INFO: renamed from: lambda$onCompleted$3$androidx-media3-exoplayer-source-preload-BasePreloadManager, reason: not valid java name */
    /* synthetic */ void m298xb3d7f77b(MediaItem mediaItem, Predicate predicate) {
        PreloadStatusT targetPreloadStatusIfCurrentlyPreloading = getTargetPreloadStatusIfCurrentlyPreloading(mediaItem);
        if (targetPreloadStatusIfCurrentlyPreloading == null) {
            return;
        }
        final MediaSourceHolder mediaSourceHolder = (MediaSourceHolder) Preconditions.checkNotNull(this.mediaSourceHolderMap.get(mediaItem));
        if (predicate.apply(targetPreloadStatusIfCurrentlyPreloading)) {
            this.listeners.sendEvent(new ListenerSet.Event() { // from class: androidx.media3.exoplayer.source.preload.BasePreloadManager$$ExternalSyntheticLambda8
                @Override // androidx.media3.common.util.ListenerSet.Event
                public final void invoke(Object obj) {
                    ((PreloadManagerListener) obj).onCompleted(mediaSourceHolder.mediaItem);
                }
            });
            maybeAdvanceToNextMediaSourceHolder();
        }
    }

    protected final void onError(final PreloadException preloadException, final MediaSource mediaSource, final Predicate<PreloadStatusT> predicate) {
        this.applicationHandler.post(new Runnable() { // from class: androidx.media3.exoplayer.source.preload.BasePreloadManager$$ExternalSyntheticLambda9
            @Override // java.lang.Runnable
            public final void run() {
                this.f$0.m299x72a3597a(mediaSource, predicate, preloadException);
            }
        });
    }

    /* JADX INFO: renamed from: lambda$onError$5$androidx-media3-exoplayer-source-preload-BasePreloadManager, reason: not valid java name */
    /* synthetic */ void m299x72a3597a(MediaSource mediaSource, Predicate predicate, final PreloadException preloadException) {
        PreloadStatusT targetPreloadStatusIfCurrentlyPreloading = getTargetPreloadStatusIfCurrentlyPreloading(mediaSource);
        if (targetPreloadStatusIfCurrentlyPreloading != null && predicate.apply(targetPreloadStatusIfCurrentlyPreloading)) {
            this.listeners.sendEvent(new ListenerSet.Event() { // from class: androidx.media3.exoplayer.source.preload.BasePreloadManager$$ExternalSyntheticLambda5
                @Override // androidx.media3.common.util.ListenerSet.Event
                public final void invoke(Object obj) {
                    ((PreloadManagerListener) obj).onError(preloadException);
                }
            });
            maybeAdvanceToNextMediaSourceHolder();
        }
    }

    protected final void onError(final PreloadException preloadException, final MediaItem mediaItem, final Predicate<PreloadStatusT> predicate) {
        this.applicationHandler.post(new Runnable() { // from class: androidx.media3.exoplayer.source.preload.BasePreloadManager$$ExternalSyntheticLambda3
            @Override // java.lang.Runnable
            public final void run() {
                this.f$0.m300xe78e9a7c(mediaItem, predicate, preloadException);
            }
        });
    }

    /* JADX INFO: renamed from: lambda$onError$7$androidx-media3-exoplayer-source-preload-BasePreloadManager, reason: not valid java name */
    /* synthetic */ void m300xe78e9a7c(MediaItem mediaItem, Predicate predicate, final PreloadException preloadException) {
        PreloadStatusT targetPreloadStatusIfCurrentlyPreloading = getTargetPreloadStatusIfCurrentlyPreloading(mediaItem);
        if (targetPreloadStatusIfCurrentlyPreloading != null && predicate.apply(targetPreloadStatusIfCurrentlyPreloading)) {
            this.listeners.sendEvent(new ListenerSet.Event() { // from class: androidx.media3.exoplayer.source.preload.BasePreloadManager$$ExternalSyntheticLambda6
                @Override // androidx.media3.common.util.ListenerSet.Event
                public final void invoke(Object obj) {
                    ((PreloadManagerListener) obj).onError(preloadException);
                }
            });
            maybeAdvanceToNextMediaSourceHolder();
        }
    }

    protected final void onSkipped(final MediaSource mediaSource, final Predicate<PreloadStatusT> predicate) {
        Util.postOrRun(this.applicationHandler, new Runnable() { // from class: androidx.media3.exoplayer.source.preload.BasePreloadManager$$ExternalSyntheticLambda0
            @Override // java.lang.Runnable
            public final void run() {
                this.f$0.m302x83a22925(mediaSource, predicate);
            }
        });
    }

    /* JADX INFO: renamed from: lambda$onSkipped$8$androidx-media3-exoplayer-source-preload-BasePreloadManager, reason: not valid java name */
    /* synthetic */ void m302x83a22925(MediaSource mediaSource, Predicate predicate) {
        PreloadStatusT targetPreloadStatusIfCurrentlyPreloading = getTargetPreloadStatusIfCurrentlyPreloading(mediaSource);
        if (targetPreloadStatusIfCurrentlyPreloading != null && predicate.apply(targetPreloadStatusIfCurrentlyPreloading)) {
            maybeAdvanceToNextMediaSourceHolder();
        }
    }

    protected final void onSourceCleared() {
        synchronized (this.lock) {
            this.indexForSourceHolderToClear--;
        }
    }

    protected final void onMediaSourceUpdated(final MediaItem mediaItem, final MediaSource mediaSource) {
        Util.postOrRun(this.applicationHandler, new Runnable() { // from class: androidx.media3.exoplayer.source.preload.BasePreloadManager$$ExternalSyntheticLambda4
            @Override // java.lang.Runnable
            public final void run() {
                this.f$0.m301xfe00ce8a(mediaItem, mediaSource);
            }
        });
    }

    /* JADX INFO: renamed from: lambda$onMediaSourceUpdated$9$androidx-media3-exoplayer-source-preload-BasePreloadManager, reason: not valid java name */
    /* synthetic */ void m301xfe00ce8a(MediaItem mediaItem, MediaSource mediaSource) {
        if (getTargetPreloadStatusIfCurrentlyPreloading(mediaItem) == null) {
            return;
        }
        BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder mediaSourceHolder = (MediaSourceHolder) Preconditions.checkNotNull(this.mediaSourceHolderMap.get(mediaItem));
        this.mediaSourceHolderMap.remove(mediaItem);
        mediaSourceHolder.setMediaSource(mediaSource);
        this.mediaSourceHolderMap.put(mediaItem, mediaSource, mediaSourceHolder);
    }

    private void maybeAdvanceToNextMediaSourceHolder() {
        synchronized (this.lock) {
            do {
                int i = this.indexForSourceHolderToPreload + 1;
                this.indexForSourceHolderToPreload = i;
                if (i >= this.sourceHolderPriorityList.size()) {
                    break;
                }
            } while (!maybeStartPreloadingNextSourceHolder());
        }
    }

    private BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder getCurrentlyPreloadingMediaSourceHolder() {
        if (this.indexForSourceHolderToPreload >= this.sourceHolderPriorityList.size()) {
            return null;
        }
        return this.sourceHolderPriorityList.get(this.indexForSourceHolderToPreload);
    }

    protected BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder getMediaSourceHolderToClear() {
        synchronized (this.lock) {
            int i = this.indexForSourceHolderToPreload;
            int i2 = this.indexForSourceHolderToClear;
            if (i >= i2) {
                return null;
            }
            return this.sourceHolderPriorityList.get(i2);
        }
    }

    protected final PreloadStatusT getTargetPreloadStatusIfCurrentlyPreloading(MediaSource mediaSource) {
        synchronized (this.lock) {
            BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder currentlyPreloadingMediaSourceHolder = getCurrentlyPreloadingMediaSourceHolder();
            if (currentlyPreloadingMediaSourceHolder != null && mediaSource == currentlyPreloadingMediaSourceHolder.getMediaSource()) {
                return this.targetPreloadStatusOfCurrentPreloadingSource;
            }
            return null;
        }
    }

    protected final PreloadStatusT getTargetPreloadStatusIfCurrentlyPreloading(MediaItem mediaItem) {
        synchronized (this.lock) {
            BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder currentlyPreloadingMediaSourceHolder = getCurrentlyPreloadingMediaSourceHolder();
            if (currentlyPreloadingMediaSourceHolder != null && mediaItem.equals(currentlyPreloadingMediaSourceHolder.mediaItem)) {
                return this.targetPreloadStatusOfCurrentPreloadingSource;
            }
            return null;
        }
    }

    private boolean isCurrentlyPreloading(BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder mediaSourceHolder) {
        boolean z;
        synchronized (this.lock) {
            z = mediaSourceHolder == getCurrentlyPreloadingMediaSourceHolder();
        }
        return z;
    }

    protected void releaseMediaSourceHolderInternal(BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder mediaSourceHolder) {
        mediaSourceHolder.release();
    }

    private boolean maybeStartPreloadingNextSourceHolder() {
        if (!shouldStartPreloadingNextSource()) {
            return false;
        }
        BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder mediaSourceHolder = this.sourceHolderPriorityList.get(this.indexForSourceHolderToPreload);
        if (mediaSourceHolder.isReleased()) {
            return false;
        }
        PreloadStatusT targetPreloadStatus = this.targetPreloadStatusControl.getTargetPreloadStatus(mediaSourceHolder.rankingData);
        this.targetPreloadStatusOfCurrentPreloadingSource = targetPreloadStatus;
        preloadMediaSourceHolderInternal(mediaSourceHolder, targetPreloadStatus);
        return true;
    }

    private void verifyApplicationThread() {
        if (Looper.myLooper() != this.applicationHandler.getLooper()) {
            throw new IllegalStateException("Preload manager is accessed on the wrong thread.");
        }
    }

    protected class MediaSourceHolder implements Comparable<BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder> {
        public final MediaItem mediaItem;
        private MediaSource mediaSource;
        public final T rankingData;
        private boolean released;

        public MediaSourceHolder(MediaItem mediaItem, T t, MediaSource mediaSource) {
            this.mediaItem = mediaItem;
            this.rankingData = t;
            this.mediaSource = mediaSource;
        }

        public final void release() {
            this.released = true;
        }

        public final boolean isReleased() {
            return this.released;
        }

        public synchronized MediaSource getMediaSource() {
            return this.mediaSource;
        }

        public synchronized void setMediaSource(MediaSource mediaSource) {
            this.mediaSource = mediaSource;
        }

        @Override // java.lang.Comparable
        public int compareTo(BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder mediaSourceHolder) {
            return BasePreloadManager.this.rankingDataComparator.compare(this.rankingData, mediaSourceHolder.rankingData);
        }
    }

    private final class MediaSourceHolderMap {
        private final HashMap<MediaItem, BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder> mediaItemToMediaSourceHolder = new HashMap<>();
        private final HashMap<MediaSource, MediaItem> mediaSourceToMediaItem = new HashMap<>();

        public MediaSourceHolderMap() {
        }

        public synchronized void put(MediaItem mediaItem, MediaSource mediaSource, BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder mediaSourceHolder) {
            this.mediaItemToMediaSourceHolder.put(mediaItem, mediaSourceHolder);
            this.mediaSourceToMediaItem.put(mediaSource, mediaItem);
        }

        public synchronized Collection<BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder> values() {
            return this.mediaItemToMediaSourceHolder.values();
        }

        public synchronized int size() {
            return this.mediaItemToMediaSourceHolder.size();
        }

        public synchronized boolean containsKey(MediaItem mediaItem) {
            return this.mediaItemToMediaSourceHolder.containsKey(mediaItem);
        }

        public synchronized BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder get(MediaItem mediaItem) {
            return this.mediaItemToMediaSourceHolder.get(mediaItem);
        }

        public synchronized BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder get(MediaSource mediaSource) {
            MediaItem mediaItem = this.mediaSourceToMediaItem.get(mediaSource);
            if (mediaItem == null) {
                return null;
            }
            return (MediaSourceHolder) Preconditions.checkNotNull(this.mediaItemToMediaSourceHolder.get(mediaItem));
        }

        public synchronized boolean remove(MediaItem mediaItem) {
            BasePreloadManager<T, PreloadStatusT>.MediaSourceHolder mediaSourceHolderRemove = this.mediaItemToMediaSourceHolder.remove(mediaItem);
            if (mediaSourceHolderRemove == null) {
                return false;
            }
            Preconditions.checkNotNull(this.mediaSourceToMediaItem.remove(mediaSourceHolderRemove.getMediaSource()));
            return true;
        }

        public synchronized boolean remove(MediaSource mediaSource) {
            MediaItem mediaItemRemove = this.mediaSourceToMediaItem.remove(mediaSource);
            if (mediaItemRemove == null) {
                return false;
            }
            Preconditions.checkNotNull(this.mediaItemToMediaSourceHolder.remove(mediaItemRemove));
            return true;
        }

        public synchronized void clear() {
            this.mediaItemToMediaSourceHolder.clear();
            this.mediaSourceToMediaItem.clear();
        }
    }
}
