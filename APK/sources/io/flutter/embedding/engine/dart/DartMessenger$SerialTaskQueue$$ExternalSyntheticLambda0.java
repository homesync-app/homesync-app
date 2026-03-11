package io.flutter.embedding.engine.dart;

import io.flutter.embedding.engine.dart.DartMessenger;

/* JADX INFO: compiled from: D8$$SyntheticClass */
/* JADX INFO: loaded from: classes3.dex */
public final /* synthetic */ class DartMessenger$SerialTaskQueue$$ExternalSyntheticLambda0 implements Runnable {
    public final /* synthetic */ DartMessenger.SerialTaskQueue f$0;

    public /* synthetic */ DartMessenger$SerialTaskQueue$$ExternalSyntheticLambda0(DartMessenger.SerialTaskQueue serialTaskQueue) {
        this.f$0 = serialTaskQueue;
    }

    @Override // java.lang.Runnable
    public final void run() {
        this.f$0.flush();
    }
}
