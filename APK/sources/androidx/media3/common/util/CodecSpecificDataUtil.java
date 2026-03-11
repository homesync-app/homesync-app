package androidx.media3.common.util;

import android.util.Pair;
import androidx.core.view.InputDeviceCompat;
import androidx.exifinterface.media.ExifInterface;
import androidx.media3.common.ColorInfo;
import androidx.media3.common.Format;
import androidx.media3.common.MimeTypes;
import androidx.media3.exoplayer.analytics.AnalyticsListener;
import androidx.media3.extractor.metadata.icy.IcyHeaders;
import com.google.common.base.Ascii;
import com.google.common.base.Preconditions;
import com.google.common.collect.ImmutableList;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import kotlinx.coroutines.internal.LockFreeTaskQueueCore;
import kotlinx.coroutines.scheduling.WorkQueueKt;

/* JADX INFO: loaded from: classes.dex */
public final class CodecSpecificDataUtil {
    private static final String CODEC_ID_AC4 = "ac-4";
    private static final String CODEC_ID_APV1 = "apv1";
    private static final String CODEC_ID_AV01 = "av01";
    private static final String CODEC_ID_AVC1 = "avc1";
    private static final String CODEC_ID_AVC2 = "avc2";
    private static final String CODEC_ID_H263 = "s263";
    private static final String CODEC_ID_HEV1 = "hev1";
    private static final String CODEC_ID_HVC1 = "hvc1";
    private static final String CODEC_ID_IAMF = "iamf";
    private static final String CODEC_ID_MP4A = "mp4a";
    private static final String CODEC_ID_VP09 = "vp09";
    private static final int EXTENDED_PAR = 15;
    private static final int OBU_IA_CODEC_CONFIG = 0;
    private static final int OBU_IA_SEQUENCE_HEADER = 31;
    private static final int RECTANGULAR = 0;
    private static final String TAG = "CodecSpecificDataUtil";
    private static final int VISUAL_OBJECT_LAYER = 1;
    private static final int VISUAL_OBJECT_LAYER_START = 32;
    private static final byte[] NAL_START_CODE = {0, 0, 0, 1};
    private static final String[] HEVC_GENERAL_PROFILE_SPACE_STRINGS = {"", ExifInterface.GPS_MEASUREMENT_IN_PROGRESS, "B", "C"};
    private static final Pattern PROFILE_PATTERN = Pattern.compile("^\\D?(\\d+)$");

    private static int ac4BitstreamAndPresentationVersionsToProfileConst(int i, int i2) {
        if (i == 0) {
            return i2 == 0 ? 257 : -1;
        }
        if (i == 1) {
            return i2 == 0 ? InputDeviceCompat.SOURCE_DPAD : i2 == 1 ? 514 : -1;
        }
        if (i != 2) {
            return -1;
        }
        if (i2 == 1) {
            return AnalyticsListener.EVENT_DRM_KEYS_REMOVED;
        }
        if (i2 == 2) {
            return AnalyticsListener.EVENT_PLAYER_RELEASED;
        }
        return -1;
    }

    private static int ac4LevelNumberToConst(int i) {
        if (i == 0) {
            return 1;
        }
        if (i == 1) {
            return 2;
        }
        if (i == 2) {
            return 4;
        }
        if (i != 3) {
            return i != 4 ? -1 : 16;
        }
        return 8;
    }

    private static int av1LevelNumberToConst(int i) {
        switch (i) {
            case 0:
                return 1;
            case 1:
                return 2;
            case 2:
                return 4;
            case 3:
                return 8;
            case 4:
                return 16;
            case 5:
                return 32;
            case 6:
                return 64;
            case 7:
                return 128;
            case 8:
                return 256;
            case 9:
                return 512;
            case 10:
                return 1024;
            case 11:
                return 2048;
            case 12:
                return 4096;
            case 13:
                return 8192;
            case 14:
                return 16384;
            case 15:
                return 32768;
            case 16:
                return 65536;
            case 17:
                return 131072;
            case 18:
                return 262144;
            case 19:
                return 524288;
            case 20:
                return 1048576;
            case 21:
                return 2097152;
            case 22:
                return 4194304;
            case 23:
                return 8388608;
            default:
                return -1;
        }
    }

    private static int avcLevelNumberToConst(int i) {
        switch (i) {
            case 10:
                return 1;
            case 11:
                return 4;
            case 12:
                return 8;
            case 13:
                return 16;
            default:
                switch (i) {
                    case 20:
                        return 32;
                    case 21:
                        return 64;
                    case 22:
                        return 128;
                    default:
                        switch (i) {
                            case 30:
                                return 256;
                            case 31:
                                return 512;
                            case 32:
                                return 1024;
                            default:
                                switch (i) {
                                    case 40:
                                        return 2048;
                                    case 41:
                                        return 4096;
                                    case 42:
                                        return 8192;
                                    default:
                                        switch (i) {
                                            case 50:
                                                return 16384;
                                            case 51:
                                                return 32768;
                                            case 52:
                                                return 65536;
                                            default:
                                                return -1;
                                        }
                                }
                        }
                }
        }
    }

