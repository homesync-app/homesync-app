package androidx.activity;

import androidx.activity.OnBackPressedCallback;
import androidx.core.app.NotificationCompat;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleEventObserver;
import androidx.lifecycle.LifecycleOwner;
import androidx.media3.container.NalUnitUtil;
import androidx.navigationevent.NavigationEventDispatcher;
import kotlin.Metadata;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: OnBackPressedDispatcher.kt */
/* JADX INFO: loaded from: classes.dex */
@Metadata(d1 = {"\u0000'\n\u0000\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002*\u0001\u0000\b\n\u0018\u00002\u00020\u00012\u00060\u0002j\u0002`\u0003J\u0018\u0010\u0004\u001a\u00020\u00052\u0006\u0010\u0006\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\tH\u0016J\b\u0010\n\u001a\u00020\u0005H\u0016¨\u0006\u000b"}, d2 = {"androidx/activity/OnBackPressedDispatcher$addCallback$lifecycleObserver$1", "Landroidx/lifecycle/LifecycleEventObserver;", "Ljava/lang/AutoCloseable;", "Lkotlin/AutoCloseable;", "onStateChanged", "", "source", "Landroidx/lifecycle/LifecycleOwner;", NotificationCompat.CATEGORY_EVENT, "Landroidx/lifecycle/Lifecycle$Event;", "close", "activity"}, k = 1, mv = {2, 0, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final class OnBackPressedDispatcher$addCallback$lifecycleObserver$1 implements LifecycleEventObserver, AutoCloseable {
    final /* synthetic */ OnBackPressedCallback.OnBackPressedEventHandler $eventHandler;
    final /* synthetic */ Lifecycle $lifecycle;
    final /* synthetic */ OnBackPressedDispatcher this$0;

    OnBackPressedDispatcher$addCallback$lifecycleObserver$1(OnBackPressedCallback.OnBackPressedEventHandler onBackPressedEventHandler, OnBackPressedDispatcher onBackPressedDispatcher, Lifecycle lifecycle) {
        this.$eventHandler = onBackPressedEventHandler;
        this.this$0 = onBackPressedDispatcher;
        this.$lifecycle = lifecycle;
    }

    @Override // androidx.lifecycle.LifecycleEventObserver
    public void onStateChanged(LifecycleOwner source, Lifecycle.Event event) {
        Intrinsics.checkNotNullParameter(source, "source");
        Intrinsics.checkNotNullParameter(event, "event");
        if (ActivityFlags.isOnBackPressedLifecycleOrderMaintained) {
            if (event == Lifecycle.Event.ON_START) {
                this.$eventHandler.setLifecycleActive(true);
            } else if (event == Lifecycle.Event.ON_STOP) {
                this.$eventHandler.setLifecycleActive(false);
            }
        } else if (event == Lifecycle.Event.ON_START) {
            NavigationEventDispatcher.addHandler$default(this.this$0.getEventDispatcher$activity(), this.$eventHandler, 0, 2, null);
        } else if (event == Lifecycle.Event.ON_STOP) {
            this.$eventHandler.remove();
        }
        if (event == Lifecycle.Event.ON_DESTROY) {
            this.$eventHandler.remove();
            this.$lifecycle.removeObserver(this);
        }
    }

    @Override // java.lang.AutoCloseable
    public void close() {
        this.$lifecycle.removeObserver(this);
    }
}
