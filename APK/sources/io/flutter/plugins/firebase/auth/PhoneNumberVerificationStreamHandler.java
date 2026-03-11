package io.flutter.plugins.firebase.auth;

import android.app.Activity;
import com.google.firebase.FirebaseException;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.MultiFactorSession;
import com.google.firebase.auth.PhoneAuthCredential;
import com.google.firebase.auth.PhoneAuthOptions;
import com.google.firebase.auth.PhoneAuthProvider;
import com.google.firebase.auth.PhoneMultiFactorInfo;
import com.tekartik.sqflite.Constant;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth;
import java.util.HashMap;
import java.util.Locale;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

/* JADX INFO: loaded from: classes3.dex */
public class PhoneNumberVerificationStreamHandler implements EventChannel.StreamHandler {
    private static final HashMap<Integer, PhoneAuthProvider.ForceResendingToken> forceResendingTokens = new HashMap<>();
    final AtomicReference<Activity> activityRef;
    String autoRetrievedSmsCodeForTesting;
    private EventChannel.EventSink eventSink;
    final FirebaseAuth firebaseAuth;
    Integer forceResendingToken;
    final PhoneMultiFactorInfo multiFactorInfo;
    final MultiFactorSession multiFactorSession;
    final OnCredentialsListener onCredentialsListener;
    final String phoneNumber;
    final int timeout;

    interface OnCredentialsListener {
        void onCredentialsReceived(PhoneAuthCredential phoneAuthCredential);
    }

    public PhoneNumberVerificationStreamHandler(Activity activity, GeneratedAndroidFirebaseAuth.AuthPigeonFirebaseApp authPigeonFirebaseApp, GeneratedAndroidFirebaseAuth.PigeonVerifyPhoneNumberRequest pigeonVerifyPhoneNumberRequest, MultiFactorSession multiFactorSession, PhoneMultiFactorInfo phoneMultiFactorInfo, OnCredentialsListener onCredentialsListener) {
        AtomicReference<Activity> atomicReference = new AtomicReference<>(null);
        this.activityRef = atomicReference;
        atomicReference.set(activity);
        this.multiFactorSession = multiFactorSession;
        this.multiFactorInfo = phoneMultiFactorInfo;
        this.firebaseAuth = FlutterFirebaseAuthPlugin.getAuthFromPigeon(authPigeonFirebaseApp);
        this.phoneNumber = pigeonVerifyPhoneNumberRequest.getPhoneNumber();
        this.timeout = Math.toIntExact(pigeonVerifyPhoneNumberRequest.getTimeout().longValue());
        if (pigeonVerifyPhoneNumberRequest.getAutoRetrievedSmsCodeForTesting() != null) {
            this.autoRetrievedSmsCodeForTesting = pigeonVerifyPhoneNumberRequest.getAutoRetrievedSmsCodeForTesting();
        }
        if (pigeonVerifyPhoneNumberRequest.getForceResendingToken() != null) {
            this.forceResendingToken = Integer.valueOf(Math.toIntExact(pigeonVerifyPhoneNumberRequest.getForceResendingToken().longValue()));
        }
        this.onCredentialsListener = onCredentialsListener;
    }

