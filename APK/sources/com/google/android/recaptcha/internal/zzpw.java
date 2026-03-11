package com.google.android.recaptcha.internal;

/* JADX INFO: compiled from: com.google.android.recaptcha:recaptcha@@18.6.1 */
/* JADX INFO: loaded from: classes3.dex */
public enum zzpw {
    DOUBLE(zzpx.DOUBLE, 1),
    FLOAT(zzpx.FLOAT, 5),
    INT64(zzpx.LONG, 0),
    UINT64(zzpx.LONG, 0),
    INT32(zzpx.INT, 0),
    FIXED64(zzpx.LONG, 1),
    FIXED32(zzpx.INT, 5),
    BOOL(zzpx.BOOLEAN, 0),
    STRING(zzpx.STRING, 2),
    GROUP(zzpx.MESSAGE, 3),
    MESSAGE(zzpx.MESSAGE, 2),
    BYTES(zzpx.BYTE_STRING, 2),
    UINT32(zzpx.INT, 0),
    ENUM(zzpx.ENUM, 0),
    SFIXED32(zzpx.INT, 5),
    SFIXED64(zzpx.LONG, 1),
    SINT32(zzpx.INT, 0),
    SINT64(zzpx.LONG, 0);

    private final zzpx zzt;

    zzpw(zzpx zzpxVar, int i) {
        this.zzt = zzpxVar;
    }

    public final zzpx zza() {
        return this.zzt;
    }
}
