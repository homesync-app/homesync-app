.class final Lcom/google/android/gms/internal/auth-api/zbbg;
.super Lcom/google/android/gms/internal/auth-api/zbbe;
.source "com.google.android.gms:play-services-auth@@21.4.0"


# instance fields
.field private final zba:Lcom/google/android/gms/internal/auth-api/zbbi;


# direct methods
.method constructor <init>(Lcom/google/android/gms/internal/auth-api/zbbi;I)V
    .locals 1

    .line 1
    invoke-virtual {p1}, Lcom/google/android/gms/internal/auth-api/zbbi;->size()I

    move-result v0

    invoke-direct {p0, v0, p2}, Lcom/google/android/gms/internal/auth-api/zbbe;-><init>(II)V

    iput-object p1, p0, Lcom/google/android/gms/internal/auth-api/zbbg;->zba:Lcom/google/android/gms/internal/auth-api/zbbi;

    return-void
.end method


# virtual methods
.method protected final zba(I)Ljava/lang/Object;
    .locals 1

    .line 1
    iget-object v0, p0, Lcom/google/android/gms/internal/auth-api/zbbg;->zba:Lcom/google/android/gms/internal/auth-api/zbbi;

    invoke-virtual {v0, p1}, Lcom/google/android/gms/internal/auth-api/zbbi;->get(I)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method
