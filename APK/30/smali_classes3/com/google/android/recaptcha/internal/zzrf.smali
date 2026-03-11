.class public final Lcom/google/android/recaptcha/internal/zzrf;
.super Lcom/google/android/recaptcha/internal/zznd;
.source "com.google.android.recaptcha:recaptcha@@18.6.1"

# interfaces
.implements Lcom/google/android/recaptcha/internal/zzoj;


# static fields
.field private static final zzb:Lcom/google/android/recaptcha/internal/zzrf;

.field private static volatile zzd:Lcom/google/android/recaptcha/internal/zzoq;


# instance fields
.field private zze:I

.field private zzf:Lcom/google/android/recaptcha/internal/zznk;

.field private zzg:Lcom/google/android/recaptcha/internal/zznk;

.field private zzh:Lcom/google/android/recaptcha/internal/zzqn;


# direct methods
.method static constructor <clinit>()V
    .locals 2

    .line 1
    new-instance v0, Lcom/google/android/recaptcha/internal/zzrf;

    invoke-direct {v0}, Lcom/google/android/recaptcha/internal/zzrf;-><init>()V

    sput-object v0, Lcom/google/android/recaptcha/internal/zzrf;->zzb:Lcom/google/android/recaptcha/internal/zzrf;

    const-class v1, Lcom/google/android/recaptcha/internal/zzrf;

    .line 2
    invoke-static {v1, v0}, Lcom/google/android/recaptcha/internal/zznd;->zzI(Ljava/lang/Class;Lcom/google/android/recaptcha/internal/zznd;)V

    return-void
.end method

.method private constructor <init>()V
    .locals 1

    .line 1
    invoke-direct {p0}, Lcom/google/android/recaptcha/internal/zznd;-><init>()V

    .line 2
    invoke-static {}, Lcom/google/android/recaptcha/internal/zzrf;->zzB()Lcom/google/android/recaptcha/internal/zznk;

    move-result-object v0

    iput-object v0, p0, Lcom/google/android/recaptcha/internal/zzrf;->zzf:Lcom/google/android/recaptcha/internal/zznk;

    .line 3
    invoke-static {}, Lcom/google/android/recaptcha/internal/zzrf;->zzB()Lcom/google/android/recaptcha/internal/zznk;

    move-result-object v0

    iput-object v0, p0, Lcom/google/android/recaptcha/internal/zzrf;->zzg:Lcom/google/android/recaptcha/internal/zznk;

    return-void
.end method

.method static synthetic zzM(Lcom/google/android/recaptcha/internal/zzrf;Lcom/google/android/recaptcha/internal/zzrc;)V
    .locals 2

    .line 1
    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzrf;->zzf:Lcom/google/android/recaptcha/internal/zznk;

    .line 2
    invoke-interface {v0}, Lcom/google/android/recaptcha/internal/zznk;->zzc()Z

    move-result v1

    if-nez v1, :cond_0

    .line 3
    invoke-static {v0}, Lcom/google/android/recaptcha/internal/zznd;->zzC(Lcom/google/android/recaptcha/internal/zznk;)Lcom/google/android/recaptcha/internal/zznk;

    move-result-object v0

    iput-object v0, p0, Lcom/google/android/recaptcha/internal/zzrf;->zzf:Lcom/google/android/recaptcha/internal/zznk;

    :cond_0
    iget-object p0, p0, Lcom/google/android/recaptcha/internal/zzrf;->zzf:Lcom/google/android/recaptcha/internal/zznk;

    .line 4
    invoke-interface {p0, p1}, Lcom/google/android/recaptcha/internal/zznk;->add(Ljava/lang/Object;)Z

    return-void
.end method

.method static synthetic zzN(Lcom/google/android/recaptcha/internal/zzrf;Lcom/google/android/recaptcha/internal/zzrr;)V
    .locals 2

    .line 1
    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzrf;->zzg:Lcom/google/android/recaptcha/internal/zznk;

    .line 2
    invoke-interface {v0}, Lcom/google/android/recaptcha/internal/zznk;->zzc()Z

    move-result v1

    if-nez v1, :cond_0

    .line 3
    invoke-static {v0}, Lcom/google/android/recaptcha/internal/zznd;->zzC(Lcom/google/android/recaptcha/internal/zznk;)Lcom/google/android/recaptcha/internal/zznk;

    move-result-object v0

    iput-object v0, p0, Lcom/google/android/recaptcha/internal/zzrf;->zzg:Lcom/google/android/recaptcha/internal/zznk;

    :cond_0
    iget-object p0, p0, Lcom/google/android/recaptcha/internal/zzrf;->zzg:Lcom/google/android/recaptcha/internal/zznk;

    .line 4
    invoke-interface {p0, p1}, Lcom/google/android/recaptcha/internal/zznk;->add(Ljava/lang/Object;)Z

    return-void
.end method

.method public static zzi()Lcom/google/android/recaptcha/internal/zzrd;
    .locals 1

    .line 1
    sget-object v0, Lcom/google/android/recaptcha/internal/zzrf;->zzb:Lcom/google/android/recaptcha/internal/zzrf;

    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zznd;->zzq()Lcom/google/android/recaptcha/internal/zzmx;

    move-result-object v0

    check-cast v0, Lcom/google/android/recaptcha/internal/zzrd;

    return-object v0
