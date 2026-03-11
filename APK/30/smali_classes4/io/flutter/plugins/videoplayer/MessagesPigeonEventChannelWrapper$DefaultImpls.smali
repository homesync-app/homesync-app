.class public final Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper$DefaultImpls;
.super Ljava/lang/Object;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "DefaultImpls"
.end annotation

.annotation runtime Lkotlin/Metadata;
    k = 0x3
    mv = {
        0x2,
        0x2,
        0x0
    }
    xi = 0x30
.end annotation


# direct methods
.method public static onCancel(Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;Ljava/lang/Object;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<T:",
            "Ljava/lang/Object;",
            ">(",
            "Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper<",
            "TT;>;",
            "Ljava/lang/Object;",
            ")V"
        }
    .end annotation

    .annotation runtime Ljava/lang/Deprecated;
    .end annotation

    .line 1113
    invoke-static {p0, p1}, Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;->access$onCancel$jd(Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;Ljava/lang/Object;)V

    return-void
.end method

.method public static onListen(Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;Ljava/lang/Object;Lio/flutter/plugins/videoplayer/PigeonEventSink;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<T:",
            "Ljava/lang/Object;",
            ">(",
            "Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper<",
            "TT;>;",
            "Ljava/lang/Object;",
            "Lio/flutter/plugins/videoplayer/PigeonEventSink<",
            "TT;>;)V"
        }
    .end annotation

    .annotation runtime Ljava/lang/Deprecated;
    .end annotation

    const-string v0, "sink"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 1111
    invoke-static {p0, p1, p2}, Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;->access$onListen$jd(Lio/flutter/plugins/videoplayer/MessagesPigeonEventChannelWrapper;Ljava/lang/Object;Lio/flutter/plugins/videoplayer/PigeonEventSink;)V

    return-void
.end method
