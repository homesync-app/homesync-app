.class public Lio/flutter/plugins/localauth/LocalAuthPlugin;
.super Ljava/lang/Object;
.source "LocalAuthPlugin.java"

# interfaces
.implements Lio/flutter/embedding/engine/plugins/FlutterPlugin;
.implements Lio/flutter/embedding/engine/plugins/activity/ActivityAware;
.implements Lio/flutter/plugins/localauth/Messages$LocalAuthApi;


# instance fields
.field private activity:Landroid/app/Activity;

.field private authHelper:Lio/flutter/plugins/localauth/AuthenticationHelper;

.field final authInProgress:Ljava/util/concurrent/atomic/AtomicBoolean;

.field private biometricManager:Landroidx/biometric/BiometricManager;

.field private keyguardManager:Landroid/app/KeyguardManager;

.field private lifecycle:Landroidx/lifecycle/Lifecycle;


# direct methods
.method public static synthetic $r8$lambda$qjxL63RqRs9EYeJKfHdQmdynDl4(Lio/flutter/plugins/localauth/LocalAuthPlugin;Lio/flutter/plugins/localauth/Messages$Result;Lio/flutter/plugins/localauth/Messages$AuthResult;)V
    .locals 0

    invoke-direct {p0, p1, p2}, Lio/flutter/plugins/localauth/LocalAuthPlugin;->lambda$createAuthCompletionHandler$0(Lio/flutter/plugins/localauth/Messages$Result;Lio/flutter/plugins/localauth/Messages$AuthResult;)V

    return-void
.end method

.method public constructor <init>()V
    .locals 2

    .line 54
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 43
    new-instance v0, Ljava/util/concurrent/atomic/AtomicBoolean;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Ljava/util/concurrent/atomic/AtomicBoolean;-><init>(Z)V

    iput-object v0, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->authInProgress:Ljava/util/concurrent/atomic/AtomicBoolean;

    return-void
.end method

.method private canAuthenticateWithBiometrics()Z
    .locals 3

    .line 168
    iget-object v0, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->biometricManager:Landroidx/biometric/BiometricManager;

    const/4 v1, 0x0

    if-nez v0, :cond_0

    return v1

    :cond_0
    const/16 v2, 0xff

    .line 169
    invoke-virtual {v0, v2}, Landroidx/biometric/BiometricManager;->canAuthenticate(I)I

    move-result v0

    if-nez v0, :cond_1

    const/4 v0, 0x1

    return v0

    :cond_1
    return v1
.end method

.method private hasBiometricHardware()Z
    .locals 3

    .line 174
    iget-object v0, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->biometricManager:Landroidx/biometric/BiometricManager;

    const/4 v1, 0x0

    if-nez v0, :cond_0

    return v1

    :cond_0
    const/16 v2, 0xff

    .line 175
    invoke-virtual {v0, v2}, Landroidx/biometric/BiometricManager;->canAuthenticate(I)I

    move-result v0

    const/16 v2, 0xc

    if-eq v0, v2, :cond_1

    const/4 v0, 0x1

    return v0

    :cond_1
    return v1
.end method

.method private synthetic lambda$createAuthCompletionHandler$0(Lio/flutter/plugins/localauth/Messages$Result;Lio/flutter/plugins/localauth/Messages$AuthResult;)V
    .locals 0

    .line 134
    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/localauth/LocalAuthPlugin;->onAuthenticationCompleted(Lio/flutter/plugins/localauth/Messages$Result;Lio/flutter/plugins/localauth/Messages$AuthResult;)V

    return-void
.end method

.method private setServicesFromActivity(Landroid/app/Activity;)V
    .locals 1

    if-nez p1, :cond_0

    return-void

    .line 205
    :cond_0
    iput-object p1, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->activity:Landroid/app/Activity;

    .line 206
    invoke-virtual {p1}, Landroid/app/Activity;->getBaseContext()Landroid/content/Context;

    move-result-object v0

    .line 207
    invoke-static {p1}, Landroidx/biometric/BiometricManager;->from(Landroid/content/Context;)Landroidx/biometric/BiometricManager;

    move-result-object p1

    iput-object p1, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->biometricManager:Landroidx/biometric/BiometricManager;

    .line 208
    const-string p1, "keyguard"

    invoke-virtual {v0, p1}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Landroid/app/KeyguardManager;

    iput-object p1, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->keyguardManager:Landroid/app/KeyguardManager;

    return-void
