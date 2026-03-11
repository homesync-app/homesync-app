.class public final enum Lio/flutter/plugins/googlesignin/GetCredentialFailureType;
.super Ljava/lang/Enum;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/googlesignin/GetCredentialFailureType$Companion;
    }
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Enum<",
        "Lio/flutter/plugins/googlesignin/GetCredentialFailureType;",
        ">;"
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000\u0012\n\u0002\u0018\u0002\n\u0002\u0010\u0010\n\u0000\n\u0002\u0010\u0008\n\u0002\u0008\u000f\u0008\u0086\u0081\u0002\u0018\u0000 \u00112\u0008\u0012\u0004\u0012\u00020\u00000\u0001:\u0001\u0011B\u0011\u0008\u0002\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0004\u0008\u0004\u0010\u0005R\u0011\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0006\u0010\u0007j\u0002\u0008\u0008j\u0002\u0008\tj\u0002\u0008\nj\u0002\u0008\u000bj\u0002\u0008\u000cj\u0002\u0008\rj\u0002\u0008\u000ej\u0002\u0008\u000fj\u0002\u0008\u0010\u00a8\u0006\u0012"
    }
    d2 = {
        "Lio/flutter/plugins/googlesignin/GetCredentialFailureType;",
        "",
        "raw",
        "",
        "<init>",
        "(Ljava/lang/String;II)V",
        "getRaw",
        "()I",
        "UNEXPECTED_CREDENTIAL_TYPE",
        "MISSING_SERVER_CLIENT_ID",
        "NO_ACTIVITY",
        "INTERRUPTED",
        "CANCELED",
        "NO_CREDENTIAL",
        "PROVIDER_CONFIGURATION_ISSUE",
        "UNSUPPORTED",
        "UNKNOWN",
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

.field private static final synthetic $VALUES:[Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

.field public static final enum CANCELED:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

.field public static final Companion:Lio/flutter/plugins/googlesignin/GetCredentialFailureType$Companion;

.field public static final enum INTERRUPTED:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

.field public static final enum MISSING_SERVER_CLIENT_ID:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

.field public static final enum NO_ACTIVITY:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

.field public static final enum NO_CREDENTIAL:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

.field public static final enum PROVIDER_CONFIGURATION_ISSUE:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

.field public static final enum UNEXPECTED_CREDENTIAL_TYPE:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

.field public static final enum UNKNOWN:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

.field public static final enum UNSUPPORTED:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;


# instance fields
.field private final raw:I


# direct methods
.method private static final synthetic $values()[Lio/flutter/plugins/googlesignin/GetCredentialFailureType;
    .locals 9

    sget-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->UNEXPECTED_CREDENTIAL_TYPE:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    sget-object v1, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->MISSING_SERVER_CLIENT_ID:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    sget-object v2, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->NO_ACTIVITY:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    sget-object v3, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->INTERRUPTED:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    sget-object v4, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->CANCELED:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    sget-object v5, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->NO_CREDENTIAL:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    sget-object v6, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->PROVIDER_CONFIGURATION_ISSUE:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    sget-object v7, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->UNSUPPORTED:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    sget-object v8, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->UNKNOWN:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    filled-new-array/range {v0 .. v8}, [Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    move-result-object v0

    return-object v0
.end method

.method static constructor <clinit>()V
    .locals 3

    .line 77
    new-instance v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    const-string v1, "UNEXPECTED_CREDENTIAL_TYPE"

    const/4 v2, 0x0

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->UNEXPECTED_CREDENTIAL_TYPE:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    .line 79
    new-instance v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    const-string v1, "MISSING_SERVER_CLIENT_ID"

    const/4 v2, 0x1

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->MISSING_SERVER_CLIENT_ID:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    .line 84
    new-instance v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    const-string v1, "NO_ACTIVITY"

    const/4 v2, 0x2

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->NO_ACTIVITY:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    .line 86
    new-instance v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    const-string v1, "INTERRUPTED"

    const/4 v2, 0x3

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->INTERRUPTED:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    .line 88
    new-instance v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    const-string v1, "CANCELED"

    const/4 v2, 0x4

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->CANCELED:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    .line 90
    new-instance v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    const-string v1, "NO_CREDENTIAL"

    const/4 v2, 0x5

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->NO_CREDENTIAL:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    .line 92
    new-instance v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    const-string v1, "PROVIDER_CONFIGURATION_ISSUE"

    const/4 v2, 0x6

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->PROVIDER_CONFIGURATION_ISSUE:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    .line 94
    new-instance v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    const-string v1, "UNSUPPORTED"

    const/4 v2, 0x7

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->UNSUPPORTED:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    .line 96
    new-instance v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    const-string v1, "UNKNOWN"

    const/16 v2, 0x8

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->UNKNOWN:Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    invoke-static {}, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->$values()[Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    move-result-object v0

    sput-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->$VALUES:[Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    check-cast v0, [Ljava/lang/Enum;

    invoke-static {v0}, Lkotlin/enums/EnumEntriesKt;->enumEntries([Ljava/lang/Enum;)Lkotlin/enums/EnumEntries;

    move-result-object v0

    sput-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->$ENTRIES:Lkotlin/enums/EnumEntries;

    new-instance v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType$Companion;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Lio/flutter/plugins/googlesignin/GetCredentialFailureType$Companion;-><init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V

    sput-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->Companion:Lio/flutter/plugins/googlesignin/GetCredentialFailureType$Companion;

    return-void
.end method

.method private constructor <init>(Ljava/lang/String;II)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I)V"
        }
    .end annotation

    .line 75
    invoke-direct {p0, p1, p2}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    iput p3, p0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->raw:I

    return-void
.end method

.method public static getEntries()Lkotlin/enums/EnumEntries;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Lkotlin/enums/EnumEntries<",
            "Lio/flutter/plugins/googlesignin/GetCredentialFailureType;",
            ">;"
        }
    .end annotation

    sget-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->$ENTRIES:Lkotlin/enums/EnumEntries;

    return-object v0
.end method

.method public static valueOf(Ljava/lang/String;)Lio/flutter/plugins/googlesignin/GetCredentialFailureType;
    .locals 1

    const-class v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    move-result-object p0

    check-cast p0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    return-object p0
.end method

.method public static values()[Lio/flutter/plugins/googlesignin/GetCredentialFailureType;
    .locals 1

    sget-object v0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->$VALUES:[Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    invoke-virtual {v0}, Ljava/lang/Object;->clone()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    return-object v0
.end method


# virtual methods
.method public final getRaw()I
    .locals 1

    .line 75
    iget v0, p0, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->raw:I

    return v0
.end method
