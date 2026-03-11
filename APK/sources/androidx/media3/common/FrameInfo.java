package androidx.media3.common;

import com.google.common.base.Preconditions;

/* JADX INFO: loaded from: classes.dex */
public class FrameInfo {
    public final Format format;
    public final long offsetToAddUs;

    public FrameInfo(Format format, long j) {
        Preconditions.checkArgument(format.colorInfo != null, "format colorInfo must be set");
        Preconditions.checkArgument(format.width > 0, "format width must be positive, but is: %s", format.width);
        Preconditions.checkArgument(format.height > 0, "format height must be positive, but is: %s", format.height);
        this.format = format;
        this.offsetToAddUs = j;
    }
}
