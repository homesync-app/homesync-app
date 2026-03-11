package com.google.android.gms.internal.p002firebaseauthapi;

import java.io.IOException;
import java.security.GeneralSecurityException;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzbz {
    public static zzbm zza(zzbv zzbvVar, zzch zzchVar) throws GeneralSecurityException, IOException {
        if (zzchVar != null) {
            return zzbm.zza(zzbvVar.zzb());
        }
        throw new NullPointerException("SecretKeyAccess cannot be null");
    }

    public static void zza(zzbm zzbmVar, zzby zzbyVar, zzch zzchVar) throws IOException {
        if (zzchVar == null) {
            throw new NullPointerException("SecretKeyAccess cannot be null");
        }
        zzbyVar.zza(zzbmVar.zzd());
    }
}
