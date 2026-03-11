package io.flutter.plugins.videoplayer;

import androidx.media3.container.NalUnitUtil;
import com.google.firebase.messaging.Constants;
import java.util.List;
import kotlin.Metadata;
import kotlin.collections.CollectionsKt;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: Messages.kt */
/* JADX INFO: loaded from: classes4.dex */
@Metadata(d1 = {"\u00002\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\t\n\u0002\b\u0002\n\u0002\u0010\u000e\n\u0002\b\u0002\n\u0002\u0010\u000b\n\u0002\b\u0014\n\u0002\u0010 \n\u0002\b\u0003\n\u0002\u0010\b\n\u0002\b\u000e\b\u0086\b\u0018\u0000 /2\u00020\u0001:\u0001/Bg\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0006\u0010\u0004\u001a\u00020\u0003\u0012\n\b\u0002\u0010\u0005\u001a\u0004\u0018\u00010\u0006\u0012\n\b\u0002\u0010\u0007\u001a\u0004\u0018\u00010\u0006\u0012\u0006\u0010\b\u001a\u00020\t\u0012\n\b\u0002\u0010\n\u001a\u0004\u0018\u00010\u0003\u0012\n\b\u0002\u0010\u000b\u001a\u0004\u0018\u00010\u0003\u0012\n\b\u0002\u0010\f\u001a\u0004\u0018\u00010\u0003\u0012\n\b\u0002\u0010\r\u001a\u0004\u0018\u00010\u0006¢\u0006\u0004\b\u000e\u0010\u000fJ\u000e\u0010\u001d\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u001eJ\u0013\u0010\u001f\u001a\u00020\t2\b\u0010 \u001a\u0004\u0018\u00010\u0001H\u0096\u0002J\b\u0010!\u001a\u00020\"H\u0016J\t\u0010#\u001a\u00020\u0003HÆ\u0003J\t\u0010$\u001a\u00020\u0003HÆ\u0003J\u000b\u0010%\u001a\u0004\u0018\u00010\u0006HÆ\u0003J\u000b\u0010&\u001a\u0004\u0018\u00010\u0006HÆ\u0003J\t\u0010'\u001a\u00020\tHÆ\u0003J\u0010\u0010(\u001a\u0004\u0018\u00010\u0003HÆ\u0003¢\u0006\u0002\u0010\u0018J\u0010\u0010)\u001a\u0004\u0018\u00010\u0003HÆ\u0003¢\u0006\u0002\u0010\u0018J\u0010\u0010*\u001a\u0004\u0018\u00010\u0003HÆ\u0003¢\u0006\u0002\u0010\u0018J\u000b\u0010+\u001a\u0004\u0018\u00010\u0006HÆ\u0003Jt\u0010,\u001a\u00020\u00002\b\b\u0002\u0010\u0002\u001a\u00020\u00032\b\b\u0002\u0010\u0004\u001a\u00020\u00032\n\b\u0002\u0010\u0005\u001a\u0004\u0018\u00010\u00062\n\b\u0002\u0010\u0007\u001a\u0004\u0018\u00010\u00062\b\b\u0002\u0010\b\u001a\u00020\t2\n\b\u0002\u0010\n\u001a\u0004\u0018\u00010\u00032\n\b\u0002\u0010\u000b\u001a\u0004\u0018\u00010\u00032\n\b\u0002\u0010\f\u001a\u0004\u0018\u00010\u00032\n\b\u0002\u0010\r\u001a\u0004\u0018\u00010\u0006HÆ\u0001¢\u0006\u0002\u0010-J\t\u0010.\u001a\u00020\u0006HÖ\u0001R\u0011\u0010\u0002\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u0010\u0010\u0011R\u0011\u0010\u0004\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u0012\u0010\u0011R\u0013\u0010\u0005\u001a\u0004\u0018\u00010\u0006¢\u0006\b\n\u0000\u001a\u0004\b\u0013\u0010\u0014R\u0013\u0010\u0007\u001a\u0004\u0018\u00010\u0006¢\u0006\b\n\u0000\u001a\u0004\b\u0015\u0010\u0014R\u0011\u0010\b\u001a\u00020\t¢\u0006\b\n\u0000\u001a\u0004\b\b\u0010\u0016R\u0015\u0010\n\u001a\u0004\u0018\u00010\u0003¢\u0006\n\n\u0002\u0010\u0019\u001a\u0004\b\u0017\u0010\u0018R\u0015\u0010\u000b\u001a\u0004\u0018\u00010\u0003¢\u0006\n\n\u0002\u0010\u0019\u001a\u0004\b\u001a\u0010\u0018R\u0015\u0010\f\u001a\u0004\u0018\u00010\u0003¢\u0006\n\n\u0002\u0010\u0019\u001a\u0004\b\u001b\u0010\u0018R\u0013\u0010\r\u001a\u0004\u0018\u00010\u0006¢\u0006\b\n\u0000\u001a\u0004\b\u001c\u0010\u0014¨\u00060"}, d2 = {"Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;", "", "groupIndex", "", "trackIndex", Constants.ScionAnalytics.PARAM_LABEL, "", "language", "isSelected", "", "bitrate", "sampleRate", "channelCount", "codec", "<init>", "(JJLjava/lang/String;Ljava/lang/String;ZLjava/lang/Long;Ljava/lang/Long;Ljava/lang/Long;Ljava/lang/String;)V", "getGroupIndex", "()J", "getTrackIndex", "getLabel", "()Ljava/lang/String;", "getLanguage", "()Z", "getBitrate", "()Ljava/lang/Long;", "Ljava/lang/Long;", "getSampleRate", "getChannelCount", "getCodec", "toList", "", "equals", "other", "hashCode", "", "component1", "component2", "component3", "component4", "component5", "component6", "component7", "component8", "component9", "copy", "(JJLjava/lang/String;Ljava/lang/String;ZLjava/lang/Long;Ljava/lang/Long;Ljava/lang/Long;Ljava/lang/String;)Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;", "toString", "Companion", "video_player_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final /* data */ class ExoPlayerAudioTrackData {

    /* JADX INFO: renamed from: Companion, reason: from kotlin metadata */
    public static final Companion INSTANCE = new Companion(null);
    private final Long bitrate;
    private final Long channelCount;
    private final String codec;
    private final long groupIndex;
    private final boolean isSelected;
    private final String label;
    private final String language;
    private final Long sampleRate;
    private final long trackIndex;

    public static /* synthetic */ ExoPlayerAudioTrackData copy$default(ExoPlayerAudioTrackData exoPlayerAudioTrackData, long j, long j2, String str, String str2, boolean z, Long l, Long l2, Long l3, String str3, int i, Object obj) {
        if ((i & 1) != 0) {
            j = exoPlayerAudioTrackData.groupIndex;
        }
        return exoPlayerAudioTrackData.copy(j, (i & 2) != 0 ? exoPlayerAudioTrackData.trackIndex : j2, (i & 4) != 0 ? exoPlayerAudioTrackData.label : str, (i & 8) != 0 ? exoPlayerAudioTrackData.language : str2, (i & 16) != 0 ? exoPlayerAudioTrackData.isSelected : z, (i & 32) != 0 ? exoPlayerAudioTrackData.bitrate : l, (i & 64) != 0 ? exoPlayerAudioTrackData.sampleRate : l2, (i & 128) != 0 ? exoPlayerAudioTrackData.channelCount : l3, (i & 256) != 0 ? exoPlayerAudioTrackData.codec : str3);
    }

    /* JADX INFO: renamed from: component1, reason: from getter */
    public final long getGroupIndex() {
        return this.groupIndex;
    }

    /* JADX INFO: renamed from: component2, reason: from getter */
    public final long getTrackIndex() {
        return this.trackIndex;
    }

    /* JADX INFO: renamed from: component3, reason: from getter */
    public final String getLabel() {
        return this.label;
    }

    /* JADX INFO: renamed from: component4, reason: from getter */
    public final String getLanguage() {
        return this.language;
    }

    /* JADX INFO: renamed from: component5, reason: from getter */
    public final boolean getIsSelected() {
        return this.isSelected;
    }

    /* JADX INFO: renamed from: component6, reason: from getter */
    public final Long getBitrate() {
        return this.bitrate;
    }

    /* JADX INFO: renamed from: component7, reason: from getter */
    public final Long getSampleRate() {
        return this.sampleRate;
    }

    /* JADX INFO: renamed from: component8, reason: from getter */
    public final Long getChannelCount() {
        return this.channelCount;
    }

    /* JADX INFO: renamed from: component9, reason: from getter */
    public final String getCodec() {
        return this.codec;
    }

    public final ExoPlayerAudioTrackData copy(long groupIndex, long trackIndex, String label, String language, boolean isSelected, Long bitrate, Long sampleRate, Long channelCount, String codec) {
        return new ExoPlayerAudioTrackData(groupIndex, trackIndex, label, language, isSelected, bitrate, sampleRate, channelCount, codec);
    }

    public String toString() {
        return "ExoPlayerAudioTrackData(groupIndex=" + this.groupIndex + ", trackIndex=" + this.trackIndex + ", label=" + this.label + ", language=" + this.language + ", isSelected=" + this.isSelected + ", bitrate=" + this.bitrate + ", sampleRate=" + this.sampleRate + ", channelCount=" + this.channelCount + ", codec=" + this.codec + ")";
    }

    public ExoPlayerAudioTrackData(long j, long j2, String str, String str2, boolean z, Long l, Long l2, Long l3, String str3) {
        this.groupIndex = j;
        this.trackIndex = j2;
        this.label = str;
        this.language = str2;
        this.isSelected = z;
        this.bitrate = l;
        this.sampleRate = l2;
        this.channelCount = l3;
        this.codec = str3;
    }

    public /* synthetic */ ExoPlayerAudioTrackData(long j, long j2, String str, String str2, boolean z, Long l, Long l2, Long l3, String str3, int i, DefaultConstructorMarker defaultConstructorMarker) {
        this(j, j2, (i & 4) != 0 ? null : str, (i & 8) != 0 ? null : str2, z, (i & 32) != 0 ? null : l, (i & 64) != 0 ? null : l2, (i & 128) != 0 ? null : l3, (i & 256) != 0 ? null : str3);
    }

    public final long getGroupIndex() {
        return this.groupIndex;
    }

    public final long getTrackIndex() {
        return this.trackIndex;
    }

    public final String getLabel() {
        return this.label;
    }

    public final String getLanguage() {
        return this.language;
    }

    public final boolean isSelected() {
        return this.isSelected;
    }

    public final Long getBitrate() {
        return this.bitrate;
    }

    public final Long getSampleRate() {
        return this.sampleRate;
    }

    public final Long getChannelCount() {
        return this.channelCount;
    }

    public final String getCodec() {
        return this.codec;
    }

    /* JADX INFO: compiled from: Messages.kt */
    @Metadata(d1 = {"\u0000\u0018\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010 \n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\t\b\u0002¢\u0006\u0004\b\u0002\u0010\u0003J\u0016\u0010\u0004\u001a\u00020\u00052\u000e\u0010\u0006\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0007¨\u0006\b"}, d2 = {"Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData$Companion;", "", "<init>", "()V", "fromList", "Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;", "pigeonVar_list", "", "video_player_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }

        public final ExoPlayerAudioTrackData fromList(List<? extends Object> pigeonVar_list) {
            Intrinsics.checkNotNullParameter(pigeonVar_list, "pigeonVar_list");
            Object obj = pigeonVar_list.get(0);
            Intrinsics.checkNotNull(obj, "null cannot be cast to non-null type kotlin.Long");
            long jLongValue = ((Long) obj).longValue();
            Object obj2 = pigeonVar_list.get(1);
            Intrinsics.checkNotNull(obj2, "null cannot be cast to non-null type kotlin.Long");
            long jLongValue2 = ((Long) obj2).longValue();
            String str = (String) pigeonVar_list.get(2);
            String str2 = (String) pigeonVar_list.get(3);
            Object obj3 = pigeonVar_list.get(4);
            Intrinsics.checkNotNull(obj3, "null cannot be cast to non-null type kotlin.Boolean");
            return new ExoPlayerAudioTrackData(jLongValue, jLongValue2, str, str2, ((Boolean) obj3).booleanValue(), (Long) pigeonVar_list.get(5), (Long) pigeonVar_list.get(6), (Long) pigeonVar_list.get(7), (String) pigeonVar_list.get(8));
        }
    }

    public final List<Object> toList() {
        return CollectionsKt.listOf(Long.valueOf(this.groupIndex), Long.valueOf(this.trackIndex), this.label, this.language, Boolean.valueOf(this.isSelected), this.bitrate, this.sampleRate, this.channelCount, this.codec);
    }

    public boolean equals(Object other) {
        if (!(other instanceof ExoPlayerAudioTrackData)) {
            return false;
        }
        if (this == other) {
            return true;
        }
        return MessagesPigeonUtils.INSTANCE.deepEquals(toList(), ((ExoPlayerAudioTrackData) other).toList());
    }

    public int hashCode() {
        return toList().hashCode();
    }
}
