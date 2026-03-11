.class public final Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;
.super Ljava/lang/Object;
.source "Messages.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/imagepicker/Messages;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "CacheRetrievalResult"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult$Builder;
    }
.end annotation


# instance fields
.field private error:Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalError;

.field private paths:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field private type:Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalType;


# direct methods
.method constructor <init>()V
    .locals 0

    .line 708
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static fromList(Ljava/util/ArrayList;)Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/ArrayList<",
            "Ljava/lang/Object;",
            ">;)",
            "Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;"
        }
    .end annotation

    .line 774
    new-instance v0, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;

    invoke-direct {v0}, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;-><init>()V

    const/4 v1, 0x0

    .line 775
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v1

    .line 776
    check-cast v1, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalType;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->setType(Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalType;)V

    const/4 v1, 0x1

    .line 777
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v1

    .line 778
    check-cast v1, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalError;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->setError(Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalError;)V

    const/4 v1, 0x2

    .line 779
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object p0

    .line 780
    check-cast p0, Ljava/util/List;

    invoke-virtual {v0, p0}, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->setPaths(Ljava/util/List;)V

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

    .line 715
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v2

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v3

    if-eq v2, v3, :cond_1

    goto :goto_0

    .line 718
    :cond_1
    check-cast p1, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;

    .line 719
    iget-object v2, p0, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->type:Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalType;

    iget-object v3, p1, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->type:Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalType;

    invoke-virtual {v2, v3}, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalType;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_2

    iget-object v2, p0, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->error:Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalError;

    iget-object v3, p1, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->error:Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalError;

    .line 720
    invoke-static {v2, v3}, Ljava/util/Objects;->equals(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_2

    iget-object v2, p0, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->paths:Ljava/util/List;

    iget-object p1, p1, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->paths:Ljava/util/List;

    .line 721
    invoke-virtual {v2, p1}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_2

    return v0

    :cond_2
    :goto_0
    return v1
.end method

.method public getError()Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalError;
    .locals 1

    .line 686
    iget-object v0, p0, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->error:Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalError;

    return-object v0
.end method

.method public getPaths()Ljava/util/List;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .line 697
    iget-object v0, p0, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->paths:Ljava/util/List;

    return-object v0
.end method

.method public getType()Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalType;
    .locals 1

    .line 672
    iget-object v0, p0, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->type:Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalType;

    return-object v0
.end method

.method public hashCode()I
    .locals 3

    .line 726
    iget-object v0, p0, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->type:Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalType;

    iget-object v1, p0, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->error:Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalError;

    iget-object v2, p0, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->paths:Ljava/util/List;

    filled-new-array {v0, v1, v2}, [Ljava/lang/Object;

    move-result-object v0

    invoke-static {v0}, Ljava/util/Objects;->hash([Ljava/lang/Object;)I

    move-result v0

    return v0
.end method

.method public setError(Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalError;)V
    .locals 0

    .line 690
    iput-object p1, p0, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->error:Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalError;

    return-void
.end method

.method public setPaths(Ljava/util/List;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;)V"
        }
    .end annotation

    if-eqz p1, :cond_0

    .line 704
    iput-object p1, p0, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->paths:Ljava/util/List;

    return-void

    .line 702
    :cond_0
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string v0, "Nonnull field \"paths\" is null."

    invoke-direct {p1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method public setType(Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalType;)V
    .locals 1

    if-eqz p1, :cond_0

    .line 679
    iput-object p1, p0, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->type:Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalType;

    return-void

    .line 677
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

    .line 766
    new-instance v0, Ljava/util/ArrayList;

    const/4 v1, 0x3

    invoke-direct {v0, v1}, Ljava/util/ArrayList;-><init>(I)V

    .line 767
    iget-object v1, p0, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->type:Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalType;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 768
    iget-object v1, p0, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->error:Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalError;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 769
    iget-object v1, p0, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->paths:Ljava/util/List;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    return-object v0
.end method
