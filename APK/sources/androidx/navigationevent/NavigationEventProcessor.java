package androidx.navigationevent;

import androidx.core.app.NotificationCompat;
import androidx.media3.container.NalUnitUtil;
import androidx.navigationevent.NavigationEventTransitionState;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import kotlin.Metadata;
import kotlin.collections.ArrayDeque;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.internal.Intrinsics;
import kotlinx.coroutines.flow.FlowKt;
import kotlinx.coroutines.flow.MutableStateFlow;
import kotlinx.coroutines.flow.StateFlow;
import kotlinx.coroutines.flow.StateFlowKt;

/* JADX INFO: compiled from: NavigationEventProcessor.kt */
/* JADX INFO: loaded from: classes.dex */
@Metadata(d1 = {"\u0000\u0080\u0001\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0003\n\u0002\u0010\b\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010#\n\u0002\b\u0003\n\u0002\u0010\u000b\n\u0002\b\u0003\n\u0002\u0010\u0002\n\u0002\b\u0005\n\u0002\u0018\u0002\n\u0002\b\b\n\u0002\u0018\u0002\n\u0002\b\u0003\n\u0002\u0018\u0002\n\u0002\b\u0004\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010 \n\u0002\u0018\u0002\n\u0000\b\u0000\u0018\u00002\u00020\u0001B\u0007¢\u0006\u0004\b\u0002\u0010\u0003J\u0006\u0010!\u001a\u00020\"J\u001b\u0010#\u001a\u00020\"2\f\u0010$\u001a\b\u0012\u0002\b\u0003\u0018\u00010\u0011H\u0000¢\u0006\u0002\b%J$\u0010&\u001a\u00020\"2\u0006\u0010'\u001a\u00020(2\n\u0010$\u001a\u0006\u0012\u0002\b\u00030\u00112\b\b\u0002\u0010)\u001a\u00020\u0015J\u0012\u0010*\u001a\u00020\"2\n\u0010$\u001a\u0006\u0012\u0002\b\u00030\u0011J\u001e\u0010+\u001a\u00020\"2\u0006\u0010'\u001a\u00020(2\u0006\u0010,\u001a\u00020\u00182\u0006\u0010)\u001a\u00020\u0015J\u000e\u0010-\u001a\u00020\"2\u0006\u0010,\u001a\u00020\u0018J\"\u0010.\u001a\u00020\"2\u0006\u0010,\u001a\u00020\u00182\u0006\u0010/\u001a\u00020\u00152\n\b\u0002\u00100\u001a\u0004\u0018\u000101J\u001e\u00102\u001a\u00020\"2\u0006\u0010,\u001a\u00020\u00182\u0006\u0010/\u001a\u00020\u00152\u0006\u00100\u001a\u000201J \u00103\u001a\u00020\"2\u0006\u0010,\u001a\u00020\u00182\u0006\u0010/\u001a\u00020\u00152\b\u00104\u001a\u0004\u0018\u000105J\u0016\u00106\u001a\u00020\"2\u0006\u0010,\u001a\u00020\u00182\u0006\u0010/\u001a\u00020\u0015J\u0018\u00107\u001a\b\u0012\u0002\b\u0003\u0018\u00010\u00112\b\b\u0002\u0010/\u001a\u00020\u0015H\u0002J'\u00108\u001a\b\u0012\u0002\b\u0003\u0018\u00010\u00112\u0016\u00109\u001a\u0012\u0012\b\u0012\u0006\u0012\u0002\b\u00030\u0011\u0012\u0004\u0012\u00020\u001e0:H\u0082\bJ\u000e\u0010;\u001a\b\u0012\u0004\u0012\u00020=0<H\u0002R\u0014\u0010\u0004\u001a\b\u0012\u0004\u0012\u00020\u00060\u0005X\u0082\u0004¢\u0006\u0002\n\u0000R\u0017\u0010\u0007\u001a\b\u0012\u0004\u0012\u00020\u00060\b¢\u0006\b\n\u0000\u001a\u0004\b\t\u0010\nR\u0014\u0010\u000b\u001a\b\u0012\u0004\u0012\u00020\f0\u0005X\u0082\u0004¢\u0006\u0002\n\u0000R\u0017\u0010\r\u001a\b\u0012\u0004\u0012\u00020\f0\b¢\u0006\b\n\u0000\u001a\u0004\b\u000e\u0010\nR\u0018\u0010\u000f\u001a\f\u0012\b\u0012\u0006\u0012\u0002\b\u00030\u00110\u0010X\u0082\u0004¢\u0006\u0002\n\u0000R\u0018\u0010\u0012\u001a\f\u0012\b\u0012\u0006\u0012\u0002\b\u00030\u00110\u0010X\u0082\u0004¢\u0006\u0002\n\u0000R\u0014\u0010\u0013\u001a\b\u0012\u0002\b\u0003\u0018\u00010\u0011X\u0082\u000e¢\u0006\u0002\n\u0000R\u0014\u0010\u0014\u001a\u00020\u0015X\u0082\u000e¢\u0006\b\n\u0000\u0012\u0004\b\u0016\u0010\u0003R\u0010\u0010\u0017\u001a\u0004\u0018\u00010\u0018X\u0082\u000e¢\u0006\u0002\n\u0000R\u0014\u0010\u0019\u001a\b\u0012\u0004\u0012\u00020\u00180\u001aX\u0082\u0004¢\u0006\u0002\n\u0000R\u0014\u0010\u001b\u001a\b\u0012\u0004\u0012\u00020\u00180\u001aX\u0082\u0004¢\u0006\u0002\n\u0000R\u0014\u0010\u001c\u001a\b\u0012\u0004\u0012\u00020\u00180\u001aX\u0082\u0004¢\u0006\u0002\n\u0000R\u000e\u0010\u001d\u001a\u00020\u001eX\u0082\u000e¢\u0006\u0002\n\u0000R\u000e\u0010\u001f\u001a\u00020\u001eX\u0082\u000e¢\u0006\u0002\n\u0000R\u000e\u0010 \u001a\u00020\u001eX\u0082\u000e¢\u0006\u0002\n\u0000¨\u0006>"}, d2 = {"Landroidx/navigationevent/NavigationEventProcessor;", "", "<init>", "()V", "_transitionState", "Lkotlinx/coroutines/flow/MutableStateFlow;", "Landroidx/navigationevent/NavigationEventTransitionState;", "transitionState", "Lkotlinx/coroutines/flow/StateFlow;", "getTransitionState", "()Lkotlinx/coroutines/flow/StateFlow;", "_history", "Landroidx/navigationevent/NavigationEventHistory;", "history", "getHistory", "overlayHandlers", "Lkotlin/collections/ArrayDeque;", "Landroidx/navigationevent/NavigationEventHandler;", "defaultHandlers", "inProgressHandler", "inProgressDirection", "", "getInProgressDirection$annotations", "inProgressInput", "Landroidx/navigationevent/NavigationEventInput;", "unspecifiedInputs", "", "defaultInputs", "overlayInputs", "hasEnabledDefaultHandlers", "", "hasEnabledOverlayHandlers", "hasEnabledAnyHandlers", "refreshEnabledHandlers", "", "updateEnabledHandlerInfo", "handler", "updateEnabledHandlerInfo$navigationevent", "addHandler", "dispatcher", "Landroidx/navigationevent/NavigationEventDispatcher;", "priority", "removeHandler", "addInput", "input", "removeInput", "dispatchOnStarted", "direction", NotificationCompat.CATEGORY_EVENT, "Landroidx/navigationevent/NavigationEvent;", "dispatchOnProgressed", "dispatchOnCompleted", "onBackCompletedFallback", "Landroidx/navigationevent/OnBackCompletedFallback;", "dispatchOnCancelled", "resolveEnabledHandler", "findHandler", "predicate", "Lkotlin/Function1;", "resolveCombinedBackInfo", "", "Landroidx/navigationevent/NavigationEventInfo;", "navigationevent"}, k = 1, mv = {2, 0, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final class NavigationEventProcessor {
    private final MutableStateFlow<NavigationEventHistory> _history;
    private final MutableStateFlow<NavigationEventTransitionState> _transitionState;
    private final ArrayDeque<NavigationEventHandler<?>> defaultHandlers;
    private final Set<NavigationEventInput> defaultInputs;
    private boolean hasEnabledAnyHandlers;
    private boolean hasEnabledDefaultHandlers;
    private boolean hasEnabledOverlayHandlers;
    private final StateFlow<NavigationEventHistory> history;
    private int inProgressDirection;
    private NavigationEventHandler<?> inProgressHandler;
    private NavigationEventInput inProgressInput;
    private final ArrayDeque<NavigationEventHandler<?>> overlayHandlers;
    private final Set<NavigationEventInput> overlayInputs;
    private final StateFlow<NavigationEventTransitionState> transitionState;
    private final Set<NavigationEventInput> unspecifiedInputs;

    private static /* synthetic */ void getInProgressDirection$annotations() {
    }

    public NavigationEventProcessor() {
        MutableStateFlow<NavigationEventTransitionState> MutableStateFlow = StateFlowKt.MutableStateFlow(NavigationEventTransitionState.Idle.INSTANCE);
        this._transitionState = MutableStateFlow;
        this.transitionState = FlowKt.asStateFlow(MutableStateFlow);
        MutableStateFlow<NavigationEventHistory> MutableStateFlow2 = StateFlowKt.MutableStateFlow(new NavigationEventHistory());
        this._history = MutableStateFlow2;
        this.history = FlowKt.asStateFlow(MutableStateFlow2);
        this.overlayHandlers = new ArrayDeque<>();
        this.defaultHandlers = new ArrayDeque<>();
        this.unspecifiedInputs = new LinkedHashSet();
        this.defaultInputs = new LinkedHashSet();
        this.overlayInputs = new LinkedHashSet();
    }

    public final StateFlow<NavigationEventTransitionState> getTransitionState() {
        return this.transitionState;
    }

    public final StateFlow<NavigationEventHistory> getHistory() {
        return this.history;
    }

    public final void refreshEnabledHandlers() {
        boolean z;
        boolean z2;
        ArrayDeque<NavigationEventHandler<?>> arrayDeque = this.overlayHandlers;
        if ((arrayDeque instanceof Collection) && arrayDeque.isEmpty()) {
            z = false;
        } else {
            for (NavigationEventHandler<?> navigationEventHandler : arrayDeque) {
                if (navigationEventHandler.isBackEnabled() || navigationEventHandler.isForwardEnabled()) {
                    z = true;
                    break;
                }
            }
            z = false;
        }
        ArrayDeque<NavigationEventHandler<?>> arrayDeque2 = this.defaultHandlers;
        if ((arrayDeque2 instanceof Collection) && arrayDeque2.isEmpty()) {
            z2 = false;
        } else {
            for (NavigationEventHandler<?> navigationEventHandler2 : arrayDeque2) {
                if (navigationEventHandler2.isBackEnabled() || navigationEventHandler2.isForwardEnabled()) {
                    z2 = true;
                    break;
                }
            }
            z2 = false;
        }
        boolean z3 = z || z2;
        boolean z4 = this.hasEnabledOverlayHandlers != z;
        boolean z5 = this.hasEnabledDefaultHandlers != z2;
        boolean z6 = this.hasEnabledAnyHandlers != z3;
        if (z4) {
            Iterator<NavigationEventInput> it = this.overlayInputs.iterator();
            while (it.hasNext()) {
                it.next().doOnHasEnabledHandlersChanged$navigationevent(z);
            }
        }
        if (z5) {
            Iterator<NavigationEventInput> it2 = this.defaultInputs.iterator();
            while (it2.hasNext()) {
                it2.next().doOnHasEnabledHandlersChanged$navigationevent(z2);
            }
        }
        if (z6) {
            Iterator<NavigationEventInput> it3 = this.unspecifiedInputs.iterator();
            while (it3.hasNext()) {
                it3.next().doOnHasEnabledHandlersChanged$navigationevent(z3);
            }
        }
        this.hasEnabledOverlayHandlers = z;
        this.hasEnabledDefaultHandlers = z2;
        this.hasEnabledAnyHandlers = z3;
        NavigationEventHandler<?> navigationEventHandlerResolveEnabledHandler$default = this.inProgressHandler;
        if (navigationEventHandlerResolveEnabledHandler$default == null) {
            navigationEventHandlerResolveEnabledHandler$default = resolveEnabledHandler$default(this, 0, 1, null);
        }
        updateEnabledHandlerInfo$navigationevent(navigationEventHandlerResolveEnabledHandler$default);
    }

    public final void updateEnabledHandlerInfo$navigationevent(NavigationEventHandler<?> handler) {
        NavigationEventHistory navigationEventHistory;
        NavigationEventHandler<?> navigationEventHandlerResolveEnabledHandler$default = this.inProgressHandler;
        if (navigationEventHandlerResolveEnabledHandler$default == null) {
            navigationEventHandlerResolveEnabledHandler$default = resolveEnabledHandler$default(this, 0, 1, null);
        }
        if (Intrinsics.areEqual(navigationEventHandlerResolveEnabledHandler$default, handler)) {
            if (navigationEventHandlerResolveEnabledHandler$default == null) {
                navigationEventHistory = new NavigationEventHistory();
            } else {
                navigationEventHistory = new NavigationEventHistory(navigationEventHandlerResolveEnabledHandler$default.getCurrentInfo(), resolveCombinedBackInfo(), navigationEventHandlerResolveEnabledHandler$default.getForwardInfo());
            }
            if (Intrinsics.areEqual(this._history.getValue(), navigationEventHistory)) {
                return;
            }
            this._history.setValue(navigationEventHistory);
            Iterator<NavigationEventInput> it = this.overlayInputs.iterator();
            while (it.hasNext()) {
                it.next().doOnHistoryChanged$navigationevent(navigationEventHistory);
            }
            Iterator<NavigationEventInput> it2 = this.defaultInputs.iterator();
            while (it2.hasNext()) {
                it2.next().doOnHistoryChanged$navigationevent(navigationEventHistory);
            }
            Iterator<NavigationEventInput> it3 = this.unspecifiedInputs.iterator();
            while (it3.hasNext()) {
                it3.next().doOnHistoryChanged$navigationevent(navigationEventHistory);
            }
        }
    }

    public static /* synthetic */ void addHandler$default(NavigationEventProcessor navigationEventProcessor, NavigationEventDispatcher navigationEventDispatcher, NavigationEventHandler navigationEventHandler, int i, int i2, Object obj) {
        if ((i2 & 4) != 0) {
            i = 1;
        }
        navigationEventProcessor.addHandler(navigationEventDispatcher, navigationEventHandler, i);
    }

    public final void addHandler(NavigationEventDispatcher dispatcher, NavigationEventHandler<?> handler, int priority) {
        Intrinsics.checkNotNullParameter(dispatcher, "dispatcher");
        Intrinsics.checkNotNullParameter(handler, "handler");
        if (handler.getDispatcher() != null) {
            throw new IllegalArgumentException(("Handler '" + handler + "' is already registered with a dispatcher").toString());
        }
        if (priority == 0) {
            this.overlayHandlers.addFirst(handler);
        } else if (priority == 1) {
            this.defaultHandlers.addFirst(handler);
        } else {
            throw new IllegalArgumentException("Unsupported priority value: " + priority);
        }
        handler.setDispatcher$navigationevent(dispatcher);
        refreshEnabledHandlers();
    }

    public final void removeHandler(NavigationEventHandler<?> handler) {
        Intrinsics.checkNotNullParameter(handler, "handler");
        if (Intrinsics.areEqual(handler, this.inProgressHandler)) {
            int i = this.inProgressDirection;
            if (i == -1) {
                handler.doOnBackCancelled$navigationevent();
            } else if (i == 1) {
                handler.doOnForwardCancelled$navigationevent();
            }
            this.inProgressHandler = null;
            this.inProgressDirection = 0;
            this.inProgressInput = null;
        }
        this.overlayHandlers.remove(handler);
        this.defaultHandlers.remove(handler);
        handler.setDispatcher$navigationevent(null);
        refreshEnabledHandlers();
    }

    public final void addInput(NavigationEventDispatcher dispatcher, NavigationEventInput input, int priority) {
        Set<NavigationEventInput> set;
        boolean z;
        Intrinsics.checkNotNullParameter(dispatcher, "dispatcher");
        Intrinsics.checkNotNullParameter(input, "input");
        if (input.getDispatcher() != null) {
            throw new IllegalArgumentException(("Input '" + input + "' is already added to dispatcher " + input.getDispatcher() + '.').toString());
        }
        if (priority == 0) {
            set = this.overlayInputs;
        } else if (priority == 1) {
            set = this.defaultInputs;
        } else {
            set = this.unspecifiedInputs;
        }
        set.add(input);
        input.setDispatcher$navigationevent(dispatcher);
        input.doOnAdded$navigationevent(dispatcher);
        input.doOnHistoryChanged$navigationevent(this.history.getValue());
        if (priority == 0) {
            z = this.hasEnabledOverlayHandlers;
        } else if (priority == 1) {
            z = this.hasEnabledDefaultHandlers;
        } else {
            z = this.hasEnabledAnyHandlers;
        }
        input.doOnHasEnabledHandlersChanged$navigationevent(z);
    }

    public final void removeInput(NavigationEventInput input) {
        Intrinsics.checkNotNullParameter(input, "input");
        this.overlayInputs.remove(input);
        this.defaultInputs.remove(input);
        this.unspecifiedInputs.remove(input);
        input.setDispatcher$navigationevent(null);
        input.doOnRemoved$navigationevent();
    }

    public static /* synthetic */ void dispatchOnStarted$default(NavigationEventProcessor navigationEventProcessor, NavigationEventInput navigationEventInput, int i, NavigationEvent navigationEvent, int i2, Object obj) {
        if ((i2 & 4) != 0) {
            navigationEvent = null;
        }
        navigationEventProcessor.dispatchOnStarted(navigationEventInput, i, navigationEvent);
    }

    public final void dispatchOnStarted(NavigationEventInput input, int direction, NavigationEvent event) {
        Intrinsics.checkNotNullParameter(input, "input");
        if (this.inProgressDirection != 0) {
            return;
        }
        NavigationEventHandler<?> navigationEventHandlerResolveEnabledHandler = resolveEnabledHandler(direction);
        this.inProgressHandler = navigationEventHandlerResolveEnabledHandler;
        this.inProgressDirection = direction;
        this.inProgressInput = input;
        if (event != null) {
            if (direction != -1) {
                if (direction == 1 && navigationEventHandlerResolveEnabledHandler != null) {
                    navigationEventHandlerResolveEnabledHandler.doOnForwardStarted$navigationevent(event);
                }
            } else if (navigationEventHandlerResolveEnabledHandler != null) {
                navigationEventHandlerResolveEnabledHandler.doOnBackStarted$navigationevent(event);
            }
            this._transitionState.setValue(new NavigationEventTransitionState.InProgress(event, direction));
        }
    }

    public final void dispatchOnProgressed(NavigationEventInput input, int direction, NavigationEvent event) {
        Intrinsics.checkNotNullParameter(input, "input");
        Intrinsics.checkNotNullParameter(event, "event");
        if (Intrinsics.areEqual(input, this.inProgressInput) && direction == this.inProgressDirection) {
            NavigationEventHandler<?> navigationEventHandlerResolveEnabledHandler = this.inProgressHandler;
            if (navigationEventHandlerResolveEnabledHandler == null) {
                navigationEventHandlerResolveEnabledHandler = resolveEnabledHandler(direction);
            }
            if (direction != -1) {
                if (direction == 1 && navigationEventHandlerResolveEnabledHandler != null) {
                    navigationEventHandlerResolveEnabledHandler.doOnForwardProgressed$navigationevent(event);
                }
            } else if (navigationEventHandlerResolveEnabledHandler != null) {
                navigationEventHandlerResolveEnabledHandler.doOnBackProgressed$navigationevent(event);
            }
            this._transitionState.setValue(new NavigationEventTransitionState.InProgress(event, direction));
        }
    }

    public final void dispatchOnCompleted(NavigationEventInput input, int direction, OnBackCompletedFallback onBackCompletedFallback) {
        Intrinsics.checkNotNullParameter(input, "input");
        if (Intrinsics.areEqual(input, this.inProgressInput) && direction == this.inProgressDirection) {
            NavigationEventHandler<?> navigationEventHandlerResolveEnabledHandler = this.inProgressHandler;
            if (navigationEventHandlerResolveEnabledHandler == null) {
                navigationEventHandlerResolveEnabledHandler = resolveEnabledHandler(direction);
            }
            this.inProgressHandler = null;
            this.inProgressDirection = 0;
            this.inProgressInput = null;
            if (direction != -1) {
                if (direction == 1 && navigationEventHandlerResolveEnabledHandler != null) {
                    navigationEventHandlerResolveEnabledHandler.doOnForwardCompleted$navigationevent();
                }
            } else if (navigationEventHandlerResolveEnabledHandler != null) {
                navigationEventHandlerResolveEnabledHandler.doOnBackCompleted$navigationevent();
            } else if (onBackCompletedFallback != null) {
                onBackCompletedFallback.onBackCompletedFallback();
            }
            this._transitionState.setValue(NavigationEventTransitionState.Idle.INSTANCE);
        }
    }

    public final void dispatchOnCancelled(NavigationEventInput input, int direction) {
        Intrinsics.checkNotNullParameter(input, "input");
        if (Intrinsics.areEqual(input, this.inProgressInput) && direction == this.inProgressDirection) {
            NavigationEventHandler<?> navigationEventHandlerResolveEnabledHandler = this.inProgressHandler;
            if (navigationEventHandlerResolveEnabledHandler == null) {
                navigationEventHandlerResolveEnabledHandler = resolveEnabledHandler(direction);
            }
            this.inProgressHandler = null;
            this.inProgressDirection = 0;
            this.inProgressInput = null;
            if (direction != -1) {
                if (direction == 1 && navigationEventHandlerResolveEnabledHandler != null) {
                    navigationEventHandlerResolveEnabledHandler.doOnForwardCancelled$navigationevent();
                }
            } else if (navigationEventHandlerResolveEnabledHandler != null) {
                navigationEventHandlerResolveEnabledHandler.doOnBackCancelled$navigationevent();
            }
            this._transitionState.setValue(NavigationEventTransitionState.Idle.INSTANCE);
        }
    }

    static /* synthetic */ NavigationEventHandler resolveEnabledHandler$default(NavigationEventProcessor navigationEventProcessor, int i, int i2, Object obj) {
        if ((i2 & 1) != 0) {
            i = 0;
        }
        return navigationEventProcessor.resolveEnabledHandler(i);
    }

    private final NavigationEventHandler<?> findHandler(Function1<? super NavigationEventHandler<?>, Boolean> predicate) {
        NavigationEventHandler<?> navigationEventHandler;
        NavigationEventHandler<?> next;
        Iterator<NavigationEventHandler<?>> it = this.overlayHandlers.iterator();
        while (true) {
            navigationEventHandler = null;
            if (!it.hasNext()) {
                next = null;
                break;
            }
            next = it.next();
            if (predicate.invoke(next).booleanValue()) {
                break;
            }
        }
        NavigationEventHandler<?> navigationEventHandler2 = next;
        if (navigationEventHandler2 != null) {
            return navigationEventHandler2;
        }
        Iterator<NavigationEventHandler<?>> it2 = this.defaultHandlers.iterator();
        while (true) {
            if (!it2.hasNext()) {
                break;
            }
            NavigationEventHandler<?> next2 = it2.next();
            if (predicate.invoke(next2).booleanValue()) {
                navigationEventHandler = next2;
                break;
            }
        }
        return navigationEventHandler;
    }

    private final List<NavigationEventInfo> resolveCombinedBackInfo() {
        ArrayList arrayList = new ArrayList();
        Iterator it = this.overlayHandlers.iterator();
        while (it.hasNext()) {
            NavigationEventHandler navigationEventHandler = (NavigationEventHandler) it.next();
            if (navigationEventHandler.isBackEnabled() && !navigationEventHandler.getBackInfo().isEmpty()) {
                arrayList.addAll(navigationEventHandler.getBackInfo());
            }
        }
        Iterator it2 = this.defaultHandlers.iterator();
        while (it2.hasNext()) {
            NavigationEventHandler navigationEventHandler2 = (NavigationEventHandler) it2.next();
            if (navigationEventHandler2.isBackEnabled() && !navigationEventHandler2.getBackInfo().isEmpty()) {
                arrayList.addAll(navigationEventHandler2.getBackInfo());
            }
        }
        return arrayList;
    }

    private final NavigationEventHandler<?> resolveEnabledHandler(int direction) {
        NavigationEventHandler<?> next;
        NavigationEventHandler<?> next2;
        NavigationEventHandler<?> next3;
        NavigationEventHandler<?> navigationEventHandler = null;
        if (direction == -1) {
            Iterator<NavigationEventHandler<?>> it = this.overlayHandlers.iterator();
            while (true) {
                if (!it.hasNext()) {
                    next = null;
                    break;
                }
                next = it.next();
                if (next.isBackEnabled()) {
                    break;
                }
            }
            NavigationEventHandler<?> navigationEventHandler2 = next;
            if (navigationEventHandler2 != null) {
                return navigationEventHandler2;
            }
            Iterator<NavigationEventHandler<?>> it2 = this.defaultHandlers.iterator();
            while (true) {
                if (!it2.hasNext()) {
                    break;
                }
                NavigationEventHandler<?> next4 = it2.next();
                if (next4.isBackEnabled()) {
                    navigationEventHandler = next4;
                    break;
                }
            }
            return navigationEventHandler;
        }
        if (direction != 0) {
            if (direction != 1) {
                throw new IllegalStateException(("Unsupported direction: '" + direction + "'.").toString());
            }
            Iterator<NavigationEventHandler<?>> it3 = this.overlayHandlers.iterator();
            while (true) {
                if (!it3.hasNext()) {
                    next3 = null;
                    break;
                }
                next3 = it3.next();
                if (next3.isForwardEnabled()) {
                    break;
                }
            }
            NavigationEventHandler<?> navigationEventHandler3 = next3;
            if (navigationEventHandler3 != null) {
                return navigationEventHandler3;
            }
            Iterator<NavigationEventHandler<?>> it4 = this.defaultHandlers.iterator();
            while (true) {
                if (!it4.hasNext()) {
                    break;
                }
                NavigationEventHandler<?> next5 = it4.next();
                if (next5.isForwardEnabled()) {
                    navigationEventHandler = next5;
                    break;
                }
            }
            return navigationEventHandler;
        }
        Iterator<NavigationEventHandler<?>> it5 = this.overlayHandlers.iterator();
        while (true) {
            if (!it5.hasNext()) {
                next2 = null;
                break;
            }
            next2 = it5.next();
            NavigationEventHandler<?> navigationEventHandler4 = next2;
            if (navigationEventHandler4.isBackEnabled() || navigationEventHandler4.isForwardEnabled()) {
                break;
            }
        }
        NavigationEventHandler<?> navigationEventHandler5 = next2;
        if (navigationEventHandler5 != null) {
            return navigationEventHandler5;
        }
        for (NavigationEventHandler<?> navigationEventHandler6 : this.defaultHandlers) {
            NavigationEventHandler<?> navigationEventHandler7 = navigationEventHandler6;
            if (navigationEventHandler7.isBackEnabled() || navigationEventHandler7.isForwardEnabled()) {
                navigationEventHandler = navigationEventHandler6;
                break;
            }
        }
        return navigationEventHandler;
    }
}
