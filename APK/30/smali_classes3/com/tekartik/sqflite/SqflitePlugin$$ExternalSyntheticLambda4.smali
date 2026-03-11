.class public final synthetic Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda4;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic f$0:Z

.field public final synthetic f$1:Ljava/lang/String;

.field public final synthetic f$2:Lio/flutter/plugin/common/MethodChannel$Result;

.field public final synthetic f$3:Ljava/lang/Boolean;

.field public final synthetic f$4:Lcom/tekartik/sqflite/Database;

.field public final synthetic f$5:Lio/flutter/plugin/common/MethodCall;

.field public final synthetic f$6:Z

.field public final synthetic f$7:I


# direct methods
.method public synthetic constructor <init>(ZLjava/lang/String;Lio/flutter/plugin/common/MethodChannel$Result;Ljava/lang/Boolean;Lcom/tekartik/sqflite/Database;Lio/flutter/plugin/common/MethodCall;ZI)V
    .locals 0

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-boolean p1, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda4;->f$0:Z

    iput-object p2, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda4;->f$1:Ljava/lang/String;

    iput-object p3, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda4;->f$2:Lio/flutter/plugin/common/MethodChannel$Result;

    iput-object p4, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda4;->f$3:Ljava/lang/Boolean;

    iput-object p5, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda4;->f$4:Lcom/tekartik/sqflite/Database;

    iput-object p6, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda4;->f$5:Lio/flutter/plugin/common/MethodCall;

    iput-boolean p7, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda4;->f$6:Z

    iput p8, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda4;->f$7:I

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 8

    .line 0
    iget-boolean v0, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda4;->f$0:Z

    iget-object v1, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda4;->f$1:Ljava/lang/String;

    iget-object v2, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda4;->f$2:Lio/flutter/plugin/common/MethodChannel$Result;

    iget-object v3, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda4;->f$3:Ljava/lang/Boolean;

    iget-object v4, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda4;->f$4:Lcom/tekartik/sqflite/Database;

    iget-object v5, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda4;->f$5:Lio/flutter/plugin/common/MethodCall;

    iget-boolean v6, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda4;->f$6:Z

    iget v7, p0, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda4;->f$7:I

    invoke-static/range {v0 .. v7}, Lcom/tekartik/sqflite/SqflitePlugin;->lambda$onOpenDatabaseCall$7(ZLjava/lang/String;Lio/flutter/plugin/common/MethodChannel$Result;Ljava/lang/Boolean;Lcom/tekartik/sqflite/Database;Lio/flutter/plugin/common/MethodCall;ZI)V

    return-void
.end method
