.class Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;
.super Ljava/lang/Object;
.source "DatabaseWorkerPool.java"

# interfaces
.implements Lcom/tekartik/sqflite/DatabaseWorkerPool;


# instance fields
.field private final busyWorkers:Ljava/util/Set;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Set<",
            "Lcom/tekartik/sqflite/DatabaseWorker;",
            ">;"
        }
    .end annotation
.end field

.field private final idleWorkers:Ljava/util/Set;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Set<",
            "Lcom/tekartik/sqflite/DatabaseWorker;",
            ">;"
        }
    .end annotation
.end field

.field final name:Ljava/lang/String;

.field final numberOfWorkers:I

.field private final onlyEligibleWorkers:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/Integer;",
            "Lcom/tekartik/sqflite/DatabaseWorker;",
            ">;"
        }
    .end annotation
.end field

.field final priority:I

.field private final waitingList:Ljava/util/LinkedList;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/LinkedList<",
            "Lcom/tekartik/sqflite/DatabaseTask;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method public static synthetic $r8$lambda$GQRlkfjH3zEaAzlz-QqIPX7EVYU(Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;Lcom/tekartik/sqflite/DatabaseWorker;)V
    .locals 0

    invoke-direct {p0, p1}, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->lambda$start$0(Lcom/tekartik/sqflite/DatabaseWorker;)V

    return-void
.end method

.method constructor <init>(Ljava/lang/String;II)V
    .locals 1

    .line 105
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 95
    new-instance v0, Ljava/util/LinkedList;

    invoke-direct {v0}, Ljava/util/LinkedList;-><init>()V

    iput-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->waitingList:Ljava/util/LinkedList;

    .line 96
    new-instance v0, Ljava/util/HashSet;

    invoke-direct {v0}, Ljava/util/HashSet;-><init>()V

    iput-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->idleWorkers:Ljava/util/Set;

    .line 97
    new-instance v0, Ljava/util/HashSet;

    invoke-direct {v0}, Ljava/util/HashSet;-><init>()V

    iput-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->busyWorkers:Ljava/util/Set;

    .line 103
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    iput-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->onlyEligibleWorkers:Ljava/util/Map;

    .line 106
    iput-object p1, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->name:Ljava/lang/String;

    .line 107
    iput p2, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->numberOfWorkers:I

    .line 108
    iput p3, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->priority:I

    return-void
.end method

.method private declared-synchronized findTaskForWorker(Lcom/tekartik/sqflite/DatabaseWorker;)Lcom/tekartik/sqflite/DatabaseTask;
    .locals 4

    monitor-enter p0

    .line 164
    :try_start_0
    iget-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->waitingList:Ljava/util/LinkedList;

    invoke-virtual {v0}, Ljava/util/LinkedList;->listIterator()Ljava/util/ListIterator;

    move-result-object v0

    .line 165
    :goto_0
    invoke-interface {v0}, Ljava/util/ListIterator;->hasNext()Z

    move-result v1

    const/4 v2, 0x0

    if-eqz v1, :cond_2

    .line 166
    invoke-interface {v0}, Ljava/util/ListIterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/tekartik/sqflite/DatabaseTask;

    .line 168
    invoke-virtual {v1}, Lcom/tekartik/sqflite/DatabaseTask;->getDatabaseId()Ljava/lang/Integer;

    move-result-object v3

    if-eqz v3, :cond_0

    .line 169
    iget-object v2, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->onlyEligibleWorkers:Ljava/util/Map;

    invoke-virtual {v1}, Lcom/tekartik/sqflite/DatabaseTask;->getDatabaseId()Ljava/lang/Integer;

    move-result-object v3

    invoke-interface {v2, v3}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/tekartik/sqflite/DatabaseWorker;

    :cond_0
    if-eqz v2, :cond_1

    if-eq v2, p1, :cond_1

    goto :goto_0

    .line 175
    :cond_1
    invoke-interface {v0}, Ljava/util/ListIterator;->remove()V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 176
    monitor-exit p0

    return-object v1

    .line 179
    :cond_2
    monitor-exit p0

    return-object v2

    :catchall_0
    move-exception p1

    :try_start_1
    monitor-exit p0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw p1
.end method

.method private synthetic lambda$start$0(Lcom/tekartik/sqflite/DatabaseWorker;)V
    .locals 0

    .line 117
    invoke-direct {p0, p1}, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->onWorkerIdle(Lcom/tekartik/sqflite/DatabaseWorker;)V

    return-void
.end method

