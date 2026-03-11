package io.flutter.plugins.googlesignin;

import androidx.media3.container.NalUnitUtil;
import java.util.List;
import kotlin.Metadata;
import kotlin.collections.CollectionsKt;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: Messages.kt */
/* JADX INFO: loaded from: classes3.dex */
@Metadata(d1 = {"\u0000(\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000e\n\u0000\n\u0002\u0010 \n\u0002\b\b\n\u0002\u0010\u000b\n\u0002\b\u0002\n\u0002\u0010\b\n\u0002\b\u0006\b\u0086\b\u0018\u0000 \u00162\u00020\u0001:\u0001\u0016B\u001d\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\f\u0010\u0004\u001a\b\u0012\u0004\u0012\u00020\u00030\u0005¢\u0006\u0004\b\u0006\u0010\u0007J\u000e\u0010\f\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0005J\u0013\u0010\r\u001a\u00020\u000e2\b\u0010\u000f\u001a\u0004\u0018\u00010\u0001H\u0096\u0002J\b\u0010\u0010\u001a\u00020\u0011H\u0016J\t\u0010\u0012\u001a\u00020\u0003HÆ\u0003J\u000f\u0010\u0013\u001a\b\u0012\u0004\u0012\u00020\u00030\u0005HÆ\u0003J#\u0010\u0014\u001a\u00020\u00002\b\b\u0002\u0010\u0002\u001a\u00020\u00032\u000e\b\u0002\u0010\u0004\u001a\b\u0012\u0004\u0012\u00020\u00030\u0005HÆ\u0001J\t\u0010\u0015\u001a\u00020\u0003HÖ\u0001R\u0011\u0010\u0002\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\b\u0010\tR\u0017\u0010\u0004\u001a\b\u0012\u0004\u0012\u00020\u00030\u0005¢\u0006\b\n\u0000\u001a\u0004\b\n\u0010\u000b¨\u0006\u0017"}, d2 = {"Lio/flutter/plugins/googlesignin/PlatformRevokeAccessRequest;", "", "accountEmail", "", "scopes", "", "<init>", "(Ljava/lang/String;Ljava/util/List;)V", "getAccountEmail", "()Ljava/lang/String;", "getScopes", "()Ljava/util/List;", "toList", "equals", "", "other", "hashCode", "", "component1", "component2", "copy", "toString", "Companion", "google_sign_in_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final /* data */ class PlatformRevokeAccessRequest {

    /* JADX INFO: renamed from: Companion, reason: from kotlin metadata */
    public static final Companion INSTANCE = new Companion(null);
    private final String accountEmail;
    private final List<String> scopes;

    /* JADX WARN: Multi-variable type inference failed */
    public static /* synthetic */ PlatformRevokeAccessRequest copy$default(PlatformRevokeAccessRequest platformRevokeAccessRequest, String str, List list, int i, Object obj) {
        if ((i & 1) != 0) {
            str = platformRevokeAccessRequest.accountEmail;
        }
        if ((i & 2) != 0) {
            list = platformRevokeAccessRequest.scopes;
        }
        return platformRevokeAccessRequest.copy(str, list);
    }

    /* JADX INFO: renamed from: component1, reason: from getter */
    public final String getAccountEmail() {
        return this.accountEmail;
    }

    public final List<String> component2() {
        return this.scopes;
    }

    public final PlatformRevokeAccessRequest copy(String accountEmail, List<String> scopes) {
        Intrinsics.checkNotNullParameter(accountEmail, "accountEmail");
        Intrinsics.checkNotNullParameter(scopes, "scopes");
        return new PlatformRevokeAccessRequest(accountEmail, scopes);
    }

    public String toString() {
        return "PlatformRevokeAccessRequest(accountEmail=" + this.accountEmail + ", scopes=" + this.scopes + ")";
    }

    public PlatformRevokeAccessRequest(String accountEmail, List<String> scopes) {
        Intrinsics.checkNotNullParameter(accountEmail, "accountEmail");
        Intrinsics.checkNotNullParameter(scopes, "scopes");
        this.accountEmail = accountEmail;
        this.scopes = scopes;
    }

    public final String getAccountEmail() {
        return this.accountEmail;
    }

    public final List<String> getScopes() {
        return this.scopes;
    }

    /* JADX INFO: compiled from: Messages.kt */
    @Metadata(d1 = {"\u0000\u0018\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010 \n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\t\b\u0002¢\u0006\u0004\b\u0002\u0010\u0003J\u0016\u0010\u0004\u001a\u00020\u00052\u000e\u0010\u0006\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0007¨\u0006\b"}, d2 = {"Lio/flutter/plugins/googlesignin/PlatformRevokeAccessRequest$Companion;", "", "<init>", "()V", "fromList", "Lio/flutter/plugins/googlesignin/PlatformRevokeAccessRequest;", "pigeonVar_list", "", "google_sign_in_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }

        public final PlatformRevokeAccessRequest fromList(List<? extends Object> pigeonVar_list) {
            Intrinsics.checkNotNullParameter(pigeonVar_list, "pigeonVar_list");
            Object obj = pigeonVar_list.get(0);
            Intrinsics.checkNotNull(obj, "null cannot be cast to non-null type kotlin.String");
            Object obj2 = pigeonVar_list.get(1);
            Intrinsics.checkNotNull(obj2, "null cannot be cast to non-null type kotlin.collections.List<kotlin.String>");
            return new PlatformRevokeAccessRequest((String) obj, (List) obj2);
        }
    }

    public final List<Object> toList() {
        return CollectionsKt.listOf(this.accountEmail, this.scopes);
    }

    public boolean equals(Object other) {
        if (!(other instanceof PlatformRevokeAccessRequest)) {
            return false;
        }
        if (this == other) {
            return true;
        }
        return MessagesPigeonUtils.INSTANCE.deepEquals(toList(), ((PlatformRevokeAccessRequest) other).toList());
    }

    public int hashCode() {
        return toList().hashCode();
    }
}
