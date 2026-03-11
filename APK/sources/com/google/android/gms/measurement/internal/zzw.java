package com.google.android.gms.measurement.internal;

import android.content.BroadcastReceiver;

/* JADX INFO: compiled from: com.google.android.gms:play-services-measurement-impl@@23.0.0 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzw extends BroadcastReceiver {
    private final zzic zza;

    public zzw(zzic zzicVar) {
        this.zza = zzicVar;
    }

    /* JADX WARN: Removed duplicated region for block: B:20:0x004c  */
    @Override // android.content.BroadcastReceiver
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public final void onReceive(android.content.Context r3, android.content.Intent r4) {
        /*
            r2 = this;
            if (r4 != 0) goto L12
            com.google.android.gms.measurement.internal.zzic r3 = r2.zza
            com.google.android.gms.measurement.internal.zzgu r3 = r3.zzaV()
            com.google.android.gms.measurement.internal.zzgs r3 = r3.zze()
            java.lang.String r4 = "App receiver called with null intent"
            r3.zza(r4)
            return
        L12:
            java.lang.String r3 = r4.getAction()
            if (r3 != 0) goto L28
            com.google.android.gms.measurement.internal.zzic r3 = r2.zza
            com.google.android.gms.measurement.internal.zzgu r3 = r3.zzaV()
            com.google.android.gms.measurement.internal.zzgs r3 = r3.zze()
            java.lang.String r4 = "App receiver called with null action"
            r3.zza(r4)
            return
        L28:
            int r4 = r3.hashCode()
            r0 = -1928239649(0xffffffff8d1165df, float:-4.4804198E-31)
            r1 = 1
            if (r4 == r0) goto L42
            r0 = 1279883384(0x4c497878, float:5.2814304E7)
            if (r4 == r0) goto L38
            goto L4c
        L38:
            java.lang.String r4 = "com.google.android.gms.measurement.BATCHES_AVAILABLE"
            boolean r3 = r3.equals(r4)
            if (r3 == 0) goto L4c
            r3 = r1
            goto L4d
        L42:
            java.lang.String r4 = "com.google.android.gms.measurement.TRIGGERS_AVAILABLE"
            boolean r3 = r3.equals(r4)
            if (r3 == 0) goto L4c
            r3 = 0
            goto L4d
        L4c:
            r3 = -1
        L4d:
            if (r3 == 0) goto L7d
            if (r3 == r1) goto L61
            com.google.android.gms.measurement.internal.zzic r3 = r2.zza
            com.google.android.gms.measurement.internal.zzgu r3 = r3.zzaV()
            com.google.android.gms.measurement.internal.zzgs r3 = r3.zze()
            java.lang.String r4 = "App receiver called with unknown action"
            r3.zza(r4)
            return
        L61:
            com.google.android.gms.measurement.internal.zzic r3 = r2.zza
            com.google.android.gms.measurement.internal.zzgu r4 = r3.zzaV()
            com.google.android.gms.measurement.internal.zzgs r4 = r4.zzk()
            java.lang.String r0 = "[sgtm] App Receiver notified batches are available"
            r4.zza(r0)
            com.google.android.gms.measurement.internal.zzhz r3 = r3.zzaW()
            com.google.android.gms.measurement.internal.zzt r4 = new com.google.android.gms.measurement.internal.zzt
            r4.<init>()
            r3.zzj(r4)
            return
        L7d:
            com.google.android.gms.measurement.internal.zzic r3 = r2.zza
            com.google.android.gms.internal.measurement.zzqp.zza()
            com.google.android.gms.measurement.internal.zzal r4 = r3.zzc()
            r0 = 0
            com.google.android.gms.measurement.internal.zzfx r1 = com.google.android.gms.measurement.internal.zzfy.zzaQ
            boolean r4 = r4.zzp(r0, r1)
            if (r4 != 0) goto L90
            return
        L90:
            com.google.android.gms.measurement.internal.zzgu r4 = r3.zzaV()
            com.google.android.gms.measurement.internal.zzgs r4 = r4.zzk()
            java.lang.String r0 = "App receiver notified triggers are available"
            r4.zza(r0)
            com.google.android.gms.measurement.internal.zzhz r4 = r3.zzaW()
            com.google.android.gms.measurement.internal.zzu r0 = new com.google.android.gms.measurement.internal.zzu
            r0.<init>()
            r4.zzj(r0)
            return
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.android.gms.measurement.internal.zzw.onReceive(android.content.Context, android.content.Intent):void");
    }

    final /* synthetic */ void zza() {
        this.zza.zzx().zzh(((Long) zzfy.zzC.zzb(null)).longValue());
    }
}
