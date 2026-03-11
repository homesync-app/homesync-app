package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzln {
    private static final byte[] zza = new byte[0];

    public static zzlr zza(zzkb zzkbVar) throws GeneralSecurityException {
        zzcb zzcbVarZzb = zzkbVar.zzb();
        if (zzcbVarZzb instanceof zzdx) {
            return new zzlp((zzdx) zzcbVarZzb);
        }
        if (zzcbVarZzb instanceof zzdi) {
            return new zzlm((zzdi) zzcbVarZzb);
        }
        if (zzcbVarZzb instanceof zzjf) {
            return new zzlo((zzjf) zzcbVarZzb);
        }
        throw new GeneralSecurityException("Unsupported DEM parameters: " + String.valueOf(zzcbVarZzb));
    }
}
