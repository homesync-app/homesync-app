.class Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;
.super Lio/flutter/plugin/common/StandardMessageCodec;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/SourceDebugExtension;
    value = "SMAP\nMessages.kt\nKotlin\n*S Kotlin\n*F\n+ 1 Messages.kt\nio/flutter/plugins/googlesignin/MessagesPigeonCodec\n+ 2 fake.kt\nkotlin/jvm/internal/FakeKt\n*L\n1#1,827:1\n1#2:828\n*E\n"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000,\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0008\u0003\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u0005\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0008\u0002\u0008\u0012\u0018\u00002\u00020\u0001B\u0007\u00a2\u0006\u0004\u0008\u0002\u0010\u0003J\u001a\u0010\u0004\u001a\u0004\u0018\u00010\u00052\u0006\u0010\u0006\u001a\u00020\u00072\u0006\u0010\u0008\u001a\u00020\tH\u0014J\u001a\u0010\n\u001a\u00020\u000b2\u0006\u0010\u000c\u001a\u00020\r2\u0008\u0010\u000e\u001a\u0004\u0018\u00010\u0005H\u0014\u00a8\u0006\u000f"
    }
    d2 = {
        "Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;",
        "Lio/flutter/plugin/common/StandardMessageCodec;",
        "<init>",
        "()V",
        "readValueOfType",
        "",
        "type",
        "",
        "buffer",
        "Ljava/nio/ByteBuffer;",
        "writeValue",
        "",
        "stream",
        "Ljava/io/ByteArrayOutputStream;",
        "value",
        "google_sign_in_android_release"
    }
    k = 0x1
    mv = {
        0x2,
        0x2,
        0x0
    }
    xi = 0x30
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 554
    invoke-direct {p0}, Lio/flutter/plugin/common/StandardMessageCodec;-><init>()V

    return-void
.end method


