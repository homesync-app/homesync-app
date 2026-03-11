.class public final Lio/flutter/plugins/localauth/Messages$AuthStrings;
.super Ljava/lang/Object;
.source "Messages.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/localauth/Messages;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "AuthStrings"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/localauth/Messages$AuthStrings$Builder;
    }
.end annotation


# instance fields
.field private cancelButton:Ljava/lang/String;

.field private reason:Ljava/lang/String;

.field private signInHint:Ljava/lang/String;

.field private signInTitle:Ljava/lang/String;


# direct methods
.method constructor <init>()V
    .locals 0

    .line 189
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static fromList(Ljava/util/ArrayList;)Lio/flutter/plugins/localauth/Messages$AuthStrings;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/ArrayList<",
            "Ljava/lang/Object;",
            ">;)",
            "Lio/flutter/plugins/localauth/Messages$AuthStrings;"
        }
    .end annotation

    .line 266
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthStrings;

    invoke-direct {v0}, Lio/flutter/plugins/localauth/Messages$AuthStrings;-><init>()V

    const/4 v1, 0x0

    .line 267
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v1

    .line 268
    check-cast v1, Ljava/lang/String;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/localauth/Messages$AuthStrings;->setReason(Ljava/lang/String;)V

    const/4 v1, 0x1

    .line 269
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v1

    .line 270
    check-cast v1, Ljava/lang/String;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/localauth/Messages$AuthStrings;->setSignInHint(Ljava/lang/String;)V

    const/4 v1, 0x2

    .line 271
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v1

    .line 272
    check-cast v1, Ljava/lang/String;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/localauth/Messages$AuthStrings;->setCancelButton(Ljava/lang/String;)V

    const/4 v1, 0x3

    .line 273
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object p0

    .line 274
    check-cast p0, Ljava/lang/String;

    invoke-virtual {v0, p0}, Lio/flutter/plugins/localauth/Messages$AuthStrings;->setSignInTitle(Ljava/lang/String;)V

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

    .line 196
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v2

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v3

    if-eq v2, v3, :cond_1

    goto :goto_0

    .line 199
    :cond_1
    check-cast p1, Lio/flutter/plugins/localauth/Messages$AuthStrings;

    .line 200
    iget-object v2, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->reason:Ljava/lang/String;

    iget-object v3, p1, Lio/flutter/plugins/localauth/Messages$AuthStrings;->reason:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_2

    iget-object v2, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->signInHint:Ljava/lang/String;

    iget-object v3, p1, Lio/flutter/plugins/localauth/Messages$AuthStrings;->signInHint:Ljava/lang/String;

    .line 201
    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_2

    iget-object v2, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->cancelButton:Ljava/lang/String;

    iget-object v3, p1, Lio/flutter/plugins/localauth/Messages$AuthStrings;->cancelButton:Ljava/lang/String;

    .line 202
    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_2

    iget-object v2, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->signInTitle:Ljava/lang/String;

    iget-object p1, p1, Lio/flutter/plugins/localauth/Messages$AuthStrings;->signInTitle:Ljava/lang/String;

    .line 203
    invoke-virtual {v2, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_2

    return v0

    :cond_2
    :goto_0
    return v1
.end method

.method public getCancelButton()Ljava/lang/String;
    .locals 1

    .line 165
    iget-object v0, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->cancelButton:Ljava/lang/String;

    return-object v0
.end method

.method public getReason()Ljava/lang/String;
    .locals 1

    .line 139
    iget-object v0, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->reason:Ljava/lang/String;

    return-object v0
.end method

.method public getSignInHint()Ljava/lang/String;
    .locals 1

    .line 152
    iget-object v0, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->signInHint:Ljava/lang/String;

    return-object v0
.end method

.method public getSignInTitle()Ljava/lang/String;
    .locals 1

    .line 178
    iget-object v0, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->signInTitle:Ljava/lang/String;

    return-object v0
.end method

.method public hashCode()I
    .locals 4

    .line 208
    iget-object v0, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->reason:Ljava/lang/String;

    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->signInHint:Ljava/lang/String;

    iget-object v2, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->cancelButton:Ljava/lang/String;

    iget-object v3, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->signInTitle:Ljava/lang/String;

    filled-new-array {v0, v1, v2, v3}, [Ljava/lang/Object;

    move-result-object v0

    invoke-static {v0}, Ljava/util/Objects;->hash([Ljava/lang/Object;)I

    move-result v0

    return v0
.end method

.method public setCancelButton(Ljava/lang/String;)V
    .locals 1

    if-eqz p1, :cond_0

    .line 172
    iput-object p1, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->cancelButton:Ljava/lang/String;

    return-void

    .line 170
    :cond_0
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string v0, "Nonnull field \"cancelButton\" is null."

    invoke-direct {p1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method public setReason(Ljava/lang/String;)V
    .locals 1

    if-eqz p1, :cond_0

    .line 146
    iput-object p1, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->reason:Ljava/lang/String;

    return-void

    .line 144
    :cond_0
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string v0, "Nonnull field \"reason\" is null."

    invoke-direct {p1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method public setSignInHint(Ljava/lang/String;)V
    .locals 1

    if-eqz p1, :cond_0

    .line 159
    iput-object p1, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->signInHint:Ljava/lang/String;

    return-void

    .line 157
    :cond_0
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string v0, "Nonnull field \"signInHint\" is null."

    invoke-direct {p1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method public setSignInTitle(Ljava/lang/String;)V
    .locals 1

    if-eqz p1, :cond_0

    .line 185
    iput-object p1, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->signInTitle:Ljava/lang/String;

    return-void

    .line 183
    :cond_0
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string v0, "Nonnull field \"signInTitle\" is null."

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

    .line 257
    new-instance v0, Ljava/util/ArrayList;

    const/4 v1, 0x4

    invoke-direct {v0, v1}, Ljava/util/ArrayList;-><init>(I)V

    .line 258
    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->reason:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 259
    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->signInHint:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 260
    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->cancelButton:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 261
    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings;->signInTitle:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    return-object v0
.end method
