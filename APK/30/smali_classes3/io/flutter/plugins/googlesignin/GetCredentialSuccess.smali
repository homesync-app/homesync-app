.class public final Lio/flutter/plugins/googlesignin/GetCredentialSuccess;
.super Lio/flutter/plugins/googlesignin/GetCredentialResult;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/googlesignin/GetCredentialSuccess$Companion;
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u00004\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0008\u0005\n\u0002\u0010 \n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000b\n\u0002\u0008\u0002\n\u0002\u0010\u0008\n\u0002\u0008\u0003\n\u0002\u0010\u000e\n\u0002\u0008\u0002\u0008\u0086\u0008\u0018\u0000 \u00142\u00020\u0001:\u0001\u0014B\u000f\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0004\u0008\u0004\u0010\u0005J\u000e\u0010\u0008\u001a\n\u0012\u0006\u0012\u0004\u0018\u00010\n0\tJ\u0013\u0010\u000b\u001a\u00020\u000c2\u0008\u0010\r\u001a\u0004\u0018\u00010\nH\u0096\u0002J\u0008\u0010\u000e\u001a\u00020\u000fH\u0016J\t\u0010\u0010\u001a\u00020\u0003H\u00c6\u0003J\u0013\u0010\u0011\u001a\u00020\u00002\u0008\u0008\u0002\u0010\u0002\u001a\u00020\u0003H\u00c6\u0001J\t\u0010\u0012\u001a\u00020\u0013H\u00d6\u0001R\u0011\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0006\u0010\u0007\u00a8\u0006\u0015"
    }
    d2 = {
        "Lio/flutter/plugins/googlesignin/GetCredentialSuccess;",
        "Lio/flutter/plugins/googlesignin/GetCredentialResult;",
        "credential",
        "Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;",
        "<init>",
        "(Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;)V",
        "getCredential",
        "()Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;",
        "toList",
        "",
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
.field public static final Companion:Lio/flutter/plugins/googlesignin/GetCredentialSuccess$Companion;


# instance fields
.field private final credential:Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Lio/flutter/plugins/googlesignin/GetCredentialSuccess$Companion;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Lio/flutter/plugins/googlesignin/GetCredentialSuccess$Companion;-><init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V

    sput-object v0, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;->Companion:Lio/flutter/plugins/googlesignin/GetCredentialSuccess$Companion;

    return-void
.end method

.method public constructor <init>(Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;)V
    .locals 1

    const-string v0, "credential"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const/4 v0, 0x0

    .line 434
    invoke-direct {p0, v0}, Lio/flutter/plugins/googlesignin/GetCredentialResult;-><init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V

    iput-object p1, p0, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;->credential:Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;

    return-void
.end method

.method public static synthetic copy$default(Lio/flutter/plugins/googlesignin/GetCredentialSuccess;Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;ILjava/lang/Object;)Lio/flutter/plugins/googlesignin/GetCredentialSuccess;
    .locals 0

    and-int/lit8 p2, p2, 0x1

    if-eqz p2, :cond_0

    iget-object p1, p0, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;->credential:Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;

    :cond_0
    invoke-virtual {p0, p1}, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;->copy(Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;)Lio/flutter/plugins/googlesignin/GetCredentialSuccess;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method public final component1()Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;
    .locals 1

    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;->credential:Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;

    return-object v0
.end method

.method public final copy(Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;)Lio/flutter/plugins/googlesignin/GetCredentialSuccess;
    .locals 1

    const-string v0, "credential"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    new-instance v0, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;

    invoke-direct {v0, p1}, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;-><init>(Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;)V

    return-object v0
.end method

.method public equals(Ljava/lang/Object;)Z
    .locals 2

    .line 450
    instance-of v0, p1, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;

    if-nez v0, :cond_0

    const/4 p1, 0x0

    return p1

    :cond_0
    if-ne p0, p1, :cond_1

    const/4 p1, 0x1

    return p1

    .line 456
    :cond_1
    sget-object v0, Lio/flutter/plugins/googlesignin/MessagesPigeonUtils;->INSTANCE:Lio/flutter/plugins/googlesignin/MessagesPigeonUtils;

    invoke-virtual {p0}, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;->toList()Ljava/util/List;

    move-result-object v1

    check-cast p1, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;

    invoke-virtual {p1}, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;->toList()Ljava/util/List;

    move-result-object p1

    invoke-virtual {v0, v1, p1}, Lio/flutter/plugins/googlesignin/MessagesPigeonUtils;->deepEquals(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p1

    return p1
.end method

.method public final getCredential()Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;
    .locals 1

    .line 434
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;->credential:Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;

    return-object v0
.end method

.method public hashCode()I
    .locals 1

    .line 459
    invoke-virtual {p0}, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;->toList()Ljava/util/List;

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

    .line 445
    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;->credential:Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;

    .line 444
    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->listOf(Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    return-object v0
.end method

.method public toString()Ljava/lang/String;
    .locals 3

    iget-object v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialSuccess;->credential:Lio/flutter/plugins/googlesignin/PlatformGoogleIdTokenCredential;

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "GetCredentialSuccess(credential="

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
