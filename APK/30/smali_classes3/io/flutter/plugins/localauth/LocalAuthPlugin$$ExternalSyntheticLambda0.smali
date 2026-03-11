.class public final synthetic Lio/flutter/plugins/localauth/LocalAuthPlugin$$ExternalSyntheticLambda0;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Lio/flutter/plugins/localauth/AuthenticationHelper$AuthCompletionHandler;


# instance fields
.field public final synthetic f$0:Lio/flutter/plugins/localauth/LocalAuthPlugin;

.field public final synthetic f$1:Lio/flutter/plugins/localauth/Messages$Result;


# direct methods
.method public synthetic constructor <init>(Lio/flutter/plugins/localauth/LocalAuthPlugin;Lio/flutter/plugins/localauth/Messages$Result;)V
    .locals 0

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin$$ExternalSyntheticLambda0;->f$0:Lio/flutter/plugins/localauth/LocalAuthPlugin;

    iput-object p2, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin$$ExternalSyntheticLambda0;->f$1:Lio/flutter/plugins/localauth/Messages$Result;

    return-void
.end method


# virtual methods
.method public final complete(Lio/flutter/plugins/localauth/Messages$AuthResult;)V
    .locals 2

    .line 0
    iget-object v0, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin$$ExternalSyntheticLambda0;->f$0:Lio/flutter/plugins/localauth/LocalAuthPlugin;

    iget-object v1, p0, Lio/flutter/plugins/localauth/LocalAuthPlugin$$ExternalSyntheticLambda0;->f$1:Lio/flutter/plugins/localauth/Messages$Result;

    invoke-static {v0, v1, p1}, Lio/flutter/plugins/localauth/LocalAuthPlugin;->$r8$lambda$qjxL63RqRs9EYeJKfHdQmdynDl4(Lio/flutter/plugins/localauth/LocalAuthPlugin;Lio/flutter/plugins/localauth/Messages$Result;Lio/flutter/plugins/localauth/Messages$AuthResult;)V

    return-void
.end method
