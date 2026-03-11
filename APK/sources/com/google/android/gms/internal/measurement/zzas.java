package com.google.android.gms.internal.measurement;

import androidx.media3.exoplayer.rtsp.SessionDescription;
import com.google.common.base.Ascii;
import com.google.firebase.analytics.FirebaseAnalytics;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/* JADX INFO: compiled from: com.google.android.gms:play-services-measurement@@23.0.0 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzas implements Iterable, zzao {
    private final String zza;

    public zzas(String str) {
        if (str == null) {
            throw new IllegalArgumentException("StringValue cannot be null.");
        }
        this.zza = str;
    }

    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj instanceof zzas) {
            return this.zza.equals(((zzas) obj).zza);
        }
        return false;
    }

    public final int hashCode() {
        return this.zza.hashCode();
    }

    @Override // java.lang.Iterable
    public final Iterator iterator() {
        return new zzar(this);
    }

    public final String toString() {
        String str = this.zza;
        StringBuilder sb = new StringBuilder(str.length() + 2);
        sb.append("\"");
        sb.append(str);
        sb.append("\"");
        return sb.toString();
    }

    final /* synthetic */ String zzb() {
        return this.zza;
    }

    @Override // com.google.android.gms.internal.measurement.zzao
    public final String zzc() {
        return this.zza;
    }

    /* JADX WARN: Can't fix incorrect switch cases order, some code will duplicate */
    /* JADX WARN: Multi-variable type inference failed */
    @Override // com.google.android.gms.internal.measurement.zzao
    public final zzao zzcA(String str, zzg zzgVar, List list) {
        String str2;
        String str3;
        String str4;
        byte b;
        zzas zzasVar;
        int i;
        String strZzc;
        int i2;
        int i3;
        zzg zzgVar2;
        int iZzi;
        if ("charAt".equals(str) || "concat".equals(str) || "hasOwnProperty".equals(str) || "indexOf".equals(str) || "lastIndexOf".equals(str) || "match".equals(str) || "replace".equals(str) || FirebaseAnalytics.Event.SEARCH.equals(str) || "slice".equals(str) || "split".equals(str) || "substring".equals(str) || "toLowerCase".equals(str) || "toLocaleLowerCase".equals(str) || "toString".equals(str) || "toUpperCase".equals(str) || "toLocaleUpperCase".equals(str)) {
            str2 = "hasOwnProperty";
        } else {
            str2 = "hasOwnProperty";
            if (!"trim".equals(str)) {
                throw new IllegalArgumentException(String.format("%s is not a String function", str));
            }
        }
        switch (str.hashCode()) {
            case -1789698943:
                str3 = str2;
                str4 = "charAt";
                b = str.equals(str3) ? (byte) 2 : (byte) -1;
                break;
            case -1776922004:
                str4 = "charAt";
                if (str.equals("toString")) {
                    b = Ascii.SO;
                    str3 = str2;
                }
                str3 = str2;
                break;
            case -1464939364:
                str4 = "charAt";
                if (str.equals("toLocaleLowerCase")) {
                    b = Ascii.FF;
                    str3 = str2;
                }
                str3 = str2;
                break;
            case -1361633751:
                str4 = "charAt";
                if (str.equals(str4)) {
                    str3 = str2;
                    b = 0;
                }
                str3 = str2;
                break;
            case -1354795244:
                if (str.equals("concat")) {
                    str3 = str2;
                    str4 = "charAt";
                    b = 1;
                }
                str3 = str2;
                str4 = "charAt";
                break;
            case -1137582698:
                if (str.equals("toLowerCase")) {
                    b = Ascii.CR;
                    str3 = str2;
                    str4 = "charAt";
                }
                str3 = str2;
                str4 = "charAt";
                break;
            case -906336856:
                if (str.equals(FirebaseAnalytics.Event.SEARCH)) {
                    b = 7;
                    str3 = str2;
                    str4 = "charAt";
                }
                str3 = str2;
                str4 = "charAt";
                break;
            case -726908483:
                if (str.equals("toLocaleUpperCase")) {
                    b = Ascii.VT;
                    str3 = str2;
                    str4 = "charAt";
                }
                str3 = str2;
                str4 = "charAt";
                break;
            case -467511597:
                if (str.equals("lastIndexOf")) {
                    b = 4;
                    str3 = str2;
                    str4 = "charAt";
                }
                str3 = str2;
                str4 = "charAt";
                break;
            case -399551817:
                if (str.equals("toUpperCase")) {
                    b = Ascii.SI;
                    str3 = str2;
                    str4 = "charAt";
                }
                str3 = str2;
                str4 = "charAt";
                break;
            case 3568674:
                if (str.equals("trim")) {
                    b = Ascii.DLE;
                    str3 = str2;
                    str4 = "charAt";
                }
                str3 = str2;
                str4 = "charAt";
                break;
            case 103668165:
                if (str.equals("match")) {
                    b = 5;
                    str3 = str2;
                    str4 = "charAt";
                }
                str3 = str2;
                str4 = "charAt";
                break;
            case 109526418:
                if (str.equals("slice")) {
                    b = 8;
                    str3 = str2;
                    str4 = "charAt";
                }
                str3 = str2;
                str4 = "charAt";
                break;
            case 109648666:
                if (str.equals("split")) {
                    b = 9;
                    str3 = str2;
                    str4 = "charAt";
                }
                str3 = str2;
                str4 = "charAt";
                break;
            case 530542161:
                if (str.equals("substring")) {
                    b = 10;
                    str3 = str2;
                    str4 = "charAt";
                }
                str3 = str2;
                str4 = "charAt";
                break;
            case 1094496948:
                if (str.equals("replace")) {
                    b = 6;
                    str3 = str2;
                    str4 = "charAt";
                }
                str3 = str2;
                str4 = "charAt";
                break;
            case 1943291465:
                if (str.equals("indexOf")) {
                    b = 3;
                    str3 = str2;
                    str4 = "charAt";
                }
                str3 = str2;
                str4 = "charAt";
                break;
            default:
                str3 = str2;
                str4 = "charAt";
                break;
        }
        String str5 = str4;
        switch (b) {
            case 0:
                zzh.zzc(str5, 1, list);
                int iZzi2 = !list.isEmpty() ? (int) zzh.zzi(zzgVar.zza((zzao) list.get(0)).zzd().doubleValue()) : 0;
                String str6 = this.zza;
                return (iZzi2 < 0 || iZzi2 >= str6.length()) ? zzao.zzm : new zzas(String.valueOf(str6.charAt(iZzi2)));
            case 1:
                zzasVar = this;
                if (!list.isEmpty()) {
                    StringBuilder sb = new StringBuilder(zzasVar.zza);
                    for (int i4 = 0; i4 < list.size(); i4++) {
                        sb.append(zzgVar.zza((zzao) list.get(i4)).zzc());
                    }
                    return new zzas(sb.toString());
                }
                return zzasVar;
            case 2:
                zzh.zza(str3, 1, list);
                String str7 = this.zza;
                zzao zzaoVarZza = zzgVar.zza((zzao) list.get(0));
                if (SessionDescription.ATTR_LENGTH.equals(zzaoVarZza.zzc())) {
                    return zzaf.zzk;
                }
                double dDoubleValue = zzaoVarZza.zzd().doubleValue();
                return (dDoubleValue != Math.floor(dDoubleValue) || (i = (int) dDoubleValue) < 0 || i >= str7.length()) ? zzaf.zzl : zzaf.zzk;
            case 3:
                zzh.zzc("indexOf", 2, list);
                return new zzah(Double.valueOf(this.zza.indexOf(list.size() > 0 ? zzgVar.zza((zzao) list.get(0)).zzc() : "undefined", (int) zzh.zzi(list.size() < 2 ? 0.0d : zzgVar.zza((zzao) list.get(1)).zzd().doubleValue()))));
            case 4:
                zzh.zzc("lastIndexOf", 2, list);
                String str8 = this.zza;
                String strZzc2 = list.size() > 0 ? zzgVar.zza((zzao) list.get(0)).zzc() : "undefined";
                return new zzah(Double.valueOf(str8.lastIndexOf(strZzc2, (int) (Double.isNaN(list.size() < 2 ? Double.NaN : zzgVar.zza((zzao) list.get(1)).zzd().doubleValue()) ? Double.POSITIVE_INFINITY : zzh.zzi(r0)))));
            case 5:
                zzh.zzc("match", 1, list);
                Matcher matcher = Pattern.compile(list.size() <= 0 ? "" : zzgVar.zza((zzao) list.get(0)).zzc()).matcher(this.zza);
                return matcher.find() ? new zzae(Arrays.asList(new zzas(matcher.group()))) : zzao.zzg;
            case 6:
                zzasVar = this;
                zzh.zzc("replace", 2, list);
                zzao zzaoVarZza2 = zzao.zzf;
                if (!list.isEmpty()) {
                    strZzc = zzgVar.zza((zzao) list.get(0)).zzc();
                    if (list.size() > 1) {
                        zzaoVarZza2 = zzgVar.zza((zzao) list.get(1));
                    }
                }
                String str9 = strZzc;
                String str10 = zzasVar.zza;
                int iIndexOf = str10.indexOf(str9);
                if (iIndexOf >= 0) {
                    if (zzaoVarZza2 instanceof zzai) {
                        zzaoVarZza2 = ((zzai) zzaoVarZza2).zza(zzgVar, Arrays.asList(new zzas(str9), new zzah(Double.valueOf(iIndexOf)), zzasVar));
                    }
                    String strSubstring = str10.substring(0, iIndexOf);
                    String strZzc3 = zzaoVarZza2.zzc();
                    String strSubstring2 = str10.substring(iIndexOf + str9.length());
                    StringBuilder sb2 = new StringBuilder(String.valueOf(strSubstring).length() + String.valueOf(strZzc3).length() + String.valueOf(strSubstring2).length());
                    sb2.append(strSubstring);
                    sb2.append(strZzc3);
                    sb2.append(strSubstring2);
                    return new zzas(sb2.toString());
                }
                return zzasVar;
            case 7:
                zzh.zzc(FirebaseAnalytics.Event.SEARCH, 1, list);
                return Pattern.compile(list.isEmpty() ? "undefined" : zzgVar.zza((zzao) list.get(0)).zzc()).matcher(this.zza).find() ? new zzah(Double.valueOf(r0.start())) : new zzah(Double.valueOf(-1.0d));
            case 8:
                zzh.zzc("slice", 2, list);
                String str11 = this.zza;
                double dZzi = zzh.zzi(!list.isEmpty() ? zzgVar.zza((zzao) list.get(0)).zzd().doubleValue() : 0.0d);
                double dMax = dZzi < 0.0d ? Math.max(((double) str11.length()) + dZzi, 0.0d) : Math.min(dZzi, str11.length());
                double dZzi2 = zzh.zzi(list.size() > 1 ? zzgVar.zza((zzao) list.get(1)).zzd().doubleValue() : str11.length());
                int i5 = (int) dMax;
                return new zzas(str11.substring(i5, Math.max(0, ((int) (dZzi2 < 0.0d ? Math.max(((double) str11.length()) + dZzi2, 0.0d) : Math.min(dZzi2, str11.length()))) - i5) + i5));
            case 9:
                zzh.zzc("split", 2, list);
                String str12 = this.zza;
                if (str12.length() == 0) {
                    return new zzae(Arrays.asList(this));
                }
                ArrayList arrayList = new ArrayList();
                if (list.isEmpty()) {
                    arrayList.add(this);
                } else {
                    String strZzc4 = zzgVar.zza((zzao) list.get(0)).zzc();
                    long jZzh = list.size() > 1 ? zzh.zzh(zzgVar.zza((zzao) list.get(1)).zzd().doubleValue()) : 2147483647L;
                    if (jZzh == 0) {
                        return new zzae();
                    }
                    String[] strArrSplit = str12.split(Pattern.quote(strZzc4), ((int) jZzh) + 1);
                    int length = strArrSplit.length;
                    if (!strZzc4.isEmpty() || length <= 0) {
                        i2 = length;
                        i3 = 0;
                    } else {
                        boolean zIsEmpty = strArrSplit[0].isEmpty();
                        i2 = length - 1;
                        i3 = zIsEmpty;
                        if (!strArrSplit[i2].isEmpty()) {
                            i2 = length;
                            i3 = zIsEmpty;
                        }
                    }
                    if (length > jZzh) {
                        i2--;
                    }
                    while (i3 < i2) {
                        arrayList.add(new zzas(strArrSplit[i3]));
                        i3++;
                    }
                }
                return new zzae(arrayList);
            case 10:
                zzh.zzc("substring", 2, list);
                String str13 = this.zza;
                if (list.isEmpty()) {
                    zzgVar2 = zzgVar;
                    iZzi = 0;
                } else {
                    zzgVar2 = zzgVar;
                    iZzi = (int) zzh.zzi(zzgVar2.zza((zzao) list.get(0)).zzd().doubleValue());
                }
                int iZzi3 = list.size() > 1 ? (int) zzh.zzi(zzgVar2.zza((zzao) list.get(1)).zzd().doubleValue()) : str13.length();
                int iMin = Math.min(Math.max(iZzi, 0), str13.length());
                int iMin2 = Math.min(Math.max(iZzi3, 0), str13.length());
                return new zzas(str13.substring(Math.min(iMin, iMin2), Math.max(iMin, iMin2)));
            case 11:
                zzh.zza("toLocaleUpperCase", 0, list);
                return new zzas(this.zza.toUpperCase());
            case 12:
                zzh.zza("toLocaleLowerCase", 0, list);
                return new zzas(this.zza.toLowerCase());
            case 13:
                zzh.zza("toLowerCase", 0, list);
                return new zzas(this.zza.toLowerCase(Locale.ENGLISH));
            case 14:
                zzh.zza("toString", 0, list);
                return this;
            case 15:
                zzh.zza("toUpperCase", 0, list);
                return new zzas(this.zza.toUpperCase(Locale.ENGLISH));
            case 16:
                zzh.zza("toUpperCase", 0, list);
                return new zzas(this.zza.trim());
            default:
                throw new IllegalArgumentException("Command not supported");
        }
    }

    @Override // com.google.android.gms.internal.measurement.zzao
    public final Double zzd() {
        String str = this.zza;
        if (str.isEmpty()) {
            return Double.valueOf(0.0d);
        }
        try {
            return Double.valueOf(str);
        } catch (NumberFormatException unused) {
            return Double.valueOf(Double.NaN);
        }
    }

    @Override // com.google.android.gms.internal.measurement.zzao
    public final Boolean zze() {
        return Boolean.valueOf(!this.zza.isEmpty());
    }

    @Override // com.google.android.gms.internal.measurement.zzao
    public final Iterator zzf() {
        return new zzaq(this);
    }

    @Override // com.google.android.gms.internal.measurement.zzao
    public final zzao zzt() {
        return new zzas(this.zza);
    }
}
