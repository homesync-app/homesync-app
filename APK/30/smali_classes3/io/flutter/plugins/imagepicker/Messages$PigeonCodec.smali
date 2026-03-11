.class Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;
.super Lio/flutter/plugin/common/StandardMessageCodec;
.source "Messages.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/imagepicker/Messages;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0xa
    name = "PigeonCodec"
.end annotation


# static fields
.field public static final INSTANCE:Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .line 786
    new-instance v0, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;

    invoke-direct {v0}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;-><init>()V

    sput-object v0, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->INSTANCE:Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;

    return-void
.end method

.method private constructor <init>()V
    .locals 0

    .line 788
    invoke-direct {p0}, Lio/flutter/plugin/common/StandardMessageCodec;-><init>()V

    return-void
.end method


# virtual methods
.method protected readValueOfType(BLjava/nio/ByteBuffer;)Ljava/lang/Object;
    .locals 1

    const/4 v0, 0x0

    packed-switch p1, :pswitch_data_0

    .line 823
    invoke-super {p0, p1, p2}, Lio/flutter/plugin/common/StandardMessageCodec;->readValueOfType(BLjava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    return-object p1

    .line 821
    :pswitch_0
    invoke-virtual {p0, p2}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/util/ArrayList;

    invoke-static {p1}, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->fromList(Ljava/util/ArrayList;)Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;

    move-result-object p1

    return-object p1

    .line 819
    :pswitch_1
    invoke-virtual {p0, p2}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/util/ArrayList;

    invoke-static {p1}, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalError;->fromList(Ljava/util/ArrayList;)Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalError;

    move-result-object p1

    return-object p1

    .line 817
    :pswitch_2
    invoke-virtual {p0, p2}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/util/ArrayList;

    invoke-static {p1}, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;->fromList(Ljava/util/ArrayList;)Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;

    move-result-object p1

    return-object p1

    .line 815
    :pswitch_3
    invoke-virtual {p0, p2}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/util/ArrayList;

    invoke-static {p1}, Lio/flutter/plugins/imagepicker/Messages$VideoSelectionOptions;->fromList(Ljava/util/ArrayList;)Lio/flutter/plugins/imagepicker/Messages$VideoSelectionOptions;

    move-result-object p1

    return-object p1

    .line 813
    :pswitch_4
    invoke-virtual {p0, p2}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/util/ArrayList;

    invoke-static {p1}, Lio/flutter/plugins/imagepicker/Messages$MediaSelectionOptions;->fromList(Ljava/util/ArrayList;)Lio/flutter/plugins/imagepicker/Messages$MediaSelectionOptions;

    move-result-object p1

    return-object p1

    .line 811
    :pswitch_5
    invoke-virtual {p0, p2}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/util/ArrayList;

    invoke-static {p1}, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->fromList(Ljava/util/ArrayList;)Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;

    move-result-object p1

    return-object p1

    .line 809
    :pswitch_6
    invoke-virtual {p0, p2}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/util/ArrayList;

    invoke-static {p1}, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->fromList(Ljava/util/ArrayList;)Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;

    move-result-object p1

    return-object p1

    .line 805
    :pswitch_7
    invoke-virtual {p0, p2}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    if-nez p1, :cond_0

    return-object v0

    .line 806
    :cond_0
    invoke-static {}, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalType;->values()[Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalType;

    move-result-object p2

    check-cast p1, Ljava/lang/Long;

    invoke-virtual {p1}, Ljava/lang/Long;->intValue()I

    move-result p1

    aget-object p1, p2, p1

    return-object p1

    .line 800
    :pswitch_8
    invoke-virtual {p0, p2}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    if-nez p1, :cond_1

    return-object v0

    .line 801
    :cond_1
    invoke-static {}, Lio/flutter/plugins/imagepicker/Messages$SourceType;->values()[Lio/flutter/plugins/imagepicker/Messages$SourceType;

    move-result-object p2

    check-cast p1, Ljava/lang/Long;

    invoke-virtual {p1}, Ljava/lang/Long;->intValue()I

    move-result p1

    aget-object p1, p2, p1

    return-object p1

    .line 795
    :pswitch_9
    invoke-virtual {p0, p2}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    if-nez p1, :cond_2

    return-object v0

    .line 796
    :cond_2
    invoke-static {}, Lio/flutter/plugins/imagepicker/Messages$SourceCamera;->values()[Lio/flutter/plugins/imagepicker/Messages$SourceCamera;

    move-result-object p2

    check-cast p1, Ljava/lang/Long;

    invoke-virtual {p1}, Ljava/lang/Long;->intValue()I

    move-result p1

    aget-object p1, p2, p1

    return-object p1

    :pswitch_data_0
    .packed-switch -0x7f
        :pswitch_9
        :pswitch_8
        :pswitch_7
        :pswitch_6
        :pswitch_5
        :pswitch_4
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method protected writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V
    .locals 2

    .line 829
    instance-of v0, p2, Lio/flutter/plugins/imagepicker/Messages$SourceCamera;

    const/4 v1, 0x0

    if-eqz v0, :cond_1

    const/16 v0, 0x81

    .line 830
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    if-nez p2, :cond_0

    goto :goto_0

    .line 831
    :cond_0
    check-cast p2, Lio/flutter/plugins/imagepicker/Messages$SourceCamera;

    iget p2, p2, Lio/flutter/plugins/imagepicker/Messages$SourceCamera;->index:I

    invoke-static {p2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    :goto_0
    invoke-virtual {p0, p1, v1}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 832
    :cond_1
    instance-of v0, p2, Lio/flutter/plugins/imagepicker/Messages$SourceType;

    if-eqz v0, :cond_3

    const/16 v0, 0x82

    .line 833
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    if-nez p2, :cond_2

    goto :goto_1

    .line 834
    :cond_2
    check-cast p2, Lio/flutter/plugins/imagepicker/Messages$SourceType;

    iget p2, p2, Lio/flutter/plugins/imagepicker/Messages$SourceType;->index:I

    invoke-static {p2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    :goto_1
    invoke-virtual {p0, p1, v1}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 835
    :cond_3
    instance-of v0, p2, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalType;

    if-eqz v0, :cond_5

    const/16 v0, 0x83

    .line 836
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    if-nez p2, :cond_4

    goto :goto_2

    .line 837
    :cond_4
    check-cast p2, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalType;

    iget p2, p2, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalType;->index:I

    invoke-static {p2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    :goto_2
    invoke-virtual {p0, p1, v1}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 838
    :cond_5
    instance-of v0, p2, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;

    if-eqz v0, :cond_6

    const/16 v0, 0x84

    .line 839
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 840
    check-cast p2, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;

    invoke-virtual {p2}, Lio/flutter/plugins/imagepicker/Messages$GeneralOptions;->toList()Ljava/util/ArrayList;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 841
    :cond_6
    instance-of v0, p2, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;

    if-eqz v0, :cond_7

    const/16 v0, 0x85

    .line 842
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 843
    check-cast p2, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;

    invoke-virtual {p2}, Lio/flutter/plugins/imagepicker/Messages$ImageSelectionOptions;->toList()Ljava/util/ArrayList;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 844
    :cond_7
    instance-of v0, p2, Lio/flutter/plugins/imagepicker/Messages$MediaSelectionOptions;

    if-eqz v0, :cond_8

    const/16 v0, 0x86

    .line 845
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 846
    check-cast p2, Lio/flutter/plugins/imagepicker/Messages$MediaSelectionOptions;

    invoke-virtual {p2}, Lio/flutter/plugins/imagepicker/Messages$MediaSelectionOptions;->toList()Ljava/util/ArrayList;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 847
    :cond_8
    instance-of v0, p2, Lio/flutter/plugins/imagepicker/Messages$VideoSelectionOptions;

    if-eqz v0, :cond_9

    const/16 v0, 0x87

    .line 848
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 849
    check-cast p2, Lio/flutter/plugins/imagepicker/Messages$VideoSelectionOptions;

    invoke-virtual {p2}, Lio/flutter/plugins/imagepicker/Messages$VideoSelectionOptions;->toList()Ljava/util/ArrayList;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 850
    :cond_9
    instance-of v0, p2, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;

    if-eqz v0, :cond_a

    const/16 v0, 0x88

    .line 851
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 852
    check-cast p2, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;

    invoke-virtual {p2}, Lio/flutter/plugins/imagepicker/Messages$SourceSpecification;->toList()Ljava/util/ArrayList;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 853
    :cond_a
    instance-of v0, p2, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalError;

    if-eqz v0, :cond_b

    const/16 v0, 0x89

    .line 854
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 855
    check-cast p2, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalError;

    invoke-virtual {p2}, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalError;->toList()Ljava/util/ArrayList;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 856
    :cond_b
    instance-of v0, p2, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;

    if-eqz v0, :cond_c

    const/16 v0, 0x8a

    .line 857
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 858
    check-cast p2, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;

    invoke-virtual {p2}, Lio/flutter/plugins/imagepicker/Messages$CacheRetrievalResult;->toList()Ljava/util/ArrayList;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/imagepicker/Messages$PigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 860
    :cond_c
    invoke-super {p0, p1, p2}, Lio/flutter/plugin/common/StandardMessageCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void
.end method