    private static int avcProfileNumberToConst(int i) {
        if (i == 66) {
            return 1;
        }
        if (i == 77) {
            return 2;
        }
        if (i == 88) {
            return 4;
        }
        if (i == 100) {
            return 8;
        }
        if (i == 110) {
            return 16;
        }
        if (i != 122) {
            return i != 244 ? -1 : 64;
        }
        return 32;
    }

    private static int mp4aAudioObjectTypeToProfile(int i) {
        int i2 = 17;
        if (i != 17) {
            i2 = 20;
            if (i != 20) {
                i2 = 23;
                if (i != 23) {
                    i2 = 29;
                    if (i != 29) {
                        i2 = 39;
                        if (i != 39) {
                            i2 = 42;
                            if (i != 42) {
                                switch (i) {
                                    case 1:
                                        return 1;
                                    case 2:
                                        return 2;
                                    case 3:
                                        return 3;
                                    case 4:
                                        return 4;
                                    case 5:
                                        return 5;
                                    case 6:
                                        return 6;
                                    default:
                                        return -1;
                                }
                            }
                        }
                    }
                }
            }
        }
        return i2;
    }

    private static int vp9LevelNumberToConst(int i) {
        if (i == 10) {
            return 1;
        }
        if (i == 11) {
            return 2;
        }
        if (i == 20) {
            return 4;
        }
        if (i == 21) {
            return 8;
        }
        if (i == 30) {
            return 16;
        }
        if (i == 31) {
            return 32;
        }
        if (i == 40) {
            return 64;
        }
        if (i == 41) {
            return 128;
        }
        if (i == 50) {
            return 256;
        }
        if (i == 51) {
            return 512;
        }
        switch (i) {
            case LockFreeTaskQueueCore.FROZEN_SHIFT /* 60 */:
                return 2048;
            case LockFreeTaskQueueCore.CLOSED_SHIFT /* 61 */:
                return 4096;
            case 62:
                return 8192;
            default:
                return -1;
        }
    }

    private static int vp9ProfileNumberToConst(int i) {
        if (i == 0) {
            return 1;
        }
        if (i == 1) {
            return 2;
        }
        if (i != 2) {
            return i != 3 ? -1 : 8;
        }
        return 4;
    }

    public static int[] parseAlacAudioSpecificConfig(byte[] bArr) {
        ParsableByteArray parsableByteArray = new ParsableByteArray(bArr);
        parsableByteArray.setPosition(5);
        int unsignedByte = parsableByteArray.readUnsignedByte();
        parsableByteArray.setPosition(9);
        int unsignedByte2 = parsableByteArray.readUnsignedByte();
        parsableByteArray.setPosition(20);
        return new int[]{parsableByteArray.readUnsignedIntToInt(), unsignedByte2, unsignedByte};
    }

    public static List<byte[]> buildCea708InitializationData(boolean z) {
        return Collections.singletonList(z ? new byte[]{1} : new byte[]{0});
    }

    public static String buildIamfCodecString(byte[] bArr) {
        ParsableByteArray parsableByteArray = new ParsableByteArray(bArr);
        String invariant = null;
        String string = null;
        while (parsableByteArray.bytesLeft() > 0 && (invariant == null || string == null)) {
            int unsignedByte = parsableByteArray.readUnsignedByte();
            int i = unsignedByte >> 3;
            boolean z = (unsignedByte & 2) != 0;
            boolean z2 = (unsignedByte & 1) != 0;
            int unsignedLeb128ToInt = parsableByteArray.readUnsignedLeb128ToInt();
            if (i > 4 && i < 24 && z) {
                parsableByteArray.skipLeb128();
                parsableByteArray.skipLeb128();
            }
            if (z2) {
                parsableByteArray.skipBytes(parsableByteArray.readUnsignedLeb128ToInt());
            }
            int position = parsableByteArray.getPosition() + unsignedLeb128ToInt;
            if (i == 31) {
                parsableByteArray.skipBytes(4);
                invariant = Util.formatInvariant("iamf.%03X.%03X", Integer.valueOf(parsableByteArray.readUnsignedByte()), Integer.valueOf(parsableByteArray.readUnsignedByte()));
            } else if (i == 0) {
                parsableByteArray.skipLeb128();
                string = parsableByteArray.readString(4);
                if (string.equals(CODEC_ID_MP4A)) {
                    parsableByteArray.skipLeb128();
                    parsableByteArray.skipBytes(2);
                    ParsableBitArray parsableBitArray = new ParsableBitArray();
                    parsableBitArray.reset(parsableByteArray);
                    int bits = parsableBitArray.readBits(5);
                    if (bits == 31) {
                        bits = parsableBitArray.readBits(6) + 32;
                    }
                    string = string + ".40." + bits;
                }
            }
            parsableByteArray.setPosition(position);
        }
        if (invariant == null || string == null) {
            return null;
        }
        return invariant + "." + string;
    }

