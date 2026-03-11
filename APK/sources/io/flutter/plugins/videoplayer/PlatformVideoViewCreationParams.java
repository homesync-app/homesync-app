package io.flutter.plugins.videoplayer;

import androidx.media3.container.NalUnitUtil;
import java.util.List;
import kotlin.Metadata;
import kotlin.collections.CollectionsKt;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: Messages.kt */
/* JADX INFO: loaded from: classes4.dex */
@Metadata(d1 = {"\u00000\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\t\n\u0002\b\u0005\n\u0002\u0010 \n\u0000\n\u0002\u0010\u000b\n\u0002\b\u0002\n\u0002\u0010\b\n\u0002\b\u0003\n\u0002\u0010\u000e\n\u0002\b\u0002\b\u0086\b\u0018\u0000 \u00132\u00020\u0001:\u0001\u0013B\u000f\u0012\u0006\u0010\u0002\u001a\u00020\u0003¢\u0006\u0004\b\u0004\u0010\u0005J\u000e\u0010\b\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\tJ\u0013\u0010\n\u001a\u00020\u000b2\b\u0010\f\u001a\u0004\u0018\u00010\u0001H\u0096\u0002J\b\u0010\r\u001a\u00020\u000eH\u0016J\t\u0010\u000f\u001a\u00020\u0003HÆ\u0003J\u0013\u0010\u0010\u001a\u00020\u00002\b\b\u0002\u0010\u0002\u001a\u00020\u0003HÆ\u0001J\t\u0010\u0011\u001a\u00020\u0012HÖ\u0001R\u0011\u0010\u0002\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u0006\u0010\u0007¨\u0006\u0014"}, d2 = {"Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;", "", "playerId", "", "<init>", "(J)V", "getPlayerId", "()J", "toList", "", "equals", "", "other", "hashCode", "", "component1", "copy", "toString", "", "Companion", "video_player_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final /* data */ class PlatformVideoViewCreationParams {

    /* JADX INFO: renamed from: Companion, reason: from kotlin metadata */
    public static final Companion INSTANCE = new Companion(null);
    private final long playerId;

    public static /* synthetic */ PlatformVideoViewCreationParams copy$default(PlatformVideoViewCreationParams platformVideoViewCreationParams, long j, int i, Object obj) {
        if ((i & 1) != 0) {
            j = platformVideoViewCreationParams.playerId;
        }
        return platformVideoViewCreationParams.copy(j);
    }

    /* JADX INFO: renamed from: component1, reason: from getter */
    public final long getPlayerId() {
        return this.playerId;
    }

    public final PlatformVideoViewCreationParams copy(long playerId) {
        return new PlatformVideoViewCreationParams(playerId);
    }

    public String toString() {
        return "PlatformVideoViewCreationParams(playerId=" + this.playerId + ")";
    }

    /* JADX INFO: compiled from: Messages.kt */
    @Metadata(d1 = {"\u0000\u0018\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010 \n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\t\b\u0002¢\u0006\u0004\b\u0002\u0010\u0003J\u0016\u0010\u0004\u001a\u00020\u00052\u000e\u0010\u0006\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0007¨\u0006\b"}, d2 = {"Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams$Companion;", "", "<init>", "()V", "fromList", "Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;", "pigeonVar_list", "", "video_player_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }

        public final PlatformVideoViewCreationParams fromList(List<? extends Object> pigeonVar_list) {
            Intrinsics.checkNotNullParameter(pigeonVar_list, "pigeonVar_list");
            Object obj = pigeonVar_list.get(0);
            Intrinsics.checkNotNull(obj, "null cannot be cast to non-null type kotlin.Long");
            return new PlatformVideoViewCreationParams(((Long) obj).longValue());
        }
    }

    public PlatformVideoViewCreationParams(long j) {
        this.playerId = j;
    }

    public final long getPlayerId() {
        return this.playerId;
    }

    public final List<Object> toList() {
        return CollectionsKt.listOf(Long.valueOf(this.playerId));
    }

    public boolean equals(Object other) {
        if (!(other instanceof PlatformVideoViewCreationParams)) {
            return false;
        }
        if (this == other) {
            return true;
        }
        return MessagesPigeonUtils.INSTANCE.deepEquals(toList(), ((PlatformVideoViewCreationParams) other).toList());
    }

    public int hashCode() {
        return toList().hashCode();
    }
}
