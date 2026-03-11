package io.flutter.embedding.engine.image;

/* JADX INFO: loaded from: classes3.dex */
public class FlutterImageDecoder {

    public interface HeaderListener {
        void onImageHeader(int i, int i2);
    }

    /* JADX WARN: Removed duplicated region for block: B:10:0x0020  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static android.graphics.Bitmap decodeImage(java.nio.ByteBuffer r3, io.flutter.embedding.engine.image.FlutterImageDecoder.HeaderListener r4) {
        /*
            io.flutter.embedding.engine.image.Metadata r0 = io.flutter.embedding.engine.image.Metadata.create(r3, r4)
            boolean r1 = r0.isHeif()
            if (r1 == 0) goto L20
            int r1 = android.os.Build.VERSION.SDK_INT
            r2 = 36
            if (r1 != r2) goto L16
            io.flutter.embedding.engine.image.ImageDecoderHeifApi36Impl r1 = new io.flutter.embedding.engine.image.ImageDecoderHeifApi36Impl
            r1.<init>()
            goto L21
        L16:
            int r1 = android.os.Build.VERSION.SDK_INT
            if (r1 >= r2) goto L20
            io.flutter.embedding.engine.image.ImageDecoderHeifPre36Impl r1 = new io.flutter.embedding.engine.image.ImageDecoderHeifPre36Impl
            r1.<init>()
            goto L21
        L20:
            r1 = 0
        L21:
            if (r1 != 0) goto L28
            io.flutter.embedding.engine.image.ImageDecoderDefaultImpl r1 = new io.flutter.embedding.engine.image.ImageDecoderDefaultImpl
            r1.<init>(r4)
        L28:
            android.graphics.Bitmap r3 = r1.decodeImage(r3, r0)
            return r3
        */
        throw new UnsupportedOperationException("Method not decompiled: io.flutter.embedding.engine.image.FlutterImageDecoder.decodeImage(java.nio.ByteBuffer, io.flutter.embedding.engine.image.FlutterImageDecoder$HeaderListener):android.graphics.Bitmap");
    }
}