    public static boolean parseCea708InitializationData(List<byte[]> list) {
        return list.size() == 1 && list.get(0).length == 1 && list.get(0)[0] == 1;
    }

    public static ImmutableList<byte[]> buildVp9CodecPrivateInitializationData(byte b, byte b2, byte b3, byte b4) {
        return ImmutableList.of(new byte[]{1, 1, b, 2, 1, b2, 3, 1, b3, 4, 1, b4});
    }

    public static ByteBuffer getVorbisInitializationData(Format format) {
        Preconditions.checkArgument(format.initializationData.size() > 1, "csd-0 and csd-1 must be present for Vorbis.");
        byte[] bArr = format.initializationData.get(0);
        byte[] bArr2 = format.initializationData.get(1);
        int length = bArr.length;
        int length2 = bArr2.length;
        byte[] bArrXiphLaceEnc = xiphLaceEnc(length);
        byte[] bArrXiphLaceEnc2 = xiphLaceEnc(23);
        ByteBuffer byteBufferAllocate = ByteBuffer.allocate(bArrXiphLaceEnc.length + 1 + bArrXiphLaceEnc2.length + length + 23 + length2);
        byteBufferAllocate.put((byte) 2);
        byteBufferAllocate.put(bArrXiphLaceEnc);
        byteBufferAllocate.put(bArrXiphLaceEnc2);
        byteBufferAllocate.put(bArr);
        byteBufferAllocate.put(new byte[]{3, 118, 111, 114, 98, 105, 115, 7, 0, 0, 0, 97, 110, 100, 114, 111, 105, 100, 0, 0, 0, 0, 1});
        byteBufferAllocate.put(bArr2);
        byteBufferAllocate.flip();
        return byteBufferAllocate;
    }

    private static byte[] xiphLaceEnc(int i) {
        int i2 = i / 255;
        byte[] bArr = new byte[i2 + 1];
        Arrays.fill(bArr, (byte) -1);
        bArr[i2] = (byte) (i % 255);
        return bArr;
    }

    public static byte[] buildDolbyVisionInitializationData(int i, int i2) {
        int i3;
        int i4;
        byte[] bArr = new byte[24];
        if (i == 8) {
            i3 = 4;
            i4 = 0;
        } else if (i == 9) {
            i3 = 2;
            i4 = 1;
        } else {
            i3 = 0;
            i4 = 0;
        }
        bArr[0] = 1;
        bArr[1] = 0;
        byte b = (byte) ((i & WorkQueueKt.MASK) << 1);
        bArr[2] = b;
        bArr[2] = (byte) ((b | ((i2 >> 5) & 1)) & 255);
        byte b2 = (byte) ((i2 & 31) << 3);
        bArr[3] = b2;
        byte b3 = (byte) (b2 | 4);
        bArr[3] = b3;
        byte b4 = b3;
        bArr[3] = b4;
        bArr[3] = (byte) (b4 | 1);
        byte b5 = (byte) (i3 << 4);
        bArr[4] = b5;
        bArr[4] = (byte) (b5 | (i4 << 2));
        return bArr;
    }

    public static Pair<Integer, Integer> getVideoResolutionFromMpeg4VideoConfig(byte[] bArr) {
        boolean z;
        ParsableByteArray parsableByteArray = new ParsableByteArray(bArr);
        int i = 0;
        int i2 = 0;
        while (true) {
            int i3 = i2 + 3;
            if (i3 >= bArr.length) {
                z = false;
                break;
            }
            if (parsableByteArray.readUnsignedInt24() == 1 && (bArr[i3] & 240) == 32) {
                z = true;
                break;
            }
            parsableByteArray.setPosition(parsableByteArray.getPosition() - 2);
            i2++;
        }
        Preconditions.checkArgument(z, "Invalid input: VOL not found.");
        ParsableBitArray parsableBitArray = new ParsableBitArray(bArr);
        parsableBitArray.skipBits((i2 + 4) * 8);
        parsableBitArray.skipBits(1);
        parsableBitArray.skipBits(8);
        if (parsableBitArray.readBit()) {
            parsableBitArray.skipBits(4);
            parsableBitArray.skipBits(3);
        }
        if (parsableBitArray.readBits(4) == 15) {
            parsableBitArray.skipBits(8);
            parsableBitArray.skipBits(8);
        }
        if (parsableBitArray.readBit()) {
            parsableBitArray.skipBits(2);
            parsableBitArray.skipBits(1);
            if (parsableBitArray.readBit()) {
                parsableBitArray.skipBits(79);
            }
        }
        Preconditions.checkArgument(parsableBitArray.readBits(2) == 0, "Only supports rectangular video object layer shape.");
        Preconditions.checkArgument(parsableBitArray.readBit());
        int bits = parsableBitArray.readBits(16);
        Preconditions.checkArgument(parsableBitArray.readBit());
        if (parsableBitArray.readBit()) {
            Preconditions.checkArgument(bits > 0);
            for (int i4 = bits - 1; i4 > 0; i4 >>= 1) {
                i++;
            }
            parsableBitArray.skipBits(i);
        }
        Preconditions.checkArgument(parsableBitArray.readBit());
        int bits2 = parsableBitArray.readBits(13);
        Preconditions.checkArgument(parsableBitArray.readBit());
        int bits3 = parsableBitArray.readBits(13);
        Preconditions.checkArgument(parsableBitArray.readBit());
        parsableBitArray.skipBits(1);
        return Pair.create(Integer.valueOf(bits2), Integer.valueOf(bits3));
    }

