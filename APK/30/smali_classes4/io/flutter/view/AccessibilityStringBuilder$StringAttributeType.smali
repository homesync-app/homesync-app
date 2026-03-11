.class public final enum Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;
.super Ljava/lang/Enum;
.source "AccessibilityStringBuilder.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/view/AccessibilityStringBuilder;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x4019
    name = "StringAttributeType"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Enum<",
        "Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;",
        ">;"
    }
.end annotation


# static fields
.field private static final synthetic $VALUES:[Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;

.field public static final enum LOCALE:Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;

.field public static final enum SPELLOUT:Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;


# direct methods
.method private static synthetic $values()[Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;
    .locals 2

    .line 27
    sget-object v0, Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;->SPELLOUT:Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;

    sget-object v1, Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;->LOCALE:Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;

    filled-new-array {v0, v1}, [Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;

    move-result-object v0

    return-object v0
.end method

.method static constructor <clinit>()V
    .locals 3

    .line 28
    new-instance v0, Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;

    const-string v1, "SPELLOUT"

    const/4 v2, 0x0

    invoke-direct {v0, v1, v2}, Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;-><init>(Ljava/lang/String;I)V

    sput-object v0, Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;->SPELLOUT:Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;

    .line 29
    new-instance v0, Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;

    const-string v1, "LOCALE"

    const/4 v2, 0x1

    invoke-direct {v0, v1, v2}, Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;-><init>(Ljava/lang/String;I)V

    sput-object v0, Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;->LOCALE:Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;

    .line 27
    invoke-static {}, Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;->$values()[Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;

    move-result-object v0

    sput-object v0, Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;->$VALUES:[Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;

    return-void
.end method

.method private constructor <init>(Ljava/lang/String;I)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x1000,
            0x1000
        }
        names = {
            null,
            null
        }
    .end annotation

    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 27
    invoke-direct {p0, p1, p2}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    return-void
.end method

.method public static valueOf(Ljava/lang/String;)Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;
    .locals 1
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8000
        }
        names = {
            null
        }
    .end annotation

    .line 27
    const-class v0, Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;

    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    move-result-object p0

    check-cast p0, Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;

    return-object p0
.end method

.method public static values()[Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;
    .locals 1

    .line 27
    sget-object v0, Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;->$VALUES:[Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;

    invoke-virtual {v0}, [Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;->clone()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;

    return-object v0
.end method
