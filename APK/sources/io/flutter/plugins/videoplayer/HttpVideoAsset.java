package io.flutter.plugins.videoplayer;

import android.content.Context;
import androidx.media3.common.MediaItem;
import androidx.media3.common.MimeTypes;
import androidx.media3.datasource.DefaultDataSource;
import androidx.media3.datasource.DefaultHttpDataSource;
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory;
import androidx.media3.exoplayer.source.MediaSource;
import io.flutter.plugins.videoplayer.VideoAsset;
import java.util.Map;

/* JADX INFO: loaded from: classes4.dex */
final class HttpVideoAsset extends VideoAsset {
    private final Map<String, String> httpHeaders;
    private final VideoAsset.StreamingFormat streamingFormat;
    private final String userAgent;

    HttpVideoAsset(String str, VideoAsset.StreamingFormat streamingFormat, Map<String, String> map, String str2) {
        super(str);
        this.streamingFormat = streamingFormat;
        this.httpHeaders = map;
        this.userAgent = str2;
    }

    @Override // io.flutter.plugins.videoplayer.VideoAsset
    public MediaItem getMediaItem() {
        String str;
        MediaItem.Builder uri = new MediaItem.Builder().setUri(this.assetUrl);
        int i = AnonymousClass1.$SwitchMap$io$flutter$plugins$videoplayer$VideoAsset$StreamingFormat[this.streamingFormat.ordinal()];
        if (i == 1) {
            str = MimeTypes.APPLICATION_SS;
        } else if (i == 2) {
            str = MimeTypes.APPLICATION_MPD;
        } else {
            str = i != 3 ? null : MimeTypes.APPLICATION_M3U8;
        }
        if (str != null) {
            uri.setMimeType(str);
        }
        return uri.build();
    }

    /* JADX INFO: renamed from: io.flutter.plugins.videoplayer.HttpVideoAsset$1, reason: invalid class name */
    static /* synthetic */ class AnonymousClass1 {
        static final /* synthetic */ int[] $SwitchMap$io$flutter$plugins$videoplayer$VideoAsset$StreamingFormat;

        static {
            int[] iArr = new int[VideoAsset.StreamingFormat.values().length];
            $SwitchMap$io$flutter$plugins$videoplayer$VideoAsset$StreamingFormat = iArr;
            try {
                iArr[VideoAsset.StreamingFormat.SMOOTH.ordinal()] = 1;
            } catch (NoSuchFieldError unused) {
            }
            try {
                $SwitchMap$io$flutter$plugins$videoplayer$VideoAsset$StreamingFormat[VideoAsset.StreamingFormat.DYNAMIC_ADAPTIVE.ordinal()] = 2;
            } catch (NoSuchFieldError unused2) {
            }
            try {
                $SwitchMap$io$flutter$plugins$videoplayer$VideoAsset$StreamingFormat[VideoAsset.StreamingFormat.HTTP_LIVE.ordinal()] = 3;
            } catch (NoSuchFieldError unused3) {
            }
        }
    }

    @Override // io.flutter.plugins.videoplayer.VideoAsset
    public MediaSource.Factory getMediaSourceFactory(Context context) {
        return getMediaSourceFactory(context, new DefaultHttpDataSource.Factory());
    }

    MediaSource.Factory getMediaSourceFactory(Context context, DefaultHttpDataSource.Factory factory) {
        unstableUpdateDataSourceFactory(factory, this.httpHeaders, this.userAgent);
        return new DefaultMediaSourceFactory(context).setDataSourceFactory(new DefaultDataSource.Factory(context, factory));
    }

    private static void unstableUpdateDataSourceFactory(DefaultHttpDataSource.Factory factory, Map<String, String> map, String str) {
        factory.setUserAgent(str).setAllowCrossProtocolRedirects(true);
        if (map.isEmpty()) {
            return;
        }
        factory.setDefaultRequestProperties(map);
    }
}
