.class public final enum Lio/flutter/plugins/googlesignin/AuthorizeFailureType;
.super Ljava/lang/Enum;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/googlesignin/AuthorizeFailureType$Companion;
    }
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Enum<",
        "Lio/flutter/plugins/googlesignin/AuthorizeFailureType;",
        ">;"
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000\u0012\n\u0002\u0018\u0002\n\u0002\u0010\u0010\n\u0000\n\u0002\u0010\u0008\n\u0002\u0008\u000b\u0008\u0086\u0081\u0002\u0018\u0000 \r2\u0008\u0012\u0004\u0012\u00020\u00000\u0001:\u0001\rB\u0011\u0008\u0002\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0004\u0008\u0004\u0010\u0005R\u0011\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0006\u0010\u0007j\u0002\u0008\u0008j\u0002\u0008\tj\u0002\u0008\nj\u0002\u0008\u000bj\u0002\u0008\u000c\u00a8\u0006\u000e"
    }
    d2 = {
        "Lio/flutter/plugins/googlesignin/AuthorizeFailureType;",
        "",
        "raw",
        "",
        "<init>",
        "(Ljava/lang/String;II)V",
        "getRaw",
        "()I",
        "UNAUTHORIZED",
        "AUTHORIZE_FAILURE",
        "PENDING_INTENT_EXCEPTION",
        "API_EXCEPTION",
        "NO_ACTIVITY",
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
.field private static final synthetic $ENTRIES:Lkotlin/enums/EnumEntries;

.field private static final synthetic $VALUES:[Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

.field public static final enum API_EXCEPTION:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

.field public static final enum AUTHORIZE_FAILURE:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

.field public static final Companion:Lio/flutter/plugins/googlesignin/AuthorizeFailureType$Companion;

.field public static final enum NO_ACTIVITY:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

.field public static final enum PENDING_INTENT_EXCEPTION:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

.field public static final enum UNAUTHORIZED:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;


# instance fields
.field private final raw:I


# direct methods
.method private static final synthetic $values()[Lio/flutter/plugins/googlesignin/AuthorizeFailureType;
    .locals 5

    sget-object v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->UNAUTHORIZED:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    sget-object v1, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->AUTHORIZE_FAILURE:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    sget-object v2, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->PENDING_INTENT_EXCEPTION:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    sget-object v3, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->API_EXCEPTION:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    sget-object v4, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->NO_ACTIVITY:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    filled-new-array {v0, v1, v2, v3, v4}, [Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    move-result-object v0

    return-object v0
.end method

.method static constructor <clinit>()V
    .locals 3

    .line 112
    new-instance v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    const-string v1, "UNAUTHORIZED"

    const/4 v2, 0x0

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->UNAUTHORIZED:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    .line 114
    new-instance v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    const-string v1, "AUTHORIZE_FAILURE"

    const/4 v2, 0x1

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->AUTHORIZE_FAILURE:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    .line 118
    new-instance v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    const-string v1, "PENDING_INTENT_EXCEPTION"

    const/4 v2, 0x2

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->PENDING_INTENT_EXCEPTION:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    .line 123
    new-instance v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    const-string v1, "API_EXCEPTION"

    const/4 v2, 0x3

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->API_EXCEPTION:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    .line 128
    new-instance v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    const-string v1, "NO_ACTIVITY"

    const/4 v2, 0x4

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->NO_ACTIVITY:Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    invoke-static {}, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->$values()[Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    move-result-object v0

    sput-object v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->$VALUES:[Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    check-cast v0, [Ljava/lang/Enum;

    invoke-static {v0}, Lkotlin/enums/EnumEntriesKt;->enumEntries([Ljava/lang/Enum;)Lkotlin/enums/EnumEntries;

    move-result-object v0

    sput-object v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->$ENTRIES:Lkotlin/enums/EnumEntries;

    new-instance v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType$Companion;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Lio/flutter/plugins/googlesignin/AuthorizeFailureType$Companion;-><init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V

    sput-object v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->Companion:Lio/flutter/plugins/googlesignin/AuthorizeFailureType$Companion;

    return-void
.end method

.method private constructor <init>(Ljava/lang/String;II)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I)V"
        }
    .end annotation

    .line 105
    invoke-direct {p0, p1, p2}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    iput p3, p0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->raw:I

    return-void
.end method

.method public static getEntries()Lkotlin/enums/EnumEntries;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Lkotlin/enums/EnumEntries<",
            "Lio/flutter/plugins/googlesignin/AuthorizeFailureType;",
            ">;"
        }
    .end annotation

    sget-object v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->$ENTRIES:Lkotlin/enums/EnumEntries;

    return-object v0
.end method

.method public static valueOf(Ljava/lang/String;)Lio/flutter/plugins/googlesignin/AuthorizeFailureType;
    .locals 1

    const-class v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    move-result-object p0

    check-cast p0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    return-object p0
.end method

.method public static values()[Lio/flutter/plugins/googlesignin/AuthorizeFailureType;
    .locals 1

    sget-object v0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->$VALUES:[Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    invoke-virtual {v0}, Ljava/lang/Object;->clone()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Lio/flutter/plugins/googlesignin/AuthorizeFailureType;

    return-object v0
.end method


# virtual methods
.method public final getRaw()I
    .locals 1

    .line 105
    iget v0, p0, Lio/flutter/plugins/googlesignin/AuthorizeFailureType;->raw:I

    return v0
.end method
