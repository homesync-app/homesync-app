package androidx.media3.exoplayer.hls;

import android.content.Context;
import android.net.Uri;
import android.os.Bundle;
import android.os.Looper;
import android.util.LongSparseArray;
import android.util.Pair;
import androidx.media3.common.AdPlaybackState;
import androidx.media3.common.AdViewProvider;
import androidx.media3.common.C;
import androidx.media3.common.MediaItem;
import androidx.media3.common.Metadata;
import androidx.media3.common.MimeTypes;
import androidx.media3.common.Player;
import androidx.media3.common.Timeline;
import androidx.media3.common.util.Consumer;
import androidx.media3.common.util.Log;
import androidx.media3.common.util.Util;
import androidx.media3.datasource.DataSource;
import androidx.media3.datasource.DataSpec;
import androidx.media3.datasource.DefaultDataSource;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.PlayerMessage;
import androidx.media3.exoplayer.drm.DrmSessionManagerProvider;
import androidx.media3.exoplayer.hls.HlsInterstitialsAdsLoader;
import androidx.media3.exoplayer.hls.HlsMediaSource;
import androidx.media3.exoplayer.hls.playlist.HlsMediaPlaylist;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.exoplayer.source.ads.AdsLoader;
import androidx.media3.exoplayer.source.ads.AdsMediaSource;
import androidx.media3.exoplayer.upstream.LoadErrorHandlingPolicy;
import androidx.media3.exoplayer.upstream.Loader;
import androidx.media3.exoplayer.upstream.ParsingLoadable;
import com.google.common.base.Preconditions;
import com.google.common.collect.ImmutableList;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.TreeMap;
import org.json.JSONObject;

/* JADX INFO: loaded from: classes.dex */
public final class HlsInterstitialsAdsLoader implements AdsLoader {
    private static final String TAG = "HlsInterstitiaAdsLoader";
    private static final int TARGET_DURATION_MULTIPLIER = 3;
    private final ContentMediaSourceAdDataHolder contentMediaSourceAdDataHolder;
    private final DataSource.Factory dataSourceFactory;
    private boolean isReleased;
    private final List<Listener> listeners;
    private Loader loader;
    private PlayerMessage pendingAssetListResolutionMessage;
    private ExoPlayer player;
    private final PlayerListener playerListener;
    private final Map<Object, AdPlaybackState> resumptionStates;

    public interface Listener {
        default void onAdCompleted(MediaItem mediaItem, Object obj, int i, int i2) {
        }

        default void onAdSkipped(MediaItem mediaItem, Object obj, int i, int i2) {
        }

        default void onAdStarted(MediaItem mediaItem, Object obj, int i, int i2) {
        }

        default void onAssetListLoadCompleted(MediaItem mediaItem, Object obj, int i, int i2, AssetList assetList, JSONObject jSONObject) {
        }

        default void onAssetListLoadFailed(MediaItem mediaItem, Object obj, int i, int i2, IOException iOException, boolean z) {
        }

        default void onAssetListLoadStarted(MediaItem mediaItem, Object obj, int i, int i2) {
        }

        default void onContentTimelineChanged(MediaItem mediaItem, Object obj, Timeline timeline) {
        }

        default void onMetadata(MediaItem mediaItem, Object obj, int i, int i2, Metadata metadata) {
        }

        default void onPrepareCompleted(MediaItem mediaItem, Object obj, int i, int i2) {
        }

        default void onPrepareError(MediaItem mediaItem, Object obj, int i, int i2, IOException iOException) {
        }

        default void onStart(MediaItem mediaItem, Object obj, AdViewProvider adViewProvider) {
        }

        default void onStop(MediaItem mediaItem, Object obj, AdPlaybackState adPlaybackState) {
        }
    }

    public static final class AssetList {
        static final AssetList EMPTY = new AssetList(ImmutableList.of(), null);
        public final ImmutableList<Asset> assets;
        public final AdPlaybackState.SkipInfo skipInfo;

        AssetList(ImmutableList<Asset> immutableList, AdPlaybackState.SkipInfo skipInfo) {
            this.assets = immutableList;
            this.skipInfo = skipInfo;
        }

        public boolean equals(Object obj) {
            if (this == obj) {
                return true;
            }
            if (!(obj instanceof AssetList)) {
                return false;
            }
            AssetList assetList = (AssetList) obj;
            return Objects.equals(this.assets, assetList.assets) && Objects.equals(this.skipInfo, assetList.skipInfo);
        }

        public int hashCode() {
            return Objects.hash(this.assets, this.skipInfo);
        }
    }

    public static final class Asset {
        public final long durationUs;
        public final Uri uri;

        Asset(Uri uri, long j) {
            this.uri = uri;
            this.durationUs = j;
        }

        public boolean equals(Object obj) {
            if (this == obj) {
                return true;
            }
            if (!(obj instanceof Asset)) {
                return false;
            }
            Asset asset = (Asset) obj;
            return this.durationUs == asset.durationUs && Objects.equals(this.uri, asset.uri);
        }

        public int hashCode() {
            return Objects.hash(this.uri, Long.valueOf(this.durationUs));
        }
    }

    public static class AdsResumptionState {
        private static final String FIELD_ADS_ID = Util.intToStringMaxRadix(0);
        private static final String FIELD_AD_PLAYBACK_STATE = Util.intToStringMaxRadix(1);
        private final AdPlaybackState adPlaybackState;
        public final String adsId;

        public AdsResumptionState(String str, AdPlaybackState adPlaybackState) {
            Preconditions.checkArgument(str.equals(adPlaybackState.adsId));
            this.adsId = str;
            this.adPlaybackState = adPlaybackState;
        }

        public boolean equals(Object obj) {
            if (!(obj instanceof AdsResumptionState)) {
                return false;
            }
            AdsResumptionState adsResumptionState = (AdsResumptionState) obj;
            return Objects.equals(this.adsId, adsResumptionState.adsId) && Objects.equals(this.adPlaybackState, adsResumptionState.adPlaybackState);
        }

        public int hashCode() {
            return Objects.hash(this.adsId, this.adPlaybackState);
        }

        public Bundle toBundle() {
            Bundle bundle = new Bundle();
            bundle.putString(FIELD_ADS_ID, this.adsId);
            bundle.putBundle(FIELD_AD_PLAYBACK_STATE, this.adPlaybackState.toBundle());
            return bundle;
        }

        public static AdsResumptionState fromBundle(Bundle bundle) {
            String str = (String) Preconditions.checkNotNull(bundle.getString(FIELD_ADS_ID));
            return new AdsResumptionState(str, AdPlaybackState.fromBundle((Bundle) Preconditions.checkNotNull(bundle.getBundle(FIELD_AD_PLAYBACK_STATE))).withAdsId(str));
        }
    }

    public static final class AdsMediaSourceFactory implements MediaSource.Factory {
        private final AdViewProvider adViewProvider;
        private final HlsInterstitialsAdsLoader adsLoader;
        private final MediaSource.Factory mediaSourceFactory;

        public AdsMediaSourceFactory(HlsInterstitialsAdsLoader hlsInterstitialsAdsLoader, AdViewProvider adViewProvider, Context context) {
            this(hlsInterstitialsAdsLoader, context, null, adViewProvider);
        }

        public AdsMediaSourceFactory(HlsInterstitialsAdsLoader hlsInterstitialsAdsLoader, AdViewProvider adViewProvider, MediaSource.Factory factory) {
            this(hlsInterstitialsAdsLoader, null, factory, adViewProvider);
        }

        private AdsMediaSourceFactory(HlsInterstitialsAdsLoader hlsInterstitialsAdsLoader, Context context, MediaSource.Factory factory, AdViewProvider adViewProvider) {
            boolean z = false;
            Preconditions.checkArgument((context == null && factory == null) ? false : true);
            this.adsLoader = hlsInterstitialsAdsLoader;
            factory = factory == null ? new HlsMediaSource.Factory(new DefaultDataSource.Factory((Context) Preconditions.checkNotNull(context))) : factory;
            this.mediaSourceFactory = factory;
            this.adViewProvider = adViewProvider;
            int[] supportedTypes = factory.getSupportedTypes();
            int length = supportedTypes.length;
            int i = 0;
            while (true) {
                if (i >= length) {
                    break;
                }
                if (supportedTypes[i] == 2) {
                    z = true;
                    break;
                }
                i++;
            }
            Preconditions.checkState(z);
        }

        @Override // androidx.media3.exoplayer.source.MediaSource.Factory
        public int[] getSupportedTypes() {
            return new int[]{2};
        }

        @Override // androidx.media3.exoplayer.source.MediaSource.Factory
        public AdsMediaSourceFactory setDrmSessionManagerProvider(DrmSessionManagerProvider drmSessionManagerProvider) {
            this.mediaSourceFactory.setDrmSessionManagerProvider(drmSessionManagerProvider);
            return this;
        }

        @Override // androidx.media3.exoplayer.source.MediaSource.Factory
        public AdsMediaSourceFactory setLoadErrorHandlingPolicy(LoadErrorHandlingPolicy loadErrorHandlingPolicy) {
            this.mediaSourceFactory.setLoadErrorHandlingPolicy(loadErrorHandlingPolicy);
            return this;
        }

        @Override // androidx.media3.exoplayer.source.MediaSource.Factory
        public MediaSource createMediaSource(MediaItem mediaItem) {
            Preconditions.checkNotNull(mediaItem.localConfiguration);
            MediaSource mediaSourceCreateMediaSource = this.mediaSourceFactory.createMediaSource(mediaItem);
            if (mediaItem.localConfiguration.adsConfiguration == null) {
                return mediaSourceCreateMediaSource;
            }
            if (!(mediaItem.localConfiguration.adsConfiguration.adsId instanceof String)) {
                throw new IllegalArgumentException("Please use an AdsConfiguration with an adsId of type String when using HlsInterstitialsAdsLoader");
            }
            return new AdsMediaSource(mediaSourceCreateMediaSource, new DataSpec(mediaItem.localConfiguration.adsConfiguration.adTagUri), Preconditions.checkNotNull(mediaItem.localConfiguration.adsConfiguration.adsId), this.mediaSourceFactory, this.adsLoader, this.adViewProvider, false);
        }
    }

