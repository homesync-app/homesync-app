# ==============================================================================
# HomeSync ProGuard/R8 Rules
# ==============================================================================
# These rules prevent R8 from stripping code that uses reflection,
# dynamic class loading, or JSON serialization — which would cause
# runtime crashes in release builds.
# ==============================================================================

# --- Flutter Engine ---
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# --- Firebase ---
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Firebase Crashlytics — keep line numbers for readable stack traces
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# --- Google Sign-In (Credential Manager) ---
-keep class com.google.android.libraries.identity.** { *; }
-dontwarn com.google.android.libraries.identity.**
-keep class androidx.credentials.** { *; }
-dontwarn androidx.credentials.**

# --- Supabase / GoTrue / Realtime ---
# Supabase uses Kotlin serialization and dynamic JSON parsing
-keep class io.supabase.** { *; }
-dontwarn io.supabase.**
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# Keep JSON model classes (prevent stripping of fields used in Maps)
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# --- Kotlin Serialization ---
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.**
-keepclassmembers class kotlinx.serialization.json.** { *; }

# --- OkHttp / Network ---
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }

# --- MercadoPago (if using native SDK in the future) ---
-keep class com.mercadopago.** { *; }
-dontwarn com.mercadopago.**

# --- In-App Purchase ---
-keep class com.android.vending.billing.** { *; }

# --- Video Player ---
-keep class io.flutter.plugins.videoplayer.** { *; }

# --- General safety ---
# Keep enums (used by many serialization libs)
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
