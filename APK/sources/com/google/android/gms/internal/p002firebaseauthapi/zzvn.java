package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzalf;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzvn extends zzalf<zzvn, zza> implements zzamo {
    private static final zzvn zzc;
    private static volatile zzamv<zzvn> zzd;
    private int zze;
    private int zzf;
    private zzvq zzg;
    private zzajv zzh = zzajv.zza;

    public final int zza() {
        return this.zzf;
    }

    public static zza zzb() {
        return (zza) zzc.zzm();
    }

    /* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
    public static final class zza extends zzalf.zzb<zzvn, zza> implements zzamo {
        public final zza zza(zzajv zzajvVar) {
            zzg();
            zzvn.zza((zzvn) this.zza, zzajvVar);
            return this;
        }

        public final zza zza(zzvq zzvqVar) {
            zzg();
            zzvn.zza((zzvn) this.zza, zzvqVar);
            return this;
        }

        public final zza zza(int i) {
            zzg();
            ((zzvn) this.zza).zzf = 0;
            return this;
        }

        private zza() {
            super(zzvn.zzc);
        }
    }

    public static zzvn zza(zzajv zzajvVar, zzaku zzakuVar) throws zzall {
        return (zzvn) zzalf.zza(zzc, zzajvVar, zzakuVar);
    }

    public final zzvq zzd() {
        zzvq zzvqVar = this.zzg;
        return zzvqVar == null ? zzvq.zze() : zzvqVar;
    }

    public final zzajv zze() {
        return this.zzh;
    }

    public static zzamv<zzvn> zzf() {
        return (zzamv) zzc.zza(zzalf.zze.zzg, (Object) null, (Object) null);
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzalf
    protected final Object zza(int i, Object obj, Object obj2) {
        zzamv zzaVar;
        switch (zzvm.zza[i - 1]) {
            case 1:
                return new zzvn();
            case 2:
                return new zza();
            case 3:
                return zza(zzc, "\u0000\u0003\u0000\u0001\u0001\u0003\u0003\u0000\u0000\u0000\u0001\u000b\u0002ဉ\u0000\u0003\n", new Object[]{"zze", "zzf", "zzg", "zzh"});
            case 4:
                return zzc;
            case 5:
                zzamv<zzvn> zzamvVar = zzd;
                if (zzamvVar != null) {
                    return zzamvVar;
                }
                synchronized (zzvn.class) {
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

    static /* synthetic */ void zza(zzvn zzvnVar, zzajv zzajvVar) {
        zzajvVar.getClass();
        zzvnVar.zzh = zzajvVar;
    }

    static /* synthetic */ void zza(zzvn zzvnVar, zzvq zzvqVar) {
        zzvqVar.getClass();
        zzvnVar.zzg = zzvqVar;
        zzvnVar.zze |= 1;
    }

    static {
        zzvn zzvnVar = new zzvn();
        zzc = zzvnVar;
        zzalf.zza((Class<zzvn>) zzvn.class, zzvnVar);
    }

    private zzvn() {
    }
}
