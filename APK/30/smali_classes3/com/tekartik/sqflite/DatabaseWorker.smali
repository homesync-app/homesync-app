.class Lcom/tekartik/sqflite/DatabaseWorker;
.super Ljava/lang/Object;
.source "DatabaseWorker.java"


# instance fields
.field private handler:Landroid/os/Handler;

.field private handlerThread:Landroid/os/HandlerThread;

.field private lastTask:Lcom/tekartik/sqflite/DatabaseTask;

.field private final name:Ljava/lang/String;

.field protected onIdle:Ljava/lang/Runnable;

.field private final priority:I


# direct methods
.method public static synthetic $r8$lambda$rwwQK9HFmHakmVZCrvN4PYlgMPw(Lcom/tekartik/sqflite/DatabaseWorker;Lcom/tekartik/sqflite/DatabaseTask;)V
    .locals 0

    invoke-direct {p0, p1}, Lcom/tekartik/sqflite/DatabaseWorker;->lambda$postTask$0(Lcom/tekartik/sqflite/DatabaseTask;)V

    return-void
.end method

.method constructor <init>(Ljava/lang/String;I)V
    .locals 0

    .line 22
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 23
    iput-object p1, p0, Lcom/tekartik/sqflite/DatabaseWorker;->name:Ljava/lang/String;

    .line 24
    iput p2, p0, Lcom/tekartik/sqflite/DatabaseWorker;->priority:I

    return-void
.end method

.method private synthetic lambda$postTask$0(Lcom/tekartik/sqflite/DatabaseTask;)V
    .locals 0

    .line 51
    invoke-virtual {p0, p1}, Lcom/tekartik/sqflite/DatabaseWorker;->work(Lcom/tekartik/sqflite/DatabaseTask;)V

    return-void
.end method


# virtual methods
.method isLastTaskInTransaction()Z
    .locals 1

    .line 43
    iget-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorker;->lastTask:Lcom/tekartik/sqflite/DatabaseTask;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lcom/tekartik/sqflite/DatabaseTask;->isInTransaction()Z

    move-result v0

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    return v0

    :cond_0
    const/4 v0, 0x0

    return v0
.end method

.method lastTaskDatabaseId()Ljava/lang/Integer;
    .locals 1

    .line 47
    iget-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorker;->lastTask:Lcom/tekartik/sqflite/DatabaseTask;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lcom/tekartik/sqflite/DatabaseTask;->getDatabaseId()Ljava/lang/Integer;

    move-result-object v0

    return-object v0

    :cond_0
    const/4 v0, 0x0

    return-object v0
.end method

.method postTask(Lcom/tekartik/sqflite/DatabaseTask;)V
    .locals 2

    .line 51
    iget-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorker;->handler:Landroid/os/Handler;

    new-instance v1, Lcom/tekartik/sqflite/DatabaseWorker$$ExternalSyntheticLambda0;

    invoke-direct {v1, p0, p1}, Lcom/tekartik/sqflite/DatabaseWorker$$ExternalSyntheticLambda0;-><init>(Lcom/tekartik/sqflite/DatabaseWorker;Lcom/tekartik/sqflite/DatabaseTask;)V

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    return-void
.end method

.method declared-synchronized quit()V
    .locals 1

    monitor-enter p0

    .line 35
    :try_start_0
    iget-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorker;->handlerThread:Landroid/os/HandlerThread;

    if-eqz v0, :cond_0

    .line 36
    invoke-virtual {v0}, Landroid/os/HandlerThread;->quit()Z

    const/4 v0, 0x0

    .line 37
    iput-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorker;->handlerThread:Landroid/os/HandlerThread;

    .line 38
    iput-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorker;->handler:Landroid/os/Handler;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 40
    :cond_0
    monitor-exit p0

    return-void

    :catchall_0
    move-exception v0

    :try_start_1
    monitor-exit p0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw v0
.end method

.method declared-synchronized start(Ljava/lang/Runnable;)V
    .locals 3

    monitor-enter p0

    .line 28
    :try_start_0
    new-instance v0, Landroid/os/HandlerThread;

    iget-object v1, p0, Lcom/tekartik/sqflite/DatabaseWorker;->name:Ljava/lang/String;

    iget v2, p0, Lcom/tekartik/sqflite/DatabaseWorker;->priority:I

    invoke-direct {v0, v1, v2}, Landroid/os/HandlerThread;-><init>(Ljava/lang/String;I)V

    iput-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorker;->handlerThread:Landroid/os/HandlerThread;

    .line 29
    invoke-virtual {v0}, Landroid/os/HandlerThread;->start()V

    .line 30
    new-instance v0, Landroid/os/Handler;

    iget-object v1, p0, Lcom/tekartik/sqflite/DatabaseWorker;->handlerThread:Landroid/os/HandlerThread;

    invoke-virtual {v1}, Landroid/os/HandlerThread;->getLooper()Landroid/os/Looper;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    iput-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorker;->handler:Landroid/os/Handler;

    .line 31
    iput-object p1, p0, Lcom/tekartik/sqflite/DatabaseWorker;->onIdle:Ljava/lang/Runnable;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 32
    monitor-exit p0

    return-void

    :catchall_0
    move-exception p1

    :try_start_1
    monitor-exit p0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw p1
.end method

.method work(Lcom/tekartik/sqflite/DatabaseTask;)V
    .locals 1

    .line 55
    iget-object v0, p1, Lcom/tekartik/sqflite/DatabaseTask;->runnable:Ljava/lang/Runnable;

    invoke-interface {v0}, Ljava/lang/Runnable;->run()V

    .line 56
    iput-object p1, p0, Lcom/tekartik/sqflite/DatabaseWorker;->lastTask:Lcom/tekartik/sqflite/DatabaseTask;

    .line 57
    iget-object p1, p0, Lcom/tekartik/sqflite/DatabaseWorker;->onIdle:Ljava/lang/Runnable;

    invoke-interface {p1}, Ljava/lang/Runnable;->run()V

    return-void
.end method
