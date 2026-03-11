.class public final synthetic Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl$$ExternalSyntheticLambda0;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic f$0:Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;

.field public final synthetic f$1:Lcom/tekartik/sqflite/DatabaseWorker;


# direct methods
.method public synthetic constructor <init>(Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;Lcom/tekartik/sqflite/DatabaseWorker;)V
    .locals 0

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl$$ExternalSyntheticLambda0;->f$0:Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;

    iput-object p2, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl$$ExternalSyntheticLambda0;->f$1:Lcom/tekartik/sqflite/DatabaseWorker;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 2

    .line 0
    iget-object v0, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl$$ExternalSyntheticLambda0;->f$0:Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;

    iget-object v1, p0, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl$$ExternalSyntheticLambda0;->f$1:Lcom/tekartik/sqflite/DatabaseWorker;

    invoke-static {v0, v1}, Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;->$r8$lambda$GQRlkfjH3zEaAzlz-QqIPX7EVYU(Lcom/tekartik/sqflite/DatabaseWorkerPoolImpl;Lcom/tekartik/sqflite/DatabaseWorker;)V

    return-void
.end method
