.class public final Lcom/google/android/recaptcha/internal/zzgd;
.super Ljava/lang/Object;
.source "com.google.android.recaptcha:recaptcha@@18.6.1"


# instance fields
.field public zza:Lcom/google/android/recaptcha/internal/zzbn;

.field private final zzb:Lcom/google/android/recaptcha/internal/zzgf;

.field private zzc:Ljava/lang/String;

.field private zzd:I

.field private final zze:Lcom/google/android/recaptcha/internal/zzge;

.field private final zzf:Lcom/google/android/recaptcha/internal/zzbn;

.field private final zzg:Lcom/google/android/recaptcha/internal/zzfw;

.field private final zzh:Lcom/google/android/recaptcha/internal/zzcg;


# direct methods
.method public constructor <init>(Lcom/google/android/recaptcha/internal/zzgf;)V
    .locals 1

    .line 1
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzgd;->zzb:Lcom/google/android/recaptcha/internal/zzgf;

    const-string v0, "recaptcha.m.Main.rge"

    iput-object v0, p0, Lcom/google/android/recaptcha/internal/zzgd;->zzc:Ljava/lang/String;

    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzgf;->zza()Lcom/google/android/recaptcha/internal/zzge;

    move-result-object v0

    iput-object v0, p0, Lcom/google/android/recaptcha/internal/zzgd;->zze:Lcom/google/android/recaptcha/internal/zzge;

    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzgf;->zzd()Lcom/google/android/recaptcha/internal/zzfw;

    move-result-object v0

    iput-object v0, p0, Lcom/google/android/recaptcha/internal/zzgd;->zzg:Lcom/google/android/recaptcha/internal/zzfw;

    new-instance v0, Lcom/google/android/recaptcha/internal/zzbn;

    invoke-direct {v0}, Lcom/google/android/recaptcha/internal/zzbn;-><init>()V

    iput-object v0, p0, Lcom/google/android/recaptcha/internal/zzgd;->zzf:Lcom/google/android/recaptcha/internal/zzbn;

    invoke-virtual {p1}, Lcom/google/android/recaptcha/internal/zzgf;->zzc()Lcom/google/android/recaptcha/internal/zzcg;

    move-result-object p1

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzgd;->zzh:Lcom/google/android/recaptcha/internal/zzcg;

    return-void
.end method


# virtual methods
.method public final zza()I
    .locals 1

    iget v0, p0, Lcom/google/android/recaptcha/internal/zzgd;->zzd:I

    return v0
.end method

.method public final zzb()Lcom/google/android/recaptcha/internal/zzbn;
    .locals 1

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzgd;->zzf:Lcom/google/android/recaptcha/internal/zzbn;

    return-object v0
.end method

.method public final zzc()Lcom/google/android/recaptcha/internal/zzge;
    .locals 1

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzgd;->zze:Lcom/google/android/recaptcha/internal/zzge;

    return-object v0
.end method

.method public final zzd()Ljava/lang/String;
    .locals 1

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzgd;->zzc:Ljava/lang/String;

    return-object v0
.end method

.method public final zze()V
    .locals 1

    .line 1
    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzgd;->zzb:Lcom/google/android/recaptcha/internal/zzgf;

    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzgf;->zzb()V

    return-void
.end method

.method public final zzf(Ljava/lang/String;)V
    .locals 0

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzgd;->zzc:Ljava/lang/String;

    return-void
.end method

.method public final zzg(I)V
    .locals 0

    iput p1, p0, Lcom/google/android/recaptcha/internal/zzgd;->zzd:I

    return-void
.end method

.method public final zzh()Lcom/google/android/recaptcha/internal/zzcg;
    .locals 1

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzgd;->zzh:Lcom/google/android/recaptcha/internal/zzcg;

    return-object v0
.end method

.method public final zzi()Lcom/google/android/recaptcha/internal/zzfw;
    .locals 1

    iget-object v0, p0, Lcom/google/android/recaptcha/internal/zzgd;->zzg:Lcom/google/android/recaptcha/internal/zzfw;

    return-object v0
.end method
