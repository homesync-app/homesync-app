package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import javax.annotation.Nullable;

/* JADX INFO: Add missing generic type declarations: [KeyT, SerializationT] */
/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zznw<KeyT, SerializationT> extends zznx<KeyT, SerializationT> {
    private final /* synthetic */ zznz zza;

    /* JADX WARN: Incorrect return type in method signature: (TKeyT;Lcom/google/android/gms/internal/firebase-auth-api/zzch;)TSerializationT; */
    @Override // com.google.android.gms.internal.p002firebaseauthapi.zznx
    public final zzqf zza(zzbi zzbiVar, @Nullable zzch zzchVar) throws GeneralSecurityException {
        return this.zza.zza(zzbiVar, zzchVar);
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    zznw(Class cls, Class cls2, zznz zznzVar) {
        super(cls, cls2);
        this.zza = zznzVar;
    }
}
