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
@Metadata(d1 = {"\u00004\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0005\n\u0002\u0010 \n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000b\n\u0002\b\u0002\n\u0002\u0010\b\n\u0002\b\u0003\n\u0002\u0010\u000e\n\u0002\b\u0002\b\u0086\b\u0018\u0000 \u00142\u00020\u0001:\u0001\u0014B\u000f\u0012\u0006\u0010\u0002\u001a\u00020\u0003¢\u0006\u0004\b\u0004\u0010\u0005J\u000e\u0010\b\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\n0\tJ\u0013\u0010\u000b\u001a\u00020\f2\b\u0010\r\u001a\u0004\u0018\u00010\nH\u0096\u0002J\b\u0010\u000e\u001a\u00020\u000fH\u0016J\t\u0010\u0010\u001a\u00020\u0003HÆ\u0003J\u0013\u0010\u0011\u001a\u00020\u00002\b\b\u0002\u0010\u0002\u001a\u00020\u0003HÆ\u0001J\t\u0010\u0012\u001a\u00020\u0013HÖ\u0001R\u0011\u0010\u0002\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u0006\u0010\u0007¨\u0006\u0015"}, d2 = {"Lio/flutter/plugins/googlesignin/GetCredentialSuccess;", "Lio/flutter/plugins/googlesignin/GetCredentialResult;", Constants.CREDENTIAL, "Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;", "<init>", "(Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;)V", "getCredential", "()Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;", "toList", "", "", "equals", "", "other", "hashCode", "", "component1", "copy", "toString", "", "Companion", "google_sign_in_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final /* data */ class GetCredentialSuccess extends GetCredentialResult {

    /* JADX INFO: renamed from: Companion, reason: from kotlin metadata */
    public static final Companion INSTANCE = new Companion(null);
    private final PlatformGoogleIdTokenCredential credential;

    public static /* synthetic */ GetCredentialSuccess copy$default(GetCredentialSuccess getCredentialSuccess, PlatformGoogleIdTokenCredential platformGoogleIdTokenCredential, int i, Object obj) {
        if ((i & 1) != 0) {
            platformGoogleIdTokenCredential = getCredentialSuccess.credential;
        }
        return getCredentialSuccess.copy(platformGoogleIdTokenCredential);
    }

    /* JADX INFO: renamed from: component1, reason: from getter */
    public final PlatformGoogleIdTokenCredential getCredential() {
        return this.credential;
    }

    public final GetCredentialSuccess copy(PlatformGoogleIdTokenCredential credential) {
        Intrinsics.checkNotNullParameter(credential, "credential");
        return new GetCredentialSuccess(credential);
    }

    public String toString() {
        return "GetCredentialSuccess(credential=" + this.credential + ")";
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public GetCredentialSuccess(PlatformGoogleIdTokenCredential credential) {
        super(null);
        Intrinsics.checkNotNullParameter(credential, "credential");
        this.credential = credential;
    }

    public final PlatformGoogleIdTokenCredential getCredential() {
        return this.credential;
    }

    /* JADX INFO: compiled from: Messages.kt */
    @Metadata(d1 = {"\u0000\u0018\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010 \n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\t\b\u0002¢\u0006\u0004\b\u0002\u0010\u0003J\u0016\u0010\u0004\u001a\u00020\u00052\u000e\u0010\u0006\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0007¨\u0006\b"}, d2 = {"Lio/flutter/plugins/googlesignin/GetCredentialSuccess$Companion;", "", "<init>", "()V", "fromList", "Lio/flutter/plugins/googlesignin/GetCredentialSuccess;", "pigeonVar_list", "", "google_sign_in_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }

        public final GetCredentialSuccess fromList(List<? extends Object> pigeonVar_list) {
            Intrinsics.checkNotNullParameter(pigeonVar_list, "pigeonVar_list");
            Object obj = pigeonVar_list.get(0);
            Intrinsics.checkNotNull(obj, "null cannot be cast to non-null type io.flutter.plugins.googlesignin.PlatformGoogleIdTokenCredential");
            return new GetCredentialSuccess((PlatformGoogleIdTokenCredential) obj);
        }
    }

    public final List<Object> toList() {
        return CollectionsKt.listOf(this.credential);
    }

    public boolean equals(Object other) {
        if (!(other instanceof GetCredentialSuccess)) {
            return false;
        }
        if (this == other) {
            return true;
        }
        return MessagesPigeonUtils.INSTANCE.deepEquals(toList(), ((GetCredentialSuccess) other).toList());
    }

    public int hashCode() {
        return toList().hashCode();
    }
}
