.class public final Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;
.super Ljava/lang/Object;
.source "Messages.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/imagepicker/Messages;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "SourceSpecification"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/imagepicker/Messages$SourceSpecification$Builder;
    }
.end annotation


# instance fields
.field private camera:Lio/flutter/plugins/imagepicker/Messages$SourceCamera;

.field private type:Lio/flutter/plugins/imagepicker/Messages$SourceType;


# direct methods
.method constructor <init>()V
    .locals 0

    .line 504
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static fromList(Ljava/util/ArrayList;)Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/ArrayList<",
            "Ljava/lang/Object;",
            ">;)",
            "Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;"
        }
    .end annotation

    .line 558
    new-instance v0, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;

    invoke-direct {v0}, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;-><init>()V

    const/4 v1, 0x0

    .line 559
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v1

    .line 560
    check-cast v1, Lio/flutter/plugins/imagepicker/Messages$SourceType;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;->setType(Lio/flutter/plugins/imagepicker/Messages$SourceType;)V

    const/4 v1, 0x1

    .line 561
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object p0

    .line 562
    check-cast p0, Lio/flutter/plugins/imagepicker/Messages$SourceCamera;

    invoke-virtual {v0, p0}, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;->setCamera(Lio/flutter/plugins/imagepicker/Messages$SourceCamera;)V

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

    .line 511
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v2

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v3

    if-eq v2, v3, :cond_1

    goto :goto_0

    .line 514
    :cond_1
    check-cast p1, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;

    .line 515
    iget-object v2, p0, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;->type:Lio/flutter/plugins/imagepicker/Messages$SourceType;

    iget-object v3, p1, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;->type:Lio/flutter/plugins/imagepicker/Messages$SourceType;

    invoke-virtual {v2, v3}, Lio/flutter/plugins/imagepicker/Messages$SourceType;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_2

    iget-object v2, p0, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;->camera:Lio/flutter/plugins/imagepicker/Messages$SourceCamera;

    iget-object p1, p1, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;->camera:Lio/flutter/plugins/imagepicker/Messages$SourceCamera;

    invoke-static {v2, p1}, Ljava/util/Objects;->equals(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_2

    return v0

    :cond_2
    :goto_0
    return v1
.end method

.method public getCamera()Lio/flutter/plugins/imagepicker/Messages$SourceCamera;
    .locals 1

    .line 496
    iget-object v0, p0, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;->camera:Lio/flutter/plugins/imagepicker/Messages$SourceCamera;

    return-object v0
.end method

.method public getType()Lio/flutter/plugins/imagepicker/Messages$SourceType;
    .locals 1

    .line 483
    iget-object v0, p0, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;->type:Lio/flutter/plugins/imagepicker/Messages$SourceType;

    return-object v0
.end method

.method public hashCode()I
    .locals 2

    .line 520
    iget-object v0, p0, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;->type:Lio/flutter/plugins/imagepicker/Messages$SourceType;

    iget-object v1, p0, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;->camera:Lio/flutter/plugins/imagepicker/Messages$SourceCamera;

    filled-new-array {v0, v1}, [Ljava/lang/Object;

    move-result-object v0

    invoke-static {v0}, Ljava/util/Objects;->hash([Ljava/lang/Object;)I

    move-result v0

    return v0
.end method

.method public setCamera(Lio/flutter/plugins/imagepicker/Messages$SourceCamera;)V
    .locals 0

    .line 500
    iput-object p1, p0, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;->camera:Lio/flutter/plugins/imagepicker/Messages$SourceCamera;

    return-void
.end method

.method public setType(Lio/flutter/plugins/imagepicker/Messages$SourceType;)V
    .locals 1

    if-eqz p1, :cond_0

    .line 490
    iput-object p1, p0, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;->type:Lio/flutter/plugins/imagepicker/Messages$SourceType;

    return-void

    .line 488
    :cond_0
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string v0, "Nonnull field \"type\" is null."

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

    .line 551
    new-instance v0, Ljava/util/ArrayList;

    const/4 v1, 0x2

    invoke-direct {v0, v1}, Ljava/util/ArrayList;-><init>(I)V

    .line 552
    iget-object v1, p0, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;->type:Lio/flutter/plugins/imagepicker/Messages$SourceType;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 553
    iget-object v1, p0, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;->camera:Lio/flutter/plugins/imagepicker/Messages$SourceCamera;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    return-object v0
.end method
