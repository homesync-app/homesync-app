.class final Lcom/google/android/gms/internal/firebase-auth-api/zzabo;
.super Ljava/lang/Object;
.source "com.google.firebase:firebase-auth@@24.0.1"

# interfaces
.implements Lcom/google/android/gms/internal/firebase-auth-api/zzafv;


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Object;",
        "Lcom/google/android/gms/internal/firebase-auth-api/zzafv<",
        "Lcom/google/android/gms/internal/firebase-auth-api/zzajd;",
        ">;"
    }
.end annotation


# instance fields
.field private final synthetic zza:Lcom/google/android/gms/internal/firebase-auth-api/zzael;

.field private final synthetic zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzafv;

.field private final synthetic zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzabl;


# direct methods
.method constructor <init>(Lcom/google/android/gms/internal/firebase-auth-api/zzabl;Lcom/google/android/gms/internal/firebase-auth-api/zzael;Lcom/google/android/gms/internal/firebase-auth-api/zzafv;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 1
    iput-object p2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzabo;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzael;

    iput-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzabo;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzafv;

    invoke-static {p1}, Ljava/util/Objects;->requireNonNull(Ljava/lang/Object;)Ljava/lang/Object;

    iput-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzabo;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzabl;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public final synthetic zza(Ljava/lang/Object;)V
    .locals 2

    .line 4
    check-cast p1, Lcom/google/android/gms/internal/firebase-auth-api/zzajd;

    .line 5
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzabo;->zzc:Lcom/google/android/gms/internal/firebase-auth-api/zzabl;

    iget-object v0, v0, Lcom/google/android/gms/internal/firebase-auth-api/zzabl;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzaar;

    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzabo;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzael;

    invoke-static {v0, p1, v1, p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzaar;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzaar;Lcom/google/android/gms/internal/firebase-auth-api/zzajd;Lcom/google/android/gms/internal/firebase-auth-api/zzael;Lcom/google/android/gms/internal/firebase-auth-api/zzafs;)V

    return-void
.end method

.method public final zza(Ljava/lang/String;)V
    .locals 1

    .line 2
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzabo;->zzb:Lcom/google/android/gms/internal/firebase-auth-api/zzafv;

    invoke-interface {v0, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzafv;->zza(Ljava/lang/String;)V

    return-void
.end method
