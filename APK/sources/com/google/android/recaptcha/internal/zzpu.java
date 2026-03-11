package com.google.android.recaptcha.internal;

/* JADX INFO: compiled from: com.google.android.recaptcha:recaptcha@@18.6.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zzpu extends IllegalArgumentException {
    zzpu(int i, int i2) {
        super("Unpaired surrogate at index " + i + " of " + i2);
    }
}
