.class Lio/flutter/plugins/localauth/AuthenticationHelper;
.super Landroidx/biometric/BiometricPrompt$AuthenticationCallback;
.source "AuthenticationHelper.java"

# interfaces
.implements Landroid/app/Application$ActivityLifecycleCallbacks;
.implements Landroidx/lifecycle/DefaultLifecycleObserver;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/localauth/AuthenticationHelper$AuthCompletionHandler;,
        Lio/flutter/plugins/localauth/AuthenticationHelper$UiThreadExecutor;
    }
.end annotation


# instance fields
.field private final activity:Landroidx/fragment/app/FragmentActivity;

.field private activityPaused:Z

.field private biometricPrompt:Landroidx/biometric/BiometricPrompt;

.field private final completionHandler:Lio/flutter/plugins/localauth/AuthenticationHelper$AuthCompletionHandler;

.field private final isAuthSticky:Z

.field private final lifecycle:Landroidx/lifecycle/Lifecycle;

.field private final promptInfo:Landroidx/biometric/BiometricPrompt$PromptInfo;

.field private final strings:Lio/flutter/plugins/localauth/Messages$AuthStrings;

.field private final uiThreadExecutor:Lio/flutter/plugins/localauth/AuthenticationHelper$UiThreadExecutor;


# direct methods
.method public static synthetic $r8$lambda$IZxQY9xuRT1VUscTlAGhkJTUouE(Lio/flutter/plugins/localauth/AuthenticationHelper;Landroidx/biometric/BiometricPrompt;)V
    .locals 0

    invoke-direct {p0, p1}, Lio/flutter/plugins/localauth/AuthenticationHelper;->lambda$onActivityResumed$0(Landroidx/biometric/BiometricPrompt;)V

    return-void
.end method

.method constructor <init>(Landroidx/lifecycle/Lifecycle;Landroidx/fragment/app/FragmentActivity;Lio/flutter/plugins/localauth/Messages$AuthOptions;Lio/flutter/plugins/localauth/Messages$AuthStrings;Lio/flutter/plugins/localauth/AuthenticationHelper$AuthCompletionHandler;Z)V
    .locals 1

    .line 53
    invoke-direct {p0}, Landroidx/biometric/BiometricPrompt$AuthenticationCallback;-><init>()V

    const/4 v0, 0x0

    .line 44
    iput-boolean v0, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->activityPaused:Z

    .line 54
    iput-object p1, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->lifecycle:Landroidx/lifecycle/Lifecycle;

    .line 55
    iput-object p2, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->activity:Landroidx/fragment/app/FragmentActivity;

    .line 56
    iput-object p5, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->completionHandler:Lio/flutter/plugins/localauth/AuthenticationHelper$AuthCompletionHandler;

    .line 57
    iput-object p4, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->strings:Lio/flutter/plugins/localauth/Messages$AuthStrings;

    .line 58
    invoke-virtual {p3}, Lio/flutter/plugins/localauth/Messages$AuthOptions;->getSticky()Ljava/lang/Boolean;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/Boolean;->booleanValue()Z

    move-result p1

    iput-boolean p1, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->isAuthSticky:Z

    .line 59
    new-instance p1, Lio/flutter/plugins/localauth/AuthenticationHelper$UiThreadExecutor;

    invoke-direct {p1}, Lio/flutter/plugins/localauth/AuthenticationHelper$UiThreadExecutor;-><init>()V

    iput-object p1, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->uiThreadExecutor:Lio/flutter/plugins/localauth/AuthenticationHelper$UiThreadExecutor;

    .line 61
    new-instance p1, Landroidx/biometric/BiometricPrompt$PromptInfo$Builder;

    invoke-direct {p1}, Landroidx/biometric/BiometricPrompt$PromptInfo$Builder;-><init>()V

    .line 63
    invoke-virtual {p4}, Lio/flutter/plugins/localauth/Messages$AuthStrings;->getReason()Ljava/lang/String;

    move-result-object p2

    invoke-virtual {p1, p2}, Landroidx/biometric/BiometricPrompt$PromptInfo$Builder;->setDescription(Ljava/lang/CharSequence;)Landroidx/biometric/BiometricPrompt$PromptInfo$Builder;

    move-result-object p1

    .line 64
    invoke-virtual {p4}, Lio/flutter/plugins/localauth/Messages$AuthStrings;->getSignInTitle()Ljava/lang/String;

    move-result-object p2

    invoke-virtual {p1, p2}, Landroidx/biometric/BiometricPrompt$PromptInfo$Builder;->setTitle(Ljava/lang/CharSequence;)Landroidx/biometric/BiometricPrompt$PromptInfo$Builder;

    move-result-object p1

    .line 65
    invoke-virtual {p4}, Lio/flutter/plugins/localauth/Messages$AuthStrings;->getSignInHint()Ljava/lang/String;

    move-result-object p2

    invoke-virtual {p1, p2}, Landroidx/biometric/BiometricPrompt$PromptInfo$Builder;->setSubtitle(Ljava/lang/CharSequence;)Landroidx/biometric/BiometricPrompt$PromptInfo$Builder;

    move-result-object p1

    .line 66
    invoke-virtual {p3}, Lio/flutter/plugins/localauth/Messages$AuthOptions;->getSensitiveTransaction()Ljava/lang/Boolean;

    move-result-object p2

    invoke-virtual {p2}, Ljava/lang/Boolean;->booleanValue()Z

    move-result p2

    invoke-virtual {p1, p2}, Landroidx/biometric/BiometricPrompt$PromptInfo$Builder;->setConfirmationRequired(Z)Landroidx/biometric/BiometricPrompt$PromptInfo$Builder;

    move-result-object p1

    if-eqz p6, :cond_0

    const p2, 0x80ff

    goto :goto_0

    .line 75
    :cond_0
    invoke-virtual {p4}, Lio/flutter/plugins/localauth/Messages$AuthStrings;->getCancelButton()Ljava/lang/String;

    move-result-object p2

    invoke-virtual {p1, p2}, Landroidx/biometric/BiometricPrompt$PromptInfo$Builder;->setNegativeButtonText(Ljava/lang/CharSequence;)Landroidx/biometric/BiometricPrompt$PromptInfo$Builder;

    const/16 p2, 0xff

    .line 78
    :goto_0
    invoke-virtual {p1, p2}, Landroidx/biometric/BiometricPrompt$PromptInfo$Builder;->setAllowedAuthenticators(I)Landroidx/biometric/BiometricPrompt$PromptInfo$Builder;

    .line 79
    invoke-virtual {p1}, Landroidx/biometric/BiometricPrompt$PromptInfo$Builder;->build()Landroidx/biometric/BiometricPrompt$PromptInfo;

    move-result-object p1

    iput-object p1, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->promptInfo:Landroidx/biometric/BiometricPrompt$PromptInfo;

    return-void
