.class Lcom/tekartik/sqflite/SingleDatabaseWorkerPoolImpl;
.super Ljava/lang/Object;
.source "DatabaseWorkerPool.java"

# interfaces
.implements Lcom/tekartik/sqflite/DatabaseWorkerPool;


# instance fields
.field private handler:Landroid/os/Handler;

.field private handlerThread:Landroid/os/HandlerThread;

.field final name:Ljava/lang/String;

.field final priority:I


# direct methods
.method constructor <init>(Ljava/lang/String;I)V
    .locals 0

    .line 62
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 63
    iput-object p1, p0, Lcom/tekartik/sqflite/SingleDatabaseWorkerPoolImpl;->name:Ljava/lang/String;

    .line 64
    iput p2, p0, Lcom/tekartik/sqflite/SingleDatabaseWorkerPoolImpl;->priority:I

    return-void
.end method


# virtual methods
.method public post(Lcom/tekartik/sqflite/DatabaseTask;)V
    .locals 1

    .line 85
    iget-object v0, p0, Lcom/tekartik/sqflite/SingleDatabaseWorkerPoolImpl;->handler:Landroid/os/Handler;

    iget-object p1, p1, Lcom/tekartik/sqflite/DatabaseTask;->runnable:Ljava/lang/Runnable;

    invoke-virtual {v0, p1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    return-void
.end method

.method public quit()V
    .locals 1

    .line 76
    iget-object v0, p0, Lcom/tekartik/sqflite/SingleDatabaseWorkerPoolImpl;->handlerThread:Landroid/os/HandlerThread;

    if-eqz v0, :cond_0

    .line 77
    invoke-virtual {v0}, Landroid/os/HandlerThread;->quit()Z

    const/4 v0, 0x0

    .line 78
    iput-object v0, p0, Lcom/tekartik/sqflite/SingleDatabaseWorkerPoolImpl;->handlerThread:Landroid/os/HandlerThread;

    .line 79
    iput-object v0, p0, Lcom/tekartik/sqflite/SingleDatabaseWorkerPoolImpl;->handler:Landroid/os/Handler;

    :cond_0
    return-void
.end method

.method public start()V
    .locals 3

    .line 69
    new-instance v0, Landroid/os/HandlerThread;

    iget-object v1, p0, Lcom/tekartik/sqflite/SingleDatabaseWorkerPoolImpl;->name:Ljava/lang/String;

    iget v2, p0, Lcom/tekartik/sqflite/SingleDatabaseWorkerPoolImpl;->priority:I

    invoke-direct {v0, v1, v2}, Landroid/os/HandlerThread;-><init>(Ljava/lang/String;I)V

    iput-object v0, p0, Lcom/tekartik/sqflite/SingleDatabaseWorkerPoolImpl;->handlerThread:Landroid/os/HandlerThread;

    .line 70
    invoke-virtual {v0}, Landroid/os/HandlerThread;->start()V

    .line 71
    new-instance v0, Landroid/os/Handler;

    iget-object v1, p0, Lcom/tekartik/sqflite/SingleDatabaseWorkerPoolImpl;->handlerThread:Landroid/os/HandlerThread;

    invoke-virtual {v1}, Landroid/os/HandlerThread;->getLooper()Landroid/os/Looper;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    iput-object v0, p0, Lcom/tekartik/sqflite/SingleDatabaseWorkerPoolImpl;->handler:Landroid/os/Handler;

    return-void
.end method
