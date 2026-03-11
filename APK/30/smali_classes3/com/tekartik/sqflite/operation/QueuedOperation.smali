.class public Lcom/tekartik/sqflite/operation/QueuedOperation;
.super Ljava/lang/Object;
.source "QueuedOperation.java"


# instance fields
.field final operation:Lcom/tekartik/sqflite/operation/Operation;

.field final runnable:Ljava/lang/Runnable;


# direct methods
.method public constructor <init>(Lcom/tekartik/sqflite/operation/Operation;Ljava/lang/Runnable;)V
    .locals 0

    .line 7
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 8
    iput-object p1, p0, Lcom/tekartik/sqflite/operation/QueuedOperation;->operation:Lcom/tekartik/sqflite/operation/Operation;

    .line 9
    iput-object p2, p0, Lcom/tekartik/sqflite/operation/QueuedOperation;->runnable:Ljava/lang/Runnable;

    return-void
.end method


# virtual methods
.method public run()V
    .locals 1

    .line 13
    iget-object v0, p0, Lcom/tekartik/sqflite/operation/QueuedOperation;->runnable:Ljava/lang/Runnable;

    invoke-interface {v0}, Ljava/lang/Runnable;->run()V

    return-void
.end method
