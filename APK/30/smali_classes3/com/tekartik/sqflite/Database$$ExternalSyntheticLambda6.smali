.class public final synthetic Lcom/tekartik/sqflite/Database$$ExternalSyntheticLambda6;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Landroid/database/sqlite/SQLiteDatabase$CursorFactory;


# instance fields
.field public final synthetic f$0:Lcom/tekartik/sqflite/SqlCommand;


# direct methods
.method public synthetic constructor <init>(Lcom/tekartik/sqflite/SqlCommand;)V
    .locals 0

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/tekartik/sqflite/Database$$ExternalSyntheticLambda6;->f$0:Lcom/tekartik/sqflite/SqlCommand;

    return-void
.end method


# virtual methods
.method public final newCursor(Landroid/database/sqlite/SQLiteDatabase;Landroid/database/sqlite/SQLiteCursorDriver;Ljava/lang/String;Landroid/database/sqlite/SQLiteQuery;)Landroid/database/Cursor;
    .locals 1

    .line 0
    iget-object v0, p0, Lcom/tekartik/sqflite/Database$$ExternalSyntheticLambda6;->f$0:Lcom/tekartik/sqflite/SqlCommand;

    invoke-static {v0, p1, p2, p3, p4}, Lcom/tekartik/sqflite/Database;->lambda$doQuery$1(Lcom/tekartik/sqflite/SqlCommand;Landroid/database/sqlite/SQLiteDatabase;Landroid/database/sqlite/SQLiteCursorDriver;Ljava/lang/String;Landroid/database/sqlite/SQLiteQuery;)Landroid/database/Cursor;

    move-result-object p1

    return-object p1
.end method
