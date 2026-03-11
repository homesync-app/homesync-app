package com.google.firebase.auth.internal;

import android.text.TextUtils;
import androidx.core.text.HtmlCompat;
import androidx.core.view.MotionEventCompat;
import androidx.media3.container.MdtaMetadataEntry;
import androidx.media3.container.NalUnitUtil;
import androidx.media3.extractor.ts.TsExtractor;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.fido.u2f.api.common.RegisterRequest;
import com.google.common.base.Ascii;
import com.google.common.primitives.SignedBytes;
import com.google.firebase.FirebaseError;
import java.util.Arrays;
import java.util.List;
import kotlin.io.encoding.Base64;
import kotlinx.coroutines.internal.LockFreeTaskQueueCore;
import okio.Utf8;

/* JADX INFO: compiled from: com.google.firebase:firebase-auth@@24.0.1 */
/* JADX INFO: loaded from: classes3.dex */
public final class zzao {
    /* JADX WARN: Failed to restore switch over string. Please report as a decompilation issue */
    private static Status zza(String str, String str2) {
        int i;
        str.hashCode();
        byte b = -1;
        switch (str.hashCode()) {
            case -2130504259:
                if (str.equals("USER_CANCELLED")) {
                    b = 0;
                }
                break;
            case -2065866930:
                if (str.equals("INVALID_RECIPIENT_EMAIL")) {
                    b = 1;
                }
                break;
            case -2014808264:
                if (str.equals("WEB_CONTEXT_ALREADY_PRESENTED")) {
                    b = 2;
                }
                break;
            case -2005236790:
                if (str.equals("INTERNAL_SUCCESS_SIGN_OUT")) {
                    b = 3;
                }
                break;
            case -2001169389:
                if (str.equals("INVALID_IDP_RESPONSE")) {
                    b = 4;
                }
                break;
            case -1944433728:
                if (str.equals("DYNAMIC_LINK_NOT_ACTIVATED")) {
                    b = 5;
                }
                break;
            case -1800638118:
                if (str.equals("QUOTA_EXCEEDED")) {
                    b = 6;
                }
                break;
            case -1774756919:
                if (str.equals("WEB_NETWORK_REQUEST_FAILED")) {
                    b = 7;
                }
                break;
            case -1699246888:
                if (str.equals("INVALID_RECAPTCHA_VERSION")) {
                    b = 8;
                }
                break;
            case -1603818979:
                if (str.equals("RECAPTCHA_NOT_ENABLED")) {
                    b = 9;
                }
                break;
            case -1587614300:
                if (str.equals("EXPIRED_OOB_CODE")) {
                    b = 10;
                }
                break;
            case -1584641425:
                if (str.equals("UNAUTHORIZED_DOMAIN")) {
                    b = Ascii.VT;
                }
                break;
            case -1583894766:
                if (str.equals("INVALID_OOB_CODE")) {
                    b = Ascii.FF;
                }
                break;
            case -1458751677:
                if (str.equals("MISSING_EMAIL")) {
                    b = Ascii.CR;
                }
                break;
            case -1421414571:
                if (str.equals("INVALID_CODE")) {
                    b = Ascii.SO;
                }
                break;
            case -1368998244:
                if (str.equals("INVALID_HOSTING_LINK_DOMAIN")) {
                    b = Ascii.SI;
                }
                break;
            case -1345867105:
                if (str.equals("TOKEN_EXPIRED")) {
                    b = Ascii.DLE;
                }
                break;
            case -1340100504:
                if (str.equals("INVALID_TENANT_ID")) {
                    b = 17;
                }
                break;
            case -1242922234:
                if (str.equals("ALTERNATE_CLIENT_IDENTIFIER_REQUIRED")) {
                    b = Ascii.DC2;
                }
                break;
            case -1232010689:
                if (str.equals("INVALID_SESSION_INFO")) {
                    b = 19;
                }
                break;
            case -1202691903:
                if (str.equals("SECOND_FACTOR_EXISTS")) {
                    b = Ascii.DC4;
                }
                break;
            case -1112393964:
                if (str.equals("INVALID_EMAIL")) {
                    b = Ascii.NAK;
                }
                break;
            case -1063710844:
                if (str.equals("ADMIN_ONLY_OPERATION")) {
                    b = Ascii.SYN;
                }
                break;
            case -974503964:
                if (str.equals("MISSING_OR_INVALID_NONCE")) {
                    b = Ascii.ETB;
                }
                break;
            case -863830559:
                if (str.equals("INVALID_CERT_HASH")) {
                    b = Ascii.CAN;
                }
                break;
            case -828507413:
                if (str.equals("NO_SUCH_PROVIDER")) {
                    b = Ascii.EM;
                }
                break;
            case -749743758:
                if (str.equals("MFA_ENROLLMENT_NOT_FOUND")) {
                    b = Ascii.SUB;
                }
                break;
            case -736207500:
                if (str.equals("MISSING_PASSWORD")) {
                    b = Ascii.ESC;
                }
                break;
            case -646022241:
                if (str.equals("CREDENTIAL_TOO_OLD_LOGIN_AGAIN")) {
                    b = Ascii.FS;
                }
                break;
            case -595928767:
                if (str.equals("TIMEOUT")) {
                    b = Ascii.GS;
                }
                break;
            case -505579581:
                if (str.equals("INVALID_REQ_TYPE")) {
                    b = Ascii.RS;
                }
                break;
            case -406804866:
                if (str.equals("INVALID_LOGIN_CREDENTIALS")) {
                    b = Ascii.US;
                }
                break;
            case -380728810:
                if (str.equals("INVALID_RECAPTCHA_ACTION")) {
                    b = 32;
                }
                break;
            case -333672188:
                if (str.equals("OPERATION_NOT_ALLOWED")) {
                    b = 33;
                }
                break;
            case -294485423:
                if (str.equals("WEB_INTERNAL_ERROR")) {
                    b = 34;
                }
                break;
            case -217128228:
                if (str.equals("SECOND_FACTOR_LIMIT_EXCEEDED")) {
                    b = 35;
                }
                break;
            case -122667194:
                if (str.equals("MISSING_MFA_ENROLLMENT_ID")) {
                    b = 36;
                }
                break;
            case -75433118:
                if (str.equals("USER_NOT_FOUND")) {
                    b = 37;
                }
                break;
            case -52772551:
                if (str.equals("CAPTCHA_CHECK_FAILED")) {
                    b = 38;
                }
                break;
            case -40686718:
                if (str.equals("WEAK_PASSWORD")) {
                    b = 39;
                }
                break;
            case 15352275:
                if (str.equals("EMAIL_NOT_FOUND")) {
                    b = 40;
                }
                break;
            case 210308040:
                if (str.equals("UNSUPPORTED_FIRST_FACTOR")) {
                    b = 41;
                }
                break;
            case 269327773:
                if (str.equals("INVALID_SENDER")) {
                    b = 42;
                }
                break;
            case 278802867:
                if (str.equals("MISSING_PHONE_NUMBER")) {
                    b = 43;
                }
                break;
            case 408411681:
                if (str.equals("INVALID_DYNAMIC_LINK_DOMAIN")) {
                    b = 44;
                }
                break;
            case 423563023:
                if (str.equals("MISSING_MFA_PENDING_CREDENTIAL")) {
                    b = 45;
                }
                break;
            case 429251986:
                if (str.equals("UNSUPPORTED_PASSTHROUGH_OPERATION")) {
                    b = 46;
                }
                break;
            case 483847807:
                if (str.equals("EMAIL_EXISTS")) {
                    b = 47;
                }
                break;
            case 491979549:
                if (str.equals("INVALID_ID_TOKEN")) {
                    b = 48;
                }
                break;
            case 492072102:
                if (str.equals("WEB_STORAGE_UNSUPPORTED")) {
                    b = 49;
                }
                break;
            case 492515765:
                if (str.equals("MISSING_CLIENT_TYPE")) {
                    b = 50;
                }
                break;
            case 530628231:
                if (str.equals("MISSING_RECAPTCHA_VERSION")) {
                    b = 51;
                }
                break;
            case 542728406:
                if (str.equals("PASSWORD_LOGIN_DISABLED")) {
                    b = 52;
                }
                break;
            case 582457886:
                if (str.equals("UNVERIFIED_EMAIL")) {
                    b = 53;
                }
                break;
            case 605031096:
                if (str.equals("REJECTED_CREDENTIAL")) {
                    b = 54;
                }
                break;
            case 745638750:
                if (str.equals("INVALID_MFA_PENDING_CREDENTIAL")) {
                    b = 55;
                }
                break;
            case 786916712:
                if (str.equals("INVALID_VERIFICATION_PROOF")) {
                    b = 56;
                }
                break;
            case 799258561:
                if (str.equals("INVALID_PROVIDER_ID")) {
                    b = 57;
                }
                break;
            case 819646646:
                if (str.equals("CREDENTIAL_MISMATCH")) {
                    b = 58;
                }
                break;
            case 844240628:
                if (str.equals("WEB_CONTEXT_CANCELED")) {
                    b = 59;
                }
                break;
            case 886186878:
                if (str.equals("REQUIRES_SECOND_FACTOR_AUTH")) {
                    b = 60;
                }
                break;
            case 895302372:
                if (str.equals("MISSING_CLIENT_IDENTIFIER")) {
                    b = Base64.padSymbol;
                }
                break;
            case 922685102:
                if (str.equals("INVALID_MESSAGE_PAYLOAD")) {
                    b = 62;
                }
                break;
            case 989000548:
                if (str.equals("RESET_PASSWORD_EXCEED_LIMIT")) {
                    b = Utf8.REPLACEMENT_BYTE;
                }
                break;
            case 1034932393:
                if (str.equals("INVALID_PENDING_TOKEN")) {
                    b = SignedBytes.MAX_POWER_OF_TWO;
                }
                break;
            case 1072360691:
                if (str.equals("INVALID_CUSTOM_TOKEN")) {
                    b = 65;
                }
                break;
            case 1094975491:
                if (str.equals("INVALID_PASSWORD")) {
                    b = 66;
                }
                break;
            case 1107081238:
                if (str.equals("<<Network Error>>")) {
                    b = 67;
                }
                break;
            case 1113992697:
                if (str.equals("INVALID_RECAPTCHA_TOKEN")) {
                    b = 68;
                }
                break;
            case 1141576252:
                if (str.equals("SESSION_EXPIRED")) {
                    b = 69;
                }
                break;
            case 1199811910:
                if (str.equals("MISSING_CODE")) {
                    b = 70;
                }
                break;
            case 1226505451:
                if (str.equals("FEDERATED_USER_ID_ALREADY_LINKED")) {
                    b = 71;
                }
                break;
            case 1308491624:
                if (str.equals("MISSING_RECAPTCHA_TOKEN")) {
                    b = 72;
                }
                break;
            case 1388786705:
                if (str.equals("INVALID_IDENTIFIER")) {
                    b = 73;
                }
                break;
            case 1433767024:
                if (str.equals("USER_DISABLED")) {
                    b = 74;
                }
                break;
            case 1442968770:
                if (str.equals("INVALID_PHONE_NUMBER")) {
                    b = 75;
                }
                break;
            case 1494923453:
                if (str.equals("INVALID_APP_CREDENTIAL")) {
                    b = 76;
                }
                break;
            case 1497901284:
                if (str.equals("TOO_MANY_ATTEMPTS_TRY_LATER")) {
                    b = 77;
                }
                break;
            case 1803454477:
                if (str.equals("MISSING_CONTINUE_URI")) {
                    b = 78;
                }
                break;
            case 1898790704:
                if (str.equals("MISSING_SESSION_INFO")) {
                    b = 79;
                }
                break;
            case 2063209097:
                if (str.equals("EMAIL_CHANGE_NEEDS_VERIFICATION")) {
                    b = 80;
                }
                break;
            case 2082564316:
                if (str.equals("UNSUPPORTED_TENANT_OPERATION")) {
                    b = 81;
                }
                break;
        }
        switch (b) {
            case 0:
                i = 18001;
                break;
            case 1:
                i = 17033;
                break;
            case 2:
                i = 17057;
                break;
            case 3:
                i = 17091;
                break;
            case 4:
            case 31:
            case 64:
                i = FirebaseError.ERROR_INVALID_CREDENTIAL;
                break;
            case 5:
                i = 17068;
                break;
            case 6:
                i = 17052;
                break;
            case 7:
                i = 17061;
                break;
            case 8:
                i = 17206;
                break;
            case 9:
                i = 17200;
                break;
            case 10:
                i = 17029;
                break;
            case 11:
                i = 17038;
                break;
            case 12:
                i = 17030;
                break;
            case 13:
                i = 17034;
                break;
            case 14:
                i = 17044;
                break;
            case 15:
                i = 17214;
                break;
            case 16:
                i = FirebaseError.ERROR_USER_TOKEN_EXPIRED;
                break;
            case 17:
                i = 17079;
                break;
            case 18:
                i = 18002;
                break;
            case 19:
                i = 17046;
                break;
            case 20:
                i = 17087;
                break;
            case 21:
            case 73:
                i = FirebaseError.ERROR_INVALID_EMAIL;
                break;
            case 22:
                i = 17085;
                break;
            case 23:
                i = 17094;
                break;
            case 24:
                i = 17064;
                break;
            case 25:
                i = FirebaseError.ERROR_NO_SUCH_PROVIDER;
                break;
            case 26:
                i = 17084;
                break;
            case 27:
                i = 17035;
                break;
            case 28:
                i = FirebaseError.ERROR_REQUIRES_RECENT_LOGIN;
                break;
            case 29:
            case MdtaMetadataEntry.TYPE_INDICATOR_INT32 /* 67 */:
                i = FirebaseError.ERROR_NETWORK_REQUEST_FAILED;
                break;
            case 30:
                i = 17207;
                break;
            case 32:
                i = 17203;
                break;
            case 33:
            case 52:
                i = FirebaseError.ERROR_OPERATION_NOT_ALLOWED;
                break;
            case 34:
                i = 17062;
                break;
            case 35:
                i = 17088;
                break;
            case 36:
                i = 17082;
                break;
            case 37:
            case 40:
                i = FirebaseError.ERROR_USER_NOT_FOUND;
                break;
            case 38:
                i = 17056;
                break;
            case 39:
                i = FirebaseError.ERROR_WEAK_PASSWORD;
                break;
            case 41:
                i = 17089;
                break;
            case 42:
                i = 17032;
                break;
            case MotionEventCompat.AXIS_GENERIC_12 /* 43 */:
                i = 17041;
                break;
            case 44:
                i = 17074;
                break;
            case 45:
                i = 17081;
                break;
            case MotionEventCompat.AXIS_GENERIC_15 /* 46 */:
                i = 17095;
                break;
            case MotionEventCompat.AXIS_GENERIC_16 /* 47 */:
                i = FirebaseError.ERROR_EMAIL_ALREADY_IN_USE;
                break;
            case NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED /* 48 */:
                i = FirebaseError.ERROR_INVALID_USER_TOKEN;
                break;
            case 49:
                i = 17065;
                break;
            case 50:
                i = 17204;
                break;
            case 51:
                i = 17205;
                break;
            case 53:
                i = 17086;
                break;
            case 54:
                i = 17075;
                break;
            case 55:
                i = 17083;
                break;
            case 56:
                i = 17049;
                break;
            case 57:
                i = 17071;
                break;
            case 58:
                i = FirebaseError.ERROR_CUSTOM_TOKEN_MISMATCH;
                break;
            case 59:
                i = 17058;
                break;
            case LockFreeTaskQueueCore.FROZEN_SHIFT /* 60 */:
                i = 17078;
                break;
            case LockFreeTaskQueueCore.CLOSED_SHIFT /* 61 */:
                i = 17093;
                break;
            case 62:
                i = 17031;
                break;
            case HtmlCompat.FROM_HTML_MODE_COMPACT /* 63 */:
            case 77:
                i = FirebaseError.ERROR_TOO_MANY_REQUESTS;
                break;
            case RegisterRequest.U2F_V1_CHALLENGE_BYTE_LENGTH /* 65 */:
                i = FirebaseError.ERROR_INVALID_CUSTOM_TOKEN;
                break;
            case 66:
                i = FirebaseError.ERROR_WRONG_PASSWORD;
                break;
            case 68:
                i = 17202;
                break;
            case 69:
                i = 17051;
                break;
            case 70:
                i = 17043;
                break;
            case TsExtractor.TS_SYNC_BYTE /* 71 */:
                i = FirebaseError.ERROR_CREDENTIAL_ALREADY_IN_USE;
                break;
            case 72:
                i = 17201;
                break;
            case 74:
                i = FirebaseError.ERROR_USER_DISABLED;
                break;
            case MdtaMetadataEntry.TYPE_INDICATOR_8_BIT_UNSIGNED_INT /* 75 */:
                i = 17042;
                break;
            case 76:
                i = FirebaseError.ERROR_APP_NOT_AUTHORIZED;
                break;
            case MdtaMetadataEntry.TYPE_INDICATOR_UNSIGNED_INT64 /* 78 */:
                i = 17040;
                break;
            case 79:
                i = 17045;
                break;
            case 80:
                i = 17090;
                break;
            case 81:
                i = 17073;
                break;
            default:
                i = 17499;
                break;
        }
        return i == 17499 ? str2 != null ? new Status(i, str + ":" + str2) : new Status(i, str) : new Status(i, str2);
    }

    public static Status zza(String str) {
        String str2;
        if (TextUtils.isEmpty(str)) {
            return new Status(FirebaseError.ERROR_INTERNAL_ERROR);
        }
        String[] strArrSplit = str.split(":", 2);
        strArrSplit[0] = strArrSplit[0].trim();
        if (strArrSplit.length > 1 && (str2 = strArrSplit[1]) != null) {
            strArrSplit[1] = str2.trim();
        }
        List listAsList = Arrays.asList(strArrSplit);
        if (listAsList.size() > 1) {
            return zza((String) listAsList.get(0), (String) listAsList.get(1));
        }
        return zza((String) listAsList.get(0), null);
    }
}
