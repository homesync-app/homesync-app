package io.flutter.plugins.videoplayer;

import androidx.exifinterface.media.ExifInterface;
import androidx.media3.container.NalUnitUtil;
import io.flutter.plugin.common.EventChannel;
import kotlin.Metadata;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: Messages.kt */
/* JADX INFO: loaded from: classes4.dex */
@Metadata(d1 = {"\u00000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0005\n\u0002\u0018\u0002\n\u0002\b\u0005\n\u0002\u0010\u0002\n\u0000\n\u0002\u0010\u0000\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\b\u0002\u0018\u0000*\u0004\b\u0000\u0010\u00012\u00020\u0002B\u0015\u0012\f\u0010\u0003\u001a\b\u0012\u0004\u0012\u00028\u00000\u0004¢\u0006\u0004\b\u0005\u0010\u0006J\u001a\u0010\u000f\u001a\u00020\u00102\b\u0010\u0011\u001a\u0004\u0018\u00010\u00122\u0006\u0010\u0013\u001a\u00020\u0014H\u0016J\u0012\u0010\u0015\u001a\u00020\u00102\b\u0010\u0011\u001a\u0004\u0018\u00010\u0012H\u0016R\u0017\u0010\u0003\u001a\b\u0012\u0004\u0012\u00028\u00000\u0004¢\u0006\b\n\u0000\u001a\u0004\b\u0007\u0010\bR\"\u0010\t\u001a\n\u0012\u0004\u0012\u00028\u0000\u0018\u00010\nX\u0086\u000e¢\u0006\u000e\n\u0000\u001a\u0004\b\u000b\u0010\f\"\u0004\b\r\u0010\u000e¨\u0006\u0016"}, d2 = {"Lio/flutter/plugins/videoplayer/MessagesPigeonStreamHandler;", ExifInterface.GPS_DIRECTION_TRUE, "Lio/flutter/plugin/common/EventChannel$StreamHandler;", "wrapper", "Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;", "<init>", "(Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;)V", "getWrapper", "()Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;", "pigeonSink", "Lio/flutter/plugins/videoplayer/PigeonEventSink;", "getPigeonSink", "()Lio/flutter/plugins/videoplayer/PigeonEventSink;", "setPigeonSink", "(Lio/flutter/plugins/videoplayer/PigeonEventSink;)V", "onListen", "", "p0", "", "sink", "Lio/flutter/plugin/common/EventChannel$EventSink;", "onCancel", "video_player_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
final class MessagesPigeonStreamHandler<T> implements EventChannel.StreamHandler {
    private PigeonEventSink<T> pigeonSink;
    private final MessagesPigeonEventChannelWrapper<T> wrapper;

    public MessagesPigeonStreamHandler(MessagesPigeonEventChannelWrapper<T> wrapper) {
        Intrinsics.checkNotNullParameter(wrapper, "wrapper");
        this.wrapper = wrapper;
    }

    public final MessagesPigeonEventChannelWrapper<T> getWrapper() {
        return this.wrapper;
    }

    public final PigeonEventSink<T> getPigeonSink() {
        return this.pigeonSink;
    }

    public final void setPigeonSink(PigeonEventSink<T> pigeonEventSink) {
        this.pigeonSink = pigeonEventSink;
    }

    @Override // io.flutter.plugin.common.EventChannel.StreamHandler
    public void onListen(Object p0, EventChannel.EventSink sink) {
        Intrinsics.checkNotNullParameter(sink, "sink");
        PigeonEventSink<T> pigeonEventSink = new PigeonEventSink<>(sink);
        this.pigeonSink = pigeonEventSink;
        MessagesPigeonEventChannelWrapper<T> messagesPigeonEventChannelWrapper = this.wrapper;
        Intrinsics.checkNotNull(pigeonEventSink);
        messagesPigeonEventChannelWrapper.onListen(p0, pigeonEventSink);
    }

    @Override // io.flutter.plugin.common.EventChannel.StreamHandler
    public void onCancel(Object p0) {
        this.pigeonSink = null;
        this.wrapper.onCancel(p0);
    }
}
