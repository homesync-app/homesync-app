.class public final Lcom/google/android/recaptcha/internal/zzub;
.super Lcom/google/android/recaptcha/internal/zznd;
.source "com.google.android.recaptcha:recaptcha@@18.6.1"

# interfaces
.implements Lcom/google/android/recaptcha/internal/zzoj;


# static fields
.field private static final zzb:Lcom/google/android/recaptcha/internal/zzub;

.field private static volatile zzd:Lcom/google/android/recaptcha/internal/zzoq;


# instance fields
.field private zze:I

.field private zzf:Ljava/lang/String;

.field private zzg:Lcom/google/android/recaptcha/internal/zzni;

.field private zzh:Lcom/google/android/recaptcha/internal/zznj;

.field private zzi:Lcom/google/android/recaptcha/internal/zztl;


# direct methods
.method static constructor <clinit>()V
    .locals 2

    .line 1
    new-instance v0, Lcom/google/android/recaptcha/internal/zzub;

    invoke-direct {v0}, Lcom/google/android/recaptcha/internal/zzub;-><init>()V

    sput-object v0, Lcom/google/android/recaptcha/internal/zzub;->zzb:Lcom/google/android/recaptcha/internal/zzub;

    const-class v1, Lcom/google/android/recaptcha/internal/zzub;

    .line 2
    invoke-static {v1, v0}, Lcom/google/android/recaptcha/internal/zznd;->zzI(Ljava/lang/Class;Lcom/google/android/recaptcha/internal/zznd;)V

    return-void
.end method

.method private constructor <init>()V
    .locals 1

    .line 1
    invoke-direct {p0}, Lcom/google/android/recaptcha/internal/zznd;-><init>()V

    const-string v0, ""

    iput-object v0, p0, Lcom/google/android/recaptcha/internal/zzub;->zzf:Ljava/lang/String;

    .line 2
    invoke-static {}, Lcom/google/android/recaptcha/internal/zzub;->zzy()Lcom/google/android/recaptcha/internal/zzni;

    move-result-object v0

    iput-object v0, p0, Lcom/google/android/recaptcha/internal/zzub;->zzg:Lcom/google/android/recaptcha/internal/zzni;

    .line 3
    invoke-static {}, Lcom/google/android/recaptcha/internal/zzub;->zzA()Lcom/google/android/recaptcha/internal/zznj;

    move-result-object v0

    iput-object v0, p0, Lcom/google/android/recaptcha/internal/zzub;->zzh:Lcom/google/android/recaptcha/internal/zznj;

    return-void
.end method

.method static bridge synthetic zzg()Lcom/google/android/recaptcha/internal/zzub;
    .locals 1

    sget-object v0, Lcom/google/android/recaptcha/internal/zzub;->zzb:Lcom/google/android/recaptcha/internal/zzub;

    return-object v0
.end method

