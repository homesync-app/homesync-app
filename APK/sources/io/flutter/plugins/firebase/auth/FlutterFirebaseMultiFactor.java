package io.flutter.plugins.firebase.auth;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.MultiFactor;
import com.google.firebase.auth.MultiFactorAssertion;
import com.google.firebase.auth.MultiFactorResolver;
import com.google.firebase.auth.MultiFactorSession;
import com.google.firebase.auth.PhoneAuthProvider;
import com.google.firebase.auth.PhoneMultiFactorGenerator;
import com.google.firebase.internal.api.FirebaseNoSignedInUserException;
import io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/* JADX INFO: loaded from: classes3.dex */
public class FlutterFirebaseMultiFactor implements GeneratedAndroidFirebaseAuth.MultiFactorUserHostApi, GeneratedAndroidFirebaseAuth.MultiFactoResolverHostApi {
    static final /* synthetic */ boolean $assertionsDisabled = false;
    static final Map<String, Map<String, MultiFactor>> multiFactorUserMap = new HashMap();
    static final Map<String, MultiFactorSession> multiFactorSessionMap = new HashMap();
    static final Map<String, MultiFactorResolver> multiFactorResolverMap = new HashMap();
    static final Map<String, MultiFactorAssertion> multiFactorAssertionMap = new HashMap();

