.class public Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;
.super Ljava/lang/Object;
.source "PhoneNumberVerificationStreamHandler.java"

# interfaces
.implements Lio/flutter/plugin/common/EventChannel$StreamHandler;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler$OnCredentialsListener;
    }
.end annotation


# static fields
.field private static final forceResendingTokens:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap<",
            "Ljava/lang/Integer;",
            "Lcom/google/firebase/auth/PhoneAuthProvider$ForceResendingToken;",
            ">;"
        }
    .end annotation
.end field


# instance fields
.field final activityRef:Ljava/util/concurrent/atomic/AtomicReference;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/concurrent/atomic/AtomicReference<",
            "Landroid/app/Activity;",
            ">;"
        }
    .end annotation
.end field

.field autoRetrievedSmsCodeForTesting:Ljava/lang/String;

.field private eventSink:Lio/flutter/plugin/common/EventChannel$EventSink;

.field final firebaseAuth:Lcom/google/firebase/auth/FirebaseAuth;

.field forceResendingToken:Ljava/lang/Integer;

.field final multiFactorInfo:Lcom/google/firebase/auth/PhoneMultiFactorInfo;

.field final multiFactorSession:Lcom/google/firebase/auth/MultiFactorSession;

.field final onCredentialsListener:Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler$OnCredentialsListener;

.field final phoneNumber:Ljava/lang/String;

.field final timeout:I


# direct methods
.method static bridge synthetic -$$Nest$fgeteventSink(Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;)Lio/flutter/plugin/common/EventChannel$EventSink;
    .locals 0

    iget-object p0, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->eventSink:Lio/flutter/plugin/common/EventChannel$EventSink;

    return-object p0
.end method

.method static bridge synthetic -$$Nest$sfgetforceResendingTokens()Ljava/util/HashMap;
    .locals 1

    sget-object v0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->forceResendingTokens:Ljava/util/HashMap;

    return-object v0
.end method

.method static constructor <clinit>()V
    .locals 1

    .line 46
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sput-object v0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->forceResendingTokens:Ljava/util/HashMap;

    return-void
.end method

