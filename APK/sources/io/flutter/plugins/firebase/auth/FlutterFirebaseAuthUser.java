package io.flutter.plugins.firebase.auth;

import android.app.Activity;
import android.net.Uri;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.android.gms.tasks.Tasks;
import com.google.firebase.FirebaseApp;
import com.google.firebase.auth.AuthCredential;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.GetTokenResult;
import com.google.firebase.auth.OAuthProvider;
import com.google.firebase.auth.PhoneAuthCredential;
import com.google.firebase.auth.UserProfileChangeRequest;
import io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth;
import io.flutter.plugins.firebase.core.FlutterFirebasePlugin;
import java.util.Map;

/* JADX INFO: loaded from: classes3.dex */
public class FlutterFirebaseAuthUser implements GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi {
    private Activity activity;

    public void setActivity(Activity activity) {
        this.activity = activity;
    }

    public static FirebaseUser getCurrentUserFromPigeon(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp) {
        FirebaseAuth firebaseAuth = FirebaseAuth.getInstance(FirebaseApp.getInstance(authPigeonFirebaseApp.getAppName()));
        if (authPigeonFirebaseApp.getTenantId() != null) {
            firebaseAuth.setTenantId(authPigeonFirebaseApp.getTenantId());
        }
        return firebaseAuth.getCurrentUser();
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi
    public void delete(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, final GeneratedAndroidFirebaseAuth.VoidResult voidResult) {
        FirebaseUser currentUserFromPigeon = getCurrentUserFromPigeon(authPigeonFirebaseApp);
        if (currentUserFromPigeon == null) {
            voidResult.error(FlutterFirebaseAuthPluginException.noUser());
        } else {
            currentUserFromPigeon.delete().addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda19
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task) {
                    FlutterFirebaseAuthUser.lambda$delete$0(voidResult, task);
                }
            });
        }
    }

    static /* synthetic */ void lambda$delete$0(GeneratedAndroidFirebaseAuth.VoidResult voidResult, Task task) {
        if (task.isSuccessful()) {
            voidResult.success();
        } else {
            voidResult.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi
    public void getIdToken(final GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, final Boolean bool, final GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonIdTokenResult> result) {
        FlutterFirebasePlugin.cachedThreadPool.execute(new Runnable() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda5
            @Override // java.lang.Runnable
            public final void run() {
                FlutterFirebaseAuthUser.lambda$getIdToken$1(authPigeonFirebaseApp, result, bool);
            }
        });
    }

    static /* synthetic */ void lambda$getIdToken$1(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, GeneratedAndroidFirebaseAuth.Result result, Boolean bool) {
        FirebaseUser currentUserFromPigeon = getCurrentUserFromPigeon(authPigeonFirebaseApp);
        if (currentUserFromPigeon == null) {
            result.error(FlutterFirebaseAuthPluginException.noUser());
            return;
        }
        try {
            result.success(PigeonParser.parseTokenResult((GetTokenResult) Tasks.await(currentUserFromPigeon.getIdToken(bool.booleanValue()))));
        } catch (Exception e) {
            result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(e));
        }
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi
    public void linkWithCredential(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, Map<String, Object> map, final GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential> result) {
        FirebaseUser currentUserFromPigeon = getCurrentUserFromPigeon(authPigeonFirebaseApp);
        AuthCredential credential = PigeonParser.getCredential(map);
        if (currentUserFromPigeon == null) {
            result.error(FlutterFirebaseAuthPluginException.noUser());
        } else if (credential == null) {
            result.error(FlutterFirebaseAuthPluginException.invalidCredential());
        } else {
            currentUserFromPigeon.linkWithCredential(credential).addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda14
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task) {
                    FlutterFirebaseAuthUser.lambda$linkWithCredential$2(result, task);
                }
            });
        }
    }

    static /* synthetic */ void lambda$linkWithCredential$2(GeneratedAndroidFirebaseAuth.Result result, Task task) {
        if (task.isSuccessful()) {
            result.success(PigeonParser.parseAuthResult((AuthResult) task.getResult()));
        } else {
            result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi
    public void linkWithProvider(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, GeneratedAndroidFirebaseAuth.PigeonSignInProvider pigeonSignInProvider, final GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential> result) {
        FirebaseUser currentUserFromPigeon = getCurrentUserFromPigeon(authPigeonFirebaseApp);
        OAuthProvider.Builder builderNewBuilder = OAuthProvider.newBuilder(pigeonSignInProvider.getProviderId());
        if (pigeonSignInProvider.getScopes() != null) {
            builderNewBuilder.setScopes(pigeonSignInProvider.getScopes());
        }
        if (pigeonSignInProvider.getCustomParameters() != null) {
            builderNewBuilder.addCustomParameters(pigeonSignInProvider.getCustomParameters());
        }
        currentUserFromPigeon.startActivityForLinkWithProvider(this.activity, builderNewBuilder.build()).addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda11
            @Override // com.google.android.gms.tasks.OnCompleteListener
            public final void onComplete(Task task) {
                FlutterFirebaseAuthUser.lambda$linkWithProvider$3(result, task);
            }
        });
    }

    static /* synthetic */ void lambda$linkWithProvider$3(GeneratedAndroidFirebaseAuth.Result result, Task task) {
        if (task.isSuccessful()) {
            result.success(PigeonParser.parseAuthResult((AuthResult) task.getResult()));
        } else {
            result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi
    public void reauthenticateWithCredential(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, Map<String, Object> map, final GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential> result) {
        FirebaseUser currentUserFromPigeon = getCurrentUserFromPigeon(authPigeonFirebaseApp);
        AuthCredential credential = PigeonParser.getCredential(map);
        if (currentUserFromPigeon == null) {
            result.error(FlutterFirebaseAuthPluginException.noUser());
        } else if (credential == null) {
            result.error(FlutterFirebaseAuthPluginException.invalidCredential());
        } else {
            currentUserFromPigeon.reauthenticateAndRetrieveData(credential).addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda9
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task) {
                    FlutterFirebaseAuthUser.lambda$reauthenticateWithCredential$4(result, task);
                }
            });
        }
    }

    static /* synthetic */ void lambda$reauthenticateWithCredential$4(GeneratedAndroidFirebaseAuth.Result result, Task task) {
        if (task.isSuccessful()) {
            result.success(PigeonParser.parseAuthResult((AuthResult) task.getResult()));
        } else {
            result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi
    public void reauthenticateWithProvider(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, GeneratedAndroidFirebaseAuth.PigeonSignInProvider pigeonSignInProvider, final GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential> result) {
        FirebaseUser currentUserFromPigeon = getCurrentUserFromPigeon(authPigeonFirebaseApp);
        OAuthProvider.Builder builderNewBuilder = OAuthProvider.newBuilder(pigeonSignInProvider.getProviderId());
        if (pigeonSignInProvider.getScopes() != null) {
            builderNewBuilder.setScopes(pigeonSignInProvider.getScopes());
        }
        if (pigeonSignInProvider.getCustomParameters() != null) {
            builderNewBuilder.addCustomParameters(pigeonSignInProvider.getCustomParameters());
        }
        currentUserFromPigeon.startActivityForReauthenticateWithProvider(this.activity, builderNewBuilder.build()).addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda1
            @Override // com.google.android.gms.tasks.OnCompleteListener
            public final void onComplete(Task task) {
                FlutterFirebaseAuthUser.lambda$reauthenticateWithProvider$5(result, task);
            }
        });
    }

    static /* synthetic */ void lambda$reauthenticateWithProvider$5(GeneratedAndroidFirebaseAuth.Result result, Task task) {
        if (task.isSuccessful()) {
            result.success(PigeonParser.parseAuthResult((AuthResult) task.getResult()));
        } else {
            result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi
    public void reload(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, final GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserDetails> result) {
        final FirebaseUser currentUserFromPigeon = getCurrentUserFromPigeon(authPigeonFirebaseApp);
        if (currentUserFromPigeon == null) {
            result.error(FlutterFirebaseAuthPluginException.noUser());
        } else {
            currentUserFromPigeon.reload().addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda2
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task) {
                    FlutterFirebaseAuthUser.lambda$reload$6(result, currentUserFromPigeon, task);
                }
            });
        }
    }

    static /* synthetic */ void lambda$reload$6(GeneratedAndroidFirebaseAuth.Result result, FirebaseUser firebaseUser, Task task) {
        if (task.isSuccessful()) {
            result.success(PigeonParser.parseFirebaseUser(firebaseUser));
        } else {
            result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi
    public void sendEmailVerification(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, GeneratedAndroidFirebaseAuth.PigeonActionCodeSettings pigeonActionCodeSettings, final GeneratedAndroidFirebaseAuth.VoidResult voidResult) {
        FirebaseUser currentUserFromPigeon = getCurrentUserFromPigeon(authPigeonFirebaseApp);
        if (currentUserFromPigeon == null) {
            voidResult.error(FlutterFirebaseAuthPluginException.noUser());
        } else if (pigeonActionCodeSettings == null) {
            currentUserFromPigeon.sendEmailVerification().addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda12
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task) {
                    FlutterFirebaseAuthUser.lambda$sendEmailVerification$7(voidResult, task);
                }
            });
        } else {
            currentUserFromPigeon.sendEmailVerification(PigeonParser.getActionCodeSettings(pigeonActionCodeSettings)).addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda13
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task) {
                    FlutterFirebaseAuthUser.lambda$sendEmailVerification$8(voidResult, task);
                }
            });
        }
    }

    static /* synthetic */ void lambda$sendEmailVerification$7(GeneratedAndroidFirebaseAuth.VoidResult voidResult, Task task) {
        if (task.isSuccessful()) {
            voidResult.success();
        } else {
            voidResult.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    static /* synthetic */ void lambda$sendEmailVerification$8(GeneratedAndroidFirebaseAuth.VoidResult voidResult, Task task) {
        if (task.isSuccessful()) {
            voidResult.success();
        } else {
            voidResult.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi
    public void unlink(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, String str, final GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserCredential> result) {
        FirebaseUser currentUserFromPigeon = getCurrentUserFromPigeon(authPigeonFirebaseApp);
        if (currentUserFromPigeon == null) {
            result.error(FlutterFirebaseAuthPluginException.noUser());
        } else {
            currentUserFromPigeon.unlink(str).addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda18
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task) {
                    FlutterFirebaseAuthUser.lambda$unlink$9(result, task);
                }
            });
        }
    }

    static /* synthetic */ void lambda$unlink$9(GeneratedAndroidFirebaseAuth.Result result, Task task) {
        if (task.isSuccessful()) {
            result.success(PigeonParser.parseAuthResult((AuthResult) task.getResult()));
            return;
        }
        Exception exception = task.getException();
        if (exception.getMessage().contains("User was not linked to an account with the given provider.")) {
            result.error(FlutterFirebaseAuthPluginException.noSuchProvider());
        } else {
            result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(exception));
        }
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi
    public void updateEmail(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, String str, final GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserDetails> result) {
        final FirebaseUser currentUserFromPigeon = getCurrentUserFromPigeon(authPigeonFirebaseApp);
        if (currentUserFromPigeon == null) {
            result.error(FlutterFirebaseAuthPluginException.noUser());
        } else {
            currentUserFromPigeon.updateEmail(str).addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda8
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task) {
                    FlutterFirebaseAuthUser.lambda$updateEmail$11(currentUserFromPigeon, result, task);
                }
            });
        }
    }

    static /* synthetic */ void lambda$updateEmail$11(final FirebaseUser firebaseUser, final GeneratedAndroidFirebaseAuth.Result result, Task task) {
        if (task.isSuccessful()) {
            firebaseUser.reload().addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda4
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task2) {
                    FlutterFirebaseAuthUser.lambda$updateEmail$10(result, firebaseUser, task2);
                }
            });
        } else {
            result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    static /* synthetic */ void lambda$updateEmail$10(GeneratedAndroidFirebaseAuth.Result result, FirebaseUser firebaseUser, Task task) {
        if (task.isSuccessful()) {
            result.success(PigeonParser.parseFirebaseUser(firebaseUser));
        } else {
            result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi
    public void updatePassword(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, String str, final GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserDetails> result) {
        final FirebaseUser currentUserFromPigeon = getCurrentUserFromPigeon(authPigeonFirebaseApp);
        if (currentUserFromPigeon == null) {
            result.error(FlutterFirebaseAuthPluginException.noUser());
        } else {
            currentUserFromPigeon.updatePassword(str).addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda7
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task) {
                    FlutterFirebaseAuthUser.lambda$updatePassword$13(currentUserFromPigeon, result, task);
                }
            });
        }
    }

    static /* synthetic */ void lambda$updatePassword$13(final FirebaseUser firebaseUser, final GeneratedAndroidFirebaseAuth.Result result, Task task) {
        if (task.isSuccessful()) {
            firebaseUser.reload().addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda0
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task2) {
                    FlutterFirebaseAuthUser.lambda$updatePassword$12(result, firebaseUser, task2);
                }
            });
        } else {
            result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    static /* synthetic */ void lambda$updatePassword$12(GeneratedAndroidFirebaseAuth.Result result, FirebaseUser firebaseUser, Task task) {
        if (task.isSuccessful()) {
            result.success(PigeonParser.parseFirebaseUser(firebaseUser));
        } else {
            result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi
    public void updatePhoneNumber(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, Map<String, Object> map, final GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserDetails> result) {
        final FirebaseUser currentUserFromPigeon = getCurrentUserFromPigeon(authPigeonFirebaseApp);
        if (currentUserFromPigeon == null) {
            result.error(FlutterFirebaseAuthPluginException.noUser());
            return;
        }
        PhoneAuthCredential phoneAuthCredential = (PhoneAuthCredential) PigeonParser.getCredential(map);
        if (phoneAuthCredential == null) {
            result.error(FlutterFirebaseAuthPluginException.invalidCredential());
        } else {
            currentUserFromPigeon.updatePhoneNumber(phoneAuthCredential).addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda6
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task) {
                    FlutterFirebaseAuthUser.lambda$updatePhoneNumber$15(currentUserFromPigeon, result, task);
                }
            });
        }
    }

    static /* synthetic */ void lambda$updatePhoneNumber$15(final FirebaseUser firebaseUser, final GeneratedAndroidFirebaseAuth.Result result, Task task) {
        if (task.isSuccessful()) {
            firebaseUser.reload().addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda10
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task2) {
                    FlutterFirebaseAuthUser.lambda$updatePhoneNumber$14(result, firebaseUser, task2);
                }
            });
        } else {
            result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    static /* synthetic */ void lambda$updatePhoneNumber$14(GeneratedAndroidFirebaseAuth.Result result, FirebaseUser firebaseUser, Task task) {
        if (task.isSuccessful()) {
            result.success(PigeonParser.parseFirebaseUser(firebaseUser));
        } else {
            result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi
    public void updateProfile(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, GeneratedAndroidFirebaseAuth.PigeonUserProfile pigeonUserProfile, final GeneratedAndroidFirebaseAuth.Result<GeneratedAndroidFirebaseAuth.PigeonUserDetails> result) {
        final FirebaseUser currentUserFromPigeon = getCurrentUserFromPigeon(authPigeonFirebaseApp);
        if (currentUserFromPigeon == null) {
            result.error(FlutterFirebaseAuthPluginException.noUser());
            return;
        }
        UserProfileChangeRequest.Builder builder = new UserProfileChangeRequest.Builder();
        if (pigeonUserProfile.getDisplayNameChanged().booleanValue()) {
            builder.setDisplayName(pigeonUserProfile.getDisplayName());
        }
        if (pigeonUserProfile.getPhotoUrlChanged().booleanValue()) {
            if (pigeonUserProfile.getPhotoUrl() != null) {
                builder.setPhotoUri(Uri.parse(pigeonUserProfile.getPhotoUrl()));
            } else {
                builder.setPhotoUri(null);
            }
        }
        currentUserFromPigeon.updateProfile(builder.build()).addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda17
            @Override // com.google.android.gms.tasks.OnCompleteListener
            public final void onComplete(Task task) {
                FlutterFirebaseAuthUser.lambda$updateProfile$17(currentUserFromPigeon, result, task);
            }
        });
    }

    static /* synthetic */ void lambda$updateProfile$17(final FirebaseUser firebaseUser, final GeneratedAndroidFirebaseAuth.Result result, Task task) {
        if (task.isSuccessful()) {
            firebaseUser.reload().addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda3
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task2) {
                    FlutterFirebaseAuthUser.lambda$updateProfile$16(result, firebaseUser, task2);
                }
            });
        } else {
            result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    static /* synthetic */ void lambda$updateProfile$16(GeneratedAndroidFirebaseAuth.Result result, FirebaseUser firebaseUser, Task task) {
        if (task.isSuccessful()) {
            result.success(PigeonParser.parseFirebaseUser(firebaseUser));
        } else {
            result.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.FirebaseAuthUserHostApi
    public void verifyBeforeUpdateEmail(GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, String str, GeneratedAndroidFirebaseAuth.PigeonActionCodeSettings pigeonActionCodeSettings, final GeneratedAndroidFirebaseAuth.VoidResult voidResult) {
        FirebaseUser currentUserFromPigeon = getCurrentUserFromPigeon(authPigeonFirebaseApp);
        if (currentUserFromPigeon == null) {
            voidResult.error(FlutterFirebaseAuthPluginException.noUser());
        } else if (pigeonActionCodeSettings == null) {
            currentUserFromPigeon.verifyBeforeUpdateEmail(str).addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda15
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task) {
                    FlutterFirebaseAuthUser.lambda$verifyBeforeUpdateEmail$18(voidResult, task);
                }
            });
        } else {
            currentUserFromPigeon.verifyBeforeUpdateEmail(str, PigeonParser.getActionCodeSettings(pigeonActionCodeSettings)).addOnCompleteListener(new OnCompleteListener() { // from class: io.flutter.plugins.firebase.auth.FlutterFirebaseAuthUser$$ExternalSyntheticLambda16
                @Override // com.google.android.gms.tasks.OnCompleteListener
                public final void onComplete(Task task) {
                    FlutterFirebaseAuthUser.lambda$verifyBeforeUpdateEmail$19(voidResult, task);
                }
            });
        }
    }

    static /* synthetic */ void lambda$verifyBeforeUpdateEmail$18(GeneratedAndroidFirebaseAuth.VoidResult voidResult, Task task) {
        if (task.isSuccessful()) {
            voidResult.success();
        } else {
            voidResult.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }

    static /* synthetic */ void lambda$verifyBeforeUpdateEmail$19(GeneratedAndroidFirebaseAuth.VoidResult voidResult, Task task) {
        if (task.isSuccessful()) {
            voidResult.success();
        } else {
            voidResult.error(FlutterFirebaseAuthPluginException.parserExceptionToFlutter(task.getException()));
        }
    }
}
