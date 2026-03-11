.class public interface abstract Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;
.super Ljava/lang/Object;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper$DefaultImpls;
    }
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "<T:",
        "Ljava/lang/Object;",
        ">",
        "Ljava/lang/Object;"
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000\u001c\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u0002\n\u0002\u0008\u0002\n\u0002\u0018\u0002\n\u0002\u0008\u0002\u0008f\u0018\u0000*\u0004\u0008\u0000\u0010\u00012\u00020\u0002J \u0010\u0003\u001a\u00020\u00042\u0008\u0010\u0005\u001a\u0004\u0018\u00010\u00022\u000c\u0010\u0006\u001a\u0008\u0012\u0004\u0012\u00028\u00000\u0007H\u0016J\u0012\u0010\u0008\u001a\u00020\u00042\u0008\u0010\u0005\u001a\u0004\u0018\u00010\u0002H\u0016\u00a8\u0006\t\u00c0\u0006\u0003"
    }
    d2 = {
        "Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;",
        "T",
        "",
        "onListen",
        "",
        "p0",
        "sink",
        "Lio/flutter/plugins/videoplayer/PigeonEventSink;",
        "onCancel",
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
.method public static synthetic access$onCancel$jd(Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;Ljava/lang/Object;)V
    .locals 0

    .line 1110
    invoke-super {p0, p1}, Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;->onCancel(Ljava/lang/Object;)V

    return-void
.end method

.method public static synthetic access$onListen$jd(Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;Ljava/lang/Object;Lio/flutter/plugins/videoplayer/PigeonEventSink;)V
    .locals 0

    .line 1110
    invoke-super {p0, p1, p2}, Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;->onListen(Ljava/lang/Object;Lio/flutter/plugins/videoplayer/PigeonEventSink;)V

    return-void
.end method


# virtual methods
.method public onCancel(Ljava/lang/Object;)V
    .locals 0

    return-void
.end method

.method public onListen(Ljava/lang/Object;Lio/flutter/plugins/videoplayer/PigeonEventSink;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/Object;",
            "Lio/flutter/plugins/videoplayer/PigeonEventSink<",
            "TT;>;)V"
        }
    .end annotation

    const-string p1, "sink"

    invoke-static {p2, p1}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    return-void
.end method
