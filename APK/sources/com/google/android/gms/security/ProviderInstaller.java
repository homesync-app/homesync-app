package com.google.android.gms.security;

import android.content.Context;
import android.content.Intent;
import android.util.Log;
import com.google.android.gms.common.GoogleApiAvailabilityLight;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.internal.Preconditions;
import java.lang.reflect.Method;

/* JADX INFO: compiled from: com.google.android.gms:play-services-basement@@18.8.0 */
/* JADX INFO: loaded from: classes3.dex */
public class ProviderInstaller {
    public static final String PROVIDER_NAME = "GmsCore_OpenSSL";
    private static final GoogleApiAvailabilityLight zza = GoogleApiAvailabilityLight.getInstance();
    private static final Object zzb = new Object();
    private static Method zzc = null;
    private static boolean zzd = false;

    /* JADX INFO: compiled from: com.google.android.gms:play-services-basement@@18.8.0 */
    public interface ProviderInstallListener {
        void onProviderInstallFailed(int i, Intent intent);

        void onProviderInstalled();
    }

    /* JADX WARN: Removed duplicated region for block: B:17:0x0051  */
    /* JADX WARN: Removed duplicated region for block: B:18:0x0052 A[Catch: all -> 0x00a7, TRY_LEAVE, TryCatch #1 {, blocks: (B:4:0x0014, B:7:0x001b, B:12:0x0040, B:13:0x0045, B:10:0x0029, B:15:0x0047, B:26:0x0091, B:27:0x0096, B:29:0x0098, B:30:0x00a6, B:18:0x0052, B:20:0x0057, B:23:0x0081), top: B:36:0x0014, inners: #0, #2 }] */
    /* JADX WARN: Removed duplicated region for block: B:26:0x0091 A[Catch: all -> 0x00a7, TryCatch #1 {, blocks: (B:4:0x0014, B:7:0x001b, B:12:0x0040, B:13:0x0045, B:10:0x0029, B:15:0x0047, B:26:0x0091, B:27:0x0096, B:29:0x0098, B:30:0x00a6, B:18:0x0052, B:20:0x0057, B:23:0x0081), top: B:36:0x0014, inners: #0, #2 }] */
    /* JADX WARN: Removed duplicated region for block: B:29:0x0098 A[Catch: all -> 0x00a7, TryCatch #1 {, blocks: (B:4:0x0014, B:7:0x001b, B:12:0x0040, B:13:0x0045, B:10:0x0029, B:15:0x0047, B:26:0x0091, B:27:0x0096, B:29:0x0098, B:30:0x00a6, B:18:0x0052, B:20:0x0057, B:23:0x0081), top: B:36:0x0014, inners: #0, #2 }] */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static void installIfNeeded(android.content.Context r14) throws com.google.android.gms.common.GooglePlayServicesRepairableException, com.google.android.gms.common.GooglePlayServicesNotAvailableException {
        /*
            java.lang.String r0 = "Context must not be null"
            com.google.android.gms.common.internal.Preconditions.checkNotNull(r14, r0)
            com.google.android.gms.common.GoogleApiAvailabilityLight r0 = com.google.android.gms.security.ProviderInstaller.zza
            r1 = 11925000(0xb5f608, float:1.6710484E-38)
            r0.verifyGooglePlayServicesIsAvailable(r14, r1)
            long r0 = android.os.SystemClock.uptimeMillis()
            java.lang.Object r2 = com.google.android.gms.security.ProviderInstaller.zzb
            monitor-enter(r2)
            boolean r3 = com.google.android.gms.security.ProviderInstaller.zzd     // Catch: java.lang.Throwable -> La7
            r4 = 0
            if (r3 != 0) goto L47
            java.lang.String r3 = "Failed to load providerinstaller module: "
            com.google.android.gms.dynamite.DynamiteModule$VersionPolicy r5 = com.google.android.gms.dynamite.DynamiteModule.PREFER_HIGHEST_OR_LOCAL_VERSION_NO_FORCE_STAGING     // Catch: com.google.android.gms.dynamite.DynamiteModule.LoadingException -> L28 java.lang.Throwable -> La7
            java.lang.String r6 = "com.google.android.gms.providerinstaller.dynamite"
            com.google.android.gms.dynamite.DynamiteModule r5 = com.google.android.gms.dynamite.DynamiteModule.load(r14, r5, r6)     // Catch: com.google.android.gms.dynamite.DynamiteModule.LoadingException -> L28 java.lang.Throwable -> La7
            android.content.Context r3 = r5.getModuleContext()     // Catch: com.google.android.gms.dynamite.DynamiteModule.LoadingException -> L28 java.lang.Throwable -> La7
            goto L3e
        L28:
            r5 = move-exception
            java.lang.String r6 = "ProviderInstaller"
            java.lang.String r5 = r5.getMessage()     // Catch: java.lang.Throwable -> La7
            java.lang.String.valueOf(r5)     // Catch: java.lang.Throwable -> La7
            java.lang.String r5 = java.lang.String.valueOf(r5)     // Catch: java.lang.Throwable -> La7
            java.lang.String r3 = r3.concat(r5)     // Catch: java.lang.Throwable -> La7
            android.util.Log.w(r6, r3)     // Catch: java.lang.Throwable -> La7
            r3 = r4
        L3e:
            if (r3 == 0) goto L47
            java.lang.String r0 = "com.google.android.gms.providerinstaller.ProviderInstallerImpl"
            zzb(r3, r14, r0)     // Catch: java.lang.Throwable -> La7
            monitor-exit(r2)     // Catch: java.lang.Throwable -> La7
            goto L97
        L47:
            boolean r3 = com.google.android.gms.security.ProviderInstaller.zzd     // Catch: java.lang.Throwable -> La7
            java.lang.String r5 = "Failed to report request stats: "
            android.content.Context r6 = com.google.android.gms.common.GooglePlayServicesUtilLight.getRemoteContext(r14)     // Catch: java.lang.Throwable -> La7
            if (r6 != 0) goto L52
            goto L8f
        L52:
            r4 = 1
            com.google.android.gms.security.ProviderInstaller.zzd = r4     // Catch: java.lang.Throwable -> La7
            if (r3 != 0) goto L8e
            long r7 = android.os.SystemClock.uptimeMillis()     // Catch: java.lang.Exception -> L80 java.lang.Throwable -> La7
            java.lang.String r3 = "com.google.android.gms.common.security.ProviderInstallerImpl"
            java.lang.String r9 = "reportRequestStats2"
            java.lang.ClassLoader r10 = r6.getClassLoader()     // Catch: java.lang.Exception -> L80 java.lang.Throwable -> La7
            r11 = 3
            com.google.android.gms.internal.common.zzi[] r11 = new com.google.android.gms.internal.common.zzi[r11]     // Catch: java.lang.Exception -> L80 java.lang.Throwable -> La7
            java.lang.Class<android.content.Context> r12 = android.content.Context.class
            com.google.android.gms.internal.common.zzi r12 = com.google.android.gms.internal.common.zzi.zzb(r12, r14)     // Catch: java.lang.Exception -> L80 java.lang.Throwable -> La7
            r13 = 0
            r11[r13] = r12     // Catch: java.lang.Exception -> L80 java.lang.Throwable -> La7
            com.google.android.gms.internal.common.zzh r0 = com.google.android.gms.internal.common.zzh.zza(r0)     // Catch: java.lang.Exception -> L80 java.lang.Throwable -> La7
            r11[r4] = r0     // Catch: java.lang.Exception -> L80 java.lang.Throwable -> La7
            com.google.android.gms.internal.common.zzh r0 = com.google.android.gms.internal.common.zzh.zza(r7)     // Catch: java.lang.Exception -> L80 java.lang.Throwable -> La7
            r1 = 2
            r11[r1] = r0     // Catch: java.lang.Exception -> L80 java.lang.Throwable -> La7
            com.google.android.gms.internal.common.zzj.zzb(r3, r9, r10, r11)     // Catch: java.lang.Exception -> L80 java.lang.Throwable -> La7
            goto L8e
        L80:
            r0 = move-exception
            java.lang.String r1 = "ProviderInstaller"
            java.lang.String r0 = r0.toString()     // Catch: java.lang.Throwable -> La7
            java.lang.String r0 = r5.concat(r0)     // Catch: java.lang.Throwable -> La7
            android.util.Log.w(r1, r0)     // Catch: java.lang.Throwable -> La7
        L8e:
            r4 = r6
        L8f:
            if (r4 == 0) goto L98
            java.lang.String r0 = "com.google.android.gms.common.security.ProviderInstallerImpl"
            zzb(r4, r14, r0)     // Catch: java.lang.Throwable -> La7
            monitor-exit(r2)     // Catch: java.lang.Throwable -> La7
        L97:
            return
        L98:
            java.lang.String r14 = "ProviderInstaller"
            java.lang.String r0 = "Failed to get remote context"
            android.util.Log.e(r14, r0)     // Catch: java.lang.Throwable -> La7
            com.google.android.gms.common.GooglePlayServicesNotAvailableException r14 = new com.google.android.gms.common.GooglePlayServicesNotAvailableException     // Catch: java.lang.Throwable -> La7
            r0 = 8
            r14.<init>(r0)     // Catch: java.lang.Throwable -> La7
            throw r14     // Catch: java.lang.Throwable -> La7
        La7:
            r14 = move-exception
            monitor-exit(r2)     // Catch: java.lang.Throwable -> La7
            throw r14
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.gms.security.ProviderInstaller.installIfNeeded(android.content.Context):void");
    }

    public static void installIfNeededAsync(Context context, ProviderInstallListener providerInstallListener) {
        Preconditions.checkNotNull(context, "Context must not be null");
        Preconditions.checkNotNull(providerInstallListener, "Listener must not be null");
        Preconditions.checkMainThread("Must be called on the UI thread");
        new zza(context, providerInstallListener).execute(new Void[0]);
    }

    private static void zzb(Context context, Context context2, String str) throws GooglePlayServicesNotAvailableException {
        try {
            if (zzc == null) {
                zzc = context.getClassLoader().loadClass(str).getMethod("insertProvider", Context.class);
            }
            zzc.invoke(null, context);
        } catch (Exception e) {
            Throwable cause = e.getCause();
            if (Log.isLoggable("ProviderInstaller", 6)) {
                String string = cause == null ? e.toString() : cause.toString();
                String.valueOf(string);
                Log.e("ProviderInstaller", "Failed to install provider: ".concat(String.valueOf(string)));
            }
            throw new GooglePlayServicesNotAvailableException(8);
        }
    }
}
