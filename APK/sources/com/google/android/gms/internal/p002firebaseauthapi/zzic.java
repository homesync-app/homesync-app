package com.google.android.gms.internal.p002firebaseauthapi;

import com.google.common.base.Ascii;
import io.flutter.embedding.android.KeyboardMap;
import java.util.Arrays;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzic {
    private static long zza(byte[] bArr, int i, int i2) {
        return (zza(bArr, i) >> i2) & 67108863;
    }

    private static long zza(byte[] bArr, int i) {
        return ((long) (((bArr[i + 3] & 255) << 24) | (bArr[i] & 255) | ((bArr[i + 1] & 255) << 8) | ((bArr[i + 2] & 255) << 16))) & KeyboardMap.kValueMask;
    }

    private static void zza(byte[] bArr, long j, int i) {
        int i2 = 0;
        while (i2 < 4) {
            bArr[i + i2] = (byte) (255 & j);
            i2++;
            j >>= 8;
        }
    }

    public static byte[] zza(byte[] bArr, byte[] bArr2) {
        if (bArr.length != 32) {
            throw new IllegalArgumentException("The key length in bytes must be 32.");
        }
        long jZza = zza(bArr, 0, 0) & 67108863;
        int i = 3;
        int i2 = 2;
        long jZza2 = zza(bArr, 3, 2) & 67108611;
        long jZza3 = zza(bArr, 6, 4) & 67092735;
        long jZza4 = zza(bArr, 9, 6) & 66076671;
        long jZza5 = zza(bArr, 12, 8) & 1048575;
        long j = jZza2 * 5;
        long j2 = jZza3 * 5;
        long j3 = jZza4 * 5;
        long j4 = jZza5 * 5;
        int i3 = 17;
        byte[] bArr3 = new byte[17];
        long j5 = 0;
        int i4 = 0;
        long j6 = 0;
        long j7 = 0;
        long j8 = 0;
        long j9 = 0;
        while (i4 < bArr2.length) {
            int iMin = Math.min(16, bArr2.length - i4);
            System.arraycopy(bArr2, i4, bArr3, 0, iMin);
            bArr3[iMin] = 1;
            if (iMin != 16) {
                Arrays.fill(bArr3, iMin + 1, i3, (byte) 0);
            }
            long jZza6 = j9 + zza(bArr3, 0, 0);
            long jZza7 = j5 + zza(bArr3, i, i2);
            long jZza8 = j6 + zza(bArr3, 6, 4);
            long jZza9 = j7 + zza(bArr3, 9, 6);
            long j10 = jZza2;
            long jZza10 = j8 + (zza(bArr3, 12, 8) | ((long) (bArr3[16] << Ascii.CAN)));
            long j11 = (jZza6 * jZza) + (jZza7 * j4) + (jZza8 * j3) + (jZza9 * j2) + (jZza10 * j);
            long j12 = (jZza6 * j10) + (jZza7 * jZza) + (jZza8 * j4) + (jZza9 * j3) + (jZza10 * j2);
            long j13 = (jZza6 * jZza3) + (jZza7 * j10) + (jZza8 * jZza) + (jZza9 * j4) + (jZza10 * j3);
            long j14 = (jZza6 * jZza4) + (jZza7 * jZza3) + (jZza8 * j10) + (jZza9 * jZza) + (jZza10 * j4);
            long j15 = j12 + (j11 >> 26);
            long j16 = j13 + (j15 >> 26);
            long j17 = j14 + (j16 >> 26);
            long j18 = (jZza6 * jZza5) + (jZza7 * jZza4) + (jZza8 * jZza3) + (jZza9 * j10) + (jZza10 * jZza) + (j17 >> 26);
            long j19 = (j11 & 67108863) + ((j18 >> 26) * 5);
            j5 = (j15 & 67108863) + (j19 >> 26);
            i4 += 16;
            j6 = j16 & 67108863;
            j7 = j17 & 67108863;
            j8 = j18 & 67108863;
            i3 = 17;
            i = 3;
            j9 = j19 & 67108863;
            jZza2 = j10;
            i2 = 2;
        }
        long j20 = j6 + (j5 >> 26);
        long j21 = j20 & 67108863;
        long j22 = j7 + (j20 >> 26);
        long j23 = j22 & 67108863;
        long j24 = j8 + (j22 >> 26);
        long j25 = j24 & 67108863;
        long j26 = j9 + ((j24 >> 26) * 5);
        long j27 = j26 & 67108863;
        long j28 = (j5 & 67108863) + (j26 >> 26);
        long j29 = j27 + 5;
        long j30 = j29 & 67108863;
        long j31 = (j29 >> 26) + j28;
        long j32 = j21 + (j31 >> 26);
        long j33 = j23 + (j32 >> 26);
        long j34 = (j25 + (j33 >> 26)) - 67108864;
        long j35 = j34 >> 63;
        long j36 = ~j35;
        long j37 = (j28 & j35) | (j31 & 67108863 & j36);
        long j38 = (j21 & j35) | (j32 & 67108863 & j36);
        long j39 = (j23 & j35) | (j33 & 67108863 & j36);
        long j40 = ((j37 << 26) | (j27 & j35) | (j30 & j36)) & KeyboardMap.kValueMask;
        long j41 = ((j37 >> 6) | (j38 << 20)) & KeyboardMap.kValueMask;
        long j42 = ((j38 >> 12) | (j39 << 14)) & KeyboardMap.kValueMask;
        long j43 = ((((j34 & j36) | (j25 & j35)) << 8) | (j39 >> 18)) & KeyboardMap.kValueMask;
        long jZza11 = j40 + zza(bArr, 16);
        long j44 = jZza11 & KeyboardMap.kValueMask;
        long jZza12 = j41 + zza(bArr, 20) + (jZza11 >> 32);
        long j45 = jZza12 & KeyboardMap.kValueMask;
        long jZza13 = j42 + zza(bArr, 24) + (jZza12 >> 32);
        long j46 = jZza13 & KeyboardMap.kValueMask;
        long jZza14 = (j43 + zza(bArr, 28) + (jZza13 >> 32)) & KeyboardMap.kValueMask;
        byte[] bArr4 = new byte[16];
        zza(bArr4, j44, 0);
        zza(bArr4, j45, 4);
        zza(bArr4, j46, 8);
        zza(bArr4, jZza14, 12);
        return bArr4;
    }
}
