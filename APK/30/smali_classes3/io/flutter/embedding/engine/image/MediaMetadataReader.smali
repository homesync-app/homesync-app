.class Lio/flutter/embedding/engine/image/MediaMetadataReader;
.super Ljava/lang/Object;
.source "MediaMetadataReader.java"


# static fields
.field private static final TAG:Ljava/lang/String; = "MediaMetadataReader"


# direct methods
.method constructor <init>()V
    .locals 0

    .line 18
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private static getMediaExtractor([B)Landroid/media/MediaExtractor;
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 24
    new-instance v0, Lio/flutter/embedding/engine/image/MediaMetadataReader$1;

    invoke-direct {v0, p0}, Lio/flutter/embedding/engine/image/MediaMetadataReader$1;-><init>([B)V

    .line 48
    new-instance p0, Landroid/media/MediaExtractor;

    invoke-direct {p0}, Landroid/media/MediaExtractor;-><init>()V

    .line 49
    invoke-virtual {p0, v0}, Landroid/media/MediaExtractor;->setDataSource(Landroid/media/MediaDataSource;)V

    return-object p0
.end method

.method static read([BLio/flutter/embedding/engine/image/Metadata;)V
    .locals 1

    .line 62
    :try_start_0
    invoke-static {p0}, Lio/flutter/embedding/engine/image/MediaMetadataReader;->getMediaExtractor([B)Landroid/media/MediaExtractor;

    move-result-object v0

    .line 63
    invoke-static {p0, p1, v0}, Lio/flutter/embedding/engine/image/MediaMetadataReader;->read([BLio/flutter/embedding/engine/image/Metadata;Landroid/media/MediaExtractor;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception p0

    .line 65
    const-string p1, "MediaMetadataReader"

    const-string v0, "Failed to decode HEIF image using MediaExtractor"

    invoke-static {p1, v0, p0}, Lio/flutter/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    return-void
.end method

.method static read([BLio/flutter/embedding/engine/image/Metadata;Landroid/media/MediaExtractor;)V
    .locals 6

    .line 71
    const-string p0, "rotation-degrees"

    .line 73
    :try_start_0
    invoke-virtual {p2}, Landroid/media/MediaExtractor;->getTrackCount()I

    move-result v0

    const/4 v1, 0x0

    move v2, v1

    :goto_0
    if-ge v2, v0, :cond_4

    .line 75
    invoke-virtual {p2, v2}, Landroid/media/MediaExtractor;->getTrackFormat(I)Landroid/media/MediaFormat;

    move-result-object v3

    .line 77
    const-string v4, "mime"

    invoke-virtual {v3, v4}, Landroid/media/MediaFormat;->getString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v4

    if-eqz v4, :cond_3

    .line 78
    const-string v5, "image/"

    invoke-virtual {v4, v5}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v4

    if-eqz v4, :cond_3

    .line 79
    invoke-virtual {v3, p0}, Landroid/media/MediaFormat;->containsKey(Ljava/lang/String;)Z

    move-result p2

    if-eqz p2, :cond_0

    .line 80
    invoke-virtual {v3, p0}, Landroid/media/MediaFormat;->getInteger(Ljava/lang/String;)I

    move-result v1

    .line 83
    :cond_0
    iget p0, p1, Lio/flutter/embedding/engine/image/Metadata;->originalWidth:I

    .line 84
    iget p2, p1, Lio/flutter/embedding/engine/image/Metadata;->originalHeight:I

    const/16 v0, 0x5a

    if-eq v1, v0, :cond_1

    const/16 v0, 0x10e

    if-ne v1, v0, :cond_2

    .line 86
    :cond_1
    iget p2, p1, Lio/flutter/embedding/engine/image/Metadata;->originalWidth:I

    .line 87
    iget p0, p1, Lio/flutter/embedding/engine/image/Metadata;->originalHeight:I

    .line 89
    :cond_2
    iput p2, p1, Lio/flutter/embedding/engine/image/Metadata;->height:I

    .line 90
    iput p0, p1, Lio/flutter/embedding/engine/image/Metadata;->width:I

    .line 91
    iput v1, p1, Lio/flutter/embedding/engine/image/Metadata;->rotation:I
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :cond_3
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    :cond_4
    return-void

    :catch_0
    move-exception p0

    .line 96
    const-string p1, "MediaMetadataReader"

    const-string p2, "Failed to decode HEIF image using MediaExtractor"

    invoke-static {p1, p2, p0}, Lio/flutter/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    return-void
.end method
