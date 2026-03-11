.class Lio/flutter/embedding/engine/image/ImageDecoderDefaultImpl;
.super Ljava/lang/Object;
.source "ImageDecoderDefaultImpl.java"

# interfaces
.implements Lio/flutter/embedding/engine/image/ImageDecoder;


# static fields
.field private static final TAG:Ljava/lang/String; = "FlutterImageDecoderImplDefault"


# instance fields
.field private final listener:Lio/flutter/embedding/engine/image/FlutterImageDecoder$HeaderListener;


# direct methods
.method public constructor <init>(Lio/flutter/embedding/engine/image/FlutterImageDecoder$HeaderListener;)V
    .locals 0

    .line 29
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 30
    iput-object p1, p0, Lio/flutter/embedding/engine/image/ImageDecoderDefaultImpl;->listener:Lio/flutter/embedding/engine/image/FlutterImageDecoder$HeaderListener;

    return-void
.end method


# virtual methods
.method public decodeImage(Ljava/nio/ByteBuffer;Lio/flutter/embedding/engine/image/Metadata;)Landroid/graphics/Bitmap;
    .locals 1

    .line 42
    invoke-static {p1}, Landroid/graphics/ImageDecoder;->createSource(Ljava/nio/ByteBuffer;)Landroid/graphics/ImageDecoder$Source;

    move-result-object p1

    .line 44
    :try_start_0
    new-instance p2, Lio/flutter/embedding/engine/image/ImageDecoderDefaultImpl$$ExternalSyntheticLambda0;

    invoke-direct {p2, p0}, Lio/flutter/embedding/engine/image/ImageDecoderDefaultImpl$$ExternalSyntheticLambda0;-><init>(Lio/flutter/embedding/engine/image/ImageDecoderDefaultImpl;)V

    invoke-static {p1, p2}, Landroid/graphics/ImageDecoder;->decodeBitmap(Landroid/graphics/ImageDecoder$Source;Landroid/graphics/ImageDecoder$OnHeaderDecodedListener;)Landroid/graphics/Bitmap;

    move-result-object p1
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    return-object p1

    :catch_0
    move-exception p1

    .line 61
    const-string p2, "FlutterImageDecoderImplDefault"

    const-string v0, "Failed to decode image"

    invoke-static {p2, v0, p1}, Lio/flutter/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    const/4 p1, 0x0

    return-object p1
.end method

.method synthetic lambda$decodeImage$0$io-flutter-embedding-engine-image-ImageDecoderDefaultImpl(Landroid/graphics/ImageDecoder;Landroid/graphics/ImageDecoder$ImageInfo;Landroid/graphics/ImageDecoder$Source;)V
    .locals 0

    .line 48
    sget-object p3, Landroid/graphics/ColorSpace$Named;->SRGB:Landroid/graphics/ColorSpace$Named;

    invoke-static {p3}, Landroid/graphics/ColorSpace;->get(Landroid/graphics/ColorSpace$Named;)Landroid/graphics/ColorSpace;

    move-result-object p3

    invoke-virtual {p1, p3}, Landroid/graphics/ImageDecoder;->setTargetColorSpace(Landroid/graphics/ColorSpace;)V

    const/4 p3, 0x1

    .line 53
    invoke-virtual {p1, p3}, Landroid/graphics/ImageDecoder;->setAllocator(I)V

    .line 55
    iget-object p1, p0, Lio/flutter/embedding/engine/image/ImageDecoderDefaultImpl;->listener:Lio/flutter/embedding/engine/image/FlutterImageDecoder$HeaderListener;

    if-eqz p1, :cond_0

    .line 56
    invoke-virtual {p2}, Landroid/graphics/ImageDecoder$ImageInfo;->getSize()Landroid/util/Size;

    move-result-object p1

    .line 57
    iget-object p2, p0, Lio/flutter/embedding/engine/image/ImageDecoderDefaultImpl;->listener:Lio/flutter/embedding/engine/image/FlutterImageDecoder$HeaderListener;

    invoke-virtual {p1}, Landroid/util/Size;->getWidth()I

    move-result p3

    invoke-virtual {p1}, Landroid/util/Size;->getHeight()I

    move-result p1

    invoke-interface {p2, p3, p1}, Lio/flutter/embedding/engine/image/FlutterImageDecoder$HeaderListener;->onImageHeader(II)V

    :cond_0
    return-void
.end method
