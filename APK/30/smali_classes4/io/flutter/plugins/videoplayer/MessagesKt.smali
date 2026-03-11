.class public final Lio/flutter/plugins/videoplayer/MessagesKt;
.super Ljava/lang/Object;
.source "Messages.kt"


# annotations
.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000\n\n\u0000\n\u0002\u0018\u0002\n\u0002\u0008\u0003\"\u0011\u0010\u0000\u001a\u00020\u0001\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0002\u0010\u0003\u00a8\u0006\u0004"
    }
    d2 = {
        "MessagesPigeonMethodCodec",
        "Lio/flutter/plugin/common/StandardMethodCodec;",
        "getMessagesPigeonMethodCodec",
        "()Lio/flutter/plugin/common/StandardMethodCodec;",
        "video_player_android_release"
    }
    k = 0x2
    mv = {
        0x2,
        0x2,
        0x0
    }
    xi = 0x30
.end annotation


# static fields
.field private static final MessagesPigeonMethodCodec:Lio/flutter/plugin/common/StandardMethodCodec;


# direct methods
.method static constructor <clinit>()V
    .locals 2

    .line 667
    new-instance v0, Lio/flutter/plugin/common/StandardMethodCodec;

    new-instance v1, Lio/flutter/plugins/videoplayer/MessagesPigeonCodec;

    invoke-direct {v1}, Lio/flutter/plugins/videoplayer/MessagesPigeonCodec;-><init>()V

    check-cast v1, Lio/flutter/plugin/common/StandardMessageCodec;

    invoke-direct {v0, v1}, Lio/flutter/plugin/common/StandardMethodCodec;-><init>(Lio/flutter/plugin/common/StandardMessageCodec;)V

    sput-object v0, Lio/flutter/plugins/videoplayer/MessagesKt;->MessagesPigeonMethodCodec:Lio/flutter/plugin/common/StandardMethodCodec;

    return-void
.end method

.method public static final getMessagesPigeonMethodCodec()Lio/flutter/plugin/common/StandardMethodCodec;
    .locals 1

    .line 667
    sget-object v0, Lio/flutter/plugins/videoplayer/MessagesKt;->MessagesPigeonMethodCodec:Lio/flutter/plugin/common/StandardMethodCodec;

    return-object v0
.end method
