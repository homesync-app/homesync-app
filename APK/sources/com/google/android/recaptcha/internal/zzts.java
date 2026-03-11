package com.google.android.recaptcha.internal;

/* JADX INFO: compiled from: com.google.android.recaptcha:recaptcha@@18.6.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzts extends zznd implements zzoj {
    private static final zzts zzb;
    private static volatile zzoq zzd;
    private int zze;

    static {
        zzts zztsVar = new zzts();
        zzb = zztsVar;
        zznd.zzI(zzts.class, zztsVar);
    }

    private zzts() {
    }

    public static zzts zzg(byte[] bArr) throws zznn {
        return (zzts) zznd.zzx(zzb, bArr);
    }

    public final zztv zzi() {
        zztv zztvVarZzb = zztv.zzb(this.zze);
        return zztvVarZzb == null ? zztv.UNRECOGNIZED : zztvVarZzb;
    }

    @Override // com.google.android.recaptcha.internal.zznd
    protected final Object zzh(int i, Object obj, Object obj2) {
        zzoq zzmyVar;
        int i2 = i - 1;
        if (i2 == 0) {
            return (byte) 1;
        }
        if (i2 == 2) {
            return zzF(zzb, "\u0000\u0001\u0000\u0000\u0001\u0001\u0001\u0000\u0000\u0000\u0001\f", new Object[]{"zze"});
        }
        if (i2 == 3) {
            return new zzts();
        }
        zzug zzugVar = null;
        if (i2 == 4) {
            return new zztr(zzugVar);
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
        synchronized (zzts.class) {
            zzmyVar = zzd;
            if (zzmyVar == null) {
                zzmyVar = new zzmy(zzb);
                zzd = zzmyVar;
            }
        }
        return zzmyVar;
    }
}
