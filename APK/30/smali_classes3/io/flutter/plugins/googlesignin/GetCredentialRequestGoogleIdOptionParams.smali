.class public final Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;
.super Ljava/lang/Object;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams$Companion;
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000*\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000b\n\u0002\u0008\u0007\n\u0002\u0010 \n\u0002\u0008\u0003\n\u0002\u0010\u0008\n\u0002\u0008\u0004\n\u0002\u0010\u000e\n\u0002\u0008\u0002\u0008\u0086\u0008\u0018\u0000 \u00152\u00020\u0001:\u0001\u0015B\u0017\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0006\u0010\u0004\u001a\u00020\u0003\u00a2\u0006\u0004\u0008\u0005\u0010\u0006J\u000e\u0010\n\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u000bJ\u0013\u0010\u000c\u001a\u00020\u00032\u0008\u0010\r\u001a\u0004\u0018\u00010\u0001H\u0096\u0002J\u0008\u0010\u000e\u001a\u00020\u000fH\u0016J\t\u0010\u0010\u001a\u00020\u0003H\u00c6\u0003J\t\u0010\u0011\u001a\u00020\u0003H\u00c6\u0003J\u001d\u0010\u0012\u001a\u00020\u00002\u0008\u0008\u0002\u0010\u0002\u001a\u00020\u00032\u0008\u0008\u0002\u0010\u0004\u001a\u00020\u0003H\u00c6\u0001J\t\u0010\u0013\u001a\u00020\u0014H\u00d6\u0001R\u0011\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0007\u0010\u0008R\u0011\u0010\u0004\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\t\u0010\u0008\u00a8\u0006\u0016"
    }
    d2 = {
        "Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;",
        "",
        "filterToAuthorized",
        "",
        "autoSelectEnabled",
        "<init>",
        "(ZZ)V",
        "getFilterToAuthorized",
        "()Z",
        "getAutoSelectEnabled",
        "toList",
        "",
        "equals",
        "other",
        "hashCode",
        "",
        "component1",
        "component2",
        "copy",
        "toString",
        "",
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
.field public static final Companion:Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams$Companion;


# instance fields
.field private final autoSelectEnabled:Z

.field private final filterToAuthorized:Z


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams$Companion;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams$Companion;-><init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V

    sput-object v0, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->Companion:Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams$Companion;

    return-void
.end method

.method public constructor <init>(ZZ)V
    .locals 0

    .line 246
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 247
    iput-boolean p1, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->filterToAuthorized:Z

    .line 248
    iput-boolean p2, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->autoSelectEnabled:Z

    return-void
.end method

.method public static synthetic copy$default(Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;ZZILjava/lang/Object;)Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;
    .locals 0

    and-int/lit8 p4, p3, 0x1

    if-eqz p4, :cond_0

    iget-boolean p1, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->filterToAuthorized:Z

    :cond_0
    and-int/lit8 p3, p3, 0x2

    if-eqz p3, :cond_1

    iget-boolean p2, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->autoSelectEnabled:Z

    :cond_1
    invoke-virtual {p0, p1, p2}, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->copy(ZZ)Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method public final component1()Z
    .locals 1

    iget-boolean v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->filterToAuthorized:Z

    return v0
.end method

.method public final component2()Z
    .locals 1

    iget-boolean v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->autoSelectEnabled:Z

    return v0
.end method

.method public final copy(ZZ)Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;
    .locals 1

    new-instance v0, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;

    invoke-direct {v0, p1, p2}, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;-><init>(ZZ)V

    return-object v0
.end method

.method public equals(Ljava/lang/Object;)Z
    .locals 2

    .line 266
    instance-of v0, p1, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;

    if-nez v0, :cond_0

    const/4 p1, 0x0

    return p1

    :cond_0
    if-ne p0, p1, :cond_1

    const/4 p1, 0x1

    return p1

    .line 272
    :cond_1
    sget-object v0, Lio/flutter/plugins/googlesignin/MessagesPigeonUtils;->INSTANCE:Lio/flutter/plugins/googlesignin/MessagesPigeonUtils;

    invoke-virtual {p0}, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->toList()Ljava/util/List;

    move-result-object v1

    check-cast p1, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;

    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->toList()Ljava/util/List;

    move-result-object p1

    invoke-virtual {v0, v1, p1}, Lio/flutter/plugins/googlesignin/MessagesPigeonUtils;->deepEquals(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p1

    return p1
.end method

.method public final getAutoSelectEnabled()Z
    .locals 1

    .line 248
    iget-boolean v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->autoSelectEnabled:Z

    return v0
.end method

.method public final getFilterToAuthorized()Z
    .locals 1

    .line 247
    iget-boolean v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->filterToAuthorized:Z

    return v0
.end method

.method public hashCode()I
    .locals 1

    .line 275
    invoke-virtual {p0}, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->toList()Ljava/util/List;

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

    .line 260
    new-array v0, v0, [Ljava/lang/Boolean;

    iget-boolean v1, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->filterToAuthorized:Z

    invoke-static {v1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v1

    const/4 v2, 0x0

    aput-object v1, v0, v2

    .line 261
    iget-boolean v1, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->autoSelectEnabled:Z

    invoke-static {v1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v1

    const/4 v2, 0x1

    aput-object v1, v0, v2

    .line 259
    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->listOf([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    return-object v0
.end method

.method public toString()Ljava/lang/String;
    .locals 4

    iget-boolean v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->filterToAuthorized:Z

    iget-boolean v1, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;->autoSelectEnabled:Z

    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "GetCredentialRequestGoogleIdOptionParams(filterToAuthorized="

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v2, ", autoSelectEnabled="

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ")"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