    public static String buildAvcCodecString(int i, int i2, int i3) {
        return String.format("avc1.%02X%02X%02X", Integer.valueOf(i), Integer.valueOf(i2), Integer.valueOf(i3));
    }

    public static String buildHevcCodecString(int i, boolean z, int i2, int i3, int[] iArr, int i4) {
        StringBuilder sb = new StringBuilder(Util.formatInvariant("hvc1.%s%d.%X.%c%d", HEVC_GENERAL_PROFILE_SPACE_STRINGS[i], Integer.valueOf(i2), Integer.valueOf(i3), Character.valueOf(z ? 'H' : 'L'), Integer.valueOf(i4)));
        int length = iArr.length;
        while (length > 0 && iArr[length - 1] == 0) {
            length--;
        }
        for (int i5 = 0; i5 < length; i5++) {
            sb.append(String.format(".%02X", Integer.valueOf(iArr[i5])));
        }
        return sb.toString();
    }

    public static String buildApvCodecString(byte[] bArr) {
        Preconditions.checkArgument(bArr.length >= 17, "Invalid APV CSD length: %s", bArr.length);
        byte b = bArr[0];
        Preconditions.checkArgument(b == 1, "Invalid APV CSD version: %s", (int) b);
        return Util.formatInvariant("apv1.apvf%d.apvl%d.apvb%d", Integer.valueOf(bArr[5]), Integer.valueOf(bArr[6]), Integer.valueOf(bArr[7]));
    }

    public static String buildH263CodecString(int i, int i2) {
        return Util.formatInvariant("s263.%d.%d", Integer.valueOf(i), Integer.valueOf(i2));
    }

    public static String buildDolbyVisionCodecString(int i, int i2) {
        if (i > 9) {
            return Util.formatInvariant("dvh1.%02d.%02d", Integer.valueOf(i), Integer.valueOf(i2));
        }
        if (i > 8) {
            return Util.formatInvariant("dvav.%02d.%02d", Integer.valueOf(i), Integer.valueOf(i2));
        }
        return Util.formatInvariant("dvhe.%02d.%02d", Integer.valueOf(i), Integer.valueOf(i2));
    }

    public static Pair<Integer, Integer> getCodecProfileAndLevel(Format format) {
        if (format.codecs == null) {
            return null;
        }
        String[] strArrSplit = format.codecs.split("\\.");
        if (MimeTypes.VIDEO_DOLBY_VISION.equals(format.sampleMimeType)) {
            return getDolbyVisionProfileAndLevel(format.codecs, strArrSplit);
        }
        String str = strArrSplit[0];
        str.hashCode();
        switch (str) {
            case "ac-4":
                return getAc4CodecProfileAndLevel(format.codecs, strArrSplit);
            case "apv1":
                return getApvProfileAndLevel(format.codecs, strArrSplit);
            case "av01":
                return getAv1ProfileAndLevel(format.codecs, strArrSplit, format.colorInfo);
            case "avc1":
            case "avc2":
                return getAvcProfileAndLevel(format.codecs, strArrSplit);
            case "hev1":
            case "hvc1":
                return getHevcProfileAndLevel(format.codecs, strArrSplit, format.colorInfo);
            case "iamf":
                return getIamfCodecProfileAndLevel(format.codecs, strArrSplit);
            case "mp4a":
                return getAacCodecProfileAndLevel(format.codecs, strArrSplit);
            case "s263":
                return getH263ProfileAndLevel(format.codecs, strArrSplit);
            case "vp09":
                return getVp9ProfileAndLevel(format.codecs, strArrSplit);
            default:
                return null;
        }
    }

