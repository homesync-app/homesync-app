package io.flutter.plugins.googlesignin;

import androidx.media3.container.NalUnitUtil;
import java.util.List;
import kotlin.Metadata;
import kotlin.collections.CollectionsKt;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: Messages.kt */
/* JADX INFO: loaded from: classes3.dex */
@Metadata(d1 = {"\u0000&\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010 \n\u0002\u0010\u000e\n\u0002\b\r\n\u0002\u0010\u000b\n\u0002\b\u0002\n\u0002\u0010\b\n\u0002\b\b\b\u0086\b\u0018\u0000 \u001c2\u00020\u0001:\u0001\u001cB9\u0012\f\u0010\u0002\u001a\b\u0012\u0004\u0012\u00020\u00040\u0003\u0012\n\b\u0002\u0010\u0005\u001a\u0004\u0018\u00010\u0004\u0012\n\b\u0002\u0010\u0006\u001a\u0004\u0018\u00010\u0004\u0012\n\b\u0002\u0010\u0007\u001a\u0004\u0018\u00010\u0004¢\u0006\u0004\b\b\u0010\tJ\u000e\u0010\u0010\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0003J\u0013\u0010\u0011\u001a\u00020\u00122\b\u0010\u0013\u001a\u0004\u0018\u00010\u0001H\u0096\u0002J\b\u0010\u0014\u001a\u00020\u0015H\u0016J\u000f\u0010\u0016\u001a\b\u0012\u0004\u0012\u00020\u00040\u0003HÆ\u0003J\u000b\u0010\u0017\u001a\u0004\u0018\u00010\u0004HÆ\u0003J\u000b\u0010\u0018\u001a\u0004\u0018\u00010\u0004HÆ\u0003J\u000b\u0010\u0019\u001a\u0004\u0018\u00010\u0004HÆ\u0003J=\u0010\u001a\u001a\u00020\u00002\u000e\b\u0002\u0010\u0002\u001a\b\u0012\u0004\u0012\u00020\u00040\u00032\n\b\u0002\u0010\u0005\u001a\u0004\u0018\u00010\u00042\n\b\u0002\u0010\u0006\u001a\u0004\u0018\u00010\u00042\n\b\u0002\u0010\u0007\u001a\u0004\u0018\u00010\u0004HÆ\u0001J\t\u0010\u001b\u001a\u00020\u0004HÖ\u0001R\u0017\u0010\u0002\u001a\b\u0012\u0004\u0012\u00020\u00040\u0003¢\u0006\b\n\u0000\u001a\u0004\b\n\u0010\u000bR\u0013\u0010\u0005\u001a\u0004\u0018\u00010\u0004¢\u0006\b\n\u0000\u001a\u0004\b\f\u0010\rR\u0013\u0010\u0006\u001a\u0004\u0018\u00010\u0004¢\u0006\b\n\u0000\u001a\u0004\b\u000e\u0010\rR\u0013\u0010\u0007\u001a\u0004\u0018\u00010\u0004¢\u0006\b\n\u0000\u001a\u0004\b\u000f\u0010\r¨\u0006\u001d"}, d2 = {"Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest;", "", "scopes", "", "", "hostedDomain", "accountEmail", "serverClientIdForForcedRefreshToken", "<init>", "(Ljava/util/List;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V", "getScopes", "()Ljava/util/List;", "getHostedDomain", "()Ljava/lang/String;", "getAccountEmail", "getServerClientIdForForcedRefreshToken", "toList", "equals", "", "other", "hashCode", "", "component1", "component2", "component3", "component4", "copy", "toString", "Companion", "google_sign_in_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final /* data */ class PlatformAuthorizationRequest {

    /* JADX INFO: renamed from: Companion, reason: from kotlin metadata */
    public static final Companion INSTANCE = new Companion(null);
    private final String accountEmail;
    private final String hostedDomain;
    private final List<String> scopes;
    private final String serverClientIdForForcedRefreshToken;

    /* JADX WARN: Multi-variable type inference failed */
    public static /* synthetic */ PlatformAuthorizationRequest copy$default(PlatformAuthorizationRequest platformAuthorizationRequest, List list, String str, String str2, String str3, int i, Object obj) {
        if ((i & 1) != 0) {
            list = platformAuthorizationRequest.scopes;
        }
        if ((i & 2) != 0) {
            str = platformAuthorizationRequest.hostedDomain;
        }
        if ((i & 4) != 0) {
            str2 = platformAuthorizationRequest.accountEmail;
        }
        if ((i & 8) != 0) {
            str3 = platformAuthorizationRequest.serverClientIdForForcedRefreshToken;
        }
        return platformAuthorizationRequest.copy(list, str, str2, str3);
    }

    public final List<String> component1() {
        return this.scopes;
    }

    /* JADX INFO: renamed from: component2, reason: from getter */
    public final String getHostedDomain() {
        return this.hostedDomain;
    }

    /* JADX INFO: renamed from: component3, reason: from getter */
    public final String getAccountEmail() {
        return this.accountEmail;
    }

    /* JADX INFO: renamed from: component4, reason: from getter */
    public final String getServerClientIdForForcedRefreshToken() {
        return this.serverClientIdForForcedRefreshToken;
    }

    public final PlatformAuthorizationRequest copy(List<String> scopes, String hostedDomain, String accountEmail, String serverClientIdForForcedRefreshToken) {
        Intrinsics.checkNotNullParameter(scopes, "scopes");
        return new PlatformAuthorizationRequest(scopes, hostedDomain, accountEmail, serverClientIdForForcedRefreshToken);
    }

    public String toString() {
        return "PlatformAuthorizationRequest(scopes=" + this.scopes + ", hostedDomain=" + this.hostedDomain + ", accountEmail=" + this.accountEmail + ", serverClientIdForForcedRefreshToken=" + this.serverClientIdForForcedRefreshToken + ")";
    }

    public PlatformAuthorizationRequest(List<String> scopes, String str, String str2, String str3) {
        Intrinsics.checkNotNullParameter(scopes, "scopes");
        this.scopes = scopes;
        this.hostedDomain = str;
        this.accountEmail = str2;
        this.serverClientIdForForcedRefreshToken = str3;
    }

    public /* synthetic */ PlatformAuthorizationRequest(List list, String str, String str2, String str3, int i, DefaultConstructorMarker defaultConstructorMarker) {
        this(list, (i & 2) != 0 ? null : str, (i & 4) != 0 ? null : str2, (i & 8) != 0 ? null : str3);
    }

    public final List<String> getScopes() {
        return this.scopes;
    }

    public final String getHostedDomain() {
        return this.hostedDomain;
    }

    public final String getAccountEmail() {
        return this.accountEmail;
    }

    public final String getServerClientIdForForcedRefreshToken() {
        return this.serverClientIdForForcedRefreshToken;
    }

    /* JADX INFO: compiled from: Messages.kt */
    @Metadata(d1 = {"\u0000\u0018\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010 \n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\t\b\u0002¢\u0006\u0004\b\u0002\u0010\u0003J\u0016\u0010\u0004\u001a\u00020\u00052\u000e\u0010\u0006\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0007¨\u0006\b"}, d2 = {"Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest$Companion;", "", "<init>", "()V", "fromList", "Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest;", "pigeonVar_list", "", "google_sign_in_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }

        public final PlatformAuthorizationRequest fromList(List<? extends Object> pigeonVar_list) {
            Intrinsics.checkNotNullParameter(pigeonVar_list, "pigeonVar_list");
            Object obj = pigeonVar_list.get(0);
            Intrinsics.checkNotNull(obj, "null cannot be cast to non-null type kotlin.collections.List<kotlin.String>");
            return new PlatformAuthorizationRequest((List) obj, (String) pigeonVar_list.get(1), (String) pigeonVar_list.get(2), (String) pigeonVar_list.get(3));
        }
    }

    public final List<Object> toList() {
        return CollectionsKt.listOf(this.scopes, this.hostedDomain, this.accountEmail, this.serverClientIdForForcedRefreshToken);
    }

    public boolean equals(Object other) {
        if (!(other instanceof PlatformAuthorizationRequest)) {
            return false;
        }
        if (this == other) {
            return true;
        }
        return MessagesPigeonUtils.INSTANCE.deepEquals(toList(), ((PlatformAuthorizationRequest) other).toList());
    }

    public int hashCode() {
        return toList().hashCode();
    }
}
