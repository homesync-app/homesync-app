package io.flutter.plugins.videoplayer;

import android.content.Context;
import androidx.media3.common.MediaItem;
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory;
import androidx.media3.exoplayer.source.MediaSource;

/* JADX INFO: loaded from: classes4.dex */
final class LocalVideoAsset extends VideoAsset {
    LocalVideoAsset(String str) {
        super(str);
    }

    @Override // io.flutter.plugins.videoplayer.VideoAsset
    public MediaItem getMediaItem() {
        return new MediaItem.Builder().setUri(this.assetUrl).build();
    }

    @Override // io.flutter.plugins.videoplayer.VideoAsset
    public MediaSource.Factory getMediaSourceFactory(Context context) {
        return new DefaultMediaSourceFactory(context);
    }
}
