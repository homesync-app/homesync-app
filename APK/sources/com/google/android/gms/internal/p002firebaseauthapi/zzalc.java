package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public enum zzalc {
    DOUBLE(0, zzale.SCALAR, zzaln.DOUBLE),
    FLOAT(1, zzale.SCALAR, zzaln.FLOAT),
    INT64(2, zzale.SCALAR, zzaln.LONG),
    UINT64(3, zzale.SCALAR, zzaln.LONG),
    INT32(4, zzale.SCALAR, zzaln.INT),
    FIXED64(5, zzale.SCALAR, zzaln.LONG),
    FIXED32(6, zzale.SCALAR, zzaln.INT),
    BOOL(7, zzale.SCALAR, zzaln.BOOLEAN),
    STRING(8, zzale.SCALAR, zzaln.STRING),
    MESSAGE(9, zzale.SCALAR, zzaln.MESSAGE),
    BYTES(10, zzale.SCALAR, zzaln.BYTE_STRING),
    UINT32(11, zzale.SCALAR, zzaln.INT),
    ENUM(12, zzale.SCALAR, zzaln.ENUM),
    SFIXED32(13, zzale.SCALAR, zzaln.INT),
    SFIXED64(14, zzale.SCALAR, zzaln.LONG),
    SINT32(15, zzale.SCALAR, zzaln.INT),
    SINT64(16, zzale.SCALAR, zzaln.LONG),
    GROUP(17, zzale.SCALAR, zzaln.MESSAGE),
    DOUBLE_LIST(18, zzale.VECTOR, zzaln.DOUBLE),
    FLOAT_LIST(19, zzale.VECTOR, zzaln.FLOAT),
    INT64_LIST(20, zzale.VECTOR, zzaln.LONG),
    UINT64_LIST(21, zzale.VECTOR, zzaln.LONG),
    INT32_LIST(22, zzale.VECTOR, zzaln.INT),
    FIXED64_LIST(23, zzale.VECTOR, zzaln.LONG),
    FIXED32_LIST(24, zzale.VECTOR, zzaln.INT),
    BOOL_LIST(25, zzale.VECTOR, zzaln.BOOLEAN),
    STRING_LIST(26, zzale.VECTOR, zzaln.STRING),
    MESSAGE_LIST(27, zzale.VECTOR, zzaln.MESSAGE),
    BYTES_LIST(28, zzale.VECTOR, zzaln.BYTE_STRING),
    UINT32_LIST(29, zzale.VECTOR, zzaln.INT),
    ENUM_LIST(30, zzale.VECTOR, zzaln.ENUM),
    SFIXED32_LIST(31, zzale.VECTOR, zzaln.INT),
    SFIXED64_LIST(32, zzale.VECTOR, zzaln.LONG),
    SINT32_LIST(33, zzale.VECTOR, zzaln.INT),
    SINT64_LIST(34, zzale.VECTOR, zzaln.LONG),
    DOUBLE_LIST_PACKED(35, zzale.PACKED_VECTOR, zzaln.DOUBLE),
    FLOAT_LIST_PACKED(36, zzale.PACKED_VECTOR, zzaln.FLOAT),
    INT64_LIST_PACKED(37, zzale.PACKED_VECTOR, zzaln.LONG),
    UINT64_LIST_PACKED(38, zzale.PACKED_VECTOR, zzaln.LONG),
    INT32_LIST_PACKED(39, zzale.PACKED_VECTOR, zzaln.INT),
    FIXED64_LIST_PACKED(40, zzale.PACKED_VECTOR, zzaln.LONG),
    FIXED32_LIST_PACKED(41, zzale.PACKED_VECTOR, zzaln.INT),
    BOOL_LIST_PACKED(42, zzale.PACKED_VECTOR, zzaln.BOOLEAN),
    UINT32_LIST_PACKED(43, zzale.PACKED_VECTOR, zzaln.INT),
    ENUM_LIST_PACKED(44, zzale.PACKED_VECTOR, zzaln.ENUM),
    SFIXED32_LIST_PACKED(45, zzale.PACKED_VECTOR, zzaln.INT),
    SFIXED64_LIST_PACKED(46, zzale.PACKED_VECTOR, zzaln.LONG),
    SINT32_LIST_PACKED(47, zzale.PACKED_VECTOR, zzaln.INT),
    SINT64_LIST_PACKED(48, zzale.PACKED_VECTOR, zzaln.LONG),
    GROUP_LIST(49, zzale.VECTOR, zzaln.MESSAGE),
    MAP(50, zzale.MAP, zzaln.VOID);

    private static final zzalc[] zzaz;
    private final int zzbb;

    public final int zza() {
        return this.zzbb;
    }

    static {
        zzalc[] zzalcVarArrValues = values();
        zzaz = new zzalc[zzalcVarArrValues.length];
        for (zzalc zzalcVar : zzalcVarArrValues) {
            zzaz[zzalcVar.zzbb] = zzalcVar;
        }
    }

    zzalc(int i, zzale zzaleVar, zzaln zzalnVar) {
        this.zzbb = i;
        int iOrdinal = zzaleVar.ordinal();
        if (iOrdinal == 1 || iOrdinal == 3) {
            zzalnVar.zza();
        }
        if (zzaleVar == zzale.SCALAR) {
            int i2 = zzalb.zza[zzalnVar.ordinal()];
        }
    }
}
