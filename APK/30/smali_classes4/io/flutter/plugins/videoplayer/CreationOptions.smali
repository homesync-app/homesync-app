.class public final Lio/flutter/plugins/videoplayer/CreationOptions;
.super Ljava/lang/Object;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/videoplayer/CreationOptions$Companion;
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u00004\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000e\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010$\n\u0002\u0008\u000b\n\u0002\u0010 \n\u0000\n\u0002\u0010\u000b\n\u0002\u0008\u0002\n\u0002\u0010\u0008\n\u0002\u0008\u0008\u0008\u0086\u0008\u0018\u0000 \u001f2\u00020\u0001:\u0001\u001fB;\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\n\u0008\u0002\u0010\u0004\u001a\u0004\u0018\u00010\u0005\u0012\u0012\u0010\u0006\u001a\u000e\u0012\u0004\u0012\u00020\u0003\u0012\u0004\u0012\u00020\u00030\u0007\u0012\n\u0008\u0002\u0010\u0008\u001a\u0004\u0018\u00010\u0003\u00a2\u0006\u0004\u0008\t\u0010\nJ\u000e\u0010\u0012\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0013J\u0013\u0010\u0014\u001a\u00020\u00152\u0008\u0010\u0016\u001a\u0004\u0018\u00010\u0001H\u0096\u0002J\u0008\u0010\u0017\u001a\u00020\u0018H\u0016J\t\u0010\u0019\u001a\u00020\u0003H\u00c6\u0003J\u000b\u0010\u001a\u001a\u0004\u0018\u00010\u0005H\u00c6\u0003J\u0015\u0010\u001b\u001a\u000e\u0012\u0004\u0012\u00020\u0003\u0012\u0004\u0012\u00020\u00030\u0007H\u00c6\u0003J\u000b\u0010\u001c\u001a\u0004\u0018\u00010\u0003H\u00c6\u0003JA\u0010\u001d\u001a\u00020\u00002\u0008\u0008\u0002\u0010\u0002\u001a\u00020\u00032\n\u0008\u0002\u0010\u0004\u001a\u0004\u0018\u00010\u00052\u0014\u0008\u0002\u0010\u0006\u001a\u000e\u0012\u0004\u0012\u00020\u0003\u0012\u0004\u0012\u00020\u00030\u00072\n\u0008\u0002\u0010\u0008\u001a\u0004\u0018\u00010\u0003H\u00c6\u0001J\t\u0010\u001e\u001a\u00020\u0003H\u00d6\u0001R\u0011\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u000b\u0010\u000cR\u0013\u0010\u0004\u001a\u0004\u0018\u00010\u0005\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\r\u0010\u000eR\u001d\u0010\u0006\u001a\u000e\u0012\u0004\u0012\u00020\u0003\u0012\u0004\u0012\u00020\u00030\u0007\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u000f\u0010\u0010R\u0013\u0010\u0008\u001a\u0004\u0018\u00010\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0011\u0010\u000c\u00a8\u0006 "
    }
    d2 = {
        "Lio/flutter/plugins/videoplayer/CreationOptions;",
        "",
        "uri",
        "",
        "formatHint",
        "Lio/flutter/plugins/videoplayer/PlatformVideoFormat;",
        "httpHeaders",
        "",
        "userAgent",
        "<init>",
        "(Ljava/lang/String;Lio/flutter/plugins/videoplayer/PlatformVideoFormat;Ljava/util/Map;Ljava/lang/String;)V",
        "getUri",
        "()Ljava/lang/String;",
        "getFormatHint",
        "()Lio/flutter/plugins/videoplayer/PlatformVideoFormat;",
        "getHttpHeaders",
        "()Ljava/util/Map;",
        "getUserAgent",
        "toList",
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
.field public static final Companion:Lio/flutter/plugins/videoplayer/CreationOptions$Companion;


# instance fields
.field private final formatHint:Lio/flutter/plugins/videoplayer/PlatformVideoFormat;

.field private final httpHeaders:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field private final uri:Ljava/lang/String;

.field private final userAgent:Ljava/lang/String;


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Lio/flutter/plugins/videoplayer/CreationOptions$Companion;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Lio/flutter/plugins/videoplayer/CreationOptions$Companion;-><init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V

    sput-object v0, Lio/flutter/plugins/videoplayer/CreationOptions;->Companion:Lio/flutter/plugins/videoplayer/CreationOptions$Companion;

    return-void
.end method

.method public constructor <init>(Ljava/lang/String;Lio/flutter/plugins/videoplayer/PlatformVideoFormat;Ljava/util/Map;Ljava/lang/String;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/String;",
            "Lio/flutter/plugins/videoplayer/PlatformVideoFormat;",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;",
            "Ljava/lang/String;",
            ")V"
        }
    .end annotation

    const-string v0, "uri"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "httpHeaders"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 299
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 300
    iput-object p1, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->uri:Ljava/lang/String;

    .line 301
    iput-object p2, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->formatHint:Lio/flutter/plugins/videoplayer/PlatformVideoFormat;

    .line 302
    iput-object p3, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->httpHeaders:Ljava/util/Map;

    .line 303
    iput-object p4, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->userAgent:Ljava/lang/String;

    return-void
.end method

.method public synthetic constructor <init>(Ljava/lang/String;Lio/flutter/plugins/videoplayer/PlatformVideoFormat;Ljava/util/Map;Ljava/lang/String;ILkotlin/jvm/internal/DefaultConstructorMarker;)V
    .locals 1

    and-int/lit8 p6, p5, 0x2

    const/4 v0, 0x0

    if-eqz p6, :cond_0

    move-object p2, v0

    :cond_0
    and-int/lit8 p5, p5, 0x8

    if-eqz p5, :cond_1

    move-object p4, v0

    .line 299
    :cond_1
    invoke-direct {p0, p1, p2, p3, p4}, Lio/flutter/plugins/videoplayer/CreationOptions;-><init>(Ljava/lang/String;Lio/flutter/plugins/videoplayer/PlatformVideoFormat;Ljava/util/Map;Ljava/lang/String;)V

    return-void
.end method

.method public static synthetic copy$default(Lio/flutter/plugins/videoplayer/CreationOptions;Ljava/lang/String;Lio/flutter/plugins/videoplayer/PlatformVideoFormat;Ljava/util/Map;Ljava/lang/String;ILjava/lang/Object;)Lio/flutter/plugins/videoplayer/CreationOptions;
    .locals 0

    and-int/lit8 p6, p5, 0x1

    if-eqz p6, :cond_0

    iget-object p1, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->uri:Ljava/lang/String;

    :cond_0
    and-int/lit8 p6, p5, 0x2

    if-eqz p6, :cond_1

    iget-object p2, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->formatHint:Lio/flutter/plugins/videoplayer/PlatformVideoFormat;

    :cond_1
    and-int/lit8 p6, p5, 0x4

    if-eqz p6, :cond_2

    iget-object p3, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->httpHeaders:Ljava/util/Map;

    :cond_2
    and-int/lit8 p5, p5, 0x8

    if-eqz p5, :cond_3

    iget-object p4, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->userAgent:Ljava/lang/String;

    :cond_3
    invoke-virtual {p0, p1, p2, p3, p4}, Lio/flutter/plugins/videoplayer/CreationOptions;->copy(Ljava/lang/String;Lio/flutter/plugins/videoplayer/PlatformVideoFormat;Ljava/util/Map;Ljava/lang/String;)Lio/flutter/plugins/videoplayer/CreationOptions;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method public final component1()Ljava/lang/String;
    .locals 1

    iget-object v0, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->uri:Ljava/lang/String;

    return-object v0
.end method

.method public final component2()Lio/flutter/plugins/videoplayer/PlatformVideoFormat;
    .locals 1

    iget-object v0, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->formatHint:Lio/flutter/plugins/videoplayer/PlatformVideoFormat;

    return-object v0
.end method

.method public final component3()Ljava/util/Map;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    iget-object v0, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->httpHeaders:Ljava/util/Map;

    return-object v0
.end method

.method public final component4()Ljava/lang/String;
    .locals 1

    iget-object v0, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->userAgent:Ljava/lang/String;

    return-object v0
.end method

.method public final copy(Ljava/lang/String;Lio/flutter/plugins/videoplayer/PlatformVideoFormat;Ljava/util/Map;Ljava/lang/String;)Lio/flutter/plugins/videoplayer/CreationOptions;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/String;",
            "Lio/flutter/plugins/videoplayer/PlatformVideoFormat;",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;",
            "Ljava/lang/String;",
            ")",
            "Lio/flutter/plugins/videoplayer/CreationOptions;"
        }
    .end annotation

    const-string v0, "uri"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "httpHeaders"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    new-instance v0, Lio/flutter/plugins/videoplayer/CreationOptions;

    invoke-direct {v0, p1, p2, p3, p4}, Lio/flutter/plugins/videoplayer/CreationOptions;-><init>(Ljava/lang/String;Lio/flutter/plugins/videoplayer/PlatformVideoFormat;Ljava/util/Map;Ljava/lang/String;)V

    return-object v0
