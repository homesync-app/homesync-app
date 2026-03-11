package io.flutter.plugins.videoplayer;

import android.content.Context;
import androidx.media3.common.MediaItem;
import androidx.media3.exoplayer.source.MediaSource;
import java.util.HashMap;
import java.util.Map;

/* JADX INFO: loaded from: classes4.dex */
public abstract class VideoAsset {
    protected final String assetUrl;

    enum StreamingFormat {
        UNKNOWN,
        SMOOTH,
        DYNAMIC_ADAPTIVE,
        HTTP_LIVE
    }

    public abstract MediaItem getMediaItem();

    public abstract MediaSource.Factory getMediaSourceFactory(Context context);

    static VideoAsset fromAssetUrl(String str) {
        if (!str.startsWith("asset:///")) {
            throw new IllegalArgumentException("assetUrl must start with 'asset:///'");
        }
        return new LocalVideoAsset(str);
    }

    static VideoAsset fromRemoteUrl(String str, StreamingFormat streamingFormat, Map<String, String> map, String str2) {
        return new HttpVideoAsset(str, streamingFormat, new HashMap(map), str2);
    }

    static VideoAsset fromRtspUrl(String str) {
        if (!str.startsWith("rtsp://")) {
            throw new IllegalArgumentException("rtspUrl must start with 'rtsp://'");
        }
        return new RtspVideoAsset(str);
    }

    protected VideoAsset(String str) {
        this.assetUrl = str;
    }
}
