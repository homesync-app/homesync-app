package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzxh;
import java.security.GeneralSecurityException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzbn {
    private final List<zzbq> zza = new ArrayList();
    private zzok zzb = zzok.zza;
    private boolean zzc = false;

    public final zzbn zza(zzbq zzbqVar) {
        if (zzbqVar.zze != null) {
            throw new IllegalStateException("Entry has already been added to a KeysetHandle.Builder");
        }
        if (zzbqVar.zza) {
            zzb();
        }
        zzbqVar.zze = this;
        this.zza.add(zzbqVar);
        return this;
    }

    public final zzbm zza() throws GeneralSecurityException {
        int iZza;
        if (this.zzc) {
            throw new GeneralSecurityException("KeysetHandle.Builder#build must only be called once");
        }
        this.zzc = true;
        zzxh.zza zzaVarZzc = zzxh.zzc();
        ArrayList arrayList = new ArrayList(this.zza.size());
        List<zzbq> list = this.zza;
        for (int i = 0; i < list.size() - 1; i++) {
            if (list.get(i).zzd == zzbp.zza && list.get(i + 1).zzd != zzbp.zza) {
                throw new GeneralSecurityException("Entries with 'withRandomId()' may only be followed by other entries with 'withRandomId()'.");
            }
        }
        HashSet hashSet = new HashSet();
        Integer numValueOf = null;
        for (zzbq zzbqVar : this.zza) {
            if (zzbqVar.zzb == null) {
                throw new GeneralSecurityException("Key Status not set.");
            }
            if (zzbqVar.zzd == null) {
                throw new GeneralSecurityException("No ID was set (with withFixedId or withRandomId)");
            }
            if (zzbqVar.zzd == zzbp.zza) {
                iZza = 0;
                while (true) {
                    if (iZza != 0 && !hashSet.contains(Integer.valueOf(iZza))) {
                        break;
                    }
                    iZza = zzqn.zza();
                }
            } else {
                iZza = zzbp.zza(zzbqVar.zzd);
            }
            int i2 = iZza;
            if (hashSet.contains(Integer.valueOf(i2))) {
                throw new GeneralSecurityException("Id " + i2 + " is used twice in the keyset");
            }
            hashSet.add(Integer.valueOf(i2));
            zzbi zzbiVarZza = zzop.zza().zza(zzbqVar.zzc, zzbqVar.zzc.zza() ? Integer.valueOf(i2) : null);
            zzbs zzbsVar = new zzbs(zzbiVarZza, zzbm.zza(zzbqVar.zzb), i2, zzbqVar.zza, false, zzbs.zza);
            zzaVarZzc.zza(zzbm.zzb(zzbiVarZza, zzbm.zza(zzbqVar.zzb), i2));
            if (zzbqVar.zza) {
                if (numValueOf != null) {
                    throw new GeneralSecurityException("Two primaries were set");
                }
                numValueOf = Integer.valueOf(i2);
                if (zzbqVar.zzb != zzbk.zza) {
                    throw new GeneralSecurityException("Primary key is not enabled");
                }
            }
            arrayList.add(zzbsVar);
        }
        if (numValueOf == null) {
            throw new GeneralSecurityException("No primary was set");
        }
        zzaVarZzc.zza(numValueOf.intValue());
        zzxh zzxhVar = (zzxh) ((zzalf) zzaVarZzc.zze());
        zzbm.zzd(zzxhVar);
        return zzbm.zzb(new zzbm(zzxhVar, arrayList, this.zzb));
    }

    /* JADX INFO: Access modifiers changed from: private */
    public final void zzb() {
        Iterator<zzbq> it = this.zza.iterator();
        while (it.hasNext()) {
            it.next().zza = false;
        }
    }
}
