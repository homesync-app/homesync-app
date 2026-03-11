package androidx.activity;

import androidx.core.app.NotificationCompat;
import androidx.media3.container.NalUnitUtil;
import androidx.navigationevent.NavigationEvent;
import androidx.navigationevent.NavigationEventHandler;
import androidx.navigationevent.NavigationEventInfo;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import kotlin.Metadata;
import kotlin.UByte$$ExternalSyntheticBackport0;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: OnBackPressedCallback.kt */
/* JADX INFO: loaded from: classes.dex */
@Metadata(d1 = {"\u0000D\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000b\n\u0002\b\u0003\n\u0002\u0010!\n\u0002\u0018\u0002\n\u0002\b\u0005\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\b\n\n\u0002\u0018\u0002\n\u0002\b\u0003\b&\u0018\u00002\u00020\u0001:\u0001\"B\u000f\u0012\u0006\u0010\u0002\u001a\u00020\u0003¢\u0006\u0004\b\u0004\u0010\u0005J\b\u0010\u0011\u001a\u00020\u0012H\u0007J\u0010\u0010\u0013\u001a\u00020\u00122\u0006\u0010\u0014\u001a\u00020\u0015H\u0017J\u0010\u0010\u0016\u001a\u00020\u00122\u0006\u0010\u0014\u001a\u00020\u0015H\u0017J\b\u0010\u0017\u001a\u00020\u0012H'J\b\u0010\u0018\u001a\u00020\u0012H\u0017J\u0019\u0010\u0019\u001a\u00020\u00122\n\u0010\u001a\u001a\u00060\u000fj\u0002`\u0010H\u0000¢\u0006\u0002\b\u001bJ\u0019\u0010\u001c\u001a\u00020\u00122\n\u0010\u001a\u001a\u00060\u000fj\u0002`\u0010H\u0000¢\u0006\u0002\b\u001dJ\u0015\u0010\u001e\u001a\u00020\b2\u0006\u0010\u001f\u001a\u00020 H\u0000¢\u0006\u0002\b!R\u0014\u0010\u0006\u001a\b\u0012\u0004\u0012\u00020\b0\u0007X\u0082\u0004¢\u0006\u0002\n\u0000R&\u0010\n\u001a\u00020\u00032\u0006\u0010\t\u001a\u00020\u00038\u0007@GX\u0086\u000e¢\u0006\u000e\n\u0000\u001a\u0004\b\n\u0010\u000b\"\u0004\b\f\u0010\u0005R\u0018\u0010\r\u001a\f\u0012\b\u0012\u00060\u000fj\u0002`\u00100\u000eX\u0082\u0004¢\u0006\u0002\n\u0000¨\u0006#"}, d2 = {"Landroidx/activity/OnBackPressedCallback;", "", "enabled", "", "<init>", "(Z)V", "eventHandlers", "", "Landroidx/activity/OnBackPressedCallback$OnBackPressedEventHandler;", "value", "isEnabled", "()Z", "setEnabled", "closeables", "Ljava/util/concurrent/CopyOnWriteArrayList;", "Ljava/lang/AutoCloseable;", "Lkotlin/AutoCloseable;", "remove", "", "handleOnBackStarted", "backEvent", "Landroidx/activity/BackEventCompat;", "handleOnBackProgressed", "handleOnBackPressed", "handleOnBackCancelled", "addCloseable", "closeable", "addCloseable$activity", "removeCloseable", "removeCloseable$activity", "createNavigationEventHandler", "info", "Landroidx/navigationevent/NavigationEventInfo;", "createNavigationEventHandler$activity", "OnBackPressedEventHandler", "activity"}, k = 1, mv = {2, 0, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public abstract class OnBackPressedCallback {
    private boolean isEnabled;
    private final List<OnBackPressedEventHandler> eventHandlers = new ArrayList();
    private final CopyOnWriteArrayList<AutoCloseable> closeables = new CopyOnWriteArrayList<>();

    public void handleOnBackCancelled() {
    }

    public abstract void handleOnBackPressed();

    public void handleOnBackProgressed(BackEventCompat backEvent) {
        Intrinsics.checkNotNullParameter(backEvent, "backEvent");
    }

    public void handleOnBackStarted(BackEventCompat backEvent) {
        Intrinsics.checkNotNullParameter(backEvent, "backEvent");
    }

    public OnBackPressedCallback(boolean z) {
        this.isEnabled = z;
    }

    /* JADX INFO: renamed from: isEnabled, reason: from getter */
    public final boolean getIsEnabled() {
        return this.isEnabled;
    }

    public final void setEnabled(boolean z) {
        this.isEnabled = z;
        for (OnBackPressedEventHandler onBackPressedEventHandler : this.eventHandlers) {
            onBackPressedEventHandler.setBackEnabled(onBackPressedEventHandler.getIsLifecycleActive() && z);
        }
    }

    public final void remove() throws Exception {
        Iterator<AutoCloseable> it = this.closeables.iterator();
        Intrinsics.checkNotNullExpressionValue(it, "iterator(...)");
        while (it.hasNext()) {
            UByte$$ExternalSyntheticBackport0.m673m((Object) it.next());
        }
        this.closeables.clear();
        Iterator<OnBackPressedEventHandler> it2 = this.eventHandlers.iterator();
        while (it2.hasNext()) {
            it2.next().remove();
        }
        this.eventHandlers.clear();
    }

    public final void addCloseable$activity(AutoCloseable closeable) {
        Intrinsics.checkNotNullParameter(closeable, "closeable");
        this.closeables.add(closeable);
    }

    public final void removeCloseable$activity(AutoCloseable closeable) {
        Intrinsics.checkNotNullParameter(closeable, "closeable");
        this.closeables.remove(closeable);
    }

    public final OnBackPressedEventHandler createNavigationEventHandler$activity(NavigationEventInfo info) {
        Intrinsics.checkNotNullParameter(info, "info");
        OnBackPressedEventHandler onBackPressedEventHandler = new OnBackPressedEventHandler(this, info);
        this.eventHandlers.add(onBackPressedEventHandler);
        return onBackPressedEventHandler;
    }

    /* JADX INFO: compiled from: OnBackPressedCallback.kt */
    @Metadata(d1 = {"\u0000,\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0004\n\u0002\u0010\u000b\n\u0002\b\u0005\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0004\b\u0000\u0018\u00002\b\u0012\u0004\u0012\u00020\u00020\u0001B\u0017\u0012\u0006\u0010\u0003\u001a\u00020\u0004\u0012\u0006\u0010\u0005\u001a\u00020\u0002¢\u0006\u0004\b\u0006\u0010\u0007J\u0010\u0010\u000e\u001a\u00020\u000f2\u0006\u0010\u0010\u001a\u00020\u0011H\u0014J\u0010\u0010\u0012\u001a\u00020\u000f2\u0006\u0010\u0010\u001a\u00020\u0011H\u0014J\b\u0010\u0013\u001a\u00020\u000fH\u0014J\b\u0010\u0014\u001a\u00020\u000fH\u0014R\u000e\u0010\u0003\u001a\u00020\u0004X\u0082\u0004¢\u0006\u0002\n\u0000R$\u0010\n\u001a\u00020\t2\u0006\u0010\b\u001a\u00020\t@FX\u0086\u000e¢\u0006\u000e\n\u0000\u001a\u0004\b\n\u0010\u000b\"\u0004\b\f\u0010\r¨\u0006\u0015"}, d2 = {"Landroidx/activity/OnBackPressedCallback$OnBackPressedEventHandler;", "Landroidx/navigationevent/NavigationEventHandler;", "Landroidx/navigationevent/NavigationEventInfo;", "onBackPressedCallback", "Landroidx/activity/OnBackPressedCallback;", "info", "<init>", "(Landroidx/activity/OnBackPressedCallback;Landroidx/navigationevent/NavigationEventInfo;)V", "value", "", "isLifecycleActive", "()Z", "setLifecycleActive", "(Z)V", "onBackStarted", "", NotificationCompat.CATEGORY_EVENT, "Landroidx/navigationevent/NavigationEvent;", "onBackProgressed", "onBackCompleted", "onBackCancelled", "activity"}, k = 1, mv = {2, 0, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
    public static final class OnBackPressedEventHandler extends NavigationEventHandler<NavigationEventInfo> {
        private boolean isLifecycleActive;
        private final OnBackPressedCallback onBackPressedCallback;

        /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
        public OnBackPressedEventHandler(OnBackPressedCallback onBackPressedCallback, NavigationEventInfo info) {
            super(info, onBackPressedCallback.getIsEnabled());
            Intrinsics.checkNotNullParameter(onBackPressedCallback, "onBackPressedCallback");
            Intrinsics.checkNotNullParameter(info, "info");
            this.onBackPressedCallback = onBackPressedCallback;
            this.isLifecycleActive = true;
        }

        /* JADX INFO: renamed from: isLifecycleActive, reason: from getter */
        public final boolean getIsLifecycleActive() {
            return this.isLifecycleActive;
        }

        public final void setLifecycleActive(boolean z) {
            this.isLifecycleActive = z;
            setBackEnabled(z && this.onBackPressedCallback.getIsEnabled());
        }

        @Override // androidx.navigationevent.NavigationEventHandler
        protected void onBackStarted(NavigationEvent event) {
            Intrinsics.checkNotNullParameter(event, "event");
            this.onBackPressedCallback.handleOnBackStarted(new BackEventCompat(event));
        }

        @Override // androidx.navigationevent.NavigationEventHandler
        protected void onBackProgressed(NavigationEvent event) {
            Intrinsics.checkNotNullParameter(event, "event");
            this.onBackPressedCallback.handleOnBackProgressed(new BackEventCompat(event));
        }

        @Override // androidx.navigationevent.NavigationEventHandler
        protected void onBackCompleted() {
            this.onBackPressedCallback.handleOnBackPressed();
        }

        @Override // androidx.navigationevent.NavigationEventHandler
        protected void onBackCancelled() {
            this.onBackPressedCallback.handleOnBackCancelled();
        }
    }
}