.end method

.method private synthetic lambda$onActivityResumed$0(Landroidx/biometric/BiometricPrompt;)V
    .locals 1

    .line 195
    iget-object v0, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->promptInfo:Landroidx/biometric/BiometricPrompt$PromptInfo;

    invoke-virtual {p1, v0}, Landroidx/biometric/BiometricPrompt;->authenticate(Landroidx/biometric/BiometricPrompt$PromptInfo;)V

    return-void
.end method

.method private stop()V
    .locals 1

    .line 103
    iget-object v0, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->lifecycle:Landroidx/lifecycle/Lifecycle;

    if-eqz v0, :cond_0

    .line 104
    invoke-virtual {v0, p0}, Landroidx/lifecycle/Lifecycle;->removeObserver(Landroidx/lifecycle/LifecycleObserver;)V

    return-void

    .line 107
    :cond_0
    iget-object v0, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->activity:Landroidx/fragment/app/FragmentActivity;

    invoke-virtual {v0}, Landroidx/fragment/app/FragmentActivity;->getApplication()Landroid/app/Application;

    move-result-object v0

    invoke-virtual {v0, p0}, Landroid/app/Application;->unregisterActivityLifecycleCallbacks(Landroid/app/Application$ActivityLifecycleCallbacks;)V

    return-void
.end method


# virtual methods
.method authenticate()V
    .locals 3

    .line 84
    iget-object v0, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->lifecycle:Landroidx/lifecycle/Lifecycle;

    if-eqz v0, :cond_0

    .line 85
    invoke-virtual {v0, p0}, Landroidx/lifecycle/Lifecycle;->addObserver(Landroidx/lifecycle/LifecycleObserver;)V

    goto :goto_0

    .line 87
    :cond_0
    iget-object v0, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->activity:Landroidx/fragment/app/FragmentActivity;

    invoke-virtual {v0}, Landroidx/fragment/app/FragmentActivity;->getApplication()Landroid/app/Application;

    move-result-object v0

    invoke-virtual {v0, p0}, Landroid/app/Application;->registerActivityLifecycleCallbacks(Landroid/app/Application$ActivityLifecycleCallbacks;)V

    .line 89
    :goto_0
    new-instance v0, Landroidx/biometric/BiometricPrompt;

    iget-object v1, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->activity:Landroidx/fragment/app/FragmentActivity;

    iget-object v2, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->uiThreadExecutor:Lio/flutter/plugins/localauth/AuthenticationHelper$UiThreadExecutor;

    invoke-direct {v0, v1, v2, p0}, Landroidx/biometric/BiometricPrompt;-><init>(Landroidx/fragment/app/FragmentActivity;Ljava/util/concurrent/Executor;Landroidx/biometric/BiometricPrompt$AuthenticationCallback;)V

    iput-object v0, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->biometricPrompt:Landroidx/biometric/BiometricPrompt;

    .line 90
    iget-object v1, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->promptInfo:Landroidx/biometric/BiometricPrompt$PromptInfo;

    invoke-virtual {v0, v1}, Landroidx/biometric/BiometricPrompt;->authenticate(Landroidx/biometric/BiometricPrompt$PromptInfo;)V

    return-void
