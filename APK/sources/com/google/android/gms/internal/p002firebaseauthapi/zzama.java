package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zzama implements zzane {
    private static final zzamj zza = new zzalz();
    private final zzamj zzb;

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzane
    public final <T> zzanb<T> zza(Class<T> cls) {
        zzand.zza((Class<?>) cls);
        zzamk zzamkVarZza = this.zzb.zza(cls);
        if (zzamkVarZza.zzc()) {
            return zzams.zza(zzand.zza(), zzaky.zza(), zzamkVarZza.zza());
        }
        return zzamq.zza(cls, zzamkVarZza, zzamw.zza(), zzaly.zza(), zzand.zza(), zzamc.zza[zzamkVarZza.zzb().ordinal()] != 1 ? zzaky.zza() : null, zzamh.zza());
    }

    public zzama() {
        this(new zzamb(zzalg.zza(), zza));
    }

    private zzama(zzamj zzamjVar) {
        this.zzb = (zzamj) zzalh.zza(zzamjVar, "messageInfoFactory");
    }
}
