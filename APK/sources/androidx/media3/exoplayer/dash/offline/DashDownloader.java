package androidx.media3.exoplayer.dash.offline;

import androidx.credentials.CredentialManager$$ExternalSyntheticLambda0;
import androidx.media3.common.C;
import androidx.media3.common.MediaItem;
import androidx.media3.common.util.RunnableFutureTask;
import androidx.media3.common.util.Util;
import androidx.media3.datasource.DataSource;
import androidx.media3.datasource.cache.CacheDataSource;
import androidx.media3.exoplayer.dash.BaseUrlExclusionList;
import androidx.media3.exoplayer.dash.DashSegmentIndex;
import androidx.media3.exoplayer.dash.DashUtil;
import androidx.media3.exoplayer.dash.DashWrappingSegmentIndex;
import androidx.media3.exoplayer.dash.manifest.AdaptationSet;
import androidx.media3.exoplayer.dash.manifest.BaseUrl;
import androidx.media3.exoplayer.dash.manifest.DashManifest;
import androidx.media3.exoplayer.dash.manifest.DashManifestParser;
import androidx.media3.exoplayer.dash.manifest.Period;
import androidx.media3.exoplayer.dash.manifest.RangedUri;
import androidx.media3.exoplayer.dash.manifest.Representation;
import androidx.media3.exoplayer.offline.DownloadException;
import androidx.media3.exoplayer.offline.SegmentDownloader;
import androidx.media3.exoplayer.upstream.ParsingLoadable;
import androidx.media3.extractor.ChunkIndex;
import com.google.common.base.Supplier;
import com.google.common.collect.ImmutableMap;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.Executor;

/* JADX INFO: loaded from: classes.dex */
public final class DashDownloader extends SegmentDownloader<DashManifest> {
    private final BaseUrlExclusionList baseUrlExclusionList;

    public static final class Factory extends SegmentDownloader.BaseFactory<DashManifest> {
        public Factory(CacheDataSource.Factory factory) {
            super(factory, new DashManifestParser());
        }

        public Factory setManifestParser(DashManifestParser dashManifestParser) {
            this.manifestParser = dashManifestParser;
            return this;
        }

        @Override // androidx.media3.exoplayer.offline.SegmentDownloader.BaseFactory, androidx.media3.exoplayer.offline.SegmentDownloaderFactory
        public Factory setExecutor(Executor executor) {
            super.setExecutor(executor);
            return this;
        }

        @Override // androidx.media3.exoplayer.offline.SegmentDownloader.BaseFactory, androidx.media3.exoplayer.offline.SegmentDownloaderFactory
        public Factory setMaxMergedSegmentStartTimeDiffMs(long j) {
            super.setMaxMergedSegmentStartTimeDiffMs(j);
            return this;
        }

        @Override // androidx.media3.exoplayer.offline.SegmentDownloader.BaseFactory, androidx.media3.exoplayer.offline.SegmentDownloaderFactory
        public Factory setStartPositionUs(long j) {
            super.setStartPositionUs(j);
            return this;
        }

        @Override // androidx.media3.exoplayer.offline.SegmentDownloader.BaseFactory, androidx.media3.exoplayer.offline.SegmentDownloaderFactory
        public Factory setDurationUs(long j) {
            super.setDurationUs(j);
            return this;
        }

        @Override // androidx.media3.exoplayer.offline.SegmentDownloaderFactory
        public DashDownloader create(MediaItem mediaItem) {
            return new DashDownloader(mediaItem, this.manifestParser, this.cacheDataSourceFactory, this.executor, this.maxMergedSegmentStartTimeDiffMs, this.startPositionUs, this.durationUs);
        }
    }

    @Deprecated
    public DashDownloader(MediaItem mediaItem, CacheDataSource.Factory factory) {
        this(mediaItem, factory, new CredentialManager$$ExternalSyntheticLambda0());
    }

    @Deprecated
    public DashDownloader(MediaItem mediaItem, CacheDataSource.Factory factory, Executor executor) {
        this(mediaItem, new DashManifestParser(), factory, executor, 20000L, 0L, C.TIME_UNSET);
    }

    private DashDownloader(MediaItem mediaItem, ParsingLoadable.Parser<DashManifest> parser, CacheDataSource.Factory factory, Executor executor, long j, long j2, long j3) {
        super(mediaItem, parser, factory, executor, j, j2, j3);
        this.baseUrlExclusionList = new BaseUrlExclusionList();
    }

    /* JADX INFO: Access modifiers changed from: protected */
    @Override // androidx.media3.exoplayer.offline.SegmentDownloader
    public List<SegmentDownloader.Segment> getSegments(DataSource dataSource, DashManifest dashManifest, boolean z) throws InterruptedException, IOException {
        int i;
        DashDownloader dashDownloader = this;
        ArrayList<SegmentDownloader.Segment> arrayList = new ArrayList<>();
        int i2 = 0;
        while (i2 < dashManifest.getPeriodCount()) {
            Period period = dashManifest.getPeriod(i2);
            long jMsToUs = Util.msToUs(period.startMs);
            long periodDurationUs = dashManifest.getPeriodDurationUs(i2);
            if (periodDurationUs != C.TIME_UNSET) {
                i = i2;
                if (jMsToUs + periodDurationUs <= dashDownloader.startPositionUs) {
                    continue;
                }
                i2 = i + 1;
                dashDownloader = this;
            } else {
                i = i2;
            }
            if (dashDownloader.durationUs != C.TIME_UNSET && jMsToUs >= dashDownloader.startPositionUs + dashDownloader.durationUs) {
                break;
            }
            List<AdaptationSet> list = period.adaptationSets;
            int i3 = 0;
            while (i3 < list.size()) {
                dashDownloader.addSegmentsForAdaptationSet(dataSource, list.get(i3), jMsToUs, periodDurationUs, z, arrayList);
                i3++;
                dashDownloader = this;
            }
            i2 = i + 1;
            dashDownloader = this;
        }
        return arrayList;
    }

