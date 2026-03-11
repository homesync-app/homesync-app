package com.google.firebase.auth;

import androidx.media3.container.NalUnitUtil;
import com.google.firebase.Firebase;
import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.ActionCodeSettings;
import com.google.firebase.auth.OAuthProvider;
import com.google.firebase.auth.UserProfileChangeRequest;
import io.flutter.plugins.firebase.auth.Constants;
import kotlin.Metadata;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
@Metadata(d1 = {"\u0000R\n\u0000\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0010\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u000e\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\u001a\u0012\u0010\u0000\u001a\u00020\u0001*\u00020\u00022\u0006\u0010\u0005\u001a\u00020\u0006\u001a%\u0010\u0007\u001a\u00020\b2\u0017\u0010\t\u001a\u0013\u0012\u0004\u0012\u00020\u000b\u0012\u0004\u0012\u00020\f0\n¢\u0006\u0002\b\rH\u0086\bø\u0001\u0000\u001a-\u0010\u000e\u001a\u00020\u000f2\u0006\u0010\u0010\u001a\u00020\u00112\u0017\u0010\t\u001a\u0013\u0012\u0004\u0012\u00020\u0012\u0012\u0004\u0012\u00020\f0\n¢\u0006\u0002\b\rH\u0086\bø\u0001\u0000\u001a5\u0010\u000e\u001a\u00020\u000f2\u0006\u0010\u0010\u001a\u00020\u00112\u0006\u0010\u0013\u001a\u00020\u00012\u0017\u0010\t\u001a\u0013\u0012\u0004\u0012\u00020\u0012\u0012\u0004\u0012\u00020\f0\n¢\u0006\u0002\b\rH\u0086\bø\u0001\u0000\u001a-\u0010\u0014\u001a\u00020\u00152\u0006\u0010\u0010\u001a\u00020\u00112\u0017\u0010\t\u001a\u0013\u0012\u0004\u0012\u00020\u0016\u0012\u0004\u0012\u00020\f0\n¢\u0006\u0002\b\rH\u0086\bø\u0001\u0000\u001a%\u0010\u0017\u001a\u00020\u00182\u0017\u0010\t\u001a\u0013\u0012\u0004\u0012\u00020\u0019\u0012\u0004\u0012\u00020\f0\n¢\u0006\u0002\b\rH\u0086\bø\u0001\u0000\"\u0015\u0010\u0000\u001a\u00020\u0001*\u00020\u00028F¢\u0006\u0006\u001a\u0004\b\u0003\u0010\u0004\u0082\u0002\u0007\n\u0005\b\u009920\u0001¨\u0006\u001a"}, d2 = {"auth", "Lcom/google/firebase/auth/FirebaseAuth;", "Lcom/google/firebase/Firebase;", "getAuth", "(Lcom/google/firebase/Firebase;)Lcom/google/firebase/auth/FirebaseAuth;", "app", "Lcom/google/firebase/FirebaseApp;", "actionCodeSettings", "Lcom/google/firebase/auth/ActionCodeSettings;", "init", "Lkotlin/Function1;", "Lcom/google/firebase/auth/ActionCodeSettings$Builder;", "", "Lkotlin/ExtensionFunctionType;", "oAuthProvider", "Lcom/google/firebase/auth/OAuthProvider;", Constants.PROVIDER_ID, "", "Lcom/google/firebase/auth/OAuthProvider$Builder;", "firebaseAuth", "oAuthCredential", "Lcom/google/firebase/auth/AuthCredential;", "Lcom/google/firebase/auth/OAuthProvider$CredentialBuilder;", "userProfileChangeRequest", "Lcom/google/firebase/auth/UserProfileChangeRequest;", "Lcom/google/firebase/auth/UserProfileChangeRequest$Builder;", "java.com.google.android.gmscore.integ.client.firebase-auth-api_firebase-auth-api"}, k = 2, mv = {2, 1, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final class AuthKt {
    public static final ActionCodeSettings actionCodeSettings(Function1<? super ActionCodeSettings.Builder, Unit> init) {
        Intrinsics.checkNotNullParameter(init, "init");
        ActionCodeSettings.Builder builderNewBuilder = ActionCodeSettings.newBuilder();
        Intrinsics.checkNotNullExpressionValue(builderNewBuilder, "newBuilder(...)");
        init.invoke(builderNewBuilder);
        ActionCodeSettings actionCodeSettingsBuild = builderNewBuilder.build();
        Intrinsics.checkNotNullExpressionValue(actionCodeSettingsBuild, "build(...)");
        return actionCodeSettingsBuild;
    }

    public static final AuthCredential oAuthCredential(String providerId, Function1<? super OAuthProvider.CredentialBuilder, Unit> init) {
        Intrinsics.checkNotNullParameter(providerId, "providerId");
        Intrinsics.checkNotNullParameter(init, "init");
        OAuthProvider.CredentialBuilder credentialBuilderNewCredentialBuilder = OAuthProvider.newCredentialBuilder(providerId);
        Intrinsics.checkNotNullExpressionValue(credentialBuilderNewCredentialBuilder, "newCredentialBuilder(...)");
        init.invoke(credentialBuilderNewCredentialBuilder);
        AuthCredential authCredentialBuild = credentialBuilderNewCredentialBuilder.build();
        Intrinsics.checkNotNullExpressionValue(authCredentialBuild, "build(...)");
        return authCredentialBuild;
    }

    public static final FirebaseAuth auth(Firebase firebase, FirebaseApp app) {
        Intrinsics.checkNotNullParameter(firebase, "<this>");
        Intrinsics.checkNotNullParameter(app, "app");
        FirebaseAuth firebaseAuth = FirebaseAuth.getInstance(app);
        Intrinsics.checkNotNullExpressionValue(firebaseAuth, "getInstance(...)");
        return firebaseAuth;
    }

    public static final FirebaseAuth getAuth(Firebase firebase) {
        Intrinsics.checkNotNullParameter(firebase, "<this>");
        FirebaseAuth firebaseAuth = FirebaseAuth.getInstance();
        Intrinsics.checkNotNullExpressionValue(firebaseAuth, "getInstance(...)");
        return firebaseAuth;
    }

    public static final OAuthProvider oAuthProvider(String providerId, Function1<? super OAuthProvider.Builder, Unit> init) {
        Intrinsics.checkNotNullParameter(providerId, "providerId");
        Intrinsics.checkNotNullParameter(init, "init");
        OAuthProvider.Builder builderNewBuilder = OAuthProvider.newBuilder(providerId);
        Intrinsics.checkNotNullExpressionValue(builderNewBuilder, "newBuilder(...)");
        init.invoke(builderNewBuilder);
        OAuthProvider oAuthProviderBuild = builderNewBuilder.build();
        Intrinsics.checkNotNullExpressionValue(oAuthProviderBuild, "build(...)");
        return oAuthProviderBuild;
    }

    public static final OAuthProvider oAuthProvider(String providerId, FirebaseAuth firebaseAuth, Function1<? super OAuthProvider.Builder, Unit> init) {
        Intrinsics.checkNotNullParameter(providerId, "providerId");
        Intrinsics.checkNotNullParameter(firebaseAuth, "firebaseAuth");
        Intrinsics.checkNotNullParameter(init, "init");
        OAuthProvider.Builder builderNewBuilder = OAuthProvider.newBuilder(providerId, firebaseAuth);
        Intrinsics.checkNotNullExpressionValue(builderNewBuilder, "newBuilder(...)");
        init.invoke(builderNewBuilder);
        OAuthProvider oAuthProviderBuild = builderNewBuilder.build();
        Intrinsics.checkNotNullExpressionValue(oAuthProviderBuild, "build(...)");
        return oAuthProviderBuild;
    }

    public static final UserProfileChangeRequest userProfileChangeRequest(Function1<? super UserProfileChangeRequest.Builder, Unit> init) {
        Intrinsics.checkNotNullParameter(init, "init");
        UserProfileChangeRequest.Builder builder = new UserProfileChangeRequest.Builder();
        init.invoke(builder);
        UserProfileChangeRequest userProfileChangeRequestBuild = builder.build();
        Intrinsics.checkNotNullExpressionValue(userProfileChangeRequestBuild, "build(...)");
        return userProfileChangeRequestBuild;
    }
}
