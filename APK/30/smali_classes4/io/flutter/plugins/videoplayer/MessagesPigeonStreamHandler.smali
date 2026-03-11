.class final Lio/flutter/plugins/videoplayer/MessagesPigeonStreamHandler;
.super Ljava/lang/Object;
.source "Messages.kt"

# interfaces
.implements Lio/flutter/plugin/common/EventChannel$StreamHandler;


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "<T:",
        "Ljava/lang/Object;",
        ">",
        "Ljava/lang/Object;",
        "Lio/flutter/plugin/common/EventChannel$StreamHandler;"
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u00000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0008\u0005\n\u0002\u0018\u0002\n\u0002\u0008\u0005\n\u0002\u0010\u0002\n\u0000\n\u0002\u0010\u0000\n\u0000\n\u0002\u0018\u0002\n\u0002\u0008\u0002\u0008\u0002\u0018\u0000*\u0004\u0008\u0000\u0010\u00012\u00020\u0002B\u0015\u0012\u000c\u0010\u0003\u001a\u0008\u0012\u0004\u0012\u00028\u00000\u0004\u00a2\u0006\u0004\u0008\u0005\u0010\u0006J\u001a\u0010\u000f\u001a\u00020\u00102\u0008\u0010\u0011\u001a\u0004\u0018\u00010\u00122\u0006\u0010\u0013\u001a\u00020\u0014H\u0016J\u0012\u0010\u0015\u001a\u00020\u00102\u0008\u0010\u0011\u001a\u0004\u0018\u00010\u0012H\u0016R\u0017\u0010\u0003\u001a\u0008\u0012\u0004\u0012\u00028\u00000\u0004\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0007\u0010\u0008R\"\u0010\t\u001a\n\u0012\u0004\u0012\u00028\u0000\u0018\u00010\nX\u0086\u000e\u00a2\u0006\u000e\n\u0000\u001a\u0004\u0008\u000b\u0010\u000c\"\u0004\u0008\r\u0010\u000e\u00a8\u0006\u0016"
    }
    d2 = {
        "Lio/flutter/plugins/videoplayer/MessagesPigeonStreamHandler;",
        "T",
        "Lio/flutter/plugin/common/EventChannel$StreamHandler;",
        "wrapper",
        "Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;",
        "<init>",
        "(Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;)V",
        "getWrapper",
        "()Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;",
        "pigeonSink",
        "Lio/flutter/plugins/videoplayer/PigeonEventSink;",
        "getPigeonSink",
        "()Lio/flutter/plugins/videoplayer/PigeonEventSink;",
        "setPigeonSink",
        "(Lio/flutter/plugins/videoplayer/PigeonEventSink;)V",
        "onListen",
        "",
        "p0",
        "",
        "sink",
        "Lio/flutter/plugin/common/EventChannel$EventSink;",
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


# instance fields
.field private pigeonSink:Lio/flutter/plugins/videoplayer/PigeonEventSink;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lio/flutter/plugins/videoplayer/PigeonEventSink<",
            "TT;>;"
        }
    .end annotation
.end field

.field private final wrapper:Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper<",
            "TT;>;"
        }
    .end annotation
.end field


# direct methods
.method public constructor <init>(Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper<",
            "TT;>;)V"
        }
    .end annotation

    const-string v0, "wrapper"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 1095
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lio/flutter/plugins/videoplayer/MessagesPigeonStreamHandler;->wrapper:Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;

    return-void
.end method


# virtual methods
.method public final getPigeonSink()Lio/flutter/plugins/videoplayer/PigeonEventSink;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Lio/flutter/plugins/videoplayer/PigeonEventSink<",
            "TT;>;"
        }
    .end annotation

    .line 1097
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/MessagesPigeonStreamHandler;->pigeonSink:Lio/flutter/plugins/videoplayer/PigeonEventSink;

    return-object v0
.end method

.method public final getWrapper()Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper<",
            "TT;>;"
        }
    .end annotation

    .line 1095
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/MessagesPigeonStreamHandler;->wrapper:Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;

    return-object v0
.end method

.method public onCancel(Ljava/lang/Object;)V
    .locals 1

    const/4 v0, 0x0

    .line 1105
    iput-object v0, p0, Lio/flutter/plugins/videoplayer/MessagesPigeonStreamHandler;->pigeonSink:Lio/flutter/plugins/videoplayer/PigeonEventSink;

    .line 1106
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/MessagesPigeonStreamHandler;->wrapper:Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;

    invoke-interface {v0, p1}, Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;->onCancel(Ljava/lang/Object;)V

    return-void
.end method

.method public onListen(Ljava/lang/Object;Lio/flutter/plugin/common/EventChannel$EventSink;)V
    .locals 1

    const-string v0, "sink"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 1100
    new-instance v0, Lio/flutter/plugins/videoplayer/PigeonEventSink;

    invoke-direct {v0, p2}, Lio/flutter/plugins/videoplayer/PigeonEventSink;-><init>(Lio/flutter/plugin/common/EventChannel$EventSink;)V

    iput-object v0, p0, Lio/flutter/plugins/videoplayer/MessagesPigeonStreamHandler;->pigeonSink:Lio/flutter/plugins/videoplayer/PigeonEventSink;

    .line 1101
    iget-object p2, p0, Lio/flutter/plugins/videoplayer/MessagesPigeonStreamHandler;->wrapper:Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;

    invoke-static {v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNull(Ljava/lang/Object;)V

    invoke-interface {p2, p1, v0}, Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;->onListen(Ljava/lang/Object;Lio/flutter/plugins/videoplayer/PigeonEventSink;)V

    return-void
.end method

.method public final setPigeonSink(Lio/flutter/plugins/videoplayer/PigeonEventSink;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lio/flutter/plugins/videoplayer/PigeonEventSink<",
            "TT;>;)V"
        }
    .end annotation

    .line 1097
    iput-object p1, p0, Lio/flutter/plugins/videoplayer/MessagesPigeonStreamHandler;->pigeonSink:Lio/flutter/plugins/videoplayer/PigeonEventSink;

    return-void
.end method
