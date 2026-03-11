package com.google.android.gms.internal.fido;

import com.google.common.primitives.SignedBytes;
import java.util.Arrays;

/* JADX INFO: compiled from: com.google.android.gms:play-services-fido@@21.0.0 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzhi extends zzhp {
    private final zzgx zza;

    zzhi(zzgx zzgxVar) {
        this.zza = zzgxVar;
    }

    @Override // java.lang.Comparable
    public final /* bridge */ /* synthetic */ int compareTo(Object obj) {
        zzhp zzhpVar = (zzhp) obj;
        if (zzd(SignedBytes.MAX_POWER_OF_TWO) != zzhpVar.zza()) {
            return zzd(SignedBytes.MAX_POWER_OF_TWO) - zzhpVar.zza();
        }
        zzhi zzhiVar = (zzhi) zzhpVar;
        zzgx zzgxVar = this.zza;
        int iZzd = zzgxVar.zzd();
        zzgx zzgxVar2 = zzhiVar.zza;
        if (iZzd != zzgxVar2.zzd()) {
            return zzgxVar.zzd() - zzgxVar2.zzd();
        }
        return zzgm.zza().compare(zzgxVar.zzm(), zzhiVar.zza.zzm());
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj != null && getClass() == obj.getClass()) {
            return this.zza.equals(((zzhi) obj).zza);
        }
        return false;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Integer.valueOf(zzd(SignedBytes.MAX_POWER_OF_TWO)), this.zza});
    }

    public final String toString() {
        zzgf zzgfVarZzd = zzgf.zzf().zzd();
        byte[] bArrZzm = this.zza.zzm();
        return "h'" + zzgfVarZzd.zzg(bArrZzm, 0, bArrZzm.length) + "'";
    }

    @Override // com.google.android.gms.internal.fido.zzhp
    protected final int zza() {
        return zzd(SignedBytes.MAX_POWER_OF_TWO);
    }

    public final zzgx zzc() {
        return this.zza;
    }
}
