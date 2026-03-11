.class public final Lcom/google/android/recaptcha/internal/zzth;
.super Lcom/google/android/recaptcha/internal/zznd;
.source "com.google.android.recaptcha:recaptcha@@18.6.1"

# interfaces
.implements Lcom/google/android/recaptcha/internal/zzoj;


# static fields
.field private static final zzb:Lcom/google/android/recaptcha/internal/zzth;

.field private static volatile zzd:Lcom/google/android/recaptcha/internal/zzoq;


# instance fields
.field private zze:I

.field private zzf:Ljava/lang/Object;


# direct methods
.method static constructor <clinit>()V
    .locals 2

    .line 1
    new-instance v0, Lcom/google/android/recaptcha/internal/zzth;

    invoke-direct {v0}, Lcom/google/android/recaptcha/internal/zzth;-><init>()V

    sput-object v0, Lcom/google/android/recaptcha/internal/zzth;->zzb:Lcom/google/android/recaptcha/internal/zzth;

    const-class v1, Lcom/google/android/recaptcha/internal/zzth;

    invoke-static {v1, v0}, Lcom/google/android/recaptcha/internal/zznd;->zzI(Ljava/lang/Class;Lcom/google/android/recaptcha/internal/zznd;)V

    return-void
.end method

.method private constructor <init>()V
    .locals 1

    .line 1
    invoke-direct {p0}, Lcom/google/android/recaptcha/internal/zznd;-><init>()V

    const/4 v0, 0x0

    iput v0, p0, Lcom/google/android/recaptcha/internal/zzth;->zze:I

    return-void
.end method

.method static synthetic zzM(Lcom/google/android/recaptcha/internal/zzth;F)V
    .locals 1

    const/16 v0, 0x9

    .line 1
    iput v0, p0, Lcom/google/android/recaptcha/internal/zzth;->zze:I

    invoke-static {p1}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object p1

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzth;->zzf:Ljava/lang/Object;

    return-void
.end method

.method static synthetic zzN(Lcom/google/android/recaptcha/internal/zzth;I)V
    .locals 1

    const/4 v0, 0x4

    .line 1
    iput v0, p0, Lcom/google/android/recaptcha/internal/zzth;->zze:I

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzth;->zzf:Ljava/lang/Object;

    return-void
.end method

.method static synthetic zzO(Lcom/google/android/recaptcha/internal/zzth;I)V
    .locals 1

    const/4 v0, 0x5

    .line 1
    iput v0, p0, Lcom/google/android/recaptcha/internal/zzth;->zze:I

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzth;->zzf:Ljava/lang/Object;

    return-void
.end method

