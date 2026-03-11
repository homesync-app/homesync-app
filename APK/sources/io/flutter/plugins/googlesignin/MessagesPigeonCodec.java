package io.flutter.plugins.googlesignin;

import androidx.media3.container.NalUnitUtil;
import androidx.media3.exoplayer.rtsp.SessionDescription;
import androidx.media3.extractor.ts.TsExtractor;
import io.flutter.plugin.common.StandardMessageCodec;
import java.io.ByteArrayOutputStream;
import java.nio.ByteBuffer;
import java.util.List;
import kotlin.Metadata;
import kotlin.jvm.internal.Intrinsics;

/* JADX INFO: compiled from: Messages.kt */
/* JADX INFO: loaded from: classes3.dex */
@Metadata(d1 = {"\u0000,\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0003\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u0005\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\b\u0012\u0018\u00002\u00020\u0001B\u0007¢\u0006\u0004\b\u0002\u0010\u0003J\u001a\u0010\u0004\u001a\u0004\u0018\u00010\u00052\u0006\u0010\u0006\u001a\u00020\u00072\u0006\u0010\b\u001a\u00020\tH\u0014J\u001a\u0010\n\u001a\u00020\u000b2\u0006\u0010\f\u001a\u00020\r2\b\u0010\u000e\u001a\u0004\u0018\u00010\u0005H\u0014¨\u0006\u000f"}, d2 = {"Lio/flutter/plugins/googlesignin/MessagesPigeonCodec;", "Lio/flutter/plugin/common/StandardMessageCodec;", "<init>", "()V", "readValueOfType", "", SessionDescription.ATTR_TYPE, "", "buffer", "Ljava/nio/ByteBuffer;", "writeValue", "", "stream", "Ljava/io/ByteArrayOutputStream;", "value", "google_sign_in_android_release"}, k = 1, mv = {2, 2, 0}, xi = NalUnitUtil.H265_NAL_UNIT_TYPE_UNSPECIFIED)
class MessagesPigeonCodec extends StandardMessageCodec {
    @Override // io.flutter.plugin.common.StandardMessageCodec
    protected Object readValueOfType(byte type, ByteBuffer buffer) {
        Intrinsics.checkNotNullParameter(buffer, "buffer");
        if (type == -127) {
            Long l = (Long) readValue(buffer);
            if (l != null) {
                return GetCredentialFailureType.INSTANCE.ofRaw((int) l.longValue());
            }
            return null;
        }
        if (type == -126) {
            Long l2 = (Long) readValue(buffer);
            if (l2 != null) {
                return AuthorizeFailureType.INSTANCE.ofRaw((int) l2.longValue());
            }
            return null;
        }
        if (type == -125) {
            Object value = readValue(buffer);
            List<? extends Object> list = value instanceof List ? (List) value : null;
            if (list != null) {
                return PlatformAuthorizationRequest.INSTANCE.fromList(list);
            }
            return null;
        }
        if (type == -124) {
            Object value2 = readValue(buffer);
            List<? extends Object> list2 = value2 instanceof List ? (List) value2 : null;
            if (list2 != null) {
                return GetCredentialRequestParams.INSTANCE.fromList(list2);
            }
            return null;
        }
        if (type == -123) {
            Object value3 = readValue(buffer);
            List<? extends Object> list3 = value3 instanceof List ? (List) value3 : null;
            if (list3 != null) {
                return GetCredentialRequestGoogleIdOptionParams.INSTANCE.fromList(list3);
            }
            return null;
        }
        if (type == -122) {
            Object value4 = readValue(buffer);
            List<? extends Object> list4 = value4 instanceof List ? (List) value4 : null;
            if (list4 != null) {
                return PlatformRevokeAccessRequest.INSTANCE.fromList(list4);
            }
            return null;
        }
        if (type == -121) {
            Object value5 = readValue(buffer);
            List<? extends Object> list5 = value5 instanceof List ? (List) value5 : null;
            if (list5 != null) {
                return PlatformGoogleIdTokenCredential.INSTANCE.fromList(list5);
            }
            return null;
        }
        if (type == -120) {
            Object value6 = readValue(buffer);
            List<? extends Object> list6 = value6 instanceof List ? (List) value6 : null;
            if (list6 != null) {
                return GetCredentialFailure.INSTANCE.fromList(list6);
            }
            return null;
        }
        if (type == -119) {
            Object value7 = readValue(buffer);
            List<? extends Object> list7 = value7 instanceof List ? (List) value7 : null;
            if (list7 != null) {
                return GetCredentialSuccess.INSTANCE.fromList(list7);
            }
            return null;
        }
        if (type == -118) {
            Object value8 = readValue(buffer);
            List<? extends Object> list8 = value8 instanceof List ? (List) value8 : null;
            if (list8 != null) {
                return AuthorizeFailure.INSTANCE.fromList(list8);
            }
            return null;
        }
        if (type == -117) {
            Object value9 = readValue(buffer);
            List<? extends Object> list9 = value9 instanceof List ? (List) value9 : null;
            if (list9 != null) {
                return PlatformAuthorizationResult.INSTANCE.fromList(list9);
            }
            return null;
        }
        return super.readValueOfType(type, buffer);
    }

