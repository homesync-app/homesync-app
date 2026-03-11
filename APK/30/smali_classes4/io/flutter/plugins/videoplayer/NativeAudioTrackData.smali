.class public final Lio/flutter/plugins/videoplayer/NativeAudioTrackData;
.super Ljava/lang/Object;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/videoplayer/NativeAudioTrackData$Companion;
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000.\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010 \n\u0002\u0018\u0002\n\u0002\u0008\u0006\n\u0002\u0010\u000b\n\u0002\u0008\u0002\n\u0002\u0010\u0008\n\u0002\u0008\u0003\n\u0002\u0010\u000e\n\u0002\u0008\u0002\u0008\u0086\u0008\u0018\u0000 \u00132\u00020\u0001:\u0001\u0013B\u0019\u0012\u0010\u0008\u0002\u0010\u0002\u001a\n\u0012\u0004\u0012\u00020\u0004\u0018\u00010\u0003\u00a2\u0006\u0004\u0008\u0005\u0010\u0006J\u000e\u0010\t\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0003J\u0013\u0010\n\u001a\u00020\u000b2\u0008\u0010\u000c\u001a\u0004\u0018\u00010\u0001H\u0096\u0002J\u0008\u0010\r\u001a\u00020\u000eH\u0016J\u0011\u0010\u000f\u001a\n\u0012\u0004\u0012\u00020\u0004\u0018\u00010\u0003H\u00c6\u0003J\u001b\u0010\u0010\u001a\u00020\u00002\u0010\u0008\u0002\u0010\u0002\u001a\n\u0012\u0004\u0012\u00020\u0004\u0018\u00010\u0003H\u00c6\u0001J\t\u0010\u0011\u001a\u00020\u0012H\u00d6\u0001R\u0019\u0010\u0002\u001a\n\u0012\u0004\u0012\u00020\u0004\u0018\u00010\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0007\u0010\u0008\u00a8\u0006\u0014"
    }
    d2 = {
        "Lio/flutter/plugins/videoplayer/NativeAudioTrackData;",
        "",
        "exoPlayerTracks",
        "",
        "Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;",
        "<init>",
        "(Ljava/util/List;)V",
        "getExoPlayerTracks",
        "()Ljava/util/List;",
        "toList",
        "equals",
        "",
        "other",
        "hashCode",
        "",
        "component1",
        "copy",
        "toString",
        "",
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
.field public static final Companion:Lio/flutter/plugins/videoplayer/NativeAudioTrackData$Companion;


# instance fields
.field private final exoPlayerTracks:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List<",
            "Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Lio/flutter/plugins/videoplayer/NativeAudioTrackData$Companion;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Lio/flutter/plugins/videoplayer/NativeAudioTrackData$Companion;-><init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V

    sput-object v0, Lio/flutter/plugins/videoplayer/NativeAudioTrackData;->Companion:Lio/flutter/plugins/videoplayer/NativeAudioTrackData$Companion;

    return-void
.end method

.method public constructor <init>()V
    .locals 2

    const/4 v0, 0x0

    const/4 v1, 0x1

    invoke-direct {p0, v0, v1, v0}, Lio/flutter/plugins/videoplayer/NativeAudioTrackData;-><init>(Ljava/util/List;ILkotlin/jvm/internal/DefaultConstructorMarker;)V

    return-void
.end method

.method public constructor <init>(Ljava/util/List;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;",
            ">;)V"
        }
    .end annotation

    .line 530
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 532
    iput-object p1, p0, Lio/flutter/plugins/videoplayer/NativeAudioTrackData;->exoPlayerTracks:Ljava/util/List;

    return-void
.end method

.method public synthetic constructor <init>(Ljava/util/List;ILkotlin/jvm/internal/DefaultConstructorMarker;)V
    .locals 0

    and-int/lit8 p2, p2, 0x1

    if-eqz p2, :cond_0

    const/4 p1, 0x0

    .line 530
    :cond_0
    invoke-direct {p0, p1}, Lio/flutter/plugins/videoplayer/NativeAudioTrackData;-><init>(Ljava/util/List;)V

    return-void
.end method

.method public static synthetic copy$default(Lio/flutter/plugins/videoplayer/NativeAudioTrackData;Ljava/util/List;ILjava/lang/Object;)Lio/flutter/plugins/videoplayer/NativeAudioTrackData;
    .locals 0

    and-int/lit8 p2, p2, 0x1

    if-eqz p2, :cond_0

    iget-object p1, p0, Lio/flutter/plugins/videoplayer/NativeAudioTrackData;->exoPlayerTracks:Ljava/util/List;

    :cond_0
    invoke-virtual {p0, p1}, Lio/flutter/plugins/videoplayer/NativeAudioTrackData;->copy(Ljava/util/List;)Lio/flutter/plugins/videoplayer/NativeAudioTrackData;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method public final component1()Ljava/util/List;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;",
            ">;"
        }
    .end annotation

    iget-object v0, p0, Lio/flutter/plugins/videoplayer/NativeAudioTrackData;->exoPlayerTracks:Ljava/util/List;

    return-object v0