.method public constructor <init>(Landroid/app/Activity;Lio/flutter/plugins/firebase/auth/GeneratedAndroidFirebaseAuth$AuthPigeonFirebaseApp;Lio/flutter/plugins/firebase/auth/GeneratedAndroidFirebaseAuth$PigeonVerifyPhoneNumberRequest;Lcom/google/firebase/auth/MultiFactorSession;Lcom/google/firebase/auth/PhoneMultiFactorInfo;Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler$OnCredentialsListener;)V
    .locals 2

    .line 56
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 34
    new-instance v0, Ljava/util/concurrent/atomic/AtomicReference;

    const/4 v1, 0x0

    invoke-direct {v0, v1}, Ljava/util/concurrent/atomic/AtomicReference;-><init>(Ljava/lang/Object;)V

    iput-object v0, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->activityRef:Ljava/util/concurrent/atomic/AtomicReference;

    .line 57
    invoke-virtual {v0, p1}, Ljava/util/concurrent/atomic/AtomicReference;->set(Ljava/lang/Object;)V

    .line 59
    iput-object p4, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->multiFactorSession:Lcom/google/firebase/auth/MultiFactorSession;

    .line 60
    iput-object p5, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->multiFactorInfo:Lcom/google/firebase/auth/PhoneMultiFactorInfo;

    .line 61
    invoke-static {p2}, Lio/flutter/plugins/firebase/auth/FlutterFirebaseAuthPlugin;->getAuthFromPigeon(Lio/flutter/plugins/firebase/auth/GeneratedAndroidFirebaseAuth$AuthPigeonFirebaseApp;)Lcom/google/firebase/auth/FirebaseAuth;

    move-result-object p1

    iput-object p1, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->firebaseAuth:Lcom/google/firebase/auth/FirebaseAuth;

    .line 62
    invoke-virtual {p3}, Lio/flutter/plugins/firebase/auth/GeneratedAndroidFirebaseAuth$PigeonVerifyPhoneNumberRequest;->getPhoneNumber()Ljava/lang/String;

    move-result-object p1

    iput-object p1, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->phoneNumber:Ljava/lang/String;

    .line 63
    invoke-virtual {p3}, Lio/flutter/plugins/firebase/auth/GeneratedAndroidFirebaseAuth$PigeonVerifyPhoneNumberRequest;->getTimeout()Ljava/lang/Long;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/Long;->longValue()J

    move-result-wide p1

    invoke-static {p1, p2}, Ljava/lang/Math;->toIntExact(J)I

    move-result p1

    iput p1, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->timeout:I

    .line 65
    invoke-virtual {p3}, Lio/flutter/plugins/firebase/auth/GeneratedAndroidFirebaseAuth$PigeonVerifyPhoneNumberRequest;->getAutoRetrievedSmsCodeForTesting()Ljava/lang/String;

    move-result-object p1

    if-eqz p1, :cond_0

    .line 66
    invoke-virtual {p3}, Lio/flutter/plugins/firebase/auth/GeneratedAndroidFirebaseAuth$PigeonVerifyPhoneNumberRequest;->getAutoRetrievedSmsCodeForTesting()Ljava/lang/String;

    move-result-object p1

    iput-object p1, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->autoRetrievedSmsCodeForTesting:Ljava/lang/String;

    .line 69
    :cond_0
    invoke-virtual {p3}, Lio/flutter/plugins/firebase/auth/GeneratedAndroidFirebaseAuth$PigeonVerifyPhoneNumberRequest;->getForceResendingToken()Ljava/lang/Long;

    move-result-object p1

    if-eqz p1, :cond_1

    .line 70
    invoke-virtual {p3}, Lio/flutter/plugins/firebase/auth/GeneratedAndroidFirebaseAuth$PigeonVerifyPhoneNumberRequest;->getForceResendingToken()Ljava/lang/Long;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/Long;->longValue()J

    move-result-wide p1

    invoke-static {p1, p2}, Ljava/lang/Math;->toIntExact(J)I

    move-result p1

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    iput-object p1, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->forceResendingToken:Ljava/lang/Integer;

    .line 73
    :cond_1
    iput-object p6, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->onCredentialsListener:Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler$OnCredentialsListener;

    return-void
.end method


# virtual methods
.method public onCancel(Ljava/lang/Object;)V
    .locals 1

    const/4 p1, 0x0

    .line 193
    iput-object p1, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->eventSink:Lio/flutter/plugin/common/EventChannel$EventSink;

    .line 195
    iget-object v0, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->activityRef:Ljava/util/concurrent/atomic/AtomicReference;

    invoke-virtual {v0, p1}, Ljava/util/concurrent/atomic/AtomicReference;->set(Ljava/lang/Object;)V

    return-void
.end method

