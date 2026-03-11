.class public Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;
.super Ljava/lang/Object;
.source "GoogleSignInPlugin.java"

# interfaces
.implements Lio/flutter/plugin/common/PluginRegistry$ActivityResultListener;
.implements Lio/flutter/plugins/googlesignin/GoogleSignInApi;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "Delegate"
.end annotation


# static fields
.field static final REQUEST_CODE_AUTHORIZE:I = 0xd02e


# instance fields
.field private activity:Landroid/app/Activity;

.field private final authorizationClientFactory:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$AuthorizationClientFactory;

.field private final context:Landroid/content/Context;

.field final credentialConverter:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$GoogleIdCredentialConverter;

.field private final credentialManagerFactory:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$CredentialManagerFactory;

.field private pendingAuthorizationCallback:Lkotlin/jvm/functions/Function1;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lkotlin/jvm/functions/Function1<",
            "-",
            "Lkotlin/Result<",
            "+",
            "Lio/flutter/plugins/googlesignin/AuthorizeResult;",
            ">;",
            "Lkotlin/Unit;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method public static synthetic $r8$lambda$LdO_goGpKxk4qUwTIhc4ogxOKeI(Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;ZLkotlin/jvm/functions/Function1;Lcom/google/android/gms/auth/api/identity/AuthorizationResult;)V
    .locals 0

    invoke-direct {p0, p1, p2, p3}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->lambda$authorize$2(ZLkotlin/jvm/functions/Function1;Lcom/google/android/gms/auth/api/identity/AuthorizationResult;)V

    return-void
.end method

.method public constructor <init>(Landroid/content/Context;Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$CredentialManagerFactory;Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$AuthorizationClientFactory;Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$GoogleIdCredentialConverter;)V
    .locals 0

    .line 182
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 183
    iput-object p1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->context:Landroid/content/Context;

    .line 184
    iput-object p2, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->credentialManagerFactory:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$CredentialManagerFactory;

    .line 185
    iput-object p3, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->authorizationClientFactory:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$AuthorizationClientFactory;

    .line 186
    iput-object p4, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->credentialConverter:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$GoogleIdCredentialConverter;

    return-void
.end method

