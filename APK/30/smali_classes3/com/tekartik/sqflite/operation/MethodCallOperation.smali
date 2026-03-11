.class public Lcom/tekartik/sqflite/operation/MethodCallOperation;
.super Lcom/tekartik/sqflite/operation/BaseOperation;
.source "MethodCallOperation.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/tekartik/sqflite/operation/MethodCallOperation$Result;
    }
.end annotation


# instance fields
.field final methodCall:Lio/flutter/plugin/common/MethodCall;

.field private final result:Lcom/tekartik/sqflite/operation/MethodCallOperation$Result;


# direct methods
.method public constructor <init>(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 0

    .line 14
    invoke-direct {p0}, Lcom/tekartik/sqflite/operation/BaseOperation;-><init>()V

    .line 15
    iput-object p1, p0, Lcom/tekartik/sqflite/operation/MethodCallOperation;->methodCall:Lio/flutter/plugin/common/MethodCall;

    .line 16
    new-instance p1, Lcom/tekartik/sqflite/operation/MethodCallOperation$Result;

    invoke-direct {p1, p2}, Lcom/tekartik/sqflite/operation/MethodCallOperation$Result;-><init>(Lio/flutter/plugin/common/MethodChannel$Result;)V

    iput-object p1, p0, Lcom/tekartik/sqflite/operation/MethodCallOperation;->result:Lcom/tekartik/sqflite/operation/MethodCallOperation$Result;

    return-void
.end method


# virtual methods
.method public getArgument(Ljava/lang/String;)Ljava/lang/Object;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<T:",
            "Ljava/lang/Object;",
            ">(",
            "Ljava/lang/String;",
            ")TT;"
        }
    .end annotation

    .line 26
    iget-object v0, p0, Lcom/tekartik/sqflite/operation/MethodCallOperation;->methodCall:Lio/flutter/plugin/common/MethodCall;

    invoke-virtual {v0, p1}, Lio/flutter/plugin/common/MethodCall;->argument(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method

.method public getMethod()Ljava/lang/String;
    .locals 1

    .line 21
    iget-object v0, p0, Lcom/tekartik/sqflite/operation/MethodCallOperation;->methodCall:Lio/flutter/plugin/common/MethodCall;

    iget-object v0, v0, Lio/flutter/plugin/common/MethodCall;->method:Ljava/lang/String;

    return-object v0
.end method

.method public getOperationResult()Lcom/tekartik/sqflite/operation/OperationResult;
    .locals 1

    .line 36
    iget-object v0, p0, Lcom/tekartik/sqflite/operation/MethodCallOperation;->result:Lcom/tekartik/sqflite/operation/MethodCallOperation$Result;

    return-object v0
.end method

.method public hasArgument(Ljava/lang/String;)Z
    .locals 1

    .line 31
    iget-object v0, p0, Lcom/tekartik/sqflite/operation/MethodCallOperation;->methodCall:Lio/flutter/plugin/common/MethodCall;

    invoke-virtual {v0, p1}, Lio/flutter/plugin/common/MethodCall;->hasArgument(Ljava/lang/String;)Z

    move-result p1

    return p1
.end method
