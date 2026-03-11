package com.google.android.gms.internal.p002firebaseauthapi;

import java.io.IOException;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzame<K, V> {
    static <K, V> int zza(zzamd<K, V> zzamdVar, K k, V v) {
        return zzakx.zza(zzamdVar.zza, 1, k) + zzakx.zza(zzamdVar.zzc, 2, v);
    }

    static <K, V> void zza(zzakn zzaknVar, zzamd<K, V> zzamdVar, K k, V v) throws IOException {
        zzakx.zza(zzaknVar, zzamdVar.zza, 1, k);
        zzakx.zza(zzaknVar, zzamdVar.zzc, 2, v);
    }
}
