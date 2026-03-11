package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zzamx {
    private static final zzamx zza = new zzamx();
    private final ConcurrentMap<Class<?>, zzanb<?>> zzc = new ConcurrentHashMap();
    private final zzane zzb = new zzama();

    public static zzamx zza() {
        return zza;
    }

    public final <T> zzanb<T> zza(Class<T> cls) {
        zzalh.zza(cls, "messageType");
        zzanb<T> zzanbVarZza = (zzanb) this.zzc.get(cls);
        if (zzanbVarZza == null) {
            zzanbVarZza = this.zzb.zza(cls);
            zzalh.zza(cls, "messageType");
            zzalh.zza(zzanbVarZza, "schema");
            zzanb<T> zzanbVar = (zzanb) this.zzc.putIfAbsent(cls, zzanbVarZza);
            if (zzanbVar != null) {
                return zzanbVar;
            }
        }
        return zzanbVarZza;
    }

    public final <T> zzanb<T> zza(T t) {
        return zza((Class) t.getClass());
    }

    private zzamx() {
    }
}