.method private synthetic lambda$authorize$2(ZLkotlin/jvm/functions/Function1;Lcom/google/android/gms/auth/api/identity/AuthorizationResult;)V
    .locals 10

    .line 399
    invoke-virtual {p3}, Lcom/google/android/gms/auth/api/identity/AuthorizationResult;->hasResolution()Z

    move-result v0

    if-eqz v0, :cond_2

    const/4 v1, 0x0

    if-eqz p1, :cond_1

    .line 401
    invoke-virtual {p0}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->getActivity()Landroid/app/Activity;

    move-result-object v2

    if-nez v2, :cond_0

    .line 403
    new-instance p1, Lio/flutter/plugins/googlesignin/AuthorizeFailure;

    sget-object p3, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->NO_ACTIVITY:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    const-string v0, "No activity available"

    invoke-direct {p1, p3, v0, v1}, Lio/flutter/plugins/googlesignin/AuthorizeFailure;-><init>(Lio/flutter/plugins/googlesignin/AuthorizeFailureType;Ljava/lang/String;Ljava/lang/String;)V

    invoke-static {p2, p1}, Lio/flutter/plugins/googlesignin/ResultUtilsKt;->completeWithValue(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V

    return-void

    .line 412
    :cond_0
    invoke-virtual {p3}, Lcom/google/android/gms/auth/api/identity/AuthorizationResult;->getPendingIntent()Landroid/app/PendingIntent;

    move-result-object p1

    invoke-static {p1}, Ljava/util/Objects;->requireNonNull(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Landroid/app/PendingIntent;

    .line 414
    :try_start_0
    iput-object p2, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->pendingAuthorizationCallback:Lkotlin/jvm/functions/Function1;

    .line 416
    invoke-virtual {p1}, Landroid/app/PendingIntent;->getIntentSender()Landroid/content/IntentSender;

    move-result-object v3

    const/4 v8, 0x0

    const/4 v9, 0x0

    const v4, 0xd02e

    const/4 v5, 0x0

    const/4 v6, 0x0

    const/4 v7, 0x0

    .line 415
    invoke-virtual/range {v2 .. v9}, Landroid/app/Activity;->startIntentSenderForResult(Landroid/content/IntentSender;ILandroid/content/Intent;IIILandroid/os/Bundle;)V
    :try_end_0
    .catch Landroid/content/IntentSender$SendIntentException; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v0

    move-object p1, v0

    .line 424
    iput-object v1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->pendingAuthorizationCallback:Lkotlin/jvm/functions/Function1;

    .line 425
    new-instance p3, Lio/flutter/plugins/googlesignin/AuthorizeFailure;

    sget-object v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->PENDING_INTENT_EXCEPTION:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    .line 429
    invoke-virtual {p1}, Landroid/content/IntentSender$SendIntentException;->getMessage()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p3, v0, p1, v1}, Lio/flutter/plugins/googlesignin/AuthorizeFailure;-><init>(Lio/flutter/plugins/googlesignin/AuthorizeFailureType;Ljava/lang/String;Ljava/lang/String;)V

    .line 425
    invoke-static {p2, p3}, Lio/flutter/plugins/googlesignin/ResultUtilsKt;->completeWithValue(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V

    :goto_0
    return-void

    .line 433
    :cond_1
    new-instance p1, Lio/flutter/plugins/googlesignin/AuthorizeFailure;

    sget-object p3, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->UNAUTHORIZED:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    invoke-direct {p1, p3, v1, v1}, Lio/flutter/plugins/googlesignin/AuthorizeFailure;-><init>(Lio/flutter/plugins/googlesignin/AuthorizeFailureType;Ljava/lang/String;Ljava/lang/String;)V

    invoke-static {p2, p1}, Lio/flutter/plugins/googlesignin/ResultUtilsKt;->completeWithValue(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V

    return-void

    .line 438
    :cond_2
    new-instance p1, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;

    .line 441
    invoke-virtual {p3}, Lcom/google/android/gms/auth/api/identity/AuthorizationResult;->getAccessToken()Ljava/lang/String;

    move-result-object v0

    .line 442
    invoke-virtual {p3}, Lcom/google/android/gms/auth/api/identity/AuthorizationResult;->getServerAuthCode()Ljava/lang/String;

    move-result-object v1

    .line 443
    invoke-virtual {p3}, Lcom/google/android/gms/auth/api/identity/AuthorizationResult;->getGrantedScopes()Ljava/util/List;

    move-result-object p3

    invoke-direct {p1, v0, v1, p3}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/util/List;)V

    .line 438
    invoke-static {p2, p1}, Lio/flutter/plugins/googlesignin/ResultUtilsKt;->completeWithValue(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V

    return-void
.end method

.method static synthetic lambda$authorize$3(Lkotlin/jvm/functions/Function1;Ljava/lang/Exception;)V
    .locals 3

    .line 448
    new-instance v0, Lio/flutter/plugins/googlesignin/AuthorizeFailure;

    sget-object v1, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->AUTHORIZE_FAILURE:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    .line 451
    invoke-virtual {p1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object p1

    const/4 v2, 0x0

    invoke-direct {v0, v1, p1, v2}, Lio/flutter/plugins/googlesignin/AuthorizeFailure;-><init>(Lio/flutter/plugins/googlesignin/AuthorizeFailureType;Ljava/lang/String;Ljava/lang/String;)V

    .line 448
    invoke-static {p0, v0}, Lio/flutter/plugins/googlesignin/ResultUtilsKt;->completeWithValue(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V

    return-void
.end method

.method static synthetic lambda$clearAuthorizationToken$0(Lkotlin/jvm/functions/Function1;Ljava/lang/Void;)V
    .locals 0

    .line 362
    invoke-static {p0}, Lio/flutter/plugins/googlesignin/ResultUtilsKt;->completeWithUnitSuccess(Lkotlin/jvm/functions/Function1;)V

    return-void
.end method

.method static synthetic lambda$clearAuthorizationToken$1(Lkotlin/jvm/functions/Function1;Ljava/lang/Exception;)V
    .locals 3

    .line 365
    new-instance v0, Lio/flutter/plugins/googlesignin/FlutterError;

    .line 367
    invoke-virtual {p1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object p1

    const/4 v1, 0x0

    const-string v2, "clearAuthorizationToken failed"

    invoke-direct {v0, v2, p1, v1}, Lio/flutter/plugins/googlesignin/FlutterError;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V

    .line 365
    invoke-static {p0, v0}, Lio/flutter/plugins/googlesignin/ResultUtilsKt;->completeWithUnitError(Lkotlin/jvm/functions/Function1;Lio/flutter/plugins/googlesignin/FlutterError;)V

    return-void
.end method

.method static synthetic lambda$revokeAccess$4(Lkotlin/jvm/functions/Function1;Ljava/lang/Void;)V
    .locals 0

    .line 477
    invoke-static {p0}, Lio/flutter/plugins/googlesignin/ResultUtilsKt;->completeWithUnitSuccess(Lkotlin/jvm/functions/Function1;)V

    return-void
.end method

.method static synthetic lambda$revokeAccess$5(Lkotlin/jvm/functions/Function1;Ljava/lang/Exception;)V
    .locals 3

    .line 480
    new-instance v0, Lio/flutter/plugins/googlesignin/FlutterError;

    .line 481
    invoke-virtual {p1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object p1

    const/4 v1, 0x0

    const-string v2, "revokeAccess failed"

    invoke-direct {v0, v2, p1, v1}, Lio/flutter/plugins/googlesignin/FlutterError;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V

    .line 480
    invoke-static {p0, v0}, Lio/flutter/plugins/googlesignin/ResultUtilsKt;->completeWithUnitError(Lkotlin/jvm/functions/Function1;Lio/flutter/plugins/googlesignin/FlutterError;)V

    return-void
.end method


# virtual methods
.method public authorize(Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest;ZLkotlin/jvm/functions/Function1;)V
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest;",
            "Z",
            "Lkotlin/jvm/functions/Function1<",
            "-",
            "Lkotlin/Result<",
            "+",
            "Lio/flutter/plugins/googlesignin/AuthorizeResult;",
            ">;",
            "Lkotlin/Unit;",
            ">;)V"
        }
    .end annotation

    .line 376
    :try_start_0
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    .line 377
    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest;->getScopes()Ljava/util/List;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/String;

    .line 378
    new-instance v3, Lcom/google/android/gms/common/api/Scope;

    invoke-direct {v3, v2}, Lcom/google/android/gms/common/api/Scope;-><init>(Ljava/lang/String;)V

    invoke-interface {v0, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0

    .line 381
    :cond_0
    invoke-static {}, Lcom/google/android/gms/auth/api/identity/AuthorizationRequest;->builder()Lcom/google/android/gms/auth/api/identity/AuthorizationRequest$Builder;

    move-result-object v1

    invoke-virtual {v1, v0}, Lcom/google/android/gms/auth/api/identity/AuthorizationRequest$Builder;->setRequestedScopes(Ljava/util/List;)Lcom/google/android/gms/auth/api/identity/AuthorizationRequest$Builder;

    move-result-object v0

    .line 382
    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest;->getHostedDomain()Ljava/lang/String;

    move-result-object v1

    if-eqz v1, :cond_1

    .line 383
    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest;->getHostedDomain()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Lcom/google/android/gms/auth/api/identity/AuthorizationRequest$Builder;->filterByHostedDomain(Ljava/lang/String;)Lcom/google/android/gms/auth/api/identity/AuthorizationRequest$Builder;

    .line 385
    :cond_1
    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest;->getServerClientIdForForcedRefreshToken()Ljava/lang/String;

    move-result-object v1

    if-eqz v1, :cond_2

    .line 387
    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest;->getServerClientIdForForcedRefreshToken()Ljava/lang/String;

    move-result-object v1

    const/4 v2, 0x1

    .line 386
    invoke-virtual {v0, v1, v2}, Lcom/google/android/gms/auth/api/identity/AuthorizationRequest$Builder;->requestOfflineAccess(Ljava/lang/String;Z)Lcom/google/android/gms/auth/api/identity/AuthorizationRequest$Builder;

    .line 389
    :cond_2
    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest;->getAccountEmail()Ljava/lang/String;

    move-result-object v1

    if-eqz v1, :cond_3

    .line 390
    new-instance v1, Landroid/accounts/Account;

    .line 391
    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest;->getAccountEmail()Ljava/lang/String;

    move-result-object p1

    const-string v2, "com.google"

    invoke-direct {v1, p1, v2}, Landroid/accounts/Account;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    .line 390
    invoke-virtual {v0, v1}, Lcom/google/android/gms/auth/api/identity/AuthorizationRequest$Builder;->setAccount(Landroid/accounts/Account;)Lcom/google/android/gms/auth/api/identity/AuthorizationRequest$Builder;

    .line 393
    :cond_3
    invoke-virtual {v0}, Lcom/google/android/gms/auth/api/identity/AuthorizationRequest$Builder;->build()Lcom/google/android/gms/auth/api/identity/AuthorizationRequest;

    move-result-object p1

    .line 394
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->authorizationClientFactory:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$AuthorizationClientFactory;

    iget-object v1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->context:Landroid/content/Context;

    .line 395
    invoke-interface {v0, v1}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$AuthorizationClientFactory;->create(Landroid/content/Context;)Lcom/google/android/gms/auth/api/identity/AuthorizationClient;

    move-result-object v0

    .line 396
    invoke-interface {v0, p1}, Lcom/google/android/gms/auth/api/identity/AuthorizationClient;->authorize(Lcom/google/android/gms/auth/api/identity/AuthorizationRequest;)Lcom/google/android/gms/tasks/Task;

    move-result-object p1

    new-instance v0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$$ExternalSyntheticLambda4;

    invoke-direct {v0, p0, p2, p3}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$$ExternalSyntheticLambda4;-><init>(Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;ZLkotlin/jvm/functions/Function1;)V

    .line 397
    invoke-virtual {p1, v0}, Lcom/google/android/gms/tasks/Task;->addOnSuccessListener(Lcom/google/android/gms/tasks/OnSuccessListener;)Lcom/google/android/gms/tasks/Task;

    move-result-object p1

    new-instance p2, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$$ExternalSyntheticLambda5;

    invoke-direct {p2, p3}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$$ExternalSyntheticLambda5;-><init>(Lkotlin/jvm/functions/Function1;)V

    .line 446
    invoke-virtual {p1, p2}, Lcom/google/android/gms/tasks/Task;->addOnFailureListener(Lcom/google/android/gms/tasks/OnFailureListener;)Lcom/google/android/gms/tasks/Task;
    :try_end_0
    .catch Ljava/lang/RuntimeException; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception p1

    .line 453
    new-instance p2, Lio/flutter/plugins/googlesignin/AuthorizeFailure;

    sget-object v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->API_EXCEPTION:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    .line 457
    invoke-virtual {p1}, Ljava/lang/RuntimeException;->getMessage()Ljava/lang/String;

    move-result-object v1

    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "Cause: "

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 458
    invoke-virtual {p1}, Ljava/lang/RuntimeException;->getCause()Ljava/lang/Throwable;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, ", Stacktrace: "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-static {p1}, Lio/flutter/Log;->getStackTraceString(Ljava/lang/Throwable;)Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p2, v0, v1, p1}, Lio/flutter/plugins/googlesignin/AuthorizeFailure;-><init>(Lio/flutter/plugins/googlesignin/AuthorizeFailureType;Ljava/lang/String;Ljava/lang/String;)V

    .line 453
    invoke-static {p3, p2}, Lio/flutter/plugins/googlesignin/ResultUtilsKt;->completeWithValue(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V

    return-void
.end method

.method public clearAuthorizationToken(Ljava/lang/String;Lkotlin/jvm/functions/Function1;)V
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/String;",
            "Lkotlin/jvm/functions/Function1<",
            "-",
            "Lkotlin/Result<",
            "Lkotlin/Unit;",
            ">;",
            "Lkotlin/Unit;",
            ">;)V"
        }
    .end annotation

    .line 359
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->authorizationClientFactory:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$AuthorizationClientFactory;

    iget-object v1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->context:Landroid/content/Context;

    .line 360
    invoke-interface {v0, v1}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$AuthorizationClientFactory;->create(Landroid/content/Context;)Lcom/google/android/gms/auth/api/identity/AuthorizationClient;

    move-result-object v0

    .line 361
    invoke-static {}, Lcom/google/android/gms/auth/api/identity/ClearTokenRequest;->builder()Lcom/google/android/gms/auth/api/identity/ClearTokenRequest$Builder;

    move-result-object v1

    invoke-virtual {v1, p1}, Lcom/google/android/gms/auth/api/identity/ClearTokenRequest$Builder;->setToken(Ljava/lang/String;)Lcom/google/android/gms/auth/api/identity/ClearTokenRequest$Builder;

    move-result-object p1

    invoke-virtual {p1}, Lcom/google/android/gms/auth/api/identity/ClearTokenRequest$Builder;->build()Lcom/google/android/gms/auth/api/identity/ClearTokenRequest;

    move-result-object p1

    invoke-interface {v0, p1}, Lcom/google/android/gms/auth/api/identity/AuthorizationClient;->clearToken(Lcom/google/android/gms/auth/api/identity/ClearTokenRequest;)Lcom/google/android/gms/tasks/Task;

    move-result-object p1

    new-instance v0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$$ExternalSyntheticLambda0;

    invoke-direct {v0, p2}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$$ExternalSyntheticLambda0;-><init>(Lkotlin/jvm/functions/Function1;)V

    .line 362
    invoke-virtual {p1, v0}, Lcom/google/android/gms/tasks/Task;->addOnSuccessListener(Lcom/google/android/gms/tasks/OnSuccessListener;)Lcom/google/android/gms/tasks/Task;

    move-result-object p1

    new-instance v0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$$ExternalSyntheticLambda1;

    invoke-direct {v0, p2}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$$ExternalSyntheticLambda1;-><init>(Lkotlin/jvm/functions/Function1;)V

    .line 363
    invoke-virtual {p1, v0}, Lcom/google/android/gms/tasks/Task;->addOnFailureListener(Lcom/google/android/gms/tasks/OnFailureListener;)Lcom/google/android/gms/tasks/Task;

    return-void
.end method

.method public clearCredentialState(Lkotlin/jvm/functions/Function1;)V
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lkotlin/jvm/functions/Function1<",
            "-",
            "Lkotlin/Result<",
            "Lkotlin/Unit;",
            ">;",
            "Lkotlin/Unit;",
            ">;)V"
        }
    .end annotation

    .line 337
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->credentialManagerFactory:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$CredentialManagerFactory;

    iget-object v1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->context:Landroid/content/Context;

    invoke-interface {v0, v1}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$CredentialManagerFactory;->create(Landroid/content/Context;)Landroidx/credentials/CredentialManager;

    move-result-object v0

    .line 338
    new-instance v1, Landroidx/credentials/ClearCredentialStateRequest;

    invoke-direct {v1}, Landroidx/credentials/ClearCredentialStateRequest;-><init>()V

    .line 341
    invoke-static {}, Ljava/util/concurrent/Executors;->newSingleThreadExecutor()Ljava/util/concurrent/ExecutorService;

    move-result-object v2

    new-instance v3, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$2;

    invoke-direct {v3, p0, p1}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$2;-><init>(Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;Lkotlin/jvm/functions/Function1;)V

    const/4 p1, 0x0

    .line 338
    invoke-interface {v0, v1, p1, v2, v3}, Landroidx/credentials/CredentialManager;->clearCredentialStateAsync(Landroidx/credentials/ClearCredentialStateRequest;Landroid/os/CancellationSignal;Ljava/util/concurrent/Executor;Landroidx/credentials/CredentialManagerCallback;)V

    return-void
.end method

.method public getActivity()Landroid/app/Activity;
    .locals 1

    .line 195
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->activity:Landroid/app/Activity;

    return-object v0
.end method

.method public getCredential(Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;Lkotlin/jvm/functions/Function1;)V
    .locals 9
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;",
            "Lkotlin/jvm/functions/Function1<",
            "-",
            "Lkotlin/Result<",
            "+",
            "Lio/flutter/plugins/googlesignin/GetCredentialResult;",
            ">;",
            "Lkotlin/Unit;",
            ">;)V"
        }
    .end annotation

    .line 216
    :try_start_0
    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->getServerClientId()Ljava/lang/String;

    move-result-object v0

    const/4 v1, 0x0

    if-eqz v0, :cond_6

    .line 217
    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z

    move-result v2

    if-eqz v2, :cond_0

    goto/16 :goto_1

    .line 229
    :cond_0
    invoke-virtual {p0}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->getActivity()Landroid/app/Activity;

    move-result-object v4

    if-nez v4, :cond_1

    .line 231
    new-instance p1, Lio/flutter/plugins/googlesignin/GetCredentialFailure;

    sget-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->NO_ACTIVITY:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    const-string v2, "No activity available"

    invoke-direct {p1, v0, v2, v1}, Lio/flutter/plugins/googlesignin/GetCredentialFailure;-><init>(Lio/flutter/plugins/googlesignin/GetCredentialFailureType;Ljava/lang/String;Ljava/lang/String;)V

    invoke-static {p2, p1}, Lio/flutter/plugins/googlesignin/ResultUtilsKt;->completeWithValue(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V

    return-void

    .line 238
    :cond_1
    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->getNonce()Ljava/lang/String;

    move-result-object v1

    .line 239
    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->getHostedDomain()Ljava/lang/String;

    move-result-object v2

    .line 240
    new-instance v3, Landroidx/credentials/GetCredentialRequest$Builder;

    invoke-direct {v3}, Landroidx/credentials/GetCredentialRequest$Builder;-><init>()V

    .line 241
    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->getUseButtonFlow()Z

    move-result v5

    if-eqz v5, :cond_4

    .line 242
    new-instance p1, Lcom/google/android/libraries/identity/googleid/GetSignInWithGoogleOption$Builder;

    invoke-direct {p1, v0}, Lcom/google/android/libraries/identity/googleid/GetSignInWithGoogleOption$Builder;-><init>(Ljava/lang/String;)V

    if-eqz v2, :cond_2

    .line 245
    invoke-virtual {p1, v2}, Lcom/google/android/libraries/identity/googleid/GetSignInWithGoogleOption$Builder;->setHostedDomainFilter(Ljava/lang/String;)Lcom/google/android/libraries/identity/googleid/GetSignInWithGoogleOption$Builder;

    :cond_2
    if-eqz v1, :cond_3

    .line 248
    invoke-virtual {p1, v1}, Lcom/google/android/libraries/identity/googleid/GetSignInWithGoogleOption$Builder;->setNonce(Ljava/lang/String;)Lcom/google/android/libraries/identity/googleid/GetSignInWithGoogleOption$Builder;

    .line 250
    :cond_3
    invoke-virtual {p1}, Lcom/google/android/libraries/identity/googleid/GetSignInWithGoogleOption$Builder;->build()Lcom/google/android/libraries/identity/googleid/GetSignInWithGoogleOption;

    move-result-object p1

    invoke-virtual {v3, p1}, Landroidx/credentials/GetCredentialRequest$Builder;->addCredentialOption(Landroidx/credentials/CredentialOption;)Landroidx/credentials/GetCredentialRequest$Builder;

    goto :goto_0

    .line 252
    :cond_4
    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->getGoogleIdOptionParams()Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;

    move-result-object p1

    .line 255
    new-instance v2, Lcom/google/android/libraries/identity/googleid/GetGoogleIdOption$Builder;

    invoke-direct {v2}, Lcom/google/android/libraries/identity/googleid/GetGoogleIdOption$Builder;-><init>()V

    .line 257
    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->getFilterToAuthorized()Z

    move-result v5

    invoke-virtual {v2, v5}, Lcom/google/android/libraries/identity/googleid/GetGoogleIdOption$Builder;->setFilterByAuthorizedAccounts(Z)Lcom/google/android/libraries/identity/googleid/GetGoogleIdOption$Builder;

    move-result-object v2

    .line 258
    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->getAutoSelectEnabled()Z

    move-result p1

    invoke-virtual {v2, p1}, Lcom/google/android/libraries/identity/googleid/GetGoogleIdOption$Builder;->setAutoSelectEnabled(Z)Lcom/google/android/libraries/identity/googleid/GetGoogleIdOption$Builder;

    move-result-object p1

    .line 259
    invoke-virtual {p1, v0}, Lcom/google/android/libraries/identity/googleid/GetGoogleIdOption$Builder;->setServerClientId(Ljava/lang/String;)Lcom/google/android/libraries/identity/googleid/GetGoogleIdOption$Builder;

    move-result-object p1

    if-eqz v1, :cond_5

    .line 261
    invoke-virtual {p1, v1}, Lcom/google/android/libraries/identity/googleid/GetGoogleIdOption$Builder;->setNonce(Ljava/lang/String;)Lcom/google/android/libraries/identity/googleid/GetGoogleIdOption$Builder;

    .line 263
    :cond_5
    invoke-virtual {p1}, Lcom/google/android/libraries/identity/googleid/GetGoogleIdOption$Builder;->build()Lcom/google/android/libraries/identity/googleid/GetGoogleIdOption;

    move-result-object p1

    invoke-virtual {v3, p1}, Landroidx/credentials/GetCredentialRequest$Builder;->addCredentialOption(Landroidx/credentials/CredentialOption;)Landroidx/credentials/GetCredentialRequest$Builder;

    .line 266
    :goto_0
    iget-object p1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->credentialManagerFactory:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$CredentialManagerFactory;

    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->context:Landroid/content/Context;

    invoke-interface {p1, v0}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$CredentialManagerFactory;->create(Landroid/content/Context;)Landroidx/credentials/CredentialManager;

    move-result-object p1

    .line 269
    invoke-virtual {v3}, Landroidx/credentials/GetCredentialRequest$Builder;->build()Landroidx/credentials/GetCredentialRequest;

    move-result-object v5

    .line 271
    invoke-static {}, Ljava/util/concurrent/Executors;->newSingleThreadExecutor()Ljava/util/concurrent/ExecutorService;

    move-result-object v7

    new-instance v8, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$1;

    invoke-direct {v8, p0, p2}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$1;-><init>(Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;Lkotlin/jvm/functions/Function1;)V

    const/4 v6, 0x0

    move-object v3, p1

    .line 267
    invoke-interface/range {v3 .. v8}, Landroidx/credentials/CredentialManager;->getCredentialAsync(Landroid/content/Context;Landroidx/credentials/GetCredentialRequest;Landroid/os/CancellationSignal;Ljava/util/concurrent/Executor;Landroidx/credentials/CredentialManagerCallback;)V

    return-void

    .line 218
    :cond_6
    :goto_1
    new-instance p1, Lio/flutter/plugins/googlesignin/GetCredentialFailure;

    sget-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->MISSING_SERVER_CLIENT_ID:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    const-string v2, "CredentialManager requires a serverClientId."

    invoke-direct {p1, v0, v2, v1}, Lio/flutter/plugins/googlesignin/GetCredentialFailure;-><init>(Lio/flutter/plugins/googlesignin/GetCredentialFailureType;Ljava/lang/String;Ljava/lang/String;)V

    invoke-static {p2, p1}, Lio/flutter/plugins/googlesignin/ResultUtilsKt;->completeWithValue(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V
    :try_end_0
    .catch Ljava/lang/RuntimeException; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0

    move-object p1, v0

    .line 326
    new-instance v0, Lio/flutter/plugins/googlesignin/GetCredentialFailure;

    sget-object v1, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->UNKNOWN:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    .line 330
    invoke-virtual {p1}, Ljava/lang/RuntimeException;->getMessage()Ljava/lang/String;

    move-result-object v2

    new-instance v3, Ljava/lang/StringBuilder;

    const-string v4, "Cause: "

    invoke-direct {v3, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    .line 331
    invoke-virtual {p1}, Ljava/lang/RuntimeException;->getCause()Ljava/lang/Throwable;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, ", Stacktrace: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-static {p1}, Lio/flutter/Log;->getStackTraceString(Ljava/lang/Throwable;)Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {v0, v1, v2, p1}, Lio/flutter/plugins/googlesignin/GetCredentialFailure;-><init>(Lio/flutter/plugins/googlesignin/GetCredentialFailureType;Ljava/lang/String;Ljava/lang/String;)V

    .line 326
    invoke-static {p2, v0}, Lio/flutter/plugins/googlesignin/ResultUtilsKt;->completeWithValue(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V

    return-void
.end method

.method public getGoogleServicesJsonServerClientId()Ljava/lang/String;
    .locals 4

    .line 201
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->context:Landroid/content/Context;

    .line 203
    invoke-virtual {v0}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v0

    iget-object v1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->context:Landroid/content/Context;

    .line 204
    invoke-virtual {v1}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v1

    const-string v2, "default_web_client_id"

    const-string v3, "string"

    invoke-virtual {v0, v2, v3, v1}, Landroid/content/res/Resources;->getIdentifier(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I

    move-result v0

    if-eqz v0, :cond_0

    .line 206
    iget-object v1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->context:Landroid/content/Context;

    invoke-virtual {v1, v0}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    return-object v0

    :cond_0
    const/4 v0, 0x0

    return-object v0
.end method

.method public onActivityResult(IILandroid/content/Intent;)Z
    .locals 2

    const p2, 0xd02e

    if-ne p1, p2, :cond_1

    .line 487
    iget-object p1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->pendingAuthorizationCallback:Lkotlin/jvm/functions/Function1;

    if-eqz p1, :cond_0

    .line 489
    :try_start_0
    iget-object p1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->authorizationClientFactory:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$AuthorizationClientFactory;

    iget-object p2, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->context:Landroid/content/Context;

    .line 490
    invoke-interface {p1, p2}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$AuthorizationClientFactory;->create(Landroid/content/Context;)Lcom/google/android/gms/auth/api/identity/AuthorizationClient;

    move-result-object p1

    invoke-interface {p1, p3}, Lcom/google/android/gms/auth/api/identity/AuthorizationClient;->getAuthorizationResultFromIntent(Landroid/content/Intent;)Lcom/google/android/gms/auth/api/identity/AuthorizationResult;

    move-result-object p1

    .line 491
    iget-object p2, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->pendingAuthorizationCallback:Lkotlin/jvm/functions/Function1;

    new-instance p3, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;

    .line 494
    invoke-virtual {p1}, Lcom/google/android/gms/auth/api/identity/AuthorizationResult;->getAccessToken()Ljava/lang/String;

    move-result-object v0

    .line 495
    invoke-virtual {p1}, Lcom/google/android/gms/auth/api/identity/AuthorizationResult;->getServerAuthCode()Ljava/lang/String;

    move-result-object v1

    .line 496
    invoke-virtual {p1}, Lcom/google/android/gms/auth/api/identity/AuthorizationResult;->getGrantedScopes()Ljava/util/List;

    move-result-object p1

    invoke-direct {p3, v0, v1, p1}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/util/List;)V

    .line 491
    invoke-static {p2, p3}, Lio/flutter/plugins/googlesignin/ResultUtilsKt;->completeWithValue(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V
    :try_end_0
    .catch Lcom/google/android/gms/common/api/ApiException; {:try_start_0 .. :try_end_0} :catch_0

    const/4 p1, 0x1

    return p1

    :catch_0
    move-exception p1

    .line 499
    iget-object p2, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->pendingAuthorizationCallback:Lkotlin/jvm/functions/Function1;

    new-instance p3, Lio/flutter/plugins/googlesignin/AuthorizeFailure;

    sget-object v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->API_EXCEPTION:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    .line 501
    invoke-virtual {p1}, Lcom/google/android/gms/common/api/ApiException;->getMessage()Ljava/lang/String;

    move-result-object p1

    const/4 v1, 0x0

    invoke-direct {p3, v0, p1, v1}, Lio/flutter/plugins/googlesignin/AuthorizeFailure;-><init>(Lio/flutter/plugins/googlesignin/AuthorizeFailureType;Ljava/lang/String;Ljava/lang/String;)V

    .line 499
    invoke-static {p2, p3}, Lio/flutter/plugins/googlesignin/ResultUtilsKt;->completeWithValue(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V

    .line 503
    iput-object v1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->pendingAuthorizationCallback:Lkotlin/jvm/functions/Function1;

    goto :goto_0

    .line 505
    :cond_0
    const-string p1, "google_sign_in"

    const-string p2, "Unexpected authorization result callback"

    invoke-static {p1, p2}, Lio/flutter/Log;->e(Ljava/lang/String;Ljava/lang/String;)V

    :cond_1
    :goto_0
    const/4 p1, 0x0

    return p1
.end method

.method public revokeAccess(Lio/flutter/plugins/googlesignin/PlatformRevokeAccessRequest;Lkotlin/jvm/functions/Function1;)V
    .locals 5
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lio/flutter/plugins/googlesignin/PlatformRevokeAccessRequest;",
            "Lkotlin/jvm/functions/Function1<",
            "-",
            "Lkotlin/Result<",
            "Lkotlin/Unit;",
            ">;",
            "Lkotlin/Unit;",
            ">;)V"
        }
    .end annotation

    .line 466
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    .line 467
    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/PlatformRevokeAccessRequest;->getScopes()Ljava/util/List;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/String;

    .line 468
    new-instance v3, Lcom/google/android/gms/common/api/Scope;

    invoke-direct {v3, v2}, Lcom/google/android/gms/common/api/Scope;-><init>(Ljava/lang/String;)V

    invoke-interface {v0, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_0

    .line 470
    :cond_0
    iget-object v1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->authorizationClientFactory:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$AuthorizationClientFactory;

    iget-object v2, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->context:Landroid/content/Context;

    .line 471
    invoke-interface {v1, v2}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$AuthorizationClientFactory;->create(Landroid/content/Context;)Lcom/google/android/gms/auth/api/identity/AuthorizationClient;

    move-result-object v1

    .line 473
    invoke-static {}, Lcom/google/android/gms/auth/api/identity/RevokeAccessRequest;->builder()Lcom/google/android/gms/auth/api/identity/RevokeAccessRequest$Builder;

    move-result-object v2

    new-instance v3, Landroid/accounts/Account;

    .line 474
    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/PlatformRevokeAccessRequest;->getAccountEmail()Ljava/lang/String;

    move-result-object p1

    const-string v4, "com.google"

    invoke-direct {v3, p1, v4}, Landroid/accounts/Account;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    invoke-virtual {v2, v3}, Lcom/google/android/gms/auth/api/identity/RevokeAccessRequest$Builder;->setAccount(Landroid/accounts/Account;)Lcom/google/android/gms/auth/api/identity/RevokeAccessRequest$Builder;

    move-result-object p1

    .line 475
    invoke-virtual {p1, v0}, Lcom/google/android/gms/auth/api/identity/RevokeAccessRequest$Builder;->setScopes(Ljava/util/List;)Lcom/google/android/gms/auth/api/identity/RevokeAccessRequest$Builder;

    move-result-object p1

    .line 476
    invoke-virtual {p1}, Lcom/google/android/gms/auth/api/identity/RevokeAccessRequest$Builder;->build()Lcom/google/android/gms/auth/api/identity/RevokeAccessRequest;

    move-result-object p1

    .line 472
    invoke-interface {v1, p1}, Lcom/google/android/gms/auth/api/identity/AuthorizationClient;->revokeAccess(Lcom/google/android/gms/auth/api/identity/RevokeAccessRequest;)Lcom/google/android/gms/tasks/Task;

    move-result-object p1

    new-instance v0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$$ExternalSyntheticLambda2;

    invoke-direct {v0, p2}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$$ExternalSyntheticLambda2;-><init>(Lkotlin/jvm/functions/Function1;)V

    .line 477
    invoke-virtual {p1, v0}, Lcom/google/android/gms/tasks/Task;->addOnSuccessListener(Lcom/google/android/gms/tasks/OnSuccessListener;)Lcom/google/android/gms/tasks/Task;

    move-result-object p1

    new-instance v0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$$ExternalSyntheticLambda3;

    invoke-direct {v0, p2}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$$ExternalSyntheticLambda3;-><init>(Lkotlin/jvm/functions/Function1;)V

    .line 478
    invoke-virtual {p1, v0}, Lcom/google/android/gms/tasks/Task;->addOnFailureListener(Lcom/google/android/gms/tasks/OnFailureListener;)Lcom/google/android/gms/tasks/Task;

    return-void
.end method

.method public setActivity(Landroid/app/Activity;)V
    .locals 0

    .line 190
    iput-object p1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->activity:Landroid/app/Activity;

    return-void
.end method
