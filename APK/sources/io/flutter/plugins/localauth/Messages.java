package io.flutter.plugins.localauth;

import android.util.Log;
import androidx.media3.extractor.ts.TsExtractor;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugins.localauth.Messages;
import java.io.ByteArrayOutputStream;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/* JADX INFO: loaded from: classes3.dex */
public class Messages {

    @Target({ElementType.METHOD})
    @Retention(RetentionPolicy.CLASS)
    @interface CanIgnoreReturnValue {
    }

    public interface NullableResult<T> {
        void error(Throwable th);

        void success(T t);
    }

    public interface Result<T> {
        void error(Throwable th);

        void success(T t);
    }

    public interface VoidResult {
        void error(Throwable th);

        void success();
    }

    public static class FlutterError extends RuntimeException {
        public final String code;
        public final Object details;

        public FlutterError(String str, String str2, Object obj) {
            super(str2);
            this.code = str;
            this.details = obj;
        }
    }

    protected static ArrayList<Object> wrapError(Throwable th) {
        ArrayList<Object> arrayList = new ArrayList<>(3);
        if (th instanceof FlutterError) {
            FlutterError flutterError = (FlutterError) th;
            arrayList.add(flutterError.code);
            arrayList.add(flutterError.getMessage());
            arrayList.add(flutterError.details);
            return arrayList;
        }
        arrayList.add(th.toString());
        arrayList.add(th.getClass().getSimpleName());
        arrayList.add("Cause: " + th.getCause() + ", Stacktrace: " + Log.getStackTraceString(th));
        return arrayList;
    }

    public enum AuthResultCode {
        SUCCESS(0),
        NEGATIVE_BUTTON(1),
        USER_CANCELED(2),
        SYSTEM_CANCELED(3),
        TIMEOUT(4),
        ALREADY_IN_PROGRESS(5),
        NO_ACTIVITY(6),
        NOT_FRAGMENT_ACTIVITY(7),
        NO_CREDENTIALS(8),
        NO_HARDWARE(9),
        HARDWARE_UNAVAILABLE(10),
        NOT_ENROLLED(11),
        LOCKED_OUT_TEMPORARILY(12),
        LOCKED_OUT_PERMANENTLY(13),
        NO_SPACE(14),
        SECURITY_UPDATE_REQUIRED(15),
        UNKNOWN_ERROR(16);

        final int index;

        AuthResultCode(int i) {
            this.index = i;
        }
    }

    public enum AuthClassification {
        WEAK(0),
        STRONG(1);

        final int index;

        AuthClassification(int i) {
            this.index = i;
        }
    }

    public static final class AuthStrings {
        private String cancelButton;
        private String reason;
        private String signInHint;
        private String signInTitle;

        public String getReason() {
            return this.reason;
        }

        public void setReason(String str) {
            if (str == null) {
                throw new IllegalStateException("Nonnull field \"reason\" is null.");
            }
            this.reason = str;
        }

        public String getSignInHint() {
            return this.signInHint;
        }

        public void setSignInHint(String str) {
            if (str == null) {
                throw new IllegalStateException("Nonnull field \"signInHint\" is null.");
            }
            this.signInHint = str;
        }

        public String getCancelButton() {
            return this.cancelButton;
        }

        public void setCancelButton(String str) {
            if (str == null) {
                throw new IllegalStateException("Nonnull field \"cancelButton\" is null.");
            }
            this.cancelButton = str;
        }

        public String getSignInTitle() {
            return this.signInTitle;
        }

        public void setSignInTitle(String str) {
            if (str == null) {
                throw new IllegalStateException("Nonnull field \"signInTitle\" is null.");
            }
            this.signInTitle = str;
        }

        AuthStrings() {
        }

        public boolean equals(Object obj) {
            if (this == obj) {
                return true;
            }
            if (obj != null && getClass() == obj.getClass()) {
                AuthStrings authStrings = (AuthStrings) obj;
                if (this.reason.equals(authStrings.reason) && this.signInHint.equals(authStrings.signInHint) && this.cancelButton.equals(authStrings.cancelButton) && this.signInTitle.equals(authStrings.signInTitle)) {
                    return true;
                }
            }
            return false;
        }

