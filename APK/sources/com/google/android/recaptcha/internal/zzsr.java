package com.google.android.recaptcha.internal;

import java.util.List;

/* JADX INFO: compiled from: com.google.android.recaptcha:recaptcha@@18.6.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzsr extends zznd implements zzoj {
    private static final zzsr zzb;
    private static volatile zzoq zzd;
    private int zze;
    private long zzg;
    private int zzh;
    private String zzf = "";
    private zznk zzi = zzB();
    private zzle zzj = zzle.zzb;
    private String zzk = "";
    private String zzl = "";

    static {
        zzsr zzsrVar = new zzsr();
        zzb = zzsrVar;
        zznd.zzI(zzsr.class, zzsrVar);
    }

    private zzsr() {
    }

    public static zzsr zzi() {
        return zzb;
    }

    public final zzle zzf() {
        return this.zzj;
    }

    public final String zzj() {
        return this.zzf;
    }

    public final List zzk() {
        return this.zzi;
    }

    @Override // com.google.android.recaptcha.internal.zznd
    protected final Object zzh(int i, Object obj, Object obj2) {
        zzoq zzmyVar;
        int i2 = i - 1;
        if (i2 == 0) {
            return (byte) 1;
        }
        if (i2 == 2) {
            return zzF(zzb, "\u0000\u0007\u0000\u0001\u0001\b\u0007\u0000\u0001\u0000\u0001ለ\u0000\u0002ဂ\u0001\u0004ဌ\u0002\u0005\u001b\u0006ည\u0003\u0007ለ\u0004\bለ\u0005", new Object[]{"zze", "zzf", "zzg", "zzh", "zzi", zzst.class, "zzj", "zzk", "zzl"});
        }
        if (i2 == 3) {
            return new zzsr();
        }
        zzsu zzsuVar = null;
        if (i2 == 4) {
            return new zzsq(zzsuVar);
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
        synchronized (zzsr.class) {
            zzmyVar = zzd;
            if (zzmyVar == null) {
                zzmyVar = new zzmy(zzb);
                zzd = zzmyVar;
            }
        }
        return zzmyVar;
    }
}
