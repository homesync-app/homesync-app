package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzrl {
    static {
        zzyc.zzb();
        try {
            zza();
        } catch (GeneralSecurityException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    public static void zza() throws GeneralSecurityException {
        zzrm.zzc();
        zzqz.zzc();
        zzre.zza(true);
        if (zziv.zzb()) {
            return;
        }
        zzqq.zza(true);
    }
}