.end method

.method public final copy(Ljava/util/List;)Lio/flutter/plugins/videoplayer/NativeAudioTrackData;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;",
            ">;)",
            "Lio/flutter/plugins/videoplayer/NativeAudioTrackData;"
        }
    .end annotation

    new-instance v0, Lio/flutter/plugins/videoplayer/NativeAudioTrackData;

    invoke-direct {v0, p1}, Lio/flutter/plugins/videoplayer/NativeAudioTrackData;-><init>(Ljava/util/List;)V

    return-object v0
.end method

.method public equals(Ljava/lang/Object;)Z
    .locals 2

    .line 548
    instance-of v0, p1, Lio/flutter/plugins/videoplayer/NativeAudioTrackData;

    if-nez v0, :cond_0

    const/4 p1, 0x0

    return p1

    :cond_0
    if-ne p0, p1, :cond_1

    const/4 p1, 0x1

    return p1

    .line 554
    :cond_1
    sget-object v0, Lio/flutter/plugins/videoplayer/MessagesPigeonUtils;->INSTANCE:Lio/flutter/plugins/videoplayer/MessagesPigeonUtils;

    invoke-virtual {p0}, Lio/flutter/plugins/videoplayer/NativeAudioTrackData;->toList()Ljava/util/List;

    move-result-object v1

    check-cast p1, Lio/flutter/plugins/videoplayer/NativeAudioTrackData;

    invoke-virtual {p1}, Lio/flutter/plugins/videoplayer/NativeAudioTrackData;->toList()Ljava/util/List;

    move-result-object p1

    invoke-virtual {v0, v1, p1}, Lio/flutter/plugins/videoplayer/MessagesPigeonUtils;->deepEquals(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p1

    return p1
.end method

.method public final getExoPlayerTracks()Ljava/util/List;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;",
            ">;"
        }
    .end annotation

    .line 532
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/NativeAudioTrackData;->exoPlayerTracks:Ljava/util/List;

    return-object v0
.end method

.method public hashCode()I
    .locals 1

    .line 557
    invoke-virtual {p0}, Lio/flutter/plugins/videoplayer/NativeAudioTrackData;->toList()Ljava/util/List;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->hashCode()I

    move-result v0

    return v0
.end method

.method public final toList()Ljava/util/List;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation

    .line 543
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/NativeAudioTrackData;->exoPlayerTracks:Ljava/util/List;

    .line 542
    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->listOf(Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    return-object v0
.end method

.method public toString()Ljava/lang/String;
    .locals 3

    iget-object v0, p0, Lio/flutter/plugins/videoplayer/NativeAudioTrackData;->exoPlayerTracks:Ljava/util/List;

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "NativeAudioTrackData(exoPlayerTracks="

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ")"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
