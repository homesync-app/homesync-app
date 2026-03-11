.class public interface abstract Lcom/tekartik/sqflite/DatabaseWorkerPool;
.super Ljava/lang/Object;
.source "DatabaseWorkerPool.java"


# direct methods
.method public static create(Ljava/lang/String;II)Lcom/tekartik/sqflite/DatabaseWorkerPool;
    .locals 1

    const/4 v0, 0x1

    if-ne p1, v0, :cond_0

    .line 48
    new-instance p1, Lcom/tekartik/sqflite/SingleDatabaseWorkerPoolImpl;

    invoke-direct {p1, p0, p2}, Lcom/tekartik/sqflite/SingleDatabaseWorkerPoolImpl;-><init>(Ljava/lang/String;I)V

    return-object p1

    .line 50
    :cond_0
    new-instance v0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;

    invoke-direct {v0, p0, p1, p2}, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;-><init>(Ljava/lang/String;II)V

    return-object v0
.end method


# virtual methods
.method public post(Lcom/tekartik/sqflite/Database;Ljava/lang/Runnable;)V
    .locals 1

    if-nez p1, :cond_0

    const/4 p1, 0x0

    goto :goto_0

    .line 32
    :cond_0
    new-instance v0, Lcom/tekartik/sqflite/DatabaseWorkerPool$1;

    invoke-direct {v0, p0, p1}, Lcom/tekartik/sqflite/DatabaseWorkerPool$1;-><init>(Lcom/tekartik/sqflite/DatabaseWorkerPool;Lcom/tekartik/sqflite/Database;)V

    move-object p1, v0

    .line 43
    :goto_0
    new-instance v0, Lcom/tekartik/sqflite/DatabaseTask;

    invoke-direct {v0, p1, p2}, Lcom/tekartik/sqflite/DatabaseTask;-><init>(Lcom/tekartik/sqflite/DatabaseDelegate;Ljava/lang/Runnable;)V

    invoke-interface {p0, v0}, Lcom/tekartik/sqflite/DatabaseWorkerPool;->post(Lcom/tekartik/sqflite/DatabaseTask;)V

    return-void
.end method

.method public abstract post(Lcom/tekartik/sqflite/DatabaseTask;)V
.end method

.method public abstract quit()V
.end method

.method public abstract start()V
.end method
