.class public final synthetic Lcom/tekartik/sqflite/Database$$ExternalSyntheticLambda5;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic f$0:Lcom/tekartik/sqflite/Database;

.field public final synthetic f$1:Lcom/tekartik/sqflite/operation/Operation;


# direct methods
.method public synthetic constructor <init>(Lcom/tekartik/sqflite/Database;Lcom/tekartik/sqflite/operation/Operation;)V
    .locals 0

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/tekartik/sqflite/Database$$ExternalSyntheticLambda5;->f$0:Lcom/tekartik/sqflite/Database;

    iput-object p2, p0, Lcom/tekartik/sqflite/Database$$ExternalSyntheticLambda5;->f$1:Lcom/tekartik/sqflite/operation/Operation;

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 2

    .line 0
    iget-object v0, p0, Lcom/tekartik/sqflite/Database$$ExternalSyntheticLambda5;->f$0:Lcom/tekartik/sqflite/Database;

    iget-object v1, p0, Lcom/tekartik/sqflite/Database$$ExternalSyntheticLambda5;->f$1:Lcom/tekartik/sqflite/operation/Operation;

    invoke-static {v0, v1}, Lcom/tekartik/sqflite/Database;->$r8$lambda$p3jrsswxQjU6mRSinYgSYNzOLB4(Lcom/tekartik/sqflite/Database;Lcom/tekartik/sqflite/operation/Operation;)V

    return-void
.end method
