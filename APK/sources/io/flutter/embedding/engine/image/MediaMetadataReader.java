package io.flutter.embedding.engine.image;

import android.media.MediaDataSource;
import android.media.MediaExtractor;
import android.media.MediaFormat;
import io.flutter.Log;
import java.io.IOException;

/* JADX INFO: loaded from: classes3.dex */
class MediaMetadataReader {
    private static final String TAG = "MediaMetadataReader";

    MediaMetadataReader() {
    }

    private static MediaExtractor getMediaExtractor(final byte[] bArr) throws IOException {
        MediaDataSource mediaDataSource = new MediaDataSource() { // from class: io.flutter.embedding.engine.image.MediaMetadataReader.1
            @Override // java.io.Closeable, java.lang.AutoCloseable
            public void close() throws IOException {
            }

            @Override // android.media.MediaDataSource
            public long getSize() throws IOException {
                return bArr.length;
            }

            @Override // android.media.MediaDataSource
            public int readAt(long j, byte[] bArr2, int i, int i2) throws IOException {
                byte[] bArr3 = bArr;
                if (j >= bArr3.length) {
                    return -1;
                }
                if (((long) i2) + j > bArr3.length) {
                    i2 = (int) (((long) bArr3.length) - j);
                }
                System.arraycopy(bArr3, (int) j, bArr2, i, i2);
                return i2;
            }
        };
        MediaExtractor mediaExtractor = new MediaExtractor();
        mediaExtractor.setDataSource(mediaDataSource);
        return mediaExtractor;
    }

    static void read(byte[] bArr, Metadata metadata) {
        try {
            read(bArr, metadata, getMediaExtractor(bArr));
        } catch (Exception e) {
            Log.e(TAG, "Failed to decode HEIF image using MediaExtractor", e);
        }
    }

    static void read(byte[] bArr, Metadata metadata, MediaExtractor mediaExtractor) {
        try {
            int trackCount = mediaExtractor.getTrackCount();
            for (int i = 0; i < trackCount; i++) {
                MediaFormat trackFormat = mediaExtractor.getTrackFormat(i);
                String string = trackFormat.getString("mime");
                if (string != null && string.startsWith("image/")) {
                    int integer = trackFormat.containsKey("rotation-degrees") ? trackFormat.getInteger("rotation-degrees") : 0;
                    int i2 = metadata.originalWidth;
                    int i3 = metadata.originalHeight;
                    if (integer == 90 || integer == 270) {
                        i3 = metadata.originalWidth;
                        i2 = metadata.originalHeight;
                    }
                    metadata.height = i3;
                    metadata.width = i2;
                    metadata.rotation = integer;
                    return;
                }
            }
        } catch (Exception e) {
            Log.e(TAG, "Failed to decode HEIF image using MediaExtractor", e);
        }
    }
}
