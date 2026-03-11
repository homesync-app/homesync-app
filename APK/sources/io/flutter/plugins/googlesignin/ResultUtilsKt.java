package io.flutter.plugins.googlesignin;

import androidx.exifinterface.media.ExifInterface;
import androidx.media3.container.NalUnitUtil;
import kotlin.Metadata;
import kotlin.Result;
import kotlin.ResultKt;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: ResultUtils.kt */
/* JADX INFO: loaded from: classes3.dex */
@Metadata(d1 = {"\u0000\u001c\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\b\u0005\u001a \u0010\u0000\u001a\u00020\u00012\u0018\u0010\u0002\u001a\u0014\u0012\n\u0012\b\u0012\u0004\u0012\u00020\u00010\u0004\u0012\u0004\u0012\u00020\u00010\u0003\u001a(\u0010\u0005\u001a\u00020\u00012\u0018\u0010\u0002\u001a\u0014\u0012\n\u0012\b\u0012\u0004\u0012\u00020\u00010\u0004\u0012\u0004\u0012\u00020\u00010\u00032\u0006\u0010\u0006\u001a\u00020\u0007\u001a3\u0010\b\u001a\u00020\u0001\"\u0004\b\u0000\u0010\t2\u0018\u0010\u0002\u001a\u0014\u0012\n\u0012\b\u0012\u0004\u0012\u0002H\t0\u0004\u0012\u0004\u0012\u00020\u00010\u00032\u0006\u0010\n\u001a\u0002H\t¢\u0006\u0002\u0010\u000b¨\u0006\f"}, d2 = {"completeWithUnitSuccess", "", "callback", "Lkotlin/Function1;", "Lkotlin/Result;", "completeWithUnitError", "failure", "Lio/flutter/plugins/googlesignin/FlutterError;", "completeWithValue", ExifInterface.GPS_DIRECTION_TRUE, "value", "(Lkotlin/jvm/functions/Function1;Ljava/lang/Object;)V", "google_sign_in_android_release"}, k = 2, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final class ResultUtilsKt {
    public static final void completeWithUnitSuccess(Function1<? super Result<Unit>, Unit> callback) {
        Intrinsics.checkNotNullParameter(callback, "callback");
        Result.Companion companion = Result.INSTANCE;
        callback.invoke(Result.m599boximpl(Result.m600constructorimpl(Unit.INSTANCE)));
    }

    public static final void completeWithUnitError(Function1<? super Result<Unit>, Unit> callback, FlutterError failure) {
        Intrinsics.checkNotNullParameter(callback, "callback");
        Intrinsics.checkNotNullParameter(failure, "failure");
        Result.Companion companion = Result.INSTANCE;
        callback.invoke(Result.m599boximpl(Result.m600constructorimpl(ResultKt.createFailure(failure))));
    }

    public static final <T> void completeWithValue(Function1<? super Result<? extends T>, Unit> callback, T t) {
        Intrinsics.checkNotNullParameter(callback, "callback");
        Result.Companion companion = Result.INSTANCE;
        callback.invoke(Result.m599boximpl(Result.m600constructorimpl(t)));
    }
}
