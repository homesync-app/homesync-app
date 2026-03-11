package androidx.media3.common;

import android.view.View;
import android.view.ViewGroup;
import com.google.common.util.concurrent.ListenableFuture;

/* JADX INFO: loaded from: classes.dex */
public interface ViewProvider {
    ListenableFuture<View> getView(ViewGroup viewGroup);
}
