package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Iterator;
import java.util.List;
import java.util.Objects;

/* JADX INFO: Add missing generic type declarations: [P] */
/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zzpo<P> implements Iterable<P> {
    private final /* synthetic */ List zza;
    private final /* synthetic */ List zzb;

    @Override // java.lang.Iterable
    public final Iterator<P> iterator() {
        return new zzpq(this.zza.iterator(), this.zzb.iterator());
    }

    zzpo(zzpl zzplVar, List list, List list2) {
        this.zza = list;
        this.zzb = list2;
        Objects.requireNonNull(zzplVar);
    }
}
