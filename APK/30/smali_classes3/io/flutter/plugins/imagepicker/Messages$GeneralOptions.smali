.class public final Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;
.super Ljava/lang/Object;
.source "Messages.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/imagepicker/Messages;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "GeneralOptions"
.end annotation

.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/imagepicker/Messages$GeneralOptions$Builder;
    }
.end annotation


# instance fields
.field private allowMultiple:Ljava/lang/Boolean;

.field private limit:Ljava/lang/Long;

.field private usePhotoPicker:Ljava/lang/Boolean;


# direct methods
.method constructor <init>()V
    .locals 0

    .line 140
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static fromList(Ljava/util/ArrayList;)Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/ArrayList<",
            "Ljava/lang/Object;",
            ">;)",
            "Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;"
        }
    .end annotation

    .line 206
    new-instance v0, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;

    invoke-direct {v0}, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;-><init>()V

    const/4 v1, 0x0

    .line 207
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v1

    .line 208
    check-cast v1, Ljava/lang/Boolean;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->setAllowMultiple(Ljava/lang/Boolean;)V

    const/4 v1, 0x1

    .line 209
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object v1

    .line 210
    check-cast v1, Ljava/lang/Boolean;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->setUsePhotoPicker(Ljava/lang/Boolean;)V

    const/4 v1, 0x2

    .line 211
    invoke-virtual {p0, v1}, Ljava/util/ArrayList;->get(I)Ljava/lang/Object;

    move-result-object p0

    .line 212
    check-cast p0, Ljava/lang/Long;

    invoke-virtual {v0, p0}, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->setLimit(Ljava/lang/Long;)V

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

    .line 147
    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v2

    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v3

    if-eq v2, v3, :cond_1

    goto :goto_0

    .line 150
    :cond_1
    check-cast p1, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;

    .line 151
    iget-object v2, p0, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->allowMultiple:Ljava/lang/Boolean;

    iget-object v3, p1, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->allowMultiple:Ljava/lang/Boolean;

    invoke-virtual {v2, v3}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_2

    iget-object v2, p0, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->usePhotoPicker:Ljava/lang/Boolean;

    iget-object v3, p1, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->usePhotoPicker:Ljava/lang/Boolean;

    .line 152
    invoke-virtual {v2, v3}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_2

    iget-object v2, p0, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->limit:Ljava/lang/Long;

    iget-object p1, p1, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->limit:Ljava/lang/Long;

    .line 153
    invoke-static {v2, p1}, Ljava/util/Objects;->equals(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_2

    return v0

    :cond_2
    :goto_0
    return v1
.end method

.method public getAllowMultiple()Ljava/lang/Boolean;
    .locals 1

    .line 106
    iget-object v0, p0, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->allowMultiple:Ljava/lang/Boolean;

    return-object v0
.end method

.method public getLimit()Ljava/lang/Long;
    .locals 1

    .line 132
    iget-object v0, p0, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->limit:Ljava/lang/Long;

    return-object v0
.end method

.method public getUsePhotoPicker()Ljava/lang/Boolean;
    .locals 1

    .line 119
    iget-object v0, p0, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->usePhotoPicker:Ljava/lang/Boolean;

    return-object v0
.end method

.method public hashCode()I
    .locals 3

    .line 158
    iget-object v0, p0, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->allowMultiple:Ljava/lang/Boolean;

    iget-object v1, p0, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->usePhotoPicker:Ljava/lang/Boolean;

    iget-object v2, p0, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->limit:Ljava/lang/Long;

    filled-new-array {v0, v1, v2}, [Ljava/lang/Object;

    move-result-object v0

    invoke-static {v0}, Ljava/util/Objects;->hash([Ljava/lang/Object;)I

    move-result v0

    return v0
.end method

.method public setAllowMultiple(Ljava/lang/Boolean;)V
    .locals 1

    if-eqz p1, :cond_0

    .line 113
    iput-object p1, p0, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->allowMultiple:Ljava/lang/Boolean;

    return-void

    .line 111
    :cond_0
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string v0, "Nonnull field \"allowMultiple\" is null."

    invoke-direct {p1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p1
.end method

.method public setLimit(Ljava/lang/Long;)V
    .locals 0

    .line 136
    iput-object p1, p0, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->limit:Ljava/lang/Long;

    return-void
.end method

.method public setUsePhotoPicker(Ljava/lang/Boolean;)V
    .locals 1

    if-eqz p1, :cond_0

    .line 126
    iput-object p1, p0, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->usePhotoPicker:Ljava/lang/Boolean;

    return-void

    .line 124
    :cond_0
    new-instance p1, Ljava/lang/IllegalStateException;

    const-string v0, "Nonnull field \"usePhotoPicker\" is null."

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

    .line 198
    new-instance v0, Ljava/util/ArrayList;

    const/4 v1, 0x3

    invoke-direct {v0, v1}, Ljava/util/ArrayList;-><init>(I)V

    .line 199
    iget-object v1, p0, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->allowMultiple:Ljava/lang/Boolean;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 200
    iget-object v1, p0, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->usePhotoPicker:Ljava/lang/Boolean;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    .line 201
    iget-object v1, p0, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->limit:Ljava/lang/Long;

    invoke-virtual {v0, v1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    return-object v0
.end method
