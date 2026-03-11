.class final Lio/flutter/plugins/videoplayer/QueuingEventSink;
.super Ljava/lang/Object;
.source "QueuingEventSink.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/videoplayer/QueuingEventSink$EndOfStreamEvent;,
        Lio/flutter/plugins/videoplayer/QueuingEventSink$ErrorEvent;
    }
.end annotation


# instance fields
.field private delegate:Lio/flutter/plugins/videoplayer/PigeonEventSink;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lio/flutter/plugins/videoplayer/PigeonEventSink<",
            "Lio/flutter/plugins/videoplayer/PlatformVideoEvent;",
            ">;"
        }
    .end annotation
.end field

.field private done:Z

.field private final eventQueue:Ljava/util/ArrayList;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/ArrayList<",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method constructor <init>()V
    .locals 1

    .line 18
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 20
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lio/flutter/plugins/videoplayer/QueuingEventSink;->eventQueue:Ljava/util/ArrayList;

    const/4 v0, 0x0

    .line 21
    iput-boolean v0, p0, Lio/flutter/plugins/videoplayer/QueuingEventSink;->done:Z

    return-void
.end method

.method private enqueue(Ljava/lang/Object;)V
    .locals 1

    .line 45
    iget-boolean v0, p0, Lio/flutter/plugins/videoplayer/QueuingEventSink;->done:Z

    if-eqz v0, :cond_0

    return-void

    .line 48
    :cond_0
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/QueuingEventSink;->eventQueue:Ljava/util/ArrayList;

    invoke-virtual {v0, p1}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    return-void
.end method

.method private maybeFlush()V
    .locals 5

    .line 52
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/QueuingEventSink;->delegate:Lio/flutter/plugins/videoplayer/PigeonEventSink;

    if-nez v0, :cond_0

    return-void

    .line 55
    :cond_0
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/QueuingEventSink;->eventQueue:Ljava/util/ArrayList;

    invoke-virtual {v0}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_3

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    .line 56
    instance-of v2, v1, Lio/flutter/plugins/videoplayer/QueuingEventSink$EndOfStreamEvent;

    if-eqz v2, :cond_1

    .line 57
    iget-object v1, p0, Lio/flutter/plugins/videoplayer/QueuingEventSink;->delegate:Lio/flutter/plugins/videoplayer/PigeonEventSink;

    invoke-virtual {v1}, Lio/flutter/plugins/videoplayer/PigeonEventSink;->endOfStream()V

    goto :goto_0

    .line 58
    :cond_1
    instance-of v2, v1, Lio/flutter/plugins/videoplayer/QueuingEventSink$ErrorEvent;

    if-eqz v2, :cond_2

    .line 59
    check-cast v1, Lio/flutter/plugins/videoplayer/QueuingEventSink$ErrorEvent;

    .line 60
    iget-object v2, p0, Lio/flutter/plugins/videoplayer/QueuingEventSink;->delegate:Lio/flutter/plugins/videoplayer/PigeonEventSink;

    iget-object v3, v1, Lio/flutter/plugins/videoplayer/QueuingEventSink$ErrorEvent;->code:Ljava/lang/String;

    iget-object v4, v1, Lio/flutter/plugins/videoplayer/QueuingEventSink$ErrorEvent;->message:Ljava/lang/String;

    iget-object v1, v1, Lio/flutter/plugins/videoplayer/QueuingEventSink$ErrorEvent;->details:Ljava/lang/Object;

    invoke-virtual {v2, v3, v4, v1}, Lio/flutter/plugins/videoplayer/PigeonEventSink;->error(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V

    goto :goto_0

    .line 62
    :cond_2
    iget-object v2, p0, Lio/flutter/plugins/videoplayer/QueuingEventSink;->delegate:Lio/flutter/plugins/videoplayer/PigeonEventSink;

    check-cast v1, Lio/flutter/plugins/videoplayer/PlatformVideoEvent;

    invoke-virtual {v2, v1}, Lio/flutter/plugins/videoplayer/PigeonEventSink;->success(Ljava/lang/Object;)V

    goto :goto_0

    .line 65
    :cond_3
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/QueuingEventSink;->eventQueue:Ljava/util/ArrayList;

    invoke-virtual {v0}, Ljava/util/ArrayList;->clear()V

    return-void
.end method


# virtual methods
.method public endOfStream()V
    .locals 1

    .line 29
    new-instance v0, Lio/flutter/plugins/videoplayer/QueuingEventSink$EndOfStreamEvent;

    invoke-direct {v0}, Lio/flutter/plugins/videoplayer/QueuingEventSink$EndOfStreamEvent;-><init>()V

    invoke-direct {p0, v0}, Lio/flutter/plugins/videoplayer/QueuingEventSink;->enqueue(Ljava/lang/Object;)V

    .line 30
    invoke-direct {p0}, Lio/flutter/plugins/videoplayer/QueuingEventSink;->maybeFlush()V

    const/4 v0, 0x1

    .line 31
    iput-boolean v0, p0, Lio/flutter/plugins/videoplayer/QueuingEventSink;->done:Z

    return-void
.end method

.method public error(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V
    .locals 1

    .line 35
    new-instance v0, Lio/flutter/plugins/videoplayer/QueuingEventSink$ErrorEvent;

    invoke-direct {v0, p1, p2, p3}, Lio/flutter/plugins/videoplayer/QueuingEventSink$ErrorEvent;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V

    invoke-direct {p0, v0}, Lio/flutter/plugins/videoplayer/QueuingEventSink;->enqueue(Ljava/lang/Object;)V

    .line 36
    invoke-direct {p0}, Lio/flutter/plugins/videoplayer/QueuingEventSink;->maybeFlush()V

    return-void
.end method

.method public setDelegate(Lio/flutter/plugins/videoplayer/PigeonEventSink;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lio/flutter/plugins/videoplayer/PigeonEventSink<",
            "Lio/flutter/plugins/videoplayer/PlatformVideoEvent;",
            ">;)V"
        }
    .end annotation

    .line 24
    iput-object p1, p0, Lio/flutter/plugins/videoplayer/QueuingEventSink;->delegate:Lio/flutter/plugins/videoplayer/PigeonEventSink;

    .line 25
    invoke-direct {p0}, Lio/flutter/plugins/videoplayer/QueuingEventSink;->maybeFlush()V

    return-void
.end method

.method public success(Lio/flutter/plugins/videoplayer/PlatformVideoEvent;)V
    .locals 0

    .line 40
    invoke-direct {p0, p1}, Lio/flutter/plugins/videoplayer/QueuingEventSink;->enqueue(Ljava/lang/Object;)V

    .line 41
    invoke-direct {p0}, Lio/flutter/plugins/videoplayer/QueuingEventSink;->maybeFlush()V

    return-void
.end method
