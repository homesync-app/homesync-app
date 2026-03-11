package com.google.android.gms.internal.p002firebaseauthapi;

import java.security.GeneralSecurityException;
import java.util.concurrent.atomic.AtomicReference;
import javax.annotation.Nullable;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzoz {
    private static final zzoz zza = (zzoz) zzql.zza(new zzqo() { // from class: com.google.android.gms.internal.firebase-auth-api.zzpc
        @Override // com.google.android.gms.internal.p002firebaseauthapi.zzqo
        public final Object zza() throws GeneralSecurityException {
            zzoz zzozVar = new zzoz();
            zzozVar.zza(zznx.zza(new zznz() { // from class: com.google.android.gms.internal.firebase-auth-api.zzpb
                @Override // com.google.android.gms.internal.p002firebaseauthapi.zznz
                public final zzqf zza(zzbi zzbiVar, zzch zzchVar) {
                    return ((zzof) zzbiVar).zza(zzchVar);
                }
            }, zzof.class, zzqb.class));
            return zzozVar;
        }
    });
    private final AtomicReference<zzqi> zzb = new AtomicReference<>(new zzqh().zza());

    public final <SerializationT extends zzqf> zzbi zza(SerializationT serializationt, @Nullable zzch zzchVar) throws GeneralSecurityException {
        return this.zzb.get().zza(serializationt, zzchVar);
    }

    public final <SerializationT extends zzqf> zzcb zza(SerializationT serializationt) throws GeneralSecurityException {
        return this.zzb.get().zza(serializationt);
    }

    public static zzoz zza() {
        return zza;
    }

    public final <KeyT extends zzbi, SerializationT extends zzqf> SerializationT zza(KeyT keyt, Class<SerializationT> cls, @Nullable zzch zzchVar) throws GeneralSecurityException {
        return (SerializationT) this.zzb.get().zza(keyt, cls, zzchVar);
    }

    public final <ParametersT extends zzcb, SerializationT extends zzqf> SerializationT zza(ParametersT parameterst, Class<SerializationT> cls) throws GeneralSecurityException {
        return (SerializationT) this.zzb.get().zza(parameterst, cls);
    }

    public final synchronized <SerializationT extends zzqf> void zza(zznt<SerializationT> zzntVar) throws GeneralSecurityException {
        this.zzb.set(new zzqh(this.zzb.get()).zza(zzntVar).zza());
    }

    public final synchronized <KeyT extends zzbi, SerializationT extends zzqf> void zza(zznx<KeyT, SerializationT> zznxVar) throws GeneralSecurityException {
        this.zzb.set(new zzqh(this.zzb.get()).zza(zznxVar).zza());
    }

    public final synchronized <SerializationT extends zzqf> void zza(zzpd<SerializationT> zzpdVar) throws GeneralSecurityException {
        this.zzb.set(new zzqh(this.zzb.get()).zza(zzpdVar).zza());
    }

    public final synchronized <ParametersT extends zzcb, SerializationT extends zzqf> void zza(zzph<ParametersT, SerializationT> zzphVar) throws GeneralSecurityException {
        this.zzb.set(new zzqh(this.zzb.get()).zza(zzphVar).zza());
    }

    public final <SerializationT extends zzqf> boolean zzb(SerializationT serializationt) {
        return this.zzb.get().zzb(serializationt);
    }

    public final <SerializationT extends zzqf> boolean zzc(SerializationT serializationt) {
        return this.zzb.get().zzc(serializationt);
    }
}
