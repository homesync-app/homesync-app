package com.google.android.recaptcha.internal;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkCapabilities;
import android.os.Build;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import kotlin.TuplesKt;
import kotlin.collections.MapsKt;
import kotlin.collections.SetsKt;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: com.google.android.recaptcha:recaptcha@@18.6.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzbe {
    public zzbe() {
        new ConcurrentHashMap();
        zzb();
    }

    public static final Set zza(Context context) {
        try {
            LinkedHashSet linkedHashSet = new LinkedHashSet();
            Object systemService = context.getSystemService("connectivity");
            Intrinsics.checkNotNull(systemService, "null cannot be cast to non-null type android.net.ConnectivityManager");
            ConnectivityManager connectivityManager = (ConnectivityManager) systemService;
            NetworkCapabilities networkCapabilities = connectivityManager.getNetworkCapabilities(connectivityManager.getActiveNetwork());
            if (networkCapabilities != null && networkCapabilities.hasTransport(1)) {
                linkedHashSet.add(zzqi.TRANSPORT_WIFI);
            }
            if (networkCapabilities != null && networkCapabilities.hasTransport(0)) {
                linkedHashSet.add(zzqi.TRANSPORT_CELLULAR);
            }
            if (networkCapabilities != null && networkCapabilities.hasTransport(4)) {
                linkedHashSet.add(zzqi.TRANSPORT_VPN);
            }
            if (networkCapabilities != null && networkCapabilities.hasTransport(3)) {
                linkedHashSet.add(zzqi.TRANSPORT_ETHERNET);
            }
            if (networkCapabilities != null && networkCapabilities.hasCapability(16)) {
                linkedHashSet.add(zzqi.NET_CAPABILITY_VALIDATED);
            }
            return linkedHashSet;
        } catch (Exception unused) {
            return SetsKt.emptySet();
        }
    }

    private static final Map zzb() {
        Map mapMutableMapOf = MapsKt.mutableMapOf(TuplesKt.to(0, zzqi.NET_CAPABILITY_MMS), TuplesKt.to(1, zzqi.NET_CAPABILITY_SUPL), TuplesKt.to(2, zzqi.NET_CAPABILITY_DUN), TuplesKt.to(3, zzqi.NET_CAPABILITY_FOTA), TuplesKt.to(4, zzqi.NET_CAPABILITY_IMS), TuplesKt.to(5, zzqi.NET_CAPABILITY_CBS), TuplesKt.to(6, zzqi.NET_CAPABILITY_WIFI_P2P), TuplesKt.to(7, zzqi.NET_CAPABILITY_IA), TuplesKt.to(8, zzqi.NET_CAPABILITY_RCS), TuplesKt.to(9, zzqi.NET_CAPABILITY_XCAP), TuplesKt.to(10, zzqi.NET_CAPABILITY_EIMS), TuplesKt.to(11, zzqi.NET_CAPABILITY_NOT_METERED), TuplesKt.to(12, zzqi.NET_CAPABILITY_INTERNET), TuplesKt.to(13, zzqi.NET_CAPABILITY_NOT_RESTRICTED), TuplesKt.to(14, zzqi.NET_CAPABILITY_TRUSTED), TuplesKt.to(15, zzqi.NET_CAPABILITY_NOT_VPN));
        mapMutableMapOf.put(17, zzqi.NET_CAPABILITY_CAPTIVE_PORTAL);
        mapMutableMapOf.put(16, zzqi.NET_CAPABILITY_VALIDATED);
        if (Build.VERSION.SDK_INT >= 28) {
            mapMutableMapOf.put(18, zzqi.NET_CAPABILITY_NOT_ROAMING);
            mapMutableMapOf.put(19, zzqi.NET_CAPABILITY_FOREGROUND);
            mapMutableMapOf.put(20, zzqi.NET_CAPABILITY_NOT_CONGESTED);
            mapMutableMapOf.put(21, zzqi.NET_CAPABILITY_NOT_SUSPENDED);
        }
        if (Build.VERSION.SDK_INT >= 29) {
            mapMutableMapOf.put(23, zzqi.NET_CAPABILITY_MCX);
        }
        if (Build.VERSION.SDK_INT >= 30) {
            mapMutableMapOf.put(25, zzqi.NET_CAPABILITY_TEMPORARILY_NOT_METERED);
        }
        if (Build.VERSION.SDK_INT >= 31) {
            mapMutableMapOf.put(32, zzqi.NET_CAPABILITY_HEAD_UNIT);
            mapMutableMapOf.put(29, zzqi.NET_CAPABILITY_ENTERPRISE);
        }
        if (Build.VERSION.SDK_INT >= 33) {
            mapMutableMapOf.put(35, zzqi.NET_CAPABILITY_PRIORITIZE_BANDWIDTH);
            mapMutableMapOf.put(34, zzqi.NET_CAPABILITY_PRIORITIZE_LATENCY);
            mapMutableMapOf.put(33, zzqi.NET_CAPABILITY_MMTEL);
        }
        return mapMutableMapOf;
    }
}
