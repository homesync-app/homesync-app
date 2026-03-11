package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzalf;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzti extends zzalf<zzti, zza> implements zzamo {
    private static final zzti zzc;
    private static volatile zzamv<zzti> zzd;
    private int zze;
    private zzto zzf;
    private zzwe zzg;

    public static zza zza() {
        return (zza) zzc.zzm();
    }

    public static zzti zza(zzajv zzajvVar, zzaku zzakuVar) throws zzall {
        return (zzti) zzalf.zza(zzc, zzajvVar, zzakuVar);
    }

    /* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
    public static final class zza extends zzalf.zzb<zzti, zza> implements zzamo {
        public final zza zza(zzto zztoVar) {
            zzg();
            zzti.zza((zzti) this.zza, zztoVar);
            return this;
        }

        public final zza zza(zzwe zzweVar) {
            zzg();
            zzti.zza((zzti) this.zza, zzweVar);
            return this;
        }

        private zza() {
            super(zzti.zzc);
        }
    }

    public final zzto zzc() {
        zzto zztoVar = this.zzf;
        return zztoVar == null ? zzto.zzd() : zztoVar;
    }

    public final zzwe zzd() {
        zzwe zzweVar = this.zzg;
        return zzweVar == null ? zzwe.zze() : zzweVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzalf
    protected final Object zza(int i, Object obj, Object obj2) {
        zzamv zzaVar;
        switch (zztk.zza[i - 1]) {
            case 1:
                return new zzti();
            case 2:
                return new zza();
            case 3:
                return zza(zzc, "\u0000\u0002\u0000\u0001\u0001\u0002\u0002\u0000\u0000\u0000\u0001ဉ\u0000\u0002ဉ\u0001", new Object[]{"zze", "zzf", "zzg"});
            case 4:
                return zzc;
            case 5:
                zzamv<zzti> zzamvVar = zzd;
                if (zzamvVar != null) {
                    return zzamvVar;
                }
                synchronized (zzti.class) {
                    zzaVar = zzd;
                    if (zzaVar == null) {
                        zzaVar = new zzalf.zza(zzc);
                        zzd = zzaVar;
                    }
                    break;
                }
                return zzaVar;
            case 6:
                return (byte) 1;
            default:
                throw null;
        }
    }

    static /* synthetic */ void zza(zzti zztiVar, zzto zztoVar) {
        zztoVar.getClass();
        zztiVar.zzf = zztoVar;
        zztiVar.zze |= 1;
    }

    static /* synthetic */ void zza(zzti zztiVar, zzwe zzweVar) {
        zzweVar.getClass();
        zztiVar.zzg = zzweVar;
        zztiVar.zze |= 2;
    }

    static {
        zzti zztiVar = new zzti();
        zzc = zztiVar;
        zzalf.zza((Class<zzti>) zzti.class, zztiVar);
    }

    private zzti() {
    }
}