    public HlsInterstitialsAdsLoader(Context context) {
        this(new DefaultDataSource.Factory(context));
    }

    public HlsInterstitialsAdsLoader(DataSource.Factory factory) {
        this.dataSourceFactory = factory;
        this.playerListener = new PlayerListener();
        this.contentMediaSourceAdDataHolder = new ContentMediaSourceAdDataHolder();
        this.resumptionStates = new HashMap();
        this.listeners = new ArrayList();
    }

    public void addListener(Listener listener) {
        this.listeners.add(listener);
    }

    public void removeListener(Listener listener) {
        this.listeners.remove(listener);
    }

    @Override // androidx.media3.exoplayer.source.ads.AdsLoader
    public void setPlayer(Player player) {
        boolean z = true;
        Preconditions.checkState(!this.isReleased);
        Preconditions.checkArgument(player == null || (player instanceof ExoPlayer));
        if (Objects.equals(this.player, player)) {
            return;
        }
        ExoPlayer exoPlayer = this.player;
        if (exoPlayer != null && !this.contentMediaSourceAdDataHolder.isIdle()) {
            exoPlayer.removeListener(this.playerListener);
        }
        if (player != null && !this.contentMediaSourceAdDataHolder.isIdle()) {
            z = false;
        }
        Preconditions.checkState(z);
        this.player = (ExoPlayer) player;
    }

    @Override // androidx.media3.exoplayer.source.ads.AdsLoader
    public void setSupportedContentTypes(int... iArr) {
        for (int i : iArr) {
            if (i == 2) {
                return;
            }
        }
        throw new IllegalArgumentException();
    }

    public ImmutableList<AdsResumptionState> getAdsResumptionStates() {
        String str;
        ImmutableList.Builder builder = new ImmutableList.Builder();
        for (AdPlaybackState adPlaybackState : this.contentMediaSourceAdDataHolder.getAdPlaybackStates()) {
            boolean zEndsWithLivePostrollPlaceHolder = adPlaybackState.endsWithLivePostrollPlaceHolder();
            if (!zEndsWithLivePostrollPlaceHolder && (adPlaybackState.adsId instanceof String)) {
                builder.add(new AdsResumptionState((String) adPlaybackState.adsId, adPlaybackState.copy()));
            } else {
                if (zEndsWithLivePostrollPlaceHolder) {
                    str = "getAdsResumptionStates(): ignoring active ad playback state of live stream. adsId=" + adPlaybackState.adsId;
                } else {
                    str = "getAdsResumptionStates(): ignoring active ad playback state when creating resumption states. `adsId` is not of type String: " + Util.castNonNull(adPlaybackState.adsId).getClass();
                }
                Log.i(TAG, str);
            }
        }
        return builder.build();
    }

    public void addAdResumptionState(AdsResumptionState adsResumptionState) {
        addAdResumptionState(adsResumptionState.adsId, adsResumptionState.adPlaybackState);
    }

    public void addAdResumptionState(Object obj, AdPlaybackState adPlaybackState) {
        Preconditions.checkArgument(!adPlaybackState.endsWithLivePostrollPlaceHolder());
        if (!this.contentMediaSourceAdDataHolder.isStartedContentMediaSource(obj)) {
            this.resumptionStates.put(obj, adPlaybackState.copy().withAdsId(obj));
        } else {
            Log.w(TAG, "Attempting to add an ad resumption state for an adsId that is currently active. adsId=" + obj);
        }
    }

    public boolean removeAdResumptionState(Object obj) {
        return this.resumptionStates.remove(obj) != null;
    }

    public void clearAllAdResumptionStates() {
        this.resumptionStates.clear();
    }

    public void skipCurrentAd() {
        Preconditions.checkNotNull(this.player);
        if (this.player.isPlayingAd()) {
            setWithSkippedAd(this.player.getCurrentAdGroupIndex(), this.player.getCurrentAdIndexInAdGroup());
        }
    }

    public void skipCurrentAdGroup() {
        Preconditions.checkNotNull(this.player);
        if (this.player.isPlayingAd()) {
            setWithSkippedAdGroup(this.player.getCurrentAdGroupIndex());
        }
    }

    public void setWithSkippedAd(int i, int i2) {
        Preconditions.checkState(this.player != null);
        AdPlaybackState adPlaybackState = getAdPlaybackState();
        if (adPlaybackState != null) {
            Preconditions.checkArgument(i < adPlaybackState.adGroupCount);
            AdPlaybackState.AdGroup adGroup = adPlaybackState.getAdGroup(i);
            Preconditions.checkArgument(i2 < adGroup.count);
            if (adGroup.states[i2] == 3 || adGroup.states[i2] == 4) {
                Log.w(TAG, "ignoring request to set ad for state AD_STATE_SKIPPED for played or failed ad at adGroupIndex=" + i + ", adIndexInAgGroup=" + i2);
            } else if (adGroup.states[i2] != 2) {
                AdPlaybackState adPlaybackStateWithSkippedAd = adPlaybackState.withSkippedAd(i, i2);
                putAndNotifyAdPlaybackStateUpdate(Preconditions.checkNotNull(adPlaybackStateWithSkippedAd.adsId), adPlaybackStateWithSkippedAd);
                removeUnresolvedAssetListOfAdGroup(adPlaybackStateWithSkippedAd, adGroup);
            }
        }
    }

    public void setWithSkippedAdGroup(int i) {
        Preconditions.checkState(this.player != null);
        AdPlaybackState adPlaybackState = getAdPlaybackState();
        if (adPlaybackState != null) {
            Preconditions.checkArgument(i < adPlaybackState.adGroupCount);
            AdPlaybackState adPlaybackStateWithSkippedAdGroup = adPlaybackState.withSkippedAdGroup(i);
            AdPlaybackState.AdGroup adGroup = adPlaybackStateWithSkippedAdGroup.getAdGroup(i);
            putAndNotifyAdPlaybackStateUpdate(Preconditions.checkNotNull(adPlaybackStateWithSkippedAdGroup.adsId), adPlaybackStateWithSkippedAdGroup);
            removeUnresolvedAssetListOfAdGroup(adPlaybackStateWithSkippedAdGroup, adGroup);
        }
    }

    public void setWithAvailableAdMediaItem(int i, int i2, MediaItem mediaItem) {
        Preconditions.checkState(this.player != null);
        if (mediaItem != null) {
            Preconditions.checkArgument(isHlsMediaItem(mediaItem));
        }
        AdPlaybackState adPlaybackState = getAdPlaybackState();
        if (adPlaybackState != null) {
            Preconditions.checkArgument(i < adPlaybackState.adGroupCount);
            AdPlaybackState.AdGroup adGroup = adPlaybackState.getAdGroup(i);
            Preconditions.checkArgument(i2 < adGroup.count);
            if (mediaItem == null) {
                mediaItem = adGroup.mediaItems[i2];
                Preconditions.checkState(mediaItem != null);
            }
            if (adGroup.states[i2] != 1) {
                AdPlaybackState adPlaybackStateWithAvailableAdMediaItem = adPlaybackState.withAvailableAdMediaItem(i, i2, mediaItem);
                putAndNotifyAdPlaybackStateUpdate(Preconditions.checkNotNull(adPlaybackStateWithAvailableAdMediaItem.adsId), adPlaybackStateWithAvailableAdMediaItem);
                removeUnresolvedAssetListOfAdGroup(adPlaybackStateWithAvailableAdMediaItem, adGroup);
            }
        }
    }

    public void setWithAvailableAdGroup(int i) {
        Preconditions.checkState(this.player != null);
        AdPlaybackState adPlaybackState = getAdPlaybackState();
        if (adPlaybackState != null) {
            Preconditions.checkArgument(i < adPlaybackState.adGroupCount);
            AdPlaybackState.AdGroup adGroup = adPlaybackState.getAdGroup(i);
            for (int i2 = 0; i2 < adGroup.states.length; i2++) {
                if ((adGroup.states[i2] == 3 || adGroup.states[i2] == 2) && adGroup.mediaItems[i2] != null) {
                    MediaItem mediaItem = adGroup.mediaItems[i2];
                    Preconditions.checkState(mediaItem != null);
                    adPlaybackState = adPlaybackState.withAvailableAdMediaItem(i, i2, mediaItem);
                }
            }
            putAndNotifyAdPlaybackStateUpdate(Preconditions.checkNotNull(adPlaybackState.adsId), adPlaybackState);
            removeUnresolvedAssetListOfAdGroup(adPlaybackState, adGroup);
        }
    }

    private void removeUnresolvedAssetListOfAdGroup(AdPlaybackState adPlaybackState, AdPlaybackState.AdGroup adGroup) {
        Preconditions.checkArgument(adPlaybackState.adsId != null);
        Map<Long, AssetListData> unresolvedAssetLists = this.contentMediaSourceAdDataHolder.getUnresolvedAssetLists(adPlaybackState.adsId);
        if (unresolvedAssetLists != null) {
            unresolvedAssetLists.remove(Long.valueOf(adGroup.timeUs == Long.MIN_VALUE ? Long.MAX_VALUE : adGroup.timeUs));
        }
    }