    public static Pair<Integer, Integer> getHevcProfileAndLevel(String str, String[] strArr, ColorInfo colorInfo) {
        if (strArr.length < 4) {
            Log.w(TAG, "Ignoring malformed HEVC codec string: " + str);
            return null;
        }
        int i = 1;
        Matcher matcher = PROFILE_PATTERN.matcher(strArr[1]);
        if (!matcher.matches()) {
            Log.w(TAG, "Ignoring malformed HEVC codec string: " + str);
            return null;
        }
        String strGroup = matcher.group(1);
        if (!IcyHeaders.REQUEST_HEADER_ENABLE_METADATA_VALUE.equals(strGroup)) {
            i = 6;
            if (ExifInterface.GPS_MEASUREMENT_2D.equals(strGroup)) {
                i = (colorInfo == null || colorInfo.colorTransfer != 6) ? 2 : 4096;
            } else if (!"6".equals(strGroup)) {
                Log.w(TAG, "Unknown HEVC profile string: " + strGroup);
                return null;
            }
        }
        String str2 = strArr[3];
        Integer numHevcCodecStringToProfileLevel = hevcCodecStringToProfileLevel(str2);
        if (numHevcCodecStringToProfileLevel == null) {
            Log.w(TAG, "Unknown HEVC level string: " + str2);
            return null;
        }
        return new Pair<>(Integer.valueOf(i), numHevcCodecStringToProfileLevel);
    }

    public static byte[] buildNalUnit(byte[] bArr, int i, int i2) {
        byte[] bArr2 = NAL_START_CODE;
        byte[] bArr3 = new byte[bArr2.length + i2];
        System.arraycopy(bArr2, 0, bArr3, 0, bArr2.length);
        System.arraycopy(bArr, i, bArr3, bArr2.length, i2);
        return bArr3;
    }

    public static byte[][] splitNalUnits(byte[] bArr) {
        if (!isNalStartCode(bArr, 0)) {
            return null;
        }
        ArrayList arrayList = new ArrayList();
        int iFindNalStartCode = 0;
        do {
            arrayList.add(Integer.valueOf(iFindNalStartCode));
            iFindNalStartCode = findNalStartCode(bArr, iFindNalStartCode + NAL_START_CODE.length);
        } while (iFindNalStartCode != -1);
        byte[][] bArr2 = new byte[arrayList.size()][];
        int i = 0;
        while (i < arrayList.size()) {
            int iIntValue = ((Integer) arrayList.get(i)).intValue();
            int iIntValue2 = (i < arrayList.size() + (-1) ? ((Integer) arrayList.get(i + 1)).intValue() : bArr.length) - iIntValue;
            byte[] bArr3 = new byte[iIntValue2];
            System.arraycopy(bArr, iIntValue, bArr3, 0, iIntValue2);
            bArr2[i] = bArr3;
            i++;
        }
        return bArr2;
    }

    public static int dolbyVisionConstantToLevelNumber(int i) {
        int i2 = 1;
        if (i != 1) {
            i2 = 2;
            if (i != 2) {
                switch (i) {
                    case 4:
                        return 3;
                    case 8:
                        return 4;
                    case 16:
                        return 5;
                    case 32:
                        return 6;
                    case 64:
                        return 7;
                    case 128:
                        return 8;
                    case 256:
                        return 9;
                    case 512:
                        return 10;
                    case 1024:
                        return 11;
                    case 2048:
                        return 12;
                    case 4096:
                        return 13;
                    default:
                        throw new IllegalArgumentException("Unknown Dolby Vision level: " + i);
                }
            }
        }
        return i2;
    }

    public static int dolbyVisionConstantToProfileNumber(int i) {
        if (i == 1) {
            return 0;
        }
        if (i == 2) {
            return 1;
        }
        if (i == 4) {
            return 2;
        }
        if (i == 8) {
            return 3;
        }
        if (i == 16) {
            return 4;
        }
        if (i == 32) {
            return 5;
        }
        if (i == 64) {
            return 6;
        }
        if (i == 128) {
            return 7;
        }
        if (i == 256) {
            return 8;
        }
        if (i == 512) {
            return 9;
        }
        if (i == 1024) {
            return 10;
        }
        throw new IllegalArgumentException("Unknown Dolby Vision profile: " + i);
    }

    private static int findNalStartCode(byte[] bArr, int i) {
        int length = bArr.length - NAL_START_CODE.length;
        while (i <= length) {
            if (isNalStartCode(bArr, i)) {
                return i;
            }
            i++;
        }
        return -1;
    }

    private static boolean isNalStartCode(byte[] bArr, int i) {
        if (bArr.length - i <= NAL_START_CODE.length) {
            return false;
        }
        int i2 = 0;
        while (true) {
            byte[] bArr2 = NAL_START_CODE;
            if (i2 >= bArr2.length) {
                return true;
            }
            if (bArr[i + i2] != bArr2[i2]) {
                return false;
            }
            i2++;
        }
    }

