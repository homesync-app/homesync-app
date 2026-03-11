package com.tekartik.sqflite;

import android.database.Cursor;
import android.os.Build;
import android.util.Log;
import com.tekartik.sqflite.dev.Debug;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Objects;

/* JADX INFO: loaded from: classes3.dex */
public class Utils {
    public static List<Object> cursorRowToList(Cursor cursor, int i) {
        ArrayList arrayList = new ArrayList(i);
        for (int i2 = 0; i2 < i; i2++) {
            Object objCursorValue = cursorValue(cursor, i2);
            if (Debug.EXTRA_LOGV) {
                String string = getString(objCursorValue);
                Log.d(Constant.TAG, "column " + i2 + " " + cursor.getType(i2) + ": " + objCursorValue + (string == null ? "" : " (" + string + ")"));
            }
            arrayList.add(objCursorValue);
        }
        return arrayList;
    }

    private static String getString(Object obj) {
        if (obj == null) {
            return null;
        }
        if (obj.getClass().isArray()) {
            try {
                return "array(" + ((Class) Objects.requireNonNull(obj.getClass().getComponentType())).getName() + ")";
            } catch (Exception unused) {
                return "array";
            }
        }
        return obj.getClass().getName();
    }

    public static Object cursorValue(Cursor cursor, int i) {
        int type = cursor.getType(i);
        if (type == 1) {
            return Long.valueOf(cursor.getLong(i));
        }
        if (type == 2) {
            return Double.valueOf(cursor.getDouble(i));
        }
        if (type == 3) {
            return cursor.getString(i);
        }
        if (type != 4) {
            return null;
        }
        return cursor.getBlob(i);
    }

    static Locale localeForLanguageTag(String str) {
        return localeForLanguageTag21(str);
    }

    static Locale localeForLanguageTag21(String str) {
        return Locale.forLanguageTag(str);
    }

    static Locale localeForLanguageTagPre21(String str) {
        String str2;
        String str3;
        String str4;
        String[] strArrSplit = str.split("-");
        str2 = "";
        if (strArrSplit.length > 0) {
            String str5 = strArrSplit[0];
            if (strArrSplit.length > 1) {
                str4 = strArrSplit[1];
                str3 = strArrSplit.length > 2 ? strArrSplit[strArrSplit.length - 1] : "";
            } else {
                str3 = "";
                str4 = str3;
            }
            str2 = str5;
        } else {
            str3 = "";
            str4 = str3;
        }
        return localOf(str2, str4, str3);
    }

    static Locale localOf(String str, String str2, String str3) {
        if (Build.VERSION.SDK_INT >= 36) {
            return Locale.of(str, str2, str3);
        }
        return new Locale(str, str2, str3);
    }

    public static long getThreadId(Thread thread) {
        if (Build.VERSION.SDK_INT >= 36) {
            return thread.threadId();
        }
        return thread.getId();
    }
}
