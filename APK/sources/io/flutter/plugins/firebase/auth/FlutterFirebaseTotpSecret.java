package io.flutter.plugins.firebase.auth;

import com.google.firebase.auth.TotpSecret;
import io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth;

/* JADX INFO: loaded from: classes3.dex */
public class FlutterFirebaseTotpSecret implements GeneratedAndroidFirebaseAuth.MultiFactorTotpSecretHostApi {
    static final /* synthetic */ boolean $assertionsDisabled = false;

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.MultiFactorTotpSecretHostApi
    public void generateQrCodeUrl(String str, String str2, String str3, GeneratedAndroidFirebaseAuth.Result<String> result) {
        TotpSecret totpSecret = FlutterFirebaseTotpMultiFactor.multiFactorSecret.get(str);
        if (str2 == null || str3 == null) {
            result.success(totpSecret.generateQrCodeUrl());
        } else {
            result.success(totpSecret.generateQrCodeUrl(str2, str3));
        }
    }

    @Override // io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.MultiFactorTotpSecretHostApi
    public void openInOtpApp(String str, String str2, GeneratedAndroidFirebaseAuth.VoidResult voidResult) {
        FlutterFirebaseTotpMultiFactor.multiFactorSecret.get(str).openInOtpApp(str2);
        voidResult.success();
    }
}