    private static Pair<Integer, Integer> getDolbyVisionProfileAndLevel(String str, String[] strArr) {
        if (strArr.length < 3) {
            Log.w(TAG, "Ignoring malformed Dolby Vision codec string: " + str);
            return null;
        }
        Matcher matcher = PROFILE_PATTERN.matcher(strArr[1]);
        if (!matcher.matches()) {
            Log.w(TAG, "Ignoring malformed Dolby Vision codec string: " + str);
            return null;
        }
        String strGroup = matcher.group(1);
        Integer numDolbyVisionStringToProfile = dolbyVisionStringToProfile(strGroup);
        if (numDolbyVisionStringToProfile == null) {
            Log.w(TAG, "Unknown Dolby Vision profile string: " + strGroup);
            return null;
        }
        String str2 = strArr[2];
        Integer numDolbyVisionStringToLevel = dolbyVisionStringToLevel(str2);
        if (numDolbyVisionStringToLevel == null) {
            Log.w(TAG, "Unknown Dolby Vision level string: " + str2);
            return null;
        }
        return new Pair<>(numDolbyVisionStringToProfile, numDolbyVisionStringToLevel);
    }

    private static Pair<Integer, Integer> getH263ProfileAndLevel(String str, String[] strArr) {
        Pair<Integer, Integer> pair = new Pair<>(1, 1);
        if (strArr.length < 3) {
            Log.w(TAG, "Ignoring malformed H263 codec string: " + str);
            return pair;
        }
        try {
            return new Pair<>(Integer.valueOf(Integer.parseInt(strArr[1])), Integer.valueOf(Integer.parseInt(strArr[2])));
        } catch (NumberFormatException unused) {
            Log.w(TAG, "Ignoring malformed H263 codec string: " + str);
            return pair;
        }
    }

    private static Pair<Integer, Integer> getAvcProfileAndLevel(String str, String[] strArr) {
        int i;
        int i2;
        if (strArr.length < 2) {
            Log.w(TAG, "Ignoring malformed AVC codec string: " + str);
            return null;
        }
        try {
            if (strArr[1].length() == 6) {
                i2 = Integer.parseInt(strArr[1].substring(0, 2), 16);
                i = Integer.parseInt(strArr[1].substring(4), 16);
            } else if (strArr.length >= 3) {
                int i3 = Integer.parseInt(strArr[1]);
                i = Integer.parseInt(strArr[2]);
                i2 = i3;
            } else {
                Log.w(TAG, "Ignoring malformed AVC codec string: " + str);
                return null;
            }
            int iAvcProfileNumberToConst = avcProfileNumberToConst(i2);
            if (iAvcProfileNumberToConst == -1) {
                Log.w(TAG, "Unknown AVC profile: " + i2);
                return null;
            }
            int iAvcLevelNumberToConst = avcLevelNumberToConst(i);
            if (iAvcLevelNumberToConst == -1) {
                Log.w(TAG, "Unknown AVC level: " + i);
                return null;
            }
            return new Pair<>(Integer.valueOf(iAvcProfileNumberToConst), Integer.valueOf(iAvcLevelNumberToConst));
        } catch (NumberFormatException unused) {
            Log.w(TAG, "Ignoring malformed AVC codec string: " + str);
            return null;
        }
    }

    private static Pair<Integer, Integer> getVp9ProfileAndLevel(String str, String[] strArr) {
        if (strArr.length < 3) {
            Log.w(TAG, "Ignoring malformed VP9 codec string: " + str);
            return null;
        }
        try {
            int i = Integer.parseInt(strArr[1]);
            int i2 = Integer.parseInt(strArr[2]);
            int iVp9ProfileNumberToConst = vp9ProfileNumberToConst(i);
            if (iVp9ProfileNumberToConst == -1) {
                Log.w(TAG, "Unknown VP9 profile: " + i);
                return null;
            }
            int iVp9LevelNumberToConst = vp9LevelNumberToConst(i2);
            if (iVp9LevelNumberToConst == -1) {
                Log.w(TAG, "Unknown VP9 level: " + i2);
                return null;
            }
            return new Pair<>(Integer.valueOf(iVp9ProfileNumberToConst), Integer.valueOf(iVp9LevelNumberToConst));
        } catch (NumberFormatException unused) {
            Log.w(TAG, "Ignoring malformed VP9 codec string: " + str);
            return null;
        }
    }

