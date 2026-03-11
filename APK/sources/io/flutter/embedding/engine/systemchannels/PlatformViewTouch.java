package io.flutter.embedding.engine.systemchannels;

/* JADX INFO: loaded from: classes3.dex */
public class PlatformViewTouch {
    public final int action;
    public final int buttonState;
    public final int deviceId;
    public final Number downTime;
    public final int edgeFlags;
    public final Number eventTime;
    public final int flags;
    public final int metaState;
    public final long motionEventId;
    public final int pointerCount;
    public final Object rawPointerCoords;
    public final Object rawPointerPropertiesList;
    public final int source;
    public final int viewId;
    public final float xPrecision;
    public final float yPrecision;

    public PlatformViewTouch(int i, Number number, Number number2, int i2, int i3, Object obj, Object obj2, int i4, int i5, float f, float f2, int i6, int i7, int i8, int i9, long j) {
        this.viewId = i;
        this.downTime = number;
        this.eventTime = number2;
        this.action = i2;
        this.pointerCount = i3;
        this.rawPointerPropertiesList = obj;
        this.rawPointerCoords = obj2;
        this.metaState = i4;
        this.buttonState = i5;
        this.xPrecision = f;
        this.yPrecision = f2;
        this.deviceId = i6;
        this.edgeFlags = i7;
        this.source = i8;
        this.flags = i9;
        this.motionEventId = j;
    }
}
