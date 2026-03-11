.class Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$1;
.super Ljava/lang/Object;
.source "GoogleSignInPlugin.java"

# interfaces
.implements Landroidx/credentials/CredentialManagerCallback;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->getCredential(Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;Lkotlin/jvm/functions/Function1;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Object;",
        "Landroidx/credentials/CredentialManagerCallback<",
        "Landroidx/credentials/GetCredentialResponse;",
        "Landroidx/credentials/exceptions/GetCredentialException;",
        ">;"
    }
.end annotation


# instance fields
.field final synthetic this$0:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;

.field final synthetic val$callback:Lkotlin/jvm/functions/Function1;


# direct methods
.method constructor <init>(Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;Lkotlin/jvm/functions/Function1;)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010,
            0x1010
        }
        names = {
            null,
            null
        }
    .end annotation

    .line 272
    iput-object p1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$1;->this$0:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;

    iput-object p2, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$1;->val$callback:Lkotlin/jvm/functions/Function1;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onError(Landroidx/credentials/exceptions/GetCredentialException;)V
    .locals 4

    .line 306
    instance-of v0, p1, Landroidx/credentials/exceptions/GetCredentialCancellationException;

    if-eqz v0, :cond_0

    .line 307
    sget-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->CANCELED:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    goto :goto_0

    .line 308
    :cond_0
    instance-of v0, p1, Landroidx/credentials/exceptions/GetCredentialInterruptedException;

    if-eqz v0, :cond_1

    .line 309
    sget-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->INTERRUPTED:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    goto :goto_0

    .line 310
    :cond_1
    instance-of v0, p1, Landroidx/credentials/exceptions/GetCredentialProviderConfigurationException;

    if-eqz v0, :cond_2

    .line 311
    sget-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->PROVIDER_CONFIGURATION_ISSUE:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    goto :goto_0

    .line 312
    :cond_2
    instance-of v0, p1, Landroidx/credentials/exceptions/GetCredentialUnsupportedException;

    if-eqz v0, :cond_3

    .line 313
    sget-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->UNSUPPORTED:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    goto :goto_0

    .line 314
    :cond_3
    instance-of v0, p1, Landroidx/credentials/exceptions/NoCredentialException;

    if-eqz v0, :cond_4

    .line 315
    sget-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->NO_CREDENTIAL:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    goto :goto_0

    .line 317
    :cond_4
    sget-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->UNKNOWN:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    .line 321
    :goto_0
    iget-object v1, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$1;->val$callback:Lkotlin/jvm/functions/Function1;

    new-instance v2, Lio/flutter/plugins/googlesignin/GetCredentialFailure;

    .line 322
    invoke-virtual {p1}, Landroidx/credentials/exceptions/GetCredentialException;->getMessage()Ljava/lang/String;

    move-result-object p1

    const/4 v3, 0x0

    invoke-direct {v2, v0, p1, v3}, Lio/flutter/plugins/googlesignin/GetCredentialFailure;-><init>(Lio/flutter/plugins/googlesignin/GetCredentialFailureType;Ljava/lang/String;Ljava/lang/String;)V

    .line 321
    invoke-static {v1, v2}, Lio/flutter/plugins/googlesignin/ResultUtilsKt;->completeWithValue(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V

    return-void
.end method

.method public bridge synthetic onError(Ljava/lang/Object;)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x1000
        }
        names = {
            null
        }
    .end annotation

    .line 272
    check-cast p1, Landroidx/credentials/exceptions/GetCredentialException;

    invoke-virtual {p0, p1}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$1;->onError(Landroidx/credentials/exceptions/GetCredentialException;)V

    return-void
.end method

