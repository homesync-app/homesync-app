package io.flutter.plugins.videoplayer;

import androidx.media3.container.NalUnitUtil;
import androidx.media3.extractor.text.ttml.TtmlNode;
import com.google.firebase.messaging.Constants;
import java.util.List;
import kotlin.Metadata;
import kotlin.collections.CollectionsKt;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: Messages.kt */
/* JADX INFO: loaded from: classes4.dex */
@Metadata(d1 = {"\u00000\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000e\n\u0002\b\u0003\n\u0002\u0010\u000b\n\u0000\n\u0002\u0010\t\n\u0002\b\u0011\n\u0002\u0010 \n\u0002\b\u0003\n\u0002\u0010\b\n\u0002\b\r\b\u0086\b\u0018\u0000 +2\u00020\u0001:\u0001+BW\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0006\u0010\u0004\u001a\u00020\u0003\u0012\u0006\u0010\u0005\u001a\u00020\u0003\u0012\u0006\u0010\u0006\u001a\u00020\u0007\u0012\n\b\u0002\u0010\b\u001a\u0004\u0018\u00010\t\u0012\n\b\u0002\u0010\n\u001a\u0004\u0018\u00010\t\u0012\n\b\u0002\u0010\u000b\u001a\u0004\u0018\u00010\t\u0012\n\b\u0002\u0010\f\u001a\u0004\u0018\u00010\u0003¢\u0006\u0004\b\r\u0010\u000eJ\u000e\u0010\u001a\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u001bJ\u0013\u0010\u001c\u001a\u00020\u00072\b\u0010\u001d\u001a\u0004\u0018\u00010\u0001H\u0096\u0002J\b\u0010\u001e\u001a\u00020\u001fH\u0016J\t\u0010 \u001a\u00020\u0003HÆ\u0003J\t\u0010!\u001a\u00020\u0003HÆ\u0003J\t\u0010\"\u001a\u00020\u0003HÆ\u0003J\t\u0010#\u001a\u00020\u0007HÆ\u0003J\u0010\u0010$\u001a\u0004\u0018\u00010\tHÆ\u0003¢\u0006\u0002\u0010\u0015J\u0010\u0010%\u001a\u0004\u0018\u00010\tHÆ\u0003¢\u0006\u0002\u0010\u0015J\u0010\u0010&\u001a\u0004\u0018\u00010\tHÆ\u0003¢\u0006\u0002\u0010\u0015J\u000b\u0010'\u001a\u0004\u0018\u00010\u0003HÆ\u0003Jf\u0010(\u001a\u00020\u00002\b\b\u0002\u0010\u0002\u001a\u00020\u00032\b\b\u0002\u0010\u0004\u001a\u00020\u00032\b\b\u0002\u0010\u0005\u001a\u00020\u00032\b\b\u0002\u0010\u0006\u001a\u00020\u00072\n\b\u0002\u0010\b\u001a\u0004\u0018\u00010\t2\n\b\u0002\u0010\n\u001a\u0004\u0018\u00010\t2\n\b\u0002\u0010\u000b\u001a\u0004\u0018\u00010\t2\n\b\u0002\u0010\f\u001a\u0004\u0018\u00010\u0003HÆ\u0001¢\u0006\u0002\u0010)J\t\u0010*\u001a\u00020\u0003HÖ\u0001R\u0011\u0010\u0002\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u000f\u0010\u0010R\u0011\u0010\u0004\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u0011\u0010\u0010R\u0011\u0010\u0005\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u0012\u0010\u0010R\u0011\u0010\u0006\u001a\u00020\u0007¢\u0006\b\n\u0000\u001a\u0004\b\u0006\u0010\u0013R\u0015\u0010\b\u001a\u0004\u0018\u00010\t¢\u0006\n\n\u0002\u0010\u0016\u001a\u0004\b\u0014\u0010\u0015R\u0015\u0010\n\u001a\u0004\u0018\u00010\t¢\u0006\n\n\u0002\u0010\u0016\u001a\u0004\b\u0017\u0010\u0015R\u0015\u0010\u000b\u001a\u0004\u0018\u00010\t¢\u0006\n\n\u0002\u0010\u0016\u001a\u0004\b\u0018\u0010\u0015R\u0013\u0010\f\u001a\u0004\u0018\u00010\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u0019\u0010\u0010¨\u0006,"}, d2 = {"Lio/flutter/plugins/videoplayer/AudioTrackMessage;", "", TtmlNode.ATTR_ID, "", Constants.ScionAnalytics.PARAM_LABEL, "language", "isSelected", "", "bitrate", "", "sampleRate", "channelCount", "codec", "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZLjava/lang/Long;Ljava/lang/Long;Ljava/lang/Long;Ljava/lang/String;)V", "getId", "()Ljava/lang/String;", "getLabel", "getLanguage", "()Z", "getBitrate", "()Ljava/lang/Long;", "Ljava/lang/Long;", "getSampleRate", "getChannelCount", "getCodec", "toList", "", "equals", "other", "hashCode", "", "component1", "component2", "component3", "component4", "component5", "component6", "component7", "component8", "copy", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZLjava/lang/Long;Ljava/lang/Long;Ljava/lang/Long;Ljava/lang/String;)Lio/flutter/plugins/videoplayer/AudioTrackMessage;", "toString", "Companion", "video_player_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final /* data */ class AudioTrackMessage {

    /* JADX INFO: renamed from: Companion, reason: from kotlin metadata */
    public static final Companion INSTANCE = new Companion(null);
    private final Long bitrate;
    private final Long channelCount;
    private final String codec;
    private final String id;
    private final boolean isSelected;
    private final String label;
    private final String language;
    private final Long sampleRate;

    public static /* synthetic */ AudioTrackMessage copy$default(AudioTrackMessage audioTrackMessage, String str, String str2, String str3, boolean z, Long l, Long l2, Long l3, String str4, int i, Object obj) {
        if ((i & 1) != 0) {
            str = audioTrackMessage.id;
        }
        if ((i & 2) != 0) {
            str2 = audioTrackMessage.label;
        }
        if ((i & 4) != 0) {
            str3 = audioTrackMessage.language;
        }
        if ((i & 8) != 0) {
            z = audioTrackMessage.isSelected;
        }
        if ((i & 16) != 0) {
            l = audioTrackMessage.bitrate;
        }
        if ((i & 32) != 0) {
            l2 = audioTrackMessage.sampleRate;
        }
        if ((i & 64) != 0) {
            l3 = audioTrackMessage.channelCount;
        }
        if ((i & 128) != 0) {
            str4 = audioTrackMessage.codec;
        }
        Long l4 = l3;
        String str5 = str4;
        Long l5 = l;
        Long l6 = l2;
        return audioTrackMessage.copy(str, str2, str3, z, l5, l6, l4, str5);
    }

    /* JADX INFO: renamed from: component1, reason: from getter */
    public final String getId() {
        return this.id;
    }

    /* JADX INFO: renamed from: component2, reason: from getter */
    public final String getLabel() {
        return this.label;
    }

    /* JADX INFO: renamed from: component3, reason: from getter */
    public final String getLanguage() {
        return this.language;
    }

    /* JADX INFO: renamed from: component4, reason: from getter */
    public final boolean getIsSelected() {
        return this.isSelected;
    }

    /* JADX INFO: renamed from: component5, reason: from getter */
    public final Long getBitrate() {
        return this.bitrate;
    }

    /* JADX INFO: renamed from: component6, reason: from getter */
    public final Long getSampleRate() {
        return this.sampleRate;
    }

    /* JADX INFO: renamed from: component7, reason: from getter */
    public final Long getChannelCount() {
        return this.channelCount;
    }

    /* JADX INFO: renamed from: component8, reason: from getter */
    public final String getCodec() {
        return this.codec;
    }

    public final AudioTrackMessage copy(String id, String label, String language, boolean isSelected, Long bitrate, Long sampleRate, Long channelCount, String codec) {
        Intrinsics.checkNotNullParameter(id, "id");
        Intrinsics.checkNotNullParameter(label, "label");
        Intrinsics.checkNotNullParameter(language, "language");
        return new AudioTrackMessage(id, label, language, isSelected, bitrate, sampleRate, channelCount, codec);
    }

    public String toString() {
        return "AudioTrackMessage(id=" + this.id + ", label=" + this.label + ", language=" + this.language + ", isSelected=" + this.isSelected + ", bitrate=" + this.bitrate + ", sampleRate=" + this.sampleRate + ", channelCount=" + this.channelCount + ", codec=" + this.codec + ")";
    }

    public AudioTrackMessage(String id, String label, String language, boolean z, Long l, Long l2, Long l3, String str) {
        Intrinsics.checkNotNullParameter(id, "id");
        Intrinsics.checkNotNullParameter(label, "label");
        Intrinsics.checkNotNullParameter(language, "language");
        this.id = id;
        this.label = label;
        this.language = language;
        this.isSelected = z;
        this.bitrate = l;
        this.sampleRate = l2;
        this.channelCount = l3;
        this.codec = str;
    }

    public /* synthetic */ AudioTrackMessage(String str, String str2, String str3, boolean z, Long l, Long l2, Long l3, String str4, int i, DefaultConstructorMarker defaultConstructorMarker) {
        this(str, str2, str3, z, (i & 16) != 0 ? null : l, (i & 32) != 0 ? null : l2, (i & 64) != 0 ? null : l3, (i & 128) != 0 ? null : str4);
    }

    public final String getId() {
        return this.id;
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
    @Metadata(d1 = {"\u0000\u0018\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010 \n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\t\b\u0002¢\u0006\u0004\b\u0002\u0010\u0003J\u0016\u0010\u0004\u001a\u00020\u00052\u000e\u0010\u0006\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0007¨\u0006\b"}, d2 = {"Lio/flutter/plugins/videoplayer/AudioTrackMessage$Companion;", "", "<init>", "()V", "fromList", "Lio/flutter/plugins/videoplayer/AudioTrackMessage;", "pigeonVar_list", "", "video_player_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }

        public final AudioTrackMessage fromList(List<? extends Object> pigeonVar_list) {
            Intrinsics.checkNotNullParameter(pigeonVar_list, "pigeonVar_list");
            Object obj = pigeonVar_list.get(0);
            Intrinsics.checkNotNull(obj, "null cannot be cast to non-null type kotlin.String");
            String str = (String) obj;
            Object obj2 = pigeonVar_list.get(1);
            Intrinsics.checkNotNull(obj2, "null cannot be cast to non-null type kotlin.String");
            String str2 = (String) obj2;
            Object obj3 = pigeonVar_list.get(2);
            Intrinsics.checkNotNull(obj3, "null cannot be cast to non-null type kotlin.String");
            String str3 = (String) obj3;
            Object obj4 = pigeonVar_list.get(3);
            Intrinsics.checkNotNull(obj4, "null cannot be cast to non-null type kotlin.Boolean");
            return new AudioTrackMessage(str, str2, str3, ((Boolean) obj4).booleanValue(), (Long) pigeonVar_list.get(4), (Long) pigeonVar_list.get(5), (Long) pigeonVar_list.get(6), (String) pigeonVar_list.get(7));
        }
    }

    public final List<Object> toList() {
        return CollectionsKt.listOf(this.id, this.label, this.language, Boolean.valueOf(this.isSelected), this.bitrate, this.sampleRate, this.channelCount, this.codec);
    }

    public boolean equals(Object other) {
        if (!(other instanceof AudioTrackMessage)) {
            return false;
        }
        if (this == other) {
            return true;
        }
        return MessagesPigeonUtils.INSTANCE.deepEquals(toList(), ((AudioTrackMessage) other).toList());
    }

    public int hashCode() {
        return toList().hashCode();
    }
}
