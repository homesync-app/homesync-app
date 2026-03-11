.class public final Lio/flutter/plugins/localauth/Messages$AuthStrings$Builder;
.super Ljava/lang/Object;
.source "Messages.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/localauth/Messages$AuthStrings;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "Builder"
.end annotation


# instance fields
.field private cancelButton:Ljava/lang/String;

.field private reason:Ljava/lang/String;

.field private signInHint:Ljava/lang/String;

.field private signInTitle:Ljava/lang/String;


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 211
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public build()Lio/flutter/plugins/localauth/Messages$AuthStrings;
    .locals 2

    .line 246
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthStrings;

    invoke-direct {v0}, Lio/flutter/plugins/localauth/Messages$AuthStrings;-><init>()V

    .line 247
    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings$Builder;->reason:Ljava/lang/String;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/localauth/Messages$AuthStrings;->setReason(Ljava/lang/String;)V

    .line 248
    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings$Builder;->signInHint:Ljava/lang/String;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/localauth/Messages$AuthStrings;->setSignInHint(Ljava/lang/String;)V

    .line 249
    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings$Builder;->cancelButton:Ljava/lang/String;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/localauth/Messages$AuthStrings;->setCancelButton(Ljava/lang/String;)V

    .line 250
    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings$Builder;->signInTitle:Ljava/lang/String;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/localauth/Messages$AuthStrings;->setSignInTitle(Ljava/lang/String;)V

    return-object v0
.end method

.method public setCancelButton(Ljava/lang/String;)Lio/flutter/plugins/localauth/Messages$AuthStrings$Builder;
    .locals 0

    .line 233
    iput-object p1, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings$Builder;->cancelButton:Ljava/lang/String;

    return-object p0
.end method

.method public setReason(Ljava/lang/String;)Lio/flutter/plugins/localauth/Messages$AuthStrings$Builder;
    .locals 0

    .line 217
    iput-object p1, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings$Builder;->reason:Ljava/lang/String;

    return-object p0
.end method

.method public setSignInHint(Ljava/lang/String;)Lio/flutter/plugins/localauth/Messages$AuthStrings$Builder;
    .locals 0

    .line 225
    iput-object p1, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings$Builder;->signInHint:Ljava/lang/String;

    return-object p0
.end method

.method public setSignInTitle(Ljava/lang/String;)Lio/flutter/plugins/localauth/Messages$AuthStrings$Builder;
    .locals 0

    .line 241
    iput-object p1, p0, Lio/flutter/plugins/localauth/Messages$AuthStrings$Builder;->signInTitle:Ljava/lang/String;

    return-object p0
.end method
