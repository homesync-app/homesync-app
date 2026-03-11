.class public final synthetic Lio/flutter/plugins/videoplayer/texture/TextureVideoPlayer$$ExternalSyntheticLambda0;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Lio/flutter/plugins/videoplayer/VideoPlayer$ExoPlayerProvider;


# instance fields
.field public final synthetic f$0:Landroid/content/Context;

.field public final synthetic f$1:Lio/flutter/plugins/videoplayer/VideoAsset;


# direct methods
.method public synthetic constructor <init>(Landroid/content/Context;Lio/flutter/plugins/videoplayer/VideoAsset;)V
    .locals 0

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lio/flutter/plugins/videoplayer/texture/TextureVideoPlayer$$ExternalSyntheticLambda0;->f$0:Landroid/content/Context;

    iput-object p2, p0, Lio/flutter/plugins/videoplayer/texture/TextureVideoPlayer$$ExternalSyntheticLambda0;->f$1:Lio/flutter/plugins/videoplayer/VideoAsset;

    return-void
.end method


# virtual methods
.method public final get()Landroidx/media3/exoplayer/ExoPlayer;
    .locals 2

    .line 0
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/texture/TextureVideoPlayer$$ExternalSyntheticLambda0;->f$0:Landroid/content/Context;

    iget-object v1, p0, Lio/flutter/plugins/videoplayer/texture/TextureVideoPlayer$$ExternalSyntheticLambda0;->f$1:Lio/flutter/plugins/videoplayer/VideoAsset;

    invoke-static {v0, v1}, Lio/flutter/plugins/videoplayer/texture/TextureVideoPlayer;->lambda$create$0(Landroid/content/Context;Lio/flutter/plugins/videoplayer/VideoAsset;)Landroidx/media3/exoplayer/ExoPlayer;

    move-result-object v0

    return-object v0
.end method
