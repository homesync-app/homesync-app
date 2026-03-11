.class public final Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;
.super Lio/flutter/plugins/googlesignin/AuthorizeResult;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult$Companion;
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u00000\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u000e\n\u0002\u0008\u0002\n\u0002\u0010 \n\u0002\u0008\u0008\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000b\n\u0002\u0008\u0002\n\u0002\u0010\u0008\n\u0002\u0008\u0007\u0008\u0086\u0008\u0018\u0000 \u001a2\u00020\u0001:\u0001\u001aB-\u0012\n\u0008\u0002\u0010\u0002\u001a\u0004\u0018\u00010\u0003\u0012\n\u0008\u0002\u0010\u0004\u001a\u0004\u0018\u00010\u0003\u0012\u000c\u0010\u0005\u001a\u0008\u0012\u0004\u0012\u00020\u00030\u0006\u00a2\u0006\u0004\u0008\u0007\u0010\u0008J\u000e\u0010\u000e\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u000f0\u0006J\u0013\u0010\u0010\u001a\u00020\u00112\u0008\u0010\u0012\u001a\u0004\u0018\u00010\u000fH\u0096\u0002J\u0008\u0010\u0013\u001a\u00020\u0014H\u0016J\u000b\u0010\u0015\u001a\u0004\u0018\u00010\u0003H\u00c6\u0003J\u000b\u0010\u0016\u001a\u0004\u0018\u00010\u0003H\u00c6\u0003J\u000f\u0010\u0017\u001a\u0008\u0012\u0004\u0012\u00020\u00030\u0006H\u00c6\u0003J1\u0010\u0018\u001a\u00020\u00002\n\u0008\u0002\u0010\u0002\u001a\u0004\u0018\u00010\u00032\n\u0008\u0002\u0010\u0004\u001a\u0004\u0018\u00010\u00032\u000e\u0008\u0002\u0010\u0005\u001a\u0008\u0012\u0004\u0012\u00020\u00030\u0006H\u00c6\u0001J\t\u0010\u0019\u001a\u00020\u0003H\u00d6\u0001R\u0013\u0010\u0002\u001a\u0004\u0018\u00010\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\t\u0010\nR\u0013\u0010\u0004\u001a\u0004\u0018\u00010\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u000b\u0010\nR\u0017\u0010\u0005\u001a\u0008\u0012\u0004\u0012\u00020\u00030\u0006\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u000c\u0010\r\u00a8\u0006\u001b"
    }
    d2 = {
        "Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;",
        "Lio/flutter/plugins/googlesignin/AuthorizeResult;",
        "accessToken",
        "",
        "serverAuthCode",
        "grantedScopes",
        "",
        "<init>",
        "(Ljava/lang/String;Ljava/lang/String;Ljava/util/List;)V",
        "getAccessToken",
        "()Ljava/lang/String;",
        "getServerAuthCode",
        "getGrantedScopes",
        "()Ljava/util/List;",
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
        "copy",
        "toString",
        "Companion",
        "google_sign_in_android_release"
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
.field public static final Companion:Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult$Companion;


# instance fields
.field private final accessToken:Ljava/lang/String;

.field private final grantedScopes:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field private final serverAuthCode:Ljava/lang/String;


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult$Companion;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult$Companion;-><init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V

    sput-object v0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->Companion:Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult$Companion;

    return-void
.end method

.method public constructor <init>(Ljava/lang/String;Ljava/lang/String;Ljava/util/List;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;)V"
        }
    .end annotation

    const-string v0, "grantedScopes"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const/4 v0, 0x0

    .line 519
    invoke-direct {p0, v0}, Lio/flutter/plugins/googlesignin/AuthorizeResult;-><init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V

    .line 520
    iput-object p1, p0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->accessToken:Ljava/lang/String;

    .line 521
    iput-object p2, p0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->serverAuthCode:Ljava/lang/String;

    .line 522
    iput-object p3, p0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->grantedScopes:Ljava/util/List;

    return-void
.end method

.method public synthetic constructor <init>(Ljava/lang/String;Ljava/lang/String;Ljava/util/List;ILkotlin/jvm/internal/DefaultConstructorMarker;)V
    .locals 1

    and-int/lit8 p5, p4, 0x1

    const/4 v0, 0x0

    if-eqz p5, :cond_0

    move-object p1, v0

    :cond_0
    and-int/lit8 p4, p4, 0x2

    if-eqz p4, :cond_1

    move-object p2, v0

    .line 519
    :cond_1
    invoke-direct {p0, p1, p2, p3}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/util/List;)V

    return-void
