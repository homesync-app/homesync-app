.class public Lio/flutter/plugins/firebase/messaging/ContextHolder;
.super Ljava/lang/Object;
.source "ContextHolder.java"


# static fields
.field private static applicationContext:Landroid/content/Context;


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 10
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static getApplicationContext()Landroid/content/Context;
    .locals 1

    .line 14
    sget-object v0, Lio/flutter/plugins/firebase/messaging/ContextHolder;->applicationContext:Landroid/content/Context;

    return-object v0
.end method

.method public static setApplicationContext(Landroid/content/Context;)V
    .locals 2

    .line 18
    const-string v0, "FLTFireContextHolder"

    const-string v1, "received application context."

    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 19
    sput-object p0, Lio/flutter/plugins/firebase/messaging/ContextHolder;->applicationContext:Landroid/content/Context;

    return-void
.end method
