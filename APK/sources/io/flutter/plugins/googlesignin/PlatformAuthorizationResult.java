package io.flutter.plugins.googlesignin;

import androidx.media3.container.NalUnitUtil;
import io.flutter.plugins.firebase.auth.Constants;
import java.util.List;
import kotlin.Metadata;
import kotlin.collections.CollectionsKt;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: Messages.kt */
/* JADX INFO: loaded from: classes3.dex */
@Metadata(d1 = {"\u00000\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u000e\n\u0002\b\u0002\n\u0002\u0010 \n\u0002\b\b\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000b\n\u0002\b\u0002\n\u0002\u0010\b\n\u0002\b\u0007\b\u0086\b\u0018\u0000 \u001a2\u00020\u0001:\u0001\u001aB-\u0012\n\b\u0002\u0010\u0002\u001a\u0004\u0018\u00010\u0003\u0012\n\b\u0002\u0010\u0004\u001a\u0004\u0018\u00010\u0003\u0012\f\u0010\u0005\u001a\b\u0012\u0004\u0012\u00020\u00030\u0006¢\u0006\u0004\b\u0007\u0010\bJ\u000e\u0010\u000e\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u000f0\u0006J\u0013\u0010\u0010\u001a\u00020\u00112\b\u0010\u0012\u001a\u0004\u0018\u00010\u000fH\u0096\u0002J\b\u0010\u0013\u001a\u00020\u0014H\u0016J\u000b\u0010\u0015\u001a\u0004\u0018\u00010\u0003HÆ\u0003J\u000b\u0010\u0016\u001a\u0004\u0018\u00010\u0003HÆ\u0003J\u000f\u0010\u0017\u001a\b\u0012\u0004\u0012\u00020\u00030\u0006HÆ\u0003J1\u0010\u0018\u001a\u00020\u00002\n\b\u0002\u0010\u0002\u001a\u0004\u0018\u00010\u00032\n\b\u0002\u0010\u0004\u001a\u0004\u0018\u00010\u00032\u000e\b\u0002\u0010\u0005\u001a\b\u0012\u0004\u0012\u00020\u00030\u0006HÆ\u0001J\t\u0010\u0019\u001a\u00020\u0003HÖ\u0001R\u0013\u0010\u0002\u001a\u0004\u0018\u00010\u0003¢\u0006\b\n\u0000\u001a\u0004\b\t\u0010\nR\u0013\u0010\u0004\u001a\u0004\u0018\u00010\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u000b\u0010\nR\u0017\u0010\u0005\u001a\b\u0012\u0004\u0012\u00020\u00030\u0006¢\u0006\b\n\u0000\u001a\u0004\b\f\u0010\r¨\u0006\u001b"}, d2 = {"Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;", "Lio/flutter/plugins/googlesignin/AuthorizeResult;", Constants.ACCESS_TOKEN, "", Constants.SERVER_AUTH_CODE, "grantedScopes", "", "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/util/List;)V", "getAccessToken", "()Ljava/lang/String;", "getServerAuthCode", "getGrantedScopes", "()Ljava/util/List;", "toList", "", "equals", "", "other", "hashCode", "", "component1", "component2", "component3", "copy", "toString", "Companion", "google_sign_in_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final /* data */ class PlatformAuthorizationResult extends AuthorizeResult {

    /* JADX INFO: renamed from: Companion, reason: from kotlin metadata */
    public static final Companion INSTANCE = new Companion(null);
    private final String accessToken;
    private final List<String> grantedScopes;
    private final String serverAuthCode;

    /* JADX WARN: Multi-variable type inference failed */
    public static /* synthetic */ PlatformAuthorizationResult copy$default(PlatformAuthorizationResult platformAuthorizationResult, String str, String str2, List list, int i, Object obj) {
        if ((i & 1) != 0) {
            str = platformAuthorizationResult.accessToken;
        }
        if ((i & 2) != 0) {
            str2 = platformAuthorizationResult.serverAuthCode;
        }
        if ((i & 4) != 0) {
            list = platformAuthorizationResult.grantedScopes;
        }
        return platformAuthorizationResult.copy(str, str2, list);
    }

    /* JADX INFO: renamed from: component1, reason: from getter */
    public final String getAccessToken() {
        return this.accessToken;
    }

    /* JADX INFO: renamed from: component2, reason: from getter */
    public final String getServerAuthCode() {
        return this.serverAuthCode;
    }

    public final List<String> component3() {
        return this.grantedScopes;
    }

    public final PlatformAuthorizationResult copy(String accessToken, String serverAuthCode, List<String> grantedScopes) {
        Intrinsics.checkNotNullParameter(grantedScopes, "grantedScopes");
        return new PlatformAuthorizationResult(accessToken, serverAuthCode, grantedScopes);
    }

    public String toString() {
        return "PlatformAuthorizationResult(accessToken=" + this.accessToken + ", serverAuthCode=" + this.serverAuthCode + ", grantedScopes=" + this.grantedScopes + ")";
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public PlatformAuthorizationResult(String str, String str2, List<String> grantedScopes) {
        super(null);
        Intrinsics.checkNotNullParameter(grantedScopes, "grantedScopes");
        this.accessToken = str;
        this.serverAuthCode = str2;
        this.grantedScopes = grantedScopes;
    }

    public /* synthetic */ PlatformAuthorizationResult(String str, String str2, List list, int i, DefaultConstructorMarker defaultConstructorMarker) {
        this((i & 1) != 0 ? null : str, (i & 2) != 0 ? null : str2, list);
    }

    public final String getAccessToken() {
        return this.accessToken;
    }

    public final String getServerAuthCode() {
        return this.serverAuthCode;
    }

    public final List<String> getGrantedScopes() {
        return this.grantedScopes;
    }

    /* JADX INFO: compiled from: Messages.kt */
    @Metadata(d1 = {"\u0000\u0018\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010 \n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\t\b\u0002¢\u0006\u0004\b\u0002\u0010\u0003J\u0016\u0010\u0004\u001a\u00020\u00052\u000e\u0010\u0006\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0007¨\u0006\b"}, d2 = {"Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult$Companion;", "", "<init>", "()V", "fromList", "Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;", "pigeonVar_list", "", "google_sign_in_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }

        public final PlatformAuthorizationResult fromList(List<? extends Object> pigeonVar_list) {
            Intrinsics.checkNotNullParameter(pigeonVar_list, "pigeonVar_list");
            String str = (String) pigeonVar_list.get(0);
            String str2 = (String) pigeonVar_list.get(1);
            Object obj = pigeonVar_list.get(2);
            Intrinsics.checkNotNull(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.String>");
            return new PlatformAuthorizationResult(str, str2, (List) obj);
        }
    }

    public final List<Object> toList() {
        return CollectionsKt.listOf(this.accessToken, this.serverAuthCode, this.grantedScopes);
    }

    public boolean equals(Object other) {
        if (!(other instanceof PlatformAuthorizationResult)) {
            return false;
        }
        if (this == other) {
            return true;
        }
        return MessagesPigeonUtils.INSTANCE.deepEquals(toList(), ((PlatformAuthorizationResult) other).toList());
    }

    public int hashCode() {
        return toList().hashCode();
    }
}
