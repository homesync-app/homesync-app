package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzalf;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzwu extends zzalf<zzwu, zza> implements zzamo {
    private static final zzwu zzc;
    private static volatile zzamv<zzwu> zzd;
    private int zze;
    private int zzf;
    private zzwo zzg;
    private zzajv zzh = zzajv.zza;

    public final int zza() {
        return this.zzf;
    }

    public final zzwo zzb() {
        zzwo zzwoVar = this.zzg;
        return zzwoVar == null ? zzwo.zzf() : zzwoVar;
    }

    /* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
    public static final class zza extends zzalf.zzb<zzwu, zza> implements zzamo {
        public final zza zza(zzwo zzwoVar) {
            zzg();
            zzwu.zza((zzwu) this.zza, zzwoVar);
            return this;
        }

        public final zza zza(zzajv zzajvVar) {
            zzg();
            zzwu.zza((zzwu) this.zza, zzajvVar);
            return this;
        }

        public final zza zza(int i) {
            zzg();
            ((zzwu) this.zza).zzf = 0;
            return this;
        }

        private zza() {
            super(zzwu.zzc);
        }
    }

    public static zza zzc() {
        return (zza) zzc.zzm();
    }

    public static zzwu zze() {
        return zzc;
    }

    public static zzwu zza(zzajv zzajvVar, zzaku zzakuVar) throws zzall {
        return (zzwu) zzalf.zza(zzc, zzajvVar, zzakuVar);
    }

    public final zzajv zzf() {
        return this.zzh;
    }

    public static zzamv<zzwu> zzg() {
        return (zzamv) zzc.zza(zzalf.zze.zzg, (Object) null, (Object) null);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzalf
    protected final Object zza(int i, Object obj, Object obj2) {
        zzamv zzaVar;
        switch (zzww.zza[i - 1]) {
            case 1:
                return new zzwu();
            case 2:
                return new zza();
            case 3:
                return zza(zzc, "\u0000\u0003\u0000\u0001\u0001\u0003\u0003\u0000\u0000\u0000\u0001\u000b\u0002ဉ\u0000\u0003\n", new Object[]{"zze", "zzf", "zzg", "zzh"});
            case 4:
                return zzc;
            case 5:
                zzamv<zzwu> zzamvVar = zzd;
                if (zzamvVar != null) {
                    return zzamvVar;
                }
                synchronized (zzwu.class) {
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

    static /* synthetic */ void zza(zzwu zzwuVar, zzwo zzwoVar) {
        zzwoVar.getClass();
        zzwuVar.zzg = zzwoVar;
        zzwuVar.zze |= 1;
    }

    static /* synthetic */ void zza(zzwu zzwuVar, zzajv zzajvVar) {
        zzajvVar.getClass();
        zzwuVar.zzh = zzajvVar;
    }

    static {
        zzwu zzwuVar = new zzwu();
        zzc = zzwuVar;
        zzalf.zza((Class<zzwu>) zzwu.class, zzwuVar);
    }

    private zzwu() {
    }
}
