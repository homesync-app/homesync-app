package androidx.media3.exoplayer.source.preload;

import androidx.media3.common.MediaItem;
import java.util.Objects;

/* JADX INFO: loaded from: classes.dex */
public final class PreloadException extends Exception {
    public final MediaItem mediaItem;

    public PreloadException(MediaItem mediaItem, String str, Throwable th) {
        super(str, th);
        this.mediaItem = mediaItem;
    }

    public boolean errorInfoEquals(PreloadException preloadException) {
        if (this == preloadException) {
            return true;
        }
        if (preloadException != null && getClass() == preloadException.getClass()) {
            Throwable cause = getCause();
            Throwable cause2 = preloadException.getCause();
            if (cause == null || cause2 == null) {
                if (cause == null && cause2 == null) {
                }
            } else if (!Objects.equals(cause.getMessage(), cause2.getMessage()) || !Objects.equals(cause.getClass(), cause2.getClass())) {
                return false;
            }
            if (Objects.equals(this.mediaItem, preloadException.mediaItem) && Objects.equals(getMessage(), preloadException.getMessage())) {
                return true;
            }
        }
        return false;
    }
}