.end method

.method static bridge synthetic zzj()Lcom/google/android/recaptcha/internal/zzrf;
    .locals 1

    sget-object v0, Lcom/google/android/recaptcha/internal/zzrf;->zzb:Lcom/google/android/recaptcha/internal/zzrf;

    return-object v0
.end method

.method public static zzk([B)Lcom/google/android/recaptcha/internal/zzrf;
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Lcom/google/android/recaptcha/internal/zznn;
        }
    .end annotation

    .line 1
    sget-object v0, Lcom/google/android/recaptcha/internal/zzrf;->zzb:Lcom/google/android/recaptcha/internal/zzrf;

    invoke-static {v0, p0}, Lcom/google/android/recaptcha/internal/zznd;->zzx(Lcom/google/android/recaptcha/internal/zznd;[B)Lcom/google/android/recaptcha/internal/zznd;

    move-result-object p0

    check-cast p0, Lcom/google/android/recaptcha/internal/zzrf;

    return-object p0
.end method


# virtual methods
.method public final zzf()I
    .locals 1

    .line 1
    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzrf;->zzf:Lcom/google/android/recaptcha/internal/zznk;

    invoke-interface {v0}, Lcom/google/android/recaptcha/internal/zznk;->size()I

    move-result v0

    return v0
.end method

.method public final zzg()I
    .locals 1

    .line 1
    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzrf;->zzg:Lcom/google/android/recaptcha/internal/zznk;

    invoke-interface {v0}, Lcom/google/android/recaptcha/internal/zznk;->size()I

    move-result v0

    return v0
.end method

.method protected final zzh(ILjava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    .locals 6

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
    sget-object p1, Lcom/google/android/recaptcha/internal/zzrf;->zzd:Lcom/google/android/recaptcha/internal/zzoq;

    if-nez p1, :cond_2

    const-class p2, Lcom/google/android/recaptcha/internal/zzrf;

    monitor-enter p2

    :try_start_0
    sget-object p1, Lcom/google/android/recaptcha/internal/zzrf;->zzd:Lcom/google/android/recaptcha/internal/zzoq;

    if-nez p1, :cond_1

    new-instance p1, Lcom/google/android/recaptcha/internal/zzmy;

    sget-object p3, Lcom/google/android/recaptcha/internal/zzrf;->zzb:Lcom/google/android/recaptcha/internal/zzrf;

    invoke-direct {p1, p3}, Lcom/google/android/recaptcha/internal/zzmy;-><init>(Lcom/google/android/recaptcha/internal/zznd;)V

    sput-object p1, Lcom/google/android/recaptcha/internal/zzrf;->zzd:Lcom/google/android/recaptcha/internal/zzoq;

    .line 3
    :cond_1
    monitor-exit p2

    return-object p1

    :catchall_0
    move-exception v0

    move-object p1, v0

    monitor-exit p2
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw p1

    :cond_2
    return-object p1

    .line 4
    :cond_3
    sget-object p1, Lcom/google/android/recaptcha/internal/zzrf;->zzb:Lcom/google/android/recaptcha/internal/zzrf;

    return-object p1

    :cond_4
    new-instance p1, Lcom/google/android/recaptcha/internal/zzrd;

    .line 5
    invoke-direct {p1, p3}, Lcom/google/android/recaptcha/internal/zzrd;-><init>(Lcom/google/android/recaptcha/internal/zzre;)V

    return-object p1

    :cond_5
    new-instance p1, Lcom/google/android/recaptcha/internal/zzrf;

    .line 6
    invoke-direct {p1}, Lcom/google/android/recaptcha/internal/zzrf;-><init>()V

    return-object p1

    .line 1
    :cond_6
    const-string v0, "zze"

    const-string v1, "zzf"

    const-class v2, Lcom/google/android/recaptcha/internal/zzrc;

    const-string v3, "zzg"

    const-class v4, Lcom/google/android/recaptcha/internal/zzrr;

    const-string v5, "zzh"

    filled-new-array/range {v0 .. v5}, [Ljava/lang/Object;

    move-result-object p1

    sget-object p2, Lcom/google/android/recaptcha/internal/zzrf;->zzb:Lcom/google/android/recaptcha/internal/zzrf;

    const-string p3, "\u0000\u0003\u0000\u0001\u0001\u0003\u0003\u0000\u0002\u0000\u0001\u001b\u0002\u001b\u0003\u1009\u0000"

    .line 4
    invoke-static {p2, p3, p1}, Lcom/google/android/recaptcha/internal/zzrf;->zzF(Lcom/google/android/recaptcha/internal/zzoi;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    return-object p1

    :cond_7
    const/4 p1, 0x1

    .line 1
    invoke-static {p1}, Ljava/lang/Byte;->valueOf(B)Ljava/lang/Byte;

    move-result-object p1

    return-object p1
.end method

.method public final zzl()Ljava/util/List;
    .locals 1

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzrf;->zzf:Lcom/google/android/recaptcha/internal/zznk;

    return-object v0
.end method
