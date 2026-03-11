package dev.fluttercommunity.plus.share;

import android.content.Context;
import androidx.media3.container.NalUnitUtil;
import com.google.firebase.analytics.FirebaseAnalytics;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;
import kotlin.Metadata;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: SharePlusPlugin.kt */
/* JADX INFO: loaded from: classes3.dex */
@Metadata(d1 = {"\u00008\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\b\u0005\u0018\u0000 \u00152\u00020\u00012\u00020\u0002:\u0001\u0015B\u0007¢\u0006\u0004\b\u0003\u0010\u0004J\u0010\u0010\u000b\u001a\u00020\f2\u0006\u0010\r\u001a\u00020\u000eH\u0016J\u0010\u0010\u000f\u001a\u00020\f2\u0006\u0010\r\u001a\u00020\u000eH\u0016J\u0010\u0010\u0010\u001a\u00020\f2\u0006\u0010\r\u001a\u00020\u0011H\u0016J\b\u0010\u0012\u001a\u00020\fH\u0016J\u0010\u0010\u0013\u001a\u00020\f2\u0006\u0010\r\u001a\u00020\u0011H\u0016J\b\u0010\u0014\u001a\u00020\fH\u0016R\u000e\u0010\u0005\u001a\u00020\u0006X\u0082.¢\u0006\u0002\n\u0000R\u000e\u0010\u0007\u001a\u00020\bX\u0082.¢\u0006\u0002\n\u0000R\u000e\u0010\t\u001a\u00020\nX\u0082.¢\u0006\u0002\n\u0000¨\u0006\u0016"}, d2 = {"Ldev/fluttercommunity/plus/share/SharePlusPlugin;", "Lio/flutter/embedding/engine/plugins/FlutterPlugin;", "Lio/flutter/embedding/engine/plugins/activity/ActivityAware;", "<init>", "()V", FirebaseAnalytics.Event.SHARE, "Ldev/fluttercommunity/plus/share/Share;", "manager", "Ldev/fluttercommunity/plus/share/ShareSuccessManager;", "methodChannel", "Lio/flutter/plugin/common/MethodChannel;", "onAttachedToEngine", "", "binding", "Lio/flutter/embedding/engine/plugins/FlutterPlugin$FlutterPluginBinding;", "onDetachedFromEngine", "onAttachedToActivity", "Lio/flutter/embedding/engine/plugins/activity/ActivityPluginBinding;", "onDetachedFromActivity", "onReattachedToActivityForConfigChanges", "onDetachedFromActivityForConfigChanges", "Companion", "share_plus_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final class SharePlusPlugin implements FlutterPlugin, ActivityAware {
    private static final String CHANNEL = "dev.fluttercommunity.plus/share";
    private ShareSuccessManager manager;
    private MethodChannel methodChannel;
    private Share share;

    @Override // io.flutter.embedding.engine.plugins.FlutterPlugin
    public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding binding) {
        Intrinsics.checkNotNullParameter(binding, "binding");
        this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL);
        Context applicationContext = binding.getApplicationContext();
        Intrinsics.checkNotNullExpressionValue(applicationContext, "getApplicationContext(...)");
        this.manager = new ShareSuccessManager(applicationContext);
        Context applicationContext2 = binding.getApplicationContext();
        Intrinsics.checkNotNullExpressionValue(applicationContext2, "getApplicationContext(...)");
        ShareSuccessManager shareSuccessManager = this.manager;
        MethodChannel methodChannel = null;
        if (shareSuccessManager == null) {
            Intrinsics.throwUninitializedPropertyAccessException("manager");
            shareSuccessManager = null;
        }
        this.share = new Share(applicationContext2, null, shareSuccessManager);
        Share share = this.share;
        if (share == null) {
            Intrinsics.throwUninitializedPropertyAccessException(FirebaseAnalytics.Event.SHARE);
            share = null;
        }
        ShareSuccessManager shareSuccessManager2 = this.manager;
        if (shareSuccessManager2 == null) {
            Intrinsics.throwUninitializedPropertyAccessException("manager");
            shareSuccessManager2 = null;
        }
        MethodCallHandler methodCallHandler = new MethodCallHandler(share, shareSuccessManager2);
        MethodChannel methodChannel2 = this.methodChannel;
        if (methodChannel2 == null) {
            Intrinsics.throwUninitializedPropertyAccessException("methodChannel");
        } else {
            methodChannel = methodChannel2;
        }
        methodChannel.setMethodCallHandler(methodCallHandler);
    }

    @Override // io.flutter.embedding.engine.plugins.FlutterPlugin
    public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding binding) {
        Intrinsics.checkNotNullParameter(binding, "binding");
        MethodChannel methodChannel = this.methodChannel;
        if (methodChannel == null) {
            Intrinsics.throwUninitializedPropertyAccessException("methodChannel");
            methodChannel = null;
        }
        methodChannel.setMethodCallHandler(null);
    }

    @Override // io.flutter.embedding.engine.plugins.activity.ActivityAware
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        Intrinsics.checkNotNullParameter(binding, "binding");
        ShareSuccessManager shareSuccessManager = this.manager;
        Share share = null;
        if (shareSuccessManager == null) {
            Intrinsics.throwUninitializedPropertyAccessException("manager");
            shareSuccessManager = null;
        }
        binding.addActivityResultListener(shareSuccessManager);
        Share share2 = this.share;
        if (share2 == null) {
            Intrinsics.throwUninitializedPropertyAccessException(FirebaseAnalytics.Event.SHARE);
        } else {
            share = share2;
        }
        share.setActivity(binding.getActivity());
    }

    @Override // io.flutter.embedding.engine.plugins.activity.ActivityAware
    public void onDetachedFromActivity() {
        Share share = this.share;
        if (share == null) {
            Intrinsics.throwUninitializedPropertyAccessException(FirebaseAnalytics.Event.SHARE);
            share = null;
        }
        share.setActivity(null);
    }

    @Override // io.flutter.embedding.engine.plugins.activity.ActivityAware
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        Intrinsics.checkNotNullParameter(binding, "binding");
        onAttachedToActivity(binding);
    }

    @Override // io.flutter.embedding.engine.plugins.activity.ActivityAware
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }
}
