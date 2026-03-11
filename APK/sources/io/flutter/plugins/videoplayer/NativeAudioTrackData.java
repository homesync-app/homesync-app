package io.flutter.plugins.videoplayer;

import androidx.media3.container.NalUnitUtil;
import java.util.List;
import kotlin.Metadata;
import kotlin.collections.CollectionsKt;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: Messages.kt */
/* JADX INFO: loaded from: classes4.dex */
@Metadata(d1 = {"\u0000.\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010 \n\u0002\u0018\u0002\n\u0002\b\u0006\n\u0002\u0010\u000b\n\u0002\b\u0002\n\u0002\u0010\b\n\u0002\b\u0003\n\u0002\u0010\u000e\n\u0002\b\u0002\b\u0086\b\u0018\u0000 \u00132\u00020\u0001:\u0001\u0013B\u0019\u0012\u0010\b\u0002\u0010\u0002\u001a\n\u0012\u0004\u0012\u00020\u0004\u0018\u00010\u0003¢\u0006\u0004\b\u0005\u0010\u0006J\u000e\u0010\t\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0003J\u0013\u0010\n\u001a\u00020\u000b2\b\u0010\f\u001a\u0004\u0018\u00010\u0001H\u0096\u0002J\b\u0010\r\u001a\u00020\u000eH\u0016J\u0011\u0010\u000f\u001a\n\u0012\u0004\u0012\u00020\u0004\u0018\u00010\u0003HÆ\u0003J\u001b\u0010\u0010\u001a\u00020\u00002\u0010\b\u0002\u0010\u0002\u001a\n\u0012\u0004\u0012\u00020\u0004\u0018\u00010\u0003HÆ\u0001J\t\u0010\u0011\u001a\u00020\u0012HÖ\u0001R\u0019\u0010\u0002\u001a\n\u0012\u0004\u0012\u00020\u0004\u0018\u00010\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u0007\u0010\b¨\u0006\u0014"}, d2 = {"Lio/flutter/plugins/videoplayer/NativeAudioTrackData;", "", "exoPlayerTracks", "", "Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;", "<init>", "(Ljava/util/List;)V", "getExoPlayerTracks", "()Ljava/util/List;", "toList", "equals", "", "other", "hashCode", "", "component1", "copy", "toString", "", "Companion", "video_player_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final /* data */ class NativeAudioTrackData {

    /* JADX INFO: renamed from: Companion, reason: from kotlin metadata */
    public static final Companion INSTANCE = new Companion(null);
    private final List<ExoPlayerAudioTrackData> exoPlayerTracks;

    public NativeAudioTrackData() {
        this(null, 1, 0 == true ? 1 : 0);
    }

    /* JADX WARN: Multi-variable type inference failed */
    public static /* synthetic */ NativeAudioTrackData copy$default(NativeAudioTrackData nativeAudioTrackData, List list, int i, Object obj) {
        if ((i & 1) != 0) {
            list = nativeAudioTrackData.exoPlayerTracks;
        }
        return nativeAudioTrackData.copy(list);
    }

    public final List<ExoPlayerAudioTrackData> component1() {
        return this.exoPlayerTracks;
    }

    public final NativeAudioTrackData copy(List<ExoPlayerAudioTrackData> exoPlayerTracks) {
        return new NativeAudioTrackData(exoPlayerTracks);
    }

    public String toString() {
        return "NativeAudioTrackData(exoPlayerTracks=" + this.exoPlayerTracks + ")";
    }

    public NativeAudioTrackData(List<ExoPlayerAudioTrackData> list) {
        this.exoPlayerTracks = list;
    }

    public /* synthetic */ NativeAudioTrackData(List list, int i, DefaultConstructorMarker defaultConstructorMarker) {
        this((i & 1) != 0 ? null : list);
    }

    public final List<ExoPlayerAudioTrackData> getExoPlayerTracks() {
        return this.exoPlayerTracks;
    }

    /* JADX INFO: compiled from: Messages.kt */
    @Metadata(d1 = {"\u0000\u0018\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010 \n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\t\b\u0002¢\u0006\u0004\b\u0002\u0010\u0003J\u0016\u0010\u0004\u001a\u00020\u00052\u000e\u0010\u0006\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0007¨\u0006\b"}, d2 = {"Lio/flutter/plugins/videoplayer/NativeAudioTrackData$Companion;", "", "<init>", "()V", "fromList", "Lio/flutter/plugins/videoplayer/NativeAudioTrackData;", "pigeonVar_list", "", "video_player_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }

        public final NativeAudioTrackData fromList(List<? extends Object> pigeonVar_list) {
            Intrinsics.checkNotNullParameter(pigeonVar_list, "pigeonVar_list");
            return new NativeAudioTrackData((List) pigeonVar_list.get(0));
        }
    }

    public final List<Object> toList() {
        return CollectionsKt.listOf(this.exoPlayerTracks);
    }

    public boolean equals(Object other) {
        if (!(other instanceof NativeAudioTrackData)) {
            return false;
        }
        if (this == other) {
            return true;
        }
        return MessagesPigeonUtils.INSTANCE.deepEquals(toList(), ((NativeAudioTrackData) other).toList());
    }

    public int hashCode() {
        return toList().hashCode();
    }
}
