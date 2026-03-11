.class public final Lio/flutter/plugins/urllauncher/Messages$WebViewOptions$Builder;
.super Ljava/lang/Object;
.source "Messages.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/urllauncher/Messages$WebViewOptions;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "Builder"
.end annotation


# instance fields
.field private enableDomStorage:Ljava/lang/Boolean;

.field private enableJavaScript:Ljava/lang/Boolean;

.field private headers:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 135
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public build()Lio/flutter/plugins/urllauncher/Messages$WebViewOptions;
    .locals 2

    .line 162
    new-instance v0, Lio/flutter/plugins/urllauncher/Messages$WebViewOptions;

    invoke-direct {v0}, Lio/flutter/plugins/urllauncher/Messages$WebViewOptions;-><init>()V

    .line 163
    iget-object v1, p0, Lio/flutter/plugins/urllauncher/Messages$WebViewOptions$Builder;->enableJavaScript:Ljava/lang/Boolean;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/urllauncher/Messages$WebViewOptions;->setEnableJavaScript(Ljava/lang/Boolean;)V

    .line 164
    iget-object v1, p0, Lio/flutter/plugins/urllauncher/Messages$WebViewOptions$Builder;->enableDomStorage:Ljava/lang/Boolean;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/urllauncher/Messages$WebViewOptions;->setEnableDomStorage(Ljava/lang/Boolean;)V

    .line 165
    iget-object v1, p0, Lio/flutter/plugins/urllauncher/Messages$WebViewOptions$Builder;->headers:Ljava/util/Map;

    invoke-virtual {v0, v1}, Lio/flutter/plugins/urllauncher/Messages$WebViewOptions;->setHeaders(Ljava/util/Map;)V

    return-object v0
.end method

.method public setEnableDomStorage(Ljava/lang/Boolean;)Lio/flutter/plugins/urllauncher/Messages$WebViewOptions$Builder;
    .locals 0

    .line 149
    iput-object p1, p0, Lio/flutter/plugins/urllauncher/Messages$WebViewOptions$Builder;->enableDomStorage:Ljava/lang/Boolean;

    return-object p0
.end method

.method public setEnableJavaScript(Ljava/lang/Boolean;)Lio/flutter/plugins/urllauncher/Messages$WebViewOptions$Builder;
    .locals 0

    .line 141
    iput-object p1, p0, Lio/flutter/plugins/urllauncher/Messages$WebViewOptions$Builder;->enableJavaScript:Ljava/lang/Boolean;

    return-object p0
.end method

.method public setHeaders(Ljava/util/Map;)Lio/flutter/plugins/urllauncher/Messages$WebViewOptions$Builder;
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;)",
            "Lio/flutter/plugins/urllauncher/Messages$WebViewOptions$Builder;"
        }
    .end annotation

    .line 157
    iput-object p1, p0, Lio/flutter/plugins/urllauncher/Messages$WebViewOptions$Builder;->headers:Ljava/util/Map;

    return-object p0
.end method
