package io.flutter.embedding.engine.image;

import android.graphics.BitmapFactory;
import io.flutter.Log;

/* JADX INFO: loaded from: classes3.dex */
public class BitmapMetadataReader {
    private static final String TAG = "BitmapMetadataReader";

    static void read(byte[] bArr, Metadata metadata) {
        try {
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inJustDecodeBounds = true;
            BitmapFactory.decodeByteArray(bArr, 0, bArr.length, options);
            metadata.mimeType = options.outMimeType;
            metadata.originalHeight = options.outHeight;
            metadata.originalWidth = options.outWidth;
        } catch (Exception e) {
            Log.e(TAG, "Failed to decode image for mime type", e);
        }
    }
}
