.class public final Lio/flutter/plugins/videoplayer/VideoEventsStreamHandler$Companion;
.super Ljava/lang/Object;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/videoplayer/VideoEventsStreamHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "Companion"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000$\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\u0008\u0003\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u000e\n\u0000\u0008\u0086\u0003\u0018\u00002\u00020\u0001B\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003J \u0010\u0004\u001a\u00020\u00052\u0006\u0010\u0006\u001a\u00020\u00072\u0006\u0010\u0008\u001a\u00020\t2\u0008\u0008\u0002\u0010\n\u001a\u00020\u000b\u00a8\u0006\u000c"
    }
    d2 = {
        "Lio/flutter/plugins/videoplayer/VideoEventsStreamHandler$Companion;",
        "",
        "<init>",
        "()V",
        "register",
        "",
        "messenger",
        "Lio/flutter/plugin/common/BinaryMessenger;",
        "streamHandler",
        "Lio/flutter/plugins/videoplayer/VideoEventsStreamHandler;",
        "instanceName",
        "",
        "video_player_android_release"
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
.method private constructor <init>()V
    .locals 0

    .line 1131
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public synthetic constructor <init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V
    .locals 0

    invoke-direct {p0}, Lio/flutter/plugins/videoplayer/VideoEventsStreamHandler$Companion;-><init>()V

    return-void
.end method

.method public static synthetic register$default(Lio/flutter/plugins/videoplayer/VideoEventsStreamHandler$Companion;Lio/flutter/plugin/common/BinaryMessenger;Lio/flutter/plugins/videoplayer/VideoEventsStreamHandler;Ljava/lang/String;ILjava/lang/Object;)V
    .locals 0

    and-int/lit8 p4, p4, 0x4

    if-eqz p4, :cond_0

    .line 1135
    const-string p3, ""

    .line 1132
    :cond_0
    invoke-virtual {p0, p1, p2, p3}, Lio/flutter/plugins/videoplayer/VideoEventsStreamHandler$Companion;->register(Lio/flutter/plugin/common/BinaryMessenger;Lio/flutter/plugins/videoplayer/VideoEventsStreamHandler;Ljava/lang/String;)V

    return-void
.end method


# virtual methods
.method public final register(Lio/flutter/plugin/common/BinaryMessenger;Lio/flutter/plugins/videoplayer/VideoEventsStreamHandler;Ljava/lang/String;)V
    .locals 2

    const-string v0, "messenger"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "streamHandler"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "instanceName"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 1139
    move-object v0, p3

    check-cast v0, Ljava/lang/CharSequence;

    invoke-interface {v0}, Ljava/lang/CharSequence;->length()I

    move-result v0

    if-lez v0, :cond_0

    .line 1140
    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "dev.flutter.pigeon.video_player_android.VideoEventChannel.videoEvents."

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p3

    invoke-virtual {p3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p3

    goto :goto_0

    .line 1139
    :cond_0
    const-string p3, "dev.flutter.pigeon.video_player_android.VideoEventChannel.videoEvents"

    .line 1142
    :goto_0
    new-instance v0, Lio/flutter/plugins/videoplayer/MessagesPigeonStreamHandler;

    check-cast p2, Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;

    invoke-direct {v0, p2}, Lio/flutter/plugins/videoplayer/MessagesPigeonStreamHandler;-><init>(Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;)V

    .line 1143
    new-instance p2, Lio/flutter/plugin/common/EventChannel;

    invoke-static {}, Lio/flutter/plugins/videoplayer/MessagesKt;->getMessagesPigeonMethodCodec()Lio/flutter/plugin/common/StandardMethodCodec;

    move-result-object v1

    check-cast v1, Lio/flutter/plugin/common/MethodCodec;

    invoke-direct {p2, p1, p3, v1}, Lio/flutter/plugin/common/EventChannel;-><init>(Lio/flutter/plugin/common/BinaryMessenger;Ljava/lang/String;Lio/flutter/plugin/common/MethodCodec;)V

    .line 1144
    check-cast v0, Lio/flutter/plugin/common/EventChannel$StreamHandler;

    invoke-virtual {p2, v0}, Lio/flutter/plugin/common/EventChannel;->setStreamHandler(Lio/flutter/plugin/common/EventChannel$StreamHandler;)V

    return-void
.end method
