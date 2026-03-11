.class Lio/flutter/embedding/engine/image/ImageDecoderHeifPre36Impl;
.super Lio/flutter/embedding/engine/image/ImageDecoderDefaultImpl;
.source "ImageDecoderHeifPre36Impl.java"


# static fields
.field private static final TAG:Ljava/lang/String; = "FlutterImageDecoderImplHeifPre36"


# direct methods
.method public constructor <init>()V
    .locals 1

    const/4 v0, 0x0

    .line 24
    invoke-direct {p0, v0}, Lio/flutter/embedding/engine/image/ImageDecoderDefaultImpl;-><init>(Lio/flutter/embedding/engine/image/FlutterImageDecoder$HeaderListener;)V

    return-void
.end method


# virtual methods
.method public decodeImage(Ljava/nio/ByteBuffer;Lio/flutter/embedding/engine/image/Metadata;)Landroid/graphics/Bitmap;
    .locals 0

    .line 36
    invoke-super {p0, p1, p2}, Lio/flutter/embedding/engine/image/ImageDecoderDefaultImpl;->decodeImage(Ljava/nio/ByteBuffer;Lio/flutter/embedding/engine/image/Metadata;)Landroid/graphics/Bitmap;

    move-result-object p1

    iget p2, p2, Lio/flutter/embedding/engine/image/Metadata;->orientation:I

    invoke-static {p1, p2}, Lio/flutter/embedding/engine/image/ImageUtils;->applyFlipIfNeeded(Landroid/graphics/Bitmap;I)Landroid/graphics/Bitmap;

    move-result-object p1

    return-object p1
.end method
