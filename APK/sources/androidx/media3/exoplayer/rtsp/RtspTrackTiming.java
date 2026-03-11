package androidx.media3.exoplayer.rtsp;

import android.net.Uri;
import androidx.credentials.exceptions.publickeycredential.DomExceptionUtils;
import androidx.media3.common.util.UriUtil;
import com.google.common.base.Preconditions;

/* JADX INFO: loaded from: classes.dex */
final class RtspTrackTiming {
    public final long rtpTimestamp;
    public final int sequenceNumber;
    public final Uri uri;

    /* JADX WARN: Removed duplicated region for block: B:23:0x0071  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static com.google.common.collect.ImmutableList<androidx.media3.exoplayer.rtsp.RtspTrackTiming> parseTrackTiming(java.lang.String r20, android.net.Uri r21) throws androidx.media3.common.ParserException {
        /*
            Method dump skipped, instruction units count: 211
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: androidx.media3.exoplayer.rtsp.RtspTrackTiming.parseTrackTiming(java.lang.String, android.net.Uri):com.google.common.collect.ImmutableList");
    }

    static Uri resolveUri(String str, Uri uri) {
        Preconditions.checkArgument(((String) Preconditions.checkNotNull(uri.getScheme())).equals("rtsp"));
        Uri uri2 = Uri.parse(str);
        if (uri2.isAbsolute()) {
            return uri2;
        }
        Uri uri3 = Uri.parse("rtsp://" + str);
        String string = uri.toString();
        if (((String) Preconditions.checkNotNull(uri3.getHost())).equals(uri.getHost())) {
            return uri3;
        }
        if (!string.endsWith(DomExceptionUtils.SEPARATOR)) {
            return UriUtil.resolveToUri(string + DomExceptionUtils.SEPARATOR, str);
        }
        return UriUtil.resolveToUri(string, str);
    }

    private RtspTrackTiming(long j, int i, Uri uri) {
        this.rtpTimestamp = j;
        this.sequenceNumber = i;
        this.uri = uri;
    }
}
