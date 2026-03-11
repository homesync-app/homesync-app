.class public final synthetic Lio/flutter/plugin/platform/PlatformViewsController2$$ExternalSyntheticLambda0;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Landroid/view/View$OnFocusChangeListener;


# instance fields
.field public final synthetic f$0:Lio/flutter/plugin/platform/PlatformViewsController2;

.field public final synthetic f$1:I


# direct methods
.method public synthetic constructor <init>(Lio/flutter/plugin/platform/PlatformViewsController2;I)V
    .locals 0

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lio/flutter/plugin/platform/PlatformViewsController2$$ExternalSyntheticLambda0;->f$0:Lio/flutter/plugin/platform/PlatformViewsController2;

    iput p2, p0, Lio/flutter/plugin/platform/PlatformViewsController2$$ExternalSyntheticLambda0;->f$1:I

    return-void
.end method


# virtual methods
.method public final onFocusChange(Landroid/view/View;Z)V
    .locals 2

    .line 0
    iget-object v0, p0, Lio/flutter/plugin/platform/PlatformViewsController2$$ExternalSyntheticLambda0;->f$0:Lio/flutter/plugin/platform/PlatformViewsController2;

    iget v1, p0, Lio/flutter/plugin/platform/PlatformViewsController2$$ExternalSyntheticLambda0;->f$1:I

    invoke-virtual {v0, v1, p1, p2}, Lio/flutter/plugin/platform/PlatformViewsController2;->lambda$initializePlatformViewIfNeeded$0$io-flutter-plugin-platform-PlatformViewsController2(ILandroid/view/View;Z)V

    return-void
.end method
