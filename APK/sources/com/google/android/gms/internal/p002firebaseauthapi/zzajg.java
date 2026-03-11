package com.google.android.gms.internal.p002firebaseauthapi;

import android.text.TextUtils;
import com.google.android.gms.common.internal.Preconditions;
import com.tekartik.sqflite.Constant;
import io.flutter.plugins.firebase.auth.Constants;
import org.json.JSONException;
import org.json.JSONObject;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzajg implements zzafa {
    private String zza;
    private String zzb;
    private String zzc;
    private String zzd;
    private String zze;
    private boolean zzf;

    public static zzajg zza(String str, String str2, boolean z) {
        zzajg zzajgVar = new zzajg();
        zzajgVar.zzb = Preconditions.checkNotEmpty(str);
        zzajgVar.zzc = Preconditions.checkNotEmpty(str2);
        zzajgVar.zzf = z;
        return zzajgVar;
    }

    public static zzajg zzb(String str, String str2, boolean z) {
        zzajg zzajgVar = new zzajg();
        zzajgVar.zza = Preconditions.checkNotEmpty(str);
        zzajgVar.zzd = Preconditions.checkNotEmpty(str2);
        zzajgVar.zzf = z;
        return zzajgVar;
    }

    @Override // com.google.android.gms.internal.p002firebaseauthapi.zzafa
    public final String zza() throws JSONException {
        JSONObject jSONObject = new JSONObject();
        if (!TextUtils.isEmpty(this.zzd)) {
            jSONObject.put("phoneNumber", this.zza);
            jSONObject.put("temporaryProof", this.zzd);
        } else {
            jSONObject.put("sessionInfo", this.zzb);
            jSONObject.put(Constant.PARAM_ERROR_CODE, this.zzc);
        }
        String str = this.zze;
        if (str != null) {
            jSONObject.put(Constants.ID_TOKEN, str);
        }
        if (!this.zzf) {
            jSONObject.put("operation", 2);
        }
        return jSONObject.toString();
    }

    private zzajg() {
    }

    public final void zza(String str) {
        this.zze = str;
    }
}
