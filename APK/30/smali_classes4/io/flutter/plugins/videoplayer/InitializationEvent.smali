.class public final Lio/flutter/plugins/videoplayer/InitializationEvent;
.super Lio/flutter/plugins/videoplayer/PlatformVideoEvent;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/videoplayer/InitializationEvent$Companion;
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u00004\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\t\n\u0002\u0008\u000b\n\u0002\u0010 \n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000b\n\u0002\u0008\u0002\n\u0002\u0010\u0008\n\u0002\u0008\u0006\n\u0002\u0010\u000e\n\u0002\u0008\u0002\u0008\u0086\u0008\u0018\u0000 \u001d2\u00020\u0001:\u0001\u001dB\'\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0006\u0010\u0004\u001a\u00020\u0003\u0012\u0006\u0010\u0005\u001a\u00020\u0003\u0012\u0006\u0010\u0006\u001a\u00020\u0003\u00a2\u0006\u0004\u0008\u0007\u0010\u0008J\u000e\u0010\u000e\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00100\u000fJ\u0013\u0010\u0011\u001a\u00020\u00122\u0008\u0010\u0013\u001a\u0004\u0018\u00010\u0010H\u0096\u0002J\u0008\u0010\u0014\u001a\u00020\u0015H\u0016J\t\u0010\u0016\u001a\u00020\u0003H\u00c6\u0003J\t\u0010\u0017\u001a\u00020\u0003H\u00c6\u0003J\t\u0010\u0018\u001a\u00020\u0003H\u00c6\u0003J\t\u0010\u0019\u001a\u00020\u0003H\u00c6\u0003J1\u0010\u001a\u001a\u00020\u00002\u0008\u0008\u0002\u0010\u0002\u001a\u00020\u00032\u0008\u0008\u0002\u0010\u0004\u001a\u00020\u00032\u0008\u0008\u0002\u0010\u0005\u001a\u00020\u00032\u0008\u0008\u0002\u0010\u0006\u001a\u00020\u0003H\u00c6\u0001J\t\u0010\u001b\u001a\u00020\u001cH\u00d6\u0001R\u0011\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\t\u0010\nR\u0011\u0010\u0004\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u000b\u0010\nR\u0011\u0010\u0005\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u000c\u0010\nR\u0011\u0010\u0006\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\r\u0010\n\u00a8\u0006\u001e"
    }
    d2 = {
        "Lio/flutter/plugins/videoplayer/InitializationEvent;",
        "Lio/flutter/plugins/videoplayer/PlatformVideoEvent;",
        "duration",
        "",
        "width",
        "height",
        "rotationCorrection",
        "<init>",
        "(JJJJ)V",
        "getDuration",
        "()J",
        "getWidth",
        "getHeight",
        "getRotationCorrection",
        "toList",
        "",
        "",
        "equals",
        "",
        "other",
        "hashCode",
        "",
        "component1",
        "component2",
        "component3",
        "component4",
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
.field public static final Companion:Lio/flutter/plugins/videoplayer/InitializationEvent$Companion;


# instance fields
.field private final duration:J

.field private final height:J

.field private final rotationCorrection:J

.field private final width:J


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Lio/flutter/plugins/videoplayer/InitializationEvent$Companion;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Lio/flutter/plugins/videoplayer/InitializationEvent$Companion;-><init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V

    sput-object v0, Lio/flutter/plugins/videoplayer/InitializationEvent;->Companion:Lio/flutter/plugins/videoplayer/InitializationEvent$Companion;

    return-void
.end method

.method public constructor <init>(JJJJ)V
    .locals 1

    const/4 v0, 0x0

    .line 118
    invoke-direct {p0, v0}, Lio/flutter/plugins/videoplayer/PlatformVideoEvent;-><init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V

    .line 120
    iput-wide p1, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->duration:J

    .line 122
    iput-wide p3, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->width:J

    .line 124
    iput-wide p5, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->height:J

    .line 126
    iput-wide p7, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->rotationCorrection:J

    return-void
.end method

.method public static synthetic copy$default(Lio/flutter/plugins/videoplayer/InitializationEvent;JJJJILjava/lang/Object;)Lio/flutter/plugins/videoplayer/InitializationEvent;
    .locals 9

    and-int/lit8 v0, p9, 0x1

    if-eqz v0, :cond_0

    iget-wide p1, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->duration:J

    :cond_0
    move-wide v1, p1

    and-int/lit8 p1, p9, 0x2

    if-eqz p1, :cond_1

    iget-wide p3, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->width:J

    :cond_1
    move-wide v3, p3

    and-int/lit8 p1, p9, 0x4

    if-eqz p1, :cond_2

    iget-wide p5, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->height:J

    :cond_2
    move-wide v5, p5

    and-int/lit8 p1, p9, 0x8

    if-eqz p1, :cond_3

    iget-wide p1, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->rotationCorrection:J

    move-wide v7, p1

    goto :goto_0

    :cond_3
    move-wide/from16 v7, p7

    :goto_0
    move-object v0, p0

    invoke-virtual/range {v0 .. v8}, Lio/flutter/plugins/videoplayer/InitializationEvent;->copy(JJJJ)Lio/flutter/plugins/videoplayer/InitializationEvent;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method public final component1()J
    .locals 2

    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->duration:J

    return-wide v0
.end method

.method public final component2()J
    .locals 2

    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->width:J

    return-wide v0
.end method

.method public final component3()J
    .locals 2

    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->height:J

    return-wide v0
.end method

.method public final component4()J
    .locals 2

    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->rotationCorrection:J

    return-wide v0
.end method

.method public final copy(JJJJ)Lio/flutter/plugins/videoplayer/InitializationEvent;
    .locals 9

    new-instance v0, Lio/flutter/plugins/videoplayer/InitializationEvent;

    move-wide v1, p1

    move-wide v3, p3

    move-wide v5, p5

    move-wide/from16 v7, p7

    invoke-direct/range {v0 .. v8}, Lio/flutter/plugins/videoplayer/InitializationEvent;-><init>(JJJJ)V

    return-object v0
.end method

.method public equals(Ljava/lang/Object;)Z
    .locals 2

    .line 148
    instance-of v0, p1, Lio/flutter/plugins/videoplayer/InitializationEvent;

    if-nez v0, :cond_0

    const/4 p1, 0x0

    return p1

    :cond_0
    if-ne p0, p1, :cond_1

    const/4 p1, 0x1

    return p1

    .line 154
    :cond_1
    sget-object v0, Lio/flutter/plugins/videoplayer/MessagesPigeonUtils;->INSTANCE:Lio/flutter/plugins/videoplayer/MessagesPigeonUtils;

    invoke-virtual {p0}, Lio/flutter/plugins/videoplayer/InitializationEvent;->toList()Ljava/util/List;

    move-result-object v1

    check-cast p1, Lio/flutter/plugins/videoplayer/InitializationEvent;

    invoke-virtual {p1}, Lio/flutter/plugins/videoplayer/InitializationEvent;->toList()Ljava/util/List;

    move-result-object p1

    invoke-virtual {v0, v1, p1}, Lio/flutter/plugins/videoplayer/MessagesPigeonUtils;->deepEquals(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p1

    return p1
.end method

.method public final getDuration()J
    .locals 2

    .line 120
    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->duration:J

    return-wide v0
.end method

.method public final getHeight()J
    .locals 2

    .line 124
    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->height:J

    return-wide v0
.end method

.method public final getRotationCorrection()J
    .locals 2

    .line 126
    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->rotationCorrection:J

    return-wide v0
.end method

.method public final getWidth()J
    .locals 2

    .line 122
    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->width:J

    return-wide v0
.end method

.method public hashCode()I
    .locals 1

    .line 157
    invoke-virtual {p0}, Lio/flutter/plugins/videoplayer/InitializationEvent;->toList()Ljava/util/List;

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

    const/4 v0, 0x4

    .line 140
    new-array v0, v0, [Ljava/lang/Long;

    iget-wide v1, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->duration:J

    invoke-static {v1, v2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v1

    const/4 v2, 0x0

    aput-object v1, v0, v2

    .line 141
    iget-wide v1, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->width:J

    invoke-static {v1, v2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v1

    const/4 v2, 0x1

    aput-object v1, v0, v2

    .line 142
    iget-wide v1, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->height:J

    invoke-static {v1, v2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v1

    const/4 v2, 0x2

    aput-object v1, v0, v2

    .line 143
    iget-wide v1, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->rotationCorrection:J

    invoke-static {v1, v2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v1

    const/4 v2, 0x3

    aput-object v1, v0, v2

    .line 139
    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->listOf([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    return-object v0
.end method

.method public toString()Ljava/lang/String;
    .locals 10

    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->duration:J

    iget-wide v2, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->width:J

    iget-wide v4, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->height:J

    iget-wide v6, p0, Lio/flutter/plugins/videoplayer/InitializationEvent;->rotationCorrection:J

    new-instance v8, Ljava/lang/StringBuilder;

    const-string v9, "InitializationEvent(duration="

    invoke-direct {v8, v9}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v8, v0, v1}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", width="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v2, v3}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", height="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v4, v5}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", rotationCorrection="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v6, v7}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ")"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
