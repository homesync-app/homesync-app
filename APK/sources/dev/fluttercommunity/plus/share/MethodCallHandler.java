package dev.fluttercommunity.plus.share;

import androidx.core.app.NotificationCompat;
import androidx.media3.container.NalUnitUtil;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.tekartik.sqflite.Constant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.Map;
import kotlin.Metadata;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: MethodCallHandler.kt */
/* JADX INFO: loaded from: classes3.dex */
@Metadata(d1 = {"\u00004\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0003\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0010\u000b\n\u0002\b\u0002\b\u0000\u0018\u00002\u00020\u0001B\u0017\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0006\u0010\u0004\u001a\u00020\u0005¢\u0006\u0004\b\u0006\u0010\u0007J\u0018\u0010\b\u001a\u00020\t2\u0006\u0010\n\u001a\u00020\u000b2\u0006\u0010\f\u001a\u00020\rH\u0016J\u0018\u0010\u000e\u001a\u00020\t2\u0006\u0010\u000f\u001a\u00020\u00102\u0006\u0010\f\u001a\u00020\rH\u0002J\u0010\u0010\u0011\u001a\u00020\t2\u0006\u0010\n\u001a\u00020\u000bH\u0002R\u000e\u0010\u0002\u001a\u00020\u0003X\u0082\u0004¢\u0006\u0002\n\u0000R\u000e\u0010\u0004\u001a\u00020\u0005X\u0082\u0004¢\u0006\u0002\n\u0000¨\u0006\u0012"}, d2 = {"Ldev/fluttercommunity/plus/share/MethodCallHandler;", "Lio/flutter/plugin/common/MethodChannel$MethodCallHandler;", FirebaseAnalytics.Event.SHARE, "Ldev/fluttercommunity/plus/share/Share;", "manager", "Ldev/fluttercommunity/plus/share/ShareSuccessManager;", "<init>", "(Ldev/fluttercommunity/plus/share/Share;Ldev/fluttercommunity/plus/share/ShareSuccessManager;)V", "onMethodCall", "", NotificationCompat.CATEGORY_CALL, "Lio/flutter/plugin/common/MethodCall;", Constant.PARAM_RESULT, "Lio/flutter/plugin/common/MethodChannel$Result;", FirebaseAnalytics.Param.SUCCESS, "isWithResult", "", "expectMapArguments", "share_plus_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final class MethodCallHandler implements MethodChannel.MethodCallHandler {
    private final ShareSuccessManager manager;
    private final Share share;

    public MethodCallHandler(Share share, ShareSuccessManager manager) {
        Intrinsics.checkNotNullParameter(share, "share");
        Intrinsics.checkNotNullParameter(manager, "manager");
        this.share = share;
        this.manager = manager;
    }

    @Override // io.flutter.plugin.common.MethodChannel.MethodCallHandler
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        Intrinsics.checkNotNullParameter(call, "call");
        Intrinsics.checkNotNullParameter(result, "result");
        expectMapArguments(call);
        this.manager.setCallback(result);
        try {
            if (Intrinsics.areEqual(call.method, FirebaseAnalytics.Event.SHARE)) {
                Share share = this.share;
                Object objArguments = call.arguments();
                Intrinsics.checkNotNull(objArguments);
                share.share((Map) objArguments, true);
                success(true, result);
                return;
            }
            result.notImplemented();
        } catch (Throwable th) {
            this.manager.clear();
            result.error("Share failed", th.getMessage(), th);
        }
    }

    private final void success(boolean isWithResult, MethodChannel.Result result) {
        if (isWithResult) {
            return;
        }
        result.success(ShareSuccessManager.RESULT_UNAVAILABLE);
    }

    private final void expectMapArguments(MethodCall call) throws IllegalArgumentException {
        if (!(call.arguments instanceof Map)) {
            throw new IllegalArgumentException("Map arguments expected".toString());
        }
    }
}
