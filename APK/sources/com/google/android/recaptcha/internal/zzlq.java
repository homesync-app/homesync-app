package com.google.android.recaptcha.internal;

import androidx.datastore.preferences.protobuf.DescriptorProtos;

/* JADX INFO: compiled from: com.google.android.recaptcha:recaptcha@@18.6.1 */
/* JADX INFO: loaded from: classes3.dex */
public enum zzlq implements zznf {
    EDITION_UNKNOWN(0),
    EDITION_LEGACY(DescriptorProtos.Edition.EDITION_LEGACY_VALUE),
    EDITION_PROTO2(DescriptorProtos.Edition.EDITION_PROTO2_VALUE),
    EDITION_PROTO3(999),
    EDITION_2023(1000),
    EDITION_2024(1001),
    EDITION_1_TEST_ONLY(1),
    EDITION_2_TEST_ONLY(2),
    EDITION_99997_TEST_ONLY(DescriptorProtos.Edition.EDITION_99997_TEST_ONLY_VALUE),
    EDITION_99998_TEST_ONLY(DescriptorProtos.Edition.EDITION_99998_TEST_ONLY_VALUE),
    EDITION_99999_TEST_ONLY(DescriptorProtos.Edition.EDITION_99999_TEST_ONLY_VALUE),
    EDITION_MAX(Integer.MAX_VALUE);

    private final int zzn;

    zzlq(int i) {
        this.zzn = i;
    }

    @Override // java.lang.Enum
    public final String toString() {
        return Integer.toString(this.zzn);
    }

    @Override // com.google.android.recaptcha.internal.zznf
    public final int zza() {
        return this.zzn;
    }
}
