.class public final Lio/flutter/plugins/localauth/Messages$AuthOptions;
.super Ljava/lang/Object;
.source "Messages.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/localauth/Messages;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "AuthOptions"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/localauth/Messages$AuthOptions$Builder;
    }
.end annotation


# instance fields
.field private biometricOnly:Ljava/lang/Boolean;

.field private sensitiveTransaction:Ljava/lang/Boolean;

.field private sticky:Ljava/lang/Boolean;


# direct methods
.method constructor <init>()V
    .locals 0

    .line 416
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static fromList(Ljava/util/ArrayList;)Lio/flutter/plugins/localauth/Messages$AuthOptions;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/ArrayList<",
            "Ljava/lang/Object;",
            ">;)",
            "Lio/flutter/plugins/localauth/Messages$AuthOptions;"
        }
    .end annotation

    .line 482
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthOptions;

    invoke-direct {v0}, Lio/flutter/plugins/localauth/Messages$AuthOptions;-><init>()V

    const/4 v1, 0x0

    .line 483
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v1

    .line 484
    check-cast v1, Ljava/lang/Boolean;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/localauth/Messages$AuthOptions;->setBiometricOnly(Ljava/lang/Boolean;)V

    const/4 v1, 0x1

    .line 485
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v1

    .line 486
    check-cast v1, Ljava/lang/Boolean;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/localauth/Messages$AuthOptions;->setSensitiveTransaction(Ljava/lang/Boolean;)V

    const/4 v1, 0x2

    .line 487
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object p0

    .line 488
    check-cast p0, Ljava/lang/Boolean;

    invoke-virtual {v0, p0}, Lio/flutter/plugins/localauth/Messages$AuthOptions;->setSticky(Ljava/lang/Boolean;)V

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

    .line 423
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v2

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v3

    if-eq v2, v3, :cond_1

    goto :goto_0

    .line 426
    :cond_1
    check-cast p1, Lio/flutter/plugins/localauth/Messages$AuthOptions;

    .line 427
    iget-object v2, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions;->biometricOnly:Ljava/lang/Boolean;

    iget-object v3, p1, Lio/flutter/plugins/localauth/Messages$AuthOptions;->biometricOnly:Ljava/lang/Boolean;

    invoke-virtual {v2, v3}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_2

    iget-object v2, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions;->sensitiveTransaction:Ljava/lang/Boolean;

    iget-object v3, p1, Lio/flutter/plugins/localauth/Messages$AuthOptions;->sensitiveTransaction:Ljava/lang/Boolean;

    .line 428
    invoke-virtual {v2, v3}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_2

    iget-object v2, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions;->sticky:Ljava/lang/Boolean;

    iget-object p1, p1, Lio/flutter/plugins/localauth/Messages$AuthOptions;->sticky:Ljava/lang/Boolean;

    .line 429
    invoke-virtual {v2, p1}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_2

    return v0

    :cond_2
    :goto_0
    return v1
.end method

.method public getBiometricOnly()Ljava/lang/Boolean;
    .locals 1

    .line 379
    iget-object v0, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions;->biometricOnly:Ljava/lang/Boolean;

    return-object v0
.end method

.method public getSensitiveTransaction()Ljava/lang/Boolean;
    .locals 1

    .line 392
    iget-object v0, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions;->sensitiveTransaction:Ljava/lang/Boolean;

    return-object v0
.end method

.method public getSticky()Ljava/lang/Boolean;
    .locals 1

    .line 405
    iget-object v0, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions;->sticky:Ljava/lang/Boolean;

    return-object v0
.end method

.method public hashCode()I
    .locals 3

    .line 434
    iget-object v0, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions;->biometricOnly:Ljava/lang/Boolean;

    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions;->sensitiveTransaction:Ljava/lang/Boolean;

    iget-object v2, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions;->sticky:Ljava/lang/Boolean;

    filled-new-array {v0, v1, v2}, [Ljava/lang/Object;

    move-result-object v0

    invoke-static {v0}, Ljava/util/Objects;->hash([Ljava/lang/Object;)I

    move-result v0

    return v0
.end method

.method public setBiometricOnly(Ljava/lang/Boolean;)V
    .locals 1

    if-eqz p1, :cond_0

    .line 386
    iput-object p1, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions;->biometricOnly:Ljava/lang/Boolean;

    return-void

    .line 384
    :cond_0
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string v0, "Nonnull field \"biometricOnly\" is null."

    invoke-direct {p1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method public setSensitiveTransaction(Ljava/lang/Boolean;)V
    .locals 1

    if-eqz p1, :cond_0

    .line 399
    iput-object p1, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions;->sensitiveTransaction:Ljava/lang/Boolean;

    return-void

    .line 397
    :cond_0
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string v0, "Nonnull field \"sensitiveTransaction\" is null."

    invoke-direct {p1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method public setSticky(Ljava/lang/Boolean;)V
    .locals 1

    if-eqz p1, :cond_0

    .line 412
    iput-object p1, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions;->sticky:Ljava/lang/Boolean;

    return-void

    .line 410
    :cond_0
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string v0, "Nonnull field \"sticky\" is null."

    invoke-direct {p1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1
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

    .line 474
    new-instance v0, Ljava/util/ArrayList;

    const/4 v1, 0x3

    invoke-direct {v0, v1}, Ljava/util/ArrayList;-><init>(I)V

    .line 475
    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions;->biometricOnly:Ljava/lang/Boolean;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 476
    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions;->sensitiveTransaction:Ljava/lang/Boolean;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 477
    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions;->sticky:Ljava/lang/Boolean;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    return-object v0
.end method