    private AdPlaybackState getAdPlaybackState() {
        ExoPlayer exoPlayer = this.player;
        if (exoPlayer == null) {
            return null;
        }
        Timeline currentTimeline = exoPlayer.getCurrentTimeline();
        if (currentTimeline.isEmpty()) {
            return null;
        }
        Timeline.Period period = currentTimeline.getPeriod(exoPlayer.getCurrentPeriodIndex(), new Timeline.Period());
        if (period.adPlaybackState.adsId != null) {
            return this.contentMediaSourceAdDataHolder.getAdPlaybackState(period.adPlaybackState.adsId);
        }
        return null;
    }

    @Override // androidx.media3.exoplayer.source.ads.AdsLoader
    public void start(AdsMediaSource adsMediaSource, DataSpec dataSpec, final Object obj, final AdViewProvider adViewProvider, AdsLoader.EventListener eventListener) {
        if (this.isReleased) {
            eventListener.onAdPlaybackState(new AdPlaybackState(obj, new long[0]));
            return;
        }
        if (this.contentMediaSourceAdDataHolder.isStartedContentMediaSource(obj)) {
            throw new IllegalStateException("media item with adsId='" + obj + "' already started. Make sure adsIds are unique within the same playlist.");
        }
        if (this.contentMediaSourceAdDataHolder.isIdle()) {
            ((ExoPlayer) Preconditions.checkNotNull(this.player, "setPlayer(Player) needs to be called")).addListener(this.playerListener);
        }
        this.contentMediaSourceAdDataHolder.startContentSource(obj, eventListener);
        final MediaItem mediaItem = adsMediaSource.getMediaItem();
        if (isHlsMediaItem(mediaItem)) {
            if ((obj instanceof String) && this.resumptionStates.containsKey(obj)) {
                putAndNotifyAdPlaybackStateUpdate(obj, (AdPlaybackState) Preconditions.checkNotNull(this.resumptionStates.remove(obj)));
            } else {
                this.contentMediaSourceAdDataHolder.putAdPlaybackState(obj, AdPlaybackState.NONE);
            }
            notifyListeners(new Consumer() { // from class: androidx.media3.exoplayer.hls.HlsInterstitialsAdsLoader$$ExternalSyntheticLambda3
                @Override // androidx.media3.common.util.Consumer
                public final void accept(Object obj2) {
                    ((HlsInterstitialsAdsLoader.Listener) obj2).onStart(mediaItem, obj, adViewProvider);
                }
            });
            return;
        }
        Log.w(TAG, "Unsupported media item. Playing without ads for adsId=" + obj);
        putAndNotifyAdPlaybackStateUpdate(obj, new AdPlaybackState(obj, new long[0]));
        this.contentMediaSourceAdDataHolder.addUnsupportedContentMediaSource(obj);
    }

    @Override // androidx.media3.exoplayer.source.ads.AdsLoader
    public boolean handleContentTimelineChanged(final AdsMediaSource adsMediaSource, Timeline timeline) {
        HlsInterstitialsAdsLoader hlsInterstitialsAdsLoader;
        final Timeline timeline2;
        AdPlaybackState adPlaybackStateMapInterstitialsForVod;
        final Object adsId = adsMediaSource.getAdsId();
        if (this.isReleased) {
            AdsLoader.EventListener eventListener = this.contentMediaSourceAdDataHolder.getEventListener(adsId);
            if (eventListener != null && ((AdPlaybackState) Preconditions.checkNotNull(this.contentMediaSourceAdDataHolder.stopContentSource(adsId))).equals(AdPlaybackState.NONE)) {
                eventListener.onAdPlaybackState(new AdPlaybackState(adsId, new long[0]));
            }
            return false;
        }
        AdPlaybackState adPlaybackState = (AdPlaybackState) Preconditions.checkNotNull(this.contentMediaSourceAdDataHolder.getAdPlaybackState(adsId));
        if (!adPlaybackState.equals(AdPlaybackState.NONE) && !adPlaybackState.endsWithLivePostrollPlaceHolder()) {
            return false;
        }
        if (adPlaybackState.equals(AdPlaybackState.NONE)) {
            adPlaybackState = new AdPlaybackState(adsId, new long[0]);
            if (isLiveMediaItem(adsMediaSource.getMediaItem(), timeline)) {
                adPlaybackState = adPlaybackState.withLivePostrollPlaceholderAppended(false);
            }
        }
        AdPlaybackState adPlaybackState2 = adPlaybackState;
        Timeline.Window window = timeline.getWindow(0, new Timeline.Window());
        if (window.manifest instanceof HlsManifest) {
            HlsMediaPlaylist hlsMediaPlaylist = ((HlsManifest) window.manifest).mediaPlaylist;
            int unresolvedAssetListCount = this.contentMediaSourceAdDataHolder.getUnresolvedAssetListCount(adsId);
            if (window.isLive()) {
                hlsInterstitialsAdsLoader = this;
                adPlaybackStateMapInterstitialsForVod = hlsInterstitialsAdsLoader.mapInterstitialsForLive(window.mediaItem, hlsMediaPlaylist, adPlaybackState2, window.positionInFirstPeriodUs, window.defaultPositionUs);
            } else {
                hlsInterstitialsAdsLoader = this;
                adPlaybackStateMapInterstitialsForVod = hlsInterstitialsAdsLoader.mapInterstitialsForVod(window.mediaItem, hlsMediaPlaylist, adPlaybackState2, window.durationUs, window.positionInFirstPeriodUs, window.defaultPositionUs);
            }
            AdPlaybackState adPlaybackState3 = adPlaybackStateMapInterstitialsForVod;
            ExoPlayer exoPlayer = hlsInterstitialsAdsLoader.player;
            if (unresolvedAssetListCount == hlsInterstitialsAdsLoader.contentMediaSourceAdDataHolder.getUnresolvedAssetListCount(adsId) || exoPlayer == null || !Objects.equals(window.mediaItem, exoPlayer.getCurrentMediaItem())) {
                timeline2 = timeline;
            } else {
                int currentPeriodIndex = exoPlayer.getCurrentPeriodIndex();
                long jMsToUs = Util.msToUs(exoPlayer.getContentPosition());
                Timeline.Period period = exoPlayer.getCurrentTimeline().getPeriod(currentPeriodIndex, new Timeline.Period());
                long j = -period.positionInWindowUs;
                if (period.isPlaceholder) {
                    if (jMsToUs >= window.durationUs) {
                        jMsToUs = window.durationUs - 1;
                    }
                    if (window.isLive()) {
                        jMsToUs = window.defaultPositionUs;
                    }
                    int adGroupIndexForPositionUs = adPlaybackState3.getAdGroupIndexForPositionUs(jMsToUs, window.isLive() ? C.TIME_UNSET : window.durationUs);
                    if (adGroupIndexForPositionUs != -1) {
                        jMsToUs = adPlaybackState3.getAdGroup(adGroupIndexForPositionUs).timeUs;
                    }
                    j = window.positionInFirstPeriodUs;
                }
                timeline2 = timeline;
                maybeExecuteOrSetNextAssetListResolutionMessage(adsId, timeline2, 0, j, jMsToUs);
                hlsInterstitialsAdsLoader = this;
            }
            adPlaybackState2 = adPlaybackState3;
        } else {
            hlsInterstitialsAdsLoader = this;
            timeline2 = timeline;
        }
        boolean zPutAndNotifyAdPlaybackStateUpdate = putAndNotifyAdPlaybackStateUpdate(adsId, adPlaybackState2);
        if (!hlsInterstitialsAdsLoader.contentMediaSourceAdDataHolder.isUnsupportedContentMediaSource(adsId)) {
            notifyListeners(new Consumer() { // from class: androidx.media3.exoplayer.hls.HlsInterstitialsAdsLoader$$ExternalSyntheticLambda1
                @Override // androidx.media3.common.util.Consumer
                public final void accept(Object obj) {
                    HlsInterstitialsAdsLoader.Listener listener = (HlsInterstitialsAdsLoader.Listener) obj;
                    listener.onContentTimelineChanged(adsMediaSource.getMediaItem(), adsId, timeline2);
                }
            });
        }
        return zPutAndNotifyAdPlaybackStateUpdate;
    }

    @Override // androidx.media3.exoplayer.source.ads.AdsLoader
    public void handlePrepareComplete(final AdsMediaSource adsMediaSource, final int i, final int i2) {
        final Object adsId = adsMediaSource.getAdsId();
        if (this.isReleased || this.contentMediaSourceAdDataHolder.isUnsupportedContentMediaSource(adsId)) {
            return;
        }
        notifyListeners(new Consumer() { // from class: androidx.media3.exoplayer.hls.HlsInterstitialsAdsLoader$$ExternalSyntheticLambda6
            @Override // androidx.media3.common.util.Consumer
            public final void accept(Object obj) {
                HlsInterstitialsAdsLoader.Listener listener = (HlsInterstitialsAdsLoader.Listener) obj;
                listener.onPrepareCompleted(adsMediaSource.getMediaItem(), adsId, i, i2);
            }
        });
    }

    @Override // androidx.media3.exoplayer.source.ads.AdsLoader
    public void handlePrepareError(final AdsMediaSource adsMediaSource, final int i, final int i2, final IOException iOException) {
        final Object adsId = adsMediaSource.getAdsId();
        putAndNotifyAdPlaybackStateUpdate(adsId, ((AdPlaybackState) Preconditions.checkNotNull(this.contentMediaSourceAdDataHolder.getAdPlaybackState(adsId))).withAdLoadError(i, i2));
        if (this.isReleased || this.contentMediaSourceAdDataHolder.isUnsupportedContentMediaSource(adsId)) {
            return;
        }
        notifyListeners(new Consumer() { // from class: androidx.media3.exoplayer.hls.HlsInterstitialsAdsLoader$$ExternalSyntheticLambda0
            @Override // androidx.media3.common.util.Consumer
            public final void accept(Object obj) {
                HlsInterstitialsAdsLoader.Listener listener = (HlsInterstitialsAdsLoader.Listener) obj;
                listener.onPrepareError(adsMediaSource.getMediaItem(), adsId, i, i2, iOException);
            }
        });
    }