.end method

.method public onActivityCreated(Landroid/app/Activity;Landroid/os/Bundle;)V
    .locals 0

    return-void
.end method

.method public onActivityDestroyed(Landroid/app/Activity;)V
    .locals 0

    return-void
.end method

.method public onActivityPaused(Landroid/app/Activity;)V
    .locals 0

    .line 183
    iget-boolean p1, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->isAuthSticky:Z

    if-eqz p1, :cond_0

    const/4 p1, 0x1

    .line 184
    iput-boolean p1, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->activityPaused:Z

    :cond_0
    return-void
.end method

.method public onActivityResumed(Landroid/app/Activity;)V
    .locals 2

    .line 190
    iget-boolean p1, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->isAuthSticky:Z

    if-eqz p1, :cond_0

    const/4 p1, 0x0

    .line 191
    iput-boolean p1, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->activityPaused:Z

    .line 192
    new-instance p1, Landroidx/biometric/BiometricPrompt;

    iget-object v0, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->activity:Landroidx/fragment/app/FragmentActivity;

    iget-object v1, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->uiThreadExecutor:Lio/flutter/plugins/localauth/AuthenticationHelper$UiThreadExecutor;

    invoke-direct {p1, v0, v1, p0}, Landroidx/biometric/BiometricPrompt;-><init>(Landroidx/fragment/app/FragmentActivity;Ljava/util/concurrent/Executor;Landroidx/biometric/BiometricPrompt$AuthenticationCallback;)V

    .line 195
    iget-object v0, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->uiThreadExecutor:Lio/flutter/plugins/localauth/AuthenticationHelper$UiThreadExecutor;

    iget-object v0, v0, Lio/flutter/plugins/localauth/AuthenticationHelper$UiThreadExecutor;->handler:Landroid/os/Handler;

    new-instance v1, Lio/flutter/plugins/localauth/AuthenticationHelper$$ExternalSyntheticLambda0;

    invoke-direct {v1, p0, p1}, Lio/flutter/plugins/localauth/AuthenticationHelper$$ExternalSyntheticLambda0;-><init>(Lio/flutter/plugins/localauth/AuthenticationHelper;Landroidx/biometric/BiometricPrompt;)V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    :cond_0
    return-void
.end method

.method public onActivitySaveInstanceState(Landroid/app/Activity;Landroid/os/Bundle;)V
    .locals 0

    return-void
.end method

.method public onActivityStarted(Landroid/app/Activity;)V
    .locals 0

    return-void
.end method

.method public onActivityStopped(Landroid/app/Activity;)V
    .locals 0

    return-void
.end method

