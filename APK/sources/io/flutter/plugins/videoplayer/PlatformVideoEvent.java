package io.flutter.plugins.videoplayer;

import androidx.media3.container.NalUnitUtil;
import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;

/* JADX INFO: compiled from: Messages.kt */
/* JADX INFO: loaded from: classes4.dex */
@Metadata(d1 = {"\u0000\u001e\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\b6\u0018\u00002\u00020\u0001B\t\b\u0004¢\u0006\u0004\b\u0002\u0010\u0003\u0082\u0001\u0004\u0004\u0005\u0006\u0007¨\u0006\b"}, d2 = {"Lio/flutter/plugins/videoplayer/PlatformVideoEvent;", "", "<init>", "()V", "Lio/flutter/plugins/videoplayer/AudioTrackChangedEvent;", "Lio/flutter/plugins/videoplayer/InitializationEvent;", "Lio/flutter/plugins/videoplayer/IsPlayingStateEvent;", "Lio/flutter/plugins/videoplayer/PlaybackStateChangeEvent;", "video_player_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public abstract class PlatformVideoEvent {
    public /* synthetic */ PlatformVideoEvent(DefaultConstructorMarker defaultConstructorMarker) {
        this();
    }

    private PlatformVideoEvent() {
    }
}
