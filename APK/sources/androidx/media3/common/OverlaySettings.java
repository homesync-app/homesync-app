package androidx.media3.common;

import android.util.Pair;

/* JADX INFO: loaded from: classes.dex */
public interface OverlaySettings {
    public static final float DEFAULT_ALPHA_SCALE = 1.0f;
    public static final Pair<Float, Float> DEFAULT_BACKGROUND_FRAME_ANCHOR;
    public static final float DEFAULT_HDR_LUMINANCE_MULTIPLIER = 1.0f;
    public static final Pair<Float, Float> DEFAULT_OVERLAY_FRAME_ANCHOR;
    public static final float DEFAULT_ROTATION_DEGREES = 0.0f;
    public static final Pair<Float, Float> DEFAULT_SCALE;

    default float getAlphaScale() {
        return 1.0f;
    }

    default float getHdrLuminanceMultiplier() {
        return 1.0f;
    }

    default float getRotationDegrees() {
        return 0.0f;
    }

    static {
        Float fValueOf = Float.valueOf(0.0f);
        DEFAULT_BACKGROUND_FRAME_ANCHOR = Pair.create(fValueOf, fValueOf);
        DEFAULT_OVERLAY_FRAME_ANCHOR = Pair.create(fValueOf, fValueOf);
        Float fValueOf2 = Float.valueOf(1.0f);
        DEFAULT_SCALE = Pair.create(fValueOf2, fValueOf2);
    }

    default Pair<Float, Float> getBackgroundFrameAnchor() {
        return DEFAULT_BACKGROUND_FRAME_ANCHOR;
    }

    default Pair<Float, Float> getOverlayFrameAnchor() {
        return DEFAULT_OVERLAY_FRAME_ANCHOR;
    }

    default Pair<Float, Float> getScale() {
        return DEFAULT_SCALE;
    }
}
