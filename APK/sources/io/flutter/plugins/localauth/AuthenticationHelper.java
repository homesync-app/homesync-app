package io.flutter.plugins.localauth;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import androidx.biometric.BiometricPrompt;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;
import io.flutter.plugins.localauth.Messages;
import java.util.concurrent.Executor;

/* JADX INFO: loaded from: classes3.dex */
class AuthenticationHelper extends BiometricPrompt.AuthenticationCallback implements Application.ActivityLifecycleCallbacks, DefaultLifecycleObserver {
    private final FragmentActivity activity;
    private BiometricPrompt biometricPrompt;
    private final AuthCompletionHandler completionHandler;
    private final boolean isAuthSticky;
    private final Lifecycle lifecycle;
    private final BiometricPrompt.PromptInfo promptInfo;
    private final Messages.AuthStrings strings;
    private boolean activityPaused = false;
    private final UiThreadExecutor uiThreadExecutor = new UiThreadExecutor();

    interface AuthCompletionHandler {
        void complete(Messages.AuthResult authResult);
    }

    @Override // android.app.Application.ActivityLifecycleCallbacks
    public void onActivityCreated(Activity activity, Bundle bundle) {
    }

    @Override // android.app.Application.ActivityLifecycleCallbacks
    public void onActivityDestroyed(Activity activity) {
    }

    @Override // android.app.Application.ActivityLifecycleCallbacks
    public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {
    }

    @Override // android.app.Application.ActivityLifecycleCallbacks
    public void onActivityStarted(Activity activity) {
    }

    @Override // android.app.Application.ActivityLifecycleCallbacks
    public void onActivityStopped(Activity activity) {
    }

    @Override // androidx.biometric.BiometricPrompt.AuthenticationCallback
    public void onAuthenticationFailed() {
    }

    @Override // androidx.lifecycle.DefaultLifecycleObserver
    public void onCreate(LifecycleOwner lifecycleOwner) {
    }

    @Override // androidx.lifecycle.DefaultLifecycleObserver
    public void onDestroy(LifecycleOwner lifecycleOwner) {
    }

    @Override // androidx.lifecycle.DefaultLifecycleObserver
    public void onStart(LifecycleOwner lifecycleOwner) {
    }

    @Override // androidx.lifecycle.DefaultLifecycleObserver
    public void onStop(LifecycleOwner lifecycleOwner) {
    }

    AuthenticationHelper(Lifecycle lifecycle, FragmentActivity fragmentActivity, Messages.AuthOptions authOptions, Messages.AuthStrings authStrings, AuthCompletionHandler authCompletionHandler, boolean z) {
        int i;
        this.lifecycle = lifecycle;
        this.activity = fragmentActivity;
        this.completionHandler = authCompletionHandler;
        this.strings = authStrings;
        this.isAuthSticky = authOptions.getSticky().booleanValue();
        BiometricPrompt.PromptInfo.Builder confirmationRequired = new BiometricPrompt.PromptInfo.Builder().setDescription(authStrings.getReason()).setTitle(authStrings.getSignInTitle()).setSubtitle(authStrings.getSignInHint()).setConfirmationRequired(authOptions.getSensitiveTransaction().booleanValue());
        if (z) {
            i = 33023;
        } else {
            confirmationRequired.setNegativeButtonText(authStrings.getCancelButton());
            i = 255;
        }
        confirmationRequired.setAllowedAuthenticators(i);
        this.promptInfo = confirmationRequired.build();
    }

    void authenticate() {
        Lifecycle lifecycle = this.lifecycle;
        if (lifecycle != null) {
            lifecycle.addObserver(this);
        } else {
            this.activity.getApplication().registerActivityLifecycleCallbacks(this);
        }
        BiometricPrompt biometricPrompt = new BiometricPrompt(this.activity, this.uiThreadExecutor, this);
        this.biometricPrompt = biometricPrompt;
        biometricPrompt.authenticate(this.promptInfo);
    }

    void stopAuthentication() {
        BiometricPrompt biometricPrompt = this.biometricPrompt;
        if (biometricPrompt != null) {
            biometricPrompt.cancelAuthentication();
            this.biometricPrompt = null;
        }
    }