    @Override // io.flutter.plugin.common.EventChannel.StreamHandler
    public void onListen(Object obj, EventChannel.EventSink eventSink) {
        PhoneAuthProvider.ForceResendingToken forceResendingToken;
        this.eventSink = eventSink;
        PhoneAuthProvider.OnVerificationStateChangedCallbacks onVerificationStateChangedCallbacks = new PhoneAuthProvider.OnVerificationStateChangedCallbacks() { // from class: io.flutter.plugins.firebase.auth.PhoneNumberVerificationStreamHandler.1
            @Override // com.google.firebase.auth.PhoneAuthProvider.OnVerificationStateChangedCallbacks
            public void onVerificationCompleted(PhoneAuthCredential phoneAuthCredential) {
                int iHashCode = phoneAuthCredential.hashCode();
                PhoneNumberVerificationStreamHandler.this.onCredentialsListener.onCredentialsReceived(phoneAuthCredential);
                HashMap map = new HashMap();
                map.put(Constants.TOKEN, Integer.valueOf(iHashCode));
                if (phoneAuthCredential.getSmsCode() != null) {
                    map.put(Constants.SMS_CODE, phoneAuthCredential.getSmsCode());
                }
                map.put("name", "Auth#phoneVerificationCompleted");
                if (PhoneNumberVerificationStreamHandler.this.eventSink != null) {
                    PhoneNumberVerificationStreamHandler.this.eventSink.success(map);
                }
            }

            @Override // com.google.firebase.auth.PhoneAuthProvider.OnVerificationStateChangedCallbacks
            public void onVerificationFailed(FirebaseException firebaseException) {
                HashMap map = new HashMap();
                HashMap map2 = new HashMap();
                GeneratedAndroidFirebaseAuth.FlutterError flutterError = FlutterFirebaseAuthPluginException.parserExceptionToFlutter(firebaseException);
                map2.put(Constant.PARAM_ERROR_CODE, flutterError.code.replaceAll("ERROR_", "").toLowerCase(Locale.ROOT).replaceAll("_", "-"));
                map2.put("message", flutterError.getMessage());
                map2.put("details", flutterError.details);
                map.put("error", map2);
                map.put("name", "Auth#phoneVerificationFailed");
                if (PhoneNumberVerificationStreamHandler.this.eventSink != null) {
                    PhoneNumberVerificationStreamHandler.this.eventSink.success(map);
                }
            }

            @Override // com.google.firebase.auth.PhoneAuthProvider.OnVerificationStateChangedCallbacks
            public void onCodeSent(String str, PhoneAuthProvider.ForceResendingToken forceResendingToken2) {
                int iHashCode = forceResendingToken2.hashCode();
                PhoneNumberVerificationStreamHandler.forceResendingTokens.put(Integer.valueOf(iHashCode), forceResendingToken2);
                HashMap map = new HashMap();
                map.put(Constants.VERIFICATION_ID, str);
                map.put(Constants.FORCE_RESENDING_TOKEN, Integer.valueOf(iHashCode));
                map.put("name", "Auth#phoneCodeSent");
                if (PhoneNumberVerificationStreamHandler.this.eventSink != null) {
                    PhoneNumberVerificationStreamHandler.this.eventSink.success(map);
                }
            }

            @Override // com.google.firebase.auth.PhoneAuthProvider.OnVerificationStateChangedCallbacks
            public void onCodeAutoRetrievalTimeOut(String str) {
                HashMap map = new HashMap();
                map.put(Constants.VERIFICATION_ID, str);
                map.put("name", "Auth#phoneCodeAutoRetrievalTimeout");
                if (PhoneNumberVerificationStreamHandler.this.eventSink != null) {
                    PhoneNumberVerificationStreamHandler.this.eventSink.success(map);
                }
            }
        };
        if (this.autoRetrievedSmsCodeForTesting != null) {
            this.firebaseAuth.getFirebaseAuthSettings().setAutoRetrievedSmsCodeForPhoneNumber(this.phoneNumber, this.autoRetrievedSmsCodeForTesting);
        }
        PhoneAuthOptions.Builder builder = new PhoneAuthOptions.Builder(this.firebaseAuth);
        builder.setActivity(this.activityRef.get());
        builder.setCallbacks(onVerificationStateChangedCallbacks);
        String str = this.phoneNumber;
        if (str != null) {
            builder.setPhoneNumber(str);
        }
        MultiFactorSession multiFactorSession = this.multiFactorSession;
        if (multiFactorSession != null) {
            builder.setMultiFactorSession(multiFactorSession);
        }
        PhoneMultiFactorInfo phoneMultiFactorInfo = this.multiFactorInfo;
        if (phoneMultiFactorInfo != null) {
            builder.setMultiFactorHint(phoneMultiFactorInfo);
        }
        builder.setTimeout(Long.valueOf(this.timeout), TimeUnit.MILLISECONDS);
        Integer num = this.forceResendingToken;
        if (num != null && (forceResendingToken = forceResendingTokens.get(num)) != null) {
            builder.setForceResendingToken(forceResendingToken);
        }
        PhoneAuthProvider.verifyPhoneNumber(builder.build());
    }

    @Override // io.flutter.plugin.common.EventChannel.StreamHandler
    public void onCancel(Object obj) {
        this.eventSink = null;
        this.activityRef.set(null);
    }
}