.end method

.method public equals(Ljava/lang/Object;)Z
    .locals 2

    .line 325
    instance-of v0, p1, Lio/flutter/plugins/videoplayer/CreationOptions;

    if-nez v0, :cond_0

    const/4 p1, 0x0

    return p1

    :cond_0
    if-ne p0, p1, :cond_1

    const/4 p1, 0x1

    return p1

    .line 331
    :cond_1
    sget-object v0, Lio/flutter/plugins/videoplayer/MessagesPigeonUtils;->INSTANCE:Lio/flutter/plugins/videoplayer/MessagesPigeonUtils;

    invoke-virtual {p0}, Lio/flutter/plugins/videoplayer/CreationOptions;->toList()Ljava/util/List;

    move-result-object v1

    check-cast p1, Lio/flutter/plugins/videoplayer/CreationOptions;

    invoke-virtual {p1}, Lio/flutter/plugins/videoplayer/CreationOptions;->toList()Ljava/util/List;

    move-result-object p1

    invoke-virtual {v0, v1, p1}, Lio/flutter/plugins/videoplayer/MessagesPigeonUtils;->deepEquals(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p1

    return p1
.end method

.method public final getFormatHint()Lio/flutter/plugins/videoplayer/PlatformVideoFormat;
    .locals 1

    .line 301
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->formatHint:Lio/flutter/plugins/videoplayer/PlatformVideoFormat;

    return-object v0
.end method

.method public final getHttpHeaders()Ljava/util/Map;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .line 302
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->httpHeaders:Ljava/util/Map;

    return-object v0
.end method

.method public final getUri()Ljava/lang/String;
    .locals 1

    .line 300
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->uri:Ljava/lang/String;

    return-object v0
.end method

.method public final getUserAgent()Ljava/lang/String;
    .locals 1

    .line 303
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->userAgent:Ljava/lang/String;

    return-object v0
.end method

.method public hashCode()I
    .locals 1

    .line 334
    invoke-virtual {p0}, Lio/flutter/plugins/videoplayer/CreationOptions;->toList()Ljava/util/List;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->hashCode()I

    move-result v0

    return v0
.end method

.method public final toList()Ljava/util/List;
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation

    .line 317
    iget-object v0, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->uri:Ljava/lang/String;

    .line 318
    iget-object v1, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->formatHint:Lio/flutter/plugins/videoplayer/PlatformVideoFormat;

    .line 319
    iget-object v2, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->httpHeaders:Ljava/util/Map;

    .line 320
    iget-object v3, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->userAgent:Ljava/lang/String;

    filled-new-array {v0, v1, v2, v3}, [Ljava/lang/Object;

    move-result-object v0

    .line 316
    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->listOf([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    return-object v0
.end method

.method public toString()Ljava/lang/String;
    .locals 6

    iget-object v0, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->uri:Ljava/lang/String;

    iget-object v1, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->formatHint:Lio/flutter/plugins/videoplayer/PlatformVideoFormat;

    iget-object v2, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->httpHeaders:Ljava/util/Map;

    iget-object v3, p0, Lio/flutter/plugins/videoplayer/CreationOptions;->userAgent:Ljava/lang/String;

    new-instance v4, Ljava/lang/StringBuilder;

    const-string v5, "CreationOptions(uri="

    invoke-direct {v4, v5}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v4, ", formatHint="

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", httpHeaders="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", userAgent="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ")"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
