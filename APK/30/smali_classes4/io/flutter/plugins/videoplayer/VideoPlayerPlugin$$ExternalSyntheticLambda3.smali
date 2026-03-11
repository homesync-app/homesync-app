.class public final synthetic Lio/flutter/plugins/videoplayer/VideoPlayerPlugin$$ExternalSyntheticLambda3;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Lio/flutter/plugins/videoplayer/platformview/PlatformVideoViewFactory$VideoPlayerProvider;


# instance fields
.field public final synthetic f$0:Landroid/util/LongSparseArray;


# direct methods
.method public synthetic constructor <init>(Landroid/util/LongSparseArray;)V
    .locals 0

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lio/flutter/plugins/videoplayer/VideoPlayerPlugin$$ExternalSyntheticLambda3;->f$0:Landroid/util/LongSparseArray;

    return-void
.end method


# virtual methods
.method public final getVideoPlayer(Ljava/lang/Long;)Lio/flutter/plugins/videoplayer/VideoPlayer;
    .locals 3

    .line 0
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/VideoPlayerPlugin$$ExternalSyntheticLambda3;->f$0:Landroid/util/LongSparseArray;

    invoke-virtual {p1}, Ljava/lang/Long;->longValue()J

    move-result-wide v1

    invoke-static {v0, v1, v2}, Lio/flutter/plugins/videoplayer/VideoPlayerPlugin;->$r8$lambda$xTK0yD7tRFgN4EEguUYNac_1BnM(Landroid/util/LongSparseArray;J)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Lio/flutter/plugins/videoplayer/VideoPlayer;

    return-object p1
.end method
