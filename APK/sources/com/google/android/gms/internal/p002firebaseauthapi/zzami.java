package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.Iterator;
import java.util.Map;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zzami implements zzamf {
    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzamf
    public final int zza(int i, Object obj, Object obj2) {
        zzamg zzamgVar = (zzamg) obj;
        if (zzamgVar.isEmpty()) {
            return 0;
        }
        Iterator it = zzamgVar.entrySet().iterator();
        if (!it.hasNext()) {
            return 0;
        }
        Map.Entry entry = (Map.Entry) it.next();
        entry.getKey();
        entry.getValue();
        throw new NoSuchMethodError();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzamf
    public final zzamd<?, ?> zza(Object obj) {
        throw new NoSuchMethodError();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzamf
    public final Object zza(Object obj, Object obj2) {
        zzamg zzamgVarZzb = (zzamg) obj;
        zzamg zzamgVar = (zzamg) obj2;
        if (!zzamgVar.isEmpty()) {
            if (!zzamgVarZzb.zzd()) {
                zzamgVarZzb = zzamgVarZzb.zzb();
            }
            zzamgVarZzb.zza(zzamgVar);
        }
        return zzamgVarZzb;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzamf
    public final Object zzb(Object obj) {
        return zzamg.zza().zzb();
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzamf
    public final Object zzc(Object obj) {
        ((zzamg) obj).zzc();
        return obj;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzamf
    public final Map<?, ?> zzd(Object obj) {
        return (zzamg) obj;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzamf
    public final Map<?, ?> zze(Object obj) {
        return (zzamg) obj;
    }

    zzami() {
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzamf
    public final boolean zzf(Object obj) {
        return !((zzamg) obj).zzd();
    }
}
