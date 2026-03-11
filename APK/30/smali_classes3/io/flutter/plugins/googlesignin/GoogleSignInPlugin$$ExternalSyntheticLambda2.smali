.class public final synthetic Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$$ExternalSyntheticLambda2;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$GoogleIdCredentialConverter;


# direct methods
.method public synthetic constructor <init>()V
    .locals 0

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public final createFrom(Landroidx/credentials/Credential;)Lcom/google/android/libraries/identity/googleid/GoogleIdTokenCredential;
    .locals 0

    .line 0
    invoke-static {p1}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin;->lambda$initInstance$2(Landroidx/credentials/Credential;)Lcom/google/android/libraries/identity/googleid/GoogleIdTokenCredential;

    move-result-object p1

    return-object p1
.end method
