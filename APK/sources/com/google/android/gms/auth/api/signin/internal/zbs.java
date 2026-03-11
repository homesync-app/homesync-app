package com.google.android.gms.auth.api.signin.internal;

import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcel;
import android.os.RemoteException;
import androidx.core.location.LocationRequestCompat;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;

/* JADX INFO: compiled from: com.google.android.gms:play-services-auth@@21.4.0 */
/* JADX INFO: loaded from: classes3.dex */
public final class zbs extends com.google.android.gms.internal.p000authapi.zba implements IInterface {
    zbs(IBinder iBinder) {
        super(iBinder, "com.google.android.gms.auth.api.signin.internal.ISignInService");
    }

    public final void zbc(zbr zbrVar, GoogleSignInOptions googleSignInOptions) throws RemoteException {
        Parcel parcelZba = zba();
        com.google.android.gms.internal.p000authapi.zbc.zbc(parcelZba, zbrVar);
        com.google.android.gms.internal.p000authapi.zbc.zbb(parcelZba, googleSignInOptions);
        zbb(101, parcelZba);
    }

    public final void zbd(zbr zbrVar, GoogleSignInOptions googleSignInOptions) throws RemoteException {
        Parcel parcelZba = zba();
        com.google.android.gms.internal.p000authapi.zbc.zbc(parcelZba, zbrVar);
        com.google.android.gms.internal.p000authapi.zbc.zbb(parcelZba, googleSignInOptions);
        zbb(LocationRequestCompat.QUALITY_BALANCED_POWER_ACCURACY, parcelZba);
    }

    public final void zbe(zbr zbrVar, GoogleSignInOptions googleSignInOptions) throws RemoteException {
        Parcel parcelZba = zba();
        com.google.android.gms.internal.p000authapi.zbc.zbc(parcelZba, zbrVar);
        com.google.android.gms.internal.p000authapi.zbc.zbb(parcelZba, googleSignInOptions);
        zbb(103, parcelZba);
    }
}
