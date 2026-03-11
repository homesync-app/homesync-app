package androidx.media3.exoplayer.source.preload;

import android.content.Context;
import android.os.HandlerThread;
import android.os.Looper;
import androidx.credentials.CredentialManager$$ExternalSyntheticLambda0;
import androidx.media3.common.C;
import androidx.media3.common.MediaItem;
import androidx.media3.common.util.Clock;
import androidx.media3.common.util.HandlerWrapper;
import androidx.media3.common.util.Util;
import androidx.media3.datasource.DefaultDataSource;
import androidx.media3.datasource.cache.Cache;
import androidx.media3.datasource.cache.CacheDataSource;
import androidx.media3.exoplayer.DefaultRendererCapabilitiesList;
import androidx.media3.exoplayer.DefaultRenderersFactory;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.ExoPlayer$Builder$$ExternalSyntheticLambda17;
import androidx.media3.exoplayer.LoadControl;
import androidx.media3.exoplayer.PlaybackLooperProvider;
import androidx.media3.exoplayer.RendererCapabilitiesList;
import androidx.media3.exoplayer.RenderersFactory;
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.exoplayer.source.preload.BasePreloadManager;
import androidx.media3.exoplayer.source.preload.DefaultPreloadManager;
import androidx.media3.exoplayer.source.preload.PreCacheHelper;
import androidx.media3.exoplayer.source.preload.PreloadMediaSource;
import androidx.media3.exoplayer.source.preload.RankingDataComparator;
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector;
import androidx.media3.exoplayer.trackselection.TrackSelector;
import androidx.media3.exoplayer.upstream.BandwidthMeter;
import androidx.media3.exoplayer.upstream.DefaultBandwidthMeter;
import com.google.common.base.Preconditions;
import com.google.common.base.Predicate;
import com.google.common.base.Supplier;
import com.google.common.base.Suppliers;
import java.io.IOException;
import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.util.concurrent.Executor;

/* JADX INFO: loaded from: classes.dex */
public final class DefaultPreloadManager extends BasePreloadManager<Integer, PreloadStatus> {
    private final PreCacheHelper.Factory preCacheHelperFactory;
    private final HandlerThread preCacheThread;
    private final HandlerWrapper preloadHandler;
    private final PlaybackLooperProvider preloadLooperProvider;
    private final PreloadMediaSource.Factory preloadMediaSourceFactory;
    private boolean releaseCalled;
    private final RendererCapabilitiesList rendererCapabilitiesList;
    private final TrackSelector trackSelector;

    static /* synthetic */ void lambda$new$0() {
    }

    public static final class Builder extends BasePreloadManager.BuilderBase<Integer, PreloadStatus> {
        private Supplier<BandwidthMeter> bandwidthMeterSupplier;
        private boolean buildCalled;
        private boolean buildExoPlayerCalled;
        private Cache cache;
        private Executor cachingExecutor;
        private Clock clock;
        private final Context context;
        private Supplier<LoadControl> loadControlSupplier;
        private PlaybackLooperProvider preloadLooperProvider;
        private Supplier<RenderersFactory> renderersFactorySupplier;
        private TrackSelector.Factory trackSelectorFactory;

        static /* synthetic */ BandwidthMeter lambda$setBandwidthMeter$4(BandwidthMeter bandwidthMeter) {
            return bandwidthMeter;
        }

        static /* synthetic */ LoadControl lambda$setLoadControl$3(LoadControl loadControl) {
            return loadControl;
        }

        static /* synthetic */ RenderersFactory lambda$setRenderersFactory$2(RenderersFactory renderersFactory) {
            return renderersFactory;
        }