    @Override // androidx.media3.exoplayer.source.ads.AdsLoader
    public void stop(final AdsMediaSource adsMediaSource, AdsLoader.EventListener eventListener) {
        Object adsId = adsMediaSource.getAdsId();
        Preconditions.checkState(this.contentMediaSourceAdDataHolder.isStartedContentMediaSource(adsId) || this.isReleased);
        boolean zIsUnsupportedContentMediaSource = this.contentMediaSourceAdDataHolder.isUnsupportedContentMediaSource(adsId);
        final AdPlaybackState adPlaybackStateStopContentSource = this.contentMediaSourceAdDataHolder.stopContentSource(adsId);
        ExoPlayer exoPlayer = this.player;
        if (exoPlayer != null && this.contentMediaSourceAdDataHolder.isIdle()) {
            exoPlayer.removeListener(this.playerListener);
            if (this.isReleased) {
                this.player = null;
            }
        }
        if (!this.isReleased && !zIsUnsupportedContentMediaSource) {
            if (adPlaybackStateStopContentSource != null && (adsId instanceof String) && this.resumptionStates.containsKey(adsId)) {
                this.resumptionStates.put(adsId, adPlaybackStateStopContentSource);
            }
            notifyListeners(new Consumer() { // from class: androidx.media3.exoplayer.hls.HlsInterstitialsAdsLoader$$ExternalSyntheticLambda5
                @Override // androidx.media3.common.util.Consumer
                public final void accept(Object obj) {
                    AdsMediaSource adsMediaSource2 = adsMediaSource;
                    ((HlsInterstitialsAdsLoader.Listener) obj).onStop(adsMediaSource2.getMediaItem(), adsMediaSource2.getAdsId(), (AdPlaybackState) Preconditions.checkNotNull(adPlaybackStateStopContentSource));
                }
            });
        }
        if (this.pendingAssetListResolutionMessage == null || !adsMediaSource.getMediaItem().equals(((PlayerMessage) Util.castNonNull(this.pendingAssetListResolutionMessage)).getPayload())) {
            return;
        }
        cancelPendingAssetListResolutionMessage();
    }

    @Override // androidx.media3.exoplayer.source.ads.AdsLoader
    public void release() {
        if (this.contentMediaSourceAdDataHolder.isIdle()) {
            this.player = null;
        }
        clearAllAdResumptionStates();
        cancelPendingAssetListResolutionMessage();
        Loader loader = this.loader;
        if (loader != null) {
            loader.release();
            this.loader = null;
        }
        this.isReleased = true;
    }

    public boolean isReleased() {
        return this.isReleased;
    }