.method public onAuthenticationError(ILjava/lang/CharSequence;)V
    .locals 2

    packed-switch p1, :pswitch_data_0

    .line 157
    :pswitch_0
    sget-object p1, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->UNKNOWN_ERROR:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    goto :goto_0

    .line 154
    :pswitch_1
    sget-object p1, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->SECURITY_UPDATE_REQUIRED:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    goto :goto_0

    .line 122
    :pswitch_2
    sget-object p1, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NO_CREDENTIALS:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    goto :goto_0

    .line 119
    :pswitch_3
    sget-object p1, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NEGATIVE_BUTTON:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    goto :goto_0

    .line 131
    :pswitch_4
    sget-object p1, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NO_HARDWARE:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    goto :goto_0

    .line 125
    :pswitch_5
    sget-object p1, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NOT_ENROLLED:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    goto :goto_0

    .line 116
    :pswitch_6
    sget-object p1, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->USER_CANCELED:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    goto :goto_0

    .line 137
    :pswitch_7
    sget-object p1, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->LOCKED_OUT_PERMANENTLY:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    goto :goto_0

    .line 134
    :pswitch_8
    sget-object p1, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->LOCKED_OUT_TEMPORARILY:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    goto :goto_0

    .line 142
    :pswitch_9
    iget-boolean p1, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->activityPaused:Z

    if-eqz p1, :cond_0

    iget-boolean p1, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->isAuthSticky:Z

    if-eqz p1, :cond_0

    return-void

    .line 145
    :cond_0
    sget-object p1, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->SYSTEM_CANCELED:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    goto :goto_0

    .line 151
    :pswitch_a
    sget-object p1, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NO_SPACE:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    goto :goto_0

    .line 148
    :pswitch_b
    sget-object p1, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->TIMEOUT:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    goto :goto_0

    .line 128
    :pswitch_c
    sget-object p1, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->HARDWARE_UNAVAILABLE:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    .line 160
    :goto_0
    iget-object v0, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->completionHandler:Lio/flutter/plugins/localauth/AuthenticationHelper$AuthCompletionHandler;

    new-instance v1, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;

    invoke-direct {v1}, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;-><init>()V

    .line 161
    invoke-virtual {v1, p1}, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;->setCode(Lio/flutter/plugins/localauth/Messages$AuthResultCode;)Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;

    move-result-object p1

    invoke-virtual {p2}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p2

    invoke-virtual {p1, p2}, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;->setErrorMessage(Ljava/lang/String;)Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;

    move-result-object p1

    invoke-virtual {p1}, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;->build()Lio/flutter/plugins/localauth/Messages$AuthResult;

    move-result-object p1

    .line 160
    invoke-interface {v0, p1}, Lio/flutter/plugins/localauth/AuthenticationHelper$AuthCompletionHandler;->complete(Lio/flutter/plugins/localauth/Messages$AuthResult;)V

    .line 162
    invoke-direct {p0}, Lio/flutter/plugins/localauth/AuthenticationHelper;->stop()V

    return-void

    :pswitch_data_0
    .packed-switch 0x1
        :pswitch_c
        :pswitch_0
        :pswitch_b
        :pswitch_a
        :pswitch_9
        :pswitch_0
        :pswitch_8
        :pswitch_0
        :pswitch_7
        :pswitch_6
        :pswitch_5
        :pswitch_4
        :pswitch_3
        :pswitch_2
        :pswitch_1
    .end packed-switch
.end method

.method public onAuthenticationFailed()V
    .locals 0

    return-void
.end method

.method public onAuthenticationSucceeded(Landroidx/biometric/BiometricPrompt$AuthenticationResult;)V
    .locals 2

    .line 167
    iget-object p1, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->completionHandler:Lio/flutter/plugins/localauth/AuthenticationHelper$AuthCompletionHandler;

    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;

    invoke-direct {v0}, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;-><init>()V

    sget-object v1, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->SUCCESS:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;->setCode(Lio/flutter/plugins/localauth/Messages$AuthResultCode;)Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;

    move-result-object v0

    invoke-virtual {v0}, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;->build()Lio/flutter/plugins/localauth/Messages$AuthResult;

    move-result-object v0

    invoke-interface {p1, v0}, Lio/flutter/plugins/localauth/AuthenticationHelper$AuthCompletionHandler;->complete(Lio/flutter/plugins/localauth/Messages$AuthResult;)V

    .line 168
    invoke-direct {p0}, Lio/flutter/plugins/localauth/AuthenticationHelper;->stop()V

    return-void
.end method

.method public onCreate(Landroidx/lifecycle/LifecycleOwner;)V
    .locals 0

    return-void
.end method

.method public onDestroy(Landroidx/lifecycle/LifecycleOwner;)V
    .locals 0

    return-void
.end method

.method public onPause(Landroidx/lifecycle/LifecycleOwner;)V
    .locals 0

    const/4 p1, 0x0

    .line 201
    invoke-virtual {p0, p1}, Lio/flutter/plugins/localauth/AuthenticationHelper;->onActivityPaused(Landroid/app/Activity;)V

    return-void
.end method

.method public onResume(Landroidx/lifecycle/LifecycleOwner;)V
    .locals 0

    const/4 p1, 0x0

    .line 206
    invoke-virtual {p0, p1}, Lio/flutter/plugins/localauth/AuthenticationHelper;->onActivityResumed(Landroid/app/Activity;)V

    return-void
.end method

.method public onStart(Landroidx/lifecycle/LifecycleOwner;)V
    .locals 0

    return-void
.end method

.method public onStop(Landroidx/lifecycle/LifecycleOwner;)V
    .locals 0

    return-void
.end method

.method stopAuthentication()V
    .locals 1

    .line 95
    iget-object v0, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->biometricPrompt:Landroidx/biometric/BiometricPrompt;

    if-eqz v0, :cond_0

    .line 96
    invoke-virtual {v0}, Landroidx/biometric/BiometricPrompt;->cancelAuthentication()V

    const/4 v0, 0x0

    .line 97
    iput-object v0, p0, Lio/flutter/plugins/localauth/AuthenticationHelper;->biometricPrompt:Landroidx/biometric/BiometricPrompt;

    :cond_0
    return-void
.end method
