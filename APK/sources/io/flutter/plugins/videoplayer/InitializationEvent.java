package io.flutter.plugins.videoplayer;

import androidx.media3.container.NalUnitUtil;
import java.util.List;
import kotlin.Metadata;
import kotlin.collections.CollectionsKt;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: Messages.kt */
/* JADX INFO: loaded from: classes4.dex */
@Metadata(d1 = {"\u00004\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\t\n\u0002\b\u000b\n\u0002\u0010 \n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000b\n\u0002\b\u0002\n\u0002\u0010\b\n\u0002\b\u0006\n\u0002\u0010\u000e\n\u0002\b\u0002\b\u0086\b\u0018\u0000 \u001d2\u00020\u0001:\u0001\u001dB'\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0006\u0010\u0004\u001a\u00020\u0003\u0012\u0006\u0010\u0005\u001a\u00020\u0003\u0012\u0006\u0010\u0006\u001a\u00020\u0003¢\u0006\u0004\b\u0007\u0010\bJ\u000e\u0010\u000e\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00100\u000fJ\u0013\u0010\u0011\u001a\u00020\u00122\b\u0010\u0013\u001a\u0004\u0018\u00010\u0010H\u0096\u0002J\b\u0010\u0014\u001a\u00020\u0015H\u0016J\t\u0010\u0016\u001a\u00020\u0003HÆ\u0003J\t\u0010\u0017\u001a\u00020\u0003HÆ\u0003J\t\u0010\u0018\u001a\u00020\u0003HÆ\u0003J\t\u0010\u0019\u001a\u00020\u0003HÆ\u0003J1\u0010\u001a\u001a\u00020\u00002\b\b\u0002\u0010\u0002\u001a\u00020\u00032\b\b\u0002\u0010\u0004\u001a\u00020\u00032\b\b\u0002\u0010\u0005\u001a\u00020\u00032\b\b\u0002\u0010\u0006\u001a\u00020\u0003HÆ\u0001J\t\u0010\u001b\u001a\u00020\u001cHÖ\u0001R\u0011\u0010\u0002\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\t\u0010\nR\u0011\u0010\u0004\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u000b\u0010\nR\u0011\u0010\u0005\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\f\u0010\nR\u0011\u0010\u0006\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\r\u0010\n¨\u0006\u001e"}, d2 = {"Lio/flutter/plugins/videoplayer/InitializationEvent;", "Lio/flutter/plugins/videoplayer/PlatformVideoEvent;", "duration", "", "width", "height", "rotationCorrection", "<init>", "(JJJJ)V", "getDuration", "()J", "getWidth", "getHeight", "getRotationCorrection", "toList", "", "", "equals", "", "other", "hashCode", "", "component1", "component2", "component3", "component4", "copy", "toString", "", "Companion", "video_player_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final /* data */ class InitializationEvent extends PlatformVideoEvent {

    /* JADX INFO: renamed from: Companion, reason: from kotlin metadata */
    public static final Companion INSTANCE = new Companion(null);
    private final long duration;
    private final long height;
    private final long rotationCorrection;
    private final long width;

    public static /* synthetic */ InitializationEvent copy$default(InitializationEvent initializationEvent, long j, long j2, long j3, long j4, int i, Object obj) {
        if ((i & 1) != 0) {
            j = initializationEvent.duration;
        }
        long j5 = j;
        if ((i & 2) != 0) {
            j2 = initializationEvent.width;
        }
        long j6 = j2;
        if ((i & 4) != 0) {
            j3 = initializationEvent.height;
        }
        return initializationEvent.copy(j5, j6, j3, (i & 8) != 0 ? initializationEvent.rotationCorrection : j4);
    }

    /* JADX INFO: renamed from: component1, reason: from getter */
    public final long getDuration() {
        return this.duration;
    }

    /* JADX INFO: renamed from: component2, reason: from getter */
    public final long getWidth() {
        return this.width;
    }

    /* JADX INFO: renamed from: component3, reason: from getter */
    public final long getHeight() {
        return this.height;
    }

    /* JADX INFO: renamed from: component4, reason: from getter */
    public final long getRotationCorrection() {
        return this.rotationCorrection;
    }

    public final InitializationEvent copy(long duration, long width, long height, long rotationCorrection) {
        return new InitializationEvent(duration, width, height, rotationCorrection);
    }

    public String toString() {
        return "InitializationEvent(duration=" + this.duration + ", width=" + this.width + ", height=" + this.height + ", rotationCorrection=" + this.rotationCorrection + ")";
    }

    public InitializationEvent(long j, long j2, long j3, long j4) {
        super(null);
        this.duration = j;
        this.width = j2;
        this.height = j3;
        this.rotationCorrection = j4;
    }

    public final long getDuration() {
        return this.duration;
    }

    public final long getWidth() {
        return this.width;
    }

    public final long getHeight() {
        return this.height;
    }

    public final long getRotationCorrection() {
        return this.rotationCorrection;
    }

    /* JADX INFO: compiled from: Messages.kt */
    @Metadata(d1 = {"\u0000\u0018\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010 \n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\t\b\u0002¢\u0006\u0004\b\u0002\u0010\u0003J\u0016\u0010\u0004\u001a\u00020\u00052\u000e\u0010\u0006\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0007¨\u0006\b"}, d2 = {"Lio/flutter/plugins/videoplayer/InitializationEvent$Companion;", "", "<init>", "()V", "fromList", "Lio/flutter/plugins/videoplayer/InitializationEvent;", "pigeonVar_list", "", "video_player_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }

        public final InitializationEvent fromList(List<? extends Object> pigeonVar_list) {
            Intrinsics.checkNotNullParameter(pigeonVar_list, "pigeonVar_list");
            Object obj = pigeonVar_list.get(0);
            Intrinsics.checkNotNull(obj, "null cannot be cast to non-null type kotlin.Long");
            long jLongValue = ((Long) obj).longValue();
            Object obj2 = pigeonVar_list.get(1);
            Intrinsics.checkNotNull(obj2, "null cannot be cast to non-null type kotlin.Long");
            long jLongValue2 = ((Long) obj2).longValue();
            Object obj3 = pigeonVar_list.get(2);
            Intrinsics.checkNotNull(obj3, "null cannot be cast to non-null type kotlin.Long");
            long jLongValue3 = ((Long) obj3).longValue();
            Object obj4 = pigeonVar_list.get(3);
            Intrinsics.checkNotNull(obj4, "null cannot be cast to non-null type kotlin.Long");
            return new InitializationEvent(jLongValue, jLongValue2, jLongValue3, ((Long) obj4).longValue());
        }
    }

    public final List<Object> toList() {
        return CollectionsKt.listOf((Object[]) new Long[]{Long.valueOf(this.duration), Long.valueOf(this.width), Long.valueOf(this.height), Long.valueOf(this.rotationCorrection)});
    }

    public boolean equals(Object other) {
        if (!(other instanceof InitializationEvent)) {
            return false;
        }
        if (this == other) {
            return true;
        }
        return MessagesPigeonUtils.INSTANCE.deepEquals(toList(), ((InitializationEvent) other).toList());
    }

    public int hashCode() {
        return toList().hashCode();
    }
}
