package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzaal {
    private final zzaaj zza;

    public final int zza() {
        return this.zza.zza();
    }

    public static zzaal zza(byte[] bArr, zzch zzchVar) {
        if (zzchVar == null) {
            throw new NullPointerException("SecretKeyAccess required");
        }
        return new zzaal(zzaaj.zza(bArr));
    }

    public static zzaal zza(int i) {
        return new zzaal(zzaaj.zza(zzqd.zza(i)));
    }

    private zzaal(zzaaj zzaajVar) {
        this.zza = zzaajVar;
    }

    public final byte[] zza(zzch zzchVar) {
        if (zzchVar == null) {
            throw new NullPointerException("SecretKeyAccess required");
        }
        return this.zza.zzb();
    }
}
