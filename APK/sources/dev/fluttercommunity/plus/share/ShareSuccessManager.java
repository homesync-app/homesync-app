package dev.fluttercommunity.plus.share;

import android.content.Context;
import android.content.Intent;
import androidx.media3.container.NalUnitUtil;
import com.tekartik.sqflite.Constant;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import java.util.concurrent.atomic.AtomicBoolean;
import kotlin.Metadata;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: ShareSuccessManager.kt */
/* JADX INFO: loaded from: classes3.dex */
@Metadata(d1 = {"\u0000B\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0002\n\u0002\b\u0004\n\u0002\u0010\u000e\n\u0000\n\u0002\u0010\u000b\n\u0000\n\u0002\u0010\b\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\b\u0002\b\u0000\u0018\u0000 \u00182\u00020\u0001:\u0001\u0018B\u000f\u0012\u0006\u0010\u0002\u001a\u00020\u0003¢\u0006\u0004\b\u0004\u0010\u0005J\u000e\u0010\n\u001a\u00020\u000b2\u0006\u0010\u0006\u001a\u00020\u0007J\u0006\u0010\f\u001a\u00020\u000bJ\u0006\u0010\r\u001a\u00020\u000bJ\u0010\u0010\u000e\u001a\u00020\u000b2\u0006\u0010\u000f\u001a\u00020\u0010H\u0002J\"\u0010\u0011\u001a\u00020\u00122\u0006\u0010\u0013\u001a\u00020\u00142\u0006\u0010\u0015\u001a\u00020\u00142\b\u0010\u0016\u001a\u0004\u0018\u00010\u0017H\u0016R\u000e\u0010\u0002\u001a\u00020\u0003X\u0082\u0004¢\u0006\u0002\n\u0000R\u0010\u0010\u0006\u001a\u0004\u0018\u00010\u0007X\u0082\u000e¢\u0006\u0002\n\u0000R\u000e\u0010\b\u001a\u00020\tX\u0082\u000e¢\u0006\u0002\n\u0000¨\u0006\u0019"}, d2 = {"Ldev/fluttercommunity/plus/share/ShareSuccessManager;", "Lio/flutter/plugin/common/PluginRegistry$ActivityResultListener;", "context", "Landroid/content/Context;", "<init>", "(Landroid/content/Context;)V", "callback", "Lio/flutter/plugin/common/MethodChannel$Result;", "isCalledBack", "Ljava/util/concurrent/atomic/AtomicBoolean;", "setCallback", "", "unavailable", "clear", "returnResult", Constant.PARAM_RESULT, "", "onActivityResult", "", "requestCode", "", "resultCode", "data", "Landroid/content/Intent;", "Companion", "share_plus_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final class ShareSuccessManager implements PluginRegistry.ActivityResultListener {
    public static final int ACTIVITY_CODE = 22643;
    public static final String RESULT_UNAVAILABLE = "dev.fluttercommunity.plus/share/unavailable";
    private MethodChannel.Result callback;
    private final Context context;
    private AtomicBoolean isCalledBack;

    public ShareSuccessManager(Context context) {
        Intrinsics.checkNotNullParameter(context, "context");
        this.context = context;
        this.isCalledBack = new AtomicBoolean(true);
    }

    public final void setCallback(MethodChannel.Result callback) {
        Intrinsics.checkNotNullParameter(callback, "callback");
        if (this.isCalledBack.compareAndSet(true, false)) {
            SharePlusPendingIntent.INSTANCE.setResult("");
            this.isCalledBack.set(false);
            this.callback = callback;
        } else {
            MethodChannel.Result result = this.callback;
            if (result != null) {
                result.success(RESULT_UNAVAILABLE);
            }
            SharePlusPendingIntent.INSTANCE.setResult("");
            this.isCalledBack.set(false);
            this.callback = callback;
        }
    }

    public final void unavailable() {
        returnResult(RESULT_UNAVAILABLE);
    }

    public final void clear() {
        this.isCalledBack.set(true);
        this.callback = null;
    }

    private final void returnResult(String result) {
        MethodChannel.Result result2;
        if (!this.isCalledBack.compareAndSet(false, true) || (result2 = this.callback) == null) {
            return;
        }
        Intrinsics.checkNotNull(result2);
        result2.success(result);
        this.callback = null;
    }

    @Override // io.flutter.plugin.common.PluginRegistry.ActivityResultListener
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode != 22643) {
            return false;
        }
        returnResult(SharePlusPendingIntent.INSTANCE.getResult());
        return true;
    }
}