.method private declared-synchronized onWorkerIdle(Lcom/tekartik/sqflite/DatabaseWorker;)V
    .locals 3

    monitor-enter p0

    .line 184
    :try_start_0
    new-instance v0, Ljava/util/HashSet;

    iget-object v1, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->idleWorkers:Ljava/util/Set;

    invoke-direct {v0, v1}, Ljava/util/HashSet;-><init>(Ljava/util/Collection;)V

    .line 187
    iget-object v1, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->busyWorkers:Ljava/util/Set;

    invoke-interface {v1, p1}, Ljava/util/Set;->remove(Ljava/lang/Object;)Z

    .line 188
    iget-object v1, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->idleWorkers:Ljava/util/Set;

    invoke-interface {v1, p1}, Ljava/util/Set;->add(Ljava/lang/Object;)Z

    .line 193
    invoke-virtual {p1}, Lcom/tekartik/sqflite/DatabaseWorker;->isLastTaskInTransaction()Z

    move-result v1

    if-nez v1, :cond_0

    invoke-virtual {p1}, Lcom/tekartik/sqflite/DatabaseWorker;->lastTaskDatabaseId()Ljava/lang/Integer;

    move-result-object v1

    if-eqz v1, :cond_0

    .line 194
    iget-object v1, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->onlyEligibleWorkers:Ljava/util/Map;

    invoke-virtual {p1}, Lcom/tekartik/sqflite/DatabaseWorker;->lastTaskDatabaseId()Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v1, v2}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    .line 196
    :cond_0
    invoke-direct {p0, p1}, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->tryPostingTaskToWorker(Lcom/tekartik/sqflite/DatabaseWorker;)V

    .line 199
    invoke-interface {v0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object p1

    :goto_0
    invoke-interface {p1}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_1

    invoke-interface {p1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/tekartik/sqflite/DatabaseWorker;

    .line 200
    invoke-direct {p0, v0}, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->tryPostingTaskToWorker(Lcom/tekartik/sqflite/DatabaseWorker;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    .line 202
    :cond_1
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

.method private declared-synchronized tryPostingTaskToWorker(Lcom/tekartik/sqflite/DatabaseWorker;)V
    .locals 3

    monitor-enter p0

    .line 148
    :try_start_0
    invoke-direct {p0, p1}, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->findTaskForWorker(Lcom/tekartik/sqflite/DatabaseWorker;)Lcom/tekartik/sqflite/DatabaseTask;

    move-result-object v0

    if-eqz v0, :cond_1

    .line 151
    iget-object v1, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->busyWorkers:Ljava/util/Set;

    invoke-interface {v1, p1}, Ljava/util/Set;->add(Ljava/lang/Object;)Z

    .line 152
    iget-object v1, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->idleWorkers:Ljava/util/Set;

    invoke-interface {v1, p1}, Ljava/util/Set;->remove(Ljava/lang/Object;)Z

    .line 156
    invoke-virtual {v0}, Lcom/tekartik/sqflite/DatabaseTask;->getDatabaseId()Ljava/lang/Integer;

    move-result-object v1

    if-eqz v1, :cond_0

    .line 157
    iget-object v1, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->onlyEligibleWorkers:Ljava/util/Map;

    invoke-virtual {v0}, Lcom/tekartik/sqflite/DatabaseTask;->getDatabaseId()Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v1, v2, p1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 159
    :cond_0
    invoke-virtual {p1, v0}, Lcom/tekartik/sqflite/DatabaseWorker;->postTask(Lcom/tekartik/sqflite/DatabaseTask;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 161
    :cond_1
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


# virtual methods
.method protected createWorker(Ljava/lang/String;I)Lcom/tekartik/sqflite/DatabaseWorker;
    .locals 1

    .line 124
    new-instance v0, Lcom/tekartik/sqflite/DatabaseWorker;

    invoke-direct {v0, p1, p2}, Lcom/tekartik/sqflite/DatabaseWorker;-><init>(Ljava/lang/String;I)V

    return-object v0
.end method

.method public declared-synchronized post(Lcom/tekartik/sqflite/DatabaseTask;)V
    .locals 1

    monitor-enter p0

    .line 139
    :try_start_0
    iget-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->waitingList:Ljava/util/LinkedList;

    invoke-virtual {v0, p1}, Ljava/util/LinkedList;->add(Ljava/lang/Object;)Z

    .line 141
    new-instance p1, Ljava/util/HashSet;

    iget-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->idleWorkers:Ljava/util/Set;

    invoke-direct {p1, v0}, Ljava/util/HashSet;-><init>(Ljava/util/Collection;)V

    .line 142
    invoke-interface {p1}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object p1

    :goto_0
    invoke-interface {p1}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_0

    invoke-interface {p1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/tekartik/sqflite/DatabaseWorker;

    .line 143
    invoke-direct {p0, v0}, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->tryPostingTaskToWorker(Lcom/tekartik/sqflite/DatabaseWorker;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    .line 145
    :cond_0
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

.method public declared-synchronized quit()V
    .locals 2

    monitor-enter p0

    .line 129
    :try_start_0
    iget-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->idleWorkers:Ljava/util/Set;

    invoke-interface {v0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_0

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/tekartik/sqflite/DatabaseWorker;

    .line 130
    invoke-virtual {v1}, Lcom/tekartik/sqflite/DatabaseWorker;->quit()V

    goto :goto_0

    .line 132
    :cond_0
    iget-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->busyWorkers:Ljava/util/Set;

    invoke-interface {v0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_1
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_1

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/tekartik/sqflite/DatabaseWorker;

    .line 133
    invoke-virtual {v1}, Lcom/tekartik/sqflite/DatabaseWorker;->quit()V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_1

    .line 135
    :cond_1
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

.method public declared-synchronized start()V
    .locals 3

    monitor-enter p0

    const/4 v0, 0x0

    .line 113
    :goto_0
    :try_start_0
    iget v1, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->numberOfWorkers:I

    if-ge v0, v1, :cond_0

    .line 114
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v2, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->name:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    iget v2, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->priority:I

    invoke-virtual {p0, v1, v2}, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->createWorker(Ljava/lang/String;I)Lcom/tekartik/sqflite/DatabaseWorker;

    move-result-object v1

    .line 115
    new-instance v2, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl$$ExternalSyntheticLambda0;

    invoke-direct {v2, p0, v1}, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl$$ExternalSyntheticLambda0;-><init>(Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;Lcom/tekartik/sqflite/DatabaseWorker;)V

    invoke-virtual {v1, v2}, Lcom/tekartik/sqflite/DatabaseWorker;->start(Ljava/lang/Runnable;)V

    .line 119
    iget-object v2, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->idleWorkers:Ljava/util/Set;

    invoke-interface {v2, v1}, Ljava/util/Set;->add(Ljava/lang/Object;)Z
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 121
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
