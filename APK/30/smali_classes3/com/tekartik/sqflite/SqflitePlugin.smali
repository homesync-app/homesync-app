.class public Lcom/tekartik/sqflite/SqflitePlugin;
.super Ljava/lang/Object;
.source "SqflitePlugin.java"

# interfaces
.implements Lio/flutter/embedding/engine/plugins/FlutterPlugin;
.implements Lio/flutter/plugin/common/MethodChannel$MethodCallHandler;


# static fields
.field private static THREAD_COUNT:I

.field private static THREAD_PRIORITY:I

.field static final _singleInstancesByPath:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/Integer;",
            ">;"
        }
    .end annotation
.end field

.field private static databaseId:I

.field static final databaseMap:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/Integer;",
            "Lcom/tekartik/sqflite/Database;",
            ">;"
        }
    .end annotation
.end field

.field private static final databaseMapLocker:Ljava/lang/Object;

.field private static databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

.field static databasesPath:Ljava/lang/String;

.field static logLevel:I

.field private static final openCloseLocker:Ljava/lang/Object;


# instance fields
.field private context:Landroid/content/Context;

.field private methodChannel:Lio/flutter/plugin/common/MethodChannel;


# direct methods
.method static bridge synthetic -$$Nest$mcloseDatabase(Lcom/tekartik/sqflite/SqflitePlugin;Lcom/tekartik/sqflite/Database;)V
    .locals 0

    invoke-direct {p0, p1}, Lcom/tekartik/sqflite/SqflitePlugin;->closeDatabase(Lcom/tekartik/sqflite/Database;)V

    return-void
.end method

.method static bridge synthetic -$$Nest$sfgetdatabaseId()I
    .locals 1

    sget v0, Lcom/tekartik/sqflite/SqflitePlugin;->databaseId:I

    return v0
.end method

.method static bridge synthetic -$$Nest$sfgetopenCloseLocker()Ljava/lang/Object;
    .locals 1

    sget-object v0, Lcom/tekartik/sqflite/SqflitePlugin;->openCloseLocker:Ljava/lang/Object;

    return-object v0
.end method

.method static constructor <clinit>()V
    .locals 2

    .line 59
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sput-object v0, Lcom/tekartik/sqflite/SqflitePlugin;->_singleInstancesByPath:Ljava/util/Map;

    .line 61
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sput-object v0, Lcom/tekartik/sqflite/SqflitePlugin;->databaseMap:Ljava/util/Map;

    .line 62
    new-instance v0, Ljava/lang/Object;

    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    sput-object v0, Lcom/tekartik/sqflite/SqflitePlugin;->databaseMapLocker:Ljava/lang/Object;

    .line 63
    new-instance v0, Ljava/lang/Object;

    invoke-direct {v0}, Ljava/lang/Object;-><init>()V

    sput-object v0, Lcom/tekartik/sqflite/SqflitePlugin;->openCloseLocker:Ljava/lang/Object;

    const/4 v0, 0x0

    .line 64
    sput v0, Lcom/tekartik/sqflite/SqflitePlugin;->logLevel:I

    .line 67
    sput v0, Lcom/tekartik/sqflite/SqflitePlugin;->THREAD_PRIORITY:I

    const/4 v1, 0x1

    .line 68
    sput v1, Lcom/tekartik/sqflite/SqflitePlugin;->THREAD_COUNT:I

    .line 69
    sput v0, Lcom/tekartik/sqflite/SqflitePlugin;->databaseId:I

    return-void
.end method

.method public constructor <init>()V
    .locals 0

    .line 76
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public constructor <init>(Landroid/content/Context;)V
    .locals 0

    .line 81
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 82
    invoke-virtual {p1}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object p1

    iput-object p1, p0, Lcom/tekartik/sqflite/SqflitePlugin;->context:Landroid/content/Context;

    return-void
.end method

