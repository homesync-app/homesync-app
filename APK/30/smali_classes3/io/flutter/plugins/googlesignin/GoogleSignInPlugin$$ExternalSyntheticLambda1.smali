.class public final synthetic Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$$ExternalSyntheticLambda1;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$AuthorizationClientFactory;


# direct methods
.method public synthetic constructor <init>()V
    .locals 0

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public final create(Landroid/content/Context;)Lcom/google/android/gms/auth/api/identity/AuthorizationClient;
    .locals 0

    .line 0
    invoke-static {p1}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->lambda$initInstance$1(Landroid/content/Context;)Lcom/google/android/gms/auth/api/identity/AuthorizationClient;

    move-result-object p1

    return-object p1
.end method
