package io.flutter.plugins.videoplayer;

import androidx.media3.container.NalUnitUtil;
import java.util.List;
import kotlin.Metadata;
import kotlin.collections.CollectionsKt;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: Messages.kt */
/* JADX INFO: loaded from: classes4.dex */
@Metadata(d1 = {"\u0000,\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u000e\n\u0002\b\u0005\n\u0002\u0010 \n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000b\n\u0002\b\u0002\n\u0002\u0010\b\n\u0002\b\u0005\b\u0086\b\u0018\u0000 \u00132\u00020\u0001:\u0001\u0013B\u0013\u0012\n\b\u0002\u0010\u0002\u001a\u0004\u0018\u00010\u0003¢\u0006\u0004\b\u0004\u0010\u0005J\u000e\u0010\b\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\n0\tJ\u0013\u0010\u000b\u001a\u00020\f2\b\u0010\r\u001a\u0004\u0018\u00010\nH\u0096\u0002J\b\u0010\u000e\u001a\u00020\u000fH\u0016J\u000b\u0010\u0010\u001a\u0004\u0018\u00010\u0003HÆ\u0003J\u0015\u0010\u0011\u001a\u00020\u00002\n\b\u0002\u0010\u0002\u001a\u0004\u0018\u00010\u0003HÆ\u0001J\t\u0010\u0012\u001a\u00020\u0003HÖ\u0001R\u0013\u0010\u0002\u001a\u0004\u0018\u00010\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u0006\u0010\u0007¨\u0006\u0014"}, d2 = {"Lio/flutter/plugins/videoplayer/AudioTrackChangedEvent;", "Lio/flutter/plugins/videoplayer/PlatformVideoEvent;", "selectedTrackId", "", "<init>", "(Ljava/lang/String;)V", "getSelectedTrackId", "()Ljava/lang/String;", "toList", "", "", "equals", "", "other", "hashCode", "", "component1", "copy", "toString", "Companion", "video_player_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final /* data */ class AudioTrackChangedEvent extends PlatformVideoEvent {

    /* JADX INFO: renamed from: Companion, reason: from kotlin metadata */
    public static final Companion INSTANCE = new Companion(null);
    private final String selectedTrackId;

    public AudioTrackChangedEvent() {
        this(null, 1, 0 == true ? 1 : 0);
    }

    public static /* synthetic */ AudioTrackChangedEvent copy$default(AudioTrackChangedEvent audioTrackChangedEvent, String str, int i, Object obj) {
        if ((i & 1) != 0) {
            str = audioTrackChangedEvent.selectedTrackId;
        }
        return audioTrackChangedEvent.copy(str);
    }

    /* JADX INFO: renamed from: component1, reason: from getter */
    public final String getSelectedTrackId() {
        return this.selectedTrackId;
    }

    public final AudioTrackChangedEvent copy(String selectedTrackId) {
        return new AudioTrackChangedEvent(selectedTrackId);
    }

    public String toString() {
        return "AudioTrackChangedEvent(selectedTrackId=" + this.selectedTrackId + ")";
    }

    public AudioTrackChangedEvent(String str) {
        super(null);
        this.selectedTrackId = str;
    }

    public /* synthetic */ AudioTrackChangedEvent(String str, int i, DefaultConstructorMarker defaultConstructorMarker) {
        this((i & 1) != 0 ? null : str);
    }

    public final String getSelectedTrackId() {
        return this.selectedTrackId;
    }

    /* JADX INFO: compiled from: Messages.kt */
    @Metadata(d1 = {"\u0000\u0018\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010 \n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\t\b\u0002¢\u0006\u0004\b\u0002\u0010\u0003J\u0016\u0010\u0004\u001a\u00020\u00052\u000e\u0010\u0006\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0007¨\u0006\b"}, d2 = {"Lio/flutter/plugins/videoplayer/AudioTrackChangedEvent$Companion;", "", "<init>", "()V", "fromList", "Lio/flutter/plugins/videoplayer/AudioTrackChangedEvent;", "pigeonVar_list", "", "video_player_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }

        public final AudioTrackChangedEvent fromList(List<? extends Object> pigeonVar_list) {
            Intrinsics.checkNotNullParameter(pigeonVar_list, "pigeonVar_list");
            return new AudioTrackChangedEvent((String) pigeonVar_list.get(0));
        }
    }

    public final List<Object> toList() {
        return CollectionsKt.listOf(this.selectedTrackId);
    }

    public boolean equals(Object other) {
        if (!(other instanceof AudioTrackChangedEvent)) {
            return false;
        }
        if (this == other) {
            return true;
        }
        return MessagesPigeonUtils.INSTANCE.deepEquals(toList(), ((AudioTrackChangedEvent) other).toList());
    }

    public int hashCode() {
        return toList().hashCode();
    }
}
