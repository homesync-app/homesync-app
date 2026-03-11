package com.google.android.recaptcha.internal;

import java.io.IOException;
import java.util.Map;

/* JADX INFO: compiled from: com.google.android.recaptcha:recaptcha@@18.6.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zzmq extends zzmp {
    zzmq() {
    }

    @Override // com.google.android.recaptcha.internal.zzmp
    final void zza(Object obj) {
        ((zzna) obj).zzb.zzg();
    }

    @Override // com.google.android.recaptcha.internal.zzmp
    final void zzb(zzpy zzpyVar, Map.Entry entry) throws IOException {
        zznb zznbVar = (zznb) entry.getKey();
        zzpw zzpwVar = zzpw.DOUBLE;
        switch (zznbVar.zzb) {
            case DOUBLE:
                zzpyVar.zzf(zznbVar.zza, ((Double) entry.getValue()).doubleValue());
                break;
            case FLOAT:
                zzpyVar.zzo(zznbVar.zza, ((Float) entry.getValue()).floatValue());
                break;
            case INT64:
                zzpyVar.zzt(zznbVar.zza, ((Long) entry.getValue()).longValue());
                break;
            case UINT64:
                zzpyVar.zzK(zznbVar.zza, ((Long) entry.getValue()).longValue());
                break;
            case INT32:
                zzpyVar.zzr(zznbVar.zza, ((Integer) entry.getValue()).intValue());
                break;
            case FIXED64:
                zzpyVar.zzm(zznbVar.zza, ((Long) entry.getValue()).longValue());
                break;
            case FIXED32:
                zzpyVar.zzk(zznbVar.zza, ((Integer) entry.getValue()).intValue());
                break;
            case BOOL:
                zzpyVar.zzb(zznbVar.zza, ((Boolean) entry.getValue()).booleanValue());
                break;
            case STRING:
                zzpyVar.zzG(zznbVar.zza, (String) entry.getValue());
                break;
            case GROUP:
                zzpyVar.zzq(zznbVar.zza, entry.getValue(), zzos.zza().zzb(entry.getValue().getClass()));
                break;
            case MESSAGE:
                zzpyVar.zzv(zznbVar.zza, entry.getValue(), zzos.zza().zzb(entry.getValue().getClass()));
                break;
            case BYTES:
                zzpyVar.zzd(zznbVar.zza, (zzle) entry.getValue());
                break;
            case UINT32:
                zzpyVar.zzI(zznbVar.zza, ((Integer) entry.getValue()).intValue());
                break;
            case ENUM:
                zzpyVar.zzr(zznbVar.zza, ((Integer) entry.getValue()).intValue());
                break;
            case SFIXED32:
                zzpyVar.zzx(zznbVar.zza, ((Integer) entry.getValue()).intValue());
                break;
            case SFIXED64:
                zzpyVar.zzz(zznbVar.zza, ((Long) entry.getValue()).longValue());
                break;
            case SINT32:
                zzpyVar.zzB(zznbVar.zza, ((Integer) entry.getValue()).intValue());
                break;
            case SINT64:
                zzpyVar.zzD(zznbVar.zza, ((Long) entry.getValue()).longValue());
                break;
        }
    }
}