.end method


# virtual methods
.method public authenticate(Lio/flutter/plugins/localauth/Messages$AuthOptions;Lio/flutter/plugins/localauth/Messages$AuthStrings;Lio/flutter/plugins/localauth/Messages$Result;)V
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lio/flutter/plugins/localauth/Messages$AuthOptions;",
            "Lio/flutter/plugins/localauth/Messages$AuthStrings;",
            "Lio/flutter/plugins/localauth/Messages$Result<",
            "Lio/flutter/plugins/localauth/Messages$AuthResult;",
            ">;)V"
        }
    .end annotation

    .line 102
    iget-object v0, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->authInProgress:Ljava/util/concurrent/atomic/AtomicBoolean;

    invoke-virtual {v0}, Ljava/util/concurrent/atomic/AtomicBoolean;->get()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 103
    new-instance p1, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;

    invoke-direct {p1}, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;-><init>()V

    sget-object p2, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->ALREADY_IN_PROGRESS:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    invoke-virtual {p1, p2}, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;->setCode(Lio/flutter/plugins/localauth/Messages$AuthResultCode;)Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;

    move-result-object p1

    invoke-virtual {p1}, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;->build()Lio/flutter/plugins/localauth/Messages$AuthResult;

    move-result-object p1

    invoke-interface {p3, p1}, Lio/flutter/plugins/localauth/Messages$Result;->success(Ljava/lang/Object;)V

    return-void

    .line 107
    :cond_0
    iget-object v0, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->activity:Landroid/app/Activity;

    if-eqz v0, :cond_5

    invoke-virtual {v0}, Landroid/app/Activity;->isFinishing()Z

    move-result v0

    if-eqz v0, :cond_1

    goto :goto_1

    .line 112
    :cond_1
    iget-object v0, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->activity:Landroid/app/Activity;

    instance-of v0, v0, Landroidx/fragment/app/FragmentActivity;

    if-nez v0, :cond_2

    .line 113
    new-instance p1, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;

    invoke-direct {p1}, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;-><init>()V

    sget-object p2, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NOT_FRAGMENT_ACTIVITY:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    .line 114
    invoke-virtual {p1, p2}, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;->setCode(Lio/flutter/plugins/localauth/Messages$AuthResultCode;)Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;

    move-result-object p1

    invoke-virtual {p1}, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;->build()Lio/flutter/plugins/localauth/Messages$AuthResult;

    move-result-object p1

    .line 113
    invoke-interface {p3, p1}, Lio/flutter/plugins/localauth/Messages$Result;->success(Ljava/lang/Object;)V

    return-void

    .line 118
    :cond_2
    invoke-virtual {p0}, Lio/flutter/plugins/localauth/LocalAuthPlugin;->isDeviceSupported()Ljava/lang/Boolean;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v0

    if-nez v0, :cond_3

    .line 119
    new-instance p1, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;

    invoke-direct {p1}, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;-><init>()V

    sget-object p2, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NO_CREDENTIALS:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    invoke-virtual {p1, p2}, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;->setCode(Lio/flutter/plugins/localauth/Messages$AuthResultCode;)Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;

    move-result-object p1

    invoke-virtual {p1}, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;->build()Lio/flutter/plugins/localauth/Messages$AuthResult;

    move-result-object p1

    invoke-interface {p3, p1}, Lio/flutter/plugins/localauth/Messages$Result;->success(Ljava/lang/Object;)V

    return-void

    .line 123
    :cond_3
    iget-object v0, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->authInProgress:Ljava/util/concurrent/atomic/AtomicBoolean;

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Ljava/util/concurrent/atomic/AtomicBoolean;->set(Z)V

    .line 124
    invoke-virtual {p0, p3}, Lio/flutter/plugins/localauth/LocalAuthPlugin;->createAuthCompletionHandler(Lio/flutter/plugins/localauth/Messages$Result;)Lio/flutter/plugins/localauth/AuthenticationHelper$AuthCompletionHandler;

    move-result-object p3

    .line 126
    invoke-virtual {p1}, Lio/flutter/plugins/localauth/Messages$AuthOptions;->getBiometricOnly()Ljava/lang/Boolean;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v0

    if-nez v0, :cond_4

    invoke-virtual {p0}, Lio/flutter/plugins/localauth/LocalAuthPlugin;->canAuthenticateWithDeviceCredential()Z

    move-result v0

    if-eqz v0, :cond_4

    goto :goto_0

    :cond_4
    const/4 v1, 0x0

    .line 128
    :goto_0
    invoke-virtual {p0, p1, p2, v1, p3}, Lio/flutter/plugins/localauth/LocalAuthPlugin;->sendAuthenticationRequest(Lio/flutter/plugins/localauth/Messages$AuthOptions;Lio/flutter/plugins/localauth/Messages$AuthStrings;ZLio/flutter/plugins/localauth/AuthenticationHelper$AuthCompletionHandler;)V

    return-void

    .line 108
    :cond_5
    :goto_1
    new-instance p1, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;

    invoke-direct {p1}, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;-><init>()V

    sget-object p2, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NO_ACTIVITY:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    invoke-virtual {p1, p2}, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;->setCode(Lio/flutter/plugins/localauth/Messages$AuthResultCode;)Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;

    move-result-object p1

    invoke-virtual {p1}, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;->build()Lio/flutter/plugins/localauth/Messages$AuthResult;

    move-result-object p1

    invoke-interface {p3, p1}, Lio/flutter/plugins/localauth/Messages$Result;->success(Ljava/lang/Object;)V

    return-void
