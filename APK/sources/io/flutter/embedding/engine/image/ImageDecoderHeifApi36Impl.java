package io.flutter.embedding.engine.image;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import java.nio.ByteBuffer;

/* JADX INFO: loaded from: classes3.dex */
class ImageDecoderHeifApi36Impl extends ImageDecoderDefaultImpl {
    public ImageDecoderHeifApi36Impl() {
        super(null);
    }

    @Override // io.flutter.embedding.engine.image.ImageDecoderDefaultImpl, io.flutter.embedding.engine.image.ImageDecoder
    public Bitmap decodeImage(ByteBuffer byteBuffer, Metadata metadata) {
        Bitmap bitmapDecodeImage = super.decodeImage(byteBuffer, metadata);
        return bitmapDecodeImage != null ? bitmapDecodeImage : decodeImageFallback(byteBuffer, metadata);
    }

    Bitmap decodeImageFallback(ByteBuffer byteBuffer, Metadata metadata) {
        byte[] bytes = ImageUtils.getBytes(byteBuffer);
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inPreferredConfig = Bitmap.Config.ARGB_8888;
        Bitmap bitmapDecodeByteArray = BitmapFactory.decodeByteArray(bytes, 0, bytes.length, options);
        if (metadata.rotation != 0) {
            Matrix matrix = new Matrix();
            matrix.postRotate(metadata.rotation);
            Bitmap bitmapCreateBitmap = Bitmap.createBitmap(bitmapDecodeByteArray, 0, 0, bitmapDecodeByteArray.getWidth(), bitmapDecodeByteArray.getHeight(), matrix, true);
            bitmapDecodeByteArray.recycle();
            return ImageUtils.applyFlipIfNeeded(bitmapCreateBitmap, metadata.orientation);
        }
        return ImageUtils.applyFlipIfNeeded(bitmapDecodeByteArray, metadata.orientation);
    }
}
