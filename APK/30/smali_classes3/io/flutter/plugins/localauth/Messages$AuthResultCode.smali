.class public final enum Lio/flutter/plugins/localauth/Messages$AuthResultCode;
.super Ljava/lang/Enum;
.source "Messages.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/localauth/Messages;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x4019
    name = "AuthResultCode"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Enum<",
        "Lio/flutter/plugins/localauth/Messages$AuthResultCode;",
        ">;"
    }
.end annotation


# static fields
.field private static final synthetic $VALUES:[Lio/flutter/plugins/localauth/Messages$AuthResultCode;

.field public static final enum ALREADY_IN_PROGRESS:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

.field public static final enum HARDWARE_UNAVAILABLE:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

.field public static final enum LOCKED_OUT_PERMANENTLY:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

.field public static final enum LOCKED_OUT_TEMPORARILY:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

.field public static final enum NEGATIVE_BUTTON:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

.field public static final enum NOT_ENROLLED:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

.field public static final enum NOT_FRAGMENT_ACTIVITY:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

.field public static final enum NO_ACTIVITY:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

.field public static final enum NO_CREDENTIALS:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

.field public static final enum NO_HARDWARE:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

.field public static final enum NO_SPACE:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

.field public static final enum SECURITY_UPDATE_REQUIRED:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

.field public static final enum SUCCESS:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

.field public static final enum SYSTEM_CANCELED:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

.field public static final enum TIMEOUT:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

.field public static final enum UNKNOWN_ERROR:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

.field public static final enum USER_CANCELED:Lio/flutter/plugins/localauth/Messages$AuthResultCode;


# instance fields
.field final index:I


# direct methods
.method private static synthetic $values()[Lio/flutter/plugins/localauth/Messages$AuthResultCode;
    .locals 18

    .line 69
    sget-object v1, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->SUCCESS:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    sget-object v2, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NEGATIVE_BUTTON:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    sget-object v3, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->USER_CANCELED:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    sget-object v4, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->SYSTEM_CANCELED:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    sget-object v5, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->TIMEOUT:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    sget-object v6, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->ALREADY_IN_PROGRESS:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    sget-object v7, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NO_ACTIVITY:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    sget-object v8, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NOT_FRAGMENT_ACTIVITY:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    sget-object v9, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NO_CREDENTIALS:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    sget-object v10, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NO_HARDWARE:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    sget-object v11, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->HARDWARE_UNAVAILABLE:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    sget-object v12, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NOT_ENROLLED:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    sget-object v13, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->LOCKED_OUT_TEMPORARILY:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    sget-object v14, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->LOCKED_OUT_PERMANENTLY:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    sget-object v15, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NO_SPACE:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    sget-object v16, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->SECURITY_UPDATE_REQUIRED:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    sget-object v17, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->UNKNOWN_ERROR:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    filled-new-array/range {v1 .. v17}, [Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    move-result-object v0

    return-object v0
.end method

.method static constructor <clinit>()V
    .locals 3

    .line 71
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    const-string v1, "SUCCESS"

    const/4 v2, 0x0

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->SUCCESS:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    .line 73
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    const-string v1, "NEGATIVE_BUTTON"

    const/4 v2, 0x1

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NEGATIVE_BUTTON:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    .line 79
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    const-string v1, "USER_CANCELED"

    const/4 v2, 0x2

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->USER_CANCELED:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    .line 81
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    const-string v1, "SYSTEM_CANCELED"

    const/4 v2, 0x3

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->SYSTEM_CANCELED:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    .line 83
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    const-string v1, "TIMEOUT"

    const/4 v2, 0x4

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->TIMEOUT:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    .line 85
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    const-string v1, "ALREADY_IN_PROGRESS"

    const/4 v2, 0x5

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->ALREADY_IN_PROGRESS:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    .line 87
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    const-string v1, "NO_ACTIVITY"

    const/4 v2, 0x6

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NO_ACTIVITY:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    .line 89
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    const-string v1, "NOT_FRAGMENT_ACTIVITY"

    const/4 v2, 0x7

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NOT_FRAGMENT_ACTIVITY:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    .line 91
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    const-string v1, "NO_CREDENTIALS"

    const/16 v2, 0x8

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NO_CREDENTIALS:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    .line 93
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    const-string v1, "NO_HARDWARE"

    const/16 v2, 0x9

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NO_HARDWARE:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    .line 95
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    const-string v1, "HARDWARE_UNAVAILABLE"

    const/16 v2, 0xa

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->HARDWARE_UNAVAILABLE:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    .line 97
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    const-string v1, "NOT_ENROLLED"

    const/16 v2, 0xb

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NOT_ENROLLED:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    .line 99
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    const-string v1, "LOCKED_OUT_TEMPORARILY"

    const/16 v2, 0xc

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->LOCKED_OUT_TEMPORARILY:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    .line 101
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    const-string v1, "LOCKED_OUT_PERMANENTLY"

    const/16 v2, 0xd

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->LOCKED_OUT_PERMANENTLY:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    .line 103
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    const-string v1, "NO_SPACE"

    const/16 v2, 0xe

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->NO_SPACE:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    .line 105
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    const-string v1, "SECURITY_UPDATE_REQUIRED"

    const/16 v2, 0xf

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->SECURITY_UPDATE_REQUIRED:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    .line 107
    new-instance v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    const-string v1, "UNKNOWN_ERROR"

    const/16 v2, 0x10

    invoke-direct {v0, v1, v2, v2}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->UNKNOWN_ERROR:Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    .line 69
    invoke-static {}, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->$values()[Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    move-result-object v0

    sput-object v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->$VALUES:[Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    return-void
.end method

.method private constructor <init>(Ljava/lang/String;II)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x1000,
            0x1000,
            0x10
        }
        names = {
            null,
            null,
            null
        }
    .end annotation

    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I)V"
        }
    .end annotation

    .line 111
    invoke-direct {p0, p1, p2}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    .line 112
    iput p3, p0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->index:I

    return-void
.end method

.method public static valueOf(Ljava/lang/String;)Lio/flutter/plugins/localauth/Messages$AuthResultCode;
    .locals 1
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8000
        }
        names = {
            null
        }
    .end annotation

    .line 69
    const-class v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    move-result-object p0

    check-cast p0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    return-object p0
.end method

.method public static values()[Lio/flutter/plugins/localauth/Messages$AuthResultCode;
    .locals 1

    .line 69
    sget-object v0, Lio/flutter/plugins/localauth/Messages$AuthResultCode;->$VALUES:[Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    invoke-virtual {v0}, [Lio/flutter/plugins/localauth/Messages$AuthResultCode;->clone()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Lio/flutter/plugins/localauth/Messages$AuthResultCode;

    return-object v0
.end method
