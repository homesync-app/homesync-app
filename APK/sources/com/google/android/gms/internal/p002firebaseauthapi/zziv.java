package com.google.android.gms.internal.p002firebaseauthapi;

import java.util.concurrent.atomic.AtomicBoolean;
import java.util.logging.Level;
import java.util.logging.Logger;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zziv {
    private static final Logger zza = Logger.getLogger(zziv.class.getName());
    private static final AtomicBoolean zzb = new AtomicBoolean(false);

    static Boolean zza() {
        try {
            return (Boolean) Class.forName("org.conscrypt.Conscrypt").getMethod("isBoringSslFIPSBuild", new Class[0]).invoke(null, new Object[0]);
        } catch (Exception unused) {
            zza.logp(Level.INFO, "com.google.crypto.tink.config.internal.TinkFipsUtil", "checkConscryptIsAvailableAndUsesFipsBoringSsl", "Conscrypt is not available or does not support checking for FIPS build.");
            return false;
        }
    }

    /* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
    /* JADX WARN: Unknown enum class pattern. Please report as an issue! */
    /* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
    public static abstract class zza {
        public static final zza zza;
        public static final zza zzb;
        private static final /* synthetic */ zza[] zzc;

        static {
            zzix zzixVar = new zzix("ALGORITHM_NOT_FIPS");
            zza = zzixVar;
            zziz zzizVar = new zziz("ALGORITHM_REQUIRES_BORINGCRYPTO");
            zzb = zzizVar;
            zzc = new zza[]{zzixVar, zzizVar};
        }

        public abstract boolean zza();

        private zza(String str, int i) {
        }

        public static zza[] values() {
            return (zza[]) zzc.clone();
        }
    }

    private zziv() {
    }

    public static boolean zzb() {
        return zzb.get();
    }
}
