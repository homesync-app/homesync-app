package com.google.android.recaptcha.internal;

/* JADX INFO: compiled from: com.google.android.recaptcha:recaptcha@@18.6.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzth extends zznd implements zzoj {
    private static final zzth zzb;
    private static volatile zzoq zzd;
    private int zze = 0;
    private Object zzf;

    static {
        zzth zzthVar = new zzth();
        zzb = zzthVar;
        zznd.zzI(zzth.class, zzthVar);
    }

    private zzth() {
    }

    static /* synthetic */ void zzM(zzth zzthVar, float f) {
        zzthVar.zze = 9;
        zzthVar.zzf = Float.valueOf(f);
    }

    static /* synthetic */ void zzN(zzth zzthVar, int i) {
        zzthVar.zze = 4;
        zzthVar.zzf = Integer.valueOf(i);
    }

    static /* synthetic */ void zzO(zzth zzthVar, int i) {
        zzthVar.zze = 5;
        zzthVar.zzf = Integer.valueOf(i);
    }

    static /* synthetic */ void zzP(zzth zzthVar, long j) {
        zzthVar.zze = 7;
        zzthVar.zzf = Long.valueOf(j);
    }

    static /* synthetic */ void zzQ(zzth zzthVar, String str) {
        str.getClass();
        zzthVar.zze = 11;
        zzthVar.zzf = str;
    }

    public static zztg zzf() {
        return (zztg) zzb.zzq();
    }

    static /* synthetic */ void zzi(zzth zzthVar, boolean z) {
        zzthVar.zze = 1;
        zzthVar.zzf = Boolean.valueOf(z);
    }

    static /* synthetic */ void zzj(zzth zzthVar, zzle zzleVar) {
        zzthVar.zze = 2;
        zzthVar.zzf = zzleVar;
    }

    static /* synthetic */ void zzk(zzth zzthVar, String str) {
        str.getClass();
        zzthVar.zze = 3;
        zzthVar.zzf = str;
    }

    static /* synthetic */ void zzl(zzth zzthVar, double d) {
        zzthVar.zze = 10;
        zzthVar.zzf = Double.valueOf(d);
    }

    @Override // com.google.android.recaptcha.internal.zznd
    protected final Object zzh(int i, Object obj, Object obj2) {
        zzoq zzmyVar;
        int i2 = i - 1;
        if (i2 == 0) {
            return (byte) 1;
        }
        if (i2 == 2) {
            return zzF(zzb, "\u0000\u000b\u0001\u0000\u0001\u000b\u000b\u0000\u0000\u0000\u0001:\u0000\u0002=\u0000\u0003Ȼ\u0000\u0004B\u0000\u0005B\u0000\u0006>\u0000\u0007C\u0000\b6\u0000\t4\u0000\n3\u0000\u000bȻ\u0000", new Object[]{"zzf", "zze"});
        }
        if (i2 == 3) {
            return new zzth();
        }
        zztj zztjVar = null;
        if (i2 == 4) {
            return new zztg(zztjVar);
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
        synchronized (zzth.class) {
            zzmyVar = zzd;
            if (zzmyVar == null) {
                zzmyVar = new zzmy(zzb);
                zzd = zzmyVar;
            }
        }
        return zzmyVar;
    }
}