.end method

.method public canAuthenticateWithDeviceCredential()Z
    .locals 3

    .line 181
    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1e

    if-ge v0, v1, :cond_0

    .line 185
    invoke-virtual {p0}, Lio/flutter/plugins/localauth/LocalAuthPlugin;->isDeviceSecure()Z

    move-result v0

    return v0

    .line 188
    :cond_0
    iget-object v0, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->biometricManager:Landroidx/biometric/BiometricManager;

    const/4 v1, 0x0

    if-nez v0, :cond_1

    return v1

    :cond_1
    const v2, 0x8000

    .line 189
    invoke-virtual {v0, v2}, Landroidx/biometric/BiometricManager;->canAuthenticate(I)I

    move-result v0

    if-nez v0, :cond_2

    const/4 v0, 0x1

    return v0

    :cond_2
    return v1
.end method

.method public createAuthCompletionHandler(Lio/flutter/plugins/localauth/Messages$Result;)Lio/flutter/plugins/localauth/AuthenticationHelper$AuthCompletionHandler;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lio/flutter/plugins/localauth/Messages$Result<",
            "Lio/flutter/plugins/localauth/Messages$AuthResult;",
            ">;)",
            "Lio/flutter/plugins/localauth/AuthenticationHelper$AuthCompletionHandler;"
        }
    .end annotation

    .line 134
    new-instance v0, Lio/flutter/plugins/localauth/LocalAuthPlugin$$ExternalSyntheticLambda0;

    invoke-direct {v0, p0, p1}, Lio/flutter/plugins/localauth/LocalAuthPlugin$$ExternalSyntheticLambda0;-><init>(Lio/flutter/plugins/localauth/LocalAuthPlugin;Lio/flutter/plugins/localauth/Messages$Result;)V

    return-object v0
.end method

.method public deviceCanSupportBiometrics()Ljava/lang/Boolean;
    .locals 1

    .line 63
    invoke-direct {p0}, Lio/flutter/plugins/localauth/LocalAuthPlugin;->hasBiometricHardware()Z

    move-result v0

    invoke-static {v0}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v0

    return-object v0
.end method

.method final getActivity()Landroid/app/Activity;
    .locals 1

    .line 237
    iget-object v0, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->activity:Landroid/app/Activity;

    return-object v0
.end method

.method public getEnrolledBiometrics()Ljava/util/List;
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Lio/flutter/plugins/localauth/Messages$AuthClassification;",
            ">;"
        }
    .end annotation

    .line 68
    iget-object v0, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->biometricManager:Landroidx/biometric/BiometricManager;

    if-nez v0, :cond_0

    const/4 v0, 0x0

    return-object v0

    .line 71
    :cond_0
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    .line 72
    iget-object v1, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->biometricManager:Landroidx/biometric/BiometricManager;

    const/16 v2, 0xff

    invoke-virtual {v1, v2}, Landroidx/biometric/BiometricManager;->canAuthenticate(I)I

    move-result v1

    if-nez v1, :cond_1

    .line 74
    sget-object v1, Lio/flutter/plugins/localauth/Messages$AuthClassification;->WEAK:Lio/flutter/plugins/localauth/Messages$AuthClassification;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 76
    :cond_1
    iget-object v1, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->biometricManager:Landroidx/biometric/BiometricManager;

    const/16 v2, 0xf

    invoke-virtual {v1, v2}, Landroidx/biometric/BiometricManager;->canAuthenticate(I)I

    move-result v1

    if-nez v1, :cond_2

    .line 78
    sget-object v1, Lio/flutter/plugins/localauth/Messages$AuthClassification;->STRONG:Lio/flutter/plugins/localauth/Messages$AuthClassification;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    :cond_2
    return-object v0