        public int hashCode() {
            return Objects.hash(this.reason, this.signInHint, this.cancelButton, this.signInTitle);
        }

        public static final class Builder {
            private String cancelButton;
            private String reason;
            private String signInHint;
            private String signInTitle;

            public Builder setReason(String str) {
                this.reason = str;
                return this;
            }

            public Builder setSignInHint(String str) {
                this.signInHint = str;
                return this;
            }

            public Builder setCancelButton(String str) {
                this.cancelButton = str;
                return this;
            }

            public Builder setSignInTitle(String str) {
                this.signInTitle = str;
                return this;
            }

            public AuthStrings build() {
                AuthStrings authStrings = new AuthStrings();
                authStrings.setReason(this.reason);
                authStrings.setSignInHint(this.signInHint);
                authStrings.setCancelButton(this.cancelButton);
                authStrings.setSignInTitle(this.signInTitle);
                return authStrings;
            }
        }

        ArrayList<Object> toList() {
            ArrayList<Object> arrayList = new ArrayList<>(4);
            arrayList.add(this.reason);
            arrayList.add(this.signInHint);
            arrayList.add(this.cancelButton);
            arrayList.add(this.signInTitle);
            return arrayList;
        }

        static AuthStrings fromList(ArrayList<Object> arrayList) {
            AuthStrings authStrings = new AuthStrings();
            authStrings.setReason((String) arrayList.get(0));
            authStrings.setSignInHint((String) arrayList.get(1));
            authStrings.setCancelButton((String) arrayList.get(2));
            authStrings.setSignInTitle((String) arrayList.get(3));
            return authStrings;
        }
    }

    public static final class AuthResult {
        private AuthResultCode code;
        private String errorMessage;

        public AuthResultCode getCode() {
            return this.code;
        }

        public void setCode(AuthResultCode authResultCode) {
            if (authResultCode == null) {
                throw new IllegalStateException("Nonnull field \"code\" is null.");
            }
            this.code = authResultCode;
        }

        public String getErrorMessage() {
            return this.errorMessage;
        }

        public void setErrorMessage(String str) {
            this.errorMessage = str;
        }

        AuthResult() {
        }

        public boolean equals(Object obj) {
            if (this == obj) {
                return true;
            }
            if (obj != null && getClass() == obj.getClass()) {
                AuthResult authResult = (AuthResult) obj;
                if (this.code.equals(authResult.code) && Objects.equals(this.errorMessage, authResult.errorMessage)) {
                    return true;
                }
            }
            return false;
        }

        public int hashCode() {
            return Objects.hash(this.code, this.errorMessage);
        }

        public static final class Builder {
            private AuthResultCode code;
            private String errorMessage;

            public Builder setCode(AuthResultCode authResultCode) {
                this.code = authResultCode;
                return this;
            }

            public Builder setErrorMessage(String str) {
                this.errorMessage = str;
                return this;
            }

            public AuthResult build() {
                AuthResult authResult = new AuthResult();
                authResult.setCode(this.code);
                authResult.setErrorMessage(this.errorMessage);
                return authResult;
            }
        }

        ArrayList<Object> toList() {
            ArrayList<Object> arrayList = new ArrayList<>(2);
            arrayList.add(this.code);
            arrayList.add(this.errorMessage);
            return arrayList;
        }

        static AuthResult fromList(ArrayList<Object> arrayList) {
            AuthResult authResult = new AuthResult();
            authResult.setCode((AuthResultCode) arrayList.get(0));
            authResult.setErrorMessage((String) arrayList.get(1));
            return authResult;
        }
    }

    public static final class AuthOptions {
        private Boolean biometricOnly;
        private Boolean sensitiveTransaction;
        private Boolean sticky;

        public Boolean getBiometricOnly() {
            return this.biometricOnly;
        }

        public void setBiometricOnly(Boolean bool) {
            if (bool == null) {
                throw new IllegalStateException("Nonnull field \"biometricOnly\" is null.");
            }
            this.biometricOnly = bool;
        }

        public Boolean getSensitiveTransaction() {
            return this.sensitiveTransaction;
        }

