package io.flutter.embedding.engine.plugins.contentprovider;

/* JADX INFO: loaded from: classes3.dex */
public interface ContentProviderAware {
    void onAttachedToContentProvider(ContentProviderPluginBinding contentProviderPluginBinding);

    void onDetachedFromContentProvider();
}
