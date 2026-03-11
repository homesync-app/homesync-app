.class public Lcom/llfbandit/app_links/AppLinksPlugin;
.super Ljava/lang/Object;
.source "AppLinksPlugin.java"

# interfaces
.implements Lio/flutter/embedding/engine/plugins/FlutterPlugin;
.implements Lio/flutter/plugin/common/MethodChannel$MethodCallHandler;
.implements Lio/flutter/plugin/common/EventChannel$StreamHandler;
.implements Lio/flutter/embedding/engine/plugins/activity/ActivityAware;
.implements Lio/flutter/plugin/common/PluginRegistry$NewIntentListener;


# static fields
.field private static final EVENTS_CHANNEL:Ljava/lang/String; = "com.llfbandit.app_links/events"

.field private static final MESSAGES_CHANNEL:Ljava/lang/String; = "com.llfbandit.app_links/messages"

.field private static final TAG:Ljava/lang/String; = "com.llfbandit.app_links"


# instance fields
.field binding:Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;

.field private eventChannel:Lio/flutter/plugin/common/EventChannel;

.field private eventSink:Lio/flutter/plugin/common/EventChannel$EventSink;

.field private initialLink:Ljava/lang/String;

.field private initialLinkSent:Z

.field private latestLink:Ljava/lang/String;

.field private methodChannel:Lio/flutter/plugin/common/MethodChannel;


# direct methods
.method public constructor <init>()V
    .locals 1

    .line 21
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const/4 v0, 0x0

    .line 49
    iput-boolean v0, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->initialLinkSent:Z

    return-void
.end method

.method private handleIntent(Landroid/content/Intent;)Z
    .locals 3

    const/4 v0, 0x0

    if-nez p1, :cond_0

    return v0

    .line 164
    :cond_0
    const-string v1, "com.llfbandit.app_links"

    invoke-virtual {p1}, Landroid/content/Intent;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v1, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 167
    invoke-virtual {p1}, Landroid/content/Intent;->getFlags()I

    move-result v1

    const/high16 v2, 0x100000

    and-int/2addr v1, v2

    if-ne v1, v2, :cond_1

    return v0

    .line 171
    :cond_1
    invoke-static {p1}, Lcom/llfbandit/app_links/AppLinksHelper;->getUrl(Landroid/content/Intent;)Ljava/lang/String;

    move-result-object p1

    if-nez p1, :cond_2

    return v0

    .line 174
    :cond_2
    iget-object v0, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->initialLink:Ljava/lang/String;

    if-nez v0, :cond_3

    .line 175
    iput-object p1, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->initialLink:Ljava/lang/String;

    .line 178
    :cond_3
    iput-object p1, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->latestLink:Ljava/lang/String;

    .line 180
    iget-object v0, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->eventSink:Lio/flutter/plugin/common/EventChannel$EventSink;

    const/4 v1, 0x1

    if-eqz v0, :cond_4

    .line 181
    iput-boolean v1, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->initialLinkSent:Z

    .line 182
    invoke-interface {v0, p1}, Lio/flutter/plugin/common/EventChannel$EventSink;->success(Ljava/lang/Object;)V

    :cond_4
    return v1
.end method


# virtual methods
.method public onAttachedToActivity(Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;)V
    .locals 0

    .line 97
    iput-object p1, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->binding:Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;

    .line 98
    invoke-interface {p1, p0}, Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;->addOnNewIntentListener(Lio/flutter/plugin/common/PluginRegistry$NewIntentListener;)V

    .line 101
    invoke-interface {p1}, Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;->getActivity()Landroid/app/Activity;

    move-result-object p1

    invoke-virtual {p1}, Landroid/app/Activity;->getIntent()Landroid/content/Intent;

    move-result-object p1

    invoke-direct {p0, p1}, Lcom/llfbandit/app_links/AppLinksPlugin;->handleIntent(Landroid/content/Intent;)Z

    return-void
.end method

.method public onAttachedToEngine(Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;)V
    .locals 3

    .line 59
    new-instance v0, Lio/flutter/plugin/common/MethodChannel;

    invoke-virtual {p1}, Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;->getBinaryMessenger()Lio/flutter/plugin/common/BinaryMessenger;

    move-result-object v1

    const-string v2, "com.llfbandit.app_links/messages"

    invoke-direct {v0, v1, v2}, Lio/flutter/plugin/common/MethodChannel;-><init>(Lio/flutter/plugin/common/BinaryMessenger;Ljava/lang/String;)V

    iput-object v0, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->methodChannel:Lio/flutter/plugin/common/MethodChannel;

    .line 60
    invoke-virtual {v0, p0}, Lio/flutter/plugin/common/MethodChannel;->setMethodCallHandler(Lio/flutter/plugin/common/MethodChannel$MethodCallHandler;)V

    .line 62
    new-instance v0, Lio/flutter/plugin/common/EventChannel;

    invoke-virtual {p1}, Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;->getBinaryMessenger()Lio/flutter/plugin/common/BinaryMessenger;

    move-result-object p1

    const-string v1, "com.llfbandit.app_links/events"

    invoke-direct {v0, p1, v1}, Lio/flutter/plugin/common/EventChannel;-><init>(Lio/flutter/plugin/common/BinaryMessenger;Ljava/lang/String;)V

    iput-object v0, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->eventChannel:Lio/flutter/plugin/common/EventChannel;

    .line 63
    invoke-virtual {v0, p0}, Lio/flutter/plugin/common/EventChannel;->setStreamHandler(Lio/flutter/plugin/common/EventChannel$StreamHandler;)V

    return-void
