package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.android.gms.internal.p002firebaseauthapi.zzalf;
import com.google.common.base.Ascii;
import java.io.IOException;
import kotlinx.coroutines.scheduling.WorkQueueKt;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zzajr {
    private static volatile int zza = 100;

    static double zza(byte[] bArr, int i) {
        return Double.longBitsToDouble(zzd(bArr, i));
    }

    static float zzb(byte[] bArr, int i) {
        return Float.intBitsToFloat(zzc(bArr, i));
    }

    static int zza(byte[] bArr, int i, zzaju zzajuVar) throws zzall {
        int iZzc = zzc(bArr, i, zzajuVar);
        int i2 = zzajuVar.zza;
        if (i2 < 0) {
            throw zzall.zzf();
        }
        if (i2 > bArr.length - iZzc) {
            throw zzall.zzj();
        }
        if (i2 == 0) {
            zzajuVar.zzc = zzajv.zza;
            return iZzc;
        }
        zzajuVar.zzc = zzajv.zza(bArr, iZzc, i2);
        return iZzc + i2;
    }

    static int zza(int i, byte[] bArr, int i2, int i3, Object obj, zzamm zzammVar, zzanu<zzanx, zzanx> zzanuVar, zzaju zzajuVar) throws IOException {
        if (zzajuVar.zzd.zza(zzammVar, i >>> 3) == null) {
            return zza(i, bArr, i2, i3, zzamq.zzc(obj), zzajuVar);
        }
        zzalf.zzd zzdVar = (zzalf.zzd) obj;
        zzdVar.zza();
        zzakx<zzalf.zzc> zzakxVar = zzdVar.zzc;
        throw new NoSuchMethodError();
    }

    static int zzc(byte[] bArr, int i) {
        return ((bArr[i + 3] & 255) << 24) | (bArr[i] & 255) | ((bArr[i + 1] & 255) << 8) | ((bArr[i + 2] & 255) << 16);
    }

    private static <T> int zza(zzanb<T> zzanbVar, byte[] bArr, int i, int i2, int i3, zzaju zzajuVar) throws IOException {
        T tZza = zzanbVar.zza();
        int iZza = zza(tZza, zzanbVar, bArr, i, i2, i3, zzajuVar);
        zzanbVar.zzd(tZza);
        zzajuVar.zzc = tZza;
        return iZza;
    }

    static int zza(zzanb<?> zzanbVar, int i, byte[] bArr, int i2, int i3, zzalm<Object> zzalmVar, zzaju zzajuVar) throws IOException {
        int i4 = (i & (-8)) | 4;
        int iZza = zza(zzanbVar, bArr, i2, i3, i4, zzajuVar);
        zzalmVar.add(zzajuVar.zzc);
        while (iZza < i3) {
            int iZzc = zzc(bArr, iZza, zzajuVar);
            if (i != zzajuVar.zza) {
                break;
            }
            iZza = zza(zzanbVar, bArr, iZzc, i3, i4, zzajuVar);
            zzalmVar.add(zzajuVar.zzc);
        }
        return iZza;
    }

    static <T> int zza(zzanb<T> zzanbVar, byte[] bArr, int i, int i2, zzaju zzajuVar) throws IOException {
        T tZza = zzanbVar.zza();
        int iZza = zza(tZza, zzanbVar, bArr, i, i2, zzajuVar);
        zzanbVar.zzd(tZza);
        zzajuVar.zzc = tZza;
        return iZza;
    }

    static int zzb(zzanb<?> zzanbVar, int i, byte[] bArr, int i2, int i3, zzalm<?> zzalmVar, zzaju zzajuVar) throws IOException {
        int iZza = zza(zzanbVar, bArr, i2, i3, zzajuVar);
        zzalmVar.add(zzajuVar.zzc);
        while (iZza < i3) {
            int iZzc = zzc(bArr, iZza, zzajuVar);
            if (i != zzajuVar.zza) {
                break;
            }
            iZza = zza(zzanbVar, bArr, iZzc, i3, zzajuVar);
            zzalmVar.add(zzajuVar.zzc);
        }
        return iZza;
    }

    static int zza(byte[] bArr, int i, zzalm<?> zzalmVar, zzaju zzajuVar) throws IOException {
        zzali zzaliVar = (zzali) zzalmVar;
        int iZzc = zzc(bArr, i, zzajuVar);
        int i2 = zzajuVar.zza + iZzc;
        while (iZzc < i2) {
            iZzc = zzc(bArr, iZzc, zzajuVar);
            zzaliVar.zzc(zzajuVar.zza);
        }
        if (iZzc == i2) {
            return iZzc;
        }
        throw zzall.zzj();
    }

    static int zzb(byte[] bArr, int i, zzaju zzajuVar) throws zzall {
        int iZzc = zzc(bArr, i, zzajuVar);
        int i2 = zzajuVar.zza;
        if (i2 < 0) {
            throw zzall.zzf();
        }
        if (i2 == 0) {
            zzajuVar.zzc = "";
            return iZzc;
        }
        zzajuVar.zzc = zzaoa.zzb(bArr, iZzc, i2);
        return iZzc + i2;
    }

    static int zza(int i, byte[] bArr, int i2, int i3, zzanx zzanxVar, zzaju zzajuVar) throws zzall {
        if ((i >>> 3) == 0) {
            throw zzall.zzc();
        }
        int i4 = i & 7;
        if (i4 == 0) {
            int iZzd = zzd(bArr, i2, zzajuVar);
            zzanxVar.zza(i, Long.valueOf(zzajuVar.zzb));
            return iZzd;
        }
        if (i4 == 1) {
            zzanxVar.zza(i, Long.valueOf(zzd(bArr, i2)));
            return i2 + 8;
        }
        if (i4 == 2) {
            int iZzc = zzc(bArr, i2, zzajuVar);
            int i5 = zzajuVar.zza;
            if (i5 < 0) {
                throw zzall.zzf();
            }
            if (i5 > bArr.length - iZzc) {
                throw zzall.zzj();
            }
            if (i5 == 0) {
                zzanxVar.zza(i, zzajv.zza);
            } else {
                zzanxVar.zza(i, zzajv.zza(bArr, iZzc, i5));
            }
            return iZzc + i5;
        }
        if (i4 != 3) {
            if (i4 == 5) {
                zzanxVar.zza(i, Integer.valueOf(zzc(bArr, i2)));
                return i2 + 4;
            }
            throw zzall.zzc();
        }
        zzanx zzanxVarZzd = zzanx.zzd();
        int i6 = (i & (-8)) | 4;
        zzajuVar.zze++;
        zza(zzajuVar.zze);
        int i7 = 0;
        while (true) {
            if (i2 >= i3) {
                break;
            }
            int iZzc2 = zzc(bArr, i2, zzajuVar);
            i7 = zzajuVar.zza;
            if (i7 == i6) {
                i2 = iZzc2;
                break;
            }
            i2 = zza(i7, bArr, iZzc2, i3, zzanxVarZzd, zzajuVar);
        }
        zzajuVar.zze--;
        if (i2 > i3 || i7 != i6) {
            throw zzall.zzg();
        }
        zzanxVar.zza(i, zzanxVarZzd);
        return i2;
    }

    static int zzc(byte[] bArr, int i, zzaju zzajuVar) {
        int i2 = i + 1;
        byte b = bArr[i];
        if (b >= 0) {
            zzajuVar.zza = b;
            return i2;
        }
        return zza(b, bArr, i2, zzajuVar);
    }

    static int zza(int i, byte[] bArr, int i2, zzaju zzajuVar) {
        int i3 = i & WorkQueueKt.MASK;
        int i4 = i2 + 1;
        byte b = bArr[i2];
        if (b >= 0) {
            zzajuVar.zza = i3 | (b << 7);
            return i4;
        }
        int i5 = i3 | ((b & 127) << 7);
        int i6 = i2 + 2;
        byte b2 = bArr[i4];
        if (b2 >= 0) {
            zzajuVar.zza = i5 | (b2 << Ascii.SO);
            return i6;
        }
        int i7 = i5 | ((b2 & 127) << 14);
        int i8 = i2 + 3;
        byte b3 = bArr[i6];
        if (b3 >= 0) {
            zzajuVar.zza = i7 | (b3 << Ascii.NAK);
            return i8;
        }
        int i9 = i7 | ((b3 & 127) << 21);
        int i10 = i2 + 4;
        byte b4 = bArr[i8];
        if (b4 >= 0) {
            zzajuVar.zza = i9 | (b4 << Ascii.FS);
            return i10;
        }
        int i11 = i9 | ((b4 & 127) << 28);
        while (true) {
            int i12 = i10 + 1;
            if (bArr[i10] >= 0) {
                zzajuVar.zza = i11;
                return i12;
            }
            i10 = i12;
        }
    }

    static int zza(int i, byte[] bArr, int i2, int i3, zzalm<?> zzalmVar, zzaju zzajuVar) {
        zzali zzaliVar = (zzali) zzalmVar;
        int iZzc = zzc(bArr, i2, zzajuVar);
        zzaliVar.zzc(zzajuVar.zza);
        while (iZzc < i3) {
            int iZzc2 = zzc(bArr, iZzc, zzajuVar);
            if (i != zzajuVar.zza) {
                break;
            }
            iZzc = zzc(bArr, iZzc2, zzajuVar);
            zzaliVar.zzc(zzajuVar.zza);
        }
        return iZzc;
    }

    static int zzd(byte[] bArr, int i, zzaju zzajuVar) {
        int i2 = i + 1;
        long j = bArr[i];
        if (j >= 0) {
            zzajuVar.zzb = j;
            return i2;
        }
        int i3 = i + 2;
        byte b = bArr[i2];
        long j2 = (j & 127) | (((long) (b & 127)) << 7);
        int i4 = 7;
        while (b < 0) {
            int i5 = i3 + 1;
            byte b2 = bArr[i3];
            i4 += 7;
            j2 |= ((long) (b2 & 127)) << i4;
            b = b2;
            i3 = i5;
        }
        zzajuVar.zzb = j2;
        return i3;
    }

    static <T> int zza(Object obj, zzanb<T> zzanbVar, byte[] bArr, int i, int i2, int i3, zzaju zzajuVar) throws IOException {
        zzajuVar.zze++;
        zza(zzajuVar.zze);
        int iZza = ((zzamq) zzanbVar).zza(obj, bArr, i, i2, i3, zzajuVar);
        zzajuVar.zze--;
        zzajuVar.zzc = obj;
        return iZza;
    }

    static <T> int zza(Object obj, zzanb<T> zzanbVar, byte[] bArr, int i, int i2, zzaju zzajuVar) throws IOException {
        int iZza = i + 1;
        int i3 = bArr[i];
        if (i3 < 0) {
            iZza = zza(i3, bArr, iZza, zzajuVar);
            i3 = zzajuVar.zza;
        }
        int i4 = iZza;
        if (i3 < 0 || i3 > i2 - i4) {
            throw zzall.zzj();
        }
        zzajuVar.zze++;
        zza(zzajuVar.zze);
        int i5 = i4 + i3;
        zzanbVar.zza(obj, bArr, i4, i5, zzajuVar);
        zzajuVar.zze--;
        zzajuVar.zzc = obj;
        return i5;
    }

    static int zza(int i, byte[] bArr, int i2, int i3, zzaju zzajuVar) throws zzall {
        if ((i >>> 3) == 0) {
            throw zzall.zzc();
        }
        int i4 = i & 7;
        if (i4 == 0) {
            return zzd(bArr, i2, zzajuVar);
        }
        if (i4 == 1) {
            return i2 + 8;
        }
        if (i4 == 2) {
            return zzc(bArr, i2, zzajuVar) + zzajuVar.zza;
        }
        if (i4 != 3) {
            if (i4 == 5) {
                return i2 + 4;
            }
            throw zzall.zzc();
        }
        int i5 = (i & (-8)) | 4;
        int i6 = 0;
        while (i2 < i3) {
            i2 = zzc(bArr, i2, zzajuVar);
            i6 = zzajuVar.zza;
            if (i6 == i5) {
                break;
            }
            i2 = zza(i6, bArr, i2, i3, zzajuVar);
        }
        if (i2 > i3 || i6 != i5) {
            throw zzall.zzg();
        }
        return i2;
    }

    static long zzd(byte[] bArr, int i) {
        return ((((long) bArr[i + 7]) & 255) << 56) | (((long) bArr[i]) & 255) | ((((long) bArr[i + 1]) & 255) << 8) | ((((long) bArr[i + 2]) & 255) << 16) | ((((long) bArr[i + 3]) & 255) << 24) | ((((long) bArr[i + 4]) & 255) << 32) | ((((long) bArr[i + 5]) & 255) << 40) | ((((long) bArr[i + 6]) & 255) << 48);
    }

    private static void zza(int i) throws zzall {
        if (i >= zza) {
            throw zzall.zzh();
        }
    }
}