    private static Pair<Integer, Integer> getAv1ProfileAndLevel(String str, String[] strArr, ColorInfo colorInfo) {
        if (strArr.length < 4) {
            Log.w(TAG, "Ignoring malformed AV1 codec string: " + str);
            return null;
        }
        int i = 1;
        try {
            int i2 = Integer.parseInt(strArr[1]);
            int i3 = Integer.parseInt(strArr[2].substring(0, 2));
            int i4 = Integer.parseInt(strArr[3]);
            if (i2 != 0) {
                Log.w(TAG, "Unknown AV1 profile: " + i2);
                return null;
            }
            if (i4 != 8 && i4 != 10) {
                Log.w(TAG, "Unknown AV1 bit depth: " + i4);
                return null;
            }
            if (i4 != 8) {
                i = (colorInfo == null || !(colorInfo.hdrStaticInfo != null || colorInfo.colorTransfer == 7 || colorInfo.colorTransfer == 6)) ? 2 : 4096;
            }
            int iAv1LevelNumberToConst = av1LevelNumberToConst(i3);
            if (iAv1LevelNumberToConst == -1) {
                Log.w(TAG, "Unknown AV1 level: " + i3);
                return null;
            }
            return new Pair<>(Integer.valueOf(i), Integer.valueOf(iAv1LevelNumberToConst));
        } catch (NumberFormatException unused) {
            Log.w(TAG, "Ignoring malformed AV1 codec string: " + str);
            return null;
        }
    }

    private static Pair<Integer, Integer> getApvProfileAndLevel(String str, String[] strArr) {
        int i;
        if (strArr.length < 4) {
            Log.w(TAG, "Ignoring malformed APV codec string: " + str);
            return null;
        }
        try {
            int i2 = Integer.parseInt(strArr[1].substring(4));
            int i3 = Integer.parseInt(strArr[2].substring(4));
            int i4 = Integer.parseInt(strArr[3].substring(4));
            if (i2 == 33) {
                i = 1;
            } else {
                if (i2 != 44) {
                    Log.w(TAG, "Ignoring invalid APV profile: " + i2);
                    return null;
                }
                i = 8192;
            }
            int i5 = (i3 / 30) * 2;
            if (i3 % 30 == 0) {
                i5--;
            }
            return new Pair<>(Integer.valueOf(i), Integer.valueOf((1 << i4) | (256 << (i5 - 1))));
        } catch (NumberFormatException e) {
            Log.w(TAG, "Ignoring malformed APV codec string: " + str, e);
            return null;
        }
    }

    private static Pair<Integer, Integer> getAacCodecProfileAndLevel(String str, String[] strArr) {
        int iMp4aAudioObjectTypeToProfile;
        if (strArr.length != 3) {
            Log.w(TAG, "Ignoring malformed MP4A codec string: " + str);
            return null;
        }
        try {
            if (MimeTypes.AUDIO_AAC.equals(MimeTypes.getMimeTypeFromMp4ObjectType(Integer.parseInt(strArr[1], 16))) && (iMp4aAudioObjectTypeToProfile = mp4aAudioObjectTypeToProfile(Integer.parseInt(strArr[2]))) != -1) {
                return new Pair<>(Integer.valueOf(iMp4aAudioObjectTypeToProfile), 0);
            }
        } catch (NumberFormatException unused) {
            Log.w(TAG, "Ignoring malformed MP4A codec string: " + str);
        }
        return null;
    }

    private static Pair<Integer, Integer> getAc4CodecProfileAndLevel(String str, String[] strArr) {
        if (strArr.length != 4) {
            Log.w(TAG, "Ignoring malformed AC-4 codec string: " + str);
            return null;
        }
        try {
            int i = Integer.parseInt(strArr[1]);
            int i2 = Integer.parseInt(strArr[2]);
            int i3 = Integer.parseInt(strArr[3]);
            int iAc4BitstreamAndPresentationVersionsToProfileConst = ac4BitstreamAndPresentationVersionsToProfileConst(i, i2);
            if (iAc4BitstreamAndPresentationVersionsToProfileConst == -1) {
                Log.w(TAG, "Unknown AC-4 profile: " + i + "." + i2);
                return null;
            }
            int iAc4LevelNumberToConst = ac4LevelNumberToConst(i3);
            if (iAc4LevelNumberToConst == -1) {
                Log.w(TAG, "Unknown AC-4 level: " + i3);
                return null;
            }
            return new Pair<>(Integer.valueOf(iAc4BitstreamAndPresentationVersionsToProfileConst), Integer.valueOf(iAc4LevelNumberToConst));
        } catch (NumberFormatException unused) {
            Log.w(TAG, "Ignoring malformed AC-4 codec string: " + str);
            return null;
        }
    }

    private static Pair<Integer, Integer> getIamfCodecProfileAndLevel(String str, String[] strArr) {
        int i = 4;
        if (strArr.length < 4) {
            Log.w(TAG, "Ignoring malformed IAMF codec string: " + str);
            return null;
        }
        try {
            int i2 = 1 << (Integer.parseInt(strArr[1]) + 16);
            String str2 = strArr[3];
            str2.hashCode();
            switch (str2) {
                case "Opus":
                    i = 1;
                    break;
                case "fLaC":
                    break;
                case "ipcm":
                    i = 8;
                    break;
                case "mp4a":
                    i = 2;
                    break;
                default:
                    Log.w(TAG, "Ignoring unknown codec identifier for IAMF auxiliary profile: " + strArr[3]);
                    return null;
            }
            return new Pair<>(Integer.valueOf(16777216 | i2 | i), 0);
        } catch (NumberFormatException e) {
            Log.w(TAG, "Ignoring malformed primary profile in IAMF codec string: " + strArr[1], e);
            return null;
        }
    }

