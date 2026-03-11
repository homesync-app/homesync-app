package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzwx;
import java.security.GeneralSecurityException;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zzoc<P> extends zzod<P> implements zzcd<P> {
    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzcd
    public final zzwx zzc(zzajv zzajvVar) throws GeneralSecurityException {
        Object objZza = zzoz.zza().zza(zzqb.zza(this.zza, zzajvVar, this.zzb, zzxz.RAW, null), zzbf.zza());
        if (!(objZza instanceof zzce)) {
            throw new GeneralSecurityException("Key not private key");
        }
        zzqb zzqbVar = (zzqb) zzoz.zza().zza(((zzce) objZza).zzc(), zzqb.class, zzbf.zza());
        return (zzwx) ((zzalf) zzwx.zza().zza(zzqbVar.zzf()).zza(zzqbVar.zzd()).zza(zzqbVar.zza()).zze());
    }

    protected zzoc(String str, Class<P> cls, zzamv<? extends zzamm> zzamvVar) {
        super(str, cls, zzwx.zzb.ASYMMETRIC_PRIVATE, zzamvVar);
    }
}
