package io.flutter.plugins.googlesignin;

import android.accounts.Account;
import android.app.Activity;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.net.Uri;
import android.os.CancellationSignal;
import androidx.credentials.ClearCredentialStateRequest;
import androidx.credentials.Credential;
import androidx.credentials.CredentialManager;
import androidx.credentials.CredentialManagerCallback;
import androidx.credentials.CustomCredential;
import androidx.credentials.GetCredentialRequest;
import androidx.credentials.GetCredentialResponse;
import androidx.credentials.exceptions.ClearCredentialException;
import androidx.credentials.exceptions.GetCredentialCancellationException;
import androidx.credentials.exceptions.GetCredentialException;
import androidx.credentials.exceptions.GetCredentialInterruptedException;
import androidx.credentials.exceptions.GetCredentialProviderConfigurationException;
import androidx.credentials.exceptions.GetCredentialUnsupportedException;
import androidx.credentials.exceptions.NoCredentialException;
import com.google.android.gms.auth.api.identity.AuthorizationClient;
import com.google.android.gms.auth.api.identity.AuthorizationRequest;
import com.google.android.gms.auth.api.identity.AuthorizationResult;
import com.google.android.gms.auth.api.identity.ClearTokenRequest;
import com.google.android.gms.auth.api.identity.Identity;
import com.google.android.gms.auth.api.identity.RevokeAccessRequest;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.libraries.identity.googleid.GetGoogleIdOption;
import com.google.android.libraries.identity.googleid.GetSignInWithGoogleOption;
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential;
import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.PluginRegistry;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Objects;
import java.util.concurrent.Executors;
import kotlin.Result;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;

/* JADX INFO: loaded from: classes3.dex */
public class GoogleSignInPlugin implements FlutterPlugin, ActivityAware {
    private static final String GOOGLE_ACCOUNT_TYPE = "com.google";
    private ActivityPluginBinding activityPluginBinding;
    private Delegate delegate;
    private BinaryMessenger messenger;

    public interface AuthorizationClientFactory {
        AuthorizationClient create(Context context);
    }

    public interface CredentialManagerFactory {
        CredentialManager create(Context context);
    }

    public interface GoogleIdCredentialConverter {
        GoogleIdTokenCredential createFrom(Credential credential);
    }

    private void initInstance(BinaryMessenger binaryMessenger, Context context) {
        initWithDelegate(binaryMessenger, new Delegate(context, new CredentialManagerFactory() { // from class: io.flutter.plugins.googlesignin.GoogleSignInPlugin$$ExternalSyntheticLambda0
            @Override // io.flutter.plugins.googlesignin.GoogleSignInPlugin.CredentialManagerFactory
            public final CredentialManager create(Context context2) {
                return CredentialManager.create(context2);
            }
        }, new AuthorizationClientFactory() { // from class: io.flutter.plugins.googlesignin.GoogleSignInPlugin$$ExternalSyntheticLambda1
            @Override // io.flutter.plugins.googlesignin.GoogleSignInPlugin.AuthorizationClientFactory
            public final AuthorizationClient create(Context context2) {
                return Identity.getAuthorizationClient(context2);
            }
        }, new GoogleIdCredentialConverter() { // from class: io.flutter.plugins.googlesignin.GoogleSignInPlugin$$ExternalSyntheticLambda2
            @Override // io.flutter.plugins.googlesignin.GoogleSignInPlugin.GoogleIdCredentialConverter
            public final GoogleIdTokenCredential createFrom(Credential credential) {
                return GoogleIdTokenCredential.createFrom(credential.getData());
            }
        }));
    }

    void initWithDelegate(BinaryMessenger binaryMessenger, Delegate delegate) {
        this.messenger = binaryMessenger;
        this.delegate = delegate;
        GoogleSignInApi.INSTANCE.setUp(binaryMessenger, delegate);
    }

    private void dispose() {
        this.delegate = null;
        if (this.messenger != null) {
            GoogleSignInApi.INSTANCE.setUp(this.messenger, null);
            this.messenger = null;
        }
    }

