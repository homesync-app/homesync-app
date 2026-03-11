.class final Lcom/google/android/gms/internal/firebase-auth-api/zzakp;
.super Ljava/lang/Object;
.source "com.google.firebase:firebase-auth@@24.0.1"

# interfaces
.implements Lcom/google/android/gms/internal/firebase-auth-api/zzaol;


# instance fields
.field private final zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;


# direct methods
.method private constructor <init>(Lcom/google/android/gms/internal/firebase-auth-api/zzakn;)V
    .locals 1

    .line 5
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 6
    const-string v0, "output"

    invoke-static {p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzalh;->zza(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    iput-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    .line 7
    iput-object p0, p1, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakp;

    return-void
.end method

.method public static zza(Lcom/google/android/gms/internal/firebase-auth-api/zzakn;)Lcom/google/android/gms/internal/firebase-auth-api/zzakp;
    .locals 1

    .line 1
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakp;

    if-eqz v0, :cond_0

    .line 2
    iget-object p0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakp;

    return-object p0

    .line 3
    :cond_0
    new-instance v0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;

    invoke-direct {v0, p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;-><init>(Lcom/google/android/gms/internal/firebase-auth-api/zzakn;)V

    return-object v0
.end method


# virtual methods
.method public final zza()I
    .locals 1

    const/4 v0, 0x1

    return v0
.end method

.method public final zza(I)V
    .locals 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .annotation runtime Ljava/lang/Deprecated;
    .end annotation

    .line 85
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    const/4 v1, 0x4

    invoke-virtual {v0, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    return-void
.end method

.method public final zza(ID)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 50
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {v0, p1, p2, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(ID)V

    return-void
.end method

.method public final zza(IF)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 197
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {v0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(IF)V

    return-void
.end method

.method public final zza(II)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 87
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    .line 88
    invoke-virtual {v0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(II)V

    return-void
.end method

.method public final zza(IJ)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 162
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {v0, p1, p2, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzf(IJ)V

    return-void
.end method

.method public final zza(ILcom/google/android/gms/internal/firebase-auth-api/zzajv;)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 44
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {v0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzc(ILcom/google/android/gms/internal/firebase-auth-api/zzajv;)V

    return-void
.end method

.method public final zza(ILcom/google/android/gms/internal/firebase-auth-api/zzamd;Ljava/util/Map;)V
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<K:",
            "Ljava/lang/Object;",
            "V:",
            "Ljava/lang/Object;",
            ">(I",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzamd<",
            "TK;TV;>;",
            "Ljava/util/Map<",
            "TK;TV;>;)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 316
    invoke-interface {p3}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object p3

    invoke-interface {p3}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object p3

    :goto_0
    invoke-interface {p3}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_0

    invoke-interface {p3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/util/Map$Entry;

    .line 317
    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    const/4 v2, 0x2

    invoke-virtual {v1, p1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    .line 318
    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    .line 319
    invoke-interface {v0}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v2

    invoke-interface {v0}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v3

    invoke-static {p2, v2, v3}, Lcom/google/android/gms/internal/firebase-auth-api/zzame;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzamd;Ljava/lang/Object;Ljava/lang/Object;)I

    move-result v2

    .line 320
    invoke-virtual {v1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 321
    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {v0}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v2

    invoke-interface {v0}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v0

    invoke-static {v1, p2, v2, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzame;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzakn;Lcom/google/android/gms/internal/firebase-auth-api/zzamd;Ljava/lang/Object;Ljava/lang/Object;)V

    goto :goto_0

    :cond_0
    return-void
.end method

.method public final zza(ILjava/lang/Object;)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 333
    instance-of v0, p2, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    if-eqz v0, :cond_0

    .line 334
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    check-cast p2, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    invoke-virtual {v0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzd(ILcom/google/android/gms/internal/firebase-auth-api/zzajv;)V

    return-void

    .line 335
    :cond_0
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    check-cast p2, Lcom/google/android/gms/internal/firebase-auth-api/zzamm;

    invoke-virtual {v0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(ILcom/google/android/gms/internal/firebase-auth-api/zzamm;)V

    return-void
.end method

.method public final zza(ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)V
    .locals 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 232
    check-cast p2, Lcom/google/android/gms/internal/firebase-auth-api/zzajm;

    .line 233
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    const/4 v1, 0x3

    invoke-virtual {v0, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    .line 234
    invoke-interface {p3, p2, p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zza(Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;)V

    .line 235
    iget-object p2, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    const/4 p3, 0x4

    invoke-virtual {p2, p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    return-void
.end method

.method public final zza(ILjava/lang/String;)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 489
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {v0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(ILjava/lang/String;)V

    return-void
.end method

.method public final zza(ILjava/util/List;)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I",
            "Ljava/util/List<",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzajv;",
            ">;)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/4 v0, 0x0

    .line 46
    :goto_0
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result v1

    if-ge v0, v1, :cond_0

    .line 47
    iget-object v1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    invoke-virtual {v1, p1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzc(ILcom/google/android/gms/internal/firebase-auth-api/zzajv;)V

    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    :cond_0
    return-void
.end method

.method public final zza(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)V
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I",
            "Ljava/util/List<",
            "*>;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzanb;",
            ")V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/4 v0, 0x0

    .line 237
    :goto_0
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result v1

    if-ge v0, v1, :cond_0

    .line 238
    invoke-interface {p2, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v1

    invoke-virtual {p0, p1, v1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza(ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)V

    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    :cond_0
    return-void
.end method

.method public final zza(ILjava/util/List;Z)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I",
            "Ljava/util/List<",
            "Ljava/lang/Boolean;",
            ">;Z)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 11
    instance-of v0, p2, Lcom/google/android/gms/internal/firebase-auth-api/zzajt;

    const/4 v1, 0x2

    const/4 v2, 0x0

    if-eqz v0, :cond_2

    .line 12
    check-cast p2, Lcom/google/android/gms/internal/firebase-auth-api/zzajt;

    if-eqz p3, :cond_1

    .line 14
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 16
    :goto_0
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzajt;->size()I

    move-result v0

    if-ge p1, v0, :cond_0

    .line 17
    invoke-virtual {p2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzajt;->zzb(I)Z

    move-result v0

    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(Z)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_0

    .line 19
    :cond_0
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 20
    :goto_1
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzajt;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 21
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzajt;->zzb(I)Z

    move-result p3

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(Z)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .line 24
    :cond_1
    :goto_2
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzajt;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 25
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzajt;->zzb(I)Z

    move-result v0

    invoke-virtual {p3, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(IZ)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_2

    :cond_2
    if-eqz p3, :cond_4

    .line 30
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 32
    :goto_3
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result v0

    if-ge p1, v0, :cond_3

    .line 33
    invoke-interface {p2, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Boolean;

    invoke-virtual {v0}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v0

    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(Z)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_3

    .line 35
    :cond_3
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 36
    :goto_4
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 37
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p3

    check-cast p3, Ljava/lang/Boolean;

    invoke-virtual {p3}, Ljava/lang/Boolean;->booleanValue()Z

    move-result p3

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(Z)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_4

    .line 40
    :cond_4
    :goto_5
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 41
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Boolean;

    invoke-virtual {v0}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v0

    invoke-virtual {p3, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(IZ)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_5

    :cond_5
    return-void
.end method

.method public final zza(IZ)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 9
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {v0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(IZ)V

    return-void
.end method

.method public final zzb(I)V
    .locals 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .annotation runtime Ljava/lang/Deprecated;
    .end annotation

    .line 487
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    const/4 v1, 0x3

    invoke-virtual {v0, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    return-void
.end method

.method public final zzb(II)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 127
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {v0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzg(II)V

    return-void
.end method

.method public final zzb(IJ)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 276
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    .line 277
    invoke-virtual {v0, p1, p2, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(IJ)V

    return-void
.end method

.method public final zzb(ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)V
    .locals 2
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 324
    check-cast p2, Lcom/google/android/gms/internal/firebase-auth-api/zzajm;

    .line 325
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    const/4 v1, 0x2

    invoke-virtual {v0, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    .line 326
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzajm;->zza(Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)I

    move-result v0

    invoke-virtual {p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 327
    invoke-interface {p3, p2, p0}, Lcom/google/android/gms/internal/firebase-auth-api/zzanb;->zza(Ljava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzaol;)V

    return-void
.end method

.method public final zzb(ILjava/util/List;)V
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 491
    instance-of v0, p2, Lcom/google/android/gms/internal/firebase-auth-api/zzalt;

    const/4 v1, 0x0

    if-eqz v0, :cond_1

    .line 492
    move-object v0, p2

    check-cast v0, Lcom/google/android/gms/internal/firebase-auth-api/zzalt;

    .line 493
    :goto_0
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result v2

    if-ge v1, v2, :cond_2

    .line 494
    invoke-interface {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzalt;->zza(I)Ljava/lang/Object;

    move-result-object v2

    .line 495
    instance-of v3, v2, Ljava/lang/String;

    if-eqz v3, :cond_0

    .line 496
    iget-object v3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    check-cast v2, Ljava/lang/String;

    invoke-virtual {v3, p1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(ILjava/lang/String;)V

    goto :goto_1

    .line 497
    :cond_0
    iget-object v3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    check-cast v2, Lcom/google/android/gms/internal/firebase-auth-api/zzajv;

    invoke-virtual {v3, p1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzc(ILcom/google/android/gms/internal/firebase-auth-api/zzajv;)V

    :goto_1
    add-int/lit8 v1, v1, 0x1

    goto :goto_0

    .line 500
    :cond_1
    :goto_2
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result v0

    if-ge v1, v0, :cond_2

    .line 501
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/String;

    invoke-virtual {v0, p1, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(ILjava/lang/String;)V

    add-int/lit8 v1, v1, 0x1

    goto :goto_2

    :cond_2
    return-void
.end method

.method public final zzb(ILjava/util/List;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)V
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I",
            "Ljava/util/List<",
            "*>;",
            "Lcom/google/android/gms/internal/firebase-auth-api/zzanb;",
            ")V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/4 v0, 0x0

    .line 329
    :goto_0
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result v1

    if-ge v0, v1, :cond_0

    .line 330
    invoke-interface {p2, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v1

    invoke-virtual {p0, p1, v1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zzb(ILjava/lang/Object;Lcom/google/android/gms/internal/firebase-auth-api/zzanb;)V

    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    :cond_0
    return-void
.end method

.method public final zzb(ILjava/util/List;Z)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I",
            "Ljava/util/List<",
            "Ljava/lang/Double;",
            ">;Z)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 52
    instance-of v0, p2, Lcom/google/android/gms/internal/firebase-auth-api/zzaks;

    const/4 v1, 0x2

    const/4 v2, 0x0

    if-eqz v0, :cond_2

    .line 53
    check-cast p2, Lcom/google/android/gms/internal/firebase-auth-api/zzaks;

    if-eqz p3, :cond_1

    .line 55
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 57
    :goto_0
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzaks;->size()I

    move-result v0

    if-ge p1, v0, :cond_0

    .line 58
    invoke-virtual {p2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzaks;->zzb(I)D

    move-result-wide v0

    invoke-static {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(D)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_0

    .line 60
    :cond_0
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 61
    :goto_1
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzaks;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 62
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzaks;->zzb(I)D

    move-result-wide v0

    invoke-virtual {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(D)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .line 65
    :cond_1
    :goto_2
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzaks;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 66
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzaks;->zzb(I)D

    move-result-wide v0

    invoke-virtual {p3, p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(ID)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_2

    :cond_2
    if-eqz p3, :cond_4

    .line 71
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 73
    :goto_3
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result v0

    if-ge p1, v0, :cond_3

    .line 74
    invoke-interface {p2, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Double;

    invoke-virtual {v0}, Ljava/lang/Double;->doubleValue()D

    move-result-wide v0

    invoke-static {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(D)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_3

    .line 76
    :cond_3
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 77
    :goto_4
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 78
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p3

    check-cast p3, Ljava/lang/Double;

    invoke-virtual {p3}, Ljava/lang/Double;->doubleValue()D

    move-result-wide v0

    invoke-virtual {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(D)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_4

    .line 81
    :cond_4
    :goto_5
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 82
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Double;

    invoke-virtual {v0}, Ljava/lang/Double;->doubleValue()D

    move-result-wide v0

    invoke-virtual {p3, p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(ID)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_5

    :cond_5
    return-void
.end method

.method public final zzc(II)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 241
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {v0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(II)V

    return-void
.end method

.method public final zzc(IJ)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 377
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    .line 378
    invoke-virtual {v0, p1, p2, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzf(IJ)V

    return-void
.end method

.method public final zzc(ILjava/util/List;Z)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I",
            "Ljava/util/List<",
            "Ljava/lang/Integer;",
            ">;Z)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 90
    instance-of v0, p2, Lcom/google/android/gms/internal/firebase-auth-api/zzali;

    const/4 v1, 0x2

    const/4 v2, 0x0

    if-eqz v0, :cond_2

    .line 91
    check-cast p2, Lcom/google/android/gms/internal/firebase-auth-api/zzali;

    if-eqz p3, :cond_1

    .line 93
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 95
    :goto_0
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->size()I

    move-result v0

    if-ge p1, v0, :cond_0

    .line 96
    invoke-virtual {p2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzb(I)I

    move-result v0

    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(I)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_0

    .line 98
    :cond_0
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 99
    :goto_1
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 100
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzb(I)I

    move-result p3

    .line 101
    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzk(I)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .line 104
    :cond_1
    :goto_2
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 105
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzb(I)I

    move-result v0

    .line 106
    invoke-virtual {p3, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(II)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_2

    :cond_2
    if-eqz p3, :cond_4

    .line 111
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 113
    :goto_3
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result v0

    if-ge p1, v0, :cond_3

    .line 114
    invoke-interface {p2, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(I)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_3

    .line 116
    :cond_3
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 117
    :goto_4
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 118
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p3

    check-cast p3, Ljava/lang/Integer;

    invoke-virtual {p3}, Ljava/lang/Integer;->intValue()I

    move-result p3

    .line 119
    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzk(I)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_4

    .line 122
    :cond_4
    :goto_5
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 123
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    .line 124
    invoke-virtual {p3, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(II)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_5

    :cond_5
    return-void
.end method

.method public final zzd(II)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 337
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    .line 338
    invoke-virtual {v0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzg(II)V

    return-void
.end method

.method public final zzd(IJ)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 452
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {v0, p1, p2, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzg(IJ)V

    return-void
.end method

.method public final zzd(ILjava/util/List;Z)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I",
            "Ljava/util/List<",
            "Ljava/lang/Integer;",
            ">;Z)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 129
    instance-of v0, p2, Lcom/google/android/gms/internal/firebase-auth-api/zzali;

    const/4 v1, 0x2

    const/4 v2, 0x0

    if-eqz v0, :cond_2

    .line 130
    check-cast p2, Lcom/google/android/gms/internal/firebase-auth-api/zzali;

    if-eqz p3, :cond_1

    .line 132
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 134
    :goto_0
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->size()I

    move-result v0

    if-ge p1, v0, :cond_0

    .line 135
    invoke-virtual {p2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzb(I)I

    move-result v0

    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(I)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_0

    .line 137
    :cond_0
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 138
    :goto_1
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 139
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzb(I)I

    move-result p3

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(I)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .line 142
    :cond_1
    :goto_2
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 143
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzb(I)I

    move-result v0

    invoke-virtual {p3, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzg(II)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_2

    :cond_2
    if-eqz p3, :cond_4

    .line 148
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 150
    :goto_3
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result v0

    if-ge p1, v0, :cond_3

    .line 151
    invoke-interface {p2, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(I)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_3

    .line 153
    :cond_3
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 154
    :goto_4
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 155
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p3

    check-cast p3, Ljava/lang/Integer;

    invoke-virtual {p3}, Ljava/lang/Integer;->intValue()I

    move-result p3

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(I)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_4

    .line 158
    :cond_4
    :goto_5
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 159
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    invoke-virtual {p3, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzg(II)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_5

    :cond_5
    return-void
.end method

.method public final zze(II)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 417
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {v0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzi(II)V

    return-void
.end method

.method public final zze(IJ)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 539
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {v0, p1, p2, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(IJ)V

    return-void
.end method

.method public final zze(ILjava/util/List;Z)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I",
            "Ljava/util/List<",
            "Ljava/lang/Long;",
            ">;Z)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 164
    instance-of v0, p2, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;

    const/4 v1, 0x2

    const/4 v2, 0x0

    if-eqz v0, :cond_2

    .line 165
    check-cast p2, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;

    if-eqz p3, :cond_1

    .line 167
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 169
    :goto_0
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->size()I

    move-result v0

    if-ge p1, v0, :cond_0

    .line 170
    invoke-virtual {p2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zzb(I)J

    move-result-wide v0

    invoke-static {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(J)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_0

    .line 172
    :cond_0
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 173
    :goto_1
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 174
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zzb(I)J

    move-result-wide v0

    invoke-virtual {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzf(J)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .line 177
    :cond_1
    :goto_2
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 178
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zzb(I)J

    move-result-wide v0

    invoke-virtual {p3, p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzf(IJ)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_2

    :cond_2
    if-eqz p3, :cond_4

    .line 183
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 185
    :goto_3
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result v0

    if-ge p1, v0, :cond_3

    .line 186
    invoke-interface {p2, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Long;

    invoke-virtual {v0}, Ljava/lang/Long;->longValue()J

    move-result-wide v0

    invoke-static {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(J)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_3

    .line 188
    :cond_3
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 189
    :goto_4
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 190
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p3

    check-cast p3, Ljava/lang/Long;

    invoke-virtual {p3}, Ljava/lang/Long;->longValue()J

    move-result-wide v0

    invoke-virtual {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzf(J)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_4

    .line 193
    :cond_4
    :goto_5
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 194
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Long;

    invoke-virtual {v0}, Ljava/lang/Long;->longValue()J

    move-result-wide v0

    invoke-virtual {p3, p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzf(IJ)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_5

    :cond_5
    return-void
.end method

.method public final zzf(II)V
    .locals 1
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 504
    iget-object v0, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {v0, p1, p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzk(II)V

    return-void
.end method

.method public final zzf(ILjava/util/List;Z)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I",
            "Ljava/util/List<",
            "Ljava/lang/Float;",
            ">;Z)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 199
    instance-of v0, p2, Lcom/google/android/gms/internal/firebase-auth-api/zzald;

    const/4 v1, 0x2

    const/4 v2, 0x0

    if-eqz v0, :cond_2

    .line 200
    check-cast p2, Lcom/google/android/gms/internal/firebase-auth-api/zzald;

    if-eqz p3, :cond_1

    .line 202
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 204
    :goto_0
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzald;->size()I

    move-result v0

    if-ge p1, v0, :cond_0

    .line 205
    invoke-virtual {p2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzald;->zzb(I)F

    move-result v0

    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(F)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_0

    .line 207
    :cond_0
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 208
    :goto_1
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzald;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 209
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzald;->zzb(I)F

    move-result p3

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(F)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .line 212
    :cond_1
    :goto_2
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzald;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 213
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzald;->zzb(I)F

    move-result v0

    invoke-virtual {p3, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(IF)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_2

    :cond_2
    if-eqz p3, :cond_4

    .line 218
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 220
    :goto_3
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result v0

    if-ge p1, v0, :cond_3

    .line 221
    invoke-interface {p2, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Float;

    invoke-virtual {v0}, Ljava/lang/Float;->floatValue()F

    move-result v0

    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zza(F)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_3

    .line 223
    :cond_3
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 224
    :goto_4
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 225
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p3

    check-cast p3, Ljava/lang/Float;

    invoke-virtual {p3}, Ljava/lang/Float;->floatValue()F

    move-result p3

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(F)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_4

    .line 228
    :cond_4
    :goto_5
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 229
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Float;

    invoke-virtual {v0}, Ljava/lang/Float;->floatValue()F

    move-result v0

    invoke-virtual {p3, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(IF)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_5

    :cond_5
    return-void
.end method

.method public final zzg(ILjava/util/List;Z)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I",
            "Ljava/util/List<",
            "Ljava/lang/Integer;",
            ">;Z)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 243
    instance-of v0, p2, Lcom/google/android/gms/internal/firebase-auth-api/zzali;

    const/4 v1, 0x2

    const/4 v2, 0x0

    if-eqz v0, :cond_2

    .line 244
    check-cast p2, Lcom/google/android/gms/internal/firebase-auth-api/zzali;

    if-eqz p3, :cond_1

    .line 246
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 248
    :goto_0
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->size()I

    move-result v0

    if-ge p1, v0, :cond_0

    .line 249
    invoke-virtual {p2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzb(I)I

    move-result v0

    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzc(I)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_0

    .line 251
    :cond_0
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 252
    :goto_1
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 253
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzb(I)I

    move-result p3

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzk(I)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .line 256
    :cond_1
    :goto_2
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 257
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzb(I)I

    move-result v0

    invoke-virtual {p3, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(II)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_2

    :cond_2
    if-eqz p3, :cond_4

    .line 262
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 264
    :goto_3
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result v0

    if-ge p1, v0, :cond_3

    .line 265
    invoke-interface {p2, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzc(I)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_3

    .line 267
    :cond_3
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 268
    :goto_4
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 269
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p3

    check-cast p3, Ljava/lang/Integer;

    invoke-virtual {p3}, Ljava/lang/Integer;->intValue()I

    move-result p3

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzk(I)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_4

    .line 272
    :cond_4
    :goto_5
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 273
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    invoke-virtual {p3, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(II)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_5

    :cond_5
    return-void
.end method

.method public final zzh(ILjava/util/List;Z)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I",
            "Ljava/util/List<",
            "Ljava/lang/Long;",
            ">;Z)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 279
    instance-of v0, p2, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;

    const/4 v1, 0x2

    const/4 v2, 0x0

    if-eqz v0, :cond_2

    .line 280
    check-cast p2, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;

    if-eqz p3, :cond_1

    .line 282
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 284
    :goto_0
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->size()I

    move-result v0

    if-ge p1, v0, :cond_0

    .line 285
    invoke-virtual {p2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zzb(I)J

    move-result-wide v0

    invoke-static {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(J)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_0

    .line 287
    :cond_0
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 288
    :goto_1
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 289
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zzb(I)J

    move-result-wide v0

    .line 290
    invoke-virtual {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(J)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .line 293
    :cond_1
    :goto_2
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 294
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zzb(I)J

    move-result-wide v0

    .line 295
    invoke-virtual {p3, p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(IJ)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_2

    :cond_2
    if-eqz p3, :cond_4

    .line 300
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 302
    :goto_3
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result v0

    if-ge p1, v0, :cond_3

    .line 303
    invoke-interface {p2, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Long;

    invoke-virtual {v0}, Ljava/lang/Long;->longValue()J

    move-result-wide v0

    invoke-static {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzb(J)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_3

    .line 305
    :cond_3
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 306
    :goto_4
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 307
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p3

    check-cast p3, Ljava/lang/Long;

    invoke-virtual {p3}, Ljava/lang/Long;->longValue()J

    move-result-wide v0

    .line 308
    invoke-virtual {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(J)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_4

    .line 311
    :cond_4
    :goto_5
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 312
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Long;

    invoke-virtual {v0}, Ljava/lang/Long;->longValue()J

    move-result-wide v0

    .line 313
    invoke-virtual {p3, p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(IJ)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_5

    :cond_5
    return-void
.end method

.method public final zzi(ILjava/util/List;Z)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I",
            "Ljava/util/List<",
            "Ljava/lang/Integer;",
            ">;Z)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 340
    instance-of v0, p2, Lcom/google/android/gms/internal/firebase-auth-api/zzali;

    const/4 v1, 0x2

    const/4 v2, 0x0

    if-eqz v0, :cond_2

    .line 341
    check-cast p2, Lcom/google/android/gms/internal/firebase-auth-api/zzali;

    if-eqz p3, :cond_1

    .line 343
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 345
    :goto_0
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->size()I

    move-result v0

    if-ge p1, v0, :cond_0

    .line 346
    invoke-virtual {p2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzb(I)I

    move-result v0

    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzf(I)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_0

    .line 348
    :cond_0
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 349
    :goto_1
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 350
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzb(I)I

    move-result p3

    .line 351
    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(I)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .line 354
    :cond_1
    :goto_2
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 355
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzb(I)I

    move-result v0

    .line 356
    invoke-virtual {p3, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzg(II)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_2

    :cond_2
    if-eqz p3, :cond_4

    .line 361
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 363
    :goto_3
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result v0

    if-ge p1, v0, :cond_3

    .line 364
    invoke-interface {p2, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzf(I)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_3

    .line 366
    :cond_3
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 367
    :goto_4
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 368
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p3

    check-cast p3, Ljava/lang/Integer;

    invoke-virtual {p3}, Ljava/lang/Integer;->intValue()I

    move-result p3

    .line 369
    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(I)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_4

    .line 372
    :cond_4
    :goto_5
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 373
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    .line 374
    invoke-virtual {p3, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzg(II)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_5

    :cond_5
    return-void
.end method

.method public final zzj(ILjava/util/List;Z)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I",
            "Ljava/util/List<",
            "Ljava/lang/Long;",
            ">;Z)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 380
    instance-of v0, p2, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;

    const/4 v1, 0x2

    const/4 v2, 0x0

    if-eqz v0, :cond_2

    .line 381
    check-cast p2, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;

    if-eqz p3, :cond_1

    .line 383
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 385
    :goto_0
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->size()I

    move-result v0

    if-ge p1, v0, :cond_0

    .line 386
    invoke-virtual {p2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zzb(I)J

    move-result-wide v0

    invoke-static {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzc(J)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_0

    .line 388
    :cond_0
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 389
    :goto_1
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 390
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zzb(I)J

    move-result-wide v0

    .line 391
    invoke-virtual {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzf(J)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .line 394
    :cond_1
    :goto_2
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 395
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zzb(I)J

    move-result-wide v0

    .line 396
    invoke-virtual {p3, p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzf(IJ)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_2

    :cond_2
    if-eqz p3, :cond_4

    .line 401
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 403
    :goto_3
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result v0

    if-ge p1, v0, :cond_3

    .line 404
    invoke-interface {p2, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Long;

    invoke-virtual {v0}, Ljava/lang/Long;->longValue()J

    move-result-wide v0

    invoke-static {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzc(J)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_3

    .line 406
    :cond_3
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 407
    :goto_4
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 408
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p3

    check-cast p3, Ljava/lang/Long;

    invoke-virtual {p3}, Ljava/lang/Long;->longValue()J

    move-result-wide v0

    .line 409
    invoke-virtual {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzf(J)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_4

    .line 412
    :cond_4
    :goto_5
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 413
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Long;

    invoke-virtual {v0}, Ljava/lang/Long;->longValue()J

    move-result-wide v0

    .line 414
    invoke-virtual {p3, p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzf(IJ)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_5

    :cond_5
    return-void
.end method

.method public final zzk(ILjava/util/List;Z)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I",
            "Ljava/util/List<",
            "Ljava/lang/Integer;",
            ">;Z)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 419
    instance-of v0, p2, Lcom/google/android/gms/internal/firebase-auth-api/zzali;

    const/4 v1, 0x2

    const/4 v2, 0x0

    if-eqz v0, :cond_2

    .line 420
    check-cast p2, Lcom/google/android/gms/internal/firebase-auth-api/zzali;

    if-eqz p3, :cond_1

    .line 422
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 424
    :goto_0
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->size()I

    move-result v0

    if-ge p1, v0, :cond_0

    .line 425
    invoke-virtual {p2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzb(I)I

    move-result v0

    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzg(I)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_0

    .line 427
    :cond_0
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 428
    :goto_1
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 429
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzb(I)I

    move-result p3

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzl(I)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .line 432
    :cond_1
    :goto_2
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 433
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzb(I)I

    move-result v0

    invoke-virtual {p3, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzi(II)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_2

    :cond_2
    if-eqz p3, :cond_4

    .line 438
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 440
    :goto_3
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result v0

    if-ge p1, v0, :cond_3

    .line 441
    invoke-interface {p2, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzg(I)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_3

    .line 443
    :cond_3
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 444
    :goto_4
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 445
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p3

    check-cast p3, Ljava/lang/Integer;

    invoke-virtual {p3}, Ljava/lang/Integer;->intValue()I

    move-result p3

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzl(I)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_4

    .line 448
    :cond_4
    :goto_5
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 449
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    invoke-virtual {p3, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzi(II)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_5

    :cond_5
    return-void
.end method

.method public final zzl(ILjava/util/List;Z)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I",
            "Ljava/util/List<",
            "Ljava/lang/Long;",
            ">;Z)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 454
    instance-of v0, p2, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;

    const/4 v1, 0x2

    const/4 v2, 0x0

    if-eqz v0, :cond_2

    .line 455
    check-cast p2, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;

    if-eqz p3, :cond_1

    .line 457
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 459
    :goto_0
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->size()I

    move-result v0

    if-ge p1, v0, :cond_0

    .line 460
    invoke-virtual {p2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zzb(I)J

    move-result-wide v0

    invoke-static {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzd(J)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_0

    .line 462
    :cond_0
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 463
    :goto_1
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 464
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zzb(I)J

    move-result-wide v0

    invoke-virtual {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzg(J)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .line 467
    :cond_1
    :goto_2
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 468
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zzb(I)J

    move-result-wide v0

    invoke-virtual {p3, p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzg(IJ)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_2

    :cond_2
    if-eqz p3, :cond_4

    .line 473
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 475
    :goto_3
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result v0

    if-ge p1, v0, :cond_3

    .line 476
    invoke-interface {p2, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Long;

    invoke-virtual {v0}, Ljava/lang/Long;->longValue()J

    move-result-wide v0

    invoke-static {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzd(J)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_3

    .line 478
    :cond_3
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 479
    :goto_4
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 480
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p3

    check-cast p3, Ljava/lang/Long;

    invoke-virtual {p3}, Ljava/lang/Long;->longValue()J

    move-result-wide v0

    invoke-virtual {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzg(J)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_4

    .line 483
    :cond_4
    :goto_5
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 484
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Long;

    invoke-virtual {v0}, Ljava/lang/Long;->longValue()J

    move-result-wide v0

    invoke-virtual {p3, p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzg(IJ)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_5

    :cond_5
    return-void
.end method

.method public final zzm(ILjava/util/List;Z)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I",
            "Ljava/util/List<",
            "Ljava/lang/Integer;",
            ">;Z)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 506
    instance-of v0, p2, Lcom/google/android/gms/internal/firebase-auth-api/zzali;

    const/4 v1, 0x2

    const/4 v2, 0x0

    if-eqz v0, :cond_2

    .line 507
    check-cast p2, Lcom/google/android/gms/internal/firebase-auth-api/zzali;

    if-eqz p3, :cond_1

    .line 509
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 511
    :goto_0
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->size()I

    move-result v0

    if-ge p1, v0, :cond_0

    .line 512
    invoke-virtual {p2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzb(I)I

    move-result v0

    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzi(I)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_0

    .line 514
    :cond_0
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 515
    :goto_1
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 516
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzb(I)I

    move-result p3

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .line 519
    :cond_1
    :goto_2
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 520
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzali;->zzb(I)I

    move-result v0

    invoke-virtual {p3, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzk(II)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_2

    :cond_2
    if-eqz p3, :cond_4

    .line 525
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 527
    :goto_3
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result v0

    if-ge p1, v0, :cond_3

    .line 528
    invoke-interface {p2, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    invoke-static {v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzi(I)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_3

    .line 530
    :cond_3
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 531
    :goto_4
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 532
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p3

    check-cast p3, Ljava/lang/Integer;

    invoke-virtual {p3}, Ljava/lang/Integer;->intValue()I

    move-result p3

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_4

    .line 535
    :cond_4
    :goto_5
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 536
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    invoke-virtual {p3, p1, v0}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzk(II)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_5

    :cond_5
    return-void
.end method

.method public final zzn(ILjava/util/List;Z)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I",
            "Ljava/util/List<",
            "Ljava/lang/Long;",
            ">;Z)V"
        }
    .end annotation

    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    .line 541
    instance-of v0, p2, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;

    const/4 v1, 0x2

    const/4 v2, 0x0

    if-eqz v0, :cond_2

    .line 542
    check-cast p2, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;

    if-eqz p3, :cond_1

    .line 544
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 546
    :goto_0
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->size()I

    move-result v0

    if-ge p1, v0, :cond_0

    .line 547
    invoke-virtual {p2, p1}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zzb(I)J

    move-result-wide v0

    invoke-static {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zze(J)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_0

    .line 549
    :cond_0
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 550
    :goto_1
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 551
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zzb(I)J

    move-result-wide v0

    invoke-virtual {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(J)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .line 554
    :cond_1
    :goto_2
    invoke-virtual {p2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 555
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p2, v2}, Lcom/google/android/gms/internal/firebase-auth-api/zzalx;->zzb(I)J

    move-result-wide v0

    invoke-virtual {p3, p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(IJ)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_2

    :cond_2
    if-eqz p3, :cond_4

    .line 560
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p3, p1, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzj(II)V

    move p1, v2

    move p3, p1

    .line 562
    :goto_3
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result v0

    if-ge p1, v0, :cond_3

    .line 563
    invoke-interface {p2, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Long;

    invoke-virtual {v0}, Ljava/lang/Long;->longValue()J

    move-result-wide v0

    invoke-static {v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zze(J)I

    move-result v0

    add-int/2addr p3, v0

    add-int/lit8 p1, p1, 0x1

    goto :goto_3

    .line 565
    :cond_3
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-virtual {p1, p3}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzm(I)V

    .line 566
    :goto_4
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p1

    if-ge v2, p1, :cond_5

    .line 567
    iget-object p1, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p3

    check-cast p3, Ljava/lang/Long;

    invoke-virtual {p3}, Ljava/lang/Long;->longValue()J

    move-result-wide v0

    invoke-virtual {p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(J)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_4

    .line 570
    :cond_4
    :goto_5
    invoke-interface {p2}, Ljava/util/List;->size()I

    move-result p3

    if-ge v2, p3, :cond_5

    .line 571
    iget-object p3, p0, Lcom/google/android/gms/internal/firebase-auth-api/zzakp;->zza:Lcom/google/android/gms/internal/firebase-auth-api/zzakn;

    invoke-interface {p2, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Long;

    invoke-virtual {v0}, Ljava/lang/Long;->longValue()J

    move-result-wide v0

    invoke-virtual {p3, p1, v0, v1}, Lcom/google/android/gms/internal/firebase-auth-api/zzakn;->zzh(IJ)V

    add-int/lit8 v2, v2, 0x1

    goto :goto_5

    :cond_5
    return-void
.end method
