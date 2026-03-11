.class public final synthetic Lio/flutter/embedding/engine/FlutterJNI$$ExternalSyntheticLambda1;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Lio/flutter/embedding/engine/image/FlutterImageDecoder$HeaderListener;


# instance fields
.field public final synthetic f$0:J


# direct methods
.method public synthetic constructor <init>(J)V
    .locals 0

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-wide p1, p0, Lio/flutter/embedding/engine/FlutterJNI$$ExternalSyntheticLambda1;->f$0:J

    return-void
.end method


# virtual methods
.method public final onImageHeader(II)V
    .locals 2

    .line 0
    iget-wide v0, p0, Lio/flutter/embedding/engine/FlutterJNI$$ExternalSyntheticLambda1;->f$0:J

    invoke-static {v0, v1, p1, p2}, Lio/flutter/embedding/engine/FlutterJNI;->lambda$decodeImage$1(JII)V

    return-void
.end method
