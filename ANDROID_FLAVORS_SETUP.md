# 🍺 CONFIGURACIÓN DE FLAVORS ANDROID

**Fecha:** 2026-03-02
**Objetivo:** Configurar builds separados para Staging y Production

---

## 📋 ESTRUCTURA DE FLAVORS

```
android/app/
├── src/
│   ├── staging/           ← Build de staging
│   │   └── res/
│   │       └── values/
│   │           └── strings.xml
│   └── production/        ← Build de producción
│       └── res/
│           └── values/
│               └── strings.xml
└── build.gradle          ← Configuración de flavors
```

---

## ✅ PASO 1: CONFIGURAR BUILD.GRADLE

### 1.1 Editar android/app/build.gradle

Agregar después de `defaultConfig`:

```gradle
android {
    // ... código existente ...
    
    defaultConfig {
        applicationId "com.homesync.staging" // Default flavor
        // ... resto de configuración ...
    }
    
    flavorDimensions "environment"
    productFlavors {
        staging {
            dimension "environment"
            applicationId "com.homesync.staging"
            resValue "string/app_name", "HomeSync Staging"
            versionNameSuffix "-staging"
            
            buildConfigField "String", "BUILD_TYPE", '"staging"'
            buildConfigField "String", "SUPABASE_URL", '"https://tfavamqszdkoeabpyxms.supabase.co"'
        }
        
        production {
            dimension "environment"
            applicationId "com.homesync.app"
            resValue "string/app_name", "HomeSync"
            
            buildConfigField "String", "BUILD_TYPE", '"production"'
            buildConfigField "String", "SUPABASE_URL", '"https://api.homesync.com"'
        }
    }
}
```

---

## ✅ PASO 2: CREAR STRINGS.XML PARA CADA FLAVOR

### 2.1 Crear android/app/src/staging/res/values/strings.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">HomeSync Staging</string>
</resources>
```

### 2.2 Crear android/app/src/production/res/values/strings.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">HomeSync</string>
</resources>
```

---

## ✅ PASO 3: CONFIGURAR MANIFEST

### 3.1 Editar android/app/src/main/AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.homesync.app">

    <application
        android:label="@string/app_name"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboardOrientation|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <!-- Firebase Messaging -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="high_priority_channel"/>
        
        <!-- App Links -->
        <intent-filter android:autoVerify="true">
            <action android:name="android.intent.action.VIEW"/>
            <category android:name="android.intent.category.DEFAULT"/>
            <category android:name="android.intent.category.BROWSABLE"/>
            <data
                android:scheme="https"
                android:host="homesync.com"/>
        </intent-filter>
    </application>
</manifest>
```

---

## ✅ PASO 4: CONFIGURAR FIRBASE (OPCIONAL)

### 4.1 Crear android/app/src/staging/google-services.json

```json
{
  "project_info": {
    "project_number": "STAGING_PROJECT_NUMBER",
    "firebase_url": "https://staging-homesync.firebaseio.com",
    "project_id": "staging-homesync",
    "storage_bucket": "staging-homesync.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:STAGING:android:STAGING_HASH",
        "android_client_info": {
          "package_name": "com.homesync.staging"
        }
      },
      "oauth_client": [
        {
          "client_id": "STAGING_CLIENT_ID.apps.googleusercontent.com",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "STAGING_API_KEY"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
```

### 4.2 Crear android/app/src/production/google-services.json

```json
{
  "project_info": {
    "project_number": "PRODUCTION_PROJECT_NUMBER",
    "firebase_url": "https://homesync.firebaseio.com",
    "project_id": "homesync-prod",
    "storage_bucket": "homesync.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:PRODUCTION:android:PRODUCTION_HASH",
        "android_client_info": {
          "package_name": "com.homesync.app"
        }
      },
      "oauth_client": [
        {
          "client_id": "PRODUCTION_CLIENT_ID.apps.googleusercontent.com",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "PRODUCTION_API_KEY"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
```

---

## 🚀 COMANDOS DE BUILD

### Build Staging APK
```bash
# Limpiar cache
flutter clean
flutter pub get

# Build APK
flutter build apk --release --flavor staging

# APK generado en:
build/app/outputs/flutter-apk/app-staging-release.apk
```

### Build Production APK
```bash
# Limpiar cache
flutter clean
flutter pub get

# Build APK
flutter build apk --release --flavor production

# APK generado en:
build/app/outputs/flutter-apk/app-production-release.apk
```

### Build App Bundle (para Play Store)
```bash
# Staging App Bundle
flutter build appbundle --release --flavor staging

# Production App Bundle
flutter build appbundle --release --flavor production
```

---

## 🎯 VERIFICACIÓN

### Verificar que flavors funcionan correctamente

1. **Construir ambos flavors:**
```bash
flutter build apk --release --flavor staging
flutter build apk --release --flavor production
```

2. **Instalar staging APK:**
```bash
adb install build/app/outputs/flutter-apk/app-staging-release.apk
```
- Verificar que el nombre de la app es "HomeSync Staging"
- Verificar que usa Supabase Staging

3. **Desinstalar staging APK:**
```bash
adb uninstall com.homesync.staging
```

4. **Instalar production APK:**
```bash
adb install build/app/outputs/flutter-apk/app-production-release.apk
```
- Verificar que el nombre de la app es "HomeSync"
- Verificar que usa Supabase Production

---

## 🔧 SOLUCIÓN DE PROBLEMAS COMUNES

### Problema 1: Build falla con error de flavor
```
Error: Flavors not configured correctly

Solución:
1. Verificar android/app/build.gradle
2. Verificar que flavorDimensions está definido
3. Verificar que productFlavors están definidos
4. Limpiar: flutter clean
5. Reintentar build
```

### Problema 2: APK tiene nombre incorrecto
```
El APK se llama "HomeSync" en lugar de "HomeSync Staging"

Solución:
1. Verificar strings.xml en staging/res/values/
2. Verificar que app_name es correcto
3. Verificar que resValue en build.gradle está definido
4. Limpiar: flutter clean
5. Reintentar build
```

### Problema 3: App se conecta al ambiente incorrecto
```
App de staging se conecta a producción

Solución:
1. Verificar lib/config/app_environment.dart
2. Verificar que Environment.current es correcto
3. Verificar que String.fromEnvironment usa nombres correctos
4. Rebuild y reinstalar APK
```

### Problema 4: Firebase no funciona en staging
```
Solución:
1. Verificar google-services.json existe en staging/
2. Verificar que google-services.json está en producción/
3. Verificar que ambos archivos están en .gitignore
4. Verificar que firebase_core.init() llama a GoogleServicesPlugin
```

---

## 📚 REFERENCIAS

- Flutter Build Modes: https://docs.flutter.dev/deployment/android
- Product Flavors: https://medium.com/flutter-community/flutter-android-flavors-a4c1d840417
- Firebase Setup: https://firebase.google.com/docs/flutter/setup

---

**Última actualización:** 2026-03-02
**Estado:** ⏳ Configuración pendiente
