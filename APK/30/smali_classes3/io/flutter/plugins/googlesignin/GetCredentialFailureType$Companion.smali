.class public final Lio/flutter/plugins/googlesignin/GetCredentialFailureType$Companion;
.super Ljava/lang/Object;
.source "Messages.kt"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/plugins/googlesignin/GetCredentialFailureType;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "Companion"
.end annotation

.annotation system Ldalvik/annotation/SourceDebugExtension;
    value = "SMAP\nMessages.kt\nKotlin\n*S Kotlin\n*F\n+ 1 Messages.kt\nio/flutter/plugins/googlesignin/GetCredentialFailureType$Companion\n+ 2 _Arrays.kt\nkotlin/collections/ArraysKt___ArraysKt\n*L\n1#1,827:1\n1400#2,2:828\n*S KotlinDebug\n*F\n+ 1 Messages.kt\nio/flutter/plugins/googlesignin/GetCredentialFailureType$Companion\n*L\n100#1:828,2\n*E\n"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000\u0018\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\u0008\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0008\n\u0000\u0008\u0086\u0003\u0018\u00002\u00020\u0001B\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003J\u0010\u0010\u0004\u001a\u0004\u0018\u00010\u00052\u0006\u0010\u0006\u001a\u00020\u0007\u00a8\u0006\u0008"
    }
    d2 = {
        "Lio/flutter/plugins/googlesignin/GetCredentialFailureType$Companion;",
        "",
        "<init>",
        "()V",
        "ofRaw",
        "Lio/flutter/plugins/googlesignin/GetCredentialFailureType;",
        "raw",
        "",
        "google_sign_in_android_release"
    }
    k = 0x1
    mv = {
        0x2,
        0x2,
        0x0
    }
    xi = 0x30
.end annotation


# direct methods
.method private constructor <init>()V
    .locals 0

    .line 98
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public synthetic constructor <init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V
    .locals 0

    invoke-direct {p0}, Lio/flutter/plugins/googlesignin/GetCredentialFailureType$Companion;-><init>()V

    return-void
.end method


# virtual methods
.method public final ofRaw(I)Lio/flutter/plugins/googlesignin/GetCredentialFailureType;
    .locals 5

    .line 100
    invoke-static {}, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->values()[Lio/flutter/plugins/googlesignin/GetCredentialFailureType;

    move-result-object v0

    .line 828
    array-length v1, v0

    const/4 v2, 0x0

    :goto_0
    if-ge v2, v1, :cond_1

    aget-object v3, v0, v2

    .line 100
    invoke-virtual {v3}, Lio/flutter/plugins/googlesignin/GetCredentialFailureType;->getRaw()I

    move-result v4

    if-ne v4, p1, :cond_0

    return-object v3

    :cond_0
    add-int/lit8 v2, v2, 0x1

    goto :goto_0

    :cond_1
    const/4 p1, 0x0

    return-object p1
.end method