    private void addSegmentsForAdaptationSet(DataSource dataSource, AdaptationSet adaptationSet, long j, long j2, boolean z, ArrayList<SegmentDownloader.Segment> arrayList) throws InterruptedException, IOException {
        long firstSegmentNum;
        long firstSegmentNum2;
        DashDownloader dashDownloader = this;
        int i = 0;
        while (i < adaptationSet.representations.size()) {
            Representation representation = adaptationSet.representations.get(i);
            try {
                try {
                    DashSegmentIndex segmentIndex = dashDownloader.getSegmentIndex(dataSource, adaptationSet.type, representation, z);
                    if (segmentIndex == null) {
                        throw new DownloadException("Missing segment index");
                    }
                    long segmentCount = segmentIndex.getSegmentCount(j2);
                    if (segmentCount == -1) {
                        throw new DownloadException("Unbounded segment index");
                    }
                    String str = ((BaseUrl) Util.castNonNull(dashDownloader.baseUrlExclusionList.selectBaseUrl(representation.baseUrls))).url;
                    RangedUri initializationUri = representation.getInitializationUri();
                    if (initializationUri != null) {
                        arrayList.add(dashDownloader.createSegment(representation, str, j, initializationUri));
                    }
                    RangedUri indexUri = representation.getIndexUri();
                    DashDownloader dashDownloader2 = this;
                    if (indexUri != null) {
                        arrayList.add(dashDownloader2.createSegment(representation, str, j, indexUri));
                    }
                    long j3 = dashDownloader2.startPositionUs - j;
                    Representation representation2 = representation;
                    String str2 = str;
                    long j4 = dashDownloader2.durationUs != C.TIME_UNSET ? dashDownloader2.durationUs + j3 : -9223372036854775807L;
                    if (z || j3 <= 0) {
                        firstSegmentNum = segmentIndex.getFirstSegmentNum();
                    } else {
                        firstSegmentNum = segmentIndex.getSegmentNum(j3, j2);
                    }
                    if (j4 == C.TIME_UNSET || z || j4 >= j + j2) {
                        firstSegmentNum2 = (segmentIndex.getFirstSegmentNum() + segmentCount) - 1;
                    } else {
                        firstSegmentNum2 = segmentIndex.getSegmentNum(j4, j2);
                    }
                    long j5 = firstSegmentNum2;
                    while (true) {
                        long j6 = firstSegmentNum;
                        if (j6 <= j5) {
                            Representation representation3 = representation2;
                            String str3 = str2;
                            arrayList.add(dashDownloader2.createSegment(representation3, str3, j + segmentIndex.getTimeUs(j6), segmentIndex.getSegmentUrl(j6)));
                            firstSegmentNum = j6 + 1;
                            dashDownloader2 = this;
                            representation2 = representation3;
                            str2 = str3;
                        }
                    }
                } catch (IOException e) {
                    e = e;
                    if (!z) {
                        throw e;
                    }
                }
            } catch (IOException e2) {
                e = e2;
            }
            i++;
            dashDownloader = this;
        }
    }

    private SegmentDownloader.Segment createSegment(Representation representation, String str, long j, RangedUri rangedUri) {
        return new SegmentDownloader.Segment(j, DashUtil.buildDataSpec(representation, str, rangedUri, 0, ImmutableMap.of()));
    }

    private DashSegmentIndex getSegmentIndex(final DataSource dataSource, final int i, final Representation representation, boolean z) throws InterruptedException, IOException {
        DashSegmentIndex index = representation.getIndex();
        if (index != null) {
            return index;
        }
        ChunkIndex chunkIndex = (ChunkIndex) execute(new Supplier() { // from class: androidx.media3.exoplayer.dash.offline.DashDownloader$$ExternalSyntheticLambda0
            @Override // com.google.common.base.Supplier
            public final Object get() {
                return this.f$0.m232xb9078c42(dataSource, i, representation);
            }
        }, z);
        if (chunkIndex == null) {
            return null;
        }
        return new DashWrappingSegmentIndex(chunkIndex, representation.presentationTimeOffsetUs);
    }

    /* JADX INFO: renamed from: lambda$getSegmentIndex$0$androidx-media3-exoplayer-dash-offline-DashDownloader, reason: not valid java name */
    /* synthetic */ RunnableFutureTask m232xb9078c42(final DataSource dataSource, final int i, final Representation representation) {
        return new RunnableFutureTask<ChunkIndex, IOException>() { // from class: androidx.media3.exoplayer.dash.offline.DashDownloader.1
            /* JADX INFO: Access modifiers changed from: protected */
            /* JADX WARN: Can't rename method to resolve collision */
            @Override // androidx.media3.common.util.RunnableFutureTask
            public ChunkIndex doWork() throws IOException {
                return DashUtil.loadChunkIndex(dataSource, i, representation);
            }
        };
    }
}
