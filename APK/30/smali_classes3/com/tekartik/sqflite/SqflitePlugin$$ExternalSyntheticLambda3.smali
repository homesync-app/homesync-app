.class public final synthetic Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda3;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic f$0:Lio/flutter/plugin/common/MethodCall;

.field public final synthetic f$1:Lcom/tekartik/sqflite/Database;

.field public final synthetic f$2:Lio/flutter/plugin/common/MethodChannel$Result;


# direct methods
.method public synthetic constructor <init>(Lio/flutter/plugin/common/MethodCall;Lcom/tekartik/sqflite/Database;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 0

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda3;->f$0:Lio/flutter/plugin/common/MethodCall;

    iput-object p2, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda3;->f$1:Lcom/tekartik/sqflite/Database;

    iput-object p3, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda3;->f$2:Lio/flutter/plugin/common/MethodChannel$Result;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 3

    .line 0
    iget-object v0, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda3;->f$0:Lio/flutter/plugin/common/MethodCall;

    iget-object v1, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda3;->f$1:Lcom/tekartik/sqflite/Database;

    iget-object v2, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda3;->f$2:Lio/flutter/plugin/common/MethodChannel$Result;

    invoke-static {v0, v1, v2}, Lcom/tekartik/sqflite/SqflitePlugin;->lambda$onSetLocaleCall$5(Lio/flutter/plugin/common/MethodCall;Lcom/tekartik/sqflite/Database;Lio/flutter/plugin/common/MethodChannel$Result;)V

    return-void
.end method
