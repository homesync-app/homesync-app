package kotlinx.serialization.json.internal;

import androidx.media3.container.NalUnitUtil;
import kotlin.Metadata;

/* JADX INFO: compiled from: JsonStreams.kt */
/* JADX INFO: loaded from: classes4.dex */
@JsonFriendModuleApi
@Metadata(d1 = {"\u0000\u0018\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\b\n\u0000\n\u0002\u0010\u0019\n\u0002\b\u0003\bg\u0018\u00002\u00020\u0001J \u0010\u0002\u001a\u00020\u00032\u0006\u0010\u0004\u001a\u00020\u00052\u0006\u0010\u0006\u001a\u00020\u00032\u0006\u0010\u0007\u001a\u00020\u0003H&¨\u0006\b"}, d2 = {"Lkotlinx/serialization/json/internal/InternalJsonReader;", "", "read", "", "buffer", "", "bufferOffset", "count", "kotlinx-serialization-json"}, k = 1, mv = {2, 0, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public interface InternalJsonReader {
    int read(char[] buffer, int bufferOffset, int count);
}
