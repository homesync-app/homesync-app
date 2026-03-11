.class public final Landroidx/window/R$styleable;
.super Ljava/lang/Object;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Landroidx/window/R;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "styleable"
.end annotation


# static fields
.field public static ActivityFilter:[I = null

.field public static ActivityFilter_activityAction:I = 0x0

.field public static ActivityFilter_activityName:I = 0x1

.field public static ActivityRule:[I = null

.field public static ActivityRule_alwaysExpand:I = 0x0

.field public static ActivityRule_tag:I = 0x1

.field public static SplitPairFilter:[I = null

.field public static SplitPairFilter_primaryActivityName:I = 0x0

.field public static SplitPairFilter_secondaryActivityAction:I = 0x1

.field public static SplitPairFilter_secondaryActivityName:I = 0x2

.field public static SplitPairRule:[I = null

.field public static SplitPairRule_animationBackgroundColor:I = 0x0

.field public static SplitPairRule_clearTop:I = 0x1

.field public static SplitPairRule_finishPrimaryWithSecondary:I = 0x2

.field public static SplitPairRule_finishSecondaryWithPrimary:I = 0x3

.field public static SplitPairRule_splitLayoutDirection:I = 0x4

.field public static SplitPairRule_splitMaxAspectRatioInLandscape:I = 0x5

.field public static SplitPairRule_splitMaxAspectRatioInPortrait:I = 0x6

.field public static SplitPairRule_splitMinHeightDp:I = 0x7

.field public static SplitPairRule_splitMinSmallestWidthDp:I = 0x8

.field public static SplitPairRule_splitMinWidthDp:I = 0x9

.field public static SplitPairRule_splitRatio:I = 0xa

.field public static SplitPairRule_tag:I = 0xb

.field public static SplitPlaceholderRule:[I = null

.field public static SplitPlaceholderRule_animationBackgroundColor:I = 0x0

.field public static SplitPlaceholderRule_finishPrimaryWithPlaceholder:I = 0x1

.field public static SplitPlaceholderRule_placeholderActivityName:I = 0x2

.field public static SplitPlaceholderRule_splitLayoutDirection:I = 0x3

.field public static SplitPlaceholderRule_splitMaxAspectRatioInLandscape:I = 0x4

.field public static SplitPlaceholderRule_splitMaxAspectRatioInPortrait:I = 0x5

.field public static SplitPlaceholderRule_splitMinHeightDp:I = 0x6

.field public static SplitPlaceholderRule_splitMinSmallestWidthDp:I = 0x7

.field public static SplitPlaceholderRule_splitMinWidthDp:I = 0x8

.field public static SplitPlaceholderRule_splitRatio:I = 0x9

.field public static SplitPlaceholderRule_stickyPlaceholder:I = 0xa

.field public static SplitPlaceholderRule_tag:I = 0xb


# direct methods
.method public static constructor <clinit>()V
    .locals 3

    const v0, 0x7f040021

    const v1, 0x7f040023

    filled-new-array {v0, v1}, [I

    move-result-object v0

    sput-object v0, Landroidx/window/R$styleable;->ActivityFilter:[I

    const v0, 0x7f04002f

    const v1, 0x7f04014a

    filled-new-array {v0, v1}, [I

    move-result-object v0

    sput-object v0, Landroidx/window/R$styleable;->ActivityRule:[I

    const v0, 0x7f040116

    const v1, 0x7f040117

    const v2, 0x7f040107

    filled-new-array {v2, v0, v1}, [I

    move-result-object v0

    sput-object v0, Landroidx/window/R$styleable;->SplitPairFilter:[I

    const/16 v0, 0xc

    new-array v1, v0, [I

    fill-array-data v1, :array_0

    sput-object v1, Landroidx/window/R$styleable;->SplitPairRule:[I

    new-array v0, v0, [I

    fill-array-data v0, :array_1

    sput-object v0, Landroidx/window/R$styleable;->SplitPlaceholderRule:[I

    return-void

    :array_0
    .array-data 4
        0x7f040030
        0x7f040052
        0x7f04009c
        0x7f04009d
        0x7f04012b
        0x7f04012c
        0x7f04012d
        0x7f04012e
        0x7f04012f
        0x7f040130
        0x7f040131
        0x7f04014a
    .end array-data

    :array_1
    .array-data 4
        0x7f040030
        0x7f04009b
        0x7f0400f7
        0x7f04012b
        0x7f04012c
        0x7f04012d
        0x7f04012e
        0x7f04012f
        0x7f040130
        0x7f040131
        0x7f040137
        0x7f04014a
    .end array-data
.end method

.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method
