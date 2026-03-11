package io.flutter.plugins.firebase.auth;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import io.flutter.plugin.common.EventChannel;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

/* JADX INFO: loaded from: classes3.dex */
public class AuthStateChannelStreamHandler implements EventChannel.StreamHandler {
    private FirebaseAuth.AuthStateListener authStateListener;
    private final FirebaseAuth firebaseAuth;

    public AuthStateChannelStreamHandler(FirebaseAuth firebaseAuth) {
        this.firebaseAuth = firebaseAuth;
    }

    @Override // io.flutter.plugin.common.EventChannel.StreamHandler
    public void onListen(Object obj, final EventChannel.EventSink eventSink) {
        final HashMap map = new HashMap();
        map.put(Constants.APP_NAME, this.firebaseAuth.getApp().getName());
        final AtomicBoolean atomicBoolean = new AtomicBoolean(true);
        FirebaseAuth.AuthStateListener authStateListener = new FirebaseAuth.AuthStateListener() { // from class: io.flutter.plugins.firebase.auth.AuthStateChannelStreamHandler$$ExternalSyntheticLambda0
            @Override // com.google.firebase.auth.FirebaseAuth.AuthStateListener
            public final void onAuthStateChanged(FirebaseAuth firebaseAuth) {
                AuthStateChannelStreamHandler.lambda$onListen$0(atomicBoolean, map, eventSink, firebaseAuth);
            }
        };
        this.authStateListener = authStateListener;
        this.firebaseAuth.addAuthStateListener(authStateListener);
    }

    static /* synthetic */ void lambda$onListen$0(AtomicBoolean atomicBoolean, Map map, EventChannel.EventSink eventSink, FirebaseAuth firebaseAuth) {
        if (atomicBoolean.get()) {
            atomicBoolean.set(false);
            return;
        }
        FirebaseUser currentUser = firebaseAuth.getCurrentUser();
        if (currentUser == null) {
            map.put(Constants.USER, null);
        } else {
            map.put(Constants.USER, PigeonParser.manuallyToList(PigeonParser.parseFirebaseUser(currentUser)));
        }
        eventSink.success(map);
    }

    @Override // io.flutter.plugin.common.EventChannel.StreamHandler
    public void onCancel(Object obj) {
        FirebaseAuth.AuthStateListener authStateListener = this.authStateListener;
        if (authStateListener != null) {
            this.firebaseAuth.removeAuthStateListener(authStateListener);
            this.authStateListener = null;
        }
    }
}
