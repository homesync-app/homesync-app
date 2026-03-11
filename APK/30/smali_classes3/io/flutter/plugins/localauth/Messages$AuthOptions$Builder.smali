.class public final Lio/flutter/plugins/localauth/Messages$AuthOptions$Builder;
.super Ljava/lang/Object;
.source "Messages.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/localauth/Messages$AuthOptions;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "Builder"
.end annotation


# instance fields
.field private biometricOnly:Ljava/lang/Boolean;

.field private sensitiveTransaction:Ljava/lang/Boolean;

.field private sticky:Ljava/lang/Boolean;


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 437
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public build()Lio/flutter/plugins/localauth/Messages$AuthOptions;
    .locals 2

    .line 464
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthOptions;

    invoke-direct {v0}, Lio/flutter/plugins/localauth/Messages$AuthOptions;-><init>()V

    .line 465
    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions$Builder;->biometricOnly:Ljava/lang/Boolean;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/localauth/Messages$AuthOptions;->setBiometricOnly(Ljava/lang/Boolean;)V

    .line 466
    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions$Builder;->sensitiveTransaction:Ljava/lang/Boolean;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/localauth/Messages$AuthOptions;->setSensitiveTransaction(Ljava/lang/Boolean;)V

    .line 467
    iget-object v1, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions$Builder;->sticky:Ljava/lang/Boolean;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/localauth/Messages$AuthOptions;->setSticky(Ljava/lang/Boolean;)V

    return-object v0
.end method

.method public setBiometricOnly(Ljava/lang/Boolean;)Lio/flutter/plugins/localauth/Messages$AuthOptions$Builder;
    .locals 0

    .line 443
    iput-object p1, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions$Builder;->biometricOnly:Ljava/lang/Boolean;

    return-object p0
.end method

.method public setSensitiveTransaction(Ljava/lang/Boolean;)Lio/flutter/plugins/localauth/Messages$AuthOptions$Builder;
    .locals 0

    .line 451
    iput-object p1, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions$Builder;->sensitiveTransaction:Ljava/lang/Boolean;

    return-object p0
.end method

.method public setSticky(Ljava/lang/Boolean;)Lio/flutter/plugins/localauth/Messages$AuthOptions$Builder;
    .locals 0

    .line 459
    iput-object p1, p0, Lio/flutter/plugins/localauth/Messages$AuthOptions$Builder;->sticky:Ljava/lang/Boolean;

    return-object p0
.end method
