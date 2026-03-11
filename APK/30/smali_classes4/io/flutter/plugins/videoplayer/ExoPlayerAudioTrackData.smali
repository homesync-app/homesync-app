.class public final Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;
.super Ljava/lang/Object;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData$Companion;
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u00002\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\t\n\u0002\u0008\u0002\n\u0002\u0010\u000e\n\u0002\u0008\u0002\n\u0002\u0010\u000b\n\u0002\u0008\u0014\n\u0002\u0010 \n\u0002\u0008\u0003\n\u0002\u0010\u0008\n\u0002\u0008\u000e\u0008\u0086\u0008\u0018\u0000 /2\u00020\u0001:\u0001/Bg\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0006\u0010\u0004\u001a\u00020\u0003\u0012\n\u0008\u0002\u0010\u0005\u001a\u0004\u0018\u00010\u0006\u0012\n\u0008\u0002\u0010\u0007\u001a\u0004\u0018\u00010\u0006\u0012\u0006\u0010\u0008\u001a\u00020\t\u0012\n\u0008\u0002\u0010\n\u001a\u0004\u0018\u00010\u0003\u0012\n\u0008\u0002\u0010\u000b\u001a\u0004\u0018\u00010\u0003\u0012\n\u0008\u0002\u0010\u000c\u001a\u0004\u0018\u00010\u0003\u0012\n\u0008\u0002\u0010\r\u001a\u0004\u0018\u00010\u0006\u00a2\u0006\u0004\u0008\u000e\u0010\u000fJ\u000e\u0010\u001d\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u001eJ\u0013\u0010\u001f\u001a\u00020\t2\u0008\u0010 \u001a\u0004\u0018\u00010\u0001H\u0096\u0002J\u0008\u0010!\u001a\u00020\"H\u0016J\t\u0010#\u001a\u00020\u0003H\u00c6\u0003J\t\u0010$\u001a\u00020\u0003H\u00c6\u0003J\u000b\u0010%\u001a\u0004\u0018\u00010\u0006H\u00c6\u0003J\u000b\u0010&\u001a\u0004\u0018\u00010\u0006H\u00c6\u0003J\t\u0010\'\u001a\u00020\tH\u00c6\u0003J\u0010\u0010(\u001a\u0004\u0018\u00010\u0003H\u00c6\u0003\u00a2\u0006\u0002\u0010\u0018J\u0010\u0010)\u001a\u0004\u0018\u00010\u0003H\u00c6\u0003\u00a2\u0006\u0002\u0010\u0018J\u0010\u0010*\u001a\u0004\u0018\u00010\u0003H\u00c6\u0003\u00a2\u0006\u0002\u0010\u0018J\u000b\u0010+\u001a\u0004\u0018\u00010\u0006H\u00c6\u0003Jt\u0010,\u001a\u00020\u00002\u0008\u0008\u0002\u0010\u0002\u001a\u00020\u00032\u0008\u0008\u0002\u0010\u0004\u001a\u00020\u00032\n\u0008\u0002\u0010\u0005\u001a\u0004\u0018\u00010\u00062\n\u0008\u0002\u0010\u0007\u001a\u0004\u0018\u00010\u00062\u0008\u0008\u0002\u0010\u0008\u001a\u00020\t2\n\u0008\u0002\u0010\n\u001a\u0004\u0018\u00010\u00032\n\u0008\u0002\u0010\u000b\u001a\u0004\u0018\u00010\u00032\n\u0008\u0002\u0010\u000c\u001a\u0004\u0018\u00010\u00032\n\u0008\u0002\u0010\r\u001a\u0004\u0018\u00010\u0006H\u00c6\u0001\u00a2\u0006\u0002\u0010-J\t\u0010.\u001a\u00020\u0006H\u00d6\u0001R\u0011\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0010\u0010\u0011R\u0011\u0010\u0004\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0012\u0010\u0011R\u0013\u0010\u0005\u001a\u0004\u0018\u00010\u0006\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0013\u0010\u0014R\u0013\u0010\u0007\u001a\u0004\u0018\u00010\u0006\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0015\u0010\u0014R\u0011\u0010\u0008\u001a\u00020\t\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0008\u0010\u0016R\u0015\u0010\n\u001a\u0004\u0018\u00010\u0003\u00a2\u0006\n\n\u0002\u0010\u0019\u001a\u0004\u0008\u0017\u0010\u0018R\u0015\u0010\u000b\u001a\u0004\u0018\u00010\u0003\u00a2\u0006\n\n\u0002\u0010\u0019\u001a\u0004\u0008\u001a\u0010\u0018R\u0015\u0010\u000c\u001a\u0004\u0018\u00010\u0003\u00a2\u0006\n\n\u0002\u0010\u0019\u001a\u0004\u0008\u001b\u0010\u0018R\u0013\u0010\r\u001a\u0004\u0018\u00010\u0006\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u001c\u0010\u0014\u00a8\u00060"
    }
    d2 = {
        "Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;",
        "",
        "groupIndex",
        "",
        "trackIndex",
        "label",
        "",
        "language",
        "isSelected",
        "",
        "bitrate",
        "sampleRate",
        "channelCount",
        "codec",
        "<init>",
        "(JJLjava/lang/String;Ljava/lang/String;ZLjava/lang/Long;Ljava/lang/Long;Ljava/lang/Long;Ljava/lang/String;)V",
        "getGroupIndex",
        "()J",
        "getTrackIndex",
        "getLabel",
        "()Ljava/lang/String;",
        "getLanguage",
        "()Z",
        "getBitrate",
        "()Ljava/lang/Long;",
        "Ljava/lang/Long;",
        "getSampleRate",
        "getChannelCount",
        "getCodec",
        "toList",
        "",
        "equals",
        "other",
        "hashCode",
        "",
        "component1",
        "component2",
        "component3",
        "component4",
        "component5",
        "component6",
        "component7",
        "component8",
        "component9",
        "copy",
        "(JJLjava/lang/String;Ljava/lang/String;ZLjava/lang/Long;Ljava/lang/Long;Ljava/lang/Long;Ljava/lang/String;)Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;",
        "toString",
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
.field public static final Companion:Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData$Companion;


# instance fields
.field private final bitrate:Ljava/lang/Long;

.field private final channelCount:Ljava/lang/Long;

.field private final codec:Ljava/lang/String;

.field private final groupIndex:J

.field private final isSelected:Z

.field private final label:Ljava/lang/String;

.field private final language:Ljava/lang/String;

.field private final sampleRate:Ljava/lang/Long;

.field private final trackIndex:J


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData$Companion;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData$Companion;-><init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V

    sput-object v0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->Companion:Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData$Companion;

    return-void
.end method

.method public constructor <init>(JJLjava/lang/String;Ljava/lang/String;ZLjava/lang/Long;Ljava/lang/Long;Ljava/lang/Long;Ljava/lang/String;)V
    .locals 0

    .line 463
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 464
    iput-wide p1, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->groupIndex:J

    .line 465
    iput-wide p3, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->trackIndex:J

    .line 466
    iput-object p5, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->label:Ljava/lang/String;

    .line 467
    iput-object p6, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->language:Ljava/lang/String;

    .line 468
    iput-boolean p7, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->isSelected:Z

    .line 469
    iput-object p8, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->bitrate:Ljava/lang/Long;

    .line 470
    iput-object p9, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->sampleRate:Ljava/lang/Long;

    .line 471
    iput-object p10, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->channelCount:Ljava/lang/Long;

    .line 472
    iput-object p11, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->codec:Ljava/lang/String;

    return-void
.end method

.method public synthetic constructor <init>(JJLjava/lang/String;Ljava/lang/String;ZLjava/lang/Long;Ljava/lang/Long;Ljava/lang/Long;Ljava/lang/String;ILkotlin/jvm/internal/DefaultConstructorMarker;)V
    .locals 1

    and-int/lit8 p13, p12, 0x4

    const/4 v0, 0x0

    if-eqz p13, :cond_0

    move-object p5, v0

    :cond_0
    and-int/lit8 p13, p12, 0x8

    if-eqz p13, :cond_1

    move-object p6, v0

    :cond_1
    and-int/lit8 p13, p12, 0x20

    if-eqz p13, :cond_2

    move-object p8, v0

    :cond_2
    and-int/lit8 p13, p12, 0x40

    if-eqz p13, :cond_3

    move-object p9, v0

    :cond_3
    and-int/lit16 p13, p12, 0x80

    if-eqz p13, :cond_4

    move-object p10, v0

    :cond_4
    and-int/lit16 p12, p12, 0x100

    if-eqz p12, :cond_5

    move-object p12, v0

    goto :goto_0

    :cond_5
    move-object p12, p11

    :goto_0
    move-object p11, p10

    move-object p10, p9

    move-object p9, p8

    move p8, p7

    move-object p7, p6

    move-object p6, p5

    move-wide p4, p3

    move-wide p2, p1

    move-object p1, p0

    .line 463
    invoke-direct/range {p1 .. p12}, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;-><init>(JJLjava/lang/String;Ljava/lang/String;ZLjava/lang/Long;Ljava/lang/Long;Ljava/lang/Long;Ljava/lang/String;)V

    return-void
.end method

.method public static synthetic copy$default(Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;JJLjava/lang/String;Ljava/lang/String;ZLjava/lang/Long;Ljava/lang/Long;Ljava/lang/Long;Ljava/lang/String;ILjava/lang/Object;)Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;
    .locals 12

    move/from16 v0, p12

    and-int/lit8 v1, v0, 0x1

    if-eqz v1, :cond_0

    iget-wide p1, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->groupIndex:J

    :cond_0
    move-wide v1, p1

    and-int/lit8 p1, v0, 0x2

    if-eqz p1, :cond_1

    iget-wide p1, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->trackIndex:J

    move-wide v3, p1

    goto :goto_0

    :cond_1
    move-wide v3, p3

    :goto_0
    and-int/lit8 p1, v0, 0x4

    if-eqz p1, :cond_2

    iget-object p1, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->label:Ljava/lang/String;

    move-object v5, p1

    goto :goto_1

    :cond_2
    move-object/from16 v5, p5

    :goto_1
    and-int/lit8 p1, v0, 0x8

    if-eqz p1, :cond_3

    iget-object p1, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->language:Ljava/lang/String;

    move-object v6, p1

    goto :goto_2

    :cond_3
    move-object/from16 v6, p6

    :goto_2
    and-int/lit8 p1, v0, 0x10

    if-eqz p1, :cond_4

    iget-boolean p1, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->isSelected:Z

    move v7, p1

    goto :goto_3

    :cond_4
    move/from16 v7, p7

    :goto_3
    and-int/lit8 p1, v0, 0x20

    if-eqz p1, :cond_5

    iget-object p1, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->bitrate:Ljava/lang/Long;

    move-object v8, p1

    goto :goto_4

    :cond_5
    move-object/from16 v8, p8

    :goto_4
    and-int/lit8 p1, v0, 0x40

    if-eqz p1, :cond_6

    iget-object p1, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->sampleRate:Ljava/lang/Long;

    move-object v9, p1

    goto :goto_5

    :cond_6
    move-object/from16 v9, p9

    :goto_5
    and-int/lit16 p1, v0, 0x80

    if-eqz p1, :cond_7

    iget-object p1, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->channelCount:Ljava/lang/Long;

    move-object v10, p1

    goto :goto_6

    :cond_7
    move-object/from16 v10, p10

    :goto_6
    and-int/lit16 p1, v0, 0x100

    if-eqz p1, :cond_8

    iget-object p1, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->codec:Ljava/lang/String;

    move-object v11, p1

    goto :goto_7

    :cond_8
    move-object/from16 v11, p11

    :goto_7
    move-object v0, p0

    invoke-virtual/range {v0 .. v11}, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->copy(JJLjava/lang/String;Ljava/lang/String;ZLjava/lang/Long;Ljava/lang/Long;Ljava/lang/Long;Ljava/lang/String;)Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method public final component1()J
    .locals 2

    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->groupIndex:J

    return-wide v0
.end method

.method public final component2()J
    .locals 2

    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->trackIndex:J

    return-wide v0
.end method

.method public final component3()Ljava/lang/String;
    .locals 1

    iget-object v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->label:Ljava/lang/String;

    return-object v0
.end method

.method public final component4()Ljava/lang/String;
    .locals 1

    iget-object v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->language:Ljava/lang/String;

    return-object v0
.end method

.method public final component5()Z
    .locals 1

    iget-boolean v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->isSelected:Z

    return v0
.end method

.method public final component6()Ljava/lang/Long;
    .locals 1

    iget-object v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->bitrate:Ljava/lang/Long;

    return-object v0
.end method

.method public final component7()Ljava/lang/Long;
    .locals 1

    iget-object v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->sampleRate:Ljava/lang/Long;

    return-object v0
.end method

.method public final component8()Ljava/lang/Long;
    .locals 1

    iget-object v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->channelCount:Ljava/lang/Long;

    return-object v0
.end method

.method public final component9()Ljava/lang/String;
    .locals 1

    iget-object v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->codec:Ljava/lang/String;

    return-object v0
.end method

.method public final copy(JJLjava/lang/String;Ljava/lang/String;ZLjava/lang/Long;Ljava/lang/Long;Ljava/lang/Long;Ljava/lang/String;)Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;
    .locals 12

    new-instance v0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;

    move-wide v1, p1

    move-wide v3, p3

    move-object/from16 v5, p5

    move-object/from16 v6, p6

    move/from16 v7, p7

    move-object/from16 v8, p8

    move-object/from16 v9, p9

    move-object/from16 v10, p10

    move-object/from16 v11, p11

    invoke-direct/range {v0 .. v11}, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;-><init>(JJLjava/lang/String;Ljava/lang/String;ZLjava/lang/Long;Ljava/lang/Long;Ljava/lang/Long;Ljava/lang/String;)V

    return-object v0
.end method

.method public equals(Ljava/lang/Object;)Z
    .locals 2

    .line 513
    instance-of v0, p1, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;

    if-nez v0, :cond_0

    const/4 p1, 0x0

    return p1

    :cond_0
    if-ne p0, p1, :cond_1

    const/4 p1, 0x1

    return p1

    .line 519
    :cond_1
    sget-object v0, Lio/flutter/plugins/videoplayer/MessagesPigeonUtils;->INSTANCE:Lio/flutter/plugins/videoplayer/MessagesPigeonUtils;

    invoke-virtual {p0}, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->toList()Ljava/util/List;

    move-result-object v1

    check-cast p1, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;

    invoke-virtual {p1}, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->toList()Ljava/util/List;

    move-result-object p1

    invoke-virtual {v0, v1, p1}, Lio/flutter/plugins/videoplayer/MessagesPigeonUtils;->deepEquals(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p1

    return p1
.end method

.method public final getBitrate()Ljava/lang/Long;
    .locals 1

    .line 469
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->bitrate:Ljava/lang/Long;

    return-object v0
.end method

.method public final getChannelCount()Ljava/lang/Long;
    .locals 1

    .line 471
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->channelCount:Ljava/lang/Long;

    return-object v0
.end method

.method public final getCodec()Ljava/lang/String;
    .locals 1

    .line 472
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->codec:Ljava/lang/String;

    return-object v0
.end method

.method public final getGroupIndex()J
    .locals 2

    .line 464
    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->groupIndex:J

    return-wide v0
.end method

.method public final getLabel()Ljava/lang/String;
    .locals 1

    .line 466
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->label:Ljava/lang/String;

    return-object v0
.end method

.method public final getLanguage()Ljava/lang/String;
    .locals 1

    .line 467
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->language:Ljava/lang/String;

    return-object v0
.end method

.method public final getSampleRate()Ljava/lang/Long;
    .locals 1

    .line 470
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->sampleRate:Ljava/lang/Long;

    return-object v0
.end method

.method public final getTrackIndex()J
    .locals 2

    .line 465
    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->trackIndex:J

    return-wide v0
.end method

.method public hashCode()I
    .locals 1

    .line 522
    invoke-virtual {p0}, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->toList()Ljava/util/List;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->hashCode()I

    move-result v0

    return v0
.end method

.method public final isSelected()Z
    .locals 1

    .line 468
    iget-boolean v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->isSelected:Z

    return v0
.end method

.method public final toList()Ljava/util/List;
    .locals 11
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation

    .line 500
    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->groupIndex:J

    invoke-static {v0, v1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v2

    .line 501
    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->trackIndex:J

    invoke-static {v0, v1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v3

    .line 502
    iget-object v4, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->label:Ljava/lang/String;

    .line 503
    iget-object v5, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->language:Ljava/lang/String;

    .line 504
    iget-boolean v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->isSelected:Z

    invoke-static {v0}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v6

    .line 505
    iget-object v7, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->bitrate:Ljava/lang/Long;

    .line 506
    iget-object v8, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->sampleRate:Ljava/lang/Long;

    .line 507
    iget-object v9, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->channelCount:Ljava/lang/Long;

    .line 508
    iget-object v10, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->codec:Ljava/lang/String;

    filled-new-array/range {v2 .. v10}, [Ljava/lang/Object;

    move-result-object v0

    .line 499
    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->listOf([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    return-object v0
.end method

.method public toString()Ljava/lang/String;
    .locals 13

    iget-wide v0, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->groupIndex:J

    iget-wide v2, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->trackIndex:J

    iget-object v4, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->label:Ljava/lang/String;

    iget-object v5, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->language:Ljava/lang/String;

    iget-boolean v6, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->isSelected:Z

    iget-object v7, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->bitrate:Ljava/lang/Long;

    iget-object v8, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->sampleRate:Ljava/lang/Long;

    iget-object v9, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->channelCount:Ljava/lang/Long;

    iget-object v10, p0, Lio/flutter/plugins/videoplayer/ExoPlayerAudioTrackData;->codec:Ljava/lang/String;

    new-instance v11, Ljava/lang/StringBuilder;

    const-string v12, "ExoPlayerAudioTrackData(groupIndex="

    invoke-direct {v11, v12}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v11, v0, v1}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", trackIndex="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v2, v3}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", label="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", language="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", isSelected="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v6}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", bitrate="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", sampleRate="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", channelCount="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", codec="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ")"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
