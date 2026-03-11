.class Lcom/tekartik/sqflite/DatabaseWorkerPool$1;
.super Ljava/lang/Object;
.source "DatabaseWorkerPool.java"

# interfaces
.implements Lcom/tekartik/sqflite/DatabaseDelegate;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/tekartik/sqflite/DatabaseWorkerPool;->post(Lcom/tekartik/sqflite/Database;Ljava/lang/Runnable;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/tekartik/sqflite/DatabaseWorkerPool;

.field final synthetic val$database:Lcom/tekartik/sqflite/Database;


# direct methods
.method constructor <init>(Lcom/tekartik/sqflite/DatabaseWorkerPool;Lcom/tekartik/sqflite/Database;)V
    .locals 0
    .annotation system Ldalvik/annotation/MethodParameters;
        accessFlags = {
            0x8010,
            0x1010
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

    .line 32
    iput-object p1, p0, Lcom/tekartik/sqflite/DatabaseWorkerPool$1;->this$0:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    iput-object p2, p0, Lcom/tekartik/sqflite/DatabaseWorkerPool$1;->val$database:Lcom/tekartik/sqflite/Database;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public getDatabaseId()I
    .locals 1

    .line 35
    iget-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorkerPool$1;->val$database:Lcom/tekartik/sqflite/Database;

    iget v0, v0, Lcom/tekartik/sqflite/Database;->id:I

    return v0
.end method

.method public isInTransaction()Z
    .locals 1

    .line 40
    iget-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorkerPool$1;->val$database:Lcom/tekartik/sqflite/Database;

    invoke-virtual {v0}, Lcom/tekartik/sqflite/Database;->isInTransaction()Z

    move-result v0

    return v0
.end method
