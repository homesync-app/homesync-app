package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzalf;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzto extends zzalf<zzto, zza> implements zzamo {
    private static final zzto zzc;
    private static volatile zzamv<zzto> zzd;
    private int zze;
    private zztr zzf;
    private int zzg;

    public final int zza() {
        return this.zzg;
    }

    public static zza zzb() {
        return (zza) zzc.zzm();
    }

    /* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
    public static final class zza extends zzalf.zzb<zzto, zza> implements zzamo {
        public final zza zza(int i) {
            zzg();
            ((zzto) this.zza).zzg = i;
            return this;
        }

        public final zza zza(zztr zztrVar) {
            zzg();
            zzto.zza((zzto) this.zza, zztrVar);
            return this;
        }

        private zza() {
            super(zzto.zzc);
        }
    }

    public static zzto zzd() {
        return zzc;
    }

    public final zztr zze() {
        zztr zztrVar = this.zzf;
        return zztrVar == null ? zztr.zzd() : zztrVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzalf
    protected final Object zza(int i, Object obj, Object obj2) {
        zzamv zzaVar;
        switch (zztq.zza[i - 1]) {
            case 1:
                return new zzto();
            case 2:
                return new zza();
            case 3:
                return zza(zzc, "\u0000\u0002\u0000\u0001\u0001\u0002\u0002\u0000\u0000\u0000\u0001ဉ\u0000\u0002\u000b", new Object[]{"zze", "zzf", "zzg"});
            case 4:
                return zzc;
            case 5:
                zzamv<zzto> zzamvVar = zzd;
                if (zzamvVar != null) {
                    return zzamvVar;
                }
                synchronized (zzto.class) {
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

    static /* synthetic */ void zza(zzto zztoVar, zztr zztrVar) {
        zztrVar.getClass();
        zztoVar.zzf = zztrVar;
        zztoVar.zze |= 1;
    }

    static {
        zzto zztoVar = new zzto();
        zzc = zztoVar;
        zzalf.zza((Class<zzto>) zzto.class, zztoVar);
    }

    private zzto() {
    }
}
