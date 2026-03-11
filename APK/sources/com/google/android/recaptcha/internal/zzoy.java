package com.google.android.recaptcha.internal;

import java.io.IOException;
import java.util.Iterator;
import java.util.List;
import java.util.RandomAccess;

/* JADX INFO: compiled from: com.google.android.recaptcha:recaptcha@@18.6.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zzoy {
    public static final /* synthetic */ int zza = 0;
    private static final zzpl zzb;

    static {
        int i = zzos.zza;
        zzb = new zzpn();
    }

    public static void zzA(int i, List list, zzpy zzpyVar, boolean z) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzpyVar.zzA(i, list, z);
    }

    public static void zzB(int i, List list, zzpy zzpyVar, boolean z) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzpyVar.zzC(i, list, z);
    }

    public static void zzC(int i, List list, zzpy zzpyVar, boolean z) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzpyVar.zzE(i, list, z);
    }

    public static void zzD(int i, List list, zzpy zzpyVar, boolean z) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzpyVar.zzJ(i, list, z);
    }

    public static void zzE(int i, List list, zzpy zzpyVar, boolean z) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzpyVar.zzL(i, list, z);
    }

    static boolean zzF(Object obj, Object obj2) {
        if (obj != obj2) {
            return obj != null && obj.equals(obj2);
        }
        return true;
    }

    static int zza(List list) {
        int size = list.size();
        int i = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zzne)) {
            int iZzB = 0;
            while (i < size) {
                iZzB += zzln.zzB(((Integer) list.get(i)).intValue());
                i++;
            }
            return iZzB;
        }
        zzne zzneVar = (zzne) list;
        int iZzB2 = 0;
        while (i < size) {
            iZzB2 += zzln.zzB(zzneVar.zze(i));
            i++;
        }
        return iZzB2;
    }

    static int zzb(int i, List list, boolean z) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return size * (zzln.zzA(i << 3) + 4);
    }

    static int zzc(List list) {
        return list.size() * 4;
    }

    static int zzd(int i, List list, boolean z) {
        int size = list.size();
        if (size == 0) {
            return 0;
        }
        return size * (zzln.zzA(i << 3) + 8);
    }

    static int zze(List list) {
        return list.size() * 8;
    }

    static int zzf(List list) {
        int size = list.size();
        int i = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zzne)) {
            int iZzB = 0;
            while (i < size) {
                iZzB += zzln.zzB(((Integer) list.get(i)).intValue());
                i++;
            }
            return iZzB;
        }
        zzne zzneVar = (zzne) list;
        int iZzB2 = 0;
        while (i < size) {
            iZzB2 += zzln.zzB(zzneVar.zze(i));
            i++;
        }
        return iZzB2;
    }

    static int zzg(List list) {
        int size = list.size();
        int i = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zznx)) {
            int iZzB = 0;
            while (i < size) {
                iZzB += zzln.zzB(((Long) list.get(i)).longValue());
                i++;
            }
            return iZzB;
        }
        zznx zznxVar = (zznx) list;
        int iZzB2 = 0;
        while (i < size) {
            iZzB2 += zzln.zzB(zznxVar.zze(i));
            i++;
        }
        return iZzB2;
    }

    static int zzh(int i, Object obj, zzow zzowVar) {
        int i2 = i << 3;
        if (!(obj instanceof zznt)) {
            return zzln.zzA(i2) + zzln.zzy((zzoi) obj, zzowVar);
        }
        int iZzA = zzln.zzA(i2);
        int iZza = ((zznt) obj).zza();
        return iZzA + zzln.zzA(iZza) + iZza;
    }

    static int zzi(List list) {
        int size = list.size();
        int i = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zzne)) {
            int iZzA = 0;
            while (i < size) {
                int iIntValue = ((Integer) list.get(i)).intValue();
                iZzA += zzln.zzA((iIntValue >> 31) ^ (iIntValue + iIntValue));
                i++;
            }
            return iZzA;
        }
        zzne zzneVar = (zzne) list;
        int iZzA2 = 0;
        while (i < size) {
            int iZze = zzneVar.zze(i);
            iZzA2 += zzln.zzA((iZze >> 31) ^ (iZze + iZze));
            i++;
        }
        return iZzA2;
    }

    static int zzj(List list) {
        int size = list.size();
        int i = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zznx)) {
            int iZzB = 0;
            while (i < size) {
                long jLongValue = ((Long) list.get(i)).longValue();
                iZzB += zzln.zzB((jLongValue >> 63) ^ (jLongValue + jLongValue));
                i++;
            }
            return iZzB;
        }
        zznx zznxVar = (zznx) list;
        int iZzB2 = 0;
        while (i < size) {
            long jZze = zznxVar.zze(i);
            iZzB2 += zzln.zzB((jZze >> 63) ^ (jZze + jZze));
            i++;
        }
        return iZzB2;
    }

    static int zzk(List list) {
        int size = list.size();
        int i = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zzne)) {
            int iZzA = 0;
            while (i < size) {
                iZzA += zzln.zzA(((Integer) list.get(i)).intValue());
                i++;
            }
            return iZzA;
        }
        zzne zzneVar = (zzne) list;
        int iZzA2 = 0;
        while (i < size) {
            iZzA2 += zzln.zzA(zzneVar.zze(i));
            i++;
        }
        return iZzA2;
    }

    static int zzl(List list) {
        int size = list.size();
        int i = 0;
        if (size == 0) {
            return 0;
        }
        if (!(list instanceof zznx)) {
            int iZzB = 0;
            while (i < size) {
                iZzB += zzln.zzB(((Long) list.get(i)).longValue());
                i++;
            }
            return iZzB;
        }
        zznx zznxVar = (zznx) list;
        int iZzB2 = 0;
        while (i < size) {
            iZzB2 += zzln.zzB(zznxVar.zze(i));
            i++;
        }
        return iZzB2;
    }

    public static zzpl zzm() {
        return zzb;
    }

    static Object zzn(Object obj, int i, List list, zznh zznhVar, Object obj2, zzpl zzplVar) {
        if (zznhVar == null) {
            return obj2;
        }
        if (!(list instanceof RandomAccess)) {
            Iterator it = list.iterator();
            while (it.hasNext()) {
                int iIntValue = ((Integer) it.next()).intValue();
                if (!zznhVar.zza(iIntValue)) {
                    obj2 = zzo(obj, i, iIntValue, obj2, zzplVar);
                    it.remove();
                }
            }
            return obj2;
        }
        int size = list.size();
        int i2 = 0;
        for (int i3 = 0; i3 < size; i3++) {
            int iIntValue2 = ((Integer) list.get(i3)).intValue();
            if (zznhVar.zza(iIntValue2)) {
                if (i3 != i2) {
                    list.set(i2, Integer.valueOf(iIntValue2));
                }
                i2++;
            } else {
                obj2 = zzo(obj, i, iIntValue2, obj2, zzplVar);
            }
        }
        if (i2 != size) {
            list.subList(i2, size).clear();
        }
        return obj2;
    }

    static Object zzo(Object obj, int i, int i2, Object obj2, zzpl zzplVar) {
        if (obj2 == null) {
            obj2 = zzplVar.zza(obj);
        }
        zzplVar.zzh(obj2, i, i2);
        return obj2;
    }

    static void zzp(zzmp zzmpVar, Object obj, Object obj2) {
        zzmt zzmtVar = ((zzna) obj2).zzb;
        if (zzmtVar.zza.isEmpty()) {
            return;
        }
        ((zzna) obj).zzi().zzh(zzmtVar);
    }

    static void zzq(zzpl zzplVar, Object obj, Object obj2) {
        zznd zzndVar = (zznd) obj;
        zzpm zzpmVarZze = zzndVar.zzc;
        zzpm zzpmVar = ((zznd) obj2).zzc;
        if (!zzpm.zzc().equals(zzpmVar)) {
            if (zzpm.zzc().equals(zzpmVarZze)) {
                zzpmVarZze = zzpm.zze(zzpmVarZze, zzpmVar);
            } else {
                zzpmVarZze.zzd(zzpmVar);
            }
        }
        zzndVar.zzc = zzpmVarZze;
    }

    public static void zzr(int i, List list, zzpy zzpyVar, boolean z) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzpyVar.zzc(i, list, z);
    }

    public static void zzs(int i, List list, zzpy zzpyVar, boolean z) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzpyVar.zzg(i, list, z);
    }

    public static void zzt(int i, List list, zzpy zzpyVar, boolean z) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzpyVar.zzj(i, list, z);
    }

    public static void zzu(int i, List list, zzpy zzpyVar, boolean z) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzpyVar.zzl(i, list, z);
    }

    public static void zzv(int i, List list, zzpy zzpyVar, boolean z) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzpyVar.zzn(i, list, z);
    }

    public static void zzw(int i, List list, zzpy zzpyVar, boolean z) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzpyVar.zzp(i, list, z);
    }

    public static void zzx(int i, List list, zzpy zzpyVar, boolean z) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzpyVar.zzs(i, list, z);
    }

    public static void zzy(int i, List list, zzpy zzpyVar, boolean z) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzpyVar.zzu(i, list, z);
    }

    public static void zzz(int i, List list, zzpy zzpyVar, boolean z) throws IOException {
        if (list == null || list.isEmpty()) {
            return;
        }
        zzpyVar.zzy(i, list, z);
    }
}
