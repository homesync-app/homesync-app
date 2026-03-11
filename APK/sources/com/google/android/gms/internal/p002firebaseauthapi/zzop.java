package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import java.util.HashMap;
import java.util.Map;
import javax.annotation.Nullable;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzop {
    private static final zzor<zzoi> zza = new zzor() { // from class: com.google.android.gms.internal.firebase-auth-api.zzos
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzor
        public final zzbi zza(zzcb zzcbVar, Integer num) {
            return zzop.zza((zzoi) zzcbVar, num);
        }
    };
    private static final zzop zzb = zzb();
    private final Map<Class<? extends zzcb>, zzor<? extends zzcb>> zzc = new HashMap();

    public final zzbi zza(zzcb zzcbVar, @Nullable Integer num) throws GeneralSecurityException {
        return zzb(zzcbVar, num);
    }

    private final synchronized <ParametersT extends zzcb> zzbi zzb(ParametersT parameterst, @Nullable Integer num) throws GeneralSecurityException {
        zzor<? extends zzcb> zzorVar;
        zzorVar = this.zzc.get(parameterst.getClass());
        if (zzorVar == null) {
            throw new GeneralSecurityException("Cannot create a new key for parameters " + String.valueOf(parameterst) + ": no key creator for this class was registered.");
        }
        return zzorVar.zza(parameterst, num);
    }

    public static /* synthetic */ zzof zza(zzoi zzoiVar, Integer num) throws GeneralSecurityException {
        zzxb zzxbVarZza = zzoiVar.zzb().zza();
        zzbh<?> zzbhVarZza = zznq.zza().zza(zzxbVarZza.zzf());
        if (!zznq.zza().zzb(zzxbVarZza.zzf())) {
            throw new GeneralSecurityException("Creating new keys is not allowed.");
        }
        zzwx zzwxVarZza = zzbhVarZza.zza(zzxbVarZza.zze());
        return new zzof(zzqb.zza(zzwxVarZza.zzf(), zzwxVarZza.zze(), zzwxVarZza.zzb(), zzxbVarZza.zzd(), num), zzbf.zza());
    }

    public static zzop zza() {
        return zzb;
    }

    private static zzop zzb() {
        zzop zzopVar = new zzop();
        try {
            zzopVar.zza(zza, zzoi.class);
            return zzopVar;
        } catch (GeneralSecurityException e) {
            throw new IllegalStateException("unexpected error.", e);
        }
    }

    public final synchronized <ParametersT extends zzcb> void zza(zzor<ParametersT> zzorVar, Class<ParametersT> cls) throws GeneralSecurityException {
        zzor<? extends zzcb> zzorVar2 = this.zzc.get(cls);
        if (zzorVar2 != null && !zzorVar2.equals(zzorVar)) {
            throw new GeneralSecurityException("Different key creator for parameters class " + String.valueOf(cls) + " already inserted");
        }
        this.zzc.put(cls, zzorVar);
    }
}
