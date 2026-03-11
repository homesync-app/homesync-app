.class public Lio/flutter/embedding/engine/image/BitmapMetadataReader;
.super Ljava/lang/Object;
.source "BitmapMetadataReader.java"


# static fields
.field private static final TAG:Ljava/lang/String; = "BitmapMetadataReader"


# direct methods
.method public constructor <init>()V
    .locals 0

    .line 14
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static read([BLio/flutter/embedding/engine/image/Metadata;)V
    .locals 3

    .line 26
    :try_start_0
    new-instance v0, Landroid/graphics/BitmapFactory$Options;

    invoke-direct {v0}, Landroid/graphics/BitmapFactory$Options;-><init>()V

    const/4 v1, 0x1

    .line 27
    iput-boolean v1, v0, Landroid/graphics/BitmapFactory$Options;->inJustDecodeBounds:Z

    .line 28
    array-length v1, p0

    const/4 v2, 0x0

    invoke-static {p0, v2, v1, v0}, Landroid/graphics/BitmapFactory;->decodeByteArray([BIILandroid/graphics/BitmapFactory$Options;)Landroid/graphics/Bitmap;

    .line 29
    iget-object p0, v0, Landroid/graphics/BitmapFactory$Options;->outMimeType:Ljava/lang/String;

    iput-object p0, p1, Lio/flutter/embedding/engine/image/Metadata;->mimeType:Ljava/lang/String;

    .line 31
    iget p0, v0, Landroid/graphics/BitmapFactory$Options;->outHeight:I

    iput p0, p1, Lio/flutter/embedding/engine/image/Metadata;->originalHeight:I

    .line 32
    iget p0, v0, Landroid/graphics/BitmapFactory$Options;->outWidth:I

    iput p0, p1, Lio/flutter/embedding/engine/image/Metadata;->originalWidth:I
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception p0

    .line 34
    const-string p1, "BitmapMetadataReader"

    const-string v0, "Failed to decode image for mime type"

    invoke-static {p1, v0, p0}, Lio/flutter/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    return-void
.end method