        public void setSensitiveTransaction(Boolean bool) {
            if (bool == null) {
                throw new IllegalStateException("Nonnull field \"sensitiveTransaction\" is null.");
            }
            this.sensitiveTransaction = bool;
        }

        public Boolean getSticky() {
            return this.sticky;
        }

        public void setSticky(Boolean bool) {
            if (bool == null) {
                throw new IllegalStateException("Nonnull field \"sticky\" is null.");
            }
            this.sticky = bool;
        }

        AuthOptions() {
        }

        public boolean equals(Object obj) {
            if (this == obj) {
                return true;
            }
            if (obj != null && getClass() == obj.getClass()) {
                AuthOptions authOptions = (AuthOptions) obj;
                if (this.biometricOnly.equals(authOptions.biometricOnly) && this.sensitiveTransaction.equals(authOptions.sensitiveTransaction) && this.sticky.equals(authOptions.sticky)) {
                    return true;
                }
            }
            return false;
        }

        public int hashCode() {
            return Objects.hash(this.biometricOnly, this.sensitiveTransaction, this.sticky);
        }

        public static final class Builder {
            private Boolean biometricOnly;
            private Boolean sensitiveTransaction;
            private Boolean sticky;

            public Builder setBiometricOnly(Boolean bool) {
                this.biometricOnly = bool;
                return this;
            }

            public Builder setSensitiveTransaction(Boolean bool) {
                this.sensitiveTransaction = bool;
                return this;
            }

            public Builder setSticky(Boolean bool) {
                this.sticky = bool;
                return this;
            }

            public AuthOptions build() {
                AuthOptions authOptions = new AuthOptions();
                authOptions.setBiometricOnly(this.biometricOnly);
                authOptions.setSensitiveTransaction(this.sensitiveTransaction);
                authOptions.setSticky(this.sticky);
                return authOptions;
            }
        }

        ArrayList<Object> toList() {
            ArrayList<Object> arrayList = new ArrayList<>(3);
            arrayList.add(this.biometricOnly);
            arrayList.add(this.sensitiveTransaction);
            arrayList.add(this.sticky);
            return arrayList;
        }

        static AuthOptions fromList(ArrayList<Object> arrayList) {
            AuthOptions authOptions = new AuthOptions();
            authOptions.setBiometricOnly((Boolean) arrayList.get(0));
            authOptions.setSensitiveTransaction((Boolean) arrayList.get(1));
            authOptions.setSticky((Boolean) arrayList.get(2));
            return authOptions;
        }
    }

    private static class PigeonCodec extends StandardMessageCodec {
        public static final PigeonCodec INSTANCE = new PigeonCodec();

        private PigeonCodec() {
        }

        @Override // io.flutter.plugin.common.StandardMessageCodec
        protected Object readValueOfType(byte b, ByteBuffer byteBuffer) {
            switch (b) {
                case -127:
                    Object value = readValue(byteBuffer);
                    if (value == null) {
                        return null;
                    }
                    return AuthResultCode.values()[((Long) value).intValue()];
                case -126:
                    Object value2 = readValue(byteBuffer);
                    if (value2 == null) {
                        return null;
                    }
                    return AuthClassification.values()[((Long) value2).intValue()];
                case -125:
                    return AuthStrings.fromList((ArrayList) readValue(byteBuffer));
                case -124:
                    return AuthResult.fromList((ArrayList) readValue(byteBuffer));
                case -123:
                    return AuthOptions.fromList((ArrayList) readValue(byteBuffer));
                default:
                    return super.readValueOfType(b, byteBuffer);
            }
        }

