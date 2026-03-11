package com.google.firebase.auth.internal;

import android.app.Application;
import com.google.android.gms.tasks.Task;
import com.google.android.recaptcha.Recaptcha;
import com.google.android.recaptcha.RecaptchaTasksClient;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
final class zzbv implements zzbs {
    @Override // com.google.firebase.auth.internal.zzbs
    public final Task<RecaptchaTasksClient> zza(Application application, String str) {
        return Recaptcha.fetchTaskClient(application, str);
    }

    zzbv() {
    }
}
