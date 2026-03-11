.class public final Lio/flutter/plugins/firebase/analytics/Constants;
.super Ljava/lang/Object;
.source "Constants.kt"


# annotations
.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000\u0014\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\u0008\u0003\n\u0002\u0010\u000e\n\u0002\u0008\u000b\u0008\u00c6\u0002\u0018\u00002\u00020\u0001B\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003R\u000e\u0010\u0004\u001a\u00020\u0005X\u0086T\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0006\u001a\u00020\u0005X\u0086T\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0007\u001a\u00020\u0005X\u0086T\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0008\u001a\u00020\u0005X\u0086T\u00a2\u0006\u0002\n\u0000R\u000e\u0010\t\u001a\u00020\u0005X\u0086T\u00a2\u0006\u0002\n\u0000R\u000e\u0010\n\u001a\u00020\u0005X\u0086T\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u000b\u001a\u00020\u0005X\u0086T\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u000c\u001a\u00020\u0005X\u0086T\u00a2\u0006\u0002\n\u0000R\u000e\u0010\r\u001a\u00020\u0005X\u0086T\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u000e\u001a\u00020\u0005X\u0086T\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u000f\u001a\u00020\u0005X\u0086T\u00a2\u0006\u0002\n\u0000\u00a8\u0006\u0010"
    }
    d2 = {
        "Lio/flutter/plugins/firebase/analytics/Constants;",
        "",
        "<init>",
        "()V",
        "AD_STORAGE_CONSENT_GRANTED",
        "",
        "ANALYTICS_STORAGE_CONSENT_GRANTED",
        "AD_PERSONALIZATION_SIGNALS_CONSENT_GRANTED",
        "AD_USER_DATA_CONSENT_GRANTED",
        "USER_ID",
        "EVENT_NAME",
        "PARAMETERS",
        "ENABLED",
        "MILLISECONDS",
        "NAME",
        "VALUE",
        "firebase_analytics_release"
    }
    k = 0x1
    mv = {
        0x2,
        0x2,
        0x0
    }
    xi = 0x30
.end annotation


# static fields
.field public static final AD_PERSONALIZATION_SIGNALS_CONSENT_GRANTED:Ljava/lang/String; = "adPersonalizationSignalsConsentGranted"

.field public static final AD_STORAGE_CONSENT_GRANTED:Ljava/lang/String; = "adStorageConsentGranted"

.field public static final AD_USER_DATA_CONSENT_GRANTED:Ljava/lang/String; = "adUserDataConsentGranted"

.field public static final ANALYTICS_STORAGE_CONSENT_GRANTED:Ljava/lang/String; = "analyticsStorageConsentGranted"

.field public static final ENABLED:Ljava/lang/String; = "enabled"

.field public static final EVENT_NAME:Ljava/lang/String; = "eventName"

.field public static final INSTANCE:Lio/flutter/plugins/firebase/analytics/Constants;

.field public static final MILLISECONDS:Ljava/lang/String; = "milliseconds"

.field public static final NAME:Ljava/lang/String; = "name"

.field public static final PARAMETERS:Ljava/lang/String; = "parameters"

.field public static final USER_ID:Ljava/lang/String; = "userId"

.field public static final VALUE:Ljava/lang/String; = "value"


# direct methods
.method static constructor <clinit>()V
    .locals 1

    new-instance v0, Lio/flutter/plugins/firebase/analytics/Constants;

    invoke-direct {v0}, Lio/flutter/plugins/firebase/analytics/Constants;-><init>()V

    sput-object v0, Lio/flutter/plugins/firebase/analytics/Constants;->INSTANCE:Lio/flutter/plugins/firebase/analytics/Constants;

    return-void
.end method

.method private constructor <init>()V
    .locals 0

    .line 7
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method
