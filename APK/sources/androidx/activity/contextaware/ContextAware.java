package androidx.activity.contextaware;

import android.content.Context;
import androidx.media3.container.NalUnitUtil;
import com.google.android.gms.common.internal.ServiceSpecificExtraArgs;
import kotlin.Metadata;

/* JADX INFO: compiled from: ContextAware.kt */
/* JADX INFO: loaded from: classes.dex */
@Metadata(d1 = {"\u0000\u001e\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\bf\u0018\u00002\u00020\u0001J\n\u0010\u0002\u001a\u0004\u0018\u00010\u0003H&J\u0010\u0010\u0004\u001a\u00020\u00052\u0006\u0010\u0006\u001a\u00020\u0007H&J\u0010\u0010\b\u001a\u00020\u00052\u0006\u0010\u0006\u001a\u00020\u0007H&ø\u0001\u0000\u0082\u0002\u0006\n\u0004\b!0\u0001¨\u0006\tÀ\u0006\u0001"}, d2 = {"Landroidx/activity/contextaware/ContextAware;", "", "peekAvailableContext", "Landroid/content/Context;", "addOnContextAvailableListener", "", ServiceSpecificExtraArgs.CastExtraArgs.LISTENER, "Landroidx/activity/contextaware/OnContextAvailableListener;", "removeOnContextAvailableListener", "activity"}, k = 1, mv = {2, 0, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public interface ContextAware {
    void addOnContextAvailableListener(OnContextAvailableListener listener);

    Context peekAvailableContext();

    void removeOnContextAvailableListener(OnContextAvailableListener listener);
}
