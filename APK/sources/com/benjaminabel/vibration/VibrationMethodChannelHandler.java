package com.benjaminabel.vibration;

import android.os.Build;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.List;

/* JADX INFO: loaded from: classes3.dex */
class VibrationMethodChannelHandler implements MethodChannel.MethodCallHandler {
    static final /* synthetic */ boolean $assertionsDisabled = false;
    private final Vibration vibration;

    VibrationMethodChannelHandler(Vibration vibration) {
        this.vibration = vibration;
    }

    @Override // io.flutter.plugin.common.MethodChannel.MethodCallHandler
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        String str = methodCall.method;
        str.hashCode();
        switch (str) {
            case "cancel":
                this.vibration.getVibrator().cancel();
                result.success(null);
                break;
            case "hasAmplitudeControl":
                if (Build.VERSION.SDK_INT >= 26) {
                    result.success(Boolean.valueOf(this.vibration.getVibrator().hasAmplitudeControl()));
                    break;
                } else {
                    result.success(false);
                    break;
                }
                break;
            case "vibrate":
                Integer num = (Integer) methodCall.argument("duration");
                List<Integer> list = (List) methodCall.argument("pattern");
                Integer num2 = (Integer) methodCall.argument("repeat");
                List<Integer> list2 = (List) methodCall.argument("intensities");
                Integer num3 = (Integer) methodCall.argument("amplitude");
                if (!list.isEmpty() && !list2.isEmpty()) {
                    this.vibration.vibrate(list, num2.intValue(), list2);
                } else if (list.size() > 0) {
                    this.vibration.vibrate(list, num2.intValue());
                } else {
                    this.vibration.vibrate(num.intValue(), num3.intValue());
                }
                result.success(null);
                break;
            case "hasCustomVibrationsSupport":
                result.success(true);
                break;
            default:
                result.notImplemented();
                break;
        }
    }
}
