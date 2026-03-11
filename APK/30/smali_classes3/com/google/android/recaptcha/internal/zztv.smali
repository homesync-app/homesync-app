.class public final enum Lcom/google/android/recaptcha/internal/zztv;
.super Ljava/lang/Enum;
.source "com.google.android.recaptcha:recaptcha@@18.6.1"

# interfaces
.implements Lcom/google/android/recaptcha/internal/zznf;


# static fields
.field public static final enum zza:Lcom/google/android/recaptcha/internal/zztv;

.field public static final enum zzb:Lcom/google/android/recaptcha/internal/zztv;

.field public static final enum zzc:Lcom/google/android/recaptcha/internal/zztv;

.field public static final enum zzd:Lcom/google/android/recaptcha/internal/zztv;

.field public static final enum zze:Lcom/google/android/recaptcha/internal/zztv;

.field public static final enum zzf:Lcom/google/android/recaptcha/internal/zztv;

.field public static final enum zzg:Lcom/google/android/recaptcha/internal/zztv;
    .annotation runtime Ljava/lang/Deprecated;
    .end annotation
.end field

.field public static final enum zzh:Lcom/google/android/recaptcha/internal/zztv;

.field public static final enum zzi:Lcom/google/android/recaptcha/internal/zztv;

.field public static final enum zzj:Lcom/google/android/recaptcha/internal/zztv;

.field public static final enum zzk:Lcom/google/android/recaptcha/internal/zztv;

