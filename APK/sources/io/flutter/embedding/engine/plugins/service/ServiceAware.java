package io.flutter.embedding.engine.plugins.service;

/* JADX INFO: loaded from: classes3.dex */
public interface ServiceAware {

    public interface OnModeChangeListener {
        void onMoveToBackground();

        void onMoveToForeground();
    }

    void onAttachedToService(ServicePluginBinding servicePluginBinding);

    void onDetachedFromService();
}