.end method

.method public isDeviceSecure()Z
    .locals 1

    .line 163
    iget-object v0, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->keyguardManager:Landroid/app/KeyguardManager;

    if-nez v0, :cond_0

    const/4 v0, 0x0

    return v0

    .line 164
    :cond_0
    invoke-virtual {v0}, Landroid/app/KeyguardManager;->isDeviceSecure()Z

    move-result v0

    return v0
.end method

.method public isDeviceSupported()Ljava/lang/Boolean;
    .locals 1

    .line 58
    invoke-virtual {p0}, Lio/flutter/plugins/localauth/LocalAuthPlugin;->isDeviceSecure()Z

    move-result v0

    if-nez v0, :cond_1

    invoke-direct {p0}, Lio/flutter/plugins/localauth/LocalAuthPlugin;->canAuthenticateWithBiometrics()Z

    move-result v0

    if-eqz v0, :cond_0

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    goto :goto_1

    :cond_1
    :goto_0
    const/4 v0, 0x1

    :goto_1
    invoke-static {v0}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v0

    return-object v0
.end method

.method public onAttachedToActivity(Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;)V
    .locals 1

    .line 213
    invoke-interface {p1}, Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;->getActivity()Landroid/app/Activity;

    move-result-object v0

    invoke-direct {p0, v0}, Lio/flutter/plugins/localauth/LocalAuthPlugin;->setServicesFromActivity(Landroid/app/Activity;)V

    .line 214
    invoke-static {p1}, Lio/flutter/embedding/engine/plugins/lifecycle/FlutterLifecycleAdapter;->getActivityLifecycle(Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;)Landroidx/lifecycle/Lifecycle;

    move-result-object p1

    iput-object p1, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->lifecycle:Landroidx/lifecycle/Lifecycle;

    return-void
.end method

.method public onAttachedToEngine(Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;)V
    .locals 0

    .line 195
    invoke-virtual {p1}, Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;->getBinaryMessenger()Lio/flutter/plugin/common/BinaryMessenger;

    move-result-object p1

    invoke-static {p1, p0}, Lio/flutter/plugins/localauth/Messages$LocalAuthApi;->setUp(Lio/flutter/plugin/common/BinaryMessenger;Lio/flutter/plugins/localauth/Messages$LocalAuthApi;)V

    return-void
.end method

.method onAuthenticationCompleted(Lio/flutter/plugins/localauth/Messages$Result;Lio/flutter/plugins/localauth/Messages$AuthResult;)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lio/flutter/plugins/localauth/Messages$Result<",
            "Lio/flutter/plugins/localauth/Messages$AuthResult;",
            ">;",
            "Lio/flutter/plugins/localauth/Messages$AuthResult;",
            ")V"
        }
    .end annotation

    .line 156
    iget-object v0, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->authInProgress:Ljava/util/concurrent/atomic/AtomicBoolean;

    const/4 v1, 0x1

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Ljava/util/concurrent/atomic/AtomicBoolean;->compareAndSet(ZZ)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 157
    invoke-interface {p1, p2}, Lio/flutter/plugins/localauth/Messages$Result;->success(Ljava/lang/Object;)V

    :cond_0
    return-void
.end method

.method public onDetachedFromActivity()V
    .locals 1

    const/4 v0, 0x0

    .line 231
    iput-object v0, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->lifecycle:Landroidx/lifecycle/Lifecycle;

    .line 232
    iput-object v0, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->activity:Landroid/app/Activity;

    return-void
.end method

.method public onDetachedFromActivityForConfigChanges()V
    .locals 1

    const/4 v0, 0x0

    .line 219
    iput-object v0, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->lifecycle:Landroidx/lifecycle/Lifecycle;

    .line 220
    iput-object v0, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->activity:Landroid/app/Activity;

    return-void
.end method

