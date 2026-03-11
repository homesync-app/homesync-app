package io.flutter.plugins.localauth;

import android.app.Activity;
import android.app.KeyguardManager;
import android.content.Context;
import android.os.Build;
import androidx.biometric.BiometricManager;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.Lifecycle;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter;
import io.flutter.plugins.localauth.AuthenticationHelper;
import io.flutter.plugins.localauth.Messages;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

/* JADX INFO: loaded from: classes3.dex */
public class LocalAuthPlugin implements FlutterPlugin, ActivityAware, Messages.LocalAuthApi {
    private Activity activity;
    private AuthenticationHelper authHelper;
    final AtomicBoolean authInProgress = new AtomicBoolean(false);
    private BiometricManager biometricManager;
    private KeyguardManager keyguardManager;
    private Lifecycle lifecycle;

    @Override // io.flutter.plugins.localauth.Messages.LocalAuthApi
    public Boolean isDeviceSupported() {
        return Boolean.valueOf(isDeviceSecure() || canAuthenticateWithBiometrics());
    }

    @Override // io.flutter.plugins.localauth.Messages.LocalAuthApi
    public Boolean deviceCanSupportBiometrics() {
        return Boolean.valueOf(hasBiometricHardware());
    }

    @Override // io.flutter.plugins.localauth.Messages.LocalAuthApi
    public List<Messages.AuthClassification> getEnrolledBiometrics() {
        if (this.biometricManager == null) {
            return null;
        }
        ArrayList arrayList = new ArrayList();
        if (this.biometricManager.canAuthenticate(255) == 0) {
            arrayList.add(Messages.AuthClassification.WEAK);
        }
        if (this.biometricManager.canAuthenticate(15) == 0) {
            arrayList.add(Messages.AuthClassification.STRONG);
        }
        return arrayList;
    }

    @Override // io.flutter.plugins.localauth.Messages.LocalAuthApi
    public Boolean stopAuthentication() {
        try {
            if (this.authHelper != null && this.authInProgress.get()) {
                this.authHelper.stopAuthentication();
                this.authHelper = null;
            }
            this.authInProgress.set(false);
            return true;
        } catch (Exception unused) {
            return false;
        }
    }

    @Override // io.flutter.plugins.localauth.Messages.LocalAuthApi
    public void authenticate(Messages.AuthOptions authOptions, Messages.AuthStrings authStrings, Messages.Result<Messages.AuthResult> result) {
        if (this.authInProgress.get()) {
            result.success(new Messages.AuthResult.Builder().setCode(Messages.AuthResultCode.ALREADY_IN_PROGRESS).build());
            return;
        }
        Activity activity = this.activity;
        if (activity == null || activity.isFinishing()) {
            result.success(new Messages.AuthResult.Builder().setCode(Messages.AuthResultCode.NO_ACTIVITY).build());
            return;
        }
        if (!(this.activity instanceof FragmentActivity)) {
            result.success(new Messages.AuthResult.Builder().setCode(Messages.AuthResultCode.NOT_FRAGMENT_ACTIVITY).build());
        } else {
            if (!isDeviceSupported().booleanValue()) {
                result.success(new Messages.AuthResult.Builder().setCode(Messages.AuthResultCode.NO_CREDENTIALS).build());
                return;
            }
            this.authInProgress.set(true);
            sendAuthenticationRequest(authOptions, authStrings, !authOptions.getBiometricOnly().booleanValue() && canAuthenticateWithDeviceCredential(), createAuthCompletionHandler(result));
        }
    }

    public AuthenticationHelper.AuthCompletionHandler createAuthCompletionHandler(final Messages.Result<Messages.AuthResult> result) {
        return new AuthenticationHelper.AuthCompletionHandler() { // from class: io.flutter.plugins.localauth.LocalAuthPlugin$$ExternalSyntheticLambda0
            @Override // io.flutter.plugins.localauth.AuthenticationHelper.AuthCompletionHandler
            public final void complete(Messages.AuthResult authResult) {
                this.f$0.lambda$createAuthCompletionHandler$0(result, authResult);
            }
        };
    }

    public void sendAuthenticationRequest(Messages.AuthOptions authOptions, Messages.AuthStrings authStrings, boolean z, AuthenticationHelper.AuthCompletionHandler authCompletionHandler) {
        AuthenticationHelper authenticationHelper = new AuthenticationHelper(this.lifecycle, (FragmentActivity) this.activity, authOptions, authStrings, authCompletionHandler, z);
        this.authHelper = authenticationHelper;
        authenticationHelper.authenticate();
    }

    /* JADX INFO: Access modifiers changed from: package-private */
    /* JADX INFO: renamed from: onAuthenticationCompleted, reason: merged with bridge method [inline-methods] */
    public void lambda$createAuthCompletionHandler$0(Messages.Result<Messages.AuthResult> result, Messages.AuthResult authResult) {
        if (this.authInProgress.compareAndSet(true, false)) {
            result.success(authResult);
        }
    }

    public boolean isDeviceSecure() {
        KeyguardManager keyguardManager = this.keyguardManager;
        if (keyguardManager == null) {
            return false;
        }
        return keyguardManager.isDeviceSecure();
    }

    private boolean canAuthenticateWithBiometrics() {
        BiometricManager biometricManager = this.biometricManager;
        return biometricManager != null && biometricManager.canAuthenticate(255) == 0;
    }

    private boolean hasBiometricHardware() {
        BiometricManager biometricManager = this.biometricManager;
        return (biometricManager == null || biometricManager.canAuthenticate(255) == 12) ? false : true;
    }

    public boolean canAuthenticateWithDeviceCredential() {
        if (Build.VERSION.SDK_INT < 30) {
            return isDeviceSecure();
        }
        BiometricManager biometricManager = this.biometricManager;
        return biometricManager != null && biometricManager.canAuthenticate(32768) == 0;
    }

    @Override // io.flutter.embedding.engine.plugins.FlutterPlugin
    public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        Messages.LocalAuthApi.setUp(flutterPluginBinding.getBinaryMessenger(), this);
    }

    @Override // io.flutter.embedding.engine.plugins.FlutterPlugin
    public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        Messages.LocalAuthApi.setUp(flutterPluginBinding.getBinaryMessenger(), null);
    }

    private void setServicesFromActivity(Activity activity) {
        if (activity == null) {
            return;
        }
        this.activity = activity;
        Context baseContext = activity.getBaseContext();
        this.biometricManager = BiometricManager.from(activity);
        this.keyguardManager = (KeyguardManager) baseContext.getSystemService("keyguard");
    }

    @Override // io.flutter.embedding.engine.plugins.activity.ActivityAware
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        setServicesFromActivity(activityPluginBinding.getActivity());
        this.lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(activityPluginBinding);
    }

    @Override // io.flutter.embedding.engine.plugins.activity.ActivityAware
    public void onDetachedFromActivityForConfigChanges() {
        this.lifecycle = null;
        this.activity = null;
    }

    @Override // io.flutter.embedding.engine.plugins.activity.ActivityAware
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
        setServicesFromActivity(activityPluginBinding.getActivity());
        this.lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(activityPluginBinding);
    }

    @Override // io.flutter.embedding.engine.plugins.activity.ActivityAware
    public void onDetachedFromActivity() {
        this.lifecycle = null;
        this.activity = null;
    }

    final Activity getActivity() {
        return this.activity;
    }

    void setBiometricManager(BiometricManager biometricManager) {
        this.biometricManager = biometricManager;
    }

    void setKeyguardManager(KeyguardManager keyguardManager) {
        this.keyguardManager = keyguardManager;
    }
}
