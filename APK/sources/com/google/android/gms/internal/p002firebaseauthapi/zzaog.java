package com.google.android.gms.internal.p002firebaseauthapi;

/* JADX WARN: Failed to restore enum class, 'enum' modifier and super class removed */
/* JADX WARN: Unknown enum class pattern. Please report as an issue! */
/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public class zzaog {
    public static final zzaog zza;
    public static final zzaog zzb;
    public static final zzaog zzc;
    public static final zzaog zzd;
    public static final zzaog zze;
    public static final zzaog zzf;
    public static final zzaog zzg;
    public static final zzaog zzh;
    public static final zzaog zzi;
    public static final zzaog zzj;
    public static final zzaog zzk;
    public static final zzaog zzl;
    public static final zzaog zzm;
    public static final zzaog zzn;
    public static final zzaog zzo;
    public static final zzaog zzp;
    public static final zzaog zzq;
    public static final zzaog zzr;
    private static final /* synthetic */ zzaog[] zzs;
    private final zzaoj zzt;
    private final int zzu;

    public final int zza() {
        return this.zzu;
    }

    public final zzaoj zzb() {
        return this.zzt;
    }

    static {
        zzaog zzaogVar = new zzaog("DOUBLE", 0, zzaoj.DOUBLE, 1);
        zza = zzaogVar;
        zzaog zzaogVar2 = new zzaog("FLOAT", 1, zzaoj.FLOAT, 5);
        zzb = zzaogVar2;
        zzaog zzaogVar3 = new zzaog("INT64", 2, zzaoj.LONG, 0);
        zzc = zzaogVar3;
        zzaog zzaogVar4 = new zzaog("UINT64", 3, zzaoj.LONG, 0);
        zzd = zzaogVar4;
        zzaog zzaogVar5 = new zzaog("INT32", 4, zzaoj.INT, 0);
        zze = zzaogVar5;
        zzaog zzaogVar6 = new zzaog("FIXED64", 5, zzaoj.LONG, 1);
        zzf = zzaogVar6;
        zzaog zzaogVar7 = new zzaog("FIXED32", 6, zzaoj.INT, 5);
        zzg = zzaogVar7;
        zzaog zzaogVar8 = new zzaog("BOOL", 7, zzaoj.BOOLEAN, 0);
        zzh = zzaogVar8;
        zzaof zzaofVar = new zzaof("STRING", zzaoj.STRING);
        zzi = zzaofVar;
        zzaoi zzaoiVar = new zzaoi("GROUP", zzaoj.MESSAGE);
        zzj = zzaoiVar;
        zzaoh zzaohVar = new zzaoh("MESSAGE", zzaoj.MESSAGE);
        zzk = zzaohVar;
        zzaok zzaokVar = new zzaok("BYTES", zzaoj.BYTE_STRING);
        zzl = zzaokVar;
        zzaog zzaogVar9 = new zzaog("UINT32", 12, zzaoj.INT, 0);
        zzm = zzaogVar9;
        zzaog zzaogVar10 = new zzaog("ENUM", 13, zzaoj.ENUM, 0);
        zzn = zzaogVar10;
        zzaog zzaogVar11 = new zzaog("SFIXED32", 14, zzaoj.INT, 5);
        zzo = zzaogVar11;
        zzaog zzaogVar12 = new zzaog("SFIXED64", 15, zzaoj.LONG, 1);
        zzp = zzaogVar12;
        zzaog zzaogVar13 = new zzaog("SINT32", 16, zzaoj.INT, 0);
        zzq = zzaogVar13;
        zzaog zzaogVar14 = new zzaog("SINT64", 17, zzaoj.LONG, 0);
        zzr = zzaogVar14;
        zzs = new zzaog[]{zzaogVar, zzaogVar2, zzaogVar3, zzaogVar4, zzaogVar5, zzaogVar6, zzaogVar7, zzaogVar8, zzaofVar, zzaoiVar, zzaohVar, zzaokVar, zzaogVar9, zzaogVar10, zzaogVar11, zzaogVar12, zzaogVar13, zzaogVar14};
    }

    private zzaog(String str, int i, zzaoj zzaojVar, int i2) {
        this.zzt = zzaojVar;
        this.zzu = i2;
    }

    public static zzaog[] values() {
        return (zzaog[]) zzs.clone();
    }
}