    MultiFactor getAppMultiFactor(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp) throws FirebaseNoSignedInUserException {
        FirebaseUser currentUserFromPigeon = FlutterFirebaseAuthUser.getCurrentUserFromPigeon(authPigeonFirebaseApp);
        if (currentUserFromPigeon == null) {
            throw new FirebaseNoSignedInUserException("No user is signed in");
        }
        Map<String, Map<String, MultiFactor>> map = multiFactorUserMap;
        if (map.get(authPigeonFirebaseApp.getAppName()) == null) {
            map.put(authPigeonFirebaseApp.getAppName(), new HashMap());
        }
        Map<String, MultiFactor> map2 = map.get(authPigeonFirebaseApp.getAppName());
        if (map2.get(currentUserFromPigeon.getUid()) == null) {
            map2.put(currentUserFromPigeon.getUid(), currentUserFromPigeon.getMultiFactor());
        }
        return map2.get(currentUserFromPigeon.getUid());
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.MultiFactorUserHostApi
    public void enrollPhone(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, GeneratedAndroidFirebaseAuth.PigeonPhoneMultiFactorAssertion pigeonPhoneMultiFactorAssertion, String str, final GeneratedAndroidFirebaseAuth.VoidResult voidResult) {
        try {
            getAppMultiFactor(authPigeonFirebaseApp).enroll(PhoneMultiFactorGenerator.getAssertion(PhoneAuthProvider.getCredential(pigeonPhoneMultiFactorAssertion.getVerificationId(), pigeonPhoneMultiFactorAssertion.getVerificationCode())), str).addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseMultiFactor$$ExternalSyntheticLambda4
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task) {
                    FlutterFirebaseMultiFactor.lambda$enrollPhone$0(voidResult, task);
                }
            });
        } catch (FirebaseNoSignedInUserException e) {
            voidResult.error(e);
        }
    }

    static /* synthetic */ void lambda$enrollPhone$0(GeneratedAndroidFirebaseAuth.VoidResult voidResult, Task task) {
        if (task.isSuccessful()) {
            voidResult.success();
        } else {
            voidResult.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.MultiFactorUserHostApi
    public void enrollTotp(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, String str, String str2, final GeneratedAndroidFirebaseAuth.VoidResult voidResult) {
        try {
            getAppMultiFactor(authPigeonFirebaseApp).enroll(multiFactorAssertionMap.get(str), str2).addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseMultiFactor$$ExternalSyntheticLambda2
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task) {
                    FlutterFirebaseMultiFactor.lambda$enrollTotp$1(voidResult, task);
                }
            });
        } catch (FirebaseNoSignedInUserException e) {
            voidResult.error(e);
        }
    }

    static /* synthetic */ void lambda$enrollTotp$1(GeneratedAndroidFirebaseAuth.VoidResult voidResult, Task task) {
        if (task.isSuccessful()) {
            voidResult.success();
        } else {
            voidResult.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.MultiFactorUserHostApi
    public void getSession(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, final GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonMultiFactorSession> result) {
        try {
            getAppMultiFactor(authPigeonFirebaseApp).getSession().addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseMultiFactor$$ExternalSyntheticLambda1
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task) {
                    FlutterFirebaseMultiFactor.lambda$getSession$2(result, task);
                }
            });
        } catch (FirebaseNoSignedInUserException e) {
            result.error(e);
        }
    }

    static /* synthetic */ void lambda$getSession$2(GeneratedAndroidFirebaseAuth.Result result, Task task) {
        if (task.isSuccessful()) {
            MultiFactorSession multiFactorSession = (MultiFactorSession) task.getResult();
            String string = UUID.randomUUID().toString();
            multiFactorSessionMap.put(string, multiFactorSession);
            result.success(new GeneratedAndroidFirebaseAuth.PigeonMultiFactorSession.Builder().setId(string).build());
            return;
        }
        result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.MultiFactorUserHostApi
    public void unenroll(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, String str, final GeneratedAndroidFirebaseAuth.VoidResult voidResult) {
        try {
            getAppMultiFactor(authPigeonFirebaseApp).unenroll(str).addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseMultiFactor$$ExternalSyntheticLambda3
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task) {
                    FlutterFirebaseMultiFactor.lambda$unenroll$3(voidResult, task);
                }
            });
        } catch (FirebaseNoSignedInUserException e) {
            voidResult.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(e));
        }
    }

    static /* synthetic */ void lambda$unenroll$3(GeneratedAndroidFirebaseAuth.VoidResult voidResult, Task task) {
        if (task.isSuccessful()) {
            voidResult.success();
        } else {
            voidResult.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.MultiFactorUserHostApi
    public void getEnrolledFactors(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, GeneratedAndroidFirebaseAuth.Result<List<GeneratedAndroidFirebaseAuth.PigeonMultiFactorInfo>> result) {
        try {
            result.success(PigeonParser.multiFactorInfoToPigeon(getAppMultiFactor(authPigeonFirebaseApp).getEnrolledFactors()));
        } catch (FirebaseNoSignedInUserException e) {
            result.error(e);
        }
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.MultiFactoResolverHostApi
    public void resolveSignIn(String str, GeneratedAndroidFirebaseAuth.PigeonPhoneMultiFactorAssertion pigeonPhoneMultiFactorAssertion, String str2, final GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential> result) {
        MultiFactorAssertion assertion;
        MultiFactorResolver multiFactorResolver = multiFactorResolverMap.get(str);
        if (multiFactorResolver == null) {
            result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(new Exception("Resolver not found")));
            return;
        }
        if (pigeonPhoneMultiFactorAssertion != null) {
            assertion = PhoneMultiFactorGenerator.getAssertion(PhoneAuthProvider.getCredential(pigeonPhoneMultiFactorAssertion.getVerificationId(), pigeonPhoneMultiFactorAssertion.getVerificationCode()));
        } else {
            assertion = multiFactorAssertionMap.get(str2);
        }
        multiFactorResolver.resolveSignIn(assertion).addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseMultiFactor$$ExternalSyntheticLambda0
            @Override // com.google.android.gms.tasks.OnCompleteListener
            public final void onComplete(Task task) {
                FlutterFirebaseMultiFactor.lambda$resolveSignIn$4(result, task);
            }
        });
    }

    static /* synthetic */ void lambda$resolveSignIn$4(GeneratedAndroidFirebaseAuth.Result result, Task task) {
        if (task.isSuccessful()) {
            result.success(PigeonParser.parseAuthResult((AuthResult) task.getResult()));
        } else {
            result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }
}
