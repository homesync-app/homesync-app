package io.flutter.plugins.videoplayer;

import androidx.exifinterface.media.ExifInterface;
import androidx.media3.container.NalUnitUtil;
import com.google.firebase.analytics.FirebaseAnalytics;
import io.flutter.plugin.common.EventChannel;
import kotlin.Metadata;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: Messages.kt */
/* JADX INFO: loaded from: classes4.dex */
@Metadata(d1 = {"\u0000$\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0000\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0003\n\u0002\u0010\u0002\n\u0002\b\u0004\n\u0002\u0010\u000e\n\u0002\b\u0004\u0018\u0000*\u0004\b\u0000\u0010\u00012\u00020\u0002B\u000f\u0012\u0006\u0010\u0003\u001a\u00020\u0004¢\u0006\u0004\b\u0005\u0010\u0006J\u0013\u0010\u0007\u001a\u00020\b2\u0006\u0010\t\u001a\u00028\u0000¢\u0006\u0002\u0010\nJ\"\u0010\u000b\u001a\u00020\b2\u0006\u0010\f\u001a\u00020\r2\b\u0010\u000e\u001a\u0004\u0018\u00010\r2\b\u0010\u000f\u001a\u0004\u0018\u00010\u0002J\u0006\u0010\u0010\u001a\u00020\bR\u000e\u0010\u0003\u001a\u00020\u0004X\u0082\u0004¢\u0006\u0002\n\u0000¨\u0006\u0011"}, d2 = {"Lio/flutter/plugins/videoplayer/PigeonEventSink;", ExifInterface.GPS_DIRECTION_TRUE, "", "sink", "Lio/flutter/plugin/common/EventChannel$EventSink;", "<init>", "(Lio/flutter/plugin/common/EventChannel$EventSink;)V", FirebaseAnalytics.Param.SUCCESS, "", "value", "(Ljava/lang/Object;)V", "error", "errorCode", "", "errorMessage", "errorDetails", "endOfStream", "video_player_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final class PigeonEventSink<T> {
    private final EventChannel.EventSink sink;

    public PigeonEventSink(EventChannel.EventSink sink) {
        Intrinsics.checkNotNullParameter(sink, "sink");
        this.sink = sink;
    }

    public final void success(T value) {
        this.sink.success(value);
    }

    public final void error(String errorCode, String errorMessage, Object errorDetails) {
        Intrinsics.checkNotNullParameter(errorCode, "errorCode");
        this.sink.error(errorCode, errorMessage, errorDetails);
    }

    public final void endOfStream() {
        this.sink.endOfStream();
    }
}
