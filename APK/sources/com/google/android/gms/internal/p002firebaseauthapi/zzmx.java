package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zzmx implements zzmt {
    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmt
    public final zzms zza() throws GeneralSecurityException {
        byte[] bArrZza = zzaah.zza();
        return new zzms(bArrZza, zzaah.zza(bArrZza));
    }

    private zzmx() {
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzmt
    public final byte[] zza(byte[] bArr, byte[] bArr2) throws GeneralSecurityException {
        return zzaah.zza(bArr, bArr2);
    }
}