    private void attachToActivity(ActivityPluginBinding activityPluginBinding) {
        this.activityPluginBinding = activityPluginBinding;
        activityPluginBinding.addActivityResultListener(this.delegate);
        this.delegate.setActivity(activityPluginBinding.getActivity());
    }

    private void disposeActivity() {
        this.activityPluginBinding.removeActivityResultListener(this.delegate);
        this.delegate.setActivity(null);
        this.activityPluginBinding = null;
    }

    @Override // io.flutter.embedding.engine.plugins.FlutterPlugin
    public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        initInstance(flutterPluginBinding.getBinaryMessenger(), flutterPluginBinding.getApplicationContext());
    }

    @Override // io.flutter.embedding.engine.plugins.FlutterPlugin
    public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        dispose();
    }

    @Override // io.flutter.embedding.engine.plugins.activity.ActivityAware
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        attachToActivity(activityPluginBinding);
    }

    @Override // io.flutter.embedding.engine.plugins.activity.ActivityAware
    public void onDetachedFromActivityForConfigChanges() {
        disposeActivity();
    }

    @Override // io.flutter.embedding.engine.plugins.activity.ActivityAware
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
        attachToActivity(activityPluginBinding);
    }

    @Override // io.flutter.embedding.engine.plugins.activity.ActivityAware
    public void onDetachedFromActivity() {
        disposeActivity();
    }

    public static class Delegate implements PluginRegistry.ActivityResultListener, GoogleSignInApi {
        static final int REQUEST_CODE_AUTHORIZE = 53294;
        private Activity activity;
        private final AuthorizationClientFactory authorizationClientFactory;
        private final Context context;
        final GoogleIdCredentialConverter credentialConverter;
        private final CredentialManagerFactory credentialManagerFactory;
        private Function1<? super Result<? extends AuthorizeResult>, Unit> pendingAuthorizationCallback;

        public Delegate(Context context, CredentialManagerFactory credentialManagerFactory, AuthorizationClientFactory authorizationClientFactory, GoogleIdCredentialConverter googleIdCredentialConverter) {
            this.context = context;
            this.credentialManagerFactory = credentialManagerFactory;
            this.authorizationClientFactory = authorizationClientFactory;
            this.credentialConverter = googleIdCredentialConverter;
        }

        public void setActivity(Activity activity) {
            this.activity = activity;
        }

        public Activity getActivity() {
            return this.activity;
        }

        @Override // io.flutter.plugins.googlesignin.GoogleSignInApi
        public String getGoogleServicesJsonServerClientId() {
            int identifier = this.context.getResources().getIdentifier("default_web_client_id", "string", this.context.getPackageName());
            if (identifier != 0) {
                return this.context.getString(identifier);
            }
            return null;
        }

        @Override // io.flutter.plugins.googlesignin.GoogleSignInApi
        public void getCredential(GetCredentialRequestParams getCredentialRequestParams, final Function1<? super Result<? extends GetCredentialResult>, Unit> function1) {
            try {
                String serverClientId = getCredentialRequestParams.getServerClientId();
                if (serverClientId != null && !serverClientId.isEmpty()) {
                    Activity activity = getActivity();
                    if (activity == null) {
                        ResultUtilsKt.completeWithValue(function1, new GetCredentialFailure(GetCredentialFailureType.NO_ACTIVITY, "No activity available", null));
                        return;
                    }
                    String nonce = getCredentialRequestParams.getNonce();
                    String hostedDomain = getCredentialRequestParams.getHostedDomain();
                    GetCredentialRequest.Builder builder = new GetCredentialRequest.Builder();
                    if (getCredentialRequestParams.getUseButtonFlow()) {
                        GetSignInWithGoogleOption.Builder builder2 = new GetSignInWithGoogleOption.Builder(serverClientId);
                        if (hostedDomain != null) {
                            builder2.setHostedDomainFilter(hostedDomain);
                        }
                        if (nonce != null) {
                            builder2.setNonce(nonce);
                        }
                        builder.addCredentialOption(builder2.build());
                    } else {
                        GetCredentialRequestGoogleIdOptionParams googleIdOptionParams = getCredentialRequestParams.getGoogleIdOptionParams();
                        GetGoogleIdOption.Builder serverClientId2 = new GetGoogleIdOption.Builder().setFilterByAuthorizedAccounts(googleIdOptionParams.getFilterToAuthorized()).setAutoSelectEnabled(googleIdOptionParams.getAutoSelectEnabled()).setServerClientId(serverClientId);
                        if (nonce != null) {
                            serverClientId2.setNonce(nonce);
                        }
                        builder.addCredentialOption(serverClientId2.build());
                    }
                    this.credentialManagerFactory.create(this.context).getCredentialAsync(activity, builder.build(), (CancellationSignal) null, Executors.newSingleThreadExecutor(), new CredentialManagerCallback<GetCredentialResponse, GetCredentialException>() { // from class: io.flutter.plugins.googlesignin.GoogleSignInPlugin.Delegate.1
                        @Override // androidx.credentials.CredentialManagerCallback
                        public void onResult(GetCredentialResponse getCredentialResponse) {
                            Credential credential = getCredentialResponse.getCredential();
                            if ((credential instanceof CustomCredential) && credential.getType().equals(GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL)) {
                                GoogleIdTokenCredential googleIdTokenCredentialCreateFrom = Delegate.this.credentialConverter.createFrom(credential);
                                Uri zzf = googleIdTokenCredentialCreateFrom.getZzf();
                                ResultUtilsKt.completeWithValue(function1, new GetCredentialSuccess(new PlatformGoogleIdTokenCredential(googleIdTokenCredentialCreateFrom.getZzc(), googleIdTokenCredentialCreateFrom.getZzd(), googleIdTokenCredentialCreateFrom.getZze(), googleIdTokenCredentialCreateFrom.getZza(), googleIdTokenCredentialCreateFrom.getZzb(), zzf != null ? zzf.toString() : null)));
                                return;
                            }
                            ResultUtilsKt.completeWithValue(function1, new GetCredentialFailure(GetCredentialFailureType.UNEXPECTED_CREDENTIAL_TYPE, "Unexpected credential type: " + credential, null));
                        }

                        @Override // androidx.credentials.CredentialManagerCallback
                        public void onError(GetCredentialException getCredentialException) {
                            GetCredentialFailureType getCredentialFailureType;
                            if (getCredentialException instanceof GetCredentialCancellationException) {
                                getCredentialFailureType = GetCredentialFailureType.CANCELED;
                            } else if (getCredentialException instanceof GetCredentialInterruptedException) {
                                getCredentialFailureType = GetCredentialFailureType.INTERRUPTED;
                            } else if (getCredentialException instanceof GetCredentialProviderConfigurationException) {
                                getCredentialFailureType = GetCredentialFailureType.PROVIDER_CONFIGURATION_ISSUE;
                            } else if (getCredentialException instanceof GetCredentialUnsupportedException) {
                                getCredentialFailureType = GetCredentialFailureType.UNSUPPORTED;
                            } else if (getCredentialException instanceof NoCredentialException) {
                                getCredentialFailureType = GetCredentialFailureType.NO_CREDENTIAL;
                            } else {
                                getCredentialFailureType = GetCredentialFailureType.UNKNOWN;
                            }
                            ResultUtilsKt.completeWithValue(function1, new GetCredentialFailure(getCredentialFailureType, getCredentialException.getMessage(), null));
                        }
                    });
                    return;
                }
                ResultUtilsKt.completeWithValue(function1, new GetCredentialFailure(GetCredentialFailureType.MISSING_SERVER_CLIENT_ID, "CredentialManager requires a serverClientId.", null));
            } catch (RuntimeException e) {
                ResultUtilsKt.completeWithValue(function1, new GetCredentialFailure(GetCredentialFailureType.UNKNOWN, e.getMessage(), "Cause: " + e.getCause() + ", Stacktrace: " + Log.getStackTraceString(e)));
            }
        }

        @Override // io.flutter.plugins.googlesignin.GoogleSignInApi
        public void clearCredentialState(final Function1<? super Result<Unit>, Unit> function1) {
            this.credentialManagerFactory.create(this.context).clearCredentialStateAsync(new ClearCredentialStateRequest(), null, Executors.newSingleThreadExecutor(), new CredentialManagerCallback<Void, ClearCredentialException>() { // from class: io.flutter.plugins.googlesignin.GoogleSignInPlugin.Delegate.2
                @Override // androidx.credentials.CredentialManagerCallback
                public void onResult(Void r1) {
                    ResultUtilsKt.completeWithUnitSuccess(function1);
                }

                @Override // androidx.credentials.CredentialManagerCallback
                public void onError(ClearCredentialException clearCredentialException) {
                    ResultUtilsKt.completeWithUnitError(function1, new FlutterError("Clear Failed", clearCredentialException.getMessage(), null));
                }
            });
        }

        @Override // io.flutter.plugins.googlesignin.GoogleSignInApi
        public void clearAuthorizationToken(String str, final Function1<? super Result<Unit>, Unit> function1) {
            this.authorizationClientFactory.create(this.context).clearToken(ClearTokenRequest.builder().setToken(str).build()).addOnSuccessListener(new OnSuccessListener() { // from class: io.flutter.plugins.googlesignin.GoogleSignInPlugin$Delegate$$ExternalSyntheticLambda0
                @Override // com.google.android.gms.tasks.OnSuccessListener
                public final void onSuccess(Object obj) {
                    ResultUtilsKt.completeWithUnitSuccess(function1);
                }
            }).addOnFailureListener(new OnFailureListener() { // from class: io.flutter.plugins.googlesignin.GoogleSignInPlugin$Delegate$$ExternalSyntheticLambda1
                @Override // com.google.android.gms.tasks.OnFailureListener
                public final void onFailure(Exception exc) {
                    ResultUtilsKt.completeWithUnitError(function1, new FlutterError("clearAuthorizationToken failed", exc.getMessage(), null));
                }
            });
        }

        @Override // io.flutter.plugins.googlesignin.GoogleSignInApi
        public void authorize(PlatformAuthorizationRequest platformAuthorizationRequest, final boolean z, final Function1<? super Result<? extends AuthorizeResult>, Unit> function1) {
            try {
                ArrayList arrayList = new ArrayList();
                Iterator<String> it = platformAuthorizationRequest.getScopes().iterator();
                while (it.hasNext()) {
                    arrayList.add(new Scope(it.next()));
                }
                AuthorizationRequest.Builder requestedScopes = AuthorizationRequest.builder().setRequestedScopes(arrayList);
                if (platformAuthorizationRequest.getHostedDomain() != null) {
                    requestedScopes.filterByHostedDomain(platformAuthorizationRequest.getHostedDomain());
                }
                if (platformAuthorizationRequest.getServerClientIdForForcedRefreshToken() != null) {
                    requestedScopes.requestOfflineAccess(platformAuthorizationRequest.getServerClientIdForForcedRefreshToken(), true);
                }
                if (platformAuthorizationRequest.getAccountEmail() != null) {
                    requestedScopes.setAccount(new Account(platformAuthorizationRequest.getAccountEmail(), "com.google"));
                }
                this.authorizationClientFactory.create(this.context).authorize(requestedScopes.build()).addOnSuccessListener(new OnSuccessListener() { // from class: io.flutter.plugins.googlesignin.GoogleSignInPlugin$Delegate$$ExternalSyntheticLambda4
                    @Override // com.google.android.gms.tasks.OnSuccessListener
                    public final void onSuccess(Object obj) {
                        this.f$0.lambda$authorize$2(z, function1, (AuthorizationResult) obj);
                    }
                }).addOnFailureListener(new OnFailureListener() { // from class: io.flutter.plugins.googlesignin.GoogleSignInPlugin$Delegate$$ExternalSyntheticLambda5
                    @Override // com.google.android.gms.tasks.OnFailureListener
                    public final void onFailure(Exception exc) {
                        ResultUtilsKt.completeWithValue(function1, new AuthorizeFailure(AuthorizeFailureType.AUTHORIZE_FAILURE, exc.getMessage(), null));
                    }
                });
            } catch (RuntimeException e) {
                ResultUtilsKt.completeWithValue(function1, new AuthorizeFailure(AuthorizeFailureType.API_EXCEPTION, e.getMessage(), "Cause: " + e.getCause() + ", Stacktrace: " + Log.getStackTraceString(e)));
            }
        }

        /* JADX INFO: Access modifiers changed from: private */
        public /* synthetic */ void lambda$authorize$2(boolean z, Function1 function1, AuthorizationResult authorizationResult) {
            if (!authorizationResult.hasResolution()) {
                ResultUtilsKt.completeWithValue(function1, new PlatformAuthorizationResult(authorizationResult.getAccessToken(), authorizationResult.getServerAuthCode(), authorizationResult.getGrantedScopes()));
                return;
            }
            if (z) {
                Activity activity = getActivity();
                if (activity == null) {
                    ResultUtilsKt.completeWithValue(function1, new AuthorizeFailure(AuthorizeFailureType.NO_ACTIVITY, "No activity available", null));
                    return;
                }
                PendingIntent pendingIntent = (PendingIntent) Objects.requireNonNull(authorizationResult.getPendingIntent());
                try {
                    this.pendingAuthorizationCallback = function1;
                    activity.startIntentSenderForResult(pendingIntent.getIntentSender(), REQUEST_CODE_AUTHORIZE, null, 0, 0, 0, null);
                    return;
                } catch (IntentSender.SendIntentException e) {
                    this.pendingAuthorizationCallback = null;
                    ResultUtilsKt.completeWithValue(function1, new AuthorizeFailure(AuthorizeFailureType.PENDING_INTENT_EXCEPTION, e.getMessage(), null));
                    return;
                }
            }
            ResultUtilsKt.completeWithValue(function1, new AuthorizeFailure(AuthorizeFailureType.UNAUTHORIZED, null, null));
        }

        @Override // io.flutter.plugins.googlesignin.GoogleSignInApi
        public void revokeAccess(PlatformRevokeAccessRequest platformRevokeAccessRequest, final Function1<? super Result<Unit>, Unit> function1) {
            ArrayList arrayList = new ArrayList();
            Iterator<String> it = platformRevokeAccessRequest.getScopes().iterator();
            while (it.hasNext()) {
                arrayList.add(new Scope(it.next()));
            }
            this.authorizationClientFactory.create(this.context).revokeAccess(RevokeAccessRequest.builder().setAccount(new Account(platformRevokeAccessRequest.getAccountEmail(), "com.google")).setScopes(arrayList).build()).addOnSuccessListener(new OnSuccessListener() { // from class: io.flutter.plugins.googlesignin.GoogleSignInPlugin$Delegate$$ExternalSyntheticLambda2
                @Override // com.google.android.gms.tasks.OnSuccessListener
                public final void onSuccess(Object obj) {
                    ResultUtilsKt.completeWithUnitSuccess(function1);
                }
            }).addOnFailureListener(new OnFailureListener() { // from class: io.flutter.plugins.googlesignin.GoogleSignInPlugin$Delegate$$ExternalSyntheticLambda3
                @Override // com.google.android.gms.tasks.OnFailureListener
                public final void onFailure(Exception exc) {
                    ResultUtilsKt.completeWithUnitError(function1, new FlutterError("revokeAccess failed", exc.getMessage(), null));
                }
            });
        }

        @Override // io.flutter.plugin.common.PluginRegistry.ActivityResultListener
        public boolean onActivityResult(int i, int i2, Intent intent) {
            if (i != REQUEST_CODE_AUTHORIZE) {
                return false;
            }
            if (this.pendingAuthorizationCallback != null) {
                try {
                    AuthorizationResult authorizationResultFromIntent = this.authorizationClientFactory.create(this.context).getAuthorizationResultFromIntent(intent);
                    ResultUtilsKt.completeWithValue(this.pendingAuthorizationCallback, new PlatformAuthorizationResult(authorizationResultFromIntent.getAccessToken(), authorizationResultFromIntent.getServerAuthCode(), authorizationResultFromIntent.getGrantedScopes()));
                    return true;
                } catch (ApiException e) {
                    ResultUtilsKt.completeWithValue(this.pendingAuthorizationCallback, new AuthorizeFailure(AuthorizeFailureType.API_EXCEPTION, e.getMessage(), null));
                    this.pendingAuthorizationCallback = null;
                    return false;
                }
            }
            Log.e("google_sign_in", "Unexpected authorization result callback");
            return false;
        }
    }
}