.method private closeDatabase(Lcom/tekartik/sqflite/Database;)V
    .locals 4

    .line 557
    :try_start_0
    iget v0, p1, Lcom/tekartik/sqflite/Database;->logLevel:I

    invoke-static {v0}, Lcom/tekartik/sqflite/LogLevel;->hasSqlLevel(I)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 558
    const-string v0, "Sqflite"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p1}, Lcom/tekartik/sqflite/Database;->getThreadLogPrefix()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "closing database "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 560
    :cond_0
    invoke-virtual {p1}, Lcom/tekartik/sqflite/Database;->close()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v0

    .line 562
    const-string v1, "Sqflite"

    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "error "

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v2, " while closing database "

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    sget v2, Lcom/tekartik/sqflite/SqflitePlugin;->databaseId:I

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v1, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 564
    :goto_0
    sget-object v0, Lcom/tekartik/sqflite/SqflitePlugin;->databaseMapLocker:Ljava/lang/Object;

    monitor-enter v0

    .line 566
    :try_start_1
    sget-object v1, Lcom/tekartik/sqflite/SqflitePlugin;->databaseMap:Ljava/util/Map;

    invoke-interface {v1}, Ljava/util/Map;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_2

    sget-object v1, Lcom/tekartik/sqflite/SqflitePlugin;->databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    if-eqz v1, :cond_2

    .line 567
    iget v1, p1, Lcom/tekartik/sqflite/Database;->logLevel:I

    invoke-static {v1}, Lcom/tekartik/sqflite/LogLevel;->hasSqlLevel(I)Z

    move-result v1

    if-eqz v1, :cond_1

    .line 568
    const-string v1, "Sqflite"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p1}, Lcom/tekartik/sqflite/Database;->getThreadLogPrefix()Ljava/lang/String;

    move-result-object p1

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    const-string v2, "stopping thread"

    invoke-virtual {p1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v1, p1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 570
    :cond_1
    sget-object p1, Lcom/tekartik/sqflite/SqflitePlugin;->databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    invoke-interface {p1}, Lcom/tekartik/sqflite/DatabaseWorkerPool;->quit()V

    const/4 p1, 0x0

    .line 571
    sput-object p1, Lcom/tekartik/sqflite/SqflitePlugin;->databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    .line 573
    :cond_2
    monitor-exit v0

    return-void

    :catchall_0
    move-exception p1

    monitor-exit v0
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw p1
.end method

.method private static fixMap(Ljava/util/Map;)Ljava/util/Map;
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/Map<",
            "Ljava/lang/Object;",
            "Ljava/lang/Object;",
            ">;)",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation

    .line 86
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    .line 87
    invoke-interface {p0}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object p0

    invoke-interface {p0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object p0

    :goto_0
    invoke-interface {p0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_1

    invoke-interface {p0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/util/Map$Entry;

    .line 88
    invoke-interface {v1}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v2

    .line 89
    instance-of v3, v2, Ljava/util/Map;

    if-eqz v3, :cond_0

    .line 91
    check-cast v2, Ljava/util/Map;

    .line 92
    invoke-static {v2}, Lcom/tekartik/sqflite/SqflitePlugin;->fixMap(Ljava/util/Map;)Ljava/util/Map;

    move-result-object v2

    goto :goto_1

    .line 94
    :cond_0
    invoke-static {v2}, Lcom/tekartik/sqflite/SqflitePlugin;->toString(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v2

    .line 96
    :goto_1
    invoke-interface {v1}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v1

    invoke-static {v1}, Lcom/tekartik/sqflite/SqflitePlugin;->toString(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    goto :goto_0

    :cond_1
    return-object v0
.end method

.method private getContext()Landroid/content/Context;
    .locals 1

    .line 162
    iget-object v0, p0, Lcom/tekartik/sqflite/SqflitePlugin;->context:Landroid/content/Context;

    return-object v0
.end method

.method private getDatabase(I)Lcom/tekartik/sqflite/Database;
    .locals 1

    .line 166
    sget-object v0, Lcom/tekartik/sqflite/SqflitePlugin;->databaseMap:Ljava/util/Map;

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    invoke-interface {v0, p1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Lcom/tekartik/sqflite/Database;

    return-object p1
.end method

.method private getDatabaseOrError(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)Lcom/tekartik/sqflite/Database;
    .locals 2

    .line 170
    const-string v0, "id"

    invoke-virtual {p1, v0}, Lio/flutter/plugin/common/MethodCall;->argument(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/Integer;

    invoke-virtual {p1}, Ljava/lang/Integer;->intValue()I

    move-result p1

    .line 171
    invoke-direct {p0, p1}, Lcom/tekartik/sqflite/SqflitePlugin;->getDatabase(I)Lcom/tekartik/sqflite/Database;

    move-result-object v0

    if-eqz v0, :cond_0

    return-object v0

    .line 176
    :cond_0
    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "database_closed "

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    const-string v0, "sqlite_error"

    const/4 v1, 0x0

    invoke-interface {p2, v0, p1, v1}, Lio/flutter/plugin/common/MethodChannel$Result;->error(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V

    return-object v1
.end method

.method static isInMemoryPath(Ljava/lang/String;)Z
    .locals 1

    if-eqz p0, :cond_1

    .line 122
    const-string v0, ":memory:"

    invoke-virtual {p0, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_0

    goto :goto_0

    :cond_0
    const/4 p0, 0x0

    return p0

    :cond_1
    :goto_0
    const/4 p0, 0x1

    return p0
.end method

.method static synthetic lambda$onBatchCall$2(Lcom/tekartik/sqflite/Database;Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 0

    .line 218
    invoke-virtual {p0, p1, p2}, Lcom/tekartik/sqflite/Database;->batch(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    return-void
.end method

.method static synthetic lambda$onExecuteCall$4(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;Lcom/tekartik/sqflite/Database;)V
    .locals 1

    .line 246
    new-instance v0, Lcom/tekartik/sqflite/operation/MethodCallOperation;

    invoke-direct {v0, p0, p1}, Lcom/tekartik/sqflite/operation/MethodCallOperation;-><init>(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    .line 247
    invoke-virtual {p2, v0}, Lcom/tekartik/sqflite/Database;->execute(Lcom/tekartik/sqflite/operation/Operation;)V

    return-void
.end method

.method static synthetic lambda$onInsertCall$3(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;Lcom/tekartik/sqflite/Database;)V
    .locals 1

    .line 231
    new-instance v0, Lcom/tekartik/sqflite/operation/MethodCallOperation;

    invoke-direct {v0, p0, p1}, Lcom/tekartik/sqflite/operation/MethodCallOperation;-><init>(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    .line 232
    invoke-virtual {p2, v0}, Lcom/tekartik/sqflite/Database;->insert(Lcom/tekartik/sqflite/operation/Operation;)V

    return-void
.end method

.method static synthetic lambda$onOpenDatabaseCall$7(ZLjava/lang/String;Lio/flutter/plugin/common/MethodChannel$Result;Ljava/lang/Boolean;Lcom/tekartik/sqflite/Database;Lio/flutter/plugin/common/MethodCall;ZI)V
    .locals 3

    const-string v0, "open_failed "

    .line 405
    sget-object v1, Lcom/tekartik/sqflite/SqflitePlugin;->openCloseLocker:Ljava/lang/Object;

    monitor-enter v1

    if-nez p0, :cond_0

    .line 408
    :try_start_0
    new-instance p0, Ljava/io/File;

    invoke-direct {p0, p1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 409
    new-instance v2, Ljava/io/File;

    invoke-virtual {p0}, Ljava/io/File;->getParent()Ljava/lang/String;

    move-result-object p0

    invoke-direct {v2, p0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 410
    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    move-result p0

    if-nez p0, :cond_0

    .line 411
    invoke-virtual {v2}, Ljava/io/File;->mkdirs()Z

    move-result p0

    if-nez p0, :cond_0

    .line 412
    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    move-result p0

    if-nez p0, :cond_0

    .line 413
    const-string p0, "sqlite_error"

    new-instance p3, Ljava/lang/StringBuilder;

    invoke-direct {p3, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    const/4 p3, 0x0

    invoke-interface {p2, p0, p1, p3}, Lio/flutter/plugin/common/MethodChannel$Result;->error(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V

    .line 414
    monitor-exit v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    return-void

    .line 422
    :cond_0
    :try_start_1
    sget-object p0, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    invoke-virtual {p0, p3}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_1

    .line 423
    invoke-virtual {p4}, Lcom/tekartik/sqflite/Database;->openReadOnly()V

    goto :goto_0

    .line 425
    :cond_1
    invoke-virtual {p4}, Lcom/tekartik/sqflite/Database;->open()V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_0
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    .line 433
    :goto_0
    :try_start_2
    sget-object p0, Lcom/tekartik/sqflite/SqflitePlugin;->databaseMapLocker:Ljava/lang/Object;

    monitor-enter p0
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_1

    if-eqz p6, :cond_2

    .line 435
    :try_start_3
    sget-object p3, Lcom/tekartik/sqflite/SqflitePlugin;->_singleInstancesByPath:Ljava/util/Map;

    invoke-static {p7}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p5

    invoke-interface {p3, p1, p5}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 437
    :cond_2
    sget-object p3, Lcom/tekartik/sqflite/SqflitePlugin;->databaseMap:Ljava/util/Map;

    invoke-static {p7}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p5

    invoke-interface {p3, p5, p4}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 438
    monitor-exit p0
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    .line 439
    :try_start_4
    iget p0, p4, Lcom/tekartik/sqflite/Database;->logLevel:I

    invoke-static {p0}, Lcom/tekartik/sqflite/LogLevel;->hasSqlLevel(I)Z

    move-result p0

    if-eqz p0, :cond_3

    .line 440
    const-string p0, "Sqflite"

    new-instance p3, Ljava/lang/StringBuilder;

    invoke-direct {p3}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p4}, Lcom/tekartik/sqflite/Database;->getThreadLogPrefix()Ljava/lang/String;

    move-result-object p4

    invoke-virtual {p3, p4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p3

    const-string p4, "opened "

    invoke-virtual {p3, p4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p3

    invoke-virtual {p3, p7}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p3

    const-string p4, " "

    invoke-virtual {p3, p4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p3

    invoke-virtual {p3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p0, p1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 442
    :cond_3
    monitor-exit v1
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_1

    const/4 p0, 0x0

    .line 444
    invoke-static {p7, p0, p0}, Lcom/tekartik/sqflite/SqflitePlugin;->makeOpenResult(IZZ)Ljava/util/Map;

    move-result-object p0

    invoke-interface {p2, p0}, Lio/flutter/plugin/common/MethodChannel$Result;->success(Ljava/lang/Object;)V

    return-void

    :catchall_0
    move-exception p1

    .line 438
    :try_start_5
    monitor-exit p0
    :try_end_5
    .catchall {:try_start_5 .. :try_end_5} :catchall_0

    :try_start_6
    throw p1

    :catchall_1
    move-exception p0

    goto :goto_1

    :catch_0
    move-exception p0

    .line 428
    new-instance p1, Lcom/tekartik/sqflite/operation/MethodCallOperation;

    invoke-direct {p1, p5, p2}, Lcom/tekartik/sqflite/operation/MethodCallOperation;-><init>(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    .line 429
    invoke-virtual {p4, p0, p1}, Lcom/tekartik/sqflite/Database;->handleException(Ljava/lang/Exception;Lcom/tekartik/sqflite/operation/Operation;)V

    .line 430
    monitor-exit v1

    return-void

    .line 442
    :goto_1
    monitor-exit v1
    :try_end_6
    .catchall {:try_start_6 .. :try_end_6} :catchall_1

    throw p0
.end method

.method static synthetic lambda$onQueryCall$0(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;Lcom/tekartik/sqflite/Database;)V
    .locals 1

    .line 190
    new-instance v0, Lcom/tekartik/sqflite/operation/MethodCallOperation;

    invoke-direct {v0, p0, p1}, Lcom/tekartik/sqflite/operation/MethodCallOperation;-><init>(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    .line 191
    invoke-virtual {p2, v0}, Lcom/tekartik/sqflite/Database;->query(Lcom/tekartik/sqflite/operation/Operation;)V

    return-void
.end method

.method static synthetic lambda$onQueryCursorNextCall$1(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;Lcom/tekartik/sqflite/Database;)V
    .locals 1

    .line 204
    new-instance v0, Lcom/tekartik/sqflite/operation/MethodCallOperation;

    invoke-direct {v0, p0, p1}, Lcom/tekartik/sqflite/operation/MethodCallOperation;-><init>(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    .line 205
    invoke-virtual {p2, v0}, Lcom/tekartik/sqflite/Database;->queryCursorNext(Lcom/tekartik/sqflite/operation/Operation;)V

    return-void
.end method

.method static synthetic lambda$onSetLocaleCall$5(Lio/flutter/plugin/common/MethodCall;Lcom/tekartik/sqflite/Database;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 2

    .line 258
    const-string v0, "locale"

    invoke-virtual {p0, v0}, Lio/flutter/plugin/common/MethodCall;->argument(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/String;

    const/4 v0, 0x0

    .line 260
    :try_start_0
    iget-object p1, p1, Lcom/tekartik/sqflite/Database;->sqliteDatabase:Landroid/database/sqlite/SQLiteDatabase;

    invoke-static {p0}, Lcom/tekartik/sqflite/Utils;->localeForLanguageTag(Ljava/lang/String;)Ljava/util/Locale;

    move-result-object p0

    invoke-virtual {p1, p0}, Landroid/database/sqlite/SQLiteDatabase;->setLocale(Ljava/util/Locale;)V

    .line 261
    invoke-interface {p2, v0}, Lio/flutter/plugin/common/MethodChannel$Result;->success(Ljava/lang/Object;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception p0

    .line 263
    new-instance p1, Ljava/lang/StringBuilder;

    const-string v1, "Error calling setLocale: "

    invoke-direct {p1, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p0}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    move-result-object p0

    invoke-virtual {p1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    const-string p1, "sqlite_error"

    invoke-interface {p2, p1, p0, v0}, Lio/flutter/plugin/common/MethodChannel$Result;->error(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V

    return-void
.end method

.method static synthetic lambda$onUpdateCall$6(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;Lcom/tekartik/sqflite/Database;)V
    .locals 1

    .line 279
    new-instance v0, Lcom/tekartik/sqflite/operation/MethodCallOperation;

    invoke-direct {v0, p0, p1}, Lcom/tekartik/sqflite/operation/MethodCallOperation;-><init>(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    .line 280
    invoke-virtual {p2, v0}, Lcom/tekartik/sqflite/Database;->update(Lcom/tekartik/sqflite/operation/Operation;)V

    return-void
.end method

.method static makeOpenResult(IZZ)Ljava/util/Map;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(IZZ)",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation

    .line 130
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    .line 131
    const-string v1, "id"

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p0

    invoke-interface {v0, v1, p0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const/4 p0, 0x1

    .line 133
    invoke-static {p0}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object p0

    if-eqz p1, :cond_0

    const-string p1, "recovered"

    invoke-interface {v0, p1, p0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    :cond_0
    if-eqz p2, :cond_1

    .line 136
    const-string p1, "recoveredInTransaction"

    invoke-interface {v0, p1, p0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    :cond_1
    return-object v0
.end method

.method private onAttachedToEngine(Landroid/content/Context;Lio/flutter/plugin/common/BinaryMessenger;)V
    .locals 3

    .line 147
    iput-object p1, p0, Lcom/tekartik/sqflite/SqflitePlugin;->context:Landroid/content/Context;

    .line 148
    new-instance p1, Lio/flutter/plugin/common/MethodChannel;

    sget-object v0, Lio/flutter/plugin/common/StandardMethodCodec;->INSTANCE:Lio/flutter/plugin/common/StandardMethodCodec;

    .line 150
    invoke-interface {p2}, Lio/flutter/plugin/common/BinaryMessenger;->makeBackgroundTaskQueue()Lio/flutter/plugin/common/BinaryMessenger$TaskQueue;

    move-result-object v1

    const-string v2, "com.tekartik.sqflite"

    invoke-direct {p1, p2, v2, v0, v1}, Lio/flutter/plugin/common/MethodChannel;-><init>(Lio/flutter/plugin/common/BinaryMessenger;Ljava/lang/String;Lio/flutter/plugin/common/MethodCodec;Lio/flutter/plugin/common/BinaryMessenger$TaskQueue;)V

    iput-object p1, p0, Lcom/tekartik/sqflite/SqflitePlugin;->methodChannel:Lio/flutter/plugin/common/MethodChannel;

    .line 151
    invoke-virtual {p1, p0}, Lio/flutter/plugin/common/MethodChannel;->setMethodCallHandler(Lio/flutter/plugin/common/MethodChannel$MethodCallHandler;)V

    return-void
.end method

.method private onBatchCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 3

    .line 214
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->getDatabaseOrError(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)Lcom/tekartik/sqflite/Database;

    move-result-object v0

    if-nez v0, :cond_0

    return-void

    .line 218
    :cond_0
    sget-object v1, Lcom/tekartik/sqflite/SqflitePlugin;->databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    new-instance v2, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda7;

    invoke-direct {v2, v0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda7;-><init>(Lcom/tekartik/sqflite/Database;Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    invoke-interface {v1, v0, v2}, Lcom/tekartik/sqflite/DatabaseWorkerPool;->post(Lcom/tekartik/sqflite/Database;Ljava/lang/Runnable;)V

    return-void
.end method

.method private onCloseDatabaseCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 4

    .line 454
    const-string v0, "id"

    invoke-virtual {p1, v0}, Lio/flutter/plugin/common/MethodCall;->argument(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    .line 455
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->getDatabaseOrError(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)Lcom/tekartik/sqflite/Database;

    move-result-object p1

    if-nez p1, :cond_0

    return-void

    .line 460
    :cond_0
    iget v1, p1, Lcom/tekartik/sqflite/Database;->logLevel:I

    invoke-static {v1}, Lcom/tekartik/sqflite/LogLevel;->hasSqlLevel(I)Z

    move-result v1

    if-eqz v1, :cond_1

    .line 461
    const-string v1, "Sqflite"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {p1}, Lcom/tekartik/sqflite/Database;->getThreadLogPrefix()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, "closing "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, " "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget-object v3, p1, Lcom/tekartik/sqflite/Database;->path:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 464
    :cond_1
    iget-object v1, p1, Lcom/tekartik/sqflite/Database;->path:Ljava/lang/String;

    .line 467
    sget-object v2, Lcom/tekartik/sqflite/SqflitePlugin;->databaseMapLocker:Ljava/lang/Object;

    monitor-enter v2

    .line 468
    :try_start_0
    sget-object v3, Lcom/tekartik/sqflite/SqflitePlugin;->databaseMap:Ljava/util/Map;

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    invoke-interface {v3, v0}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    .line 470
    iget-boolean v0, p1, Lcom/tekartik/sqflite/Database;->singleInstance:Z

    if-eqz v0, :cond_2

    .line 471
    sget-object v0, Lcom/tekartik/sqflite/SqflitePlugin;->_singleInstancesByPath:Ljava/util/Map;

    invoke-interface {v0, v1}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    .line 473
    :cond_2
    monitor-exit v2
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 475
    sget-object v0, Lcom/tekartik/sqflite/SqflitePlugin;->databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    new-instance v1, Lcom/tekartik/sqflite/SqflitePlugin$1;

    invoke-direct {v1, p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin$1;-><init>(Lcom/tekartik/sqflite/SqflitePlugin;Lcom/tekartik/sqflite/Database;Lio/flutter/plugin/common/MethodChannel$Result;)V

    invoke-interface {v0, p1, v1}, Lcom/tekartik/sqflite/DatabaseWorkerPool;->post(Lcom/tekartik/sqflite/Database;Ljava/lang/Runnable;)V

    return-void

    :catchall_0
    move-exception p1

    .line 473
    :try_start_1
    monitor-exit v2
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw p1
.end method

.method private onDatabaseExistsCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 1

    .line 550
    const-string v0, "path"

    invoke-virtual {p1, v0}, Lio/flutter/plugin/common/MethodCall;->argument(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/String;

    .line 551
    invoke-static {p1}, Lcom/tekartik/sqflite/Database;->existsDatabase(Ljava/lang/String;)Z

    move-result p1

    .line 552
    invoke-static {p1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object p1

    invoke-interface {p2, p1}, Lio/flutter/plugin/common/MethodChannel$Result;->success(Ljava/lang/Object;)V

    return-void
.end method

.method private onDebugCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 8

    .line 285
    const-string v0, "cmd"

    invoke-virtual {p1, v0}, Lio/flutter/plugin/common/MethodCall;->argument(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/String;

    .line 286
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    .line 290
    const-string v1, "get"

    invoke-virtual {v1, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_3

    .line 291
    sget p1, Lcom/tekartik/sqflite/SqflitePlugin;->logLevel:I

    const-string v1, "logLevel"

    if-lez p1, :cond_0

    .line 292
    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    invoke-interface {v0, v1, p1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 294
    :cond_0
    sget-object p1, Lcom/tekartik/sqflite/SqflitePlugin;->databaseMap:Ljava/util/Map;

    invoke-interface {p1}, Ljava/util/Map;->isEmpty()Z

    move-result v2

    if-nez v2, :cond_3

    .line 295
    new-instance v2, Ljava/util/HashMap;

    invoke-direct {v2}, Ljava/util/HashMap;-><init>()V

    .line 296
    invoke-interface {p1}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object p1

    invoke-interface {p1}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object p1

    :goto_0
    invoke-interface {p1}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_2

    invoke-interface {p1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/util/Map$Entry;

    .line 297
    invoke-interface {v3}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Lcom/tekartik/sqflite/Database;

    .line 298
    new-instance v5, Ljava/util/HashMap;

    invoke-direct {v5}, Ljava/util/HashMap;-><init>()V

    .line 299
    const-string v6, "path"

    iget-object v7, v4, Lcom/tekartik/sqflite/Database;->path:Ljava/lang/String;

    invoke-interface {v5, v6, v7}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 300
    iget-boolean v6, v4, Lcom/tekartik/sqflite/Database;->singleInstance:Z

    invoke-static {v6}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v6

    const-string v7, "singleInstance"

    invoke-interface {v5, v7, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 301
    iget v6, v4, Lcom/tekartik/sqflite/Database;->logLevel:I

    if-lez v6, :cond_1

    .line 302
    iget v4, v4, Lcom/tekartik/sqflite/Database;->logLevel:I

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v4

    invoke-interface {v5, v1, v4}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 304
    :cond_1
    invoke-interface {v3}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/Integer;

    invoke-virtual {v3}, Ljava/lang/Integer;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-interface {v2, v3, v5}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    goto :goto_0

    .line 307
    :cond_2
    const-string p1, "databases"

    invoke-interface {v0, p1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 310
    :cond_3
    invoke-interface {p2, v0}, Lio/flutter/plugin/common/MethodChannel$Result;->success(Ljava/lang/Object;)V

    return-void
.end method

.method private onDebugModeCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 2

    .line 317
    invoke-virtual {p1}, Lio/flutter/plugin/common/MethodCall;->arguments()Ljava/lang/Object;

    move-result-object p1

    .line 318
    sget-object v0, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    invoke-virtual {v0, p1}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result p1

    sput-boolean p1, Lcom/tekartik/sqflite/dev/Debug;->LOGV:Z

    .line 319
    sget-boolean p1, Lcom/tekartik/sqflite/dev/Debug;->_EXTRA_LOGV:Z

    const/4 v0, 0x1

    const/4 v1, 0x0

    if-eqz p1, :cond_0

    sget-boolean p1, Lcom/tekartik/sqflite/dev/Debug;->LOGV:Z

    if-eqz p1, :cond_0

    move p1, v0

    goto :goto_0

    :cond_0
    move p1, v1

    :goto_0
    sput-boolean p1, Lcom/tekartik/sqflite/dev/Debug;->EXTRA_LOGV:Z

    .line 322
    sget-boolean p1, Lcom/tekartik/sqflite/dev/Debug;->LOGV:Z

    if-eqz p1, :cond_2

    .line 323
    sget-boolean p1, Lcom/tekartik/sqflite/dev/Debug;->EXTRA_LOGV:Z

    if-eqz p1, :cond_1

    const/4 p1, 0x2

    .line 324
    sput p1, Lcom/tekartik/sqflite/SqflitePlugin;->logLevel:I

    goto :goto_1

    .line 325
    :cond_1
    sget-boolean p1, Lcom/tekartik/sqflite/dev/Debug;->LOGV:Z

    if-eqz p1, :cond_3

    .line 326
    sput v0, Lcom/tekartik/sqflite/SqflitePlugin;->logLevel:I

    goto :goto_1

    .line 330
    :cond_2
    sput v1, Lcom/tekartik/sqflite/SqflitePlugin;->logLevel:I

    :cond_3
    :goto_1
    const/4 p1, 0x0

    .line 332
    invoke-interface {p2, p1}, Lio/flutter/plugin/common/MethodChannel$Result;->success(Ljava/lang/Object;)V

    return-void
.end method

.method private onDeleteDatabaseCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 8

    const-string v0, "Look for "

    .line 492
    const-string v1, "path"

    invoke-virtual {p1, v1}, Lio/flutter/plugin/common/MethodCall;->argument(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/String;

    .line 495
    sget-object v1, Lcom/tekartik/sqflite/SqflitePlugin;->databaseMapLocker:Ljava/lang/Object;

    monitor-enter v1

    .line 496
    :try_start_0
    sget v2, Lcom/tekartik/sqflite/SqflitePlugin;->logLevel:I

    invoke-static {v2}, Lcom/tekartik/sqflite/LogLevel;->hasVerboseLevel(I)Z

    move-result v2

    if-eqz v2, :cond_0

    .line 497
    const-string v2, "Sqflite"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v3, " in "

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    sget-object v3, Lcom/tekartik/sqflite/SqflitePlugin;->_singleInstancesByPath:Ljava/util/Map;

    invoke-interface {v3}, Ljava/util/Map;->keySet()Ljava/util/Set;

    move-result-object v3

    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v2, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 499
    :cond_0
    sget-object v0, Lcom/tekartik/sqflite/SqflitePlugin;->_singleInstancesByPath:Ljava/util/Map;

    invoke-interface {v0, p1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/Integer;

    if-eqz v2, :cond_3

    .line 501
    sget-object v3, Lcom/tekartik/sqflite/SqflitePlugin;->databaseMap:Ljava/util/Map;

    invoke-interface {v3, v2}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Lcom/tekartik/sqflite/Database;

    if-eqz v4, :cond_3

    .line 503
    iget-object v5, v4, Lcom/tekartik/sqflite/Database;->sqliteDatabase:Landroid/database/sqlite/SQLiteDatabase;

    invoke-virtual {v5}, Landroid/database/sqlite/SQLiteDatabase;->isOpen()Z

    move-result v5

    if-eqz v5, :cond_3

    .line 504
    sget v5, Lcom/tekartik/sqflite/SqflitePlugin;->logLevel:I

    invoke-static {v5}, Lcom/tekartik/sqflite/LogLevel;->hasVerboseLevel(I)Z

    move-result v5

    if-eqz v5, :cond_2

    .line 505
    const-string v5, "Sqflite"

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v4}, Lcom/tekartik/sqflite/Database;->getThreadLogPrefix()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "found single instance "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v4}, Lcom/tekartik/sqflite/Database;->isInTransaction()Z

    move-result v7

    if-eqz v7, :cond_1

    const-string v7, "(in transaction) "

    goto :goto_0

    :cond_1
    const-string v7, ""

    :goto_0
    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, " "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v5, v6}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 510
    :cond_2
    invoke-interface {v3, v2}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    .line 511
    invoke-interface {v0, p1}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    goto :goto_1

    :cond_3
    const/4 v4, 0x0

    .line 515
    :goto_1
    monitor-exit v1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 518
    new-instance v0, Lcom/tekartik/sqflite/SqflitePlugin$2;

    invoke-direct {v0, p0, v4, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin$2;-><init>(Lcom/tekartik/sqflite/SqflitePlugin;Lcom/tekartik/sqflite/Database;Ljava/lang/String;Lio/flutter/plugin/common/MethodChannel$Result;)V

    .line 540
    sget-object p1, Lcom/tekartik/sqflite/SqflitePlugin;->databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    if-eqz p1, :cond_4

    .line 541
    invoke-interface {p1, v4, v0}, Lcom/tekartik/sqflite/DatabaseWorkerPool;->post(Lcom/tekartik/sqflite/Database;Ljava/lang/Runnable;)V

    return-void

    .line 544
    :cond_4
    invoke-interface {v0}, Ljava/lang/Runnable;->run()V

    return-void

    :catchall_0
    move-exception p1

    .line 515
    :try_start_1
    monitor-exit v1
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    throw p1
.end method

.method private onExecuteCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 3

    .line 241
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->getDatabaseOrError(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)Lcom/tekartik/sqflite/Database;

    move-result-object v0

    if-nez v0, :cond_0

    return-void

    .line 245
    :cond_0
    sget-object v1, Lcom/tekartik/sqflite/SqflitePlugin;->databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    new-instance v2, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda5;

    invoke-direct {v2, p1, p2, v0}, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda5;-><init>(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;Lcom/tekartik/sqflite/Database;)V

    invoke-interface {v1, v0, v2}, Lcom/tekartik/sqflite/DatabaseWorkerPool;->post(Lcom/tekartik/sqflite/Database;Ljava/lang/Runnable;)V

    return-void
.end method

.method private onInsertCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 3

    .line 226
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->getDatabaseOrError(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)Lcom/tekartik/sqflite/Database;

    move-result-object v0

    if-nez v0, :cond_0

    return-void

    .line 230
    :cond_0
    sget-object v1, Lcom/tekartik/sqflite/SqflitePlugin;->databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    new-instance v2, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda1;

    invoke-direct {v2, p1, p2, v0}, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda1;-><init>(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;Lcom/tekartik/sqflite/Database;)V

    invoke-interface {v1, v0, v2}, Lcom/tekartik/sqflite/DatabaseWorkerPool;->post(Lcom/tekartik/sqflite/Database;Ljava/lang/Runnable;)V

    return-void
.end method

.method private onOpenDatabaseCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 12

    const-string v0, "Look for "

    .line 339
    const-string v1, "path"

    invoke-virtual {p1, v1}, Lio/flutter/plugin/common/MethodCall;->argument(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    move-object v4, v1

    check-cast v4, Ljava/lang/String;

    .line 340
    const-string v1, "readOnly"

    invoke-virtual {p1, v1}, Lio/flutter/plugin/common/MethodCall;->argument(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Boolean;

    .line 341
    invoke-static {v4}, Lcom/tekartik/sqflite/SqflitePlugin;->isInMemoryPath(Ljava/lang/String;)Z

    move-result v8

    .line 343
    sget-object v2, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    const-string v3, "singleInstance"

    invoke-virtual {p1, v3}, Lio/flutter/plugin/common/MethodCall;->argument(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/Boolean;->equals(Ljava/lang/Object;)Z

    move-result v2

    const/4 v3, 0x1

    if-nez v2, :cond_0

    if-nez v8, :cond_0

    move v6, v3

    goto :goto_0

    :cond_0
    const/4 v2, 0x0

    move v6, v2

    :goto_0
    if-eqz v6, :cond_6

    .line 351
    sget-object v2, Lcom/tekartik/sqflite/SqflitePlugin;->databaseMapLocker:Ljava/lang/Object;

    monitor-enter v2

    .line 352
    :try_start_0
    sget v5, Lcom/tekartik/sqflite/SqflitePlugin;->logLevel:I

    invoke-static {v5}, Lcom/tekartik/sqflite/LogLevel;->hasVerboseLevel(I)Z

    move-result v5

    if-eqz v5, :cond_1

    .line 353
    const-string v5, "Sqflite"

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v7, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v7, " in "

    invoke-virtual {v0, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    sget-object v7, Lcom/tekartik/sqflite/SqflitePlugin;->_singleInstancesByPath:Ljava/util/Map;

    invoke-interface {v7}, Ljava/util/Map;->keySet()Ljava/util/Set;

    move-result-object v7

    invoke-virtual {v0, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v5, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 355
    :cond_1
    sget-object v0, Lcom/tekartik/sqflite/SqflitePlugin;->_singleInstancesByPath:Ljava/util/Map;

    invoke-interface {v0, v4}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    if-eqz v0, :cond_5

    .line 357
    sget-object v5, Lcom/tekartik/sqflite/SqflitePlugin;->databaseMap:Ljava/util/Map;

    invoke-interface {v5, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Lcom/tekartik/sqflite/Database;

    if-eqz v5, :cond_5

    .line 359
    iget-object v7, v5, Lcom/tekartik/sqflite/Database;->sqliteDatabase:Landroid/database/sqlite/SQLiteDatabase;

    invoke-virtual {v7}, Landroid/database/sqlite/SQLiteDatabase;->isOpen()Z

    move-result v7

    if-nez v7, :cond_2

    .line 360
    sget v0, Lcom/tekartik/sqflite/SqflitePlugin;->logLevel:I

    invoke-static {v0}, Lcom/tekartik/sqflite/LogLevel;->hasVerboseLevel(I)Z

    move-result v0

    if-eqz v0, :cond_5

    .line 361
    const-string v0, "Sqflite"

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5}, Lcom/tekartik/sqflite/Database;->getThreadLogPrefix()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v7, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v7, "single instance database of "

    invoke-virtual {v5, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v7, " not opened"

    invoke-virtual {v5, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v0, v5}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_2

    .line 364
    :cond_2
    sget p1, Lcom/tekartik/sqflite/SqflitePlugin;->logLevel:I

    invoke-static {p1}, Lcom/tekartik/sqflite/LogLevel;->hasVerboseLevel(I)Z

    move-result p1

    if-eqz p1, :cond_4

    .line 365
    const-string p1, "Sqflite"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v5}, Lcom/tekartik/sqflite/Database;->getThreadLogPrefix()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v6, "re-opened single instance "

    invoke-virtual {v1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v5}, Lcom/tekartik/sqflite/Database;->isInTransaction()Z

    move-result v6

    if-eqz v6, :cond_3

    const-string v6, "(in transaction) "

    goto :goto_1

    :cond_3
    const-string v6, ""

    :goto_1
    invoke-virtual {v1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v6, " "

    invoke-virtual {v1, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {p1, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 367
    :cond_4
    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result p1

    invoke-virtual {v5}, Lcom/tekartik/sqflite/Database;->isInTransaction()Z

    move-result v0

    invoke-static {p1, v3, v0}, Lcom/tekartik/sqflite/SqflitePlugin;->makeOpenResult(IZZ)Ljava/util/Map;

    move-result-object p1

    invoke-interface {p2, p1}, Lio/flutter/plugin/common/MethodChannel$Result;->success(Ljava/lang/Object;)V

    .line 368
    monitor-exit v2

    return-void

    .line 372
    :cond_5
    :goto_2
    monitor-exit v2

    goto :goto_3

    :catchall_0
    move-exception v0

    move-object p1, v0

    monitor-exit v2
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw p1

    .line 377
    :cond_6
    :goto_3
    sget-object v11, Lcom/tekartik/sqflite/SqflitePlugin;->databaseMapLocker:Ljava/lang/Object;

    monitor-enter v11

    .line 378
    :try_start_1
    sget v0, Lcom/tekartik/sqflite/SqflitePlugin;->databaseId:I

    add-int/lit8 v5, v0, 0x1

    sput v5, Lcom/tekartik/sqflite/SqflitePlugin;->databaseId:I

    .line 379
    monitor-exit v11
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_2

    .line 382
    new-instance v2, Lcom/tekartik/sqflite/Database;

    iget-object v3, p0, Lcom/tekartik/sqflite/SqflitePlugin;->context:Landroid/content/Context;

    sget v7, Lcom/tekartik/sqflite/SqflitePlugin;->logLevel:I

    invoke-direct/range {v2 .. v7}, Lcom/tekartik/sqflite/Database;-><init>(Landroid/content/Context;Ljava/lang/String;IZI)V

    .line 384
    monitor-enter v11

    .line 386
    :try_start_2
    sget-object v0, Lcom/tekartik/sqflite/SqflitePlugin;->databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    if-nez v0, :cond_7

    .line 387
    const-string v0, "Sqflite"

    sget v3, Lcom/tekartik/sqflite/SqflitePlugin;->THREAD_COUNT:I

    sget v7, Lcom/tekartik/sqflite/SqflitePlugin;->THREAD_PRIORITY:I

    invoke-static {v0, v3, v7}, Lcom/tekartik/sqflite/DatabaseWorkerPool;->create(Ljava/lang/String;II)Lcom/tekartik/sqflite/DatabaseWorkerPool;

    move-result-object v0

    sput-object v0, Lcom/tekartik/sqflite/SqflitePlugin;->databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    .line 389
    invoke-interface {v0}, Lcom/tekartik/sqflite/DatabaseWorkerPool;->start()V

    .line 390
    iget v0, v2, Lcom/tekartik/sqflite/Database;->logLevel:I

    invoke-static {v0}, Lcom/tekartik/sqflite/LogLevel;->hasSqlLevel(I)Z

    move-result v0

    if-eqz v0, :cond_7

    .line 391
    const-string v0, "Sqflite"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v2}, Lcom/tekartik/sqflite/Database;->getThreadLogPrefix()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v3, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v7, "starting worker pool with priority "

    invoke-virtual {v3, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    sget v7, Lcom/tekartik/sqflite/SqflitePlugin;->THREAD_PRIORITY:I

    invoke-virtual {v3, v7}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v0, v3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 394
    :cond_7
    sget-object v0, Lcom/tekartik/sqflite/SqflitePlugin;->databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    iput-object v0, v2, Lcom/tekartik/sqflite/Database;->databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    .line 395
    iget v0, v2, Lcom/tekartik/sqflite/Database;->logLevel:I

    invoke-static {v0}, Lcom/tekartik/sqflite/LogLevel;->hasSqlLevel(I)Z

    move-result v0

    if-eqz v0, :cond_8

    .line 396
    const-string v0, "Sqflite"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v2}, Lcom/tekartik/sqflite/Database;->getThreadLogPrefix()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v3, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v7, "opened "

    invoke-virtual {v3, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v7, " "

    invoke-virtual {v3, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v0, v3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 401
    :cond_8
    sget-object v0, Lcom/tekartik/sqflite/SqflitePlugin;->databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    move-object v7, v2

    new-instance v2, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda4;

    move v10, v5

    move v9, v6

    move v3, v8

    move-object v8, p1

    move-object v5, p2

    move-object v6, v1

    invoke-direct/range {v2 .. v10}, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda4;-><init>(ZLjava/lang/String;Lio/flutter/plugin/common/MethodChannel$Result;Ljava/lang/Boolean;Lcom/tekartik/sqflite/Database;Lio/flutter/plugin/common/MethodCall;ZI)V

    move-object p1, v2

    move-object v2, v7

    invoke-interface {v0, v2, p1}, Lcom/tekartik/sqflite/DatabaseWorkerPool;->post(Lcom/tekartik/sqflite/Database;Ljava/lang/Runnable;)V

    .line 446
    monitor-exit v11

    return-void

    :catchall_1
    move-exception v0

    move-object p1, v0

    monitor-exit v11
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_1

    throw p1

    :catchall_2
    move-exception v0

    move-object p1, v0

    .line 379
    :try_start_3
    monitor-exit v11
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_2

    throw p1
.end method

.method private onQueryCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 3

    .line 185
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->getDatabaseOrError(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)Lcom/tekartik/sqflite/Database;

    move-result-object v0

    if-nez v0, :cond_0

    return-void

    .line 189
    :cond_0
    sget-object v1, Lcom/tekartik/sqflite/SqflitePlugin;->databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    new-instance v2, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda2;

    invoke-direct {v2, p1, p2, v0}, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda2;-><init>(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;Lcom/tekartik/sqflite/Database;)V

    invoke-interface {v1, v0, v2}, Lcom/tekartik/sqflite/DatabaseWorkerPool;->post(Lcom/tekartik/sqflite/Database;Ljava/lang/Runnable;)V

    return-void
.end method

.method private onQueryCursorNextCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 3

    .line 199
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->getDatabaseOrError(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)Lcom/tekartik/sqflite/Database;

    move-result-object v0

    if-nez v0, :cond_0

    return-void

    .line 203
    :cond_0
    sget-object v1, Lcom/tekartik/sqflite/SqflitePlugin;->databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    new-instance v2, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda0;

    invoke-direct {v2, p1, p2, v0}, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda0;-><init>(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;Lcom/tekartik/sqflite/Database;)V

    invoke-interface {v1, v0, v2}, Lcom/tekartik/sqflite/DatabaseWorkerPool;->post(Lcom/tekartik/sqflite/Database;Ljava/lang/Runnable;)V

    return-void
.end method

.method private onSetLocaleCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 3

    .line 253
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->getDatabaseOrError(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)Lcom/tekartik/sqflite/Database;

    move-result-object v0

    if-nez v0, :cond_0

    return-void

    .line 257
    :cond_0
    sget-object v1, Lcom/tekartik/sqflite/SqflitePlugin;->databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    new-instance v2, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda3;

    invoke-direct {v2, p1, v0, p2}, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda3;-><init>(Lio/flutter/plugin/common/MethodCall;Lcom/tekartik/sqflite/Database;Lio/flutter/plugin/common/MethodChannel$Result;)V

    invoke-interface {v1, v0, v2}, Lcom/tekartik/sqflite/DatabaseWorkerPool;->post(Lcom/tekartik/sqflite/Database;Ljava/lang/Runnable;)V

    return-void
.end method

.method private onUpdateCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 3

    .line 274
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->getDatabaseOrError(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)Lcom/tekartik/sqflite/Database;

    move-result-object v0

    if-nez v0, :cond_0

    return-void

    .line 278
    :cond_0
    sget-object v1, Lcom/tekartik/sqflite/SqflitePlugin;->databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    new-instance v2, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda6;

    invoke-direct {v2, p1, p2, v0}, Lcom/tekartik/sqflite/SqflitePlugin$$ExternalSyntheticLambda6;-><init>(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;Lcom/tekartik/sqflite/Database;)V

    invoke-interface {v1, v0, v2}, Lcom/tekartik/sqflite/DatabaseWorkerPool;->post(Lcom/tekartik/sqflite/Database;Ljava/lang/Runnable;)V

    return-void
.end method

.method private static toString(Ljava/lang/Object;)Ljava/lang/String;
    .locals 4

    if-nez p0, :cond_0

    const/4 p0, 0x0

    return-object p0

    .line 106
    :cond_0
    instance-of v0, p0, [B

    if-eqz v0, :cond_2

    .line 107
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    .line 108
    check-cast p0, [B

    array-length v1, p0

    const/4 v2, 0x0

    :goto_0
    if-ge v2, v1, :cond_1

    aget-byte v3, p0, v2

    .line 109
    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    invoke-interface {v0, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    .line 111
    :cond_1
    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 112
    :cond_2
    instance-of v0, p0, Ljava/util/Map;

    if-eqz v0, :cond_3

    .line 114
    check-cast p0, Ljava/util/Map;

    .line 115
    invoke-static {p0}, Lcom/tekartik/sqflite/SqflitePlugin;->fixMap(Ljava/util/Map;)Ljava/util/Map;

    move-result-object p0

    invoke-virtual {p0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0

    .line 117
    :cond_3
    invoke-virtual {p0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method public onAttachedToEngine(Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;)V
    .locals 1

    .line 143
    invoke-virtual {p1}, Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;->getApplicationContext()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {p1}, Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;->getBinaryMessenger()Lio/flutter/plugin/common/BinaryMessenger;

    move-result-object p1

    invoke-direct {p0, v0, p1}, Lcom/tekartik/sqflite/SqflitePlugin;->onAttachedToEngine(Landroid/content/Context;Lio/flutter/plugin/common/BinaryMessenger;)V

    return-void
.end method

.method public onDetachedFromEngine(Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;)V
    .locals 1

    const/4 p1, 0x0

    .line 156
    iput-object p1, p0, Lcom/tekartik/sqflite/SqflitePlugin;->context:Landroid/content/Context;

    .line 157
    iget-object v0, p0, Lcom/tekartik/sqflite/SqflitePlugin;->methodChannel:Lio/flutter/plugin/common/MethodChannel;

    invoke-virtual {v0, p1}, Lio/flutter/plugin/common/MethodChannel;->setMethodCallHandler(Lio/flutter/plugin/common/MethodChannel$MethodCallHandler;)V

    .line 158
    iput-object p1, p0, Lcom/tekartik/sqflite/SqflitePlugin;->methodChannel:Lio/flutter/plugin/common/MethodChannel;

    return-void
.end method

.method onGetDatabasesPathCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 1

    .line 675
    sget-object p1, Lcom/tekartik/sqflite/SqflitePlugin;->databasesPath:Ljava/lang/String;

    if-nez p1, :cond_0

    .line 676
    const-string p1, "tekartik_sqflite.db"

    .line 677
    iget-object v0, p0, Lcom/tekartik/sqflite/SqflitePlugin;->context:Landroid/content/Context;

    invoke-virtual {v0, p1}, Landroid/content/Context;->getDatabasePath(Ljava/lang/String;)Ljava/io/File;

    move-result-object p1

    .line 678
    invoke-virtual {p1}, Ljava/io/File;->getParent()Ljava/lang/String;

    move-result-object p1

    sput-object p1, Lcom/tekartik/sqflite/SqflitePlugin;->databasesPath:Ljava/lang/String;

    .line 680
    :cond_0
    sget-object p1, Lcom/tekartik/sqflite/SqflitePlugin;->databasesPath:Ljava/lang/String;

    invoke-interface {p2, p1}, Lio/flutter/plugin/common/MethodChannel$Result;->success(Ljava/lang/Object;)V

    return-void
.end method

.method public onMethodCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 3

    .line 578
    iget-object v0, p1, Lio/flutter/plugin/common/MethodCall;->method:Ljava/lang/String;

    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I

    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I

    move-result v1

    const/4 v2, -0x1

    sparse-switch v1, :sswitch_data_0

    goto/16 :goto_0

    :sswitch_0
    const-string v1, "getDatabasesPath"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_0

    goto/16 :goto_0

    :cond_0
    const/16 v2, 0xf

    goto/16 :goto_0

    :sswitch_1
    const-string v1, "getPlatformVersion"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_1

    goto/16 :goto_0

    :cond_1
    const/16 v2, 0xe

    goto/16 :goto_0

    :sswitch_2
    const-string v1, "queryCursorNext"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_2

    goto/16 :goto_0

    :cond_2
    const/16 v2, 0xd

    goto/16 :goto_0

    :sswitch_3
    const-string v1, "databaseExists"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_3

    goto/16 :goto_0

    :cond_3
    const/16 v2, 0xc

    goto/16 :goto_0

    :sswitch_4
    const-string v1, "query"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_4

    goto/16 :goto_0

    :cond_4
    const/16 v2, 0xb

    goto/16 :goto_0

    :sswitch_5
    const-string v1, "debug"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_5

    goto/16 :goto_0

    :cond_5
    const/16 v2, 0xa

    goto/16 :goto_0

    :sswitch_6
    const-string v1, "batch"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_6

    goto/16 :goto_0

    :cond_6
    const/16 v2, 0x9

    goto/16 :goto_0

    :sswitch_7
    const-string v1, "openDatabase"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_7

    goto/16 :goto_0

    :cond_7
    const/16 v2, 0x8

    goto/16 :goto_0

    :sswitch_8
    const-string v1, "debugMode"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_8

    goto :goto_0

    :cond_8
    const/4 v2, 0x7

    goto :goto_0

    :sswitch_9
    const-string v1, "deleteDatabase"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_9

    goto :goto_0

    :cond_9
    const/4 v2, 0x6

    goto :goto_0

    :sswitch_a
    const-string v1, "androidSetLocale"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_a

    goto :goto_0

    :cond_a
    const/4 v2, 0x5

    goto :goto_0

    :sswitch_b
    const-string v1, "update"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_b

    goto :goto_0

    :cond_b
    const/4 v2, 0x4

    goto :goto_0

    :sswitch_c
    const-string v1, "insert"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_c

    goto :goto_0

    :cond_c
    const/4 v2, 0x3

    goto :goto_0

    :sswitch_d
    const-string v1, "options"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_d

    goto :goto_0

    :cond_d
    const/4 v2, 0x2

    goto :goto_0

    :sswitch_e
    const-string v1, "closeDatabase"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_e

    goto :goto_0

    :cond_e
    const/4 v2, 0x1

    goto :goto_0

    :sswitch_f
    const-string v1, "execute"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_f

    goto :goto_0

    :cond_f
    const/4 v2, 0x0

    :goto_0
    packed-switch v2, :pswitch_data_0

    .line 646
    invoke-interface {p2}, Lio/flutter/plugin/common/MethodChannel$Result;->notImplemented()V

    return-void

    .line 617
    :pswitch_0
    invoke-virtual {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->onGetDatabasesPathCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    return-void

    .line 581
    :pswitch_1
    new-instance p1, Ljava/lang/StringBuilder;

    const-string v0, "Android "

    invoke-direct {p1, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    sget-object v0, Landroid/os/Build$VERSION;->RELEASE:Ljava/lang/String;

    invoke-virtual {p1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-interface {p2, p1}, Lio/flutter/plugin/common/MethodChannel$Result;->success(Ljava/lang/Object;)V

    return-void

    .line 629
    :pswitch_2
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->onQueryCursorNextCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    return-void

    .line 633
    :pswitch_3
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->onDatabaseExistsCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    return-void

    .line 589
    :pswitch_4
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->onQueryCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    return-void

    .line 625
    :pswitch_5
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->onDebugCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    return-void

    .line 609
    :pswitch_6
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->onBatchCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    return-void

    .line 605
    :pswitch_7
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->onOpenDatabaseCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    return-void

    .line 638
    :pswitch_8
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->onDebugModeCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    return-void

    .line 621
    :pswitch_9
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->onDeleteDatabaseCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    return-void

    .line 642
    :pswitch_a
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->onSetLocaleCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    return-void

    .line 597
    :pswitch_b
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->onUpdateCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    return-void

    .line 593
    :pswitch_c
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->onInsertCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    return-void

    .line 613
    :pswitch_d
    invoke-virtual {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->onOptionsCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    return-void

    .line 585
    :pswitch_e
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->onCloseDatabaseCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    return-void

    .line 601
    :pswitch_f
    invoke-direct {p0, p1, p2}, Lcom/tekartik/sqflite/SqflitePlugin;->onExecuteCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V

    return-void

    :sswitch_data_0
    .sparse-switch
        -0x4ea7088b -> :sswitch_f
        -0x4ab8246d -> :sswitch_e
        -0x4a797962 -> :sswitch_d
        -0x468f3d47 -> :sswitch_c
        -0x31ffc737 -> :sswitch_b
        -0x179ee453 -> :sswitch_a
        -0xfb4dfba -> :sswitch_9
        -0xbd41d6a -> :sswitch_8
        -0x1064e1b -> :sswitch_7
        0x592d73a -> :sswitch_6
        0x5b09653 -> :sswitch_5
        0x66f18c8 -> :sswitch_4
        0x3901a9b7 -> :sswitch_3
        0x47241251 -> :sswitch_2
        0x529446af -> :sswitch_1
        0x6f17c6e7 -> :sswitch_0
    .end sparse-switch

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_f
        :pswitch_e
        :pswitch_d
        :pswitch_c
        :pswitch_b
        :pswitch_a
        :pswitch_9
        :pswitch_8
        :pswitch_7
        :pswitch_6
        :pswitch_5
        :pswitch_4
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method onOptionsCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 3

    .line 652
    const-string v0, "androidThreadPriority"

    invoke-virtual {p1, v0}, Lio/flutter/plugin/common/MethodCall;->argument(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_0

    .line 654
    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    sput v0, Lcom/tekartik/sqflite/SqflitePlugin;->THREAD_PRIORITY:I

    .line 656
    :cond_0
    const-string v0, "androidThreadCount"

    invoke-virtual {p1, v0}, Lio/flutter/plugin/common/MethodCall;->argument(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    const/4 v1, 0x0

    if-eqz v0, :cond_1

    .line 657
    sget v2, Lcom/tekartik/sqflite/SqflitePlugin;->THREAD_COUNT:I

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v0, v2}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-nez v2, :cond_1

    .line 658
    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    sput v0, Lcom/tekartik/sqflite/SqflitePlugin;->THREAD_COUNT:I

    .line 660
    sget-object v0, Lcom/tekartik/sqflite/SqflitePlugin;->databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    if-eqz v0, :cond_1

    .line 661
    invoke-interface {v0}, Lcom/tekartik/sqflite/DatabaseWorkerPool;->quit()V

    .line 662
    sput-object v1, Lcom/tekartik/sqflite/SqflitePlugin;->databaseWorkerPool:Lcom/tekartik/sqflite/DatabaseWorkerPool;

    .line 665
    :cond_1
    invoke-static {p1}, Lcom/tekartik/sqflite/LogLevel;->getLogLevel(Lio/flutter/plugin/common/MethodCall;)Ljava/lang/Integer;

    move-result-object p1

    if-eqz p1, :cond_2

    .line 667
    invoke-virtual {p1}, Ljava/lang/Integer;->intValue()I

    move-result p1

    sput p1, Lcom/tekartik/sqflite/SqflitePlugin;->logLevel:I

    .line 669
    :cond_2
    invoke-interface {p2, v1}, Lio/flutter/plugin/common/MethodChannel$Result;->success(Ljava/lang/Object;)V

    return-void
.end method
