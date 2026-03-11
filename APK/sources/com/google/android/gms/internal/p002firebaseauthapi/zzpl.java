package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzpl<P> {
    private static final zzaaj zza = zzaaj.zza(new byte[0]);
    private final Map<zzaaj, List<P>> zzb;

    public final Iterable<P> zza(byte[] bArr) {
        List<P> list = this.zzb.get(zza);
        List<P> list2 = bArr.length >= 5 ? this.zzb.get(zzaaj.zza(bArr, 0, 5)) : null;
        return (list == null && list2 == null) ? new ArrayList() : list == null ? list2 : list2 == null ? list : new zzpo(this, list2, list);
    }

    private zzpl(Map<zzaaj, List<P>> map) {
        this.zzb = map;
    }
}