# virtual methods
.method protected readValueOfType(BLjava/nio/ByteBuffer;)Ljava/lang/Object;
    .locals 2

    const-string v0, "buffer"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const/16 v0, -0x7f

    const/4 v1, 0x0

    if-ne p1, v0, :cond_1

    .line 558
    invoke-virtual {p0, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/Long;

    if-eqz p1, :cond_0

    check-cast p1, Ljava/lang/Number;

    invoke-virtual {p1}, Ljava/lang/Number;->longValue()J

    move-result-wide p1

    sget-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->Companion:Lio/flutter/plugins/googlesignin/GetCredentialFailureType$Companion;

    long-to-int p1, p1

    invoke-virtual {v0, p1}, Lio/flutter/plugins/googlesignin/GetCredentialFailureType$Companion;->ofRaw(I)Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    move-result-object p1

    return-object p1

    :cond_0
    return-object v1

    :cond_1
    const/16 v0, -0x7e

    if-ne p1, v0, :cond_3

    .line 561
    invoke-virtual {p0, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/Long;

    if-eqz p1, :cond_2

    check-cast p1, Ljava/lang/Number;

    invoke-virtual {p1}, Ljava/lang/Number;->longValue()J

    move-result-wide p1

    sget-object v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->Companion:Lio/flutter/plugins/googlesignin/AuthorizeFailureType$Companion;

    long-to-int p1, p1

    invoke-virtual {v0, p1}, Lio/flutter/plugins/googlesignin/AuthorizeFailureType$Companion;->ofRaw(I)Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    move-result-object p1

    return-object p1

    :cond_2
    return-object v1

    :cond_3
    const/16 v0, -0x7d

    if-ne p1, v0, :cond_6

    .line 564
    invoke-virtual {p0, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    instance-of p2, p1, Ljava/util/List;

    if-eqz p2, :cond_4

    check-cast p1, Ljava/util/List;

    goto :goto_0

    :cond_4
    move-object p1, v1

    :goto_0
    if-eqz p1, :cond_5

    sget-object p2, Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest;->Companion:Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest$Companion;

    invoke-virtual {p2, p1}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest$Companion;->fromList(Ljava/util/List;)Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest;

    move-result-object p1

    return-object p1

    :cond_5
    return-object v1

    :cond_6
    const/16 v0, -0x7c

    if-ne p1, v0, :cond_9

    .line 567
    invoke-virtual {p0, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    instance-of p2, p1, Ljava/util/List;

    if-eqz p2, :cond_7

    check-cast p1, Ljava/util/List;

    goto :goto_1

    :cond_7
    move-object p1, v1

    :goto_1
    if-eqz p1, :cond_8

    sget-object p2, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->Companion:Lio/flutter/plugins/googlesignin/GetCredentialRequestParams$Companion;

    invoke-virtual {p2, p1}, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams$Companion;->fromList(Ljava/util/List;)Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;

    move-result-object p1

    return-object p1

    :cond_8
    return-object v1

    :cond_9
    const/16 v0, -0x7b

    if-ne p1, v0, :cond_c

    .line 570
    invoke-virtual {p0, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    instance-of p2, p1, Ljava/util/List;

    if-eqz p2, :cond_a

    check-cast p1, Ljava/util/List;

    goto :goto_2

    :cond_a
    move-object p1, v1

    :goto_2
    if-eqz p1, :cond_b

    .line 571
    sget-object p2, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->Companion:Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams$Companion;

    invoke-virtual {p2, p1}, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams$Companion;->fromList(Ljava/util/List;)Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;

    move-result-object p1

    return-object p1

    :cond_b
    return-object v1

    :cond_c
    const/16 v0, -0x7a

    if-ne p1, v0, :cond_f

    .line 575
    invoke-virtual {p0, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    instance-of p2, p1, Ljava/util/List;

    if-eqz p2, :cond_d

    check-cast p1, Ljava/util/List;

    goto :goto_3

    :cond_d
    move-object p1, v1

    :goto_3
    if-eqz p1, :cond_e

    sget-object p2, Lio/flutter/plugins/googlesignin/PlatformRevokeAccessRequest;->Companion:Lio/flutter/plugins/googlesignin/PlatformRevokeAccessRequest$Companion;

    invoke-virtual {p2, p1}, Lio/flutter/plugins/googlesignin/PlatformRevokeAccessRequest$Companion;->fromList(Ljava/util/List;)Lio/flutter/plugins/googlesignin/PlatformRevokeAccessRequest;

    move-result-object p1

    return-object p1

    :cond_e
    return-object v1

    :cond_f
    const/16 v0, -0x79

    if-ne p1, v0, :cond_12

    .line 578
    invoke-virtual {p0, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    instance-of p2, p1, Ljava/util/List;

    if-eqz p2, :cond_10

    check-cast p1, Ljava/util/List;

    goto :goto_4

    :cond_10
    move-object p1, v1

    :goto_4
    if-eqz p1, :cond_11

    .line 579
    sget-object p2, Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;->Companion:Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential$Companion;

    invoke-virtual {p2, p1}, Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential$Companion;->fromList(Ljava/util/List;)Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;

    move-result-object p1

    return-object p1

    :cond_11
    return-object v1

    :cond_12
    const/16 v0, -0x78

    if-ne p1, v0, :cond_15

    .line 583
    invoke-virtual {p0, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    instance-of p2, p1, Ljava/util/List;

    if-eqz p2, :cond_13

    check-cast p1, Ljava/util/List;

    goto :goto_5

    :cond_13
    move-object p1, v1

    :goto_5
    if-eqz p1, :cond_14

    sget-object p2, Lio/flutter/plugins/googlesignin/GetCredentialFailure;->Companion:Lio/flutter/plugins/googlesignin/GetCredentialFailure$Companion;

    invoke-virtual {p2, p1}, Lio/flutter/plugins/googlesignin/GetCredentialFailure$Companion;->fromList(Ljava/util/List;)Lio/flutter/plugins/googlesignin/GetCredentialFailure;

    move-result-object p1

    return-object p1

    :cond_14
    return-object v1

    :cond_15
    const/16 v0, -0x77

    if-ne p1, v0, :cond_18

    .line 586
    invoke-virtual {p0, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    instance-of p2, p1, Ljava/util/List;

    if-eqz p2, :cond_16

    check-cast p1, Ljava/util/List;

    goto :goto_6

    :cond_16
    move-object p1, v1

    :goto_6
    if-eqz p1, :cond_17

    sget-object p2, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;->Companion:Lio/flutter/plugins/googlesignin/GetCredentialSuccess$Companion;

    invoke-virtual {p2, p1}, Lio/flutter/plugins/googlesignin/GetCredentialSuccess$Companion;->fromList(Ljava/util/List;)Lio/flutter/plugins/googlesignin/GetCredentialSuccess;

    move-result-object p1

    return-object p1

    :cond_17
    return-object v1

    :cond_18
    const/16 v0, -0x76

    if-ne p1, v0, :cond_1b

    .line 589
    invoke-virtual {p0, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    instance-of p2, p1, Ljava/util/List;

    if-eqz p2, :cond_19

    check-cast p1, Ljava/util/List;

    goto :goto_7

    :cond_19
    move-object p1, v1

    :goto_7
    if-eqz p1, :cond_1a

    sget-object p2, Lio/flutter/plugins/googlesignin/AuthorizeFailure;->Companion:Lio/flutter/plugins/googlesignin/AuthorizeFailure$Companion;

    invoke-virtual {p2, p1}, Lio/flutter/plugins/googlesignin/AuthorizeFailure$Companion;->fromList(Ljava/util/List;)Lio/flutter/plugins/googlesignin/AuthorizeFailure;

    move-result-object p1

    return-object p1

    :cond_1a
    return-object v1

    :cond_1b
    const/16 v0, -0x75

    if-ne p1, v0, :cond_1e

    .line 592
    invoke-virtual {p0, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->readValue(Ljava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    instance-of p2, p1, Ljava/util/List;

    if-eqz p2, :cond_1c

    check-cast p1, Ljava/util/List;

    goto :goto_8

    :cond_1c
    move-object p1, v1

    :goto_8
    if-eqz p1, :cond_1d

    sget-object p2, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->Companion:Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult$Companion;

    invoke-virtual {p2, p1}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult$Companion;->fromList(Ljava/util/List;)Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;

    move-result-object p1

    return-object p1

    :cond_1d
    return-object v1

    .line 594
    :cond_1e
    invoke-super {p0, p1, p2}, Lio/flutter/plugin/common/StandardMessageCodec;->readValueOfType(BLjava/nio/ByteBuffer;)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method

.method protected writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V
    .locals 2

    const-string v0, "stream"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 600
    instance-of v0, p2, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    if-eqz v0, :cond_0

    const/16 v0, 0x81

    .line 601
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 602
    check-cast p2, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    invoke-virtual {p2}, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->getRaw()I

    move-result p2

    int-to-long v0, p2

    invoke-static {v0, v1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 604
    :cond_0
    instance-of v0, p2, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    if-eqz v0, :cond_1

    const/16 v0, 0x82

    .line 605
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 606
    check-cast p2, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    invoke-virtual {p2}, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->getRaw()I

    move-result p2

    int-to-long v0, p2

    invoke-static {v0, v1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 608
    :cond_1
    instance-of v0, p2, Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest;

    if-eqz v0, :cond_2

    const/16 v0, 0x83

    .line 609
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 610
    check-cast p2, Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest;

    invoke-virtual {p2}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationRequest;->toList()Ljava/util/List;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 612
    :cond_2
    instance-of v0, p2, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;

    if-eqz v0, :cond_3

    const/16 v0, 0x84

    .line 613
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 614
    check-cast p2, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;

    invoke-virtual {p2}, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->toList()Ljava/util/List;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 616
    :cond_3
    instance-of v0, p2, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;

    if-eqz v0, :cond_4

    const/16 v0, 0x85

    .line 617
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 618
    check-cast p2, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;

    invoke-virtual {p2}, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->toList()Ljava/util/List;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 620
    :cond_4
    instance-of v0, p2, Lio/flutter/plugins/googlesignin/PlatformRevokeAccessRequest;

    if-eqz v0, :cond_5

    const/16 v0, 0x86

    .line 621
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 622
    check-cast p2, Lio/flutter/plugins/googlesignin/PlatformRevokeAccessRequest;

    invoke-virtual {p2}, Lio/flutter/plugins/googlesignin/PlatformRevokeAccessRequest;->toList()Ljava/util/List;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 624
    :cond_5
    instance-of v0, p2, Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;

    if-eqz v0, :cond_6

    const/16 v0, 0x87

    .line 625
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 626
    check-cast p2, Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;

    invoke-virtual {p2}, Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;->toList()Ljava/util/List;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 628
    :cond_6
    instance-of v0, p2, Lio/flutter/plugins/googlesignin/GetCredentialFailure;

    if-eqz v0, :cond_7

    const/16 v0, 0x88

    .line 629
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 630
    check-cast p2, Lio/flutter/plugins/googlesignin/GetCredentialFailure;

    invoke-virtual {p2}, Lio/flutter/plugins/googlesignin/GetCredentialFailure;->toList()Ljava/util/List;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 632
    :cond_7
    instance-of v0, p2, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;

    if-eqz v0, :cond_8

    const/16 v0, 0x89

    .line 633
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 634
    check-cast p2, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;

    invoke-virtual {p2}, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;->toList()Ljava/util/List;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 636
    :cond_8
    instance-of v0, p2, Lio/flutter/plugins/googlesignin/AuthorizeFailure;

    if-eqz v0, :cond_9

    const/16 v0, 0x8a

    .line 637
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 638
    check-cast p2, Lio/flutter/plugins/googlesignin/AuthorizeFailure;

    invoke-virtual {p2}, Lio/flutter/plugins/googlesignin/AuthorizeFailure;->toList()Ljava/util/List;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 640
    :cond_9
    instance-of v0, p2, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;

    if-eqz v0, :cond_a

    const/16 v0, 0x8b

    .line 641
    invoke-virtual {p1, v0}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 642
    check-cast p2, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;

    invoke-virtual {p2}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->toList()Ljava/util/List;

    move-result-object p2

    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void

    .line 644
    :cond_a
    invoke-super {p0, p1, p2}, Lio/flutter/plugin/common/StandardMessageCodec;->writeValue(Ljava/io/ByteArrayOutputStream;Ljava/lang/Object;)V

    return-void
.end method
