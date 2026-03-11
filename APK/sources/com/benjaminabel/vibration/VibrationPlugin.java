package com.benjaminabel.vibration;

import android.content.Context;
import android.os.Build;
import android.os.Vibrator;
import android.os.VibratorManager;
import androidx.core.content.ContextCompat;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodChannel;

/* JADX INFO: loaded from: classes3.dex */
public class VibrationPlugin implements FlutterPlugin {
    private static final String CHANNEL = "vibration";
    private MethodChannel methodChannel;

    public Vibrator getVibrator(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        if (Build.VERSION.SDK_INT < 31) {
            return getLegacyVibrator(flutterPluginBinding);
        }
        try {
            return ((VibratorManager) flutterPluginBinding.getApplicationContext().getSystemService("vibrator_manager")).getDefaultVibrator();
        } catch (NoClassDefFoundError | NoSuchMethodError unused) {
            return getLegacyVibrator(flutterPluginBinding);
        }
    }

    private Vibrator getLegacyVibrator(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        Context applicationContext = flutterPluginBinding.getApplicationContext();
        Vibrator vibrator = (Vibrator) ContextCompat.getSystemService(applicationContext, Vibrator.class);
        return vibrator != null ? vibrator : (Vibrator) applicationContext.getSystemService("vibrator");
    }

    @Override // io.flutter.embedding.engine.plugins.FlutterPlugin
    public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        VibrationMethodChannelHandler vibrationMethodChannelHandler = new VibrationMethodChannelHandler(new Vibration(getVibrator(flutterPluginBinding)));
        MethodChannel methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL);
        this.methodChannel = methodChannel;
        methodChannel.setMethodCallHandler(vibrationMethodChannelHandler);
    }

    @Override // io.flutter.embedding.engine.plugins.FlutterPlugin
    public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        this.methodChannel.setMethodCallHandler(null);
        this.methodChannel = null;
    }
}
