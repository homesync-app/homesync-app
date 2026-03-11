package io.flutter.plugins.googlesignin;

import androidx.media3.container.NalUnitUtil;
import androidx.media3.extractor.text.ttml.TtmlNode;
import io.flutter.plugins.firebase.auth.Constants;
import java.util.List;
import kotlin.Metadata;
import kotlin.collections.CollectionsKt;
import kotlin.jvm.internal.DefaultConstructorMarker;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: Messages.kt */
/* JADX INFO: loaded from: classes3.dex */
@Metadata(d1 = {"\u0000(\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000e\n\u0002\b\u000f\n\u0002\u0010 \n\u0000\n\u0002\u0010\u000b\n\u0002\b\u0002\n\u0002\u0010\b\n\u0002\b\n\b\u0086\b\u0018\u0000 !2\u00020\u0001:\u0001!BG\u0012\n\b\u0002\u0010\u0002\u001a\u0004\u0018\u00010\u0003\u0012\n\b\u0002\u0010\u0004\u001a\u0004\u0018\u00010\u0003\u0012\n\b\u0002\u0010\u0005\u001a\u0004\u0018\u00010\u0003\u0012\u0006\u0010\u0006\u001a\u00020\u0003\u0012\u0006\u0010\u0007\u001a\u00020\u0003\u0012\n\b\u0002\u0010\b\u001a\u0004\u0018\u00010\u0003¢\u0006\u0004\b\t\u0010\nJ\u000e\u0010\u0012\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0013J\u0013\u0010\u0014\u001a\u00020\u00152\b\u0010\u0016\u001a\u0004\u0018\u00010\u0001H\u0096\u0002J\b\u0010\u0017\u001a\u00020\u0018H\u0016J\u000b\u0010\u0019\u001a\u0004\u0018\u00010\u0003HÆ\u0003J\u000b\u0010\u001a\u001a\u0004\u0018\u00010\u0003HÆ\u0003J\u000b\u0010\u001b\u001a\u0004\u0018\u00010\u0003HÆ\u0003J\t\u0010\u001c\u001a\u00020\u0003HÆ\u0003J\t\u0010\u001d\u001a\u00020\u0003HÆ\u0003J\u000b\u0010\u001e\u001a\u0004\u0018\u00010\u0003HÆ\u0003JM\u0010\u001f\u001a\u00020\u00002\n\b\u0002\u0010\u0002\u001a\u0004\u0018\u00010\u00032\n\b\u0002\u0010\u0004\u001a\u0004\u0018\u00010\u00032\n\b\u0002\u0010\u0005\u001a\u0004\u0018\u00010\u00032\b\b\u0002\u0010\u0006\u001a\u00020\u00032\b\b\u0002\u0010\u0007\u001a\u00020\u00032\n\b\u0002\u0010\b\u001a\u0004\u0018\u00010\u0003HÆ\u0001J\t\u0010 \u001a\u00020\u0003HÖ\u0001R\u0013\u0010\u0002\u001a\u0004\u0018\u00010\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u000b\u0010\fR\u0013\u0010\u0004\u001a\u0004\u0018\u00010\u0003¢\u0006\b\n\u0000\u001a\u0004\b\r\u0010\fR\u0013\u0010\u0005\u001a\u0004\u0018\u00010\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u000e\u0010\fR\u0011\u0010\u0006\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u000f\u0010\fR\u0011\u0010\u0007\u001a\u00020\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u0010\u0010\fR\u0013\u0010\b\u001a\u0004\u0018\u00010\u0003¢\u0006\b\n\u0000\u001a\u0004\b\u0011\u0010\f¨\u0006\""}, d2 = {"Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;", "", "displayName", "", "familyName", "givenName", TtmlNode.ATTR_ID, Constants.ID_TOKEN, "profilePictureUri", "<init>", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V", "getDisplayName", "()Ljava/lang/String;", "getFamilyName", "getGivenName", "getId", "getIdToken", "getProfilePictureUri", "toList", "", "equals", "", "other", "hashCode", "", "component1", "component2", "component3", "component4", "component5", "component6", "copy", "toString", "Companion", "google_sign_in_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final /* data */ class PlatformGoogleIdTokenCredential {

    /* JADX INFO: renamed from: Companion, reason: from kotlin metadata */
    public static final Companion INSTANCE = new Companion(null);
    private final String displayName;
    private final String familyName;
    private final String givenName;
    private final String id;
    private final String idToken;
    private final String profilePictureUri;

    public static /* synthetic */ PlatformGoogleIdTokenCredential copy$default(PlatformGoogleIdTokenCredential platformGoogleIdTokenCredential, String str, String str2, String str3, String str4, String str5, String str6, int i, Object obj) {
        if ((i & 1) != 0) {
            str = platformGoogleIdTokenCredential.displayName;
        }
        if ((i & 2) != 0) {
            str2 = platformGoogleIdTokenCredential.familyName;
        }
        if ((i & 4) != 0) {
            str3 = platformGoogleIdTokenCredential.givenName;
        }
        if ((i & 8) != 0) {
            str4 = platformGoogleIdTokenCredential.id;
        }
        if ((i & 16) != 0) {
            str5 = platformGoogleIdTokenCredential.idToken;
        }
        if ((i & 32) != 0) {
            str6 = platformGoogleIdTokenCredential.profilePictureUri;
        }
        String str7 = str5;
        String str8 = str6;
        return platformGoogleIdTokenCredential.copy(str, str2, str3, str4, str7, str8);
    }

    /* JADX INFO: renamed from: component1, reason: from getter */
    public final String getDisplayName() {
        return this.displayName;
    }

    /* JADX INFO: renamed from: component2, reason: from getter */
    public final String getFamilyName() {
        return this.familyName;
    }

    /* JADX INFO: renamed from: component3, reason: from getter */
    public final String getGivenName() {
        return this.givenName;
    }

    /* JADX INFO: renamed from: component4, reason: from getter */
    public final String getId() {
        return this.id;
    }

    /* JADX INFO: renamed from: component5, reason: from getter */
    public final String getIdToken() {
        return this.idToken;
    }

    /* JADX INFO: renamed from: component6, reason: from getter */
    public final String getProfilePictureUri() {
        return this.profilePictureUri;
    }

    public final PlatformGoogleIdTokenCredential copy(String displayName, String familyName, String givenName, String id, String idToken, String profilePictureUri) {
        Intrinsics.checkNotNullParameter(id, "id");
        Intrinsics.checkNotNullParameter(idToken, "idToken");
        return new PlatformGoogleIdTokenCredential(displayName, familyName, givenName, id, idToken, profilePictureUri);
    }

    public String toString() {
        return "PlatformGoogleIdTokenCredential(displayName=" + this.displayName + ", familyName=" + this.familyName + ", givenName=" + this.givenName + ", id=" + this.id + ", idToken=" + this.idToken + ", profilePictureUri=" + this.profilePictureUri + ")";
    }

    public PlatformGoogleIdTokenCredential(String str, String str2, String str3, String id, String idToken, String str4) {
        Intrinsics.checkNotNullParameter(id, "id");
        Intrinsics.checkNotNullParameter(idToken, "idToken");
        this.displayName = str;
        this.familyName = str2;
        this.givenName = str3;
        this.id = id;
        this.idToken = idToken;
        this.profilePictureUri = str4;
    }

    public /* synthetic */ PlatformGoogleIdTokenCredential(String str, String str2, String str3, String str4, String str5, String str6, int i, DefaultConstructorMarker defaultConstructorMarker) {
        this((i & 1) != 0 ? null : str, (i & 2) != 0 ? null : str2, (i & 4) != 0 ? null : str3, str4, str5, (i & 32) != 0 ? null : str6);
    }

    public final String getDisplayName() {
        return this.displayName;
    }

    public final String getFamilyName() {
        return this.familyName;
    }

    public final String getGivenName() {
        return this.givenName;
    }

    public final String getId() {
        return this.id;
    }

    public final String getIdToken() {
        return this.idToken;
    }

    public final String getProfilePictureUri() {
        return this.profilePictureUri;
    }

    /* JADX INFO: compiled from: Messages.kt */
    @Metadata(d1 = {"\u0000\u0018\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010 \n\u0000\b\u0086\u0003\u0018\u00002\u00020\u0001B\t\b\u0002¢\u0006\u0004\b\u0002\u0010\u0003J\u0016\u0010\u0004\u001a\u00020\u00052\u000e\u0010\u0006\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0007¨\u0006\b"}, d2 = {"Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential$Companion;", "", "<init>", "()V", "fromList", "Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;", "pigeonVar_list", "", "google_sign_in_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
    public static final class Companion {
        public /* synthetic */ Companion(DefaultConstructorMarker defaultConstructorMarker) {
            this();
        }

        private Companion() {
        }

        public final PlatformGoogleIdTokenCredential fromList(List<? extends Object> pigeonVar_list) {
            Intrinsics.checkNotNullParameter(pigeonVar_list, "pigeonVar_list");
            String str = (String) pigeonVar_list.get(0);
            String str2 = (String) pigeonVar_list.get(1);
            String str3 = (String) pigeonVar_list.get(2);
            Object obj = pigeonVar_list.get(3);
            Intrinsics.checkNotNull(obj, "null cannot be cast to non-null type kotlin.String");
            String str4 = (String) obj;
            Object obj2 = pigeonVar_list.get(4);
            Intrinsics.checkNotNull(obj2, "null cannot be cast to non-null type kotlin.String");
            return new PlatformGoogleIdTokenCredential(str, str2, str3, str4, (String) obj2, (String) pigeonVar_list.get(5));
        }
    }

    public final List<Object> toList() {
        return CollectionsKt.listOf((Object[]) new String[]{this.displayName, this.familyName, this.givenName, this.id, this.idToken, this.profilePictureUri});
    }

    public boolean equals(Object other) {
        if (!(other instanceof PlatformGoogleIdTokenCredential)) {
            return false;
        }
        if (this == other) {
            return true;
        }
        return MessagesPigeonUtils.INSTANCE.deepEquals(toList(), ((PlatformGoogleIdTokenCredential) other).toList());
    }

    public int hashCode() {
        return toList().hashCode();
    }
}
