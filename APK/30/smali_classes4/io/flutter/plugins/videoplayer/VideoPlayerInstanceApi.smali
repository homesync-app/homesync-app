.class public interface abstract Lio/flutter/plugins/videoplayer/VideoPlayerInstanceApi;
.super Ljava/lang/Object;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/videoplayer/VideoPlayerInstanceApi$Companion;
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u00000\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0010\u000b\n\u0002\u0008\u0002\n\u0002\u0010\u0006\n\u0002\u0008\u0006\n\u0002\u0010\t\n\u0002\u0008\u0003\n\u0002\u0018\u0002\n\u0002\u0008\u0005\u0008f\u0018\u0000 \u00172\u00020\u0001:\u0001\u0017J\u0010\u0010\u0002\u001a\u00020\u00032\u0006\u0010\u0004\u001a\u00020\u0005H&J\u0010\u0010\u0006\u001a\u00020\u00032\u0006\u0010\u0007\u001a\u00020\u0008H&J\u0010\u0010\t\u001a\u00020\u00032\u0006\u0010\n\u001a\u00020\u0008H&J\u0008\u0010\u000b\u001a\u00020\u0003H&J\u0008\u0010\u000c\u001a\u00020\u0003H&J\u0010\u0010\r\u001a\u00020\u00032\u0006\u0010\u000e\u001a\u00020\u000fH&J\u0008\u0010\u0010\u001a\u00020\u000fH&J\u0008\u0010\u0011\u001a\u00020\u000fH&J\u0008\u0010\u0012\u001a\u00020\u0013H&J\u0018\u0010\u0014\u001a\u00020\u00032\u0006\u0010\u0015\u001a\u00020\u000f2\u0006\u0010\u0016\u001a\u00020\u000fH&\u00a8\u0006\u0018\u00c0\u0006\u0003"
    }
    d2 = {
        "Lio/flutter/plugins/videoplayer/VideoPlayerInstanceApi;",
        "",
        "setLooping",
        "",
        "looping",
        "",
        "setVolume",
        "volume",
        "",
        "setPlaybackSpeed",
        "speed",
        "play",
        "pause",
        "seekTo",
        "position",
        "",
        "getCurrentPosition",
        "getBufferedPosition",
        "getAudioTracks",
        "Lio/flutter/plugins/videoplayer/NativeAudioTrackData;",
        "selectAudioTrack",
        "groupIndex",
        "trackIndex",
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
.field public static final Companion:Lio/flutter/plugins/videoplayer/VideoPlayerInstanceApi$Companion;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    sget-object v0, Lio/flutter/plugins/videoplayer/VideoPlayerInstanceApi$Companion;->$$INSTANCE:Lio/flutter/plugins/videoplayer/VideoPlayerInstanceApi$Companion;

    sput-object v0, Lio/flutter/plugins/videoplayer/VideoPlayerInstanceApi;->Companion:Lio/flutter/plugins/videoplayer/VideoPlayerInstanceApi$Companion;

    return-void
.end method


# virtual methods
.method public abstract getAudioTracks()Lio/flutter/plugins/videoplayer/NativeAudioTrackData;
.end method

.method public abstract getBufferedPosition()J
.end method

.method public abstract getCurrentPosition()J
.end method

.method public abstract pause()V
.end method

.method public abstract play()V
.end method

.method public abstract seekTo(J)V
.end method

.method public abstract selectAudioTrack(JJ)V
.end method

.method public abstract setLooping(Z)V
.end method

.method public abstract setPlaybackSpeed(D)V
.end method

.method public abstract setVolume(D)V
.end method
