package com.llfbandit.app_links;

import android.content.Intent;
import android.util.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

/* JADX INFO: loaded from: classes3.dex */
public class AppLinksPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler, ActivityAware, PluginRegistry.NewIntentListener {
    private static final String EVENTS_CHANNEL = "com.llfbandit.app_links/events";
    private static final String MESSAGES_CHANNEL = "com.llfbandit.app_links/messages";
    private static final String TAG = "com.llfbandit.app_links";
    ActivityPluginBinding binding;
    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;
    private String initialLink;
    private boolean initialLinkSent = false;
    private String latestLink;
    private MethodChannel methodChannel;

    @Override // io.flutter.embedding.engine.plugins.FlutterPlugin
    public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        MethodChannel methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), MESSAGES_CHANNEL);
        this.methodChannel = methodChannel;
        methodChannel.setMethodCallHandler(this);
        EventChannel eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), EVENTS_CHANNEL);
        this.eventChannel = eventChannel;
        eventChannel.setStreamHandler(this);
    }

    @Override // io.flutter.embedding.engine.plugins.FlutterPlugin
    public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        this.methodChannel.setMethodCallHandler(null);
        this.eventChannel.setStreamHandler(null);
    }

    @Override // io.flutter.plugin.common.MethodChannel.MethodCallHandler
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        if (methodCall.method.equals("getLatestLink")) {
            result.success(this.latestLink);
        } else if (methodCall.method.equals("getInitialLink")) {
            result.success(this.initialLink);
        } else {
            result.notImplemented();
        }
    }

    @Override // io.flutter.embedding.engine.plugins.activity.ActivityAware
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        this.binding = activityPluginBinding;
        activityPluginBinding.addOnNewIntentListener(this);
        handleIntent(activityPluginBinding.getActivity().getIntent());
    }

    @Override // io.flutter.embedding.engine.plugins.activity.ActivityAware
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
        this.binding = activityPluginBinding;
        activityPluginBinding.addOnNewIntentListener(this);
    }

    @Override // io.flutter.embedding.engine.plugins.activity.ActivityAware
    public void onDetachedFromActivity() {
        ActivityPluginBinding activityPluginBinding = this.binding;
        if (activityPluginBinding != null) {
            activityPluginBinding.removeOnNewIntentListener(this);
        }
        this.binding = null;
    }

    @Override // io.flutter.embedding.engine.plugins.activity.ActivityAware
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override // io.flutter.plugin.common.EventChannel.StreamHandler
    public void onListen(Object obj, EventChannel.EventSink eventSink) {
        String str;
        this.eventSink = eventSink;
        if (this.initialLinkSent || (str = this.initialLink) == null) {
            return;
        }
        this.initialLinkSent = true;
        eventSink.success(str);
    }

    @Override // io.flutter.plugin.common.EventChannel.StreamHandler
    public void onCancel(Object obj) {
        this.eventSink = null;
    }

    @Override // io.flutter.plugin.common.PluginRegistry.NewIntentListener
    public boolean onNewIntent(Intent intent) {
        return handleIntent(intent);
    }

    private boolean handleIntent(Intent intent) {
        String url;
        if (intent == null) {
            return false;
        }
        Log.d(TAG, intent.toString());
        if ((intent.getFlags() & 1048576) == 1048576 || (url = AppLinksHelper.getUrl(intent)) == null) {
            return false;
        }
        if (this.initialLink == null) {
            this.initialLink = url;
        }
        this.latestLink = url;
        EventChannel.EventSink eventSink = this.eventSink;
        if (eventSink != null) {
            this.initialLinkSent = true;
            eventSink.success(url);
        }
        return true;
    }
}
