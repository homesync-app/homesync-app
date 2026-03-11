.class public final Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;
.super Ljava/lang/Object;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams$Companion;
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u00000\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\t\n\u0002\u0008\u0005\n\u0002\u0010 \n\u0000\n\u0002\u0010\u000b\n\u0002\u0008\u0002\n\u0002\u0010\u0008\n\u0002\u0008\u0003\n\u0002\u0010\u000e\n\u0002\u0008\u0002\u0008\u0086\u0008\u0018\u0000 \u00132\u00020\u0001:\u0001\u0013B\u000f\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0004\u0008\u0004\u0010\u0005J\u000e\u0010\u0008\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\tJ\u0013\u0010\n\u001a\u00020\u000b2\u0008\u0010\u000c\u001a\u0004\u0018\u00010\u0001H\u0096\u0002J\u0008\u0010\r\u001a\u00020\u000eH\u0016J\t\u0010\u000f\u001a\u00020\u0003H\u00c6\u0003J\u0013\u0010\u0010\u001a\u00020\u00002\u0008\u0008\u0002\u0010\u0002\u001a\u00020\u0003H\u00c6\u0001J\t\u0010\u0011\u001a\u00020\u0012H\u00d6\u0001R\u0011\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0006\u0010\u0007\u00a8\u0006\u0014"
    }
    d2 = {
        "Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;",
        "",
        "playerId",
        "",
        "<init>",
        "(J)V",
        "getPlayerId",
        "()J",
        "toList",
        "",
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
.field public static final Companion:Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams$Companion;


# instance fields
.field private final playerId:J


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams$Companion;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams$Companion;-><init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V

    sput-object v0, Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;->Companion:Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams$Companion;

    return-void
.end method

.method public constructor <init>(J)V
    .locals 0

    .line 271
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-wide p1, p0, Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;->playerId:J

    return-void
.end method

.method public static synthetic copy$default(Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;JILjava/lang/Object;)Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;
    .locals 0

    and-int/lit8 p3, p3, 0x1

    if-eqz p3, :cond_0

    iget-wide p1, p0, Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;->playerId:J

    :cond_0
    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;->copy(J)Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method public final component1()J
    .locals 2

    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;->playerId:J

    return-wide v0
.end method

.method public final copy(J)Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;
    .locals 1

    new-instance v0, Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;

    invoke-direct {v0, p1, p2}, Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;-><init>(J)V

    return-object v0
.end method

.method public equals(Ljava/lang/Object;)Z
    .locals 2

    .line 286
    instance-of v0, p1, Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;

    if-nez v0, :cond_0

    const/4 p1, 0x0

    return p1

    :cond_0
    if-ne p0, p1, :cond_1

    const/4 p1, 0x1

    return p1

    .line 292
    :cond_1
    sget-object v0, Lio/flutter/plugins/videoplayer/MessagesPigeonUtils;->INSTANCE:Lio/flutter/plugins/videoplayer/MessagesPigeonUtils;

    invoke-virtual {p0}, Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;->toList()Ljava/util/List;

    move-result-object v1

    check-cast p1, Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;

    invoke-virtual {p1}, Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;->toList()Ljava/util/List;

    move-result-object p1

    invoke-virtual {v0, v1, p1}, Lio/flutter/plugins/videoplayer/MessagesPigeonUtils;->deepEquals(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p1

    return p1
.end method

.method public final getPlayerId()J
    .locals 2

    .line 271
    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;->playerId:J

    return-wide v0
.end method

.method public hashCode()I
    .locals 1

    .line 295
    invoke-virtual {p0}, Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;->toList()Ljava/util/List;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->hashCode()I

    move-result v0

    return v0
.end method

.method public final toList()Ljava/util/List;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation

    .line 281
    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;->playerId:J

    invoke-static {v0, v1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v0

    .line 280
    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->listOf(Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    return-object v0
.end method

.method public toString()Ljava/lang/String;
    .locals 4

    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/PlatformVideoViewCreationParams;->playerId:J

    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "PlatformVideoViewCreationParams(playerId="

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, v0, v1}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ")"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
