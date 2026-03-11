package dev.fluttercommunity.plus.device_info;

import android.app.ActivityManager;
import android.content.ContentResolver;
import android.content.pm.FeatureInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Environment;
import android.os.StatFs;
import android.provider.Settings;
import androidx.core.app.NotificationCompat;
import androidx.core.os.EnvironmentCompat;
import androidx.media3.container.NalUnitUtil;
import androidx.media3.exoplayer.rtsp.SessionDescription;
import androidx.media3.extractor.text.ttml.TtmlNode;
import com.google.firebase.messaging.Constants;
import com.tekartik.sqflite.Constant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import kotlin.Metadata;
import kotlin.collections.CollectionsKt;
import kotlin.jvm.internal.Intrinsics;
import kotlin.text.StringsKt;

/* JADX INFO: compiled from: MethodCallHandlerImpl.kt */
/* JADX INFO: loaded from: classes3.dex */
@Metadata(d1 = {"\u0000B\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0003\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010 \n\u0002\u0010\u000e\n\u0000\n\u0002\u0010\u000b\n\u0002\b\u0002\b\u0000\u0018\u00002\u00020\u0001B\u001f\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0006\u0010\u0004\u001a\u00020\u0005\u0012\u0006\u0010\u0006\u001a\u00020\u0007¢\u0006\u0004\b\b\u0010\tJ\u0018\u0010\n\u001a\u00020\u000b2\u0006\u0010\f\u001a\u00020\r2\u0006\u0010\u000e\u001a\u00020\u000fH\u0016J\u000e\u0010\u0010\u001a\b\u0012\u0004\u0012\u00020\u00120\u0011H\u0002R\u000e\u0010\u0002\u001a\u00020\u0003X\u0082\u0004¢\u0006\u0002\n\u0000R\u000e\u0010\u0004\u001a\u00020\u0005X\u0082\u0004¢\u0006\u0002\n\u0000R\u000e\u0010\u0006\u001a\u00020\u0007X\u0082\u0004¢\u0006\u0002\n\u0000R\u0014\u0010\u0013\u001a\u00020\u00148BX\u0082\u0004¢\u0006\u0006\u001a\u0004\b\u0013\u0010\u0015¨\u0006\u0016"}, d2 = {"Ldev/fluttercommunity/plus/device_info/MethodCallHandlerImpl;", "Lio/flutter/plugin/common/MethodChannel$MethodCallHandler;", "packageManager", "Landroid/content/pm/PackageManager;", "activityManager", "Landroid/app/ActivityManager;", "contentResolver", "Landroid/content/ContentResolver;", "<init>", "(Landroid/content/pm/PackageManager;Landroid/app/ActivityManager;Landroid/content/ContentResolver;)V", "onMethodCall", "", NotificationCompat.CATEGORY_CALL, "Lio/flutter/plugin/common/MethodCall;", Constant.PARAM_RESULT, "Lio/flutter/plugin/common/MethodChannel$Result;", "getSystemFeatures", "", "", "isEmulator", "", "()Z", "device_info_plus_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
public final class MethodCallHandlerImpl implements MethodChannel.MethodCallHandler {
    private final ActivityManager activityManager;
    private final ContentResolver contentResolver;
    private final PackageManager packageManager;

    public MethodCallHandlerImpl(PackageManager packageManager, ActivityManager activityManager, ContentResolver contentResolver) {
        Intrinsics.checkNotNullParameter(packageManager, "packageManager");
        Intrinsics.checkNotNullParameter(activityManager, "activityManager");
        Intrinsics.checkNotNullParameter(contentResolver, "contentResolver");
        this.packageManager = packageManager;
        this.activityManager = activityManager;
        this.contentResolver = contentResolver;
    }

    @Override // io.flutter.plugin.common.MethodChannel.MethodCallHandler
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        Intrinsics.checkNotNullParameter(call, "call");
        Intrinsics.checkNotNullParameter(result, "result");
        if (call.method.equals("getDeviceInfo")) {
            HashMap map = new HashMap();
            map.put("board", Build.BOARD);
            map.put("bootloader", Build.BOOTLOADER);
            map.put("brand", Build.BRAND);
            map.put("device", Build.DEVICE);
            map.put(Constants.ScionAnalytics.MessageType.DISPLAY_NOTIFICATION, Build.DISPLAY);
            map.put("fingerprint", Build.FINGERPRINT);
            map.put("hardware", Build.HARDWARE);
            map.put("host", Build.HOST);
            map.put(TtmlNode.ATTR_ID, Build.ID);
            map.put("manufacturer", Build.MANUFACTURER);
            map.put("model", Build.MODEL);
            map.put("product", Build.PRODUCT);
            if (Build.VERSION.SDK_INT >= 25) {
                String string = Settings.Global.getString(this.contentResolver, "device_name");
                if (string == null) {
                    string = "";
                }
                map.put("name", string);
            }
            String[] strArr = Build.SUPPORTED_32_BIT_ABIS;
            map.put("supported32BitAbis", CollectionsKt.listOf(Arrays.copyOf(strArr, strArr.length)));
            String[] strArr2 = Build.SUPPORTED_64_BIT_ABIS;
            map.put("supported64BitAbis", CollectionsKt.listOf(Arrays.copyOf(strArr2, strArr2.length)));
            String[] strArr3 = Build.SUPPORTED_ABIS;
            map.put("supportedAbis", CollectionsKt.listOf(Arrays.copyOf(strArr3, strArr3.length)));
            map.put("tags", Build.TAGS);
            map.put(SessionDescription.ATTR_TYPE, Build.TYPE);
            map.put("isPhysicalDevice", Boolean.valueOf(!isEmulator()));
            map.put("systemFeatures", getSystemFeatures());
            StatFs statFs = new StatFs(Environment.getDataDirectory().getPath());
            map.put("freeDiskSize", Long.valueOf(statFs.getFreeBytes()));
            map.put("totalDiskSize", Long.valueOf(statFs.getTotalBytes()));
            HashMap map2 = new HashMap();
            map2.put("baseOS", Build.VERSION.BASE_OS);
            map2.put("previewSdkInt", Integer.valueOf(Build.VERSION.PREVIEW_SDK_INT));
            map2.put("securityPatch", Build.VERSION.SECURITY_PATCH);
            map2.put("codename", Build.VERSION.CODENAME);
            map2.put("incremental", Build.VERSION.INCREMENTAL);
            map2.put("release", Build.VERSION.RELEASE);
            map2.put("sdkInt", Integer.valueOf(Build.VERSION.SDK_INT));
            map.put("version", map2);
            ActivityManager.MemoryInfo memoryInfo = new ActivityManager.MemoryInfo();
            this.activityManager.getMemoryInfo(memoryInfo);
            map.put("isLowRamDevice", Boolean.valueOf(memoryInfo.lowMemory));
            map.put("physicalRamSize", Long.valueOf(memoryInfo.totalMem / 1048576));
            map.put("availableRamSize", Long.valueOf(memoryInfo.availMem / 1048576));
            result.success(map);
            return;
        }
        result.notImplemented();
    }

    private final List<String> getSystemFeatures() {
        FeatureInfo[] systemAvailableFeatures = this.packageManager.getSystemAvailableFeatures();
        Intrinsics.checkNotNullExpressionValue(systemAvailableFeatures, "getSystemAvailableFeatures(...)");
        ArrayList arrayList = new ArrayList();
        for (FeatureInfo featureInfo : systemAvailableFeatures) {
            if (featureInfo.name != null) {
                arrayList.add(featureInfo);
            }
        }
        ArrayList arrayList2 = arrayList;
        ArrayList arrayList3 = new ArrayList(CollectionsKt.collectionSizeOrDefault(arrayList2, 10));
        Iterator it = arrayList2.iterator();
        while (it.hasNext()) {
            arrayList3.add(((FeatureInfo) it.next()).name);
        }
        return arrayList3;
    }

    private final boolean isEmulator() {
        String BRAND = Build.BRAND;
        Intrinsics.checkNotNullExpressionValue(BRAND, "BRAND");
        if (StringsKt.startsWith$default(BRAND, "generic", false, 2, (Object) null)) {
            String DEVICE = Build.DEVICE;
            Intrinsics.checkNotNullExpressionValue(DEVICE, "DEVICE");
            if (StringsKt.startsWith$default(DEVICE, "generic", false, 2, (Object) null)) {
                return true;
            }
        }
        String FINGERPRINT = Build.FINGERPRINT;
        Intrinsics.checkNotNullExpressionValue(FINGERPRINT, "FINGERPRINT");
        if (StringsKt.startsWith$default(FINGERPRINT, "generic", false, 2, (Object) null)) {
            return true;
        }
        String FINGERPRINT2 = Build.FINGERPRINT;
        Intrinsics.checkNotNullExpressionValue(FINGERPRINT2, "FINGERPRINT");
        if (StringsKt.startsWith$default(FINGERPRINT2, EnvironmentCompat.MEDIA_UNKNOWN, false, 2, (Object) null)) {
            return true;
        }
        String HARDWARE = Build.HARDWARE;
        Intrinsics.checkNotNullExpressionValue(HARDWARE, "HARDWARE");
        if (StringsKt.contains$default((CharSequence) HARDWARE, (CharSequence) "goldfish", false, 2, (Object) null)) {
            return true;
        }
        String HARDWARE2 = Build.HARDWARE;
        Intrinsics.checkNotNullExpressionValue(HARDWARE2, "HARDWARE");
        if (StringsKt.contains$default((CharSequence) HARDWARE2, (CharSequence) "ranchu", false, 2, (Object) null)) {
            return true;
        }
        String MODEL = Build.MODEL;
        Intrinsics.checkNotNullExpressionValue(MODEL, "MODEL");
        if (StringsKt.contains$default((CharSequence) MODEL, (CharSequence) "google_sdk", false, 2, (Object) null)) {
            return true;
        }
        String MODEL2 = Build.MODEL;
        Intrinsics.checkNotNullExpressionValue(MODEL2, "MODEL");
        if (StringsKt.contains$default((CharSequence) MODEL2, (CharSequence) "Emulator", false, 2, (Object) null)) {
            return true;
        }
        String MODEL3 = Build.MODEL;
        Intrinsics.checkNotNullExpressionValue(MODEL3, "MODEL");
        if (StringsKt.contains$default((CharSequence) MODEL3, (CharSequence) "Android SDK built for x86", false, 2, (Object) null)) {
            return true;
        }
        String MANUFACTURER = Build.MANUFACTURER;
        Intrinsics.checkNotNullExpressionValue(MANUFACTURER, "MANUFACTURER");
        if (StringsKt.contains$default((CharSequence) MANUFACTURER, (CharSequence) "Genymotion", false, 2, (Object) null)) {
            return true;
        }
        String PRODUCT = Build.PRODUCT;
        Intrinsics.checkNotNullExpressionValue(PRODUCT, "PRODUCT");
        if (StringsKt.contains$default((CharSequence) PRODUCT, (CharSequence) "sdk", false, 2, (Object) null)) {
            return true;
        }
        String PRODUCT2 = Build.PRODUCT;
        Intrinsics.checkNotNullExpressionValue(PRODUCT2, "PRODUCT");
        if (StringsKt.contains$default((CharSequence) PRODUCT2, (CharSequence) "vbox86p", false, 2, (Object) null)) {
            return true;
        }
        String PRODUCT3 = Build.PRODUCT;
        Intrinsics.checkNotNullExpressionValue(PRODUCT3, "PRODUCT");
        if (StringsKt.contains$default((CharSequence) PRODUCT3, (CharSequence) "emulator", false, 2, (Object) null)) {
            return true;
        }
        String PRODUCT4 = Build.PRODUCT;
        Intrinsics.checkNotNullExpressionValue(PRODUCT4, "PRODUCT");
        return StringsKt.contains$default((CharSequence) PRODUCT4, (CharSequence) "simulator", false, 2, (Object) null);
    }
}
