.class public final Lcom/google/android/recaptcha/internal/zzeu;
.super Ljava/lang/Object;
.source "com.google.android.recaptcha:recaptcha@@18.6.1"

# interfaces
.implements Lcom/google/android/recaptcha/internal/zzet;


# instance fields
.field private final zza:Ljava/lang/String;


# direct methods
.method public constructor <init>(Ljava/lang/String;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/google/android/recaptcha/internal/zzeu;->zza:Ljava/lang/String;

    return-void
.end method

.method private static final zzb([B)V
    .locals 5

    .line 1
    invoke-static {p0}, Lcom/google/android/recaptcha/internal/zzrf;->zzk([B)Lcom/google/android/recaptcha/internal/zzrf;

    move-result-object p0

    invoke-virtual {p0}, Lcom/google/android/recaptcha/internal/zzrf;->zzl()Ljava/util/List;

    move-result-object p0

    invoke-interface {p0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object p0

    :goto_0
    invoke-interface {p0}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_1

    invoke-interface {p0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/google/android/recaptcha/internal/zzrc;

    const/4 v1, 0x2

    new-array v1, v1, [Ljava/lang/String;

    const/4 v2, 0x0

    const-string v3, "INIT_TOTAL"

    aput-object v3, v1, v2

    const/4 v2, 0x1

    const-string v4, "EXECUTE_TOTAL"

    aput-object v4, v1, v2

    .line 2
    invoke-static {v1}, Lkotlin/collections/CollectionsKt;->listOf([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v1

    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzrc;->zzY()I

    move-result v2

    packed-switch v2, :pswitch_data_0

    const-string v3, "UNRECOGNIZED"

    goto/16 :goto_1

    .line 7
    :pswitch_0
    const-string v3, "WEBVIEW_INITIALIZATION"

    goto/16 :goto_1

    :pswitch_1
    const-string v3, "INIT_ATTEMPT"

    goto/16 :goto_1

    :pswitch_2
    const-string v3, "GMSCORE_ENGINE_SIGNAL_COLLECTION"

    goto/16 :goto_1

    :pswitch_3
    const-string v3, "GMSCORE_ENGINE_INITIALIZATION"

    goto/16 :goto_1

    :pswitch_4
    const-string v3, "PIA_WARMUP"

    goto/16 :goto_1

    :pswitch_5
    const-string v3, "NATIVE_SIGNAL_COLLECTION"

    goto/16 :goto_1

    :pswitch_6
    const-string v3, "NATIVE_SIGNAL_INITIALIZATION"

    goto/16 :goto_1

    :pswitch_7
    const-string v3, "NATIVE_ENGINE_SIGNAL_COLLECTION"

    goto/16 :goto_1

    :pswitch_8
    const-string v3, "NATIVE_ENGINE_INITIALIZATION"

    goto/16 :goto_1

    :pswitch_9
    const-string v3, "WEBVIEW_ENGINE_SIGNAL_COLLECTION"

    goto/16 :goto_1

    :pswitch_a
    const-string v3, "WEBVIEW_ENGINE_INITIALIATION"

    goto/16 :goto_1

    :pswitch_b
    const-string v3, "SIGNAL_MANAGER_COLLECT_SIGNALS"

    goto/16 :goto_1

    :pswitch_c
    const-string v3, "SIGNAL_MANAGER_INITIALIZATION"

    goto/16 :goto_1

    :pswitch_d
    const-string v3, "POST_EXECUTE"

    goto/16 :goto_1

    :pswitch_e
    const-string v3, "FETCH_TOKEN"

    goto :goto_1

    :pswitch_f
    const-string v3, "COLLECT_SIGNALS"

    goto :goto_1

    :pswitch_10
    const-string v3, "LOAD_WEBVIEW"

    goto :goto_1

    :pswitch_11
    const-string v3, "LOAD_CACHE_JS"

    goto :goto_1

    :pswitch_12
    const-string v3, "SAVE_CACHE_JS"

    goto :goto_1

    :pswitch_13
    const-string v3, "DOWNLOAD_JS"

    goto :goto_1

    :pswitch_14
    const-string v3, "VALIDATE_INPUT"

    goto :goto_1

    :pswitch_15
    const-string v3, "INIT_DOWNLOAD_JS"

    goto :goto_1

    :pswitch_16
    const-string v3, "INIT_NETWORK_MRI_ACTION"

    goto :goto_1

    :pswitch_17
    const-string v3, "WEB_VIEW_RELOAD_JS"

    goto :goto_1

    :pswitch_18
    const-string v3, "JS_LOAD"

    goto :goto_1

    :pswitch_19
    const-string v3, "FETCH_ALLOWLIST"

    goto :goto_1

    :pswitch_1a
    const-string v3, "RUN_PROGRAM"

    goto :goto_1

    :pswitch_1b
    const-string v3, "VERIFY_PIN_TOTAL"

    goto :goto_1

    :pswitch_1c
    const-string v3, "VERIFY_PIN_JS"

    goto :goto_1

    :pswitch_1d
    const-string v3, "VERIFY_PIN_NATIVE"

    goto :goto_1

    :pswitch_1e
    const-string v3, "CHALLENGE_ACCOUNT_TOTAL"

    goto :goto_1

    :pswitch_1f
    const-string v3, "CHALLENGE_ACCOUNT_JS"

    goto :goto_1

    :pswitch_20
    const-string v3, "CHALLENGE_ACCOUNT_NATIVE"

    goto :goto_1

    :pswitch_21
    move-object v3, v4

    goto :goto_1

    :pswitch_22
    const-string v3, "EXECUTE_JS"

    goto :goto_1

    :pswitch_23
    const-string v3, "EXECUTE_NATIVE"

    goto :goto_1

    :pswitch_24
    const-string v3, "INIT_JS"

    goto :goto_1

    :pswitch_25
    const-string v3, "INIT_NETWORK"

    goto :goto_1

    :pswitch_26
    const-string v3, "INIT_NATIVE"

    goto :goto_1

    :pswitch_27
    const-string v3, "UNKNOWN"

    .line 2
    :goto_1
    :pswitch_28
    invoke-interface {v1, v3}, Ljava/util/List;->contains(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 3
    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzrc;->zzX()Z

    move-result v1

    if-eqz v1, :cond_0

    .line 8
    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzrc;->zzM()Ljava/lang/String;

    .line 9
    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzrc;->zzN()Ljava/lang/String;

    .line 10
    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzrc;->zzY()I

    .line 11
    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzrc;->zzg()Lcom/google/android/recaptcha/internal/zzqq;

    move-result-object v1

    invoke-virtual {v1}, Lcom/google/android/recaptcha/internal/zzqq;->zzk()Ljava/lang/String;

    .line 12
    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzrc;->zzg()Lcom/google/android/recaptcha/internal/zzqq;

    move-result-object v1

    invoke-virtual {v1}, Lcom/google/android/recaptcha/internal/zzqq;->zzf()I

    .line 13
    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzrc;->zzZ()I

    goto/16 :goto_0

    .line 4
    :cond_0
    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzrc;->zzM()Ljava/lang/String;

    .line 5
    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzrc;->zzN()Ljava/lang/String;

    .line 6
    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzrc;->zzY()I

    .line 7
    invoke-virtual {v0}, Lcom/google/android/recaptcha/internal/zzrc;->zzZ()I

    goto/16 :goto_0

    :cond_1
    return-void

    nop

    :pswitch_data_0
    .packed-switch 0x2
        :pswitch_27
        :pswitch_26
        :pswitch_25
        :pswitch_24
        :pswitch_28
        :pswitch_23
        :pswitch_22
        :pswitch_21
        :pswitch_20
        :pswitch_1f
        :pswitch_1e
        :pswitch_1d
        :pswitch_1c
        :pswitch_1b
        :pswitch_1a
        :pswitch_19
        :pswitch_18
        :pswitch_17
        :pswitch_16
        :pswitch_15
        :pswitch_14
        :pswitch_13
        :pswitch_12
        :pswitch_11
        :pswitch_10
        :pswitch_f
        :pswitch_e
        :pswitch_d
        :pswitch_c
        :pswitch_b
        :pswitch_a
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
.method public final zza([B)Z
    .locals 5

    const/4 v0, 0x0

    .line 1
    :try_start_0
    invoke-static {}, Ljava/lang/Thread;->currentThread()Ljava/lang/Thread;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Thread;->getId()J

    move-result-wide v1

    long-to-int v1, v1

    invoke-static {v1}, Landroid/net/TrafficStats;->setThreadStatsTag(I)V

    .line 2
    invoke-static {p1}, Lcom/google/android/recaptcha/internal/zzeu;->zzb([B)V

    iget-object v1, p0, Lcom/google/android/recaptcha/internal/zzeu;->zza:Ljava/lang/String;

    .line 3
    invoke-static {v1}, Landroid/webkit/URLUtil;->isHttpUrl(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 4
    new-instance v1, Ljava/net/URL;

    iget-object v2, p0, Lcom/google/android/recaptcha/internal/zzeu;->zza:Ljava/lang/String;

    invoke-direct {v1, v2}, Ljava/net/URL;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1}, Ljava/net/URL;->openConnection()Ljava/net/URLConnection;

    move-result-object v1

    const-string v2, "null cannot be cast to non-null type java.net.HttpURLConnection"

    invoke-static {v1, v2}, Lkotlin/jvm/internal/Intrinsics;->checkNotNull(Ljava/lang/Object;Ljava/lang/String;)V

    check-cast v1, Ljava/net/HttpURLConnection;

    goto :goto_0

    .line 13
    :cond_0
    iget-object v1, p0, Lcom/google/android/recaptcha/internal/zzeu;->zza:Ljava/lang/String;

    .line 5
    invoke-static {v1}, Landroid/webkit/URLUtil;->isHttpsUrl(Ljava/lang/String;)Z

    move-result v1

    if-eqz v1, :cond_2

    .line 6
    new-instance v1, Ljava/net/URL;

    iget-object v2, p0, Lcom/google/android/recaptcha/internal/zzeu;->zza:Ljava/lang/String;

    invoke-direct {v1, v2}, Ljava/net/URL;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1}, Ljava/net/URL;->openConnection()Ljava/net/URLConnection;

    move-result-object v1

    const-string v2, "null cannot be cast to non-null type javax.net.ssl.HttpsURLConnection"

    invoke-static {v1, v2}, Lkotlin/jvm/internal/Intrinsics;->checkNotNull(Ljava/lang/Object;Ljava/lang/String;)V

    check-cast v1, Ljavax/net/ssl/HttpsURLConnection;

    check-cast v1, Ljava/net/HttpURLConnection;

    .line 4
    :goto_0
    const-string v2, "POST"

    .line 7
    invoke-virtual {v1, v2}, Ljava/net/HttpURLConnection;->setRequestMethod(Ljava/lang/String;)V

    const/4 v2, 0x1

    .line 8
    invoke-virtual {v1, v2}, Ljava/net/HttpURLConnection;->setDoOutput(Z)V

    const-string v3, "Content-Type"

    const-string v4, "application/x-protobuffer"

    .line 9
    invoke-virtual {v1, v3, v4}, Ljava/net/HttpURLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    .line 10
    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->connect()V

    .line 11
    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->getOutputStream()Ljava/io/OutputStream;

    move-result-object v3

    .line 12
    invoke-virtual {v3, p1}, Ljava/io/OutputStream;->write([B)V

    .line 13
    invoke-virtual {v1}, Ljava/net/HttpURLConnection;->getResponseCode()I

    move-result p1

    const/16 v1, 0xc8

    if-ne p1, v1, :cond_1

    return v2

    :cond_1
    return v0

    .line 14
    :cond_2
    new-instance p1, Ljava/net/MalformedURLException;

    const-string v1, "Recaptcha server url only allows using Http or Https."

    invoke-direct {p1, v1}, Ljava/net/MalformedURLException;-><init>(Ljava/lang/String;)V

    throw p1
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    :catch_0
    move-exception p1

    .line 15
    invoke-virtual {p1}, Ljava/lang/Exception;->getMessage()Ljava/lang/String;

    return v0
.end method