.end method

.method public onCancel(Ljava/lang/Object;)V
    .locals 0

    const/4 p1, 0x0

    .line 141
    iput-object p1, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->eventSink:Lio/flutter/plugin/common/EventChannel$EventSink;

    return-void
.end method

.method public onDetachedFromActivity()V
    .locals 1

    .line 112
    iget-object v0, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->binding:Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;

    if-eqz v0, :cond_0

    .line 113
    invoke-interface {v0, p0}, Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;->removeOnNewIntentListener(Lio/flutter/plugin/common/PluginRegistry$NewIntentListener;)V

    :cond_0
    const/4 v0, 0x0

    .line 115
    iput-object v0, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->binding:Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;

    return-void
.end method

.method public onDetachedFromActivityForConfigChanges()V
    .locals 0

    .line 120
    invoke-virtual {p0}, Lcom/llfbandit/app_links/AppLinksPlugin;->onDetachedFromActivity()V

    return-void
.end method

.method public onDetachedFromEngine(Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;)V
    .locals 1

    .line 68
    iget-object p1, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->methodChannel:Lio/flutter/plugin/common/MethodChannel;

    const/4 v0, 0x0

    invoke-virtual {p1, v0}, Lio/flutter/plugin/common/MethodChannel;->setMethodCallHandler(Lio/flutter/plugin/common/MethodChannel$MethodCallHandler;)V

    .line 69
    iget-object p1, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->eventChannel:Lio/flutter/plugin/common/EventChannel;

    invoke-virtual {p1, v0}, Lio/flutter/plugin/common/EventChannel;->setStreamHandler(Lio/flutter/plugin/common/EventChannel$StreamHandler;)V

    return-void
.end method

.method public onListen(Ljava/lang/Object;Lio/flutter/plugin/common/EventChannel$EventSink;)V
    .locals 1

    .line 131
    iput-object p2, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->eventSink:Lio/flutter/plugin/common/EventChannel$EventSink;

    .line 133
    iget-boolean p1, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->initialLinkSent:Z

    if-nez p1, :cond_0

    iget-object p1, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->initialLink:Ljava/lang/String;

    if-eqz p1, :cond_0

    const/4 v0, 0x1

    .line 134
    iput-boolean v0, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->initialLinkSent:Z

    .line 135
    invoke-interface {p2, p1}, Lio/flutter/plugin/common/EventChannel$EventSink;->success(Ljava/lang/Object;)V

    :cond_0
    return-void
.end method

.method public onMethodCall(Lio/flutter/plugin/common/MethodCall;Lio/flutter/plugin/common/MethodChannel$Result;)V
    .locals 2

    .line 80
    iget-object v0, p1, Lio/flutter/plugin/common/MethodCall;->method:Ljava/lang/String;

    const-string v1, "getLatestLink"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    .line 81
    iget-object p1, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->latestLink:Ljava/lang/String;

    invoke-interface {p2, p1}, Lio/flutter/plugin/common/MethodChannel$Result;->success(Ljava/lang/Object;)V

    return-void

    .line 82
    :cond_0
    iget-object p1, p1, Lio/flutter/plugin/common/MethodCall;->method:Ljava/lang/String;

    const-string v0, "getInitialLink"

    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_1

    .line 83
    iget-object p1, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->initialLink:Ljava/lang/String;

    invoke-interface {p2, p1}, Lio/flutter/plugin/common/MethodChannel$Result;->success(Ljava/lang/Object;)V

    return-void

    .line 85
    :cond_1
    invoke-interface {p2}, Lio/flutter/plugin/common/MethodChannel$Result;->notImplemented()V

    return-void
.end method

.method public onNewIntent(Landroid/content/Intent;)Z
    .locals 0

    .line 152
    invoke-direct {p0, p1}, Lcom/llfbandit/app_links/AppLinksPlugin;->handleIntent(Landroid/content/Intent;)Z

    move-result p1

    return p1
.end method

.method public onReattachedToActivityForConfigChanges(Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;)V
    .locals 0

    .line 106
    iput-object p1, p0, Lcom/llfbandit/app_links/AppLinksPlugin;->binding:Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;

    .line 107
    invoke-interface {p1, p0}, Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;->addOnNewIntentListener(Lio/flutter/plugin/common/PluginRegistry$NewIntentListener;)V

    return-void
.end method
