.class public Lio/flutter/plugins/firebase/crashlytics/FirebaseCrashlyticsTestCrash;
.super Ljava/lang/RuntimeException;
.source "FirebaseCrashlyticsTestCrash.java"


# direct methods
.method constructor <init>()V
    .locals 1

    .line 18
    const-string v0, "This is a test crash caused by calling .crash() in Dart."

    invoke-direct {p0, v0}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    return-void
.end method