.method public onDetachedFromEngine(Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;)V
    .locals 1

    .line 200
    invoke-virtual {p1}, Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;->getBinaryMessenger()Lio/flutter/plugin/common/BinaryMessenger;

    move-result-object p1

    const/4 v0, 0x0

    invoke-static {p1, v0}, Lio/flutter/plugins/localauth/Messages$LocalAuthApi;->setUp(Lio/flutter/plugin/common/BinaryMessenger;Lio/flutter/plugins/localauth/Messages$LocalAuthApi;)V

    return-void
.end method

.method public onReattachedToActivityForConfigChanges(Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;)V
    .locals 1

    .line 225
    invoke-interface {p1}, Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;->getActivity()Landroid/app/Activity;

    move-result-object v0

    invoke-direct {p0, v0}, Lio/flutter/plugins/localauth/LocalAuthPlugin;->setServicesFromActivity(Landroid/app/Activity;)V

    .line 226
    invoke-static {p1}, Lio/flutter/embedding/engine/plugins/lifecycle/FlutterLifecycleAdapter;->getActivityLifecycle(Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;)Landroidx/lifecycle/Lifecycle;

    move-result-object p1

    iput-object p1, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->lifecycle:Landroidx/lifecycle/Lifecycle;

    return-void
.end method

.method public sendAuthenticationRequest(Lio/flutter/plugins/localauth/Messages$AuthOptions;Lio/flutter/plugins/localauth/Messages$AuthStrings;ZLio/flutter/plugins/localauth/AuthenticationHelper$AuthCompletionHandler;)V
    .locals 7

    .line 143
    new-instance v0, Lio/flutter/plugins/localauth/AuthenticationHelper;

    iget-object v1, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->lifecycle:Landroidx/lifecycle/Lifecycle;

    iget-object v2, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->activity:Landroid/app/Activity;

    check-cast v2, Landroidx/fragment/app/FragmentActivity;

    move-object v3, p1

    move-object v4, p2

    move v6, p3

    move-object v5, p4

    invoke-direct/range {v0 .. v6}, Lio/flutter/plugins/localauth/AuthenticationHelper;-><init>(Landroidx/lifecycle/Lifecycle;Landroidx/fragment/app/FragmentActivity;Lio/flutter/plugins/localauth/Messages$AuthOptions;Lio/flutter/plugins/localauth/Messages$AuthStrings;Lio/flutter/plugins/localauth/AuthenticationHelper$AuthCompletionHandler;Z)V

    iput-object v0, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->authHelper:Lio/flutter/plugins/localauth/AuthenticationHelper;

    .line 152
    invoke-virtual {v0}, Lio/flutter/plugins/localauth/AuthenticationHelper;->authenticate()V

    return-void
.end method

.method setBiometricManager(Landroidx/biometric/BiometricManager;)V
    .locals 0

    .line 242
    iput-object p1, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->biometricManager:Landroidx/biometric/BiometricManager;

    return-void
.end method

.method setKeyguardManager(Landroid/app/KeyguardManager;)V
    .locals 0

    .line 247
    iput-object p1, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->keyguardManager:Landroid/app/KeyguardManager;

    return-void
.end method

.method public stopAuthentication()Ljava/lang/Boolean;
    .locals 2

    const/4 v0, 0x0

    .line 86
    :try_start_0
    iget-object v1, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->authHelper:Lio/flutter/plugins/localauth/AuthenticationHelper;

    if-eqz v1, :cond_0

    iget-object v1, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->authInProgress:Ljava/util/concurrent/atomic/AtomicBoolean;

    invoke-virtual {v1}, Ljava/util/concurrent/atomic/AtomicBoolean;->get()Z

    move-result v1

    if-eqz v1, :cond_0

    .line 87
    iget-object v1, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->authHelper:Lio/flutter/plugins/localauth/AuthenticationHelper;

    invoke-virtual {v1}, Lio/flutter/plugins/localauth/AuthenticationHelper;->stopAuthentication()V

    const/4 v1, 0x0

    .line 88
    iput-object v1, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->authHelper:Lio/flutter/plugins/localauth/AuthenticationHelper;

    .line 90
    :cond_0
    iget-object v1, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin;->authInProgress:Ljava/util/concurrent/atomic/AtomicBoolean;

    invoke-virtual {v1, v0}, Ljava/util/concurrent/atomic/AtomicBoolean;->set(Z)V

    const/4 v1, 0x1

    .line 91
    invoke-static {v1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v0
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    return-object v0

    .line 93
    :catch_0
    invoke-static {v0}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v0

    return-object v0
.end method
