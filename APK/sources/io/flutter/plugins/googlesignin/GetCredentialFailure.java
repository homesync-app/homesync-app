package io.flutter.plugins.googlesignin;

import androidx.media3.container.NalUnitUtil;
import androidx.media3.exoplayer.rtsp.SessionDescription;
import java.util.List;
import kotlin.Metadata;
import kotlin.collections.CollectionsKt;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: Messages.kt */
/* JADX INFO: loaded from: classes3.dex */
@Metadata(d1 = {"\u00002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u000e\n\u0002\b\t\n\u0002\u0010 \n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000b\n\u0002\b\u0002\n\u0002\u0010\b\n\u0002\b\u0007\b\u0086\b\u0018\u0000 \u001b2\u00020\u0001:\u0001\u001bB'\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\n\b\u0002\u0010\u0004\u001a\u0004\u0018\u00010\u0005\u0012\n\b\u0002\u0010\u0006\u001a\u0004\u0018\u00010\u0005¢\u0006\u0004\b\u0007\u0010\bJ\u000e\u0010\u000e\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00100\u000fJ\u0013\u0010\u0011\u001a\u00020\u00122\b\u0010\u0013\u001a\u0004\u0018\u00010\u0010H\u0096\u0002J\b\u0010\u0014\u001a\u00020\u0015H\u0016J\t\u0010\u0016\u001a\u00020\u0003HÆ\u0003J\u000b\u0010\u0017\u001a\u0004\u0018\u00010\u0005HÆ\u0003J\u000b\u0010\u0018\u001a\u0004\u0018\u00010\u0005HÆ\u0003J+\u0010\u0019\u001a\u00020\u00002\b\b\u0002\u0010\u0002\u001a\u00020\u00032\n\b\u0002\u0010\u0004\u001a\u0004\u0018\u00010\u00052\n\b\u0002\u0010\u0006\u001a\u0004\u0018\u00010\u0005HÆ\u0001J\t\u0010\u001a\u001a\u00020\u0005HÖ\u0001R\u0011\u0010\u0002\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\t\u0010\nR\u0013\u0010\u0004\u001a\u0004\u0018\u00010\u0005¢\u0006\b\n\u0000\u001a\u0004\b\u000b\u0010\fR\u0013\u0010\u0006\u001a\u0004\u0018\u00010\u0005¢\u0006\b\n\u0000\u001a\u0004\b\r\u0010\f¨\u0006\u001c"}, d2 = {"Lio/flutter/plugins/googlesignin/GetCredentialFailure;", "Lio/flutter/plugins/googlesignin/GetCredentialResult;", SessionDescription.ATTR_TYPE, "Lio/flutter/plugins/googlesignin/GetCredentialFailureType;", "message", "", "details", "<init>", "(Lio/flutter/plugins/googlesignin/GetCredentialFailureType;Ljava/lang/String;Ljava/lang/String;)V", "getType", "()Lio/flutter/plugins/googlesignin/GetCredentialFailureType;", "getMessage", "()Ljava/lang/String;", "getDetails", "toList", "", "", "equals", "", "other", "hashCode", "", "component1", "component2", "component3", "copy", "toString", "Companion", "google_sign_in_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final /* data */ class GetCredentialFailure extends GetCredentialResult {

    /* JADX INFO: renamed from: Companion, reason: from kotlin metadata */
    public static final Companion INSTANCE = new Companion(null);
    private final String details;
    private final String message;
    private final GetCredentialFailureType type;

    public static /* synthetic */ GetCredentialFailure copy$default(GetCredentialFailure getCredentialFailure, GetCredentialFailureType getCredentialFailureType, String str, String str2, int i, Object obj) {
        if ((i & 1) != 0) {
            getCredentialFailureType = getCredentialFailure.type;
        }
        if ((i & 2) != 0) {
            str = getCredentialFailure.message;
        }
        if ((i & 4) != 0) {
            str2 = getCredentialFailure.details;
        }
        return getCredentialFailure.copy(getCredentialFailureType, str, str2);
    }

    /* JADX INFO: renamed from: component1, reason: from getter */
    public final GetCredentialFailureType getType() {
        return this.type;
    }

    /* JADX INFO: renamed from: component2, reason: from getter */
    public final String getMessage() {
        return this.message;
    }

    /* JADX INFO: renamed from: component3, reason: from getter */
    public final String getDetails() {
        return this.details;
    }

    public final GetCredentialFailure copy(GetCredentialFailureType type, String message, String details) {
        Intrinsics.checkNotNullParameter(type, "type");
        return new GetCredentialFailure(type, message, details);
    }

    public String toString() {
        return "GetCredentialFailure(type=" + this.type + ", message=" + this.message + ", details=" + this.details + ")";
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public GetCredentialFailure(GetCredentialFailureType type, String str, String str2) {
        super(null);
        Intrinsics.checkNotNullParameter(type, "type");
        this.type = type;
        this.message = str;
        this.details = str2;
    }

    public /* synthetic */ GetCredentialFailure(GetCredentialFailureType getCredentialFailureType, String str, String str2, int i, DefaultConstructorMarker defaultConstructorMarker) {
        this(getCredentialFailureType, (i & 2) != 0 ? null : str, (i & 4) != 0 ? null : str2);
    }

    public final GetCredentialFailureType getType() {
        return this.type;
    }

    public final String getMessage() {
        return this.message;
    }

    public final String getDetails() {
        return this.details;
    }

    /* JADX INFO: compiled from: Messages.kt */
    @Metadata(d1 = {"\u0000\u0018\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010 \n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\t\b\u0002¢\u0006\u0004\b\u0002\u0010\u0003J\u0016\u0010\u0004\u001a\u00020\u00052\u000e\u0010\u0006\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0007¨\u0006\b"}, d2 = {"Lio/flutter/plugins/googlesignin/GetCredentialFailure$Companion;", "", "<init>", "()V", "fromList", "Lio/flutter/plugins/googlesignin/GetCredentialFailure;", "pigeonVar_list", "", "google_sign_in_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }

        public final GetCredentialFailure fromList(List<? extends Object> pigeonVar_list) {
            Intrinsics.checkNotNullParameter(pigeonVar_list, "pigeonVar_list");
            Object obj = pigeonVar_list.get(0);
            Intrinsics.checkNotNull(obj, "null cannot be cast to non-null type io.flutter.plugins.googlesignin.GetCredentialFailureType");
            return new GetCredentialFailure((GetCredentialFailureType) obj, (String) pigeonVar_list.get(1), (String) pigeonVar_list.get(2));
        }
    }

    public final List<Object> toList() {
        return CollectionsKt.listOf(this.type, this.message, this.details);
    }

    public boolean equals(Object other) {
        if (!(other instanceof GetCredentialFailure)) {
            return false;
        }
        if (this == other) {
            return true;
        }
        return MessagesPigeonUtils.INSTANCE.deepEquals(toList(), ((GetCredentialFailure) other).toList());
    }

    public int hashCode() {
        return toList().hashCode();
    }
}
