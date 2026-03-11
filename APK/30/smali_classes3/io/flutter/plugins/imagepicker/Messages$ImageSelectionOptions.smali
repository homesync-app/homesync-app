.class public final Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;
.super Ljava/lang/Object;
.source "Messages.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/imagepicker/Messages;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "ImageSelectionOptions"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions$Builder;
    }
.end annotation


# instance fields
.field private maxHeight:Ljava/lang/Double;

.field private maxWidth:Ljava/lang/Double;

.field private quality:Ljava/lang/Long;


# direct methods
.method constructor <init>()V
    .locals 0

    .line 264
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static fromList(Ljava/util/ArrayList;)Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/ArrayList<",
            "Ljava/lang/Object;",
            ">;)",
            "Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;"
        }
    .end annotation

    .line 330
    new-instance v0, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;

    invoke-direct {v0}, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;-><init>()V

    const/4 v1, 0x0

    .line 331
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v1

    .line 332
    check-cast v1, Ljava/lang/Double;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->setMaxWidth(Ljava/lang/Double;)V

    const/4 v1, 0x1

    .line 333
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v1

    .line 334
    check-cast v1, Ljava/lang/Double;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->setMaxHeight(Ljava/lang/Double;)V

    const/4 v1, 0x2

    .line 335
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object p0

    .line 336
    check-cast p0, Ljava/lang/Long;

    invoke-virtual {v0, p0}, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->setQuality(Ljava/lang/Long;)V

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

    .line 271
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v2

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v3

    if-eq v2, v3, :cond_1

    goto :goto_0

    .line 274
    :cond_1
    check-cast p1, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;

    .line 275
    iget-object v2, p0, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->maxWidth:Ljava/lang/Double;

    iget-object v3, p1, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->maxWidth:Ljava/lang/Double;

    invoke-static {v2, v3}, Ljava/util/Objects;->equals(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_2

    iget-object v2, p0, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->maxHeight:Ljava/lang/Double;

    iget-object v3, p1, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->maxHeight:Ljava/lang/Double;

    .line 276
    invoke-static {v2, v3}, Ljava/util/Objects;->equals(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_2

    iget-object v2, p0, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->quality:Ljava/lang/Long;

    iget-object p1, p1, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->quality:Ljava/lang/Long;

    .line 277
    invoke-virtual {v2, p1}, Ljava/lang/Long;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_2

    return v0

    :cond_2
    :goto_0
    return v1
.end method

.method public getMaxHeight()Ljava/lang/Double;
    .locals 1

    .line 238
    iget-object v0, p0, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->maxHeight:Ljava/lang/Double;

    return-object v0
.end method

.method public getMaxWidth()Ljava/lang/Double;
    .locals 1

    .line 227
    iget-object v0, p0, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->maxWidth:Ljava/lang/Double;

    return-object v0
.end method

.method public getQuality()Ljava/lang/Long;
    .locals 1

    .line 253
    iget-object v0, p0, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->quality:Ljava/lang/Long;

    return-object v0
.end method

.method public hashCode()I
    .locals 3

    .line 282
    iget-object v0, p0, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->maxWidth:Ljava/lang/Double;

    iget-object v1, p0, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->maxHeight:Ljava/lang/Double;

    iget-object v2, p0, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->quality:Ljava/lang/Long;

    filled-new-array {v0, v1, v2}, [Ljava/lang/Object;

    move-result-object v0

    invoke-static {v0}, Ljava/util/Objects;->hash([Ljava/lang/Object;)I

    move-result v0

    return v0
.end method

.method public setMaxHeight(Ljava/lang/Double;)V
    .locals 0

    .line 242
    iput-object p1, p0, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->maxHeight:Ljava/lang/Double;

    return-void
.end method

.method public setMaxWidth(Ljava/lang/Double;)V
    .locals 0

    .line 231
    iput-object p1, p0, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->maxWidth:Ljava/lang/Double;

    return-void
.end method

.method public setQuality(Ljava/lang/Long;)V
    .locals 1

    if-eqz p1, :cond_0

    .line 260
    iput-object p1, p0, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->quality:Ljava/lang/Long;

    return-void

    .line 258
    :cond_0
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string v0, "Nonnull field \"quality\" is null."

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

    .line 322
    new-instance v0, Ljava/util/ArrayList;

    const/4 v1, 0x3

    invoke-direct {v0, v1}, Ljava/util/ArrayList;-><init>(I)V

    .line 323
    iget-object v1, p0, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->maxWidth:Ljava/lang/Double;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 324
    iget-object v1, p0, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->maxHeight:Ljava/lang/Double;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 325
    iget-object v1, p0, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->quality:Ljava/lang/Long;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    return-object v0
.end method
