package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zzamb implements zzamj {
    private zzamj[] zza;

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzamj
    public final zzamk zza(Class<?> cls) {
        for (zzamj zzamjVar : this.zza) {
            if (zzamjVar.zzb(cls)) {
                return zzamjVar.zza(cls);
            }
        }
        throw new UnsupportedOperationException("No factory is available for message type: " + cls.getName());
    }

    zzamb(zzamj... zzamjVarArr) {
        this.zza = zzamjVarArr;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzamj
    public final boolean zzb(Class<?> cls) {
        for (zzamj zzamjVar : this.zza) {
            if (zzamjVar.zzb(cls)) {
                return true;
            }
        }
        return false;
    }
}