.method public onListen(Ljava/lang/Object;Lio/flutter/plugin/common/EventChannel$EventSink;)V
    .locals 2

    .line 78
    iput-object p2, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->eventSink:Lio/flutter/plugin/common/EventChannel$EventSink;

    .line 80
    new-instance p1, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler$1;

    invoke-direct {p1, p0}, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler$1;-><init>(Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;)V

    .line 158
    iget-object p2, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->autoRetrievedSmsCodeForTesting:Ljava/lang/String;

    if-eqz p2, :cond_0

    .line 159
    iget-object p2, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->firebaseAuth:Lcom/google/firebase/auth/FirebaseAuth;

    .line 160
    invoke-virtual {p2}, Lcom/google/firebase/auth/FirebaseAuth;->getFirebaseAuthSettings()Lcom/google/firebase/auth/FirebaseAuthSettings;

    move-result-object p2

    iget-object v0, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->phoneNumber:Ljava/lang/String;

    iget-object v1, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->autoRetrievedSmsCodeForTesting:Ljava/lang/String;

    .line 161
    invoke-virtual {p2, v0, v1}, Lcom/google/firebase/auth/FirebaseAuthSettings;->setAutoRetrievedSmsCodeForPhoneNumber(Ljava/lang/String;Ljava/lang/String;)V

    .line 164
    :cond_0
    new-instance p2, Lcom/google/firebase/auth/PhoneAuthOptions$Builder;

    iget-object v0, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->firebaseAuth:Lcom/google/firebase/auth/FirebaseAuth;

    invoke-direct {p2, v0}, Lcom/google/firebase/auth/PhoneAuthOptions$Builder;-><init>(Lcom/google/firebase/auth/FirebaseAuth;)V

    .line 165
    iget-object v0, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->activityRef:Ljava/util/concurrent/atomic/AtomicReference;

    invoke-virtual {v0}, Ljava/util/concurrent/atomic/AtomicReference;->get()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/app/Activity;

    invoke-virtual {p2, v0}, Lcom/google/firebase/auth/PhoneAuthOptions$Builder;->setActivity(Landroid/app/Activity;)Lcom/google/firebase/auth/PhoneAuthOptions$Builder;

    .line 166
    invoke-virtual {p2, p1}, Lcom/google/firebase/auth/PhoneAuthOptions$Builder;->setCallbacks(Lcom/google/firebase/auth/PhoneAuthProvider$OnVerificationStateChangedCallbacks;)Lcom/google/firebase/auth/PhoneAuthOptions$Builder;

    .line 168
    iget-object p1, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->phoneNumber:Ljava/lang/String;

    if-eqz p1, :cond_1

    .line 169
    invoke-virtual {p2, p1}, Lcom/google/firebase/auth/PhoneAuthOptions$Builder;->setPhoneNumber(Ljava/lang/String;)Lcom/google/firebase/auth/PhoneAuthOptions$Builder;

    .line 171
    :cond_1
    iget-object p1, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->multiFactorSession:Lcom/google/firebase/auth/MultiFactorSession;

    if-eqz p1, :cond_2

    .line 172
    invoke-virtual {p2, p1}, Lcom/google/firebase/auth/PhoneAuthOptions$Builder;->setMultiFactorSession(Lcom/google/firebase/auth/MultiFactorSession;)Lcom/google/firebase/auth/PhoneAuthOptions$Builder;

    .line 174
    :cond_2
    iget-object p1, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->multiFactorInfo:Lcom/google/firebase/auth/PhoneMultiFactorInfo;

    if-eqz p1, :cond_3

    .line 175
    invoke-virtual {p2, p1}, Lcom/google/firebase/auth/PhoneAuthOptions$Builder;->setMultiFactorHint(Lcom/google/firebase/auth/PhoneMultiFactorInfo;)Lcom/google/firebase/auth/PhoneAuthOptions$Builder;

    .line 177
    :cond_3
    iget p1, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->timeout:I

    int-to-long v0, p1

    invoke-static {v0, v1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object p1

    sget-object v0, Ljava/util/concurrent/TimeUnit;->MILLISECONDS:Ljava/util/concurrent/TimeUnit;

    invoke-virtual {p2, p1, v0}, Lcom/google/firebase/auth/PhoneAuthOptions$Builder;->setTimeout(Ljava/lang/Long;Ljava/util/concurrent/TimeUnit;)Lcom/google/firebase/auth/PhoneAuthOptions$Builder;

    .line 179
    iget-object p1, p0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->forceResendingToken:Ljava/lang/Integer;

    if-eqz p1, :cond_4

    .line 180
    sget-object v0, Lio/flutter/plugins/firebase/auth/PhoneNumberVerificationStreamHandler;->forceResendingTokens:Ljava/util/HashMap;

    .line 181
    invoke-virtual {v0, p1}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Lcom/google/firebase/auth/PhoneAuthProvider$ForceResendingToken;

    if-eqz p1, :cond_4

    .line 184
    invoke-virtual {p2, p1}, Lcom/google/firebase/auth/PhoneAuthOptions$Builder;->setForceResendingToken(Lcom/google/firebase/auth/PhoneAuthProvider$ForceResendingToken;)Lcom/google/firebase/auth/PhoneAuthOptions$Builder;

    .line 188
    :cond_4
    invoke-virtual {p2}, Lcom/google/firebase/auth/PhoneAuthOptions$Builder;->build()Lcom/google/firebase/auth/PhoneAuthOptions;

    move-result-object p1

    invoke-static {p1}, Lcom/google/firebase/auth/PhoneAuthProvider;->verifyPhoneNumber(Lcom/google/firebase/auth/PhoneAuthOptions;)V

    return-void
.end method
