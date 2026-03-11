.class public Lio/flutter/view/AccessibilityStringBuilder;
.super Ljava/lang/Object;
.source "AccessibilityStringBuilder.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lio/flutter/view/AccessibilityStringBuilder$StringAttribute;,
        Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;,
        Lio/flutter/view/AccessibilityStringBuilder$LocaleStringAttribute;,
        Lio/flutter/view/AccessibilityStringBuilder$UrlStringAttribute;,
        Lio/flutter/view/AccessibilityStringBuilder$SpellOutStringAttribute;
    }
.end annotation


# instance fields
.field private attributes:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List<",
            "Lio/flutter/view/AccessibilityStringBuilder$StringAttribute;",
            ">;"
        }
    .end annotation
.end field

.field private locale:Ljava/lang/String;

.field private string:Ljava/lang/String;

.field private url:Ljava/lang/String;


# direct methods
.method constructor <init>()V
    .locals 0

    .line 48
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method addAttributes(Ljava/util/List;)Lio/flutter/view/AccessibilityStringBuilder;
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Lio/flutter/view/AccessibilityStringBuilder$StringAttribute;",
            ">;)",
            "Lio/flutter/view/AccessibilityStringBuilder;"
        }
    .end annotation

    .line 61
    iput-object p1, p0, Lio/flutter/view/AccessibilityStringBuilder;->attributes:Ljava/util/List;

    return-object p0
.end method

.method addLocale(Ljava/lang/String;)Lio/flutter/view/AccessibilityStringBuilder;
    .locals 0

    .line 66
    iput-object p1, p0, Lio/flutter/view/AccessibilityStringBuilder;->locale:Ljava/lang/String;

    return-object p0
.end method

.method addString(Ljava/lang/String;)Lio/flutter/view/AccessibilityStringBuilder;
    .locals 0

    .line 56
    iput-object p1, p0, Lio/flutter/view/AccessibilityStringBuilder;->string:Ljava/lang/String;

    return-object p0
.end method

.method addUrl(Ljava/lang/String;)Lio/flutter/view/AccessibilityStringBuilder;
    .locals 0

    .line 71
    iput-object p1, p0, Lio/flutter/view/AccessibilityStringBuilder;->url:Ljava/lang/String;

    return-object p0
.end method

.method build()Ljava/lang/CharSequence;
    .locals 6

    .line 76
    iget-object v0, p0, Lio/flutter/view/AccessibilityStringBuilder;->string:Ljava/lang/String;

    if-nez v0, :cond_0

    const/4 v0, 0x0

    return-object v0

    .line 79
    :cond_0
    new-instance v0, Landroid/text/SpannableString;

    iget-object v1, p0, Lio/flutter/view/AccessibilityStringBuilder;->string:Ljava/lang/String;

    invoke-direct {v0, v1}, Landroid/text/SpannableString;-><init>(Ljava/lang/CharSequence;)V

    .line 80
    iget-object v1, p0, Lio/flutter/view/AccessibilityStringBuilder;->attributes:Ljava/util/List;

    const/4 v2, 0x0

    if-eqz v1, :cond_3

    .line 81
    invoke-interface {v1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_3

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Lio/flutter/view/AccessibilityStringBuilder$StringAttribute;

    .line 82
    iget-object v4, v3, Lio/flutter/view/AccessibilityStringBuilder$StringAttribute;->type:Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;

    invoke-virtual {v4}, Lio/flutter/view/AccessibilityStringBuilder$StringAttributeType;->ordinal()I

    move-result v4

    if-eqz v4, :cond_2

    const/4 v5, 0x1

    if-eq v4, v5, :cond_1

    goto :goto_0

    .line 91
    :cond_1
    move-object v4, v3

    check-cast v4, Lio/flutter/view/AccessibilityStringBuilder$LocaleStringAttribute;

    .line 92
    iget-object v4, v4, Lio/flutter/view/AccessibilityStringBuilder$LocaleStringAttribute;->locale:Ljava/lang/String;

    invoke-static {v4}, Ljava/util/Locale;->forLanguageTag(Ljava/lang/String;)Ljava/util/Locale;

    move-result-object v4

    .line 93
    new-instance v5, Landroid/text/style/LocaleSpan;

    invoke-direct {v5, v4}, Landroid/text/style/LocaleSpan;-><init>(Ljava/util/Locale;)V

    .line 94
    iget v4, v3, Lio/flutter/view/AccessibilityStringBuilder$StringAttribute;->start:I

    iget v3, v3, Lio/flutter/view/AccessibilityStringBuilder$StringAttribute;->end:I

    invoke-virtual {v0, v5, v4, v3, v2}, Landroid/text/SpannableString;->setSpan(Ljava/lang/Object;III)V

    goto :goto_0

    .line 85
    :cond_2
    new-instance v4, Landroid/text/style/TtsSpan$Builder;

    const-string v5, "android.type.verbatim"

    invoke-direct {v4, v5}, Landroid/text/style/TtsSpan$Builder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v4}, Landroid/text/style/TtsSpan$Builder;->build()Landroid/text/style/TtsSpan;

    move-result-object v4

    .line 86
    iget v5, v3, Lio/flutter/view/AccessibilityStringBuilder$StringAttribute;->start:I

    iget v3, v3, Lio/flutter/view/AccessibilityStringBuilder$StringAttribute;->end:I

    invoke-virtual {v0, v4, v5, v3, v2}, Landroid/text/SpannableString;->setSpan(Ljava/lang/Object;III)V

    goto :goto_0

    .line 100
    :cond_3
    iget-object v1, p0, Lio/flutter/view/AccessibilityStringBuilder;->url:Ljava/lang/String;

    if-eqz v1, :cond_4

    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-nez v1, :cond_4

    .line 101
    new-instance v1, Landroid/text/style/URLSpan;

    iget-object v3, p0, Lio/flutter/view/AccessibilityStringBuilder;->url:Ljava/lang/String;

    invoke-direct {v1, v3}, Landroid/text/style/URLSpan;-><init>(Ljava/lang/String;)V

    .line 102
    iget-object v3, p0, Lio/flutter/view/AccessibilityStringBuilder;->string:Ljava/lang/String;

    invoke-virtual {v3}, Ljava/lang/String;->length()I

    move-result v3

    invoke-virtual {v0, v1, v2, v3, v2}, Landroid/text/SpannableString;->setSpan(Ljava/lang/Object;III)V

    .line 105
    :cond_4
    iget-object v1, p0, Lio/flutter/view/AccessibilityStringBuilder;->locale:Ljava/lang/String;

    if-eqz v1, :cond_5

    invoke-virtual {v1}, Ljava/lang/String;->isEmpty()Z

    move-result v1

    if-nez v1, :cond_5

    .line 106
    iget-object v1, p0, Lio/flutter/view/AccessibilityStringBuilder;->locale:Ljava/lang/String;

    invoke-static {v1}, Ljava/util/Locale;->forLanguageTag(Ljava/lang/String;)Ljava/util/Locale;

    move-result-object v1

    .line 107
    new-instance v3, Landroid/text/style/LocaleSpan;

    invoke-direct {v3, v1}, Landroid/text/style/LocaleSpan;-><init>(Ljava/util/Locale;)V

    .line 108
    iget-object v1, p0, Lio/flutter/view/AccessibilityStringBuilder;->string:Ljava/lang/String;

    invoke-virtual {v1}, Ljava/lang/String;->length()I

    move-result v1

    invoke-virtual {v0, v3, v2, v1, v2}, Landroid/text/SpannableString;->setSpan(Ljava/lang/Object;III)V

    :cond_5
    return-object v0
.end method
