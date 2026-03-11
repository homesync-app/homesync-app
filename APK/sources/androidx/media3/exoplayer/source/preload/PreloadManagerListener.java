package androidx.media3.exoplayer.source.preload;

import androidx.media3.common.MediaItem;

/* JADX INFO: loaded from: classes.dex */
public interface PreloadManagerListener {
    default void onCompleted(MediaItem mediaItem) {
    }

    default void onError(PreloadException preloadException) {
    }
}