        @Override // io.flutter.plugin.common.StandardMessageCodec
        protected void writeValue(ByteArrayOutputStream byteArrayOutputStream, Object obj) {
            if (obj instanceof AuthResultCode) {
                byteArrayOutputStream.write(TsExtractor.TS_STREAM_TYPE_AC3);
                writeValue(byteArrayOutputStream, obj != null ? Integer.valueOf(((AuthResultCode) obj).index) : null);
                return;
            }
            if (obj instanceof AuthClassification) {
                byteArrayOutputStream.write(TsExtractor.TS_STREAM_TYPE_HDMV_DTS);
                writeValue(byteArrayOutputStream, obj != null ? Integer.valueOf(((AuthClassification) obj).index) : null);
                return;
            }
            if (obj instanceof AuthStrings) {
                byteArrayOutputStream.write(131);
                writeValue(byteArrayOutputStream, ((AuthStrings) obj).toList());
            } else if (obj instanceof AuthResult) {
                byteArrayOutputStream.write(132);
                writeValue(byteArrayOutputStream, ((AuthResult) obj).toList());
            } else if (obj instanceof AuthOptions) {
                byteArrayOutputStream.write(133);
                writeValue(byteArrayOutputStream, ((AuthOptions) obj).toList());
            } else {
                super.writeValue(byteArrayOutputStream, obj);
            }
        }
    }

    public interface LocalAuthApi {
        void authenticate(AuthOptions authOptions, AuthStrings authStrings, Result<AuthResult> result);

        Boolean deviceCanSupportBiometrics();

        List<AuthClassification> getEnrolledBiometrics();

        Boolean isDeviceSupported();

        Boolean stopAuthentication();

        static MessageCodec<Object> getCodec() {
            return PigeonCodec.INSTANCE;
        }

        static void setUp(BinaryMessenger binaryMessenger, LocalAuthApi localAuthApi) {
            setUp(binaryMessenger, "", localAuthApi);
        }

        static void setUp(BinaryMessenger binaryMessenger, String str, final LocalAuthApi localAuthApi) {
            String str2 = str.isEmpty() ? "" : "." + str;
            BasicMessageChannel basicMessageChannel = new BasicMessageChannel(binaryMessenger, "dev.flutter.pigeon.local_auth_android.LocalAuthApi.isDeviceSupported" + str2, getCodec());
            if (localAuthApi != null) {
                basicMessageChannel.setMessageHandler(new BasicMessageChannel.MessageHandler() { // from class: io.flutter.plugins.localauth.Messages$LocalAuthApi$$ExternalSyntheticLambda0
                    @Override // io.flutter.plugin.common.BasicMessageChannel.MessageHandler
                    public final void onMessage(Object obj, BasicMessageChannel.Reply reply) {
                        Messages.LocalAuthApi.lambda$setUp$0(this.f$0, obj, reply);
                    }
                });
            } else {
                basicMessageChannel.setMessageHandler(null);
            }
            BasicMessageChannel basicMessageChannel2 = new BasicMessageChannel(binaryMessenger, "dev.flutter.pigeon.local_auth_android.LocalAuthApi.deviceCanSupportBiometrics" + str2, getCodec());
            if (localAuthApi != null) {
                basicMessageChannel2.setMessageHandler(new BasicMessageChannel.MessageHandler() { // from class: io.flutter.plugins.localauth.Messages$LocalAuthApi$$ExternalSyntheticLambda1
                    @Override // io.flutter.plugin.common.BasicMessageChannel.MessageHandler
                    public final void onMessage(Object obj, BasicMessageChannel.Reply reply) {
                        Messages.LocalAuthApi.lambda$setUp$1(this.f$0, obj, reply);
                    }
                });
            } else {
                basicMessageChannel2.setMessageHandler(null);
            }
            BasicMessageChannel basicMessageChannel3 = new BasicMessageChannel(binaryMessenger, "dev.flutter.pigeon.local_auth_android.LocalAuthApi.stopAuthentication" + str2, getCodec());
            if (localAuthApi != null) {
                basicMessageChannel3.setMessageHandler(new BasicMessageChannel.MessageHandler() { // from class: io.flutter.plugins.localauth.Messages$LocalAuthApi$$ExternalSyntheticLambda2
                    @Override // io.flutter.plugin.common.BasicMessageChannel.MessageHandler
                    public final void onMessage(Object obj, BasicMessageChannel.Reply reply) {
                        Messages.LocalAuthApi.lambda$setUp$2(this.f$0, obj, reply);
                    }
                });
            } else {
                basicMessageChannel3.setMessageHandler(null);
            }
            BasicMessageChannel basicMessageChannel4 = new BasicMessageChannel(binaryMessenger, "dev.flutter.pigeon.local_auth_android.LocalAuthApi.getEnrolledBiometrics" + str2, getCodec());
            if (localAuthApi != null) {
                basicMessageChannel4.setMessageHandler(new BasicMessageChannel.MessageHandler() { // from class: io.flutter.plugins.localauth.Messages$LocalAuthApi$$ExternalSyntheticLambda3
                    @Override // io.flutter.plugin.common.BasicMessageChannel.MessageHandler
                    public final void onMessage(Object obj, BasicMessageChannel.Reply reply) {
                        Messages.LocalAuthApi.lambda$setUp$3(this.f$0, obj, reply);
                    }
                });
            } else {
                basicMessageChannel4.setMessageHandler(null);
            }
            BasicMessageChannel basicMessageChannel5 = new BasicMessageChannel(binaryMessenger, "dev.flutter.pigeon.local_auth_android.LocalAuthApi.authenticate" + str2, getCodec());
            if (localAuthApi != null) {
                basicMessageChannel5.setMessageHandler(new BasicMessageChannel.MessageHandler() { // from class: io.flutter.plugins.localauth.Messages$LocalAuthApi$$ExternalSyntheticLambda4
                    @Override // io.flutter.plugin.common.BasicMessageChannel.MessageHandler
                    public final void onMessage(Object obj, BasicMessageChannel.Reply reply) {
                        Messages.LocalAuthApi.lambda$setUp$4(this.f$0, obj, reply);
                    }
                });
            } else {
                basicMessageChannel5.setMessageHandler(null);
            }
        }