.method public onResult(Landroidx/credentials/GetCredentialResponse;)V
    .locals 11

    .line 275
    invoke-virtual {p1}, Landroidx/credentials/GetCredentialResponse;->getCredential()Landroidx/credentials/Credential;

    move-result-object p1

    .line 276
    instance-of v0, p1, Landroidx/credentials/CustomCredential;

    const/4 v1, 0x0

    if-eqz v0, :cond_1

    .line 278
    invoke-virtual {p1}, Landroidx/credentials/Credential;->getType()Ljava/lang/String;

    move-result-object v0

    const-string v2, "com.google.android.libraries.identity.googleid.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL"

    .line 279
    invoke-virtual {v0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    .line 280
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$1;->this$0:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;

    iget-object v0, v0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate;->credentialConverter:Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$GoogleIdCredentialConverter;

    .line 281
    invoke-interface {v0, p1}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$GoogleIdCredentialConverter;->createFrom(Landroidx/credentials/Credential;)Lcom/google/android/libraries/identity/googleid/GoogleIdTokenCredential;

    move-result-object p1

    .line 282
    invoke-virtual {p1}, Lcom/google/android/libraries/identity/googleid/GoogleIdTokenCredential;->getProfilePictureUri()Landroid/net/Uri;

    move-result-object v0

    .line 283
    iget-object v2, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$1;->val$callback:Lkotlin/jvm/functions/Function1;

    new-instance v3, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;

    new-instance v4, Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;

    .line 287
    invoke-virtual {p1}, Lcom/google/android/libraries/identity/googleid/GoogleIdTokenCredential;->getDisplayName()Ljava/lang/String;

    move-result-object v5

    .line 288
    invoke-virtual {p1}, Lcom/google/android/libraries/identity/googleid/GoogleIdTokenCredential;->getFamilyName()Ljava/lang/String;

    move-result-object v6

    .line 289
    invoke-virtual {p1}, Lcom/google/android/libraries/identity/googleid/GoogleIdTokenCredential;->getGivenName()Ljava/lang/String;

    move-result-object v7

    .line 290
    invoke-virtual {p1}, Lcom/google/android/libraries/identity/googleid/GoogleIdTokenCredential;->getId()Ljava/lang/String;

    move-result-object v8

    .line 291
    invoke-virtual {p1}, Lcom/google/android/libraries/identity/googleid/GoogleIdTokenCredential;->getIdToken()Ljava/lang/String;

    move-result-object v9

    if-nez v0, :cond_0

    goto :goto_0

    .line 292
    :cond_0
    invoke-virtual {v0}, Landroid/net/Uri;->toString()Ljava/lang/String;

    move-result-object v1

    :goto_0
    move-object v10, v1

    invoke-direct/range {v4 .. v10}, Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    invoke-direct {v3, v4}, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;-><init>(Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;)V

    .line 283
    invoke-static {v2, v3}, Lio/flutter/plugins/googlesignin/ResultUtilsKt;->completeWithValue(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V

    return-void

    .line 294
    :cond_1
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$1;->val$callback:Lkotlin/jvm/functions/Function1;

    new-instance v2, Lio/flutter/plugins/googlesignin/GetCredentialFailure;

    sget-object v3, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->UNEXPECTED_CREDENTIAL_TYPE:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    new-instance v4, Ljava/lang/StringBuilder;

    const-string v5, "Unexpected credential type: "

    invoke-direct {v4, v5}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v4, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {v2, v3, p1, v1}, Lio/flutter/plugins/googlesignin/GetCredentialFailure;-><init>(Lio/flutter/plugins/googlesignin/GetCredentialFailureType;Ljava/lang/String;Ljava/lang/String;)V

    invoke-static {v0, v2}, Lio/flutter/plugins/googlesignin/ResultUtilsKt;->completeWithValue(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V

    return-void
.end method

.method public bridge synthetic onResult(Ljava/lang/Object;)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x1000
        }
        names = {
            null
        }
    .end annotation

    .line 272
    check-cast p1, Landroidx/credentials/GetCredentialResponse;

    invoke-virtual {p0, p1}, Lio/flutter/plugins/googlesignin/GoogleSignInPlugin$Delegate$1;->onResult(Landroidx/credentials/GetCredentialResponse;)V

    return-void
.end method
