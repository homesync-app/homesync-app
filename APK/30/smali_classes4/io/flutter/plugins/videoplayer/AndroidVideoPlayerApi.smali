.class public interface abstract Lio/flutter/plugins/videoplayer/AndroidVideoPlayerApi;
.super Ljava/lang/Object;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/videoplayer/AndroidVideoPlayerApi$Companion;
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u00002\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0010\t\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0008\u0004\n\u0002\u0010\u000b\n\u0000\n\u0002\u0010\u000e\n\u0002\u0008\u0004\u0008f\u0018\u0000 \u00132\u00020\u0001:\u0001\u0013J\u0008\u0010\u0002\u001a\u00020\u0003H&J\u0010\u0010\u0004\u001a\u00020\u00052\u0006\u0010\u0006\u001a\u00020\u0007H&J\u0010\u0010\u0008\u001a\u00020\t2\u0006\u0010\u0006\u001a\u00020\u0007H&J\u0010\u0010\n\u001a\u00020\u00032\u0006\u0010\u000b\u001a\u00020\u0005H&J\u0010\u0010\u000c\u001a\u00020\u00032\u0006\u0010\r\u001a\u00020\u000eH&J\u001a\u0010\u000f\u001a\u00020\u00102\u0006\u0010\u0011\u001a\u00020\u00102\u0008\u0010\u0012\u001a\u0004\u0018\u00010\u0010H&\u00a8\u0006\u0014\u00c0\u0006\u0003"
    }
    d2 = {
        "Lio/flutter/plugins/videoplayer/AndroidVideoPlayerApi;",
        "",
        "initialize",
        "",
        "createForPlatformView",
        "",
        "options",
        "Lio/flutter/plugins/videoplayer/CreationOptions;",
        "createForTextureView",
        "Lio/flutter/plugins/videoplayer/TexturePlayerIds;",
        "dispose",
        "playerId",
        "setMixWithOthers",
        "mixWithOthers",
        "",
        "getLookupKeyForAsset",
        "",
        "asset",
        "packageName",
        "Companion",
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


# static fields
.field public static final Companion:Lio/flutter/plugins/videoplayer/AndroidVideoPlayerApi$Companion;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    sget-object v0, Lio/flutter/plugins/videoplayer/AndroidVideoPlayerApi$Companion;->$$INSTANCE:Lio/flutter/plugins/videoplayer/AndroidVideoPlayerApi$Companion;

    sput-object v0, Lio/flutter/plugins/videoplayer/AndroidVideoPlayerApi;->Companion:Lio/flutter/plugins/videoplayer/AndroidVideoPlayerApi$Companion;

    return-void
.end method


# virtual methods
.method public abstract createForPlatformView(Lio/flutter/plugins/videoplayer/CreationOptions;)J
.end method

.method public abstract createForTextureView(Lio/flutter/plugins/videoplayer/CreationOptions;)Lio/flutter/plugins/videoplayer/TexturePlayerIds;
.end method

.method public abstract dispose(J)V
.end method

.method public abstract getLookupKeyForAsset(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
.end method

.method public abstract initialize()V
.end method

.method public abstract setMixWithOthers(Z)V
.end method
