.class Lio/flutter/plugins/localauth/Messages$PigeonCodec;
.super Lio/flutter/plugin/common/StandardMessageCodec;
.source "Messages.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/localauth/Messages;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0xa
    name = "PigeonCodec"
.end annotation


# static fields
.field public static final INSTANCE:Lio/flutter/plugins/localauth/Messages$PigeonCodec;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .line 494
    new-instance v0, Lio/flutter/plugins/localauth/Messages$PigeonCodec;

    invoke-direct {v0}, Lio/flutter/plugins/localauth/Messages$PigeonCodec;-><init>()V

    sput-object v0, Lio/flutter/plugins/localauth/Messages$PigeonCodec;->INSTANCE:Lio/flutter/plugins/localauth/Messages$PigeonCodec;

    return-void
.end method

.method private constructor <init>()V
    .locals 0

    .line 496
    invoke-direct {p0}, Lio/flutter/plugin/common/StandardMessageCodec;-><init>()V

    return-void
.end method


# virtual methods
.method protected readValueOfType(BLjava/nio/ByteBuffer;)Ljava/lang/Object;
    .locals 1

    const/4 v0, 0x0

    packed-switch p1, :pswitch_data_0

    .line 518
    invoke-super {p0, p1, p2}, Lio/flutter/plugin/common/StandardMessageCodec;->readValueOfType(BLjava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    return-object p1

    .line 516
    :pswitch_0
    invoke-virtual {p0, p2}, Lio/flutter/plugins/localauth/Messages$PigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/util/ArrayList;

    invoke-static {p1}, Lio/flutter/plugins/localauth/Messages$AuthOptions;->fromList(Ljava/util/ArrayList;)Lio/flutter/plugins/localauth/Messages$AuthOptions;

    move-result-object p1

    return-object p1

    .line 514
    :pswitch_1
    invoke-virtual {p0, p2}, Lio/flutter/plugins/localauth/Messages$PigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/util/ArrayList;

    invoke-static {p1}, Lio/flutter/plugins/localauth/Messages$AuthResult;->fromList(Ljava/util/ArrayList;)Lio/flutter/plugins/localauth/Messages$AuthResult;

    move-result-object p1

    return-object p1

    .line 512
    :pswitch_2
    invoke-virtual {p0, p2}, Lio/flutter/plugins/localauth/Messages$PigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/util/ArrayList;

    invoke-static {p1}, Lio/flutter/plugins/localauth/Messages$AuthStrings;->fromList(Ljava/util/ArrayList;)Lio/flutter/plugins/localauth/Messages$AuthStrings;

    move-result-object p1

    return-object p1

    .line 508
    :pswitch_3
    invoke-virtual {p0, p2}, Lio/flutter/plugins/localauth/Messages$PigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    if-nez p1, :cond_0

    return-object v0

    .line 509
    :cond_0
    invoke-static {}, Lio/flutter/plugins/localauth/Messages$AuthClassification;->values()[Lio/flutter/plugins/localauth/Messages$AuthClassification;

    move-result-object p2

    check-cast p1, Ljava/lang/Long;

    invoke-virtual {p1}, Ljava/lang/Long;->intValue()I

    move-result p1

    aget-object p1, p2, p1

    return-object p1

    .line 503
    :pswitch_4
    invoke-virtual {p0, p2}, Lio/flutter/plugins/localauth/Messages$PigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    if-nez p1, :cond_1

    return-object v0

    .line 504
    :cond_1
    invoke-static {}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->values()[Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    move-result-object p2

    check-cast p1, Ljava/lang/Long;

    invoke-virtual {p1}, Ljava/lang/Long;->intValue()I

    move-result p1

    aget-object p1, p2, p1

    return-object p1

    :pswitch_data_0
    .packed-switch -0x7f
        :pswitch_4
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method protected writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V
    .locals 2

    .line 524
    instance-of v0, p2, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    const/4 v1, 0x0

    if-eqz v0, :cond_1

    const/16 v0, 0x81

    .line 525
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    if-nez p2, :cond_0

    goto :goto_0

    .line 526
    :cond_0
    check-cast p2, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    iget p2, p2, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->index:I

    invoke-static {p2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    :goto_0
    invoke-virtual {p0, p1, v1}, Lio/flutter/plugins/localauth/Messages$PigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 527
    :cond_1
    instance-of v0, p2, Lio/flutter/plugins/localauth/Messages$AuthClassification;

    if-eqz v0, :cond_3

    const/16 v0, 0x82

    .line 528
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    if-nez p2, :cond_2

    goto :goto_1

    .line 529
    :cond_2
    check-cast p2, Lio/flutter/plugins/localauth/Messages$AuthClassification;

    iget p2, p2, Lio/flutter/plugins/localauth/Messages$AuthClassification;->index:I

    invoke-static {p2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    :goto_1
    invoke-virtual {p0, p1, v1}, Lio/flutter/plugins/localauth/Messages$PigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 530
    :cond_3
    instance-of v0, p2, Lio/flutter/plugins/localauth/Messages$AuthStrings;

    if-eqz v0, :cond_4

    const/16 v0, 0x83

    .line 531
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 532
    check-cast p2, Lio/flutter/plugins/localauth/Messages$AuthStrings;

    invoke-virtual {p2}, Lio/flutter/plugins/localauth/Messages$AuthStrings;->toList()Ljava/util/ArrayList;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/localauth/Messages$PigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 533
    :cond_4
    instance-of v0, p2, Lio/flutter/plugins/localauth/Messages$AuthResult;

    if-eqz v0, :cond_5

    const/16 v0, 0x84

    .line 534
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 535
    check-cast p2, Lio/flutter/plugins/localauth/Messages$AuthResult;

    invoke-virtual {p2}, Lio/flutter/plugins/localauth/Messages$AuthResult;->toList()Ljava/util/ArrayList;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/localauth/Messages$PigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 536
    :cond_5
    instance-of v0, p2, Lio/flutter/plugins/localauth/Messages$AuthOptions;

    if-eqz v0, :cond_6

    const/16 v0, 0x85

    .line 537
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 538
    check-cast p2, Lio/flutter/plugins/localauth/Messages$AuthOptions;

    invoke-virtual {p2}, Lio/flutter/plugins/localauth/Messages$AuthOptions;->toList()Ljava/util/ArrayList;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/localauth/Messages$PigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 540
    :cond_6
    invoke-super {p0, p1, p2}, Lio/flutter/plugin/common/StandardMessageCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void
.end method