.method public static zzi([B)Lcom/google/android/recaptcha/internal/zzub;
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/google/android/recaptcha/internal/zznn;
        }
    .end annotation

    .line 1
    sget-object v0, Lcom/google/android/recaptcha/internal/zzub;->zzb:Lcom/google/android/recaptcha/internal/zzub;

    invoke-static {v0, p0}, Lcom/google/android/recaptcha/internal/zznd;->zzx(Lcom/google/android/recaptcha/internal/zznd;[B)Lcom/google/android/recaptcha/internal/zznd;

    move-result-object p0

    check-cast p0, Lcom/google/android/recaptcha/internal/zzub;

    return-object p0
.end method


# virtual methods
.method public final zzf()Lcom/google/android/recaptcha/internal/zztl;
    .locals 1

    .line 1
    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzub;->zzi:Lcom/google/android/recaptcha/internal/zztl;

    if-nez v0, :cond_0

    invoke-static {}, Lcom/google/android/recaptcha/internal/zztl;->zzg()Lcom/google/android/recaptcha/internal/zztl;

    move-result-object v0

    :cond_0
    return-object v0
.end method

.method protected final zzh(ILjava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    .locals 2

    add-int/lit8 p1, p1, -0x1

    if-eqz p1, :cond_7

    const/4 p2, 0x2

    if-eq p1, p2, :cond_6

    const/4 p2, 0x3

    if-eq p1, p2, :cond_5

    const/4 p2, 0x4

    const/4 p3, 0x0

    if-eq p1, p2, :cond_4

    const/4 p2, 0x5

    if-eq p1, p2, :cond_3

    const/4 p2, 0x6

    if-eq p1, p2, :cond_0

    return-object p3

    .line 2
    :cond_0
    sget-object p1, Lcom/google/android/recaptcha/internal/zzub;->zzd:Lcom/google/android/recaptcha/internal/zzoq;

    if-nez p1, :cond_2

    const-class p2, Lcom/google/android/recaptcha/internal/zzub;

    monitor-enter p2

    :try_start_0
    sget-object p1, Lcom/google/android/recaptcha/internal/zzub;->zzd:Lcom/google/android/recaptcha/internal/zzoq;

    if-nez p1, :cond_1

    new-instance p1, Lcom/google/android/recaptcha/internal/zzmy;

    sget-object p3, Lcom/google/android/recaptcha/internal/zzub;->zzb:Lcom/google/android/recaptcha/internal/zzub;

    invoke-direct {p1, p3}, Lcom/google/android/recaptcha/internal/zzmy;-><init>(Lcom/google/android/recaptcha/internal/zznd;)V

    sput-object p1, Lcom/google/android/recaptcha/internal/zzub;->zzd:Lcom/google/android/recaptcha/internal/zzoq;

    .line 3
    :cond_1
    monitor-exit p2

    return-object p1

    :catchall_0
    move-exception p1

    monitor-exit p2
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw p1

    :cond_2
    return-object p1

    .line 4
    :cond_3
    sget-object p1, Lcom/google/android/recaptcha/internal/zzub;->zzb:Lcom/google/android/recaptcha/internal/zzub;

    return-object p1

    :cond_4
    new-instance p1, Lcom/google/android/recaptcha/internal/zzua;

    .line 5
    invoke-direct {p1, p3}, Lcom/google/android/recaptcha/internal/zzua;-><init>(Lcom/google/android/recaptcha/internal/zzug;)V

    return-object p1

    :cond_5
    new-instance p1, Lcom/google/android/recaptcha/internal/zzub;

    .line 6
    invoke-direct {p1}, Lcom/google/android/recaptcha/internal/zzub;-><init>()V

    return-object p1

    .line 1
    :cond_6
    const-string p1, "zze"

    const-string p2, "zzf"

    const-string p3, "zzg"

    const-string v0, "zzh"

    const-string v1, "zzi"

    filled-new-array {p1, p2, p3, v0, v1}, [Ljava/lang/Object;

    move-result-object p1

    sget-object p2, Lcom/google/android/recaptcha/internal/zzub;->zzb:Lcom/google/android/recaptcha/internal/zzub;

    const-string p3, "\u0000\u0004\u0000\u0001\u0001\u0004\u0004\u0000\u0002\u0000\u0001\u0208\u0002\'\u0003%\u0004\u1009\u0000"

    .line 4
    invoke-static {p2, p3, p1}, Lcom/google/android/recaptcha/internal/zzub;->zzF(Lcom/google/android/recaptcha/internal/zzoi;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    return-object p1

    :cond_7
    const/4 p1, 0x1

    .line 1
    invoke-static {p1}, Ljava/lang/Byte;->valueOf(B)Ljava/lang/Byte;

    move-result-object p1

    return-object p1
.end method

.method public final zzj()Ljava/lang/String;
    .locals 1

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzub;->zzf:Ljava/lang/String;

    return-object v0
.end method

.method public final zzk()Ljava/util/List;
    .locals 1

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzub;->zzh:Lcom/google/android/recaptcha/internal/zznj;

    return-object v0
.end method
