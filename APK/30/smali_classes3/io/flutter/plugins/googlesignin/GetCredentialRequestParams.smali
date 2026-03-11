.class public final Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;
.super Ljava/lang/Object;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/googlesignin/GetCredentialRequestParams$Companion;
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000.\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000b\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u000e\n\u0002\u0008\r\n\u0002\u0010 \n\u0002\u0008\u0003\n\u0002\u0010\u0008\n\u0002\u0008\t\u0008\u0086\u0008\u0018\u0000 !2\u00020\u0001:\u0001!B;\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0006\u0010\u0004\u001a\u00020\u0005\u0012\n\u0008\u0002\u0010\u0006\u001a\u0004\u0018\u00010\u0007\u0012\n\u0008\u0002\u0010\u0008\u001a\u0004\u0018\u00010\u0007\u0012\n\u0008\u0002\u0010\t\u001a\u0004\u0018\u00010\u0007\u00a2\u0006\u0004\u0008\n\u0010\u000bJ\u000e\u0010\u0014\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\u00010\u0015J\u0013\u0010\u0016\u001a\u00020\u00032\u0008\u0010\u0017\u001a\u0004\u0018\u00010\u0001H\u0096\u0002J\u0008\u0010\u0018\u001a\u00020\u0019H\u0016J\t\u0010\u001a\u001a\u00020\u0003H\u00c6\u0003J\t\u0010\u001b\u001a\u00020\u0005H\u00c6\u0003J\u000b\u0010\u001c\u001a\u0004\u0018\u00010\u0007H\u00c6\u0003J\u000b\u0010\u001d\u001a\u0004\u0018\u00010\u0007H\u00c6\u0003J\u000b\u0010\u001e\u001a\u0004\u0018\u00010\u0007H\u00c6\u0003JA\u0010\u001f\u001a\u00020\u00002\u0008\u0008\u0002\u0010\u0002\u001a\u00020\u00032\u0008\u0008\u0002\u0010\u0004\u001a\u00020\u00052\n\u0008\u0002\u0010\u0006\u001a\u0004\u0018\u00010\u00072\n\u0008\u0002\u0010\u0008\u001a\u0004\u0018\u00010\u00072\n\u0008\u0002\u0010\t\u001a\u0004\u0018\u00010\u0007H\u00c6\u0001J\t\u0010 \u001a\u00020\u0007H\u00d6\u0001R\u0011\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u000c\u0010\rR\u0011\u0010\u0004\u001a\u00020\u0005\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u000e\u0010\u000fR\u0013\u0010\u0006\u001a\u0004\u0018\u00010\u0007\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0010\u0010\u0011R\u0013\u0010\u0008\u001a\u0004\u0018\u00010\u0007\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0012\u0010\u0011R\u0013\u0010\t\u001a\u0004\u0018\u00010\u0007\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0013\u0010\u0011\u00a8\u0006\""
    }
    d2 = {
        "Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;",
        "",
        "useButtonFlow",
        "",
        "googleIdOptionParams",
        "Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;",
        "serverClientId",
        "",
        "hostedDomain",
        "nonce",
        "<init>",
        "(ZLio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
        "getUseButtonFlow",
        "()Z",
        "getGoogleIdOptionParams",
        "()Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;",
        "getServerClientId",
        "()Ljava/lang/String;",
        "getHostedDomain",
        "getNonce",
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
.field public static final Companion:Lio/flutter/plugins/googlesignin/GetCredentialRequestParams$Companion;


# instance fields
.field private final googleIdOptionParams:Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;

.field private final hostedDomain:Ljava/lang/String;

.field private final nonce:Ljava/lang/String;

.field private final serverClientId:Ljava/lang/String;

.field private final useButtonFlow:Z


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams$Companion;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams$Companion;-><init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V

    sput-object v0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->Companion:Lio/flutter/plugins/googlesignin/GetCredentialRequestParams$Companion;

    return-void
.end method

.method public constructor <init>(ZLio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    .locals 1

    const-string v0, "googleIdOptionParams"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 193
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 199
    iput-boolean p1, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->useButtonFlow:Z

    .line 205
    iput-object p2, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->googleIdOptionParams:Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;

    .line 206
    iput-object p3, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->serverClientId:Ljava/lang/String;

    .line 207
    iput-object p4, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->hostedDomain:Ljava/lang/String;

    .line 208
    iput-object p5, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->nonce:Ljava/lang/String;

    return-void
.end method

.method public synthetic constructor <init>(ZLio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILkotlin/jvm/internal/DefaultConstructorMarker;)V
    .locals 1

    and-int/lit8 p7, p6, 0x4

    const/4 v0, 0x0

    if-eqz p7, :cond_0

    move-object p3, v0

    :cond_0
    and-int/lit8 p7, p6, 0x8

    if-eqz p7, :cond_1

    move-object p4, v0

    :cond_1
    and-int/lit8 p6, p6, 0x10

    if-eqz p6, :cond_2

    move-object p6, v0

    goto :goto_0

    :cond_2
    move-object p6, p5

    :goto_0
    move-object p5, p4

    move-object p4, p3

    move-object p3, p2

    move p2, p1

    move-object p1, p0

    .line 193
    invoke-direct/range {p1 .. p6}, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;-><init>(ZLio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    return-void
.end method

.method public static synthetic copy$default(Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;ZLio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/Object;)Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;
    .locals 0

    and-int/lit8 p7, p6, 0x1

    if-eqz p7, :cond_0

    iget-boolean p1, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->useButtonFlow:Z

    :cond_0
    and-int/lit8 p7, p6, 0x2

    if-eqz p7, :cond_1

    iget-object p2, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->googleIdOptionParams:Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;

    :cond_1
    and-int/lit8 p7, p6, 0x4

    if-eqz p7, :cond_2

    iget-object p3, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->serverClientId:Ljava/lang/String;

    :cond_2
    and-int/lit8 p7, p6, 0x8

    if-eqz p7, :cond_3

    iget-object p4, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->hostedDomain:Ljava/lang/String;

    :cond_3
    and-int/lit8 p6, p6, 0x10

    if-eqz p6, :cond_4

    iget-object p5, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->nonce:Ljava/lang/String;

    :cond_4
    move-object p6, p4

    move-object p7, p5

    move-object p4, p2

    move-object p5, p3

    move-object p2, p0

    move p3, p1

    invoke-virtual/range {p2 .. p7}, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->copy(ZLio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method public final component1()Z
    .locals 1

    iget-boolean v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->useButtonFlow:Z

    return v0
.end method

.method public final component2()Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;
    .locals 1

    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->googleIdOptionParams:Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;

    return-object v0
.end method

.method public final component3()Ljava/lang/String;
    .locals 1

    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->serverClientId:Ljava/lang/String;

    return-object v0
.end method

.method public final component4()Ljava/lang/String;
    .locals 1

    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->hostedDomain:Ljava/lang/String;

    return-object v0
.end method

.method public final component5()Ljava/lang/String;
    .locals 1

    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->nonce:Ljava/lang/String;

    return-object v0
.end method

.method public final copy(ZLio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;
    .locals 7

    const-string v0, "googleIdOptionParams"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    new-instance v1, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;

    move v2, p1

    move-object v3, p2

    move-object v4, p3

    move-object v5, p4

    move-object v6, p5

    invoke-direct/range {v1 .. v6}, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;-><init>(ZLio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    return-object v1
.end method

.method public equals(Ljava/lang/Object;)Z
    .locals 2

    .line 233
    instance-of v0, p1, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;

    if-nez v0, :cond_0

    const/4 p1, 0x0

    return p1

    :cond_0
    if-ne p0, p1, :cond_1

    const/4 p1, 0x1

    return p1

    .line 239
    :cond_1
    sget-object v0, Lio/flutter/plugins/googlesignin/MessagesPigeonUtils;->INSTANCE:Lio/flutter/plugins/googlesignin/MessagesPigeonUtils;

    invoke-virtual {p0}, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->toList()Ljava/util/List;

    move-result-object v1

    check-cast p1, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;

    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->toList()Ljava/util/List;

    move-result-object p1

    invoke-virtual {v0, v1, p1}, Lio/flutter/plugins/googlesignin/MessagesPigeonUtils;->deepEquals(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p1

    return p1
.end method

.method public final getGoogleIdOptionParams()Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;
    .locals 1

    .line 205
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->googleIdOptionParams:Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;

    return-object v0
.end method

.method public final getHostedDomain()Ljava/lang/String;
    .locals 1

    .line 207
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->hostedDomain:Ljava/lang/String;

    return-object v0
.end method

.method public final getNonce()Ljava/lang/String;
    .locals 1

    .line 208
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->nonce:Ljava/lang/String;

    return-object v0
.end method

.method public final getServerClientId()Ljava/lang/String;
    .locals 1

    .line 206
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->serverClientId:Ljava/lang/String;

    return-object v0
.end method

.method public final getUseButtonFlow()Z
    .locals 1

    .line 199
    iget-boolean v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->useButtonFlow:Z

    return v0
.end method

.method public hashCode()I
    .locals 1

    .line 242
    invoke-virtual {p0}, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->toList()Ljava/util/List;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->hashCode()I

    move-result v0

    return v0
.end method

.method public final toList()Ljava/util/List;
    .locals 5
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation

    .line 224
    iget-boolean v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->useButtonFlow:Z

    invoke-static {v0}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v0

    .line 225
    iget-object v1, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->googleIdOptionParams:Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;

    .line 226
    iget-object v2, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->serverClientId:Ljava/lang/String;

    .line 227
    iget-object v3, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->hostedDomain:Ljava/lang/String;

    .line 228
    iget-object v4, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->nonce:Ljava/lang/String;

    filled-new-array {v0, v1, v2, v3, v4}, [Ljava/lang/Object;

    move-result-object v0

    .line 223
    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->listOf([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    return-object v0
.end method

.method public toString()Ljava/lang/String;
    .locals 7

    iget-boolean v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->useButtonFlow:Z

    iget-object v1, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->googleIdOptionParams:Lio/flutter/plugins/googlesignin/GetCredentialRequestGoogleIdOptionParams;

    iget-object v2, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->serverClientId:Ljava/lang/String;

    iget-object v3, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->hostedDomain:Ljava/lang/String;

    iget-object v4, p0, Lio/flutter/plugins/googlesignin/GetCredentialRequestParams;->nonce:Ljava/lang/String;

    new-instance v5, Ljava/lang/StringBuilder;

    const-string v6, "GetCredentialRequestParams(useButtonFlow="

    invoke-direct {v5, v6}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v5, v0}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v5, ", googleIdOptionParams="

    invoke-virtual {v0, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", serverClientId="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", hostedDomain="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", nonce="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ")"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
