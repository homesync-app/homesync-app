package dev.fluttercommunity.plus.share;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ResolveInfo;
import android.net.Uri;
import android.os.Parcelable;
import androidx.core.content.FileProvider;
import androidx.credentials.exceptions.publickeycredential.DomExceptionUtils;
import androidx.media3.container.NalUnitUtil;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.tekartik.sqflite.Constant;
import io.flutter.plugins.firebase.crashlytics.Constants;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import kotlin.Lazy;
import kotlin.LazyKt;
import kotlin.Metadata;
import kotlin.collections.CollectionsKt;
import kotlin.io.FilesKt;
import kotlin.jvm.functions.Function0;
import kotlin.jvm.internal.Intrinsics;
import kotlin.text.StringsKt;

/* JADX INFO: compiled from: Share.kt */
/* JADX INFO: loaded from: classes3.dex */
@Metadata(d1 = {"\u0000h\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0003\n\u0002\u0010\u000e\n\u0002\b\u0005\n\u0002\u0018\u0002\n\u0002\b\u0003\n\u0002\u0010\b\n\u0002\b\u0005\n\u0002\u0010\u0002\n\u0002\b\u0002\n\u0002\u0010$\n\u0000\n\u0002\u0010\u000b\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010 \n\u0002\b\t\b\u0000\u0018\u00002\u00020\u0001B!\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\b\u0010\u0004\u001a\u0004\u0018\u00010\u0005\u0012\u0006\u0010\u0006\u001a\u00020\u0007¢\u0006\u0004\b\b\u0010\tJ\b\u0010\u0019\u001a\u00020\u0003H\u0002J\u0010\u0010\u001a\u001a\u00020\u001b2\b\u0010\u0004\u001a\u0004\u0018\u00010\u0005J\"\u0010\u001c\u001a\u00020\u001b2\u0012\u0010\u001d\u001a\u000e\u0012\u0004\u0012\u00020\u000b\u0012\u0004\u0012\u00020\u00010\u001e2\u0006\u0010\u001f\u001a\u00020 J\u0018\u0010!\u001a\u00020\u001b2\u0006\u0010\"\u001a\u00020#2\u0006\u0010\u001f\u001a\u00020 H\u0002J&\u0010$\u001a\u0012\u0012\u0004\u0012\u00020&0%j\b\u0012\u0004\u0012\u00020&`'2\f\u0010(\u001a\b\u0012\u0004\u0012\u00020\u000b0)H\u0002J\u0018\u0010*\u001a\u00020\u000b2\u000e\u0010+\u001a\n\u0012\u0004\u0012\u00020\u000b\u0018\u00010)H\u0002J\u0012\u0010,\u001a\u00020\u000b2\b\u0010-\u001a\u0004\u0018\u00010\u000bH\u0002J\u0010\u0010.\u001a\u00020 2\u0006\u0010/\u001a\u00020\u0011H\u0002J\b\u00100\u001a\u00020\u001bH\u0002J\u0010\u00101\u001a\u00020\u00112\u0006\u0010/\u001a\u00020\u0011H\u0002R\u000e\u0010\u0002\u001a\u00020\u0003X\u0082\u0004¢\u0006\u0002\n\u0000R\u0010\u0010\u0004\u001a\u0004\u0018\u00010\u0005X\u0082\u000e¢\u0006\u0002\n\u0000R\u000e\u0010\u0006\u001a\u00020\u0007X\u0082\u0004¢\u0006\u0002\n\u0000R\u001b\u0010\n\u001a\u00020\u000b8BX\u0082\u0084\u0002¢\u0006\f\n\u0004\b\u000e\u0010\u000f\u001a\u0004\b\f\u0010\rR\u0014\u0010\u0010\u001a\u00020\u00118BX\u0082\u0004¢\u0006\u0006\u001a\u0004\b\u0012\u0010\u0013R\u001b\u0010\u0014\u001a\u00020\u00158BX\u0082\u0084\u0002¢\u0006\f\n\u0004\b\u0018\u0010\u000f\u001a\u0004\b\u0016\u0010\u0017¨\u00062"}, d2 = {"Ldev/fluttercommunity/plus/share/Share;", "", "context", "Landroid/content/Context;", "activity", "Landroid/app/Activity;", "manager", "Ldev/fluttercommunity/plus/share/ShareSuccessManager;", "<init>", "(Landroid/content/Context;Landroid/app/Activity;Ldev/fluttercommunity/plus/share/ShareSuccessManager;)V", "providerAuthority", "", "getProviderAuthority", "()Ljava/lang/String;", "providerAuthority$delegate", "Lkotlin/Lazy;", "shareCacheFolder", "Ljava/io/File;", "getShareCacheFolder", "()Ljava/io/File;", "immutabilityIntentFlags", "", "getImmutabilityIntentFlags", "()I", "immutabilityIntentFlags$delegate", "getContext", "setActivity", "", FirebaseAnalytics.Event.SHARE, Constant.PARAM_SQL_ARGUMENTS, "", "withResult", "", "startActivity", "intent", "Landroid/content/Intent;", "getUrisForPaths", "Ljava/util/ArrayList;", "Landroid/net/Uri;", "Lkotlin/collections/ArrayList;", "paths", "", "reduceMimeTypes", "mimeTypes", "getMimeTypeBase", "mimeType", "fileIsInShareCache", Constants.FILE, "clearShareCacheFolder", "copyToShareCacheFolder", "share_plus_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final class Share {
    private Activity activity;
    private final Context context;

    /* JADX INFO: renamed from: immutabilityIntentFlags$delegate, reason: from kotlin metadata */
    private final Lazy immutabilityIntentFlags;
    private final ShareSuccessManager manager;

    /* JADX INFO: renamed from: providerAuthority$delegate, reason: from kotlin metadata */
    private final Lazy providerAuthority;

    /* JADX INFO: Access modifiers changed from: private */
    public static final int immutabilityIntentFlags_delegate$lambda$0() {
        return 33554432;
    }

    public Share(Context context, Activity activity, ShareSuccessManager manager) {
        Intrinsics.checkNotNullParameter(context, "context");
        Intrinsics.checkNotNullParameter(manager, "manager");
        this.context = context;
        this.activity = activity;
        this.manager = manager;
        this.providerAuthority = LazyKt.lazy(new Function0() { // from class: dev.fluttercommunity.plus.share.Share$$ExternalSyntheticLambda0
            @Override // kotlin.jvm.functions.Function0
            public final Object invoke() {
                return Share.providerAuthority_delegate$lambda$0(this.f$0);
            }
        });
        this.immutabilityIntentFlags = LazyKt.lazy(new Function0() { // from class: dev.fluttercommunity.plus.share.Share$$ExternalSyntheticLambda1
            @Override // kotlin.jvm.functions.Function0
            public final Object invoke() {
                return Integer.valueOf(Share.immutabilityIntentFlags_delegate$lambda$0());
            }
        });
    }

    private final String getProviderAuthority() {
        return (String) this.providerAuthority.getValue();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static final String providerAuthority_delegate$lambda$0(Share share) {
        return share.getContext().getPackageName() + ".flutter.share_provider";
    }

    private final File getShareCacheFolder() {
        return new File(getContext().getCacheDir(), "share_plus");
    }

    private final int getImmutabilityIntentFlags() {
        return ((Number) this.immutabilityIntentFlags.getValue()).intValue();
    }

    private final Context getContext() {
        Activity activity = this.activity;
        if (activity != null) {
            Intrinsics.checkNotNull(activity);
            return activity;
        }
        return this.context;
    }

    public final void setActivity(Activity activity) {
        this.activity = activity;
    }

    public final void share(Map<String, ? extends Object> arguments, boolean withResult) throws IOException {
        ArrayList arrayList;
        ArrayList arrayList2;
        String str;
        Intent intentCreateChooser;
        Intrinsics.checkNotNullParameter(arguments, "arguments");
        clearShareCacheFolder();
        String str2 = (String) arguments.get("text");
        String str3 = (String) arguments.get("uri");
        String str4 = (String) arguments.get("subject");
        String str5 = (String) arguments.get("title");
        List list = (List) arguments.get("paths");
        if (list != null) {
            ArrayList arrayList3 = new ArrayList();
            for (Object obj : list) {
                if (obj instanceof String) {
                    arrayList3.add(obj);
                }
            }
            arrayList = arrayList3;
        } else {
            arrayList = null;
        }
        List list2 = (List) arguments.get("mimeTypes");
        if (list2 != null) {
            ArrayList arrayList4 = new ArrayList();
            for (Object obj2 : list2) {
                if (obj2 instanceof String) {
                    arrayList4.add(obj2);
                }
            }
            arrayList2 = arrayList4;
        } else {
            arrayList2 = null;
        }
        ArrayList<Uri> urisForPaths = arrayList != null ? getUrisForPaths(arrayList) : null;
        Intent intent = new Intent();
        if (urisForPaths == null) {
            intent.setAction("android.intent.action.SEND");
            intent.setType("text/plain");
            if (str3 != null) {
                str2 = str3;
            }
            intent.putExtra("android.intent.extra.TEXT", str2);
            String str6 = str4;
            if (str6 != null && !StringsKt.isBlank(str6)) {
                intent.putExtra("android.intent.extra.SUBJECT", str4);
            }
            String str7 = str5;
            if (str7 != null && !StringsKt.isBlank(str7)) {
                intent.putExtra("android.intent.extra.TITLE", str5);
            }
        } else {
            if (urisForPaths.isEmpty()) {
                throw new IOException("Error sharing files: No files found");
            }
            if (urisForPaths.size() == 1) {
                ArrayList arrayList5 = arrayList2;
                if (arrayList5 != null && !arrayList5.isEmpty()) {
                    str = (String) CollectionsKt.first((List) arrayList2);
                } else {
                    str = "*/*";
                }
                intent.setAction("android.intent.action.SEND");
                intent.setType(str);
                intent.putExtra("android.intent.extra.STREAM", (Parcelable) CollectionsKt.first((List) urisForPaths));
            } else {
                intent.setAction("android.intent.action.SEND_MULTIPLE");
                intent.setType(reduceMimeTypes(arrayList2));
                intent.putParcelableArrayListExtra("android.intent.extra.STREAM", urisForPaths);
            }
            String str8 = str2;
            if (str8 != null && !StringsKt.isBlank(str8)) {
                intent.putExtra("android.intent.extra.TEXT", str2);
            }
            String str9 = str4;
            if (str9 != null && !StringsKt.isBlank(str9)) {
                intent.putExtra("android.intent.extra.SUBJECT", str4);
            }
            String str10 = str5;
            if (str10 != null && !StringsKt.isBlank(str10)) {
                intent.putExtra("android.intent.extra.TITLE", str5);
            }
            intent.addFlags(1);
        }
        if (withResult) {
            intentCreateChooser = Intent.createChooser(intent, str5, PendingIntent.getBroadcast(this.context, 0, new Intent(this.context, (Class<?>) SharePlusPendingIntent.class), 134217728 | getImmutabilityIntentFlags()).getIntentSender());
        } else {
            intentCreateChooser = Intent.createChooser(intent, str5);
        }
        if (urisForPaths != null) {
            List<ResolveInfo> listQueryIntentActivities = getContext().getPackageManager().queryIntentActivities(intentCreateChooser, 65536);
            Intrinsics.checkNotNullExpressionValue(listQueryIntentActivities, "queryIntentActivities(...)");
            Iterator<T> it = listQueryIntentActivities.iterator();
            while (it.hasNext()) {
                String str11 = ((ResolveInfo) it.next()).activityInfo.packageName;
                Iterator<T> it2 = urisForPaths.iterator();
                while (it2.hasNext()) {
                    getContext().grantUriPermission(str11, (Uri) it2.next(), 3);
                }
            }
        }
        Intrinsics.checkNotNull(intentCreateChooser);
        startActivity(intentCreateChooser, withResult);
    }

    private final void startActivity(Intent intent, boolean withResult) {
        Activity activity = this.activity;
        if (activity == null) {
            intent.addFlags(268435456);
            if (withResult) {
                this.manager.unavailable();
            }
            this.context.startActivity(intent);
            return;
        }
        if (withResult) {
            Intrinsics.checkNotNull(activity);
            activity.startActivityForResult(intent, ShareSuccessManager.ACTIVITY_CODE);
        } else {
            Intrinsics.checkNotNull(activity);
            activity.startActivity(intent);
        }
    }

    private final ArrayList<Uri> getUrisForPaths(List<String> paths) throws IOException {
        ArrayList<Uri> arrayList = new ArrayList<>(paths.size());
        Iterator<T> it = paths.iterator();
        while (it.hasNext()) {
            File file = new File((String) it.next());
            if (fileIsInShareCache(file)) {
                throw new IOException("Shared file can not be located in '" + getShareCacheFolder().getCanonicalPath() + "'");
            }
            arrayList.add(FileProvider.getUriForFile(getContext(), getProviderAuthority(), copyToShareCacheFolder(file)));
        }
        return arrayList;
    }

    private final String reduceMimeTypes(List<String> mimeTypes) {
        if (mimeTypes == null || mimeTypes.isEmpty()) {
            return "*/*";
        }
        int i = 1;
        if (mimeTypes.size() == 1) {
            return (String) CollectionsKt.first((List) mimeTypes);
        }
        String str = (String) CollectionsKt.first((List) mimeTypes);
        int lastIndex = CollectionsKt.getLastIndex(mimeTypes);
        if (1 <= lastIndex) {
            while (true) {
                if (!Intrinsics.areEqual(str, mimeTypes.get(i))) {
                    if (!Intrinsics.areEqual(getMimeTypeBase(str), getMimeTypeBase(mimeTypes.get(i)))) {
                        return "*/*";
                    }
                    str = getMimeTypeBase(mimeTypes.get(i)) + "/*";
                }
                if (i == lastIndex) {
                    break;
                }
                i++;
            }
        }
        return str;
    }

    private final String getMimeTypeBase(String mimeType) {
        if (mimeType != null) {
            String str = mimeType;
            if (!StringsKt.contains$default((CharSequence) str, (CharSequence) DomExceptionUtils.SEPARATOR, false, 2, (Object) null)) {
                return "*";
            }
            String strSubstring = mimeType.substring(0, StringsKt.indexOf$default((CharSequence) str, DomExceptionUtils.SEPARATOR, 0, false, 6, (Object) null));
            Intrinsics.checkNotNullExpressionValue(strSubstring, "substring(...)");
            return strSubstring;
        }
        return "*";
    }

    private final boolean fileIsInShareCache(File file) {
        try {
            String canonicalPath = file.getCanonicalPath();
            Intrinsics.checkNotNull(canonicalPath);
            String canonicalPath2 = getShareCacheFolder().getCanonicalPath();
            Intrinsics.checkNotNullExpressionValue(canonicalPath2, "getCanonicalPath(...)");
            return StringsKt.startsWith$default(canonicalPath, canonicalPath2, false, 2, (Object) null);
        } catch (IOException unused) {
            return false;
        }
    }

    private final void clearShareCacheFolder() {
        File shareCacheFolder = getShareCacheFolder();
        File[] fileArrListFiles = shareCacheFolder.listFiles();
        if (!shareCacheFolder.exists() || fileArrListFiles == null || fileArrListFiles.length == 0) {
            return;
        }
        for (File file : fileArrListFiles) {
            file.delete();
        }
        shareCacheFolder.delete();
    }

    private final File copyToShareCacheFolder(File file) throws IOException {
        File shareCacheFolder = getShareCacheFolder();
        if (!shareCacheFolder.exists()) {
            shareCacheFolder.mkdirs();
        }
        File file2 = new File(shareCacheFolder, file.getName());
        FilesKt.copyTo$default(file, file2, true, 0, 4, null);
        return file2;
    }
}
