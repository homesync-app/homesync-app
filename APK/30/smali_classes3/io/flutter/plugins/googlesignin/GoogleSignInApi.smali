.class public interface abstract Lio/flutter/plugins/googlesignin/GoogleSignInApi;
.super Ljava/lang/Object;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/googlesignin/GoogleSignInApi$Companion;
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000D\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000e\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0008\u0004\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u000b\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0008\u0002\u0008f\u0018\u0000 \u00162\u00020\u0001:\u0001\u0016J\n\u0010\u0002\u001a\u0004\u0018\u00010\u0003H&J*\u0010\u0004\u001a\u00020\u00052\u0006\u0010\u0006\u001a\u00020\u00072\u0018\u0010\u0008\u001a\u0014\u0012\n\u0012\u0008\u0012\u0004\u0012\u00020\u000b0\n\u0012\u0004\u0012\u00020\u00050\tH&J\"\u0010\u000c\u001a\u00020\u00052\u0018\u0010\u0008\u001a\u0014\u0012\n\u0012\u0008\u0012\u0004\u0012\u00020\u00050\n\u0012\u0004\u0012\u00020\u00050\tH&J*\u0010\r\u001a\u00020\u00052\u0006\u0010\u000e\u001a\u00020\u00032\u0018\u0010\u0008\u001a\u0014\u0012\n\u0012\u0008\u0012\u0004\u0012\u00020\u00050\n\u0012\u0004\u0012\u00020\u00050\tH&J2\u0010\u000f\u001a\u00020\u00052\u0006\u0010\u0006\u001a\u00020\u00102\u0006\u0010\u0011\u001a\u00020\u00122\u0018\u0010\u0008\u001a\u0014\u0012\n\u0012\u0008\u0012\u0004\u0012\u00020\u00130\n\u0012\u0004\u0012\u00020\u00050\tH&J*\u0010\u0014\u001a\u00020\u00052\u0006\u0010\u0006\u001a\u00020\u00152\u0018\u0010\u0008\u001a\u0014\u0012\n\u0012\u0008\u0012\u0004\u0012\u00020\u00050\n\u0012\u0004\u0012\u00020\u00050\tH&\u00a8\u0006\u0017\u00c0\u0006\u0003"
    }
    d2 = {
        "Lio/flutter/plugins/googlesignin/GoogleSignInApi;",
        "",
        "getGoogleServicesJsonServerClientId",
        "",
        "getCredential",
        "",
        "params",
        "Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;",
        "callback",
        "Lkotlin/Function1;",
        "Lkotlin/Result;",
        "Lio/flutter/plugins/googlesignin/GetCredentialResult;",
        "clearCredentialState",
        "clearAuthorizationToken",
        "token",
        "authorize",
        "Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest;",
        "promptIfUnauthorized",
        "",
        "Lio/flutter/plugins/googlesignin/AuthorizeResult;",
        "revokeAccess",
        "Lio/flutter/plugins/googlesignin/PlatformRevokeAccessRequest;",
        "Companion",
        "google_sign_in_android_release"
    }
    k = 0x1
    mv = {
        0x2,
        0x2,
        0x0
    }
    xi = 0x30
.end annotation


# static fields
.field public static final Companion:Lio/flutter/plugins/googlesignin/GoogleSignInApi$Companion;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    sget-object v0, Lio/flutter/plugins/googlesignin/GoogleSignInApi$Companion;->$$INSTANCE:Lio/flutter/plugins/googlesignin/GoogleSignInApi$Companion;

    sput-object v0, Lio/flutter/plugins/googlesignin/GoogleSignInApi;->Companion:Lio/flutter/plugins/googlesignin/GoogleSignInApi$Companion;

    return-void
.end method


# virtual methods
.method public abstract authorize(Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest;ZLkotlin/jvm/functions/Function1;)V
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
.end method

.method public abstract clearAuthorizationToken(Ljava/lang/String;Lkotlin/jvm/functions/Function1;)V
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
.end method

.method public abstract clearCredentialState(Lkotlin/jvm/functions/Function1;)V
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
.end method

.method public abstract getCredential(Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;Lkotlin/jvm/functions/Function1;)V
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
.end method

.method public abstract getGoogleServicesJsonServerClientId()Ljava/lang/String;
.end method

.method public abstract revokeAccess(Lio/flutter/plugins/googlesignin/PlatformRevokeAccessRequest;Lkotlin/jvm/functions/Function1;)V
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
.end method
