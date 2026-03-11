package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzalf;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zztu extends zzalf<zztu, zza> implements zzamo {
    private static final zztu zzc;
    private static volatile zzamv<zztu> zzd;
    private int zze;
    private int zzf;
    private zzua zzg;
    private zzajv zzh = zzajv.zza;

    public final int zza() {
        return this.zzf;
    }

    public static zza zzb() {
        return (zza) zzc.zzm();
    }

    /* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
    public static final class zza extends zzalf.zzb<zztu, zza> implements zzamo {
        public final zza zza(zzajv zzajvVar) {
            zzg();
            zztu.zza((zztu) this.zza, zzajvVar);
            return this;
        }

        public final zza zza(zzua zzuaVar) {
            zzg();
            zztu.zza((zztu) this.zza, zzuaVar);
            return this;
        }

        private zza() {
            super(zztu.zzc);
        }
    }

    public static zztu zza(zzajv zzajvVar, zzaku zzakuVar) throws zzall {
        return (zztu) zzalf.zza(zzc, zzajvVar, zzakuVar);
    }

    public final zzua zzd() {
        zzua zzuaVar = this.zzg;
        return zzuaVar == null ? zzua.zzd() : zzuaVar;
    }

    public final zzajv zze() {
        return this.zzh;
    }

    public static zzamv<zztu> zzf() {
        return (zzamv) zzc.zza(zzalf.zze.zzg, (Object) null, (Object) null);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzalf
    protected final Object zza(int i, Object obj, Object obj2) {
        zzamv zzaVar;
        switch (zztw.zza[i - 1]) {
            case 1:
                return new zztu();
            case 2:
                return new zza();
            case 3:
                return zza(zzc, "\u0000\u0003\u0000\u0001\u0001\u0003\u0003\u0000\u0000\u0000\u0001\u000b\u0002ဉ\u0000\u0003\n", new Object[]{"zze", "zzf", "zzg", "zzh"});
            case 4:
                return zzc;
            case 5:
                zzamv<zztu> zzamvVar = zzd;
                if (zzamvVar != null) {
                    return zzamvVar;
                }
                synchronized (zztu.class) {
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

    static /* synthetic */ void zza(zztu zztuVar, zzajv zzajvVar) {
        zzajvVar.getClass();
        zztuVar.zzh = zzajvVar;
    }

    static /* synthetic */ void zza(zztu zztuVar, zzua zzuaVar) {
        zzuaVar.getClass();
        zztuVar.zzg = zzuaVar;
        zztuVar.zze |= 1;
    }

    static {
        zztu zztuVar = new zztu();
        zzc = zztuVar;
        zzalf.zza((Class<zztu>) zztu.class, zztuVar);
    }

    private zztu() {
    }
}