.field private static final synthetic zzl:[Lcom/google/android/recaptcha/internal/zztv;


# instance fields
.field private final zzm:I


# direct methods
.method static constructor <clinit>()V
    .locals 14

    .line 1
    new-instance v0, Lcom/google/android/recaptcha/internal/zztv;

    const-string v1, "JS_CODE_UNSPECIFIED"

    const/4 v2, 0x0

    invoke-direct {v0, v1, v2, v2}, Lcom/google/android/recaptcha/internal/zztv;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lcom/google/android/recaptcha/internal/zztv;->zza:Lcom/google/android/recaptcha/internal/zztv;

    new-instance v1, Lcom/google/android/recaptcha/internal/zztv;

    const-string v2, "JS_CODE_SUCCESS"

    const/4 v3, 0x1

    .line 2
    invoke-direct {v1, v2, v3, v3}, Lcom/google/android/recaptcha/internal/zztv;-><init>(Ljava/lang/String;II)V

    sput-object v1, Lcom/google/android/recaptcha/internal/zztv;->zzb:Lcom/google/android/recaptcha/internal/zztv;

    new-instance v2, Lcom/google/android/recaptcha/internal/zztv;

    const-string v3, "JS_NETWORK_ERROR"

    const/4 v4, 0x2

    .line 3
    invoke-direct {v2, v3, v4, v4}, Lcom/google/android/recaptcha/internal/zztv;-><init>(Ljava/lang/String;II)V

    sput-object v2, Lcom/google/android/recaptcha/internal/zztv;->zzc:Lcom/google/android/recaptcha/internal/zztv;

    new-instance v3, Lcom/google/android/recaptcha/internal/zztv;

    const-string v4, "JS_INTERNAL_ERROR"

    const/4 v5, 0x3

    .line 4
    invoke-direct {v3, v4, v5, v5}, Lcom/google/android/recaptcha/internal/zztv;-><init>(Ljava/lang/String;II)V

    sput-object v3, Lcom/google/android/recaptcha/internal/zztv;->zzd:Lcom/google/android/recaptcha/internal/zztv;

    new-instance v4, Lcom/google/android/recaptcha/internal/zztv;

    const-string v5, "JS_INVALID_SITE_KEY"

    const/4 v6, 0x4

    .line 5
    invoke-direct {v4, v5, v6, v6}, Lcom/google/android/recaptcha/internal/zztv;-><init>(Ljava/lang/String;II)V

    sput-object v4, Lcom/google/android/recaptcha/internal/zztv;->zze:Lcom/google/android/recaptcha/internal/zztv;

    new-instance v5, Lcom/google/android/recaptcha/internal/zztv;

    const-string v6, "JS_INVALID_SITE_KEY_TYPE"

    const/4 v7, 0x5

    .line 6
    invoke-direct {v5, v6, v7, v7}, Lcom/google/android/recaptcha/internal/zztv;-><init>(Ljava/lang/String;II)V

    sput-object v5, Lcom/google/android/recaptcha/internal/zztv;->zzf:Lcom/google/android/recaptcha/internal/zztv;

    new-instance v6, Lcom/google/android/recaptcha/internal/zztv;

    const-string v7, "JS_3P_APP_PACKAGE_NAME_NOT_ALLOWED"

    const/4 v8, 0x6

    .line 7
    invoke-direct {v6, v7, v8, v8}, Lcom/google/android/recaptcha/internal/zztv;-><init>(Ljava/lang/String;II)V

    sput-object v6, Lcom/google/android/recaptcha/internal/zztv;->zzg:Lcom/google/android/recaptcha/internal/zztv;

    new-instance v7, Lcom/google/android/recaptcha/internal/zztv;

    const-string v8, "JS_INVALID_ACTION"

    const/4 v9, 0x7

    .line 8
    invoke-direct {v7, v8, v9, v9}, Lcom/google/android/recaptcha/internal/zztv;-><init>(Ljava/lang/String;II)V

    sput-object v7, Lcom/google/android/recaptcha/internal/zztv;->zzh:Lcom/google/android/recaptcha/internal/zztv;

    new-instance v8, Lcom/google/android/recaptcha/internal/zztv;

    const-string v9, "JS_THIRD_PARTY_APP_PACKAGE_NAME_NOT_ALLOWED"

    const/16 v10, 0x8

    .line 9
    invoke-direct {v8, v9, v10, v10}, Lcom/google/android/recaptcha/internal/zztv;-><init>(Ljava/lang/String;II)V

    sput-object v8, Lcom/google/android/recaptcha/internal/zztv;->zzi:Lcom/google/android/recaptcha/internal/zztv;

    new-instance v9, Lcom/google/android/recaptcha/internal/zztv;

    const-string v10, "JS_PROGRAM_ERROR"

    const/16 v11, 0x9

    .line 10
    invoke-direct {v9, v10, v11, v11}, Lcom/google/android/recaptcha/internal/zztv;-><init>(Ljava/lang/String;II)V

    sput-object v9, Lcom/google/android/recaptcha/internal/zztv;->zzj:Lcom/google/android/recaptcha/internal/zztv;

    new-instance v10, Lcom/google/android/recaptcha/internal/zztv;

    const/16 v11, 0xa

    const/4 v12, -0x1

    .line 11
    const-string v13, "UNRECOGNIZED"

    invoke-direct {v10, v13, v11, v12}, Lcom/google/android/recaptcha/internal/zztv;-><init>(Ljava/lang/String;II)V

    sput-object v10, Lcom/google/android/recaptcha/internal/zztv;->zzk:Lcom/google/android/recaptcha/internal/zztv;

    filled-new-array/range {v0 .. v10}, [Lcom/google/android/recaptcha/internal/zztv;

    move-result-object v0

    sput-object v0, Lcom/google/android/recaptcha/internal/zztv;->zzl:[Lcom/google/android/recaptcha/internal/zztv;

    return-void
.end method

.method private constructor <init>(Ljava/lang/String;II)V
    .locals 0

    .line 1
    invoke-direct {p0, p1, p2}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    iput p3, p0, Lcom/google/android/recaptcha/internal/zztv;->zzm:I

    return-void
.end method

.method public static values()[Lcom/google/android/recaptcha/internal/zztv;
    .locals 1

    .line 1
    sget-object v0, Lcom/google/android/recaptcha/internal/zztv;->zzl:[Lcom/google/android/recaptcha/internal/zztv;

    invoke-virtual {v0}, [Lcom/google/android/recaptcha/internal/zztv;->clone()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Lcom/google/android/recaptcha/internal/zztv;

    return-object v0
.end method

.method public static zzb(I)Lcom/google/android/recaptcha/internal/zztv;
    .locals 0

    packed-switch p0, :pswitch_data_0

    const/4 p0, 0x0

    return-object p0

    :pswitch_0
    sget-object p0, Lcom/google/android/recaptcha/internal/zztv;->zzj:Lcom/google/android/recaptcha/internal/zztv;

    return-object p0

    :pswitch_1
    sget-object p0, Lcom/google/android/recaptcha/internal/zztv;->zzi:Lcom/google/android/recaptcha/internal/zztv;

    return-object p0

    :pswitch_2
    sget-object p0, Lcom/google/android/recaptcha/internal/zztv;->zzh:Lcom/google/android/recaptcha/internal/zztv;

    return-object p0

    :pswitch_3
    sget-object p0, Lcom/google/android/recaptcha/internal/zztv;->zzg:Lcom/google/android/recaptcha/internal/zztv;

    return-object p0

    :pswitch_4
    sget-object p0, Lcom/google/android/recaptcha/internal/zztv;->zzf:Lcom/google/android/recaptcha/internal/zztv;

    return-object p0

    :pswitch_5
    sget-object p0, Lcom/google/android/recaptcha/internal/zztv;->zze:Lcom/google/android/recaptcha/internal/zztv;

    return-object p0

    :pswitch_6
    sget-object p0, Lcom/google/android/recaptcha/internal/zztv;->zzd:Lcom/google/android/recaptcha/internal/zztv;

    return-object p0

    :pswitch_7
    sget-object p0, Lcom/google/android/recaptcha/internal/zztv;->zzc:Lcom/google/android/recaptcha/internal/zztv;

    return-object p0

    :pswitch_8
    sget-object p0, Lcom/google/android/recaptcha/internal/zztv;->zzb:Lcom/google/android/recaptcha/internal/zztv;

    return-object p0

    :pswitch_9
    sget-object p0, Lcom/google/android/recaptcha/internal/zztv;->zza:Lcom/google/android/recaptcha/internal/zztv;

    return-object p0

    nop

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_9
        :pswitch_8
        :pswitch_7
        :pswitch_6
        :pswitch_5
        :pswitch_4
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method


# virtual methods
.method public final toString()Ljava/lang/String;
    .locals 1

    invoke-virtual {p0}, Lcom/google/android/recaptcha/internal/zztv;->zza()I

    move-result v0

    invoke-static {v0}, Ljava/lang/Integer;->toString(I)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public final zza()I
    .locals 2

    .line 1
    sget-object v0, Lcom/google/android/recaptcha/internal/zztv;->zzk:Lcom/google/android/recaptcha/internal/zztv;

    if-eq p0, v0, :cond_0

    iget v0, p0, Lcom/google/android/recaptcha/internal/zztv;->zzm:I

    return v0

    :cond_0
    new-instance v0, Ljava/lang/IllegalArgumentException;

    const-string v1, "Can\'t get the number of an unknown enum value."

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0
.end method
