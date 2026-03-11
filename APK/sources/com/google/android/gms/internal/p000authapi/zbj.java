package com.google.android.gms.internal.p000authapi;

import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcel;
import android.os.RemoteException;
import com.google.android.gms.auth.api.identity.AuthorizationRequest;
import com.google.android.gms.auth.api.identity.ClearTokenRequest;
import com.google.android.gms.auth.api.identity.RevokeAccessRequest;
import com.google.android.gms.common.api.ApiMetadata;
import com.google.android.gms.common.api.internal.IStatusCallback;

/* JADX INFO: compiled from: com.google.android.gms:play-services-auth@@21.4.0 */
/* JADX INFO: loaded from: classes3.dex */
public final class zbj extends zba implements IInterface {
    zbj(IBinder iBinder) {
        super(iBinder, "com.google.android.gms.auth.api.identity.internal.IAuthorizationService");
    }

    public final void zbc(zbi zbiVar, AuthorizationRequest authorizationRequest, ApiMetadata apiMetadata) throws RemoteException {
        Parcel parcelZba = zba();
        zbc.zbc(parcelZba, zbiVar);
        zbc.zbb(parcelZba, authorizationRequest);
        zbc.zbb(parcelZba, apiMetadata);
        zbb(1, parcelZba);
    }

    public final void zbd(IStatusCallback iStatusCallback, RevokeAccessRequest revokeAccessRequest, ApiMetadata apiMetadata) throws RemoteException {
        Parcel parcelZba = zba();
        zbc.zbc(parcelZba, iStatusCallback);
        zbc.zbb(parcelZba, revokeAccessRequest);
        zbc.zbb(parcelZba, apiMetadata);
        zbb(3, parcelZba);
    }

    public final void zbe(IStatusCallback iStatusCallback, ClearTokenRequest clearTokenRequest, ApiMetadata apiMetadata) throws RemoteException {
        Parcel parcelZba = zba();
        zbc.zbc(parcelZba, iStatusCallback);
        zbc.zbb(parcelZba, clearTokenRequest);
        zbc.zbb(parcelZba, apiMetadata);
        zbb(4, parcelZba);
    }
}
