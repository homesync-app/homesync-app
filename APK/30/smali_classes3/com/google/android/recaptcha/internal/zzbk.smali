.class public final Lcom/google/android/recaptcha/internal/zzbk;
.super Ljava/lang/Object;
.source "com.google.android.recaptcha:recaptcha@@18.6.1"


# static fields
.field public static final synthetic zza:I

.field private static final zzb:Ljava/util/concurrent/ConcurrentHashMap;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .line 1
    new-instance v0, Ljava/util/concurrent/ConcurrentHashMap;

    invoke-direct {v0}, Ljava/util/concurrent/ConcurrentHashMap;-><init>()V

    sput-object v0, Lcom/google/android/recaptcha/internal/zzbk;->zzb:Ljava/util/concurrent/ConcurrentHashMap;

    return-void
.end method

.method public static final zza(IJ)V
    .locals 4

    .line 1
    sget-object v0, Lcom/google/android/recaptcha/internal/zzbk;->zzb:Ljava/util/concurrent/ConcurrentHashMap;

    move-object v1, v0

    check-cast v1, Ljava/util/Map;

    invoke-static {p0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p0

    invoke-interface {v1, p0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    if-nez v1, :cond_0

    new-instance v1, Lcom/google/android/recaptcha/internal/zzbj;

    invoke-direct {v1}, Lcom/google/android/recaptcha/internal/zzbj;-><init>()V

    :cond_0
    check-cast v1, Lcom/google/android/recaptcha/internal/zzbj;

    invoke-virtual {v1}, Lcom/google/android/recaptcha/internal/zzbj;->zzb()I

    move-result v2

    add-int/lit8 v2, v2, 0x1

    .line 2
    invoke-virtual {v1, v2}, Lcom/google/android/recaptcha/internal/zzbj;->zzg(I)V

    invoke-virtual {v1}, Lcom/google/android/recaptcha/internal/zzbj;->zzd()J

    move-result-wide v2

    add-long/2addr v2, p1

    .line 3
    invoke-virtual {v1, v2, v3}, Lcom/google/android/recaptcha/internal/zzbj;->zzf(J)V

    invoke-virtual {v1}, Lcom/google/android/recaptcha/internal/zzbj;->zzc()J

    move-result-wide v2

    .line 4
    invoke-static {p1, p2, v2, v3}, Ljava/lang/Math;->max(JJ)J

    move-result-wide p1

    .line 5
    invoke-virtual {v1, p1, p2}, Lcom/google/android/recaptcha/internal/zzbj;->zze(J)V

    .line 6
    check-cast v0, Ljava/util/Map;

    invoke-interface {v0, p0, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    return-void
.end method
