.class public interface abstract Lio/flutter/view/TextureRegistry$SurfaceProducer$Callback;
.super Ljava/lang/Object;
.source "TextureRegistry.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/view/TextureRegistry$SurfaceProducer;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x609
    name = "Callback"
.end annotation


# virtual methods
.method public onSurfaceAvailable()V
    .locals 0

    .line 204
    invoke-interface {p0}, Lio/flutter/view/TextureRegistry$SurfaceProducer$Callback;->onSurfaceCreated()V

    return-void
.end method

.method public onSurfaceCleanup()V
    .locals 0

    .line 245
    invoke-interface {p0}, Lio/flutter/view/TextureRegistry$SurfaceProducer$Callback;->onSurfaceDestroyed()V

    return-void
.end method

.method public onSurfaceCreated()V
    .locals 0
    .annotation runtime Ljava/lang/Deprecated;
        forRemoval = true
        since = "Flutter 3.27"
    .end annotation

    return-void
.end method

.method public onSurfaceDestroyed()V
    .locals 0
    .annotation runtime Ljava/lang/Deprecated;
        forRemoval = true
        since = "Flutter 3.28"
    .end annotation

    return-void
.end method
