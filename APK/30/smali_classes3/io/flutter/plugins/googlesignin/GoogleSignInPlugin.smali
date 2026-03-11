.class public Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;
.super Ljava/lang/Object;
.source "GoogleSignInPlugin.java"

# interfaces
.implements Lio/flutter/embedding/engine/plugins/FlutterPlugin;
.implements Lio/flutter/embedding/engine/plugins/activity/ActivityAware;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;,
        Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$CredentialManagerFactory;,
        Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$AuthorizationClientFactory;,
        Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$GoogleIdCredentialConverter;
    }
.end annotation


# static fields
.field private static final GOOGLE_ACCOUNT_TYPE:Ljava/lang/String; = "com.google"


# instance fields
.field private activityPluginBinding:Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;

.field private delegate:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;

.field private messenger:Lio/flutter/plugin/common/BinaryMessenger;


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 58
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private attachToActivity(Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;)V
    .locals 1

    .line 93
    iput-object p1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->activityPluginBinding:Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;

    .line 94
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->delegate:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;

    invoke-interface {p1, v0}, Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;->addActivityResultListener(Lio/flutter/plugin/common/PluginRegistry$ActivityResultListener;)V

    .line 95
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->delegate:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;

    invoke-interface {p1}, Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;->getActivity()Landroid/app/Activity;

    move-result-object p1

    invoke-virtual {v0, p1}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->setActivity(Landroid/app/Activity;)V

    return-void
.end method

.method private dispose()V
    .locals 3

    const/4 v0, 0x0

    .line 85
    iput-object v0, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->delegate:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;

    .line 86
    iget-object v1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->messenger:Lio/flutter/plugin/common/BinaryMessenger;

    if-eqz v1, :cond_0

    .line 87
    sget-object v1, Lio/flutter/plugins/googlesignin/GoogleSignInApi;->Companion:Lio/flutter/plugins/googlesignin/GoogleSignInApi$Companion;

    iget-object v2, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->messenger:Lio/flutter/plugin/common/BinaryMessenger;

    invoke-virtual {v1, v2, v0}, Lio/flutter/plugins/googlesignin/GoogleSignInApi$Companion;->setUp(Lio/flutter/plugin/common/BinaryMessenger;Lio/flutter/plugins/googlesignin/GoogleSignInApi;)V

    .line 88
    iput-object v0, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->messenger:Lio/flutter/plugin/common/BinaryMessenger;

    :cond_0
    return-void
.end method

.method private disposeActivity()V
    .locals 2

    .line 99
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->activityPluginBinding:Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;

    iget-object v1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->delegate:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;

    invoke-interface {v0, v1}, Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;->removeActivityResultListener(Lio/flutter/plugin/common/PluginRegistry$ActivityResultListener;)V

    .line 100
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->delegate:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->setActivity(Landroid/app/Activity;)V

    .line 101
    iput-object v1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->activityPluginBinding:Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;

    return-void
.end method

.method private initInstance(Lio/flutter/plugin/common/BinaryMessenger;Landroid/content/Context;)V
    .locals 4

    .line 67
    new-instance v0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;

    new-instance v1, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$$ExternalSyntheticLambda0;

    invoke-direct {v1}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$$ExternalSyntheticLambda0;-><init>()V

    new-instance v2, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$$ExternalSyntheticLambda1;

    invoke-direct {v2}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$$ExternalSyntheticLambda1;-><init>()V

    new-instance v3, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$$ExternalSyntheticLambda2;

    invoke-direct {v3}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$$ExternalSyntheticLambda2;-><init>()V

    invoke-direct {v0, p2, v1, v2, v3}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;-><init>(Landroid/content/Context;Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$CredentialManagerFactory;Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$AuthorizationClientFactory;Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$GoogleIdCredentialConverter;)V

    invoke-virtual {p0, p1, v0}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->initWithDelegate(Lio/flutter/plugin/common/BinaryMessenger;Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;)V

    return-void
.end method

.method static synthetic lambda$initInstance$0(Landroid/content/Context;)Landroidx/credentials/CredentialManager;
    .locals 0

    .line 71
    invoke-static {p0}, Landroidx/credentials/CredentialManager;->create(Landroid/content/Context;)Landroidx/credentials/CredentialManager;

    move-result-object p0

    return-object p0
.end method

.method static synthetic lambda$initInstance$1(Landroid/content/Context;)Lcom/google/android/gms/auth/api/identity/AuthorizationClient;
    .locals 0

    .line 72
    invoke-static {p0}, Lcom/google/android/gms/auth/api/identity/Identity;->getAuthorizationClient(Landroid/content/Context;)Lcom/google/android/gms/auth/api/identity/AuthorizationClient;

    move-result-object p0

    return-object p0
.end method

.method static synthetic lambda$initInstance$2(Landroidx/credentials/Credential;)Lcom/google/android/libraries/identity/googleid/GoogleIdTokenCredential;
    .locals 0

    .line 74
    invoke-virtual {p0}, Landroidx/credentials/Credential;->getData()Landroid/os/Bundle;

    move-result-object p0

    invoke-static {p0}, Lcom/google/android/libraries/identity/googleid/GoogleIdTokenCredential;->createFrom(Landroid/os/Bundle;)Lcom/google/android/libraries/identity/googleid/GoogleIdTokenCredential;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method initWithDelegate(Lio/flutter/plugin/common/BinaryMessenger;Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;)V
    .locals 1

    .line 79
    iput-object p1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->messenger:Lio/flutter/plugin/common/BinaryMessenger;

    .line 80
    iput-object p2, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->delegate:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;

    .line 81
    sget-object v0, Lio/flutter/plugins/googlesignin/GoogleSignInApi;->Companion:Lio/flutter/plugins/googlesignin/GoogleSignInApi$Companion;

    invoke-virtual {v0, p1, p2}, Lio/flutter/plugins/googlesignin/GoogleSignInApi$Companion;->setUp(Lio/flutter/plugin/common/BinaryMessenger;Lio/flutter/plugins/googlesignin/GoogleSignInApi;)V

    return-void
.end method

.method public onAttachedToActivity(Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;)V
    .locals 0

    .line 116
    invoke-direct {p0, p1}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->attachToActivity(Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;)V

    return-void
.end method

.method public onAttachedToEngine(Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;)V
    .locals 1

    .line 106
    invoke-virtual {p1}, Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;->getBinaryMessenger()Lio/flutter/plugin/common/BinaryMessenger;

    move-result-object v0

    invoke-virtual {p1}, Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;->getApplicationContext()Landroid/content/Context;

    move-result-object p1

    invoke-direct {p0, v0, p1}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->initInstance(Lio/flutter/plugin/common/BinaryMessenger;Landroid/content/Context;)V

    return-void
.end method

.method public onDetachedFromActivity()V
    .locals 0

    .line 132
    invoke-direct {p0}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->disposeActivity()V

    return-void
.end method

.method public onDetachedFromActivityForConfigChanges()V
    .locals 0

    .line 121
    invoke-direct {p0}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->disposeActivity()V

    return-void
.end method

.method public onDetachedFromEngine(Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;)V
    .locals 0

    .line 111
    invoke-direct {p0}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->dispose()V

    return-void
.end method

.method public onReattachedToActivityForConfigChanges(Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;)V
    .locals 0

    .line 127
    invoke-direct {p0, p1}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->attachToActivity(Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;)V

    return-void
.end method
