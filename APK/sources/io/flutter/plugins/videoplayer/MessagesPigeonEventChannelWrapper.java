package io.flutter.plugins.videoplayer;

import androidx.exifinterface.media.ExifInterface;
import androidx.media3.container.NalUnitUtil;
import kotlin.Metadata;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: Messages.kt */
/* JADX INFO: loaded from: classes4.dex */
@Metadata(d1 = {"\u0000\u001c\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\b\u0002\bf\u0018\u0000*\u0004\b\u0000\u0010\u00012\u00020\u0002J \u0010\u0003\u001a\u00020\u00042\b\u0010\u0005\u001a\u0004\u0018\u00010\u00022\f\u0010\u0006\u001a\b\u0012\u0004\u0012\u00028\u00000\u0007H\u0016J\u0012\u0010\b\u001a\u00020\u00042\b\u0010\u0005\u001a\u0004\u0018\u00010\u0002H\u0016¨\u0006\tÀ\u0006\u0003"}, d2 = {"Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;", ExifInterface.GPS_DIRECTION_TRUE, "", "onListen", "", "p0", "sink", "Lio/flutter/plugins/videoplayer/PigeonEventSink;", "onCancel", "video_player_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public interface MessagesPigeonEventChannelWrapper<T> {
    default void onCancel(Object p0) {
    }

    default void onListen(Object p0, PigeonEventSink<T> sink) {
        Intrinsics.checkNotNullParameter(sink, "sink");
    }

    /* JADX INFO: compiled from: Messages.kt */
    @Metadata(k = 3, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
    public static final class DefaultImpls {
        @Deprecated
        public static <T> void onListen(MessagesPigeonEventChannelWrapper<T> messagesPigeonEventChannelWrapper, Object obj, PigeonEventSink<T> sink) {
            Intrinsics.checkNotNullParameter(sink, "sink");
            MessagesPigeonEventChannelWrapper.super.onListen(obj, sink);
        }

        @Deprecated
        public static <T> void onCancel(MessagesPigeonEventChannelWrapper<T> messagesPigeonEventChannelWrapper, Object obj) {
            MessagesPigeonEventChannelWrapper.super.onCancel(obj);
        }
    }
}
