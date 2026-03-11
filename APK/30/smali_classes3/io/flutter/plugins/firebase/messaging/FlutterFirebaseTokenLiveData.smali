.class public Lio/flutter/plugins/firebase/messaging/FlutterFirebaseTokenLiveData;
.super Landroidx/lifecycle/LiveData;
.source "FlutterFirebaseTokenLiveData.java"


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "Landroidx/lifecycle/LiveData<",
        "Ljava/lang/String;",
        ">;"
    }
.end annotation


# static fields
.field private static instance:Lio/flutter/plugins/firebase/messaging/FlutterFirebaseTokenLiveData;


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 9
    invoke-direct {p0}, Landroidx/lifecycle/LiveData;-><init>()V

    return-void
.end method

.method public static getInstance()Lio/flutter/plugins/firebase/messaging/FlutterFirebaseTokenLiveData;
    .locals 1

    .line 13
    sget-object v0, Lio/flutter/plugins/firebase/messaging/FlutterFirebaseTokenLiveData;->instance:Lio/flutter/plugins/firebase/messaging/FlutterFirebaseTokenLiveData;

    if-nez v0, :cond_0

    .line 14
    new-instance v0, Lio/flutter/plugins/firebase/messaging/FlutterFirebaseTokenLiveData;

    invoke-direct {v0}, Lio/flutter/plugins/firebase/messaging/FlutterFirebaseTokenLiveData;-><init>()V

    sput-object v0, Lio/flutter/plugins/firebase/messaging/FlutterFirebaseTokenLiveData;->instance:Lio/flutter/plugins/firebase/messaging/FlutterFirebaseTokenLiveData;

    .line 16
    :cond_0
    sget-object v0, Lio/flutter/plugins/firebase/messaging/FlutterFirebaseTokenLiveData;->instance:Lio/flutter/plugins/firebase/messaging/FlutterFirebaseTokenLiveData;

    return-object v0
.end method


# virtual methods
.method public postToken(Ljava/lang/String;)V
    .locals 0

    .line 20
    invoke-virtual {p0, p1}, Lio/flutter/plugins/firebase/messaging/FlutterFirebaseTokenLiveData;->postValue(Ljava/lang/Object;)V

    return-void
.end method
