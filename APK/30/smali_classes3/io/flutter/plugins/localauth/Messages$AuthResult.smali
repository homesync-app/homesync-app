.class public final Lio/flutter/plugins/localauth/Messages$AuthResult;
.super Ljava/lang/Object;
.source "Messages.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/localauth/Messages;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "AuthResult"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/localauth/Messages$AuthResult$Builder;
    }
.end annotation


# instance fields
.field private code:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

.field private errorMessage:Ljava/lang/String;


# direct methods
.method constructor <init>()V
    .locals 0

    .line 311
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static fromList(Ljava/util/ArrayList;)Lio/flutter/plugins/localauth/Messages$AuthResult;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/ArrayList<",
            "Ljava/lang/Object;",
            ">;)",
            "Lio/flutter/plugins/localauth/Messages$AuthResult;"
        }
    .end annotation

    .line 365
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResult;

    invoke-direct {v0}, Lio/flutter/plugins/localauth/Messages$AuthResult;-><init>()V

    const/4 v1, 0x0

    .line 366
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v1

    .line 367
    check-cast v1, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/localauth/Messages$AuthResult;->setCode(Lio/flutter/plugins/localauth/Messages$AuthResultCode;)V

    const/4 v1, 0x1

    .line 368
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object p0

    .line 369
    check-cast p0, Ljava/lang/String;

    invoke-virtual {v0, p0}, Lio/flutter/plugins/localauth/Messages$AuthResult;->setErrorMessage(Ljava/lang/String;)V

    return-object v0
.end method


# virtual methods
.method public equals(Ljava/lang/Object;)Z
    .locals 4

    const/4 v0, 0x1

    if-ne p0, p1, :cond_0

    return v0

    :cond_0
    const/4 v1, 0x0

    if-eqz p1, :cond_2

    .line 318
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v2

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v3

    if-eq v2, v3, :cond_1

    goto :goto_0

    .line 321
    :cond_1
    check-cast p1, Lio/flutter/plugins/localauth/Messages$AuthResult;

    .line 322
    iget-object v2, p0, Lio/flutter/plugins/localauth/Messages$AuthResult;->code:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    iget-object v3, p1, Lio/flutter/plugins/localauth/Messages$AuthResult;->code:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    invoke-virtual {v2, v3}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_2

    iget-object v2, p0, Lio/flutter/plugins/localauth/Messages$AuthResult;->errorMessage:Ljava/lang/String;

    iget-object p1, p1, Lio/flutter/plugins/localauth/Messages$AuthResult;->errorMessage:Ljava/lang/String;

    invoke-static {v2, p1}, Ljava/util/Objects;->equals(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_2

    return v0

    :cond_2
    :goto_0
    return v1
.end method

.method public getCode()Lio/flutter/plugins/localauth/Messages$AuthResultCode;
    .locals 1

    .line 289
    iget-object v0, p0, Lio/flutter/plugins/localauth/Messages$AuthResult;->code:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    return-object v0
.end method

.method public getErrorMessage()Ljava/lang/String;
    .locals 1

    .line 303
    iget-object v0, p0, Lio/flutter/plugins/localauth/Messages$AuthResult;->errorMessage:Ljava/lang/String;

    return-object v0
.end method

.method public hashCode()I
    .locals 2

    .line 327
    iget-object v0, p0, Lio/flutter/plugins/localauth/Messages$AuthResult;->code:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthResult;->errorMessage:Ljava/lang/String;

    filled-new-array {v0, v1}, [Ljava/lang/Object;

    move-result-object v0

    invoke-static {v0}, Ljava/util/Objects;->hash([Ljava/lang/Object;)I

    move-result v0

    return v0
.end method

.method public setCode(Lio/flutter/plugins/localauth/Messages$AuthResultCode;)V
    .locals 1

    if-eqz p1, :cond_0

    .line 296
    iput-object p1, p0, Lio/flutter/plugins/localauth/Messages$AuthResult;->code:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    return-void

    .line 294
    :cond_0
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string v0, "Nonnull field \"code\" is null."

    invoke-direct {p1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method public setErrorMessage(Ljava/lang/String;)V
    .locals 0

    .line 307
    iput-object p1, p0, Lio/flutter/plugins/localauth/Messages$AuthResult;->errorMessage:Ljava/lang/String;

    return-void
.end method

.method toList()Ljava/util/ArrayList;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/ArrayList<",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation

    .line 358
    new-instance v0, Ljava/util/ArrayList;

    const/4 v1, 0x2

    invoke-direct {v0, v1}, Ljava/util/ArrayList;-><init>(I)V

    .line 359
    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthResult;->code:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 360
    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthResult;->errorMessage:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    return-object v0
.end method
