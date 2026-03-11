package com.google.android.recaptcha.internal;

/* JADX INFO: compiled from: com.google.android.recaptcha:recaptcha@@18.6.1 */
/* JADX INFO: loaded from: classes3.dex */
public abstract class zzna extends zznd implements zzoj {
    protected zzmt zzb = zzmt.zzd();

    final zzmt zzi() {
        if (this.zzb.zzj()) {
            this.zzb = this.zzb.clone();
        }
        return this.zzb;
    }
}