        public Builder(final Context context, TargetPreloadStatusControl<Integer, PreloadStatus> targetPreloadStatusControl) {
            super(new SimpleRankingDataComparator(), targetPreloadStatusControl, new MediaSourceFactorySupplier(context));
            this.context = context;
            this.preloadLooperProvider = new PlaybackLooperProvider();
            this.trackSelectorFactory = new TrackSelector.Factory() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$Builder$$ExternalSyntheticLambda3
                @Override // androidx.media3.exoplayer.trackselection.TrackSelector.Factory
                public final TrackSelector createTrackSelector(Context context2) {
                    return new DefaultTrackSelector(context2);
                }
            };
            this.bandwidthMeterSupplier = new Supplier() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$Builder$$ExternalSyntheticLambda4
                @Override // com.google.common.base.Supplier
                public final Object get() {
                    return DefaultBandwidthMeter.getSingletonInstance(context);
                }
            };
            this.renderersFactorySupplier = Suppliers.memoize(new Supplier() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$Builder$$ExternalSyntheticLambda5
                @Override // com.google.common.base.Supplier
                public final Object get() {
                    return DefaultPreloadManager.Builder.lambda$new$1(context);
                }
            });
            this.loadControlSupplier = Suppliers.memoize(new ExoPlayer$Builder$$ExternalSyntheticLambda17());
            this.cachingExecutor = new CredentialManager$$ExternalSyntheticLambda0();
            this.clock = Clock.DEFAULT;
        }

        static /* synthetic */ RenderersFactory lambda$new$1(Context context) {
            return new DefaultRenderersFactory(context);
        }

        public Builder setMediaSourceFactory(MediaSource.Factory factory) {
            Preconditions.checkState((this.buildCalled || this.buildExoPlayerCalled) ? false : true);
            ((MediaSourceFactorySupplier) this.mediaSourceFactorySupplier).setCustomMediaSourceFactory(factory);
            return this;
        }

        public Builder setRenderersFactory(final RenderersFactory renderersFactory) {
            Preconditions.checkState((this.buildCalled || this.buildExoPlayerCalled) ? false : true);
            this.renderersFactorySupplier = new Supplier() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$Builder$$ExternalSyntheticLambda1
                @Override // com.google.common.base.Supplier
                public final Object get() {
                    return DefaultPreloadManager.Builder.lambda$setRenderersFactory$2(renderersFactory);
                }
            };
            return this;
        }

        public Builder setTrackSelectorFactory(TrackSelector.Factory factory) {
            Preconditions.checkState((this.buildCalled || this.buildExoPlayerCalled) ? false : true);
            this.trackSelectorFactory = factory;
            return this;
        }

        public Builder setLoadControl(final LoadControl loadControl) {
            Preconditions.checkState((this.buildCalled || this.buildExoPlayerCalled) ? false : true);
            this.loadControlSupplier = new Supplier() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$Builder$$ExternalSyntheticLambda0
                @Override // com.google.common.base.Supplier
                public final Object get() {
                    return DefaultPreloadManager.Builder.lambda$setLoadControl$3(loadControl);
                }
            };
            return this;
        }

        public Builder setBandwidthMeter(final BandwidthMeter bandwidthMeter) {
            Preconditions.checkState((this.buildCalled || this.buildExoPlayerCalled) ? false : true);
            this.bandwidthMeterSupplier = new Supplier() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$Builder$$ExternalSyntheticLambda2
                @Override // com.google.common.base.Supplier
                public final Object get() {
                    return DefaultPreloadManager.Builder.lambda$setBandwidthMeter$4(bandwidthMeter);
                }
            };
            return this;
        }

        public Builder setPreloadLooper(Looper looper) {
            Preconditions.checkState((this.buildCalled || this.buildExoPlayerCalled || looper == Looper.getMainLooper()) ? false : true);
            this.preloadLooperProvider = new PlaybackLooperProvider(looper);
            return this;
        }

        public Builder setCache(Cache cache) {
            Preconditions.checkState((this.buildCalled || this.buildExoPlayerCalled) ? false : true);
            this.cache = cache;
            ((MediaSourceFactorySupplier) this.mediaSourceFactorySupplier).setCache(cache);
            return this;
        }

        public Builder setCachingExecutor(Executor executor) {
            Preconditions.checkState((this.buildCalled || this.buildExoPlayerCalled) ? false : true);
            this.cachingExecutor = executor;
            return this;
        }

        public Builder setClock(Clock clock) {
            this.clock = clock;
            return this;
        }

        public ExoPlayer buildExoPlayer() {
            return buildExoPlayer(new ExoPlayer.Builder(this.context));
        }

        public ExoPlayer buildExoPlayer(ExoPlayer.Builder builder) {
            this.buildExoPlayerCalled = true;
            return builder.setMediaSourceFactory(this.mediaSourceFactorySupplier.get()).setBandwidthMeter(this.bandwidthMeterSupplier.get()).setRenderersFactory(this.renderersFactorySupplier.get()).setLoadControl(this.loadControlSupplier.get()).setPlaybackLooperProvider(this.preloadLooperProvider).setTrackSelector(this.trackSelectorFactory.createTrackSelector(this.context)).build();
        }

        @Override // androidx.media3.exoplayer.source.preload.BasePreloadManager.BuilderBase
        public BasePreloadManager<Integer, PreloadStatus> build() {
            Preconditions.checkState(!this.buildCalled);
            this.buildCalled = true;
            return new DefaultPreloadManager(this);
        }
    }

    public static final class PreloadStatus {
        public static final PreloadStatus PRELOAD_STATUS_NOT_PRELOADED = new PreloadStatus(Integer.MIN_VALUE, C.TIME_UNSET, 0);
        public static final PreloadStatus PRELOAD_STATUS_SOURCE_PREPARED = new PreloadStatus(0, C.TIME_UNSET, 0);
        public static final PreloadStatus PRELOAD_STATUS_TRACKS_SELECTED = new PreloadStatus(1, C.TIME_UNSET, 0);
        public static final int STAGE_NOT_PRELOADED = Integer.MIN_VALUE;
        public static final int STAGE_SOURCE_PREPARED = 0;
        public static final int STAGE_SPECIFIED_RANGE_CACHED = -1;
        public static final int STAGE_SPECIFIED_RANGE_LOADED = 2;
        public static final int STAGE_TRACKS_SELECTED = 1;
        public final long durationMs;
        public final int stage;
        public final long startPositionMs;

        @Target({ElementType.TYPE_USE})
        @Documented
        @Retention(RetentionPolicy.SOURCE)
        public @interface Stage {
        }

        private PreloadStatus(int i, long j, long j2) {
            Preconditions.checkArgument(j == C.TIME_UNSET || j >= 0);
            Preconditions.checkArgument(j2 == C.TIME_UNSET || j2 >= 0);
            this.stage = i;
            this.startPositionMs = j;
            this.durationMs = j2;
        }

        public static PreloadStatus specifiedRangeLoaded(long j) {
            return new PreloadStatus(2, C.TIME_UNSET, j);
        }

        public static PreloadStatus specifiedRangeLoaded(long j, long j2) {
            return new PreloadStatus(2, j, j2);
        }

        public static PreloadStatus specifiedRangeCached(long j) {
            return new PreloadStatus(-1, C.TIME_UNSET, j);
        }

        public static PreloadStatus specifiedRangeCached(long j, long j2) {
            return new PreloadStatus(-1, j, j2);
        }

        /* JADX INFO: Access modifiers changed from: private */
        public boolean isPreloadingCategory() {
            int i = this.stage;
            return i == 0 || i == 1 || i == 2;
        }

        /* JADX INFO: Access modifiers changed from: private */
        public boolean isPreCachingCategory() {
            return this.stage == -1;
        }

        public boolean equals(Object obj) {
            if (this == obj) {
                return true;
            }
            if (obj != null && getClass() == obj.getClass()) {
                PreloadStatus preloadStatus = (PreloadStatus) obj;
                if (this.stage == preloadStatus.stage && this.startPositionMs == preloadStatus.startPositionMs && this.durationMs == preloadStatus.durationMs) {
                    return true;
                }
            }
            return false;
        }

        public int hashCode() {
            return ((((527 + this.stage) * 31) + ((int) this.startPositionMs)) * 31) + ((int) this.durationMs);
        }
    }

    private DefaultPreloadManager(Builder builder) {
        super(new SimpleRankingDataComparator(), builder.targetPreloadStatusControl, builder.mediaSourceFactorySupplier.get());
        DefaultRendererCapabilitiesList defaultRendererCapabilitiesListCreateRendererCapabilitiesList = new DefaultRendererCapabilitiesList.Factory((RenderersFactory) builder.renderersFactorySupplier.get()).createRendererCapabilitiesList();
        this.rendererCapabilitiesList = defaultRendererCapabilitiesListCreateRendererCapabilitiesList;
        PlaybackLooperProvider playbackLooperProvider = builder.preloadLooperProvider;
        this.preloadLooperProvider = playbackLooperProvider;
        TrackSelector trackSelectorCreateTrackSelector = builder.trackSelectorFactory.createTrackSelector(builder.context);
        this.trackSelector = trackSelectorCreateTrackSelector;
        BandwidthMeter bandwidthMeter = (BandwidthMeter) builder.bandwidthMeterSupplier.get();
        trackSelectorCreateTrackSelector.init(new TrackSelector.InvalidationListener() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$$ExternalSyntheticLambda2
            @Override // androidx.media3.exoplayer.trackselection.TrackSelector.InvalidationListener
            public final void onTrackSelectionsInvalidated() {
                DefaultPreloadManager.lambda$new$0();
            }
        }, bandwidthMeter);
        Looper looperObtainLooper = playbackLooperProvider.obtainLooper();
        this.preloadMediaSourceFactory = new PreloadMediaSource.Factory(builder.mediaSourceFactorySupplier.get(), new PreloadMediaSourceControl(), trackSelectorCreateTrackSelector, bandwidthMeter, defaultRendererCapabilitiesListCreateRendererCapabilitiesList.getRendererCapabilities(), (LoadControl) builder.loadControlSupplier.get(), looperObtainLooper).setClock(builder.clock);
        Cache cache = builder.cache;
        if (cache != null) {
            HandlerThread handlerThread = new HandlerThread("DefaultPreloadManager:PreCacheHelper");
            this.preCacheThread = handlerThread;
            handlerThread.start();
            this.preCacheHelperFactory = new PreCacheHelper.Factory(builder.context, cache, handlerThread.getLooper()).setDownloadExecutor(builder.cachingExecutor).setListener(new PreCacheHelperListener());
        } else {
            this.preCacheThread = null;
            this.preCacheHelperFactory = null;
        }
        this.preloadHandler = builder.clock.createHandler(looperObtainLooper, null);
    }

    public void setCurrentPlayingIndex(int i) {
        ((SimpleRankingDataComparator) this.rankingDataComparator).setCurrentPlayingIndex(i);
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // androidx.media3.exoplayer.source.preload.BasePreloadManager
    public BasePreloadManager<Integer, PreloadStatus>.MediaSourceHolder createMediaSourceHolder(MediaItem mediaItem, MediaSource mediaSource, Integer num) {
        PreloadMediaSource preloadMediaSourceCreateMediaSource;
        if (mediaSource != null) {
            preloadMediaSourceCreateMediaSource = this.preloadMediaSourceFactory.createMediaSource(mediaSource);
        } else {
            preloadMediaSourceCreateMediaSource = this.preloadMediaSourceFactory.createMediaSource(mediaItem);
        }
        return new PreloadMediaSourceHolder(mediaItem, preloadMediaSourceCreateMediaSource, num);
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // androidx.media3.exoplayer.source.preload.BasePreloadManager
    public void preloadMediaSourceHolderInternal(BasePreloadManager<Integer, PreloadStatus>.MediaSourceHolder mediaSourceHolder, PreloadStatus preloadStatus) {
        if (this.releaseCalled) {
            return;
        }
        Preconditions.checkArgument(mediaSourceHolder instanceof PreloadMediaSourceHolder);
        PreloadMediaSourceHolder preloadMediaSourceHolder = (PreloadMediaSourceHolder) mediaSourceHolder;
        PreloadMediaSource mediaSource = preloadMediaSourceHolder.getMediaSource();
        maybeClearPreloadMediaSource(mediaSource, preloadStatus);
        if (preloadStatus.equals(PreloadStatus.PRELOAD_STATUS_NOT_PRELOADED)) {
            onSkipped(mediaSource, new Predicate() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$$ExternalSyntheticLambda1
                @Override // com.google.common.base.Predicate
                public final boolean apply(Object obj) {
                    return DefaultPreloadManager.lambda$preloadMediaSourceHolderInternal$1((DefaultPreloadManager.PreloadStatus) obj);
                }
            });
        } else {
            if (preloadStatus.stage == -1) {
                if (preloadMediaSourceHolder.preCacheHelper == null) {
                    preloadMediaSourceHolder.preCacheHelper = ((PreCacheHelper.Factory) Preconditions.checkNotNull(this.preCacheHelperFactory, "DefaultPreloadManager wasn't configured with a Cache")).create(mediaSourceHolder.mediaItem);
                }
                ((PreCacheHelper) Preconditions.checkNotNull(preloadMediaSourceHolder.preCacheHelper)).preCache(preloadStatus.startPositionMs, preloadStatus.durationMs);
                return;
            }
            mediaSource.preload(Util.msToUs(preloadStatus.startPositionMs));
        }
    }

    static /* synthetic */ boolean lambda$preloadMediaSourceHolderInternal$1(PreloadStatus preloadStatus) {
        return preloadStatus.stage == Integer.MIN_VALUE;
    }

    private void maybeClearPreloadMediaSource(PreloadMediaSource preloadMediaSource, PreloadStatus preloadStatus) {
        if (preloadStatus.stage == Integer.MIN_VALUE || preloadStatus.stage == -1 || preloadStatus.stage == 0) {
            preloadMediaSource.clear();
        }
    }

    @Override // androidx.media3.exoplayer.source.preload.BasePreloadManager
    protected void releaseMediaSourceHolderInternal(BasePreloadManager<Integer, PreloadStatus>.MediaSourceHolder mediaSourceHolder) {
        if (this.releaseCalled) {
            return;
        }
        super.releaseMediaSourceHolderInternal(mediaSourceHolder);
        Preconditions.checkArgument(mediaSourceHolder instanceof PreloadMediaSourceHolder);
        PreloadMediaSourceHolder preloadMediaSourceHolder = (PreloadMediaSourceHolder) mediaSourceHolder;
        preloadMediaSourceHolder.getMediaSource().releasePreloadMediaSource();
        if (preloadMediaSourceHolder.preCacheHelper != null) {
            preloadMediaSourceHolder.preCacheHelper.release(true);
            preloadMediaSourceHolder.preCacheHelper = null;
        }
    }

    @Override // androidx.media3.exoplayer.source.preload.BasePreloadManager
    protected void releaseInternal() {
        this.releaseCalled = true;
        releasePreloadUtils();
        releasePreCacheUtils();
    }

    private void releasePreloadUtils() {
        this.preloadHandler.post(new Runnable() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$$ExternalSyntheticLambda0
            @Override // java.lang.Runnable
            public final void run() {
                this.f$0.m303xa55db43d();
            }
        });
    }

    /* JADX INFO: renamed from: lambda$releasePreloadUtils$2$androidx-media3-exoplayer-source-preload-DefaultPreloadManager, reason: not valid java name */
    /* synthetic */ void m303xa55db43d() {
        this.rendererCapabilitiesList.release();
        this.trackSelector.release();
        this.preloadLooperProvider.releaseLooper();
    }

    private void releasePreCacheUtils() {
        HandlerThread handlerThread = this.preCacheThread;
        if (handlerThread != null) {
            handlerThread.quit();
        }
    }

    private static final class SimpleRankingDataComparator implements RankingDataComparator<Integer> {
        private int currentPlayingIndex = -1;
        private RankingDataComparator.InvalidationListener invalidationListener;

        @Override // java.util.Comparator
        public int compare(Integer num, Integer num2) {
            return Integer.compare(Math.abs(num.intValue() - this.currentPlayingIndex), Math.abs(num2.intValue() - this.currentPlayingIndex));
        }

        @Override // androidx.media3.exoplayer.source.preload.RankingDataComparator
        public void setInvalidationListener(RankingDataComparator.InvalidationListener invalidationListener) {
            this.invalidationListener = invalidationListener;
        }

        public void setCurrentPlayingIndex(int i) {
            if (i != this.currentPlayingIndex) {
                this.currentPlayingIndex = i;
                RankingDataComparator.InvalidationListener invalidationListener = this.invalidationListener;
                if (invalidationListener != null) {
                    invalidationListener.onRankingDataComparatorInvalidated();
                }
            }
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    final class PreCacheHelperListener implements PreCacheHelper.Listener {
        private PreCacheHelperListener() {
        }

        @Override // androidx.media3.exoplayer.source.preload.PreCacheHelper.Listener
        public void onPrepared(MediaItem mediaItem, MediaItem mediaItem2) {
            PreloadStatus targetPreloadStatusIfCurrentlyPreloading = DefaultPreloadManager.this.getTargetPreloadStatusIfCurrentlyPreloading(mediaItem);
            if (targetPreloadStatusIfCurrentlyPreloading == null || !targetPreloadStatusIfCurrentlyPreloading.isPreCachingCategory()) {
                return;
            }
            DefaultPreloadManager.this.onMediaSourceUpdated(mediaItem, DefaultPreloadManager.this.preloadMediaSourceFactory.createMediaSource(mediaItem2));
        }

        @Override // androidx.media3.exoplayer.source.preload.PreCacheHelper.Listener
        public void onPreCacheProgress(MediaItem mediaItem, long j, long j2, float f) {
            final PreloadStatus targetPreloadStatusIfCurrentlyPreloading;
            if (f == 100.0f && (targetPreloadStatusIfCurrentlyPreloading = DefaultPreloadManager.this.getTargetPreloadStatusIfCurrentlyPreloading(mediaItem)) != null && targetPreloadStatusIfCurrentlyPreloading.isPreCachingCategory()) {
                DefaultPreloadManager.this.onCompleted(mediaItem, new Predicate() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$PreCacheHelperListener$$ExternalSyntheticLambda1
                    @Override // com.google.common.base.Predicate
                    public final boolean apply(Object obj) {
                        return ((DefaultPreloadManager.PreloadStatus) obj).equals(targetPreloadStatusIfCurrentlyPreloading);
                    }
                });
            }
        }

        @Override // androidx.media3.exoplayer.source.preload.PreCacheHelper.Listener
        public void onPrepareError(MediaItem mediaItem, IOException iOException) {
            final PreloadStatus targetPreloadStatusIfCurrentlyPreloading = DefaultPreloadManager.this.getTargetPreloadStatusIfCurrentlyPreloading(mediaItem);
            if (targetPreloadStatusIfCurrentlyPreloading == null || !targetPreloadStatusIfCurrentlyPreloading.isPreCachingCategory()) {
                return;
            }
            DefaultPreloadManager.this.onError(new PreloadException(mediaItem, null, iOException), mediaItem, new Predicate() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$PreCacheHelperListener$$ExternalSyntheticLambda0
                @Override // com.google.common.base.Predicate
                public final boolean apply(Object obj) {
                    return ((DefaultPreloadManager.PreloadStatus) obj).equals(targetPreloadStatusIfCurrentlyPreloading);
                }
            });
        }

        @Override // androidx.media3.exoplayer.source.preload.PreCacheHelper.Listener
        public void onDownloadError(MediaItem mediaItem, IOException iOException) {
            final PreloadStatus targetPreloadStatusIfCurrentlyPreloading = DefaultPreloadManager.this.getTargetPreloadStatusIfCurrentlyPreloading(mediaItem);
            if (targetPreloadStatusIfCurrentlyPreloading == null || !targetPreloadStatusIfCurrentlyPreloading.isPreCachingCategory()) {
                return;
            }
            DefaultPreloadManager.this.onError(new PreloadException(mediaItem, null, iOException), mediaItem, new Predicate() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$PreCacheHelperListener$$ExternalSyntheticLambda2
                @Override // com.google.common.base.Predicate
                public final boolean apply(Object obj) {
                    return ((DefaultPreloadManager.PreloadStatus) obj).equals(targetPreloadStatusIfCurrentlyPreloading);
                }
            });
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    final class PreloadMediaSourceControl implements PreloadMediaSource.PreloadControl {
        private PreloadMediaSourceControl() {
        }

        @Override // androidx.media3.exoplayer.source.preload.PreloadMediaSource.PreloadControl
        public boolean onSourcePrepared(PreloadMediaSource preloadMediaSource) {
            return continueOrCompletePreloading(preloadMediaSource, new Predicate() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$PreloadMediaSourceControl$$ExternalSyntheticLambda0
                @Override // com.google.common.base.Predicate
                public final boolean apply(Object obj) {
                    return DefaultPreloadManager.PreloadMediaSourceControl.lambda$onSourcePrepared$0((DefaultPreloadManager.PreloadStatus) obj);
                }
            });
        }

        static /* synthetic */ boolean lambda$onSourcePrepared$0(PreloadStatus preloadStatus) {
            return preloadStatus.stage > 0;
        }

        @Override // androidx.media3.exoplayer.source.preload.PreloadMediaSource.PreloadControl
        public boolean onTracksSelected(PreloadMediaSource preloadMediaSource) {
            return continueOrCompletePreloading(preloadMediaSource, new Predicate() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$PreloadMediaSourceControl$$ExternalSyntheticLambda2
                @Override // com.google.common.base.Predicate
                public final boolean apply(Object obj) {
                    return DefaultPreloadManager.PreloadMediaSourceControl.lambda$onTracksSelected$1((DefaultPreloadManager.PreloadStatus) obj);
                }
            });
        }

        static /* synthetic */ boolean lambda$onTracksSelected$1(PreloadStatus preloadStatus) {
            return preloadStatus.stage > 1;
        }

        @Override // androidx.media3.exoplayer.source.preload.PreloadMediaSource.PreloadControl
        public boolean onContinueLoadingRequested(PreloadMediaSource preloadMediaSource, final long j) {
            return continueOrCompletePreloading(preloadMediaSource, new Predicate() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$PreloadMediaSourceControl$$ExternalSyntheticLambda3
                @Override // com.google.common.base.Predicate
                public final boolean apply(Object obj) {
                    return DefaultPreloadManager.PreloadMediaSourceControl.lambda$onContinueLoadingRequested$2(j, (DefaultPreloadManager.PreloadStatus) obj);
                }
            });
        }

        static /* synthetic */ boolean lambda$onContinueLoadingRequested$2(long j, PreloadStatus preloadStatus) {
            return preloadStatus.stage == 2 && preloadStatus.durationMs != C.TIME_UNSET && preloadStatus.durationMs > Util.usToMs(j);
        }

        @Override // androidx.media3.exoplayer.source.preload.PreloadMediaSource.PreloadControl
        public void onUsedByPlayer(PreloadMediaSource preloadMediaSource) {
            final PreloadStatus targetPreloadStatusIfCurrentlyPreloading = DefaultPreloadManager.this.getTargetPreloadStatusIfCurrentlyPreloading(preloadMediaSource);
            if (targetPreloadStatusIfCurrentlyPreloading == null || !targetPreloadStatusIfCurrentlyPreloading.isPreloadingCategory()) {
                return;
            }
            DefaultPreloadManager.this.onSkipped(preloadMediaSource, new Predicate() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$PreloadMediaSourceControl$$ExternalSyntheticLambda1
                @Override // com.google.common.base.Predicate
                public final boolean apply(Object obj) {
                    return ((DefaultPreloadManager.PreloadStatus) obj).equals(targetPreloadStatusIfCurrentlyPreloading);
                }
            });
        }

        @Override // androidx.media3.exoplayer.source.preload.PreloadMediaSource.PreloadControl
        public void onLoadedToTheEndOfSource(PreloadMediaSource preloadMediaSource) {
            final PreloadStatus targetPreloadStatusIfCurrentlyPreloading = DefaultPreloadManager.this.getTargetPreloadStatusIfCurrentlyPreloading(preloadMediaSource);
            if (targetPreloadStatusIfCurrentlyPreloading == null || !targetPreloadStatusIfCurrentlyPreloading.isPreloadingCategory()) {
                return;
            }
            DefaultPreloadManager.this.onCompleted(preloadMediaSource, new Predicate() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$PreloadMediaSourceControl$$ExternalSyntheticLambda5
                @Override // com.google.common.base.Predicate
                public final boolean apply(Object obj) {
                    return ((DefaultPreloadManager.PreloadStatus) obj).equals(targetPreloadStatusIfCurrentlyPreloading);
                }
            });
        }

        @Override // androidx.media3.exoplayer.source.preload.PreloadMediaSource.PreloadControl
        public void onPreloadError(PreloadException preloadException, PreloadMediaSource preloadMediaSource) {
            final PreloadStatus targetPreloadStatusIfCurrentlyPreloading = DefaultPreloadManager.this.getTargetPreloadStatusIfCurrentlyPreloading(preloadMediaSource);
            if (targetPreloadStatusIfCurrentlyPreloading == null || !targetPreloadStatusIfCurrentlyPreloading.isPreloadingCategory()) {
                return;
            }
            DefaultPreloadManager.this.onError(preloadException, preloadMediaSource, new Predicate() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$PreloadMediaSourceControl$$ExternalSyntheticLambda4
                @Override // com.google.common.base.Predicate
                public final boolean apply(Object obj) {
                    return ((DefaultPreloadManager.PreloadStatus) obj).equals(targetPreloadStatusIfCurrentlyPreloading);
                }
            });
        }

        @Override // androidx.media3.exoplayer.source.preload.PreloadMediaSource.PreloadControl
        public boolean onLoadingUnableToContinue(PreloadMediaSource preloadMediaSource) {
            BasePreloadManager<Integer, PreloadStatus>.MediaSourceHolder mediaSourceHolderToClear = DefaultPreloadManager.this.getMediaSourceHolderToClear();
            if (mediaSourceHolderToClear == null) {
                return false;
            }
            ((PreloadMediaSource) mediaSourceHolderToClear.getMediaSource()).clear();
            DefaultPreloadManager.this.onSourceCleared();
            return true;
        }

        private boolean continueOrCompletePreloading(PreloadMediaSource preloadMediaSource, Predicate<PreloadStatus> predicate) {
            final PreloadStatus targetPreloadStatusIfCurrentlyPreloading = DefaultPreloadManager.this.getTargetPreloadStatusIfCurrentlyPreloading(preloadMediaSource);
            if (targetPreloadStatusIfCurrentlyPreloading == null || !targetPreloadStatusIfCurrentlyPreloading.isPreloadingCategory()) {
                return false;
            }
            if (predicate.apply(targetPreloadStatusIfCurrentlyPreloading)) {
                return true;
            }
            DefaultPreloadManager.this.onCompleted(preloadMediaSource, new Predicate() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$PreloadMediaSourceControl$$ExternalSyntheticLambda6
                @Override // com.google.common.base.Predicate
                public final boolean apply(Object obj) {
                    return ((DefaultPreloadManager.PreloadStatus) obj).equals(targetPreloadStatusIfCurrentlyPreloading);
                }
            });
            return false;
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    static class MediaSourceFactorySupplier implements Supplier<MediaSource.Factory> {
        private Cache cache;
        private final Context context;
        private MediaSource.Factory customMediaSourceFactory;
        private final Supplier<DefaultMediaSourceFactory> defaultMediaSourceFactorySupplier;

        public MediaSourceFactorySupplier(final Context context) {
            this.context = context;
            this.defaultMediaSourceFactorySupplier = Suppliers.memoize(new Supplier() { // from class: androidx.media3.exoplayer.source.preload.DefaultPreloadManager$MediaSourceFactorySupplier$$ExternalSyntheticLambda0
                @Override // com.google.common.base.Supplier
                public final Object get() {
                    return DefaultPreloadManager.MediaSourceFactorySupplier.lambda$new$0(context);
                }
            });
        }

        static /* synthetic */ DefaultMediaSourceFactory lambda$new$0(Context context) {
            return new DefaultMediaSourceFactory(context);
        }

        public void setCache(Cache cache) {
            this.cache = cache;
        }

        public void setCustomMediaSourceFactory(MediaSource.Factory factory) {
            this.customMediaSourceFactory = factory;
        }

        /* JADX WARN: Can't rename method to resolve collision */
        @Override // com.google.common.base.Supplier
        public MediaSource.Factory get() {
            MediaSource.Factory factory = this.customMediaSourceFactory;
            if (factory != null) {
                return factory;
            }
            DefaultMediaSourceFactory defaultMediaSourceFactory = this.defaultMediaSourceFactorySupplier.get();
            Cache cache = this.cache;
            if (cache != null) {
                defaultMediaSourceFactory.setDataSourceFactory(new CacheDataSource.Factory().setUpstreamDataSourceFactory(new DefaultDataSource.Factory(this.context)).setCache(cache).setCacheWriteDataSinkFactory(null));
            }
            return defaultMediaSourceFactory;
        }
    }

    private final class PreloadMediaSourceHolder extends BasePreloadManager<Integer, PreloadStatus>.MediaSourceHolder {
        public PreCacheHelper preCacheHelper;

        public PreloadMediaSourceHolder(MediaItem mediaItem, PreloadMediaSource preloadMediaSource, Integer num) {
            super(mediaItem, num, preloadMediaSource);
        }

        @Override // androidx.media3.exoplayer.source.preload.BasePreloadManager.MediaSourceHolder
        public synchronized PreloadMediaSource getMediaSource() {
            return (PreloadMediaSource) super.getMediaSource();
        }

        @Override // androidx.media3.exoplayer.source.preload.BasePreloadManager.MediaSourceHolder
        public synchronized void setMediaSource(MediaSource mediaSource) {
            getMediaSource().releasePreloadMediaSource();
            super.setMediaSource(mediaSource);
        }
    }
}
