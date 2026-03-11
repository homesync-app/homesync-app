.class public Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel;
.super Ljava/lang/Object;
.source "SensitiveContentChannel.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel$SensitiveContentMethodHandler;
    }
.end annotation


# static fields
.field public static final AUTO_SENSITIVE_CONTENT_SENSITIVITY:I = 0x0

.field public static final NOT_SENSITIVE_CONTENT_SENSITIVITY:I = 0x2

.field public static final SENSITIVE_CONTENT_SENSITIVITY:I = 0x1

.field private static final TAG:Ljava/lang/String; = "SensitiveContentChannel"

.field public static final UNKNOWN_CONTENT_SENSITIVITY:I = 0x3


# instance fields
.field public final channel:Lio/flutter/plugin/common/MethodChannel;

.field public final parsingMethodHandler:Lio/flutter/plugin/common/MethodChannel$MethodCallHandler;

.field private sensitiveContentMethodHandler:Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel$SensitiveContentMethodHandler;


# direct methods
.method public constructor <init>(Lio/flutter/embedding/engine/dart/DartExecutor;)V
    .locals 4

    .line 145
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 59
    new-instance v0, Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel$1;

    invoke-direct {v0, p0}, Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel$1;-><init>(Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel;)V

    iput-object v0, p0, Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel;->parsingMethodHandler:Lio/flutter/plugin/common/MethodChannel$MethodCallHandler;

    .line 146
    new-instance v1, Lio/flutter/plugin/common/MethodChannel;

    const-string v2, "flutter/sensitivecontent"

    sget-object v3, Lio/flutter/plugin/common/StandardMethodCodec;->INSTANCE:Lio/flutter/plugin/common/StandardMethodCodec;

    invoke-direct {v1, p1, v2, v3}, Lio/flutter/plugin/common/MethodChannel;-><init>(Lio/flutter/plugin/common/BinaryMessenger;Ljava/lang/String;Lio/flutter/plugin/common/MethodCodec;)V

    iput-object v1, p0, Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel;->channel:Lio/flutter/plugin/common/MethodChannel;

    .line 148
    invoke-virtual {v1, v0}, Lio/flutter/plugin/common/MethodChannel;->setMethodCallHandler(Lio/flutter/plugin/common/MethodChannel$MethodCallHandler;)V

    return-void
.end method

.method static synthetic access$000(Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel;)Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel$SensitiveContentMethodHandler;
    .locals 0

    .line 22
    iget-object p0, p0, Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel;->sensitiveContentMethodHandler:Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel$SensitiveContentMethodHandler;

    return-object p0
.end method

.method static synthetic access$100(Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel;I)I
    .locals 0

    .line 22
    invoke-direct {p0, p1}, Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel;->deserializeContentSensitivity(I)I

    move-result p0

    return p0
.end method

.method static synthetic access$200(Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel;I)I
    .locals 0

    .line 22
    invoke-direct {p0, p1}, Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel;->serializeContentSensitivity(I)I

    move-result p0

    return p0
.end method

.method private deserializeContentSensitivity(I)I
    .locals 3

    if-eqz p1, :cond_2

    const/4 v0, 0x1

    if-eq p1, v0, :cond_1

    const/4 v0, 0x2

    if-ne p1, v0, :cond_0

    return v0

    .line 117
    :cond_0
    new-instance v0, Ljava/lang/IllegalArgumentException;

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "contentSensitivityIndex "

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v1, " not known to the SensitiveContentChannel."

    invoke-virtual {p1, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {v0, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_1
    return v0

    :cond_2
    const/4 p1, 0x0

    return p1
.end method

.method private serializeContentSensitivity(I)I
    .locals 1

    if-eqz p1, :cond_1

    const/4 v0, 0x1

    if-eq p1, v0, :cond_0

    const/4 v0, 0x2

    if-eq p1, v0, :cond_0

    const/4 p1, 0x3

    return p1

    :cond_0
    return v0

    :cond_1
    const/4 p1, 0x0

    return p1
.end method


# virtual methods
.method public setSensitiveContentMethodHandler(Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel$SensitiveContentMethodHandler;)V
    .locals 0

    .line 157
    iput-object p1, p0, Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel;->sensitiveContentMethodHandler:Lio/flutter/embedding/engine/systemchannels/SensitiveContentChannel$SensitiveContentMethodHandler;

    return-void
.end method
