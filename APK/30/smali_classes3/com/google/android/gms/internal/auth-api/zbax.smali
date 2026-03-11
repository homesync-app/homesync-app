.class public final Lcom/google/android/gms/internal/auth-api/zbax;
.super Ljava/lang/Object;
.source "com.google.android.gms:play-services-auth@@21.4.0"


# static fields
.field private static volatile zba:Lcom/google/android/gms/internal/auth-api/zbay;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    new-instance v0, Lcom/google/android/gms/internal/auth-api/zbay;

    invoke-direct {v0}, Lcom/google/android/gms/internal/auth-api/zbay;-><init>()V

    sput-object v0, Lcom/google/android/gms/internal/auth-api/zbax;->zba:Lcom/google/android/gms/internal/auth-api/zbay;

    return-void
.end method

.method public static zba()Lcom/google/android/gms/internal/auth-api/zbay;
    .locals 1

    sget-object v0, Lcom/google/android/gms/internal/auth-api/zbax;->zba:Lcom/google/android/gms/internal/auth-api/zbay;

    return-object v0
.end method
