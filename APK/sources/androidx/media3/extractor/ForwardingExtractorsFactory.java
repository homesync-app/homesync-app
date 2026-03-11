package androidx.media3.extractor;

import android.net.Uri;
import androidx.media3.extractor.text.SubtitleParser;
import java.util.List;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public class ForwardingExtractorsFactory implements ExtractorsFactory {
    private final ExtractorsFactory factory;

    public ForwardingExtractorsFactory(ExtractorsFactory extractorsFactory) {
        this.factory = extractorsFactory;
    }

    @Override // androidx.media3.extractor.ExtractorsFactory
    public ExtractorsFactory experimentalSetTextTrackTranscodingEnabled(boolean z) {
        return this.factory.experimentalSetTextTrackTranscodingEnabled(z);
    }

    @Override // androidx.media3.extractor.ExtractorsFactory
    public ExtractorsFactory setSubtitleParserFactory(SubtitleParser.Factory factory) {
        return this.factory.setSubtitleParserFactory(factory);
    }

    @Override // androidx.media3.extractor.ExtractorsFactory
    public ExtractorsFactory experimentalSetCodecsToParseWithinGopSampleDependencies(int i) {
        return this.factory.experimentalSetCodecsToParseWithinGopSampleDependencies(i);
    }

    @Override // androidx.media3.extractor.ExtractorsFactory
    public Extractor[] createExtractors() {
        return this.factory.createExtractors();
    }

    @Override // androidx.media3.extractor.ExtractorsFactory
    public Extractor[] createExtractors(Uri uri, Map<String, List<String>> map) {
        return this.factory.createExtractors(uri, map);
    }
}
