package androidx.media3.extractor;

import androidx.media3.extractor.SeekMap;

/* JADX INFO: loaded from: classes.dex */
public interface TrackAwareSeekMap extends SeekMap {
    SeekMap.SeekPoints getSeekPoints(long j, int i);

    boolean isSeekable(int i);
}
