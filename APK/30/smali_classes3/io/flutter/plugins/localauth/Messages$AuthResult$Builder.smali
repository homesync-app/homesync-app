.class public final Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;
.super Ljava/lang/Object;
.source "Messages.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/localauth/Messages$AuthResult;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "Builder"
.end annotation


# instance fields
.field private code:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

.field private errorMessage:Ljava/lang/String;


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 330
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public build()Lio/flutter/plugins/localauth/Messages$AuthResult;
    .locals 2

    .line 349
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResult;

    invoke-direct {v0}, Lio/flutter/plugins/localauth/Messages$AuthResult;-><init>()V

    .line 350
    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;->code:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/localauth/Messages$AuthResult;->setCode(Lio/flutter/plugins/localauth/Messages$AuthResultCode;)V

    .line 351
    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;->errorMessage:Ljava/lang/String;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/localauth/Messages$AuthResult;->setErrorMessage(Ljava/lang/String;)V

    return-object v0
.end method

.method public setCode(Lio/flutter/plugins/localauth/Messages$AuthResultCode;)Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;
    .locals 0

    .line 336
    iput-object p1, p0, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;->code:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    return-object p0
.end method

.method public setErrorMessage(Ljava/lang/String;)Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;
    .locals 0

    .line 344
    iput-object p1, p0, Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;->errorMessage:Ljava/lang/String;

    return-object p0
.end method
