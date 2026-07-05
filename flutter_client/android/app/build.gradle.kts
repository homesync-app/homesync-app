import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // Kotlin: migrado a Built-in Kotlin (Flutter aplica KGP via flutter-gradle-plugin
    // con android.builtInKotlin=false en gradle.properties). Ya no declaramos
    // id("kotlin-android") aca; la version de jvmTarget va en el bloque kotlin{} abajo.
    // The Flutter Gradle Plugin must be applied after the Android Gradle plugin.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

// Load signing config from key.properties (never commit that file to git!)
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0.0"

// NOTA: BillingClient 7.1.1 (traído por in_app_purchase_android) tiene un NPE
// conocido en ProxyBillingActivity.onCreate (Crashlytics issue a0b58a19, 2
// eventos / 2 users en 7d). No existe 7.1.2 en Maven y 8.x rompe API del
// plugin. Si los eventos se vuelven significativos, bumpear in_app_purchase
// en pubspec.yaml a una versión que use billing 8.x.

android {
    namespace = "com.blas.homesync"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String? ?: ""
            keyPassword = keystoreProperties["keyPassword"] as String? ?: ""
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String? ?: ""
        }
    }

    defaultConfig {
        applicationId = "com.blas.homesync"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }

    buildTypes {
        release {
            // Enable shrinking/obfuscation to reduce app size and provide mapping files
            isMinifyEnabled = true
            isShrinkResources = true
            
            // FORCE the release keystore. If it's missing, the build SHOULD fail
            // instead of using the debug key (which causes the SHA1 mismatch)
            signingConfig = signingConfigs.getByName("release")

            // Enable Crashlytics native symbol upload for better crash reports
            firebaseCrashlytics {
                nativeSymbolUploadEnabled = true
                unstrippedNativeLibsDir = "build/intermediates/merged_native_libs/release/out/lib"
            }
        }
    }
}

// Built-in Kotlin: jvmTarget se configura via el DSL kotlin.compilerOptions
// (reemplaza al viejo android.kotlinOptions). Ver migracion a Built-in Kotlin.
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    // Android 15 edge-to-edge backport for SDK < 35.
    implementation("androidx.activity:activity:1.10.1")

    // Emoji2: renderiza emojis nuevos en Android < 10 sin actualización del sistema
    implementation("androidx.emoji2:emoji2:1.4.0")
    implementation("androidx.emoji2:emoji2-bundled:1.4.0")

    // Import the BoM for the Firebase platform
    implementation(platform("com.google.firebase:firebase-bom:34.10.0"))

    // Add dependencies for Credential Manager and Google Identity.
    // Requerido por google_sign_in 7.x. Crashlytics issue 7d8e6d01
    // ("providerConfigurationError: no provider dependencies found") se
    // dispara en dispositivos donde credentials-play-services-auth < 1.5
    // no registra el proveedor de Google. 1.5.0 ya es estable.
    implementation("androidx.credentials:credentials:1.5.0")
    implementation("androidx.credentials:credentials-play-services-auth:1.5.0")
    implementation("com.google.android.libraries.identity.googleid:googleid:1.1.1")
}

flutter {
    source = "../.."
}

