package io.flutter.plugins.googlesignin;

import androidx.media3.container.NalUnitUtil;
import java.util.List;
import kotlin.Metadata;
import kotlin.collections.CollectionsKt;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: Messages.kt */
/* JADX INFO: loaded from: classes3.dex */
@Metadata(d1 = {"\u0000.\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000b\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u000e\n\u0002\b\r\n\u0002\u0010 \n\u0002\b\u0003\n\u0002\u0010\b\n\u0002\b\t\b\u0086\b\u0018\u0000 !2\u00020\u0001:\u0001!B;\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0006\u0010\u0004\u001a\u00020\u0005\u0012\n\b\u0002\u0010\u0006\u001a\u0004\u0018\u00010\u0007\u0012\n\b\u0002\u0010\b\u001a\u0004\u0018\u00010\u0007\u0012\n\b\u0002\u0010\t\u001a\u0004\u0018\u00010\u0007¢\u0006\u0004\b\n\u0010\u000bJ\u000e\u0010\u0014\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0015J\u0013\u0010\u0016\u001a\u00020\u00032\b\u0010\u0017\u001a\u0004\u0018\u00010\u0001H\u0096\u0002J\b\u0010\u0018\u001a\u00020\u0019H\u0016J\t\u0010\u001a\u001a\u00020\u0003HÆ\u0003J\t\u0010\u001b\u001a\u00020\u0005HÆ\u0003J\u000b\u0010\u001c\u001a\u0004\u0018\u00010\u0007HÆ\u0003J\u000b\u0010\u001d\u001a\u0004\u0018\u00010\u0007HÆ\u0003J\u000b\u0010\u001e\u001a\u0004\u0018\u00010\u0007HÆ\u0003JA\u0010\u001f\u001a\u00020\u00002\b\b\u0002\u0010\u0002\u001a\u00020\u00032\b\b\u0002\u0010\u0004\u001a\u00020\u00052\n\b\u0002\u0010\u0006\u001a\u0004\u0018\u00010\u00072\n\b\u0002\u0010\b\u001a\u0004\u0018\u00010\u00072\n\b\u0002\u0010\t\u001a\u0004\u0018\u00010\u0007HÆ\u0001J\t\u0010 \u001a\u00020\u0007HÖ\u0001R\u0011\u0010\u0002\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\f\u0010\rR\u0011\u0010\u0004\u001a\u00020\u0005¢\u0006\b\n\u0000\u001a\u0004\b\u000e\u0010\u000fR\u0013\u0010\u0006\u001a\u0004\u0018\u00010\u0007¢\u0006\b\n\u0000\u001a\u0004\b\u0010\u0010\u0011R\u0013\u0010\b\u001a\u0004\u0018\u00010\u0007¢\u0006\b\n\u0000\u001a\u0004\b\u0012\u0010\u0011R\u0013\u0010\t\u001a\u0004\u0018\u00010\u0007¢\u0006\b\n\u0000\u001a\u0004\b\u0013\u0010\u0011¨\u0006\""}, d2 = {"Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;", "", "useButtonFlow", "", "googleIdOptionParams", "Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;", "serverClientId", "", "hostedDomain", "nonce", "<init>", "(ZLio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V", "getUseButtonFlow", "()Z", "getGoogleIdOptionParams", "()Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;", "getServerClientId", "()Ljava/lang/String;", "getHostedDomain", "getNonce", "toList", "", "equals", "other", "hashCode", "", "component1", "component2", "component3", "component4", "component5", "copy", "toString", "Companion", "google_sign_in_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final /* data */ class GetCredentialRequestParams {

    /* JADX INFO: renamed from: Companion, reason: from kotlin metadata */
    public static final Companion INSTANCE = new Companion(null);
    private final GetCredentialRequestGoogleIdOptionParams googleIdOptionParams;
    private final String hostedDomain;
    private final String nonce;
    private final String serverClientId;
    private final boolean useButtonFlow;

    public static /* synthetic */ GetCredentialRequestParams copy$default(GetCredentialRequestParams getCredentialRequestParams, boolean z, GetCredentialRequestGoogleIdOptionParams getCredentialRequestGoogleIdOptionParams, String str, String str2, String str3, int i, Object obj) {
        if ((i & 1) != 0) {
            z = getCredentialRequestParams.useButtonFlow;
        }
        if ((i & 2) != 0) {
            getCredentialRequestGoogleIdOptionParams = getCredentialRequestParams.googleIdOptionParams;
        }
        if ((i & 4) != 0) {
            str = getCredentialRequestParams.serverClientId;
        }
        if ((i & 8) != 0) {
            str2 = getCredentialRequestParams.hostedDomain;
        }
        if ((i & 16) != 0) {
            str3 = getCredentialRequestParams.nonce;
        }
        String str4 = str3;
        String str5 = str;
        return getCredentialRequestParams.copy(z, getCredentialRequestGoogleIdOptionParams, str5, str2, str4);
    }

    /* JADX INFO: renamed from: component1, reason: from getter */
    public final boolean getUseButtonFlow() {
        return this.useButtonFlow;
    }

    /* JADX INFO: renamed from: component2, reason: from getter */
    public final GetCredentialRequestGoogleIdOptionParams getGoogleIdOptionParams() {
        return this.googleIdOptionParams;
    }

    /* JADX INFO: renamed from: component3, reason: from getter */
    public final String getServerClientId() {
        return this.serverClientId;
    }

    /* JADX INFO: renamed from: component4, reason: from getter */
    public final String getHostedDomain() {
        return this.hostedDomain;
    }

    /* JADX INFO: renamed from: component5, reason: from getter */
    public final String getNonce() {
        return this.nonce;
    }

    public final GetCredentialRequestParams copy(boolean useButtonFlow, GetCredentialRequestGoogleIdOptionParams googleIdOptionParams, String serverClientId, String hostedDomain, String nonce) {
        Intrinsics.checkNotNullParameter(googleIdOptionParams, "googleIdOptionParams");
        return new GetCredentialRequestParams(useButtonFlow, googleIdOptionParams, serverClientId, hostedDomain, nonce);
    }

    public String toString() {
        return "GetCredentialRequestParams(useButtonFlow=" + this.useButtonFlow + ", googleIdOptionParams=" + this.googleIdOptionParams + ", serverClientId=" + this.serverClientId + ", hostedDomain=" + this.hostedDomain + ", nonce=" + this.nonce + ")";
    }

    public GetCredentialRequestParams(boolean z, GetCredentialRequestGoogleIdOptionParams googleIdOptionParams, String str, String str2, String str3) {
        Intrinsics.checkNotNullParameter(googleIdOptionParams, "googleIdOptionParams");
        this.useButtonFlow = z;
        this.googleIdOptionParams = googleIdOptionParams;
        this.serverClientId = str;
        this.hostedDomain = str2;
        this.nonce = str3;
    }

    public /* synthetic */ GetCredentialRequestParams(boolean z, GetCredentialRequestGoogleIdOptionParams getCredentialRequestGoogleIdOptionParams, String str, String str2, String str3, int i, DefaultConstructorMarker defaultConstructorMarker) {
        this(z, getCredentialRequestGoogleIdOptionParams, (i & 4) != 0 ? null : str, (i & 8) != 0 ? null : str2, (i & 16) != 0 ? null : str3);
    }

    public final boolean getUseButtonFlow() {
        return this.useButtonFlow;
    }

    public final GetCredentialRequestGoogleIdOptionParams getGoogleIdOptionParams() {
        return this.googleIdOptionParams;
    }

    public final String getServerClientId() {
        return this.serverClientId;
    }

    public final String getHostedDomain() {
        return this.hostedDomain;
    }

    public final String getNonce() {
        return this.nonce;
    }

    /* JADX INFO: compiled from: Messages.kt */
    @Metadata(d1 = {"\u0000\u0018\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010 \n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\t\b\u0002¢\u0006\u0004\b\u0002\u0010\u0003J\u0016\u0010\u0004\u001a\u00020\u00052\u000e\u0010\u0006\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0007¨\u0006\b"}, d2 = {"Lio/flutter/plugins/googlesignin/GetCredentialRequestParams$Companion;", "", "<init>", "()V", "fromList", "Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;", "pigeonVar_list", "", "google_sign_in_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }

        public final GetCredentialRequestParams fromList(List<? extends Object> pigeonVar_list) {
            Intrinsics.checkNotNullParameter(pigeonVar_list, "pigeonVar_list");
            Object obj = pigeonVar_list.get(0);
            Intrinsics.checkNotNull(obj, "null cannot be cast to non-null type kotlin.Boolean");
            boolean zBooleanValue = ((Boolean) obj).booleanValue();
            Object obj2 = pigeonVar_list.get(1);
            Intrinsics.checkNotNull(obj2, "null cannot be cast to non-null type io.flutter.plugins.googlesignin.GetCredentialRequestGoogleIdOptionParams");
            return new GetCredentialRequestParams(zBooleanValue, (GetCredentialRequestGoogleIdOptionParams) obj2, (String) pigeonVar_list.get(2), (String) pigeonVar_list.get(3), (String) pigeonVar_list.get(4));
        }
    }

    public final List<Object> toList() {
        return CollectionsKt.listOf(Boolean.valueOf(this.useButtonFlow), this.googleIdOptionParams, this.serverClientId, this.hostedDomain, this.nonce);
    }

    public boolean equals(Object other) {
        if (!(other instanceof GetCredentialRequestParams)) {
            return false;
        }
        if (this == other) {
            return true;
        }
        return MessagesPigeonUtils.INSTANCE.deepEquals(toList(), ((GetCredentialRequestParams) other).toList());
    }

    public int hashCode() {
        return toList().hashCode();
    }
}