    private void startLoadingAssetList(final AssetListData assetListData) {
        cancelPendingAssetListResolutionMessage();
        getLoader().startLoading(new ParsingLoadable(this.dataSourceFactory.createDataSource(), (Uri) Preconditions.checkNotNull(assetListData.interstitial.assetListUri), 6, new AssetListParser()), new LoaderCallback(assetListData), 1);
        notifyListeners(new Consumer() { // from class: androidx.media3.exoplayer.hls.HlsInterstitialsAdsLoader$$ExternalSyntheticLambda4
            @Override // androidx.media3.common.util.Consumer
            public final void accept(Object obj) {
                HlsInterstitialsAdsLoader.AssetListData assetListData2 = assetListData;
                ((HlsInterstitialsAdsLoader.Listener) obj).onAssetListLoadStarted(assetListData2.mediaItem, assetListData2.adsId, assetListData2.adGroupIndex, assetListData2.adIndexInAdGroup);
            }
        });
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void maybeExecuteOrSetNextAssetListResolutionMessage(Object obj, Timeline timeline, int i, long j, long j2) {
        long j3;
        Loader loader = this.loader;
        if (loader == null || !loader.isLoading()) {
            cancelPendingAssetListResolutionMessage();
            Timeline.Window window = timeline.getWindow(i, new Timeline.Window());
            long j4 = j2 + j;
            final RunnableAtPosition nextAssetResolution = getNextAssetResolution(obj, j4);
            if (nextAssetResolution == null) {
                return;
            }
            if (nextAssetResolution.adStartTimeUs != Long.MAX_VALUE) {
                j3 = nextAssetResolution.adStartTimeUs;
            } else {
                j3 = window.durationUs;
            }
            long jMax = Math.max(j4, j3 - (nextAssetResolution.targetDurationUs * 3));
            if (jMax - j4 < 200000) {
                nextAssetResolution.run();
                return;
            }
            long jMax2 = jMax - j;
            AdPlaybackState adPlaybackState = (AdPlaybackState) Preconditions.checkNotNull(this.contentMediaSourceAdDataHolder.getAdPlaybackState(obj));
            int adGroupIndexForPositionUs = adPlaybackState.getAdGroupIndexForPositionUs(jMax, timeline.getPeriod(0, new Timeline.Period()).durationUs);
            if (adGroupIndexForPositionUs != -1) {
                AdPlaybackState.AdGroup adGroup = adPlaybackState.getAdGroup(adGroupIndexForPositionUs);
                jMax2 = Math.max(jMax2, (adGroup.timeUs + adGroup.contentResumeOffsetUs) - j);
            }
            PlayerMessage position = ((ExoPlayer) Preconditions.checkNotNull(this.player)).createMessage(new PlayerMessage.Target() { // from class: androidx.media3.exoplayer.hls.HlsInterstitialsAdsLoader$$ExternalSyntheticLambda7
                @Override // androidx.media3.exoplayer.PlayerMessage.Target
                public final void handleMessage(int i2, Object obj2) {
                    nextAssetResolution.run();
                }
            }).setPayload(window.mediaItem).setLooper((Looper) Preconditions.checkNotNull(Looper.myLooper())).setPosition(Math.max(Util.usToMs(jMax2), 0L));
            this.pendingAssetListResolutionMessage = position;
            position.send();
        }
    }

    private RunnableAtPosition getNextAssetResolution(Object obj, long j) {
        final Map map = (Map) Preconditions.checkNotNull(this.contentMediaSourceAdDataHolder.getUnresolvedAssetLists(obj));
        for (final Long l : map.keySet()) {
            if (j <= l.longValue()) {
                final AssetListData assetListData = (AssetListData) Preconditions.checkNotNull((AssetListData) map.get(l));
                return new RunnableAtPosition(l.longValue(), assetListData.targetDurationUs, new Runnable() { // from class: androidx.media3.exoplayer.hls.HlsInterstitialsAdsLoader$$ExternalSyntheticLambda2
                    @Override // java.lang.Runnable
                    public final void run() {
                        this.f$0.m249x24977f42(map, l, assetListData);
                    }
                });
            }
        }
        return null;
    }

    /* JADX INFO: renamed from: lambda$getNextAssetResolution$7$androidx-media3-exoplayer-hls-HlsInterstitialsAdsLoader, reason: not valid java name */
    /* synthetic */ void m249x24977f42(Map map, Long l, AssetListData assetListData) {
        if (map.remove(l) != null) {
            startLoadingAssetList(assetListData);
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void cancelPendingAssetListResolutionMessage() {
        PlayerMessage playerMessage = this.pendingAssetListResolutionMessage;
        if (playerMessage != null) {
            playerMessage.cancel();
            this.pendingAssetListResolutionMessage = null;
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public long getUnresolvedAssetListWindowPositionForContentPositionUs(long j, Timeline timeline, int i) {
        int adGroupIndexForPositionUs;
        Timeline.Period period = timeline.getPeriod(i, new Timeline.Period());
        long j2 = j - period.positionInWindowUs;
        AdPlaybackState adPlaybackState = period.adPlaybackState;
        if (adPlaybackState.adsId != null && (adGroupIndexForPositionUs = adPlaybackState.getAdGroupIndexForPositionUs(j2, C.TIME_UNSET)) != -1) {
            AdPlaybackState.AdGroup adGroup = adPlaybackState.getAdGroup(adGroupIndexForPositionUs);
            Map<Long, AssetListData> unresolvedAssetLists = this.contentMediaSourceAdDataHolder.getUnresolvedAssetLists(adPlaybackState.adsId);
            if (unresolvedAssetLists != null && unresolvedAssetLists.containsKey(Long.valueOf(adGroup.timeUs))) {
                return adGroup.timeUs - timeline.getWindow(period.windowIndex, new Timeline.Window()).positionInFirstPeriodUs;
            }
        }
        return C.TIME_UNSET;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void notifyListeners(Consumer<Listener> consumer) {
        for (int i = 0; i < this.listeners.size(); i++) {
            consumer.accept(this.listeners.get(i));
        }
    }

    private Loader getLoader() {
        if (this.loader == null) {
            this.loader = new Loader("HLS-interstitials");
        }
        return this.loader;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public boolean putAndNotifyAdPlaybackStateUpdate(Object obj, AdPlaybackState adPlaybackState) {
        if (adPlaybackState.equals(this.contentMediaSourceAdDataHolder.putAdPlaybackState(obj, adPlaybackState))) {
            return false;
        }
        AdsLoader.EventListener eventListener = this.contentMediaSourceAdDataHolder.getEventListener(obj);
        if (eventListener != null) {
            eventListener.onAdPlaybackState(adPlaybackState);
            return true;
        }
        this.contentMediaSourceAdDataHolder.stopContentSource(obj);
        return false;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void notifyAssetResolutionFailed(Object obj, int i, int i2) {
        AdPlaybackState adPlaybackState = this.contentMediaSourceAdDataHolder.getAdPlaybackState(obj);
        if (adPlaybackState == null) {
            return;
        }
        putAndNotifyAdPlaybackStateUpdate(obj, adPlaybackState.withAdLoadError(i, i2));
    }

    private static boolean isLiveMediaItem(MediaItem mediaItem, Timeline timeline) {
        int firstWindowIndex = timeline.getFirstWindowIndex(false);
        Timeline.Window window = new Timeline.Window();
        while (firstWindowIndex != -1) {
            timeline.getWindow(firstWindowIndex, window);
            if (window.mediaItem.equals(mediaItem)) {
                return window.isLive();
            }
            firstWindowIndex = timeline.getNextWindowIndex(firstWindowIndex, 0, false);
        }
        return false;
    }

    private static boolean isHlsMediaItem(MediaItem mediaItem) {
        MediaItem.LocalConfiguration localConfiguration = (MediaItem.LocalConfiguration) Preconditions.checkNotNull(mediaItem.localConfiguration);
        return Objects.equals(localConfiguration.mimeType, MimeTypes.APPLICATION_M3U8) || Util.inferContentType(localConfiguration.uri) == 2;
    }

    private AdPlaybackState mapInterstitialsForLive(MediaItem mediaItem, HlsMediaPlaylist hlsMediaPlaylist, AdPlaybackState adPlaybackState, long j, long j2) {
        int i;
        AdPlaybackState adPlaybackStateInsertOrUpdateInterstitialInAdGroup = adPlaybackState;
        Object objCheckNotNull = Preconditions.checkNotNull(adPlaybackStateInsertOrUpdateInterstitialInAdGroup.adsId);
        LongSparseArray<List<HlsMediaPlaylist.Interstitial>> longSparseArrayFilterAndSortWithResolvedStartPositions = filterAndSortWithResolvedStartPositions(hlsMediaPlaylist.interstitials, objCheckNotNull, hlsMediaPlaylist, j2, true);
        int i2 = 0;
        while (i2 < longSparseArrayFilterAndSortWithResolvedStartPositions.size()) {
            long jKeyAt = longSparseArrayFilterAndSortWithResolvedStartPositions.keyAt(i2);
            List<HlsMediaPlaylist.Interstitial> list = longSparseArrayFilterAndSortWithResolvedStartPositions.get(jKeyAt);
            int i3 = 0;
            while (i3 < list.size()) {
                HlsMediaPlaylist.Interstitial interstitial = list.get(i3);
                long j3 = jKeyAt - hlsMediaPlaylist.startTimeUs;
                if (j3 >= 0) {
                    i = i2;
                    if (hlsMediaPlaylist.durationUs + (hlsMediaPlaylist.targetDurationUs * 3) >= j3) {
                        long j4 = j + j3;
                        boolean z = true;
                        int i4 = adPlaybackStateInsertOrUpdateInterstitialInAdGroup.adGroupCount - 1;
                        int i5 = adPlaybackStateInsertOrUpdateInterstitialInAdGroup.adGroupCount - 2;
                        while (true) {
                            int i6 = i5;
                            int i7 = i4;
                            i4 = i6;
                            if (i4 < adPlaybackStateInsertOrUpdateInterstitialInAdGroup.removedAdGroupCount) {
                                i4 = i7;
                                break;
                            }
                            AdPlaybackState.AdGroup adGroup = adPlaybackStateInsertOrUpdateInterstitialInAdGroup.getAdGroup(i4);
                            if (adGroup.timeUs == j4) {
                                z = false;
                                break;
                            }
                            if (adGroup.timeUs < j4) {
                                i4++;
                                break;
                            }
                            i5 = i4 - 1;
                        }
                        if (z) {
                            if (i4 < getLowestValidAdGroupInsertionIndex(adPlaybackStateInsertOrUpdateInterstitialInAdGroup)) {
                                Log.w(TAG, "Skipping insertion of interstitial attempted to be inserted behind an already initialized ad group.");
                            } else {
                                adPlaybackStateInsertOrUpdateInterstitialInAdGroup = adPlaybackStateInsertOrUpdateInterstitialInAdGroup.withNewAdGroup(i4, j4);
                            }
                        }
                        adPlaybackStateInsertOrUpdateInterstitialInAdGroup = insertOrUpdateInterstitialInAdGroup(mediaItem, interstitial, adPlaybackStateInsertOrUpdateInterstitialInAdGroup, i4, hlsMediaPlaylist.targetDurationUs);
                        this.contentMediaSourceAdDataHolder.addInsertedInterstitialId(objCheckNotNull, interstitial.id);
                    }
                } else {
                    i = i2;
                }
                i3++;
                i2 = i;
            }
            i2++;
        }
        return adPlaybackStateInsertOrUpdateInterstitialInAdGroup;
    }

    private LongSparseArray<List<HlsMediaPlaylist.Interstitial>> filterAndSortWithResolvedStartPositions(ImmutableList<HlsMediaPlaylist.Interstitial> immutableList, Object obj, HlsMediaPlaylist hlsMediaPlaylist, long j, boolean z) {
        List<HlsMediaPlaylist.Interstitial> arrayList;
        LongSparseArray<List<HlsMediaPlaylist.Interstitial>> longSparseArray = new LongSparseArray<>();
        for (int i = 0; i < immutableList.size(); i++) {
            HlsMediaPlaylist.Interstitial interstitial = immutableList.get(i);
            if (!this.contentMediaSourceAdDataHolder.isInsertedInterstitialId(obj, interstitial.id) && (!z || !interstitial.cue.contains("POST"))) {
                long jResolveInterstitialStartTimeUs = resolveInterstitialStartTimeUs(interstitial, hlsMediaPlaylist, j);
                if (longSparseArray.indexOfKey(jResolveInterstitialStartTimeUs) < 0) {
                    arrayList = new ArrayList<>();
                } else {
                    arrayList = longSparseArray.get(jResolveInterstitialStartTimeUs);
                }
                longSparseArray.put(jResolveInterstitialStartTimeUs, arrayList);
                arrayList.add(interstitial);
            }
        }
        return longSparseArray;
    }

    private AdPlaybackState mapInterstitialsForVod(MediaItem mediaItem, HlsMediaPlaylist hlsMediaPlaylist, AdPlaybackState adPlaybackState, long j, long j2, long j3) {
        AdPlaybackState adPlaybackStateWithNewAdGroup = adPlaybackState;
        Preconditions.checkArgument(adPlaybackStateWithNewAdGroup.adGroupCount == adPlaybackStateWithNewAdGroup.removedAdGroupCount);
        LongSparseArray<List<HlsMediaPlaylist.Interstitial>> longSparseArrayFilterAndSortWithResolvedStartPositions = filterAndSortWithResolvedStartPositions(hlsMediaPlaylist.interstitials, Preconditions.checkNotNull(adPlaybackStateWithNewAdGroup.adsId), hlsMediaPlaylist, j2, false);
        long j4 = hlsMediaPlaylist.startTimeUs + j2;
        long j5 = j4 + j;
        for (int i = 0; i < longSparseArrayFilterAndSortWithResolvedStartPositions.size(); i++) {
            List<HlsMediaPlaylist.Interstitial> list = longSparseArrayFilterAndSortWithResolvedStartPositions.get(longSparseArrayFilterAndSortWithResolvedStartPositions.keyAt(i));
            for (int i2 = 0; i2 < list.size(); i2++) {
                HlsMediaPlaylist.Interstitial interstitial = list.get(i2);
                long jResolveInterstitialStartTimeUs = resolveInterstitialStartTimeUs(interstitial, hlsMediaPlaylist, j3);
                if (jResolveInterstitialStartTimeUs < j4 && interstitial.cue.contains(HlsMediaPlaylist.Interstitial.CUE_TRIGGER_PRE)) {
                    jResolveInterstitialStartTimeUs = j4;
                } else if (jResolveInterstitialStartTimeUs <= j5 || !interstitial.cue.contains("POST")) {
                    if (jResolveInterstitialStartTimeUs < j4 || j5 < jResolveInterstitialStartTimeUs) {
                    }
                } else {
                    jResolveInterstitialStartTimeUs = j5;
                }
                long j6 = j5 == jResolveInterstitialStartTimeUs ? Long.MIN_VALUE : jResolveInterstitialStartTimeUs - hlsMediaPlaylist.startTimeUs;
                int adGroupIndexForPositionUs = adPlaybackStateWithNewAdGroup.getAdGroupIndexForPositionUs(j6, hlsMediaPlaylist.durationUs);
                if (adGroupIndexForPositionUs == -1) {
                    adGroupIndexForPositionUs = adPlaybackStateWithNewAdGroup.removedAdGroupCount;
                    adPlaybackStateWithNewAdGroup = adPlaybackStateWithNewAdGroup.withNewAdGroup(adPlaybackStateWithNewAdGroup.removedAdGroupCount, j6);
                } else if (adPlaybackStateWithNewAdGroup.getAdGroup(adGroupIndexForPositionUs).timeUs != j6) {
                    adGroupIndexForPositionUs++;
                    adPlaybackStateWithNewAdGroup = adPlaybackStateWithNewAdGroup.withNewAdGroup(adGroupIndexForPositionUs, j6);
                }
                adPlaybackStateWithNewAdGroup = insertOrUpdateInterstitialInAdGroup(mediaItem, interstitial, adPlaybackStateWithNewAdGroup, adGroupIndexForPositionUs, hlsMediaPlaylist.targetDurationUs);
                this.contentMediaSourceAdDataHolder.addInsertedInterstitialId(Preconditions.checkNotNull(adPlaybackStateWithNewAdGroup.adsId), interstitial.id);
            }
        }
        return adPlaybackStateWithNewAdGroup;
    }

    private AdPlaybackState insertOrUpdateInterstitialInAdGroup(MediaItem mediaItem, HlsMediaPlaylist.Interstitial interstitial, AdPlaybackState adPlaybackState, int i, long j) {
        long[] jArr;
        AdPlaybackState.AdGroup adGroup = adPlaybackState.getAdGroup(i);
        if (adGroup.getIndexOfAdId(interstitial.id) != -1) {
            return adPlaybackState;
        }
        int iMax = Math.max(adGroup.count, 0);
        long jResolveInterstitialDurationUs = resolveInterstitialDurationUs(interstitial, C.TIME_UNSET);
        if (iMax == 0) {
            jArr = new long[1];
        } else {
            long[] jArr2 = adGroup.durationsUs;
            long[] jArr3 = new long[jArr2.length + 1];
            System.arraycopy(jArr2, 0, jArr3, 0, jArr2.length);
            jArr = jArr3;
        }
        jArr[jArr.length - 1] = jResolveInterstitialDurationUs;
        if (interstitial.resumeOffsetUs != C.TIME_UNSET) {
            jResolveInterstitialDurationUs = interstitial.resumeOffsetUs;
        } else if (jResolveInterstitialDurationUs == C.TIME_UNSET) {
            jResolveInterstitialDurationUs = 0;
        }
        AdPlaybackState adPlaybackStateWithContentResumeOffsetUs = adPlaybackState.withAdCount(i, iMax + 1).withAdId(i, iMax, interstitial.id).withAdDurationsUs(i, jArr).withContentResumeOffsetUs(i, adGroup.contentResumeOffsetUs + jResolveInterstitialDurationUs);
        if (interstitial.skipControlDurationUs != C.TIME_UNSET || interstitial.skipControlOffsetUs != C.TIME_UNSET || interstitial.skipControlLabelId != null) {
            adPlaybackStateWithContentResumeOffsetUs = adPlaybackStateWithContentResumeOffsetUs.withAdSkipInfo(i, iMax, new AdPlaybackState.SkipInfo(interstitial.skipControlOffsetUs, interstitial.skipControlDurationUs, interstitial.skipControlLabelId));
        }
        AdPlaybackState adPlaybackState2 = adPlaybackStateWithContentResumeOffsetUs;
        if (interstitial.assetUri != null) {
            return adPlaybackState2.withAvailableAdMediaItem(i, iMax, new MediaItem.Builder().setUri(interstitial.assetUri).setMimeType(MimeTypes.APPLICATION_M3U8).build());
        }
        Object objCheckNotNull = Preconditions.checkNotNull(adPlaybackState2.adsId);
        ((Map) Preconditions.checkNotNull(this.contentMediaSourceAdDataHolder.getUnresolvedAssetLists(objCheckNotNull))).put(Long.valueOf(adGroup.timeUs != Long.MIN_VALUE ? adGroup.timeUs : Long.MAX_VALUE), new AssetListData(mediaItem, objCheckNotNull, interstitial, i, iMax, j));
        return adPlaybackState2;
    }

    private static int getLowestValidAdGroupInsertionIndex(AdPlaybackState adPlaybackState) {
        int i = adPlaybackState.adGroupCount;
        while (true) {
            i--;
            if (i >= adPlaybackState.removedAdGroupCount) {
                for (int i2 : adPlaybackState.getAdGroup(i).states) {
                    if (i2 != 0) {
                        return i + 1;
                    }
                }
            } else {
                return adPlaybackState.removedAdGroupCount;
            }
        }
    }

    private static long resolveInterstitialDurationUs(HlsMediaPlaylist.Interstitial interstitial, long j) {
        if (interstitial.playoutLimitUs != C.TIME_UNSET) {
            return interstitial.playoutLimitUs;
        }
        if (interstitial.durationUs != C.TIME_UNSET) {
            return interstitial.durationUs;
        }
        if (interstitial.endDateUnixUs != C.TIME_UNSET) {
            return interstitial.endDateUnixUs - interstitial.startDateUnixUs;
        }
        return interstitial.plannedDurationUs != C.TIME_UNSET ? interstitial.plannedDurationUs : j;
    }

    private static long resolveInterstitialStartTimeUs(HlsMediaPlaylist.Interstitial interstitial, HlsMediaPlaylist hlsMediaPlaylist, long j) {
        long jResolveInterstitialDurationUs;
        if (interstitial.cue.contains(HlsMediaPlaylist.Interstitial.CUE_TRIGGER_PRE)) {
            return hlsMediaPlaylist.startTimeUs + j;
        }
        if (interstitial.cue.contains("POST")) {
            return hlsMediaPlaylist.startTimeUs + hlsMediaPlaylist.durationUs;
        }
        if (interstitial.snapTypes.contains(HlsMediaPlaylist.Interstitial.SNAP_TYPE_OUT)) {
            return getClosestSegmentBoundaryUs(interstitial.startDateUnixUs, hlsMediaPlaylist);
        }
        if (interstitial.snapTypes.contains(HlsMediaPlaylist.Interstitial.SNAP_TYPE_IN)) {
            if (interstitial.resumeOffsetUs != C.TIME_UNSET) {
                jResolveInterstitialDurationUs = interstitial.resumeOffsetUs;
            } else {
                jResolveInterstitialDurationUs = resolveInterstitialDurationUs(interstitial, 0L);
            }
            return getClosestSegmentBoundaryUs(interstitial.startDateUnixUs + jResolveInterstitialDurationUs, hlsMediaPlaylist) - jResolveInterstitialDurationUs;
        }
        return interstitial.startDateUnixUs;
    }

    static long getClosestSegmentBoundaryUs(long j, HlsMediaPlaylist hlsMediaPlaylist) {
        long j2;
        long j3;
        long j4 = j - hlsMediaPlaylist.startTimeUs;
        if (j4 <= 0 || hlsMediaPlaylist.segments.isEmpty()) {
            return hlsMediaPlaylist.startTimeUs;
        }
        if (j4 >= hlsMediaPlaylist.durationUs) {
            j2 = hlsMediaPlaylist.startTimeUs;
            j3 = hlsMediaPlaylist.durationUs;
        } else {
            int size = hlsMediaPlaylist.segments.size() - 1;
            int i = 0;
            int i2 = 0;
            while (i <= size) {
                i2 = ((size - i) / 2) + i;
                HlsMediaPlaylist.Segment segment = hlsMediaPlaylist.segments.get(i2);
                long j5 = segment.relativeStartTimeUs;
                long j6 = segment.durationUs + j5;
                if (j4 >= j5 && j4 <= j6) {
                    break;
                }
                if (j4 < j5) {
                    size = i2 - 1;
                } else {
                    i = i2 + 1;
                }
            }
            HlsMediaPlaylist.Segment segment2 = hlsMediaPlaylist.segments.get(i2);
            if (j4 - segment2.relativeStartTimeUs < Math.abs(j4 - (segment2.relativeStartTimeUs + segment2.durationUs))) {
                j2 = hlsMediaPlaylist.startTimeUs;
                j3 = segment2.relativeStartTimeUs;
            } else {
                j2 = hlsMediaPlaylist.startTimeUs + segment2.relativeStartTimeUs;
                j3 = segment2.durationUs;
            }
        }
        return j2 + j3;
    }

    /* JADX INFO: Access modifiers changed from: private */
    class PlayerListener implements Player.Listener {
        private final Timeline.Period period;

        private PlayerListener() {
            this.period = new Timeline.Period();
        }

        @Override // androidx.media3.common.Player.Listener
        public void onMetadata(final Metadata metadata) {
            ExoPlayer exoPlayer = HlsInterstitialsAdsLoader.this.player;
            if (exoPlayer == null || !exoPlayer.isPlayingAd()) {
                return;
            }
            exoPlayer.getCurrentTimeline().getPeriod(exoPlayer.getCurrentPeriodIndex(), this.period);
            final Object obj = this.period.adPlaybackState.adsId;
            if (obj == null || !HlsInterstitialsAdsLoader.this.contentMediaSourceAdDataHolder.isManagedContentSource(obj)) {
                return;
            }
            final MediaItem mediaItem = (MediaItem) Preconditions.checkNotNull(exoPlayer.getCurrentMediaItem());
            final int currentAdGroupIndex = exoPlayer.getCurrentAdGroupIndex();
            final int currentAdIndexInAdGroup = exoPlayer.getCurrentAdIndexInAdGroup();
            HlsInterstitialsAdsLoader.this.notifyListeners(new Consumer() { // from class: androidx.media3.exoplayer.hls.HlsInterstitialsAdsLoader$PlayerListener$$ExternalSyntheticLambda5
                @Override // androidx.media3.common.util.Consumer
                public final void accept(Object obj2) {
                    ((HlsInterstitialsAdsLoader.Listener) obj2).onMetadata(mediaItem, obj, currentAdGroupIndex, currentAdIndexInAdGroup, metadata);
                }
            });
        }

        @Override // androidx.media3.common.Player.Listener
        public void onTimelineChanged(Timeline timeline, int i) {
            if (timeline.isEmpty()) {
                HlsInterstitialsAdsLoader.this.cancelPendingAssetListResolutionMessage();
            }
        }

        @Override // androidx.media3.common.Player.Listener
        public void onPositionDiscontinuity(final Player.PositionInfo positionInfo, final Player.PositionInfo positionInfo2, int i) {
            if (HlsInterstitialsAdsLoader.this.player == null || positionInfo.mediaItem == null || positionInfo2.mediaItem == null || i == 4 || i == 6 || i == 5) {
                HlsInterstitialsAdsLoader.this.cancelPendingAssetListResolutionMessage();
                return;
            }
            Timeline currentTimeline = HlsInterstitialsAdsLoader.this.player.getCurrentTimeline();
            currentTimeline.getPeriod(positionInfo2.periodIndex, this.period);
            final Object obj = this.period.adPlaybackState.adsId;
            if (obj == null || !HlsInterstitialsAdsLoader.this.contentMediaSourceAdDataHolder.isManagedContentSource(obj)) {
                HlsInterstitialsAdsLoader.this.cancelPendingAssetListResolutionMessage();
                return;
            }
            if (i == 0) {
                if (positionInfo.adGroupIndex != -1) {
                    markAdAsPlayedAndNotifyListeners(positionInfo.mediaItem, obj, positionInfo.adGroupIndex, positionInfo.adIndexInAdGroup);
                }
                if (positionInfo2.adIndexInAdGroup != -1) {
                    HlsInterstitialsAdsLoader.this.contentMediaSourceAdDataHolder.notifyAdStarted(obj);
                    HlsInterstitialsAdsLoader.this.notifyListeners(new Consumer() { // from class: androidx.media3.exoplayer.hls.HlsInterstitialsAdsLoader$PlayerListener$$ExternalSyntheticLambda0
                        @Override // androidx.media3.common.util.Consumer
                        public final void accept(Object obj2) {
                            Player.PositionInfo positionInfo3 = positionInfo2;
                            ((HlsInterstitialsAdsLoader.Listener) obj2).onAdStarted((MediaItem) Preconditions.checkNotNull(positionInfo3.mediaItem), obj, positionInfo3.adGroupIndex, positionInfo3.adIndexInAdGroup);
                        }
                    });
                    return;
                }
                return;
            }
            if (i == 1 || i == 2) {
                long jMsToUs = Util.msToUs(positionInfo2.contentPositionMs);
                long unresolvedAssetListWindowPositionForContentPositionUs = HlsInterstitialsAdsLoader.this.getUnresolvedAssetListWindowPositionForContentPositionUs(jMsToUs, currentTimeline, positionInfo2.periodIndex);
                HlsInterstitialsAdsLoader.this.maybeExecuteOrSetNextAssetListResolutionMessage(obj, currentTimeline, positionInfo2.mediaItemIndex, -this.period.positionInWindowUs, unresolvedAssetListWindowPositionForContentPositionUs != C.TIME_UNSET ? unresolvedAssetListWindowPositionForContentPositionUs : jMsToUs);
                if (positionInfo.adIndexInAdGroup != -1 || positionInfo2.adIndexInAdGroup == -1) {
                    return;
                }
                HlsInterstitialsAdsLoader.this.notifyListeners(new Consumer() { // from class: androidx.media3.exoplayer.hls.HlsInterstitialsAdsLoader$PlayerListener$$ExternalSyntheticLambda1
                    @Override // androidx.media3.common.util.Consumer
                    public final void accept(Object obj2) {
                        Player.PositionInfo positionInfo3 = positionInfo2;
                        ((HlsInterstitialsAdsLoader.Listener) obj2).onAdStarted((MediaItem) Preconditions.checkNotNull(positionInfo3.mediaItem), obj, positionInfo3.adGroupIndex, positionInfo3.adIndexInAdGroup);
                    }
                });
                return;
            }
            if (positionInfo.adGroupIndex == -1 || i != 3) {
                return;
            }
            HlsInterstitialsAdsLoader.this.notifyListeners(new Consumer() { // from class: androidx.media3.exoplayer.hls.HlsInterstitialsAdsLoader$PlayerListener$$ExternalSyntheticLambda2
                @Override // androidx.media3.common.util.Consumer
                public final void accept(Object obj2) {
                    Player.PositionInfo positionInfo3 = positionInfo;
                    ((HlsInterstitialsAdsLoader.Listener) obj2).onAdSkipped((MediaItem) Preconditions.checkNotNull(positionInfo3.mediaItem), obj, positionInfo3.adGroupIndex, positionInfo3.adIndexInAdGroup);
                }
            });
        }

        @Override // androidx.media3.common.Player.Listener
        public void onPlaybackStateChanged(int i) {
            final ExoPlayer exoPlayer = HlsInterstitialsAdsLoader.this.player;
            if (i == 3 && exoPlayer != null && exoPlayer.isPlayingAd()) {
                exoPlayer.getCurrentTimeline().getPeriod(exoPlayer.getCurrentPeriodIndex(), this.period);
                final Object obj = this.period.adPlaybackState.adsId;
                if (obj == null || !HlsInterstitialsAdsLoader.this.contentMediaSourceAdDataHolder.awaitingFirstAdToStartFor(obj)) {
                    return;
                }
                HlsInterstitialsAdsLoader.this.contentMediaSourceAdDataHolder.notifyAdStarted(obj);
                HlsInterstitialsAdsLoader.this.notifyListeners(new Consumer() { // from class: androidx.media3.exoplayer.hls.HlsInterstitialsAdsLoader$PlayerListener$$ExternalSyntheticLambda3
                    @Override // androidx.media3.common.util.Consumer
                    public final void accept(Object obj2) {
                        Player player = exoPlayer;
                        ((HlsInterstitialsAdsLoader.Listener) obj2).onAdStarted((MediaItem) Preconditions.checkNotNull(player.getCurrentMediaItem()), obj, player.getCurrentAdGroupIndex(), player.getCurrentAdIndexInAdGroup());
                    }
                });
            }
        }

        private void markAdAsPlayedAndNotifyListeners(final MediaItem mediaItem, final Object obj, final int i, final int i2) {
            AdPlaybackState adPlaybackState = HlsInterstitialsAdsLoader.this.contentMediaSourceAdDataHolder.getAdPlaybackState(obj);
            if (adPlaybackState == null || adPlaybackState.getAdGroup(i).states[i2] != 1) {
                return;
            }
            HlsInterstitialsAdsLoader.this.putAndNotifyAdPlaybackStateUpdate(obj, adPlaybackState.withPlayedAd(i, i2));
            HlsInterstitialsAdsLoader.this.notifyListeners(new Consumer() { // from class: androidx.media3.exoplayer.hls.HlsInterstitialsAdsLoader$PlayerListener$$ExternalSyntheticLambda4
                @Override // androidx.media3.common.util.Consumer
                public final void accept(Object obj2) {
                    ((HlsInterstitialsAdsLoader.Listener) obj2).onAdCompleted(mediaItem, obj, i, i2);
                }
            });
        }
    }

    private static final class ContentMediaSourceAdDataHolder {
        private final Map<Object, AdsLoader.EventListener> activeEventListeners = new HashMap();
        private final Map<Object, AdPlaybackState> activeAdPlaybackStates = new HashMap();
        private final Map<Object, Set<String>> insertedInterstitialIds = new HashMap();
        private final Map<Object, TreeMap<Long, AssetListData>> unresolvedAssetLists = new HashMap();
        private final Set<Object> contentSourceAwaitingFirstAdToStart = new HashSet();
        private final Set<Object> unsupportedAdsIds = new HashSet();

        public boolean isIdle() {
            return this.activeEventListeners.isEmpty();
        }

        public AdsLoader.EventListener startContentSource(Object obj, AdsLoader.EventListener eventListener) {
            this.insertedInterstitialIds.put(obj, new HashSet());
            this.unresolvedAssetLists.put(obj, new TreeMap<>());
            this.contentSourceAwaitingFirstAdToStart.add(obj);
            return this.activeEventListeners.put(obj, eventListener);
        }

        public void notifyAdStarted(Object obj) {
            this.contentSourceAwaitingFirstAdToStart.remove(obj);
        }

        public boolean awaitingFirstAdToStartFor(Object obj) {
            return this.contentSourceAwaitingFirstAdToStart.contains(obj);
        }

        public boolean isStartedContentMediaSource(Object obj) {
            return this.activeEventListeners.containsKey(obj);
        }

        public boolean isManagedContentSource(Object obj) {
            return this.activeAdPlaybackStates.containsKey(obj);
        }

        public AdsLoader.EventListener getEventListener(Object obj) {
            return this.activeEventListeners.get(obj);
        }

        public void addUnsupportedContentMediaSource(Object obj) {
            this.unsupportedAdsIds.add(obj);
        }

        public boolean isUnsupportedContentMediaSource(Object obj) {
            return this.unsupportedAdsIds.contains(obj);
        }

        public AdPlaybackState putAdPlaybackState(Object obj, AdPlaybackState adPlaybackState) {
            return this.activeAdPlaybackStates.put(obj, adPlaybackState);
        }

        public AdPlaybackState getAdPlaybackState(Object obj) {
            return this.activeAdPlaybackStates.get(obj);
        }

        public Collection<AdPlaybackState> getAdPlaybackStates() {
            return this.activeAdPlaybackStates.values();
        }

        public void addInsertedInterstitialId(Object obj, String str) {
            Set<String> set = this.insertedInterstitialIds.get(obj);
            if (set != null) {
                set.add(str);
            }
        }

        public boolean isInsertedInterstitialId(Object obj, String str) {
            Set<String> set = this.insertedInterstitialIds.get(obj);
            return set != null && set.contains(str);
        }

        public Map<Long, AssetListData> getUnresolvedAssetLists(Object obj) {
            return this.unresolvedAssetLists.get(obj);
        }

        public int getUnresolvedAssetListCount(Object obj) {
            TreeMap<Long, AssetListData> treeMap = this.unresolvedAssetLists.get(obj);
            if (treeMap != null) {
                return treeMap.size();
            }
            return 0;
        }

        public AdPlaybackState stopContentSource(Object obj) {
            this.activeEventListeners.remove(obj);
            this.insertedInterstitialIds.remove(obj);
            this.unresolvedAssetLists.remove(obj);
            this.unsupportedAdsIds.remove(obj);
            this.contentSourceAwaitingFirstAdToStart.remove(obj);
            return this.activeAdPlaybackStates.remove(obj);
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    class LoaderCallback implements Loader.Callback<ParsingLoadable<Pair<AssetList, JSONObject>>> {
        private final AssetListData assetListData;
        private final Timeline.Window window = new Timeline.Window();

        public LoaderCallback(AssetListData assetListData) {
            this.assetListData = assetListData;
        }

        @Override // androidx.media3.exoplayer.upstream.Loader.Callback
        public void onLoadCompleted(ParsingLoadable<Pair<AssetList, JSONObject>> parsingLoadable, long j, long j2) {
            final Pair pair = (Pair) Preconditions.checkNotNull(parsingLoadable.getResult());
            final AssetList assetList = (AssetList) pair.first;
            AdPlaybackState adPlaybackState = HlsInterstitialsAdsLoader.this.contentMediaSourceAdDataHolder.getAdPlaybackState(this.assetListData.adsId);
            if ((adPlaybackState != null ? adPlaybackState.getAdGroup(this.assetListData.adGroupIndex).states[this.assetListData.adIndexInAdGroup] : 4) != 0) {
                maybeContinueAssetResolution();
                HlsInterstitialsAdsLoader.this.notifyListeners(new Consumer() { // from class: androidx.media3.exoplayer.hls.HlsInterstitialsAdsLoader$LoaderCallback$$ExternalSyntheticLambda1
                    @Override // androidx.media3.common.util.Consumer
                    public final void accept(Object obj) {
                        this.f$0.m251x4e88d248((HlsInterstitialsAdsLoader.Listener) obj);
                    }
                });
                return;
            }
            int i = 0;
            if (assetList == null || assetList.assets.isEmpty()) {
                handleAssetResolutionFailed(new IOException("empty asset list"), false);
                return;
            }
            AdPlaybackState.AdGroup adGroup = ((AdPlaybackState) Preconditions.checkNotNull(adPlaybackState)).getAdGroup(this.assetListData.adGroupIndex);
            long j3 = adGroup.durationsUs[this.assetListData.adIndexInAdGroup];
            long j4 = C.TIME_UNSET;
            long j5 = 0;
            long j6 = j3 != C.TIME_UNSET ? adGroup.durationsUs[this.assetListData.adIndexInAdGroup] : 0L;
            int i2 = adGroup.count;
            if (assetList.assets.size() > 1) {
                adPlaybackState = adPlaybackState.withAdCount(this.assetListData.adGroupIndex, (assetList.assets.size() + i2) - 1);
                adGroup = adPlaybackState.getAdGroup(this.assetListData.adGroupIndex);
            }
            int i3 = this.assetListData.adIndexInAdGroup;
            long[] jArr = (long[]) adGroup.durationsUs.clone();
            while (i < assetList.assets.size()) {
                Asset asset = assetList.assets.get(i);
                if (i > 0) {
                    i3 = (i2 + i) - 1;
                }
                long j7 = j4;
                jArr[i3] = asset.durationUs;
                j5 += asset.durationUs;
                adPlaybackState = adPlaybackState.withAvailableAdMediaItem(this.assetListData.adGroupIndex, i3, new MediaItem.Builder().setUri(asset.uri).setMimeType(MimeTypes.APPLICATION_M3U8).build());
                if (assetList.skipInfo != null) {
                    adPlaybackState = adPlaybackState.withAdSkipInfo(this.assetListData.adGroupIndex, i3, assetList.skipInfo);
                }
                i++;
                j4 = j7;
            }
            long j8 = j4;
            AdPlaybackState adPlaybackStateWithAdDurationsUs = adPlaybackState.withAdDurationsUs(this.assetListData.adGroupIndex, jArr);
            if (this.assetListData.interstitial.resumeOffsetUs == j8) {
                adPlaybackStateWithAdDurationsUs = adPlaybackStateWithAdDurationsUs.withContentResumeOffsetUs(this.assetListData.adGroupIndex, (adPlaybackStateWithAdDurationsUs.getAdGroup(this.assetListData.adGroupIndex).contentResumeOffsetUs - j6) + j5);
            }
            HlsInterstitialsAdsLoader.this.putAndNotifyAdPlaybackStateUpdate(this.assetListData.adsId, adPlaybackStateWithAdDurationsUs);
            HlsInterstitialsAdsLoader.this.notifyListeners(new Consumer() { // from class: androidx.media3.exoplayer.hls.HlsInterstitialsAdsLoader$LoaderCallback$$ExternalSyntheticLambda2
                @Override // androidx.media3.common.util.Consumer
                public final void accept(Object obj) {
                    this.f$0.m252xd0d38727(assetList, pair, (HlsInterstitialsAdsLoader.Listener) obj);
                }
            });
            maybeContinueAssetResolution();
        }

        /* JADX INFO: renamed from: lambda$onLoadCompleted$0$androidx-media3-exoplayer-hls-HlsInterstitialsAdsLoader$LoaderCallback, reason: not valid java name */
        /* synthetic */ void m251x4e88d248(Listener listener) {
            listener.onAssetListLoadFailed(this.assetListData.mediaItem, this.assetListData.adsId, this.assetListData.adGroupIndex, this.assetListData.adIndexInAdGroup, null, true);
        }

        /* JADX INFO: renamed from: lambda$onLoadCompleted$1$androidx-media3-exoplayer-hls-HlsInterstitialsAdsLoader$LoaderCallback, reason: not valid java name */
        /* synthetic */ void m252xd0d38727(AssetList assetList, Pair pair, Listener listener) {
            listener.onAssetListLoadCompleted(this.assetListData.mediaItem, this.assetListData.adsId, this.assetListData.adGroupIndex, this.assetListData.adIndexInAdGroup, assetList, (JSONObject) pair.second);
        }

        @Override // androidx.media3.exoplayer.upstream.Loader.Callback
        public void onLoadCanceled(ParsingLoadable<Pair<AssetList, JSONObject>> parsingLoadable, long j, long j2, boolean z) {
            handleAssetResolutionFailed(null, true);
        }

        @Override // androidx.media3.exoplayer.upstream.Loader.Callback
        public Loader.LoadErrorAction onLoadError(ParsingLoadable<Pair<AssetList, JSONObject>> parsingLoadable, long j, long j2, IOException iOException, int i) {
            handleAssetResolutionFailed(iOException, false);
            return Loader.DONT_RETRY;
        }

        private void handleAssetResolutionFailed(final IOException iOException, final boolean z) {
            HlsInterstitialsAdsLoader.this.notifyAssetResolutionFailed(this.assetListData.adsId, this.assetListData.adGroupIndex, this.assetListData.adIndexInAdGroup);
            HlsInterstitialsAdsLoader.this.notifyListeners(new Consumer() { // from class: androidx.media3.exoplayer.hls.HlsInterstitialsAdsLoader$LoaderCallback$$ExternalSyntheticLambda0
                @Override // androidx.media3.common.util.Consumer
                public final void accept(Object obj) {
                    this.f$0.m250xdc927f7b(iOException, z, (HlsInterstitialsAdsLoader.Listener) obj);
                }
            });
            maybeContinueAssetResolution();
        }

        /* JADX INFO: renamed from: lambda$handleAssetResolutionFailed$2$androidx-media3-exoplayer-hls-HlsInterstitialsAdsLoader$LoaderCallback, reason: not valid java name */
        /* synthetic */ void m250xdc927f7b(IOException iOException, boolean z, Listener listener) {
            listener.onAssetListLoadFailed(this.assetListData.mediaItem, this.assetListData.adsId, this.assetListData.adGroupIndex, this.assetListData.adIndexInAdGroup, iOException, z);
        }

        private void maybeContinueAssetResolution() {
            ExoPlayer exoPlayer = HlsInterstitialsAdsLoader.this.player;
            if (exoPlayer == null || exoPlayer.getPlaybackState() == 1 || !this.assetListData.mediaItem.equals(exoPlayer.getCurrentMediaItem())) {
                return;
            }
            long jMsToUs = Util.msToUs(exoPlayer.getContentPosition());
            Timeline currentTimeline = exoPlayer.getCurrentTimeline();
            int currentMediaItemIndex = exoPlayer.getCurrentMediaItemIndex();
            HlsInterstitialsAdsLoader.this.maybeExecuteOrSetNextAssetListResolutionMessage(this.assetListData.adsId, currentTimeline, currentMediaItemIndex, currentTimeline.getWindow(currentMediaItemIndex, this.window).positionInFirstPeriodUs, jMsToUs);
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    static class RunnableAtPosition implements Runnable {
        public final long adStartTimeUs;
        private final Runnable runnable;
        private final long targetDurationUs;

        public RunnableAtPosition(long j, long j2, Runnable runnable) {
            this.adStartTimeUs = j;
            this.targetDurationUs = j2;
            this.runnable = runnable;
        }

        @Override // java.lang.Runnable
        public void run() {
            this.runnable.run();
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    static class AssetListData {
        private final int adGroupIndex;
        private final int adIndexInAdGroup;
        private final Object adsId;
        private final HlsMediaPlaylist.Interstitial interstitial;
        private final MediaItem mediaItem;
        private final long targetDurationUs;

        public AssetListData(MediaItem mediaItem, Object obj, HlsMediaPlaylist.Interstitial interstitial, int i, int i2, long j) {
            Preconditions.checkArgument(interstitial.assetListUri != null);
            this.mediaItem = mediaItem;
            this.adsId = obj;
            this.adGroupIndex = i;
            this.adIndexInAdGroup = i2;
            this.targetDurationUs = j;
            this.interstitial = interstitial;
        }

        public boolean equals(Object obj) {
            if (!(obj instanceof AssetListData)) {
                return false;
            }
            AssetListData assetListData = (AssetListData) obj;
            return this.adGroupIndex == assetListData.adGroupIndex && this.adIndexInAdGroup == assetListData.adIndexInAdGroup && this.targetDurationUs == assetListData.targetDurationUs && Objects.equals(this.mediaItem, assetListData.mediaItem) && Objects.equals(this.adsId, assetListData.adsId) && Objects.equals(this.interstitial, assetListData.interstitial);
        }

        public int hashCode() {
            return (int) ((((long) ((((((((this.mediaItem.hashCode() * 31) + this.adsId.hashCode()) * 31) + this.interstitial.hashCode()) * 31) + this.adGroupIndex) * 31) + this.adIndexInAdGroup)) * 31) + this.targetDurationUs);
        }
    }
}
