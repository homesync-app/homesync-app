.class public final synthetic Lio/flutter/plugins/firebase/auth/FlutterFirebaseAuthUser$$ExternalSyntheticLambda17;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Lcom/google/android/gms/tasks/OnCompleteListener;


# instance fields
.field public final synthetic f$0:Lcom/google/firebase/auth/FirebaseUser;

.field public final synthetic f$1:Lio/flutter/plugins/firebase/auth/GeneratedAndroidFirebaseAuth$Result;


# direct methods
.method public synthetic constructor <init>(Lcom/google/firebase/auth/FirebaseUser;Lio/flutter/plugins/firebase/auth/GeneratedAndroidFirebaseAuth$Result;)V
    .locals 0

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lio/flutter/plugins/firebase/auth/FlutterFirebaseAuthUser$$ExternalSyntheticLambda17;->f$0:Lcom/google/firebase/auth/FirebaseUser;

    iput-object p2, p0, Lio/flutter/plugins/firebase/auth/FlutterFirebaseAuthUser$$ExternalSyntheticLambda17;->f$1:Lio/flutter/plugins/firebase/auth/GeneratedAndroidFirebaseAuth$Result;

    return-void
.end method


# virtual methods
.method public final onComplete(Lcom/google/android/gms/tasks/Task;)V
    .locals 2

    .line 0
    iget-object v0, p0, Lio/flutter/plugins/firebase/auth/FlutterFirebaseAuthUser$$ExternalSyntheticLambda17;->f$0:Lcom/google/firebase/auth/FirebaseUser;

    iget-object v1, p0, Lio/flutter/plugins/firebase/auth/FlutterFirebaseAuthUser$$ExternalSyntheticLambda17;->f$1:Lio/flutter/plugins/firebase/auth/GeneratedAndroidFirebaseAuth$Result;

    invoke-static {v0, v1, p1}, Lio/flutter/plugins/firebase/auth/FlutterFirebaseAuthUser;->lambda$updateProfile$17(Lcom/google/firebase/auth/FirebaseUser;Lio/flutter/plugins/firebase/auth/GeneratedAndroidFirebaseAuth$Result;Lcom/google/android/gms/tasks/Task;)V

    return-void
.end method
