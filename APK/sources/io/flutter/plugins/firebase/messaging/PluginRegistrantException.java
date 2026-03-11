package io.flutter.plugins.firebase.messaging;

/* JADX INFO: loaded from: classes3.dex */
class PluginRegistrantException extends RuntimeException {
    public PluginRegistrantException() {
        super("PluginRegistrantCallback is not set. Did you forget to call FlutterFirebaseMessagingBackgroundService.setPluginRegistrant? See the documentation for instructions.");
    }
}