    @Override // io.flutter.plugin.common.StandardMessageCodec
    protected void writeValue(ByteArrayOutputStream stream, Object value) {
        Intrinsics.checkNotNullParameter(stream, "stream");
        if (value instanceof GetCredentialFailureType) {
            stream.write(TsExtractor.TS_STREAM_TYPE_AC3);
            writeValue(stream, Long.valueOf(((GetCredentialFailureType) value).getRaw()));
            return;
        }
        if (value instanceof AuthorizeFailureType) {
            stream.write(TsExtractor.TS_STREAM_TYPE_HDMV_DTS);
            writeValue(stream, Long.valueOf(((AuthorizeFailureType) value).getRaw()));
            return;
        }
        if (value instanceof PlatformAuthorizationRequest) {
            stream.write(131);
            writeValue(stream, ((PlatformAuthorizationRequest) value).toList());
            return;
        }
        if (value instanceof GetCredentialRequestParams) {
            stream.write(132);
            writeValue(stream, ((GetCredentialRequestParams) value).toList());
            return;
        }
        if (value instanceof GetCredentialRequestGoogleIdOptionParams) {
            stream.write(133);
            writeValue(stream, ((GetCredentialRequestGoogleIdOptionParams) value).toList());
            return;
        }
        if (value instanceof PlatformRevokeAccessRequest) {
            stream.write(TsExtractor.TS_STREAM_TYPE_SPLICE_INFO);
            writeValue(stream, ((PlatformRevokeAccessRequest) value).toList());
            return;
        }
        if (value instanceof PlatformGoogleIdTokenCredential) {
            stream.write(TsExtractor.TS_STREAM_TYPE_E_AC3);
            writeValue(stream, ((PlatformGoogleIdTokenCredential) value).toList());
            return;
        }
        if (value instanceof GetCredentialFailure) {
            stream.write(TsExtractor.TS_STREAM_TYPE_DTS_HD);
            writeValue(stream, ((GetCredentialFailure) value).toList());
            return;
        }
        if (value instanceof GetCredentialSuccess) {
            stream.write(137);
            writeValue(stream, ((GetCredentialSuccess) value).toList());
        } else if (value instanceof AuthorizeFailure) {
            stream.write(TsExtractor.TS_STREAM_TYPE_DTS);
            writeValue(stream, ((AuthorizeFailure) value).toList());
        } else if (value instanceof PlatformAuthorizationResult) {
            stream.write(TsExtractor.TS_STREAM_TYPE_DTS_UHD);
            writeValue(stream, ((PlatformAuthorizationResult) value).toList());
        } else {
            super.writeValue(stream, value);
        }
    }
}
