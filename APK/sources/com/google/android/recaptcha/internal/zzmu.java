package com.google.android.recaptcha.internal;

/* JADX INFO: compiled from: com.google.android.recaptcha:recaptcha@@18.6.1 */
/* JADX INFO: loaded from: classes3.dex */
public enum zzmu {
    DOUBLE(0, 1, zzno.DOUBLE),
    FLOAT(1, 1, zzno.FLOAT),
    INT64(2, 1, zzno.LONG),
    UINT64(3, 1, zzno.LONG),
    INT32(4, 1, zzno.INT),
    FIXED64(5, 1, zzno.LONG),
    FIXED32(6, 1, zzno.INT),
    BOOL(7, 1, zzno.BOOLEAN),
    STRING(8, 1, zzno.STRING),
    MESSAGE(9, 1, zzno.MESSAGE),
    BYTES(10, 1, zzno.BYTE_STRING),
    UINT32(11, 1, zzno.INT),
    ENUM(12, 1, zzno.ENUM),
    SFIXED32(13, 1, zzno.INT),
    SFIXED64(14, 1, zzno.LONG),
    SINT32(15, 1, zzno.INT),
    SINT64(16, 1, zzno.LONG),
    GROUP(17, 1, zzno.MESSAGE),
    DOUBLE_LIST(18, 2, zzno.DOUBLE),
    FLOAT_LIST(19, 2, zzno.FLOAT),
    INT64_LIST(20, 2, zzno.LONG),
    UINT64_LIST(21, 2, zzno.LONG),
    INT32_LIST(22, 2, zzno.INT),
    FIXED64_LIST(23, 2, zzno.LONG),
    FIXED32_LIST(24, 2, zzno.INT),
    BOOL_LIST(25, 2, zzno.BOOLEAN),
    STRING_LIST(26, 2, zzno.STRING),
    MESSAGE_LIST(27, 2, zzno.MESSAGE),
    BYTES_LIST(28, 2, zzno.BYTE_STRING),
    UINT32_LIST(29, 2, zzno.INT),
    ENUM_LIST(30, 2, zzno.ENUM),
    SFIXED32_LIST(31, 2, zzno.INT),
    SFIXED64_LIST(32, 2, zzno.LONG),
    SINT32_LIST(33, 2, zzno.INT),
    SINT64_LIST(34, 2, zzno.LONG),
    DOUBLE_LIST_PACKED(35, 3, zzno.DOUBLE),
    FLOAT_LIST_PACKED(36, 3, zzno.FLOAT),
    INT64_LIST_PACKED(37, 3, zzno.LONG),
    UINT64_LIST_PACKED(38, 3, zzno.LONG),
    INT32_LIST_PACKED(39, 3, zzno.INT),
    FIXED64_LIST_PACKED(40, 3, zzno.LONG),
    FIXED32_LIST_PACKED(41, 3, zzno.INT),
    BOOL_LIST_PACKED(42, 3, zzno.BOOLEAN),
    UINT32_LIST_PACKED(43, 3, zzno.INT),
    ENUM_LIST_PACKED(44, 3, zzno.ENUM),
    SFIXED32_LIST_PACKED(45, 3, zzno.INT),
    SFIXED64_LIST_PACKED(46, 3, zzno.LONG),
    SINT32_LIST_PACKED(47, 3, zzno.INT),
    SINT64_LIST_PACKED(48, 3, zzno.LONG),
    GROUP_LIST(49, 2, zzno.MESSAGE),
    MAP(50, 4, zzno.VOID);

    private static final zzmu[] zzZ;
    private final int zzab;

    static {
        zzmu[] zzmuVarArrValues = values();
        zzZ = new zzmu[zzmuVarArrValues.length];
        for (zzmu zzmuVar : zzmuVarArrValues) {
            zzZ[zzmuVar.zzab] = zzmuVar;
        }
    }

    zzmu(int i, int i2, zzno zznoVar) {
        this.zzab = i;
        int i3 = i2 - 1;
        if (i3 == 1 || i3 == 3) {
            zznoVar.zza();
        }
        if (i2 == 1) {
            zzno zznoVar2 = zzno.VOID;
            zznoVar.ordinal();
        }
    }

    public final int zza() {
        return this.zzab;
    }
}
