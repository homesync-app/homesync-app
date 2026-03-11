package io.flutter.plugins.videoplayer;

import androidx.media3.container.NalUnitUtil;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import kotlin.Metadata;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: Messages.kt */
/* JADX INFO: loaded from: classes4.dex */
@Metadata(d1 = {"\u0000$\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0003\n\u0002\u0010\u0002\n\u0000\n\u0002\u0010\u0000\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0003\b&\u0018\u0000 \f2\b\u0012\u0004\u0012\u00020\u00020\u0001:\u0001\fB\u0007¢\u0006\u0004\b\u0003\u0010\u0004J \u0010\u0005\u001a\u00020\u00062\b\u0010\u0007\u001a\u0004\u0018\u00010\b2\f\u0010\t\u001a\b\u0012\u0004\u0012\u00020\u00020\nH\u0016J\u0012\u0010\u000b\u001a\u00020\u00062\b\u0010\u0007\u001a\u0004\u0018\u00010\bH\u0016¨\u0006\r"}, d2 = {"Lio/flutter/plugins/videoplayer/VideoEventsStreamHandler;", "Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;", "Lio/flutter/plugins/videoplayer/PlatformVideoEvent;", "<init>", "()V", "onListen", "", "p0", "", "sink", "Lio/flutter/plugins/videoplayer/PigeonEventSink;", "onCancel", "Companion", "video_player_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public abstract class VideoEventsStreamHandler implements MessagesPigeonEventChannelWrapper<PlatformVideoEvent> {

    /* JADX INFO: renamed from: Companion, reason: from kotlin metadata */
    public static final Companion INSTANCE = new Companion(null);

    @Override // io.flutter.plugins.videoplayer.MessagesPigeonEventChannelWrapper
    public void onCancel(Object p0) {
    }

    @Override // io.flutter.plugins.videoplayer.MessagesPigeonEventChannelWrapper
    public void onListen(Object p0, PigeonEventSink<PlatformVideoEvent> sink) {
        Intrinsics.checkNotNullParameter(sink, "sink");
    }

    /* JADX INFO: compiled from: Messages.kt */
    @Metadata(d1 = {"\u0000$\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0003\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u000e\n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\t\b\u0002¢\u0006\u0004\b\u0002\u0010\u0003J \u0010\u0004\u001a\u00020\u00052\u0006\u0010\u0006\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\t2\b\b\u0002\u0010\n\u001a\u00020\u000b¨\u0006\f"}, d2 = {"Lio/flutter/plugins/videoplayer/VideoEventsStreamHandler$Companion;", "", "<init>", "()V", "register", "", "messenger", "Lio/flutter/plugin/common/BinaryMessenger;", "streamHandler", "Lio/flutter/plugins/videoplayer/VideoEventsStreamHandler;", "instanceName", "", "video_player_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }

        public static /* synthetic */ void register$default(Companion companion, BinaryMessenger binaryMessenger, VideoEventsStreamHandler videoEventsStreamHandler, String str, int i, Object obj) {
            if ((i & 4) != 0) {
                str = "";
            }
            companion.register(binaryMessenger, videoEventsStreamHandler, str);
        }

        public final void register(BinaryMessenger messenger, VideoEventsStreamHandler streamHandler, String instanceName) {
            String str;
            Intrinsics.checkNotNullParameter(messenger, "messenger");
            Intrinsics.checkNotNullParameter(streamHandler, "streamHandler");
            Intrinsics.checkNotNullParameter(instanceName, "instanceName");
            if (instanceName.length() <= 0) {
                str = "dev.flutter.pigeon.video_player_android.VideoEventChannel.videoEvents";
            } else {
                str = "dev.flutter.pigeon.video_player_android.VideoEventChannel.videoEvents." + instanceName;
            }
            new EventChannel(messenger, str, MessagesKt.getMessagesPigeonMethodCodec()).setStreamHandler(new MessagesPigeonStreamHandler(streamHandler));
        }
    }
}