.end method

.method public static synthetic copy$default(Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;Ljava/lang/String;Ljava/lang/String;Ljava/util/List;ILjava/lang/Object;)Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;
    .locals 0

    and-int/lit8 p5, p4, 0x1

    if-eqz p5, :cond_0

    iget-object p1, p0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->accessToken:Ljava/lang/String;

    :cond_0
    and-int/lit8 p5, p4, 0x2

    if-eqz p5, :cond_1

    iget-object p2, p0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->serverAuthCode:Ljava/lang/String;

    :cond_1
    and-int/lit8 p4, p4, 0x4

    if-eqz p4, :cond_2

    iget-object p3, p0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->grantedScopes:Ljava/util/List;

    :cond_2
    invoke-virtual {p0, p1, p2, p3}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->copy(Ljava/lang/String;Ljava/lang/String;Ljava/util/List;)Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method public final component1()Ljava/lang/String;
    .locals 1

    iget-object v0, p0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->accessToken:Ljava/lang/String;

    return-object v0
.end method

.method public final component2()Ljava/lang/String;
    .locals 1

    iget-object v0, p0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->serverAuthCode:Ljava/lang/String;

    return-object v0
.end method

.method public final component3()Ljava/util/List;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    iget-object v0, p0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->grantedScopes:Ljava/util/List;

    return-object v0
.end method

.method public final copy(Ljava/lang/String;Ljava/lang/String;Ljava/util/List;)Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;)",
            "Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;"
        }
    .end annotation

    const-string v0, "grantedScopes"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    new-instance v0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;

    invoke-direct {v0, p1, p2, p3}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/util/List;)V

    return-object v0
.end method

.method public equals(Ljava/lang/Object;)Z
    .locals 2

    .line 542
    instance-of v0, p1, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;

    if-nez v0, :cond_0

    const/4 p1, 0x0

    return p1

    :cond_0
    if-ne p0, p1, :cond_1

    const/4 p1, 0x1

    return p1

    .line 548
    :cond_1
    sget-object v0, Lio/flutter/plugins/googlesignin/MessagesPigeonUtils;->INSTANCE:Lio/flutter/plugins/googlesignin/MessagesPigeonUtils;

    invoke-virtual {p0}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->toList()Ljava/util/List;

    move-result-object v1

    check-cast p1, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;

    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->toList()Ljava/util/List;

    move-result-object p1

    invoke-virtual {v0, v1, p1}, Lio/flutter/plugins/googlesignin/MessagesPigeonUtils;->deepEquals(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p1

    return p1
.end method

.method public final getAccessToken()Ljava/lang/String;
    .locals 1

    .line 520
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->accessToken:Ljava/lang/String;

    return-object v0
.end method

.method public final getGrantedScopes()Ljava/util/List;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .line 522
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->grantedScopes:Ljava/util/List;

    return-object v0
.end method

.method public final getServerAuthCode()Ljava/lang/String;
    .locals 1

    .line 521
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->serverAuthCode:Ljava/lang/String;

    return-object v0
.end method

.method public hashCode()I
    .locals 1

    .line 551
    invoke-virtual {p0}, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->toList()Ljava/util/List;

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

    .line 535
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->accessToken:Ljava/lang/String;

    .line 536
    iget-object v1, p0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->serverAuthCode:Ljava/lang/String;

    .line 537
    iget-object v2, p0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->grantedScopes:Ljava/util/List;

    filled-new-array {v0, v1, v2}, [Ljava/lang/Object;

    move-result-object v0

    .line 534
    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->listOf([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    return-object v0
.end method

.method public toString()Ljava/lang/String;
    .locals 5

    iget-object v0, p0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->accessToken:Ljava/lang/String;

    iget-object v1, p0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->serverAuthCode:Ljava/lang/String;

    iget-object v2, p0, Lio/flutter/plugins/googlesignin/PlatformAuthorizationResult;->grantedScopes:Ljava/util/List;

    new-instance v3, Ljava/lang/StringBuilder;

    const-string v4, "PlatformAuthorizationResult(accessToken="

    invoke-direct {v3, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v3, ", serverAuthCode="

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", grantedScopes="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ")"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