    private void stop() {
        Lifecycle lifecycle = this.lifecycle;
        if (lifecycle != null) {
            lifecycle.removeObserver(this);
        } else {
            this.activity.getApplication().unregisterActivityLifecycleCallbacks(this);
        }
    }

    @Override // androidx.biometric.BiometricPrompt.AuthenticationCallback
    public void onAuthenticationError(int i, CharSequence charSequence) {
        Messages.AuthResultCode authResultCode;
        switch (i) {
            case 1:
                authResultCode = Messages.AuthResultCode.HARDWARE_UNAVAILABLE;
                break;
            case 2:
            case 6:
            case 8:
            default:
                authResultCode = Messages.AuthResultCode.UNKNOWN_ERROR;
                break;
            case 3:
                authResultCode = Messages.AuthResultCode.TIMEOUT;
                break;
            case 4:
                authResultCode = Messages.AuthResultCode.NO_SPACE;
                break;
            case 5:
                if (this.activityPaused && this.isAuthSticky) {
                    return;
                } else {
                    authResultCode = Messages.AuthResultCode.SYSTEM_CANCELED;
                }
                break;
            case 7:
                authResultCode = Messages.AuthResultCode.LOCKED_OUT_TEMPORARILY;
                break;
            case 9:
                authResultCode = Messages.AuthResultCode.LOCKED_OUT_PERMANENTLY;
                break;
            case 10:
                authResultCode = Messages.AuthResultCode.USER_CANCELED;
                break;
            case 11:
                authResultCode = Messages.AuthResultCode.NOT_ENROLLED;
                break;
            case 12:
                authResultCode = Messages.AuthResultCode.NO_HARDWARE;
                break;
            case 13:
                authResultCode = Messages.AuthResultCode.NEGATIVE_BUTTON;
                break;
            case 14:
                authResultCode = Messages.AuthResultCode.NO_CREDENTIALS;
                break;
            case 15:
                authResultCode = Messages.AuthResultCode.SECURITY_UPDATE_REQUIRED;
                break;
        }
        this.completionHandler.complete(new Messages.AuthResult.Builder().setCode(authResultCode).setErrorMessage(charSequence.toString()).build());
        stop();
    }

    @Override // androidx.biometric.BiometricPrompt.AuthenticationCallback
    public void onAuthenticationSucceeded(BiometricPrompt.AuthenticationResult authenticationResult) {
        this.completionHandler.complete(new Messages.AuthResult.Builder().setCode(Messages.AuthResultCode.SUCCESS).build());
        stop();
    }

    @Override // android.app.Application.ActivityLifecycleCallbacks
    public void onActivityPaused(Activity activity) {
        if (this.isAuthSticky) {
            this.activityPaused = true;
        }
    }

    @Override // android.app.Application.ActivityLifecycleCallbacks
    public void onActivityResumed(Activity activity) {
        if (this.isAuthSticky) {
            this.activityPaused = false;
            final BiometricPrompt biometricPrompt = new BiometricPrompt(this.activity, this.uiThreadExecutor, this);
            this.uiThreadExecutor.handler.post(new Runnable() { // from class: io.flutter.plugins.localauth.AuthenticationHelper$$ExternalSyntheticLambda0
                @Override // java.lang.Runnable
                public final void run() {
                    this.f$0.lambda$onActivityResumed$0(biometricPrompt);
                }
            });
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public /* synthetic */ void lambda$onActivityResumed$0(BiometricPrompt biometricPrompt) {
        biometricPrompt.authenticate(this.promptInfo);
    }

    @Override // androidx.lifecycle.DefaultLifecycleObserver
    public void onPause(LifecycleOwner lifecycleOwner) {
        onActivityPaused(null);
    }

    @Override // androidx.lifecycle.DefaultLifecycleObserver
    public void onResume(LifecycleOwner lifecycleOwner) {
        onActivityResumed(null);
    }

    static class UiThreadExecutor implements Executor {
        final Handler handler = new Handler(Looper.getMainLooper());

        UiThreadExecutor() {
        }

        @Override // java.util.concurrent.Executor
        public void execute(Runnable runnable) {
            this.handler.post(runnable);
        }
    }
}