    /* JADX WARN: Failed to restore switch over string. Please report as a decompilation issue */
    private static Integer hevcCodecStringToProfileLevel(String str) {
        if (str == null) {
            return null;
        }
        str.hashCode();
        byte b = -1;
        switch (str.hashCode()) {
            case 70821:
                if (str.equals("H30")) {
                    b = 0;
                }
                break;
            case 70914:
                if (str.equals("H60")) {
                    b = 1;
                }
                break;
            case 70917:
                if (str.equals("H63")) {
                    b = 2;
                }
                break;
            case 71007:
                if (str.equals("H90")) {
                    b = 3;
                }
                break;
            case 71010:
                if (str.equals("H93")) {
                    b = 4;
                }
                break;
            case 74665:
                if (str.equals("L30")) {
                    b = 5;
                }
                break;
            case 74758:
                if (str.equals("L60")) {
                    b = 6;
                }
                break;
            case 74761:
                if (str.equals("L63")) {
                    b = 7;
                }
                break;
            case 74851:
                if (str.equals("L90")) {
                    b = 8;
                }
                break;
            case 74854:
                if (str.equals("L93")) {
                    b = 9;
                }
                break;
            case 2193639:
                if (str.equals("H120")) {
                    b = 10;
                }
                break;
            case 2193642:
                if (str.equals("H123")) {
                    b = Ascii.VT;
                }
                break;
            case 2193732:
                if (str.equals("H150")) {
                    b = Ascii.FF;
                }
                break;
            case 2193735:
                if (str.equals("H153")) {
                    b = Ascii.CR;
                }
                break;
            case 2193738:
                if (str.equals("H156")) {
                    b = Ascii.SO;
                }
                break;
            case 2193825:
                if (str.equals("H180")) {
                    b = Ascii.SI;
                }
                break;
            case 2193828:
                if (str.equals("H183")) {
                    b = 16;
                }
                break;
            case 2193831:
                if (str.equals("H186")) {
                    b = 17;
                }
                break;
            case 2312803:
                if (str.equals("L120")) {
                    b = Ascii.DC2;
                }
                break;
            case 2312806:
                if (str.equals("L123")) {
                    b = 19;
                }
                break;
            case 2312896:
                if (str.equals("L150")) {
                    b = Ascii.DC4;
                }
                break;
            case 2312899:
                if (str.equals("L153")) {
                    b = Ascii.NAK;
                }
                break;
            case 2312902:
                if (str.equals("L156")) {
                    b = Ascii.SYN;
                }
                break;
            case 2312989:
                if (str.equals("L180")) {
                    b = Ascii.ETB;
                }
                break;
            case 2312992:
                if (str.equals("L183")) {
                    b = Ascii.CAN;
                }
                break;
            case 2312995:
                if (str.equals("L186")) {
                    b = Ascii.EM;
                }
                break;
        }
        switch (b) {
        }
        return null;
    }

    private static Integer dolbyVisionStringToProfile(String str) {
        if (str == null) {
            return null;
        }
        str.hashCode();
        switch (str) {
        }
        return null;
    }

    /* JADX WARN: Failed to restore switch over string. Please report as a decompilation issue */
    private static Integer dolbyVisionStringToLevel(String str) {
        if (str == null) {
            return null;
        }
        str.hashCode();
        byte b = -1;
        switch (str.hashCode()) {
            case 1537:
                if (str.equals("01")) {
                    b = 0;
                }
                break;
            case 1538:
                if (str.equals("02")) {
                    b = 1;
                }
                break;
            case 1539:
                if (str.equals("03")) {
                    b = 2;
                }
                break;
            case 1540:
                if (str.equals("04")) {
                    b = 3;
                }
                break;
            case 1541:
                if (str.equals("05")) {
                    b = 4;
                }
                break;
            case 1542:
                if (str.equals("06")) {
                    b = 5;
                }
                break;
            case 1543:
                if (str.equals("07")) {
                    b = 6;
                }
                break;
            case 1544:
                if (str.equals("08")) {
                    b = 7;
                }
                break;
            case 1545:
                if (str.equals("09")) {
                    b = 8;
                }
                break;
            case 1567:
                if (str.equals("10")) {
                    b = 9;
                }
                break;
            case 1568:
                if (str.equals("11")) {
                    b = 10;
                }
                break;
            case 1569:
                if (str.equals("12")) {
                    b = Ascii.VT;
                }
                break;
            case 1570:
                if (str.equals("13")) {
                    b = Ascii.FF;
                }
                break;
        }
        switch (b) {
        }
        return null;
    }

    private CodecSpecificDataUtil() {
    }
}
