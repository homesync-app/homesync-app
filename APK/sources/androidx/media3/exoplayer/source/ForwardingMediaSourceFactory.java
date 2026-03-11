package androidx.media3.exoplayer.source;

import androidx.media3.common.MediaItem;
import androidx.media3.exoplayer.drm.DrmSessionManagerProvider;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.exoplayer.upstream.CmcdConfiguration;
import androidx.media3.exoplayer.upstream.LoadErrorHandlingPolicy;
import androidx.media3.exoplayer.util.ReleasableExecutor;
import androidx.media3.extractor.text.SubtitleParser;
import com.google.common.base.Supplier;

/* JADX INFO: loaded from: classes.dex */
public class ForwardingMediaSourceFactory implements MediaSource.Factory {
    private final MediaSource.Factory factory;

    public ForwardingMediaSourceFactory(MediaSource.Factory factory) {
        this.factory = factory;
    }

    @Override // androidx.media3.exoplayer.source.MediaSource.Factory
    public MediaSource createMediaSource(MediaItem mediaItem) {
        return this.factory.createMediaSource(mediaItem);
    }

    @Override // androidx.media3.exoplayer.source.MediaSource.Factory
    public MediaSource.Factory experimentalParseSubtitlesDuringExtraction(boolean z) {
        return this.factory.experimentalParseSubtitlesDuringExtraction(z);
    }

    @Override // androidx.media3.exoplayer.source.MediaSource.Factory
    public MediaSource.Factory experimentalSetCodecsToParseWithinGopSampleDependencies(int i) {
        return this.factory.experimentalSetCodecsToParseWithinGopSampleDependencies(i);
    }

    @Override // androidx.media3.exoplayer.source.MediaSource.Factory
    public int[] getSupportedTypes() {
        return this.factory.getSupportedTypes();
    }

    @Override // androidx.media3.exoplayer.source.MediaSource.Factory
    public MediaSource.Factory setCmcdConfigurationFactory(CmcdConfiguration.Factory factory) {
        return this.factory.setCmcdConfigurationFactory(factory);
    }

    @Override // androidx.media3.exoplayer.source.MediaSource.Factory
    public MediaSource.Factory setDownloadExecutor(Supplier<ReleasableExecutor> supplier) {
        return this.factory.setDownloadExecutor(supplier);
    }

    @Override // androidx.media3.exoplayer.source.MediaSource.Factory
    public MediaSource.Factory setDrmSessionManagerProvider(DrmSessionManagerProvider drmSessionManagerProvider) {
        return this.factory.setDrmSessionManagerProvider(drmSessionManagerProvider);
    }

    @Override // androidx.media3.exoplayer.source.MediaSource.Factory
    public MediaSource.Factory setLoadErrorHandlingPolicy(LoadErrorHandlingPolicy loadErrorHandlingPolicy) {
        return this.factory.setLoadErrorHandlingPolicy(loadErrorHandlingPolicy);
    }

    @Override // androidx.media3.exoplayer.source.MediaSource.Factory
    public MediaSource.Factory setSubtitleParserFactory(SubtitleParser.Factory factory) {
        return this.factory.setSubtitleParserFactory(factory);
    }
}
