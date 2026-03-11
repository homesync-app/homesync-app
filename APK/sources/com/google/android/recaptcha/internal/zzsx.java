package com.google.android.recaptcha.internal;

/* JADX INFO: compiled from: com.google.android.recaptcha:recaptcha@@18.6.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzsx extends zznd implements zzoj {
    private static final zzsx zzb;
    private static volatile zzoq zzd;
    private int zze;
    private String zzf = "";
    private String zzg = "";
    private zzni zzh = zzy();
    private int zzi;
    private int zzj;

    static {
        zzsx zzsxVar = new zzsx();
        zzb = zzsxVar;
        zznd.zzI(zzsx.class, zzsxVar);
    }

    private zzsx() {
    }

    public static zzsv zzf() {
        return (zzsv) zzb.zzq();
    }

    static /* synthetic */ void zzi(zzsx zzsxVar, String str) {
        str.getClass();
        zzsxVar.zze |= 2;
        zzsxVar.zzg = str;
    }

    static /* synthetic */ void zzj(zzsx zzsxVar, String str) {
        str.getClass();
        zzsxVar.zze |= 1;
        zzsxVar.zzf = str;
    }

    static /* synthetic */ void zzk(zzsx zzsxVar, int i) {
        zzsxVar.zzi = 2;
        zzsxVar.zze |= 4;
    }

    @Override // com.google.android.recaptcha.internal.zznd
    protected final Object zzh(int i, Object obj, Object obj2) {
        zzoq zzmyVar;
        int i2 = i - 1;
        if (i2 == 0) {
            return (byte) 1;
        }
        if (i2 == 2) {
            return zzF(zzb, "\u0001\u0005\u0000\u0001\u0001\u0005\u0005\u0000\u0001\u0000\u0001ဈ\u0000\u0002ဈ\u0001\u0003'\u0004᠌\u0002\u0005င\u0003", new Object[]{"zze", "zzf", "zzg", "zzh", "zzi", zzsw.zza, "zzj"});
        }
        if (i2 == 3) {
            return new zzsx();
        }
        zzta zztaVar = null;
        if (i2 == 4) {
            return new zzsv(zztaVar);
        }
        if (i2 == 5) {
            return zzb;
        }
        if (i2 != 6) {
            return null;
        }
        zzoq zzoqVar = zzd;
        if (zzoqVar != null) {
            return zzoqVar;
        }
        synchronized (zzsx.class) {
            zzmyVar = zzd;
            if (zzmyVar == null) {
                zzmyVar = new zzmy(zzb);
                zzd = zzmyVar;
            }
        }
        return zzmyVar;
    }
}
