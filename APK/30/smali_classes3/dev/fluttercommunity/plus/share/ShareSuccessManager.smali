.class public final Ldev/fluttercommunity/plus/share/ShareSuccessManager;
.super Ljava/lang/Object;
.source "ShareSuccessManager.kt"

# interfaces
.implements Lio/flutter/plugin/common/PluginRegistry$ActivityResultListener;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Ldev/fluttercommunity/plus/share/ShareSuccessManager$Companion;
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000B\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0008\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0002\n\u0002\u0008\u0004\n\u0002\u0010\u000e\n\u0000\n\u0002\u0010\u000b\n\u0000\n\u0002\u0010\u0008\n\u0002\u0008\u0002\n\u0002\u0018\u0002\n\u0002\u0008\u0002\u0008\u0000\u0018\u0000 \u00182\u00020\u0001:\u0001\u0018B\u000f\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0004\u0008\u0004\u0010\u0005J\u000e\u0010\n\u001a\u00020\u000b2\u0006\u0010\u0006\u001a\u00020\u0007J\u0006\u0010\u000c\u001a\u00020\u000bJ\u0006\u0010\r\u001a\u00020\u000bJ\u0010\u0010\u000e\u001a\u00020\u000b2\u0006\u0010\u000f\u001a\u00020\u0010H\u0002J\"\u0010\u0011\u001a\u00020\u00122\u0006\u0010\u0013\u001a\u00020\u00142\u0006\u0010\u0015\u001a\u00020\u00142\u0008\u0010\u0016\u001a\u0004\u0018\u00010\u0017H\u0016R\u000e\u0010\u0002\u001a\u00020\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u0010\u0010\u0006\u001a\u0004\u0018\u00010\u0007X\u0082\u000e\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0008\u001a\u00020\tX\u0082\u000e\u00a2\u0006\u0002\n\u0000\u00a8\u0006\u0019"
    }
    d2 = {
        "Ldev/fluttercommunity/plus/share/ShareSuccessManager;",
        "Lio/flutter/plugin/common/PluginRegistry$ActivityResultListener;",
        "context",
        "Landroid/content/Context;",
        "<init>",
        "(Landroid/content/Context;)V",
        "callback",
        "Lio/flutter/plugin/common/MethodChannel$Result;",
        "isCalledBack",
        "Ljava/util/concurrent/atomic/AtomicBoolean;",
        "setCallback",
        "",
        "unavailable",
        "clear",
        "returnResult",
        "result",
        "",
        "onActivityResult",
        "",
        "requestCode",
        "",
        "resultCode",
        "data",
        "Landroid/content/Intent;",
        "Companion",
        "share_plus_release"
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
.field public static final ACTIVITY_CODE:I = 0x5873

.field public static final Companion:Ldev/fluttercommunity/plus/share/ShareSuccessManager$Companion;

.field public static final RESULT_UNAVAILABLE:Ljava/lang/String; = "dev.fluttercommunity.plus/share/unavailable"


# instance fields
.field private callback:Lio/flutter/plugin/common/MethodChannel$Result;

.field private final context:Landroid/content/Context;

.field private isCalledBack:Ljava/util/concurrent/atomic/AtomicBoolean;


# direct methods
.method static constructor <clinit>()V
    .locals 2

    new-instance v0, Ldev/fluttercommunity/plus/share/ShareSuccessManager$Companion;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Ldev/fluttercommunity/plus/share/ShareSuccessManager$Companion;-><init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V

    sput-object v0, Ldev/fluttercommunity/plus/share/ShareSuccessManager;->Companion:Ldev/fluttercommunity/plus/share/ShareSuccessManager$Companion;

    return-void
.end method

.method public constructor <init>(Landroid/content/Context;)V
    .locals 1

    const-string v0, "context"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 12
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Ldev/fluttercommunity/plus/share/ShareSuccessManager;->context:Landroid/content/Context;

    .line 14
    new-instance p1, Ljava/util/concurrent/atomic/AtomicBoolean;

    const/4 v0, 0x1

    invoke-direct {p1, v0}, Ljava/util/concurrent/atomic/AtomicBoolean;-><init>(Z)V

    iput-object p1, p0, Ldev/fluttercommunity/plus/share/ShareSuccessManager;->isCalledBack:Ljava/util/concurrent/atomic/AtomicBoolean;

    return-void
.end method

.method private final returnResult(Ljava/lang/String;)V
    .locals 3

    .line 58
    iget-object v0, p0, Ldev/fluttercommunity/plus/share/ShareSuccessManager;->isCalledBack:Ljava/util/concurrent/atomic/AtomicBoolean;

    const/4 v1, 0x0

    const/4 v2, 0x1

    invoke-virtual {v0, v1, v2}, Ljava/util/concurrent/atomic/AtomicBoolean;->compareAndSet(ZZ)Z

    move-result v0

    if-eqz v0, :cond_0

    iget-object v0, p0, Ldev/fluttercommunity/plus/share/ShareSuccessManager;->callback:Lio/flutter/plugin/common/MethodChannel$Result;

    if-eqz v0, :cond_0

    .line 59
    invoke-static {v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNull(Ljava/lang/Object;)V

    invoke-interface {v0, p1}, Lio/flutter/plugin/common/MethodChannel$Result;->success(Ljava/lang/Object;)V

    const/4 p1, 0x0

    .line 60
    iput-object p1, p0, Ldev/fluttercommunity/plus/share/ShareSuccessManager;->callback:Lio/flutter/plugin/common/MethodChannel$Result;

    :cond_0
    return-void
.end method


# virtual methods
.method public final clear()V
    .locals 2

    .line 50
    iget-object v0, p0, Ldev/fluttercommunity/plus/share/ShareSuccessManager;->isCalledBack:Ljava/util/concurrent/atomic/AtomicBoolean;

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Ljava/util/concurrent/atomic/AtomicBoolean;->set(Z)V

    const/4 v0, 0x0

    .line 51
    iput-object v0, p0, Ldev/fluttercommunity/plus/share/ShareSuccessManager;->callback:Lio/flutter/plugin/common/MethodChannel$Result;

    return-void
.end method

.method public onActivityResult(IILandroid/content/Intent;)Z
    .locals 0

    const/16 p2, 0x5873

    if-ne p1, p2, :cond_0

    .line 70
    sget-object p1, Ldev/fluttercommunity/plus/share/SharePlusPendingIntent;->Companion:Ldev/fluttercommunity/plus/share/SharePlusPendingIntent$Companion;

    invoke-virtual {p1}, Ldev/fluttercommunity/plus/share/SharePlusPendingIntent$Companion;->getResult()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p0, p1}, Ldev/fluttercommunity/plus/share/ShareSuccessManager;->returnResult(Ljava/lang/String;)V

    const/4 p1, 0x1

    return p1

    :cond_0
    const/4 p1, 0x0

    return p1
.end method

.method public final setCallback(Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 4

    const-string v0, "callback"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 21
    iget-object v0, p0, Ldev/fluttercommunity/plus/share/ShareSuccessManager;->isCalledBack:Ljava/util/concurrent/atomic/AtomicBoolean;

    const/4 v1, 0x1

    const/4 v2, 0x0

    invoke-virtual {v0, v1, v2}, Ljava/util/concurrent/atomic/AtomicBoolean;->compareAndSet(ZZ)Z

    move-result v0

    const-string v1, ""

    if-eqz v0, :cond_0

    .line 23
    sget-object v0, Ldev/fluttercommunity/plus/share/SharePlusPendingIntent;->Companion:Ldev/fluttercommunity/plus/share/SharePlusPendingIntent$Companion;

    invoke-virtual {v0, v1}, Ldev/fluttercommunity/plus/share/SharePlusPendingIntent$Companion;->setResult(Ljava/lang/String;)V

    .line 24
    iget-object v0, p0, Ldev/fluttercommunity/plus/share/ShareSuccessManager;->isCalledBack:Ljava/util/concurrent/atomic/AtomicBoolean;

    invoke-virtual {v0, v2}, Ljava/util/concurrent/atomic/AtomicBoolean;->set(Z)V

    .line 25
    iput-object p1, p0, Ldev/fluttercommunity/plus/share/ShareSuccessManager;->callback:Lio/flutter/plugin/common/MethodChannel$Result;

    return-void

    .line 30
    :cond_0
    iget-object v0, p0, Ldev/fluttercommunity/plus/share/ShareSuccessManager;->callback:Lio/flutter/plugin/common/MethodChannel$Result;

    if-eqz v0, :cond_1

    const-string v3, "dev.fluttercommunity.plus/share/unavailable"

    invoke-interface {v0, v3}, Lio/flutter/plugin/common/MethodChannel$Result;->success(Ljava/lang/Object;)V

    .line 33
    :cond_1
    sget-object v0, Ldev/fluttercommunity/plus/share/SharePlusPendingIntent;->Companion:Ldev/fluttercommunity/plus/share/SharePlusPendingIntent$Companion;

    invoke-virtual {v0, v1}, Ldev/fluttercommunity/plus/share/SharePlusPendingIntent$Companion;->setResult(Ljava/lang/String;)V

    .line 34
    iget-object v0, p0, Ldev/fluttercommunity/plus/share/ShareSuccessManager;->isCalledBack:Ljava/util/concurrent/atomic/AtomicBoolean;

    invoke-virtual {v0, v2}, Ljava/util/concurrent/atomic/AtomicBoolean;->set(Z)V

    .line 35
    iput-object p1, p0, Ldev/fluttercommunity/plus/share/ShareSuccessManager;->callback:Lio/flutter/plugin/common/MethodChannel$Result;

    return-void
.end method

.method public final unavailable()V
    .locals 1

    .line 43
    const-string v0, "dev.fluttercommunity.plus/share/unavailable"

    invoke-direct {p0, v0}, Ldev/fluttercommunity/plus/share/ShareSuccessManager;->returnResult(Ljava/lang/String;)V

    return-void
.end method