        static /* synthetic */ void lambda$setUp$0(LocalAuthApi localAuthApi, Object obj, BasicMessageChannel.Reply reply) {
            ArrayList<Object> arrayList = new ArrayList<>();
            try {
                arrayList.add(0, localAuthApi.isDeviceSupported());
            } catch (Throwable th) {
                arrayList = Messages.wrapError(th);
            }
            reply.reply(arrayList);
        }

        static /* synthetic */ void lambda$setUp$1(LocalAuthApi localAuthApi, Object obj, BasicMessageChannel.Reply reply) {
            ArrayList<Object> arrayList = new ArrayList<>();
            try {
                arrayList.add(0, localAuthApi.deviceCanSupportBiometrics());
            } catch (Throwable th) {
                arrayList = Messages.wrapError(th);
            }
            reply.reply(arrayList);
        }

        static /* synthetic */ void lambda$setUp$2(LocalAuthApi localAuthApi, Object obj, BasicMessageChannel.Reply reply) {
            ArrayList<Object> arrayList = new ArrayList<>();
            try {
                arrayList.add(0, localAuthApi.stopAuthentication());
            } catch (Throwable th) {
                arrayList = Messages.wrapError(th);
            }
            reply.reply(arrayList);
        }

        static /* synthetic */ void lambda$setUp$3(LocalAuthApi localAuthApi, Object obj, BasicMessageChannel.Reply reply) {
            ArrayList<Object> arrayList = new ArrayList<>();
            try {
                arrayList.add(0, localAuthApi.getEnrolledBiometrics());
            } catch (Throwable th) {
                arrayList = Messages.wrapError(th);
            }
            reply.reply(arrayList);
        }

        static /* synthetic */ void lambda$setUp$4(LocalAuthApi localAuthApi, Object obj, final BasicMessageChannel.Reply reply) {
            final ArrayList arrayList = new ArrayList();
            ArrayList arrayList2 = (ArrayList) obj;
            localAuthApi.authenticate((AuthOptions) arrayList2.get(0), (AuthStrings) arrayList2.get(1), new Result<AuthResult>() { // from class: io.flutter.plugins.localauth.Messages.LocalAuthApi.1
                @Override // io.flutter.plugins.localauth.Messages.Result
                public void success(AuthResult authResult) {
                    arrayList.add(0, authResult);
                    reply.reply(arrayList);
                }

                @Override // io.flutter.plugins.localauth.Messages.Result
                public void error(Throwable th) {
                    reply.reply(Messages.wrapError(th));
                }
            });
        }
    }
}
