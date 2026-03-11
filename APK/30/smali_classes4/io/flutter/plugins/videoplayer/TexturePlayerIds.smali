.class public final Lio/flutter/plugins/videoplayer/TexturePlayerIds;
.super Ljava/lang/Object;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/videoplayer/TexturePlayerIds$Companion;
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u00000\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\t\n\u0002\u0008\u0007\n\u0002\u0010 \n\u0000\n\u0002\u0010\u000b\n\u0002\u0008\u0002\n\u0002\u0010\u0008\n\u0002\u0008\u0004\n\u0002\u0010\u000e\n\u0002\u0008\u0002\u0008\u0086\u0008\u0018\u0000 \u00162\u00020\u0001:\u0001\u0016B\u0017\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0006\u0010\u0004\u001a\u00020\u0003\u00a2\u0006\u0004\u0008\u0005\u0010\u0006J\u000e\u0010\n\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u000bJ\u0013\u0010\u000c\u001a\u00020\r2\u0008\u0010\u000e\u001a\u0004\u0018\u00010\u0001H\u0096\u0002J\u0008\u0010\u000f\u001a\u00020\u0010H\u0016J\t\u0010\u0011\u001a\u00020\u0003H\u00c6\u0003J\t\u0010\u0012\u001a\u00020\u0003H\u00c6\u0003J\u001d\u0010\u0013\u001a\u00020\u00002\u0008\u0008\u0002\u0010\u0002\u001a\u00020\u00032\u0008\u0008\u0002\u0010\u0004\u001a\u00020\u0003H\u00c6\u0001J\t\u0010\u0014\u001a\u00020\u0015H\u00d6\u0001R\u0011\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0007\u0010\u0008R\u0011\u0010\u0004\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\t\u0010\u0008\u00a8\u0006\u0017"
    }
    d2 = {
        "Lio/flutter/plugins/videoplayer/TexturePlayerIds;",
        "",
        "playerId",
        "",
        "textureId",
        "<init>",
        "(JJ)V",
        "getPlayerId",
        "()J",
        "getTextureId",
        "toList",
        "",
        "equals",
        "",
        "other",
        "hashCode",
        "",
        "component1",
        "component2",
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
.field public static final Companion:Lio/flutter/plugins/videoplayer/TexturePlayerIds$Companion;


# instance fields
.field private final playerId:J

.field private final textureId:J


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Lio/flutter/plugins/videoplayer/TexturePlayerIds$Companion;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Lio/flutter/plugins/videoplayer/TexturePlayerIds$Companion;-><init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V

    sput-object v0, Lio/flutter/plugins/videoplayer/TexturePlayerIds;->Companion:Lio/flutter/plugins/videoplayer/TexturePlayerIds$Companion;

    return-void
.end method

.method public constructor <init>(JJ)V
    .locals 0

    .line 338
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-wide p1, p0, Lio/flutter/plugins/videoplayer/TexturePlayerIds;->playerId:J

    iput-wide p3, p0, Lio/flutter/plugins/videoplayer/TexturePlayerIds;->textureId:J

    return-void
.end method

.method public static synthetic copy$default(Lio/flutter/plugins/videoplayer/TexturePlayerIds;JJILjava/lang/Object;)Lio/flutter/plugins/videoplayer/TexturePlayerIds;
    .locals 0

    and-int/lit8 p6, p5, 0x1

    if-eqz p6, :cond_0

    iget-wide p1, p0, Lio/flutter/plugins/videoplayer/TexturePlayerIds;->playerId:J

    :cond_0
    and-int/lit8 p5, p5, 0x2

    if-eqz p5, :cond_1

    iget-wide p3, p0, Lio/flutter/plugins/videoplayer/TexturePlayerIds;->textureId:J

    :cond_1
    invoke-virtual {p0, p1, p2, p3, p4}, Lio/flutter/plugins/videoplayer/TexturePlayerIds;->copy(JJ)Lio/flutter/plugins/videoplayer/TexturePlayerIds;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method public final component1()J
    .locals 2

    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/TexturePlayerIds;->playerId:J

    return-wide v0
.end method

.method public final component2()J
    .locals 2

    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/TexturePlayerIds;->textureId:J

    return-wide v0
.end method

.method public final copy(JJ)Lio/flutter/plugins/videoplayer/TexturePlayerIds;
    .locals 1

    new-instance v0, Lio/flutter/plugins/videoplayer/TexturePlayerIds;

    invoke-direct {v0, p1, p2, p3, p4}, Lio/flutter/plugins/videoplayer/TexturePlayerIds;-><init>(JJ)V

    return-object v0
.end method

.method public equals(Ljava/lang/Object;)Z
    .locals 2

    .line 355
    instance-of v0, p1, Lio/flutter/plugins/videoplayer/TexturePlayerIds;

    if-nez v0, :cond_0

    const/4 p1, 0x0

    return p1

    :cond_0
    if-ne p0, p1, :cond_1

    const/4 p1, 0x1

    return p1

    .line 361
    :cond_1
    sget-object v0, Lio/flutter/plugins/videoplayer/MessagesPigeonUtils;->INSTANCE:Lio/flutter/plugins/videoplayer/MessagesPigeonUtils;

    invoke-virtual {p0}, Lio/flutter/plugins/videoplayer/TexturePlayerIds;->toList()Ljava/util/List;

    move-result-object v1

    check-cast p1, Lio/flutter/plugins/videoplayer/TexturePlayerIds;

    invoke-virtual {p1}, Lio/flutter/plugins/videoplayer/TexturePlayerIds;->toList()Ljava/util/List;

    move-result-object p1

    invoke-virtual {v0, v1, p1}, Lio/flutter/plugins/videoplayer/MessagesPigeonUtils;->deepEquals(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p1

    return p1
.end method

.method public final getPlayerId()J
    .locals 2

    .line 338
    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/TexturePlayerIds;->playerId:J

    return-wide v0
.end method

.method public final getTextureId()J
    .locals 2

    .line 338
    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/TexturePlayerIds;->textureId:J

    return-wide v0
.end method

.method public hashCode()I
    .locals 1

    .line 364
    invoke-virtual {p0}, Lio/flutter/plugins/videoplayer/TexturePlayerIds;->toList()Ljava/util/List;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->hashCode()I

    move-result v0

    return v0
.end method

.method public final toList()Ljava/util/List;
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation

    const/4 v0, 0x2

    .line 349
    new-array v0, v0, [Ljava/lang/Long;

    iget-wide v1, p0, Lio/flutter/plugins/videoplayer/TexturePlayerIds;->playerId:J

    invoke-static {v1, v2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v1

    const/4 v2, 0x0

    aput-object v1, v0, v2

    .line 350
    iget-wide v1, p0, Lio/flutter/plugins/videoplayer/TexturePlayerIds;->textureId:J

    invoke-static {v1, v2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v1

    const/4 v2, 0x1

    aput-object v1, v0, v2

    .line 348
    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->listOf([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    return-object v0
.end method

.method public toString()Ljava/lang/String;
    .locals 6

    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/TexturePlayerIds;->playerId:J

    iget-wide v2, p0, Lio/flutter/plugins/videoplayer/TexturePlayerIds;->textureId:J

    new-instance v4, Ljava/lang/StringBuilder;

    const-string v5, "TexturePlayerIds(playerId="

    invoke-direct {v4, v5}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v4, v0, v1}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", textureId="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v2, v3}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ")"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
