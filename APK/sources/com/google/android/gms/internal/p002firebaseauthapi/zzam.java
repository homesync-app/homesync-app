package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.List;
import java.util.Objects;

/* JADX INFO: Add missing generic type declarations: [E] */
/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zzam<E> extends zzah<E> {
    private final transient int zza;
    private final transient int zzb;
    private final /* synthetic */ zzah zzc;

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzag
    final int zza() {
        return this.zzc.zzb() + this.zza + this.zzb;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzag
    final int zzb() {
        return this.zzc.zzb() + this.zza;
    }

    @Override // java.util.AbstractCollection, java.util.Collection, java.util.List
    public final int size() {
        return this.zzb;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzah
    /* JADX INFO: renamed from: zza */
    public final zzah<E> subList(int i, int i2) {
        zzu.zza(i, i2, this.zzb);
        zzah zzahVar = this.zzc;
        int i3 = this.zza;
        return (zzah) zzahVar.subList(i + i3, i2 + i3);
    }

    @Override // java.util.List
    public final E get(int i) {
        zzu.zza(i, this.zzb);
        return this.zzc.get(i + this.zza);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzah, java.util.List
    public final /* synthetic */ List subList(int i, int i2) {
        return subList(i, i2);
    }

    zzam(zzah zzahVar, int i, int i2) {
        Objects.requireNonNull(zzahVar);
        this.zzc = zzahVar;
        this.zza = i;
        this.zzb = i2;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzag
    final Object[] zze() {
        return this.zzc.zze();
    }
}