.method static synthetic zzP(Lcom/google/android/recaptcha/internal/zzth;J)V
    .locals 1

    const/4 v0, 0x7

    .line 1
    iput v0, p0, Lcom/google/android/recaptcha/internal/zzth;->zze:I

    invoke-static {p1, p2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object p1

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzth;->zzf:Ljava/lang/Object;

    return-void
.end method

.method static synthetic zzQ(Lcom/google/android/recaptcha/internal/zzth;Ljava/lang/String;)V
    .locals 1

    .line 1
    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    const/16 v0, 0xb

    iput v0, p0, Lcom/google/android/recaptcha/internal/zzth;->zze:I

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzth;->zzf:Ljava/lang/Object;

    return-void
.end method

.method public static zzf()Lcom/google/android/recaptcha/internal/zztg;
    .locals 1

    .line 1
    sget-object v0, Lcom/google/android/recaptcha/internal/zzth;->zzb:Lcom/google/android/recaptcha/internal/zzth;

    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zznd;->zzq()Lcom/google/android/recaptcha/internal/zzmx;

    move-result-object v0

    check-cast v0, Lcom/google/android/recaptcha/internal/zztg;

    return-object v0
.end method

.method static bridge synthetic zzg()Lcom/google/android/recaptcha/internal/zzth;
    .locals 1

    sget-object v0, Lcom/google/android/recaptcha/internal/zzth;->zzb:Lcom/google/android/recaptcha/internal/zzth;

    return-object v0
.end method

.method static synthetic zzi(Lcom/google/android/recaptcha/internal/zzth;Z)V
    .locals 1

    const/4 v0, 0x1

    .line 1
    iput v0, p0, Lcom/google/android/recaptcha/internal/zzth;->zze:I

    invoke-static {p1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object p1

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzth;->zzf:Ljava/lang/Object;

    return-void
.end method

.method static synthetic zzj(Lcom/google/android/recaptcha/internal/zzth;Lcom/google/android/recaptcha/internal/zzle;)V
    .locals 1

    const/4 v0, 0x2

    iput v0, p0, Lcom/google/android/recaptcha/internal/zzth;->zze:I

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzth;->zzf:Ljava/lang/Object;

    return-void
.end method

.method static synthetic zzk(Lcom/google/android/recaptcha/internal/zzth;Ljava/lang/String;)V
    .locals 1

    .line 1
    invoke-virtual {p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    const/4 v0, 0x3

    iput v0, p0, Lcom/google/android/recaptcha/internal/zzth;->zze:I

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzth;->zzf:Ljava/lang/Object;

    return-void
.end method

.method static synthetic zzl(Lcom/google/android/recaptcha/internal/zzth;D)V
    .locals 1

    const/16 v0, 0xa

    .line 1
    iput v0, p0, Lcom/google/android/recaptcha/internal/zzth;->zze:I

    invoke-static {p1, p2}, Ljava/lang/Double;->valueOf(D)Ljava/lang/Double;

    move-result-object p1

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzth;->zzf:Ljava/lang/Object;

    return-void
.end method


# virtual methods
.method protected final zzh(ILjava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    .locals 0

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
    sget-object p1, Lcom/google/android/recaptcha/internal/zzth;->zzd:Lcom/google/android/recaptcha/internal/zzoq;

    if-nez p1, :cond_2

    const-class p2, Lcom/google/android/recaptcha/internal/zzth;

    monitor-enter p2

    :try_start_0
    sget-object p1, Lcom/google/android/recaptcha/internal/zzth;->zzd:Lcom/google/android/recaptcha/internal/zzoq;

    if-nez p1, :cond_1

    new-instance p1, Lcom/google/android/recaptcha/internal/zzmy;

    sget-object p3, Lcom/google/android/recaptcha/internal/zzth;->zzb:Lcom/google/android/recaptcha/internal/zzth;

    invoke-direct {p1, p3}, Lcom/google/android/recaptcha/internal/zzmy;-><init>(Lcom/google/android/recaptcha/internal/zznd;)V

    sput-object p1, Lcom/google/android/recaptcha/internal/zzth;->zzd:Lcom/google/android/recaptcha/internal/zzoq;

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
    sget-object p1, Lcom/google/android/recaptcha/internal/zzth;->zzb:Lcom/google/android/recaptcha/internal/zzth;

    return-object p1

    :cond_4
    new-instance p1, Lcom/google/android/recaptcha/internal/zztg;

    .line 5
    invoke-direct {p1, p3}, Lcom/google/android/recaptcha/internal/zztg;-><init>(Lcom/google/android/recaptcha/internal/zztj;)V

    return-object p1

    :cond_5
    new-instance p1, Lcom/google/android/recaptcha/internal/zzth;

    invoke-direct {p1}, Lcom/google/android/recaptcha/internal/zzth;-><init>()V

    return-object p1

    .line 1
    :cond_6
    const-string p1, "zzf"

    const-string p2, "zze"

    filled-new-array {p1, p2}, [Ljava/lang/Object;

    move-result-object p1

    sget-object p2, Lcom/google/android/recaptcha/internal/zzth;->zzb:Lcom/google/android/recaptcha/internal/zzth;

    const-string p3, "\u0000\u000b\u0001\u0000\u0001\u000b\u000b\u0000\u0000\u0000\u0001:\u0000\u0002=\u0000\u0003\u023b\u0000\u0004B\u0000\u0005B\u0000\u0006>\u0000\u0007C\u0000\u00086\u0000\t4\u0000\n3\u0000\u000b\u023b\u0000"

    .line 4
    invoke-static {p2, p3, p1}, Lcom/google/android/recaptcha/internal/zzth;->zzF(Lcom/google/android/recaptcha/internal/zzoi;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    return-object p1

    :cond_7
    const/4 p1, 0x1

    .line 1
    invoke-static {p1}, Ljava/lang/Byte;->valueOf(B)Ljava/lang/Byte;

    move-result-object p1

    return-object p1
.end method
