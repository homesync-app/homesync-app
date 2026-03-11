package com.google.android.recaptcha.internal;

import java.lang.reflect.Field;

/* JADX INFO: compiled from: com.google.android.recaptcha:recaptcha@@18.6.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzhn implements zzgx {
    public static final zzhn zza = new zzhn();

    private zzhn() {
    }

    @Override // com.google.android.recaptcha.internal.zzgx
    public final void zza(int i, zzgd zzgdVar, zzue... zzueVarArr) throws zzce {
        if (zzueVarArr.length != 3) {
            throw new zzce(4, 3, null);
        }
        Object objZza = zzgdVar.zzc().zza(zzueVarArr[0]);
        if (true != (objZza instanceof Field)) {
            objZza = null;
        }
        Field field = (Field) objZza;
        if (field == null) {
            throw new zzce(4, 5, null);
        }
        try {
            field.set(zzgdVar.zzc().zza(zzueVarArr[1]), zzgdVar.zzc().zza(zzueVarArr[2]));
        } catch (Exception e) {
            throw new zzce(6, 11, e);
        }
    }
}
