.class public Lio/flutter/plugins/firebase/auth/IdTokenChannelStreamHandler;
.super Ljava/lang/Object;
.source "IdTokenChannelStreamHandler.java"

# interfaces
.implements Lio/flutter/plugin/common/EventChannel$StreamHandler;


# instance fields
.field private final firebaseAuth:Lcom/google/firebase/auth/FirebaseAuth;

.field private idTokenListener:Lcom/google/firebase/auth/FirebaseAuth$IdTokenListener;


# direct methods
.method public constructor <init>(Lcom/google/firebase/auth/FirebaseAuth;)V
    .locals 0

    .line 23
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 24
    iput-object p1, p0, Lio/flutter/plugins/firebase/auth/IdTokenChannelStreamHandler;->firebaseAuth:Lcom/google/firebase/auth/FirebaseAuth;

    return-void
.end method

.method static synthetic lambda$onListen$0(Ljava/util/concurrent/atomic/AtomicBoolean;Ljava/util/Map;Lio/flutter/plugin/common/EventChannel$EventSink;Lcom/google/firebase/auth/FirebaseAuth;)V
    .locals 1

    .line 36
    invoke-virtual {p0}, Ljava/util/concurrent/atomic/AtomicBoolean;->get()Z

    move-result v0

    if-eqz v0, :cond_0

    const/4 p1, 0x0

    .line 37
    invoke-virtual {p0, p1}, Ljava/util/concurrent/atomic/AtomicBoolean;->set(Z)V

    return-void

    .line 41
    :cond_0
    invoke-virtual {p3}, Lcom/google/firebase/auth/FirebaseAuth;->getCurrentUser()Lcom/google/firebase/auth/FirebaseUser;

    move-result-object p0

    .line 43
    const-string p3, "user"

    if-nez p0, :cond_1

    const/4 p0, 0x0

    .line 44
    invoke-interface {p1, p3, p0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    goto :goto_0

    .line 47
    :cond_1
    invoke-static {p0}, Lio/flutter/plugins/firebase/auth/PigeonParser;->parseFirebaseUser(Lcom/google/firebase/auth/FirebaseUser;)Lio/flutter/plugins/firebase/auth/GeneratedAndroidFirebaseAuth$PigeonUserDetails;

    move-result-object p0

    invoke-static {p0}, Lio/flutter/plugins/firebase/auth/PigeonParser;->manuallyToList(Lio/flutter/plugins/firebase/auth/GeneratedAndroidFirebaseAuth$PigeonUserDetails;)Ljava/util/List;

    move-result-object p0

    .line 46
    invoke-interface {p1, p3, p0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 50
    :goto_0
    invoke-interface {p2, p1}, Lio/flutter/plugin/common/EventChannel$EventSink;->success(Ljava/lang/Object;)V

    return-void
.end method


# virtual methods
.method public onCancel(Ljava/lang/Object;)V
    .locals 1

    .line 58
    iget-object p1, p0, Lio/flutter/plugins/firebase/auth/IdTokenChannelStreamHandler;->idTokenListener:Lcom/google/firebase/auth/FirebaseAuth$IdTokenListener;

    if-eqz p1, :cond_0

    .line 59
    iget-object v0, p0, Lio/flutter/plugins/firebase/auth/IdTokenChannelStreamHandler;->firebaseAuth:Lcom/google/firebase/auth/FirebaseAuth;

    invoke-virtual {v0, p1}, Lcom/google/firebase/auth/FirebaseAuth;->removeIdTokenListener(Lcom/google/firebase/auth/FirebaseAuth$IdTokenListener;)V

    const/4 p1, 0x0

    .line 60
    iput-object p1, p0, Lio/flutter/plugins/firebase/auth/IdTokenChannelStreamHandler;->idTokenListener:Lcom/google/firebase/auth/FirebaseAuth$IdTokenListener;

    :cond_0
    return-void
.end method

.method public onListen(Ljava/lang/Object;Lio/flutter/plugin/common/EventChannel$EventSink;)V
    .locals 2

    .line 29
    new-instance p1, Ljava/util/HashMap;

    invoke-direct {p1}, Ljava/util/HashMap;-><init>()V

    .line 30
    iget-object v0, p0, Lio/flutter/plugins/firebase/auth/IdTokenChannelStreamHandler;->firebaseAuth:Lcom/google/firebase/auth/FirebaseAuth;

    invoke-virtual {v0}, Lcom/google/firebase/auth/FirebaseAuth;->getApp()Lcom/google/firebase/FirebaseApp;

    move-result-object v0

    invoke-virtual {v0}, Lcom/google/firebase/FirebaseApp;->getName()Ljava/lang/String;

    move-result-object v0

    const-string v1, "appName"

    invoke-interface {p1, v1, v0}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 32
    new-instance v0, Ljava/util/concurrent/atomic/AtomicBoolean;

    const/4 v1, 0x1

    invoke-direct {v0, v1}, Ljava/util/concurrent/atomic/AtomicBoolean;-><init>(Z)V

    .line 34
    new-instance v1, Lio/flutter/plugins/firebase/auth/IdTokenChannelStreamHandler$$ExternalSyntheticLambda0;

    invoke-direct {v1, v0, p1, p2}, Lio/flutter/plugins/firebase/auth/IdTokenChannelStreamHandler$$ExternalSyntheticLambda0;-><init>(Ljava/util/concurrent/atomic/AtomicBoolean;Ljava/util/Map;Lio/flutter/plugin/common/EventChannel$EventSink;)V

    iput-object v1, p0, Lio/flutter/plugins/firebase/auth/IdTokenChannelStreamHandler;->idTokenListener:Lcom/google/firebase/auth/FirebaseAuth$IdTokenListener;

    .line 53
    iget-object p1, p0, Lio/flutter/plugins/firebase/auth/IdTokenChannelStreamHandler;->firebaseAuth:Lcom/google/firebase/auth/FirebaseAuth;

    invoke-virtual {p1, v1}, Lcom/google/firebase/auth/FirebaseAuth;->addIdTokenListener(Lcom/google/firebase/auth/FirebaseAuth$IdTokenListener;)V

    return-void
.end method
