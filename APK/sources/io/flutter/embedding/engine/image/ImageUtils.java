package io.flutter.embedding.engine.image;

import android.graphics.Bitmap;
import android.graphics.Matrix;
import io.flutter.Log;
import java.nio.ByteBuffer;

/* JADX INFO: loaded from: classes3.dex */
class ImageUtils {
    private static final String TAG = "ImageUtils";

    ImageUtils() {
    }

    static byte[] getBytes(ByteBuffer byteBuffer) {
        byte[] bArr = new byte[byteBuffer.remaining()];
        byteBuffer.get(bArr);
        byteBuffer.rewind();
        return bArr;
    }

    static boolean isFlipCase(int i) {
        switch (i) {
            case 1:
            case 3:
            case 6:
            case 8:
                break;
            case 2:
            case 4:
            case 5:
            case 7:
                break;
            default:
                Log.e(TAG, "Unknown EXIF orientation: " + i);
                break;
        }
        return false;
    }

    static Bitmap applyFlipIfNeeded(Bitmap bitmap, int i) {
        if (bitmap != null && isFlipCase(i)) {
            int width = bitmap.getWidth();
            int height = bitmap.getHeight();
            Matrix matrix = new Matrix();
            if (i == 2 || i == 7) {
                matrix.setScale(-1.0f, 1.0f, width / 2.0f, height / 2.0f);
            } else if (i == 4 || i == 5) {
                matrix.setScale(1.0f, -1.0f, width / 2.0f, height / 2.0f);
            }
            Bitmap bitmapCreateBitmap = Bitmap.createBitmap(bitmap, 0, 0, width, height, matrix, true);
            if (bitmapCreateBitmap != bitmap) {
                bitmap.recycle();
            }
            return bitmapCreateBitmap;
        }
        return bitmap;
    }
}
