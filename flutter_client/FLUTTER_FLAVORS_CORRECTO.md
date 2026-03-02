# 📦 FLUTTER FLAVORS - CONFIGURACIÓN CORRECTA

**Fecha:** 2026-03-02
**Estado:** ⏳ Pendiente de configurar

---

## ❌ ERROR COMÚN

### Qué NO hacer
```
❌ NO configurar flavors en pubspec.yaml
   ❌ flutter:
       ❌   staging: ...
       ❌   production: ...
```

**Por qué no:**
- Flutter NO soporta flavors en pubspec.yaml
- Genera error: "Unexpected child 'staging' found under 'flutter'"
- Los flavors se configuran en Android (build.gradle)

---

## ✅ CONFIGURACIÓN CORRECTA

### Paso 1: Configurar Android Build Gradle

Editar: `android/app/build.gradle`

```gradle
android {
    defaultConfig {
        applicationId "com.homesync.staging" // Default flavor
    }
    
    flavorDimensions "environment"
    productFlavors {
        staging {
            dimension "environment"
            applicationId "com.homesync.staging"
            resValue "string/app_name", "HomeSync Staging"
            versionNameSuffix "-staging"
            
            // Variables de entorno para Flutter
            buildConfigField "String", "ENVIRONMENT", '"staging"'
            buildConfigField "String", "SUPABASE_URL", '"https://tfavamqszdkoeabpyxms.supabase.co"'
        }
        
        production {
            dimension "environment"
            applicationId "com.homesync.app"
            resValue "string/app_name", "HomeSync"
            
            // Variables de entorno para Flutter
            buildConfigField "String", "ENVIRONMENT", '"production"'
            buildConfigField "String", "SUPABASE_URL", '"https://api.homesync.com"'
        }
    }
}
```

---

### Paso 2: Configurar Strings por Flavor

Crear: `android/app/src/staging/res/values/strings.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">HomeSync Staging</string>
</resources>
```

Crear: `android/app/src/production/res/values/strings.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">HomeSync</string>
</resources>
```

---

### Paso 3: Leer Variables de Entorno en Flutter

Editar: `flutter_client/lib/config/app_environment.dart`

```dart
enum Environment {
  local,
  staging,
  production;
}

class AppEnvironment {
  static const Environment current = Environment.staging;

  static String get environment {
    return const String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'local',
    );
  }

  static Environment get env {
    switch (environment) {
      case 'staging':
        return Environment.staging;
      case 'production':
        return Environment.production;
      case 'local':
      default:
        return Environment.local;
    }
  }

  static String get supabaseUrl {
    switch (env) {
      case Environment.local:
        return 'http://localhost:54321';
      case Environment.staging:
        return const String.fromEnvironment(
          'SUPABASE_URL',
          defaultValue: 'https://tfavamqszdkoeabpyxms.supabase.co',
        );
      case Environment.production:
        return const String.fromEnvironment(
          'SUPABASE_URL',
          defaultValue: 'https://api.homesync.com',
        );
    }
  }

  static String get supabaseAnonKey {
    switch (env) {
      case Environment.local:
        return 'YOUR_LOCAL_ANON_KEY';
      case Environment.staging:
        return const String.fromEnvironment(
          'SUPABASE_ANON_KEY',
          defaultValue: 'YOUR_STAGING_ANON_KEY',
        );
      case Environment.production:
        return const String.fromEnvironment(
          'SUPABASE_ANON_KEY',
          defaultValue: 'YOUR_PRODUCTION_ANON_KEY',
        );
    }
  }
}
```

---

## 🚀 COMANDOS DE BUILD

### Build Staging APK
```bash
flutter build apk --release --flavor staging

# APK generado en:
# build/app/outputs/flutter-apk/app-staging-release.apk
```

### Build Production APK
```bash
flutter build apk --release --flavor production

# APK generado en:
# build/app/outputs/flutter-apk/app-production-release.apk
```

### Build Staging App Bundle
```bash
flutter build appbundle --release --flavor staging
```

### Build Production App Bundle
```bash
flutter build appbundle --release --flavor production
```

---

## 🎯 COMANDOS PARA GITHUB ACTIONS

### Tests (sin flavor específico)
```yaml
- name: Run tests
  run: flutter test
```

### Build Staging APK
```yaml
- name: Build Staging APK
  run: flutter build apk --release --flavor staging
```

### Build Production APK
```yaml
- name: Build Production APK
  run: flutter build apk --release --flavor production
```

---

## 📋 CHECKLIST DE VERIFICACIÓN

### Configuración Android
- [ ] build.gradle configurado con flavorDimensions
- [ ] productFlavors: staging configurado
- [ ] productFlavors: production configurado
- [ ] buildConfigField para ENVIRONMENT agregado
- [ ] buildConfigField para SUPABASE_URL agregado

### Strings por Flavor
- [ ] android/app/src/staging/res/values/strings.xml creado
- [ ] android/app/src/production/res/values/strings.xml creado
- [ ] app_name correcto en staging
- [ ] app_name correcto en production

### Configuración Flutter
- [ ] app_environment.dart actualizado
- [ ] Leer variable ENVIRONMENT desde buildConfigField
- [ ] Leer variable SUPABASE_URL desde buildConfigField
- [ ] Env actual por defecto: Environment.staging

### Verificación de Builds
- [ ] flutter build apk --release --flavor staging funciona
- [ ] flutter build apk --release --flavor production funciona
- [ ] APK de staging tiene nombre "HomeSync Staging"
- [ ] APK de production tiene nombre "HomeSync"
- [ ] applicationId correcto en staging (com.homesync.staging)
- [ ] applicationId correcto en production (com.homesync.app)

---

## 🐛 SOLUCIÓN DE PROBLEMAS

### Problema 1: Error "Unexpected child 'staging' found under 'flutter'"
```
Solución:
1. Remover configuración de flavors de pubspec.yaml
2. Solo configurar en android/app/build.gradle
3. pubspec.yaml debe tener solo:
   flutter:
     uses-material-design: true
     assets: ...
```

### Problema 2: App no lee variables de entorno
```
Solución:
1. Verificar que buildConfigField está en build.gradle
2. Verificar que se usa String.fromEnvironment en Dart
3. Verificar que se usa const String.fromEnvironment
```

### Problema 3: APK tiene nombre incorrecto
```
Solución:
1. Verificar strings.xml en cada flavor
2. Verificar que resValue está en build.gradle
3. Limpiar: flutter clean
4. Rebuild: flutter build apk --flavor X
```

---

## 📚 REFERENCIAS

- Flutter Product Flavors: https://docs.flutter.dev/deployment/flavors
- Android Build Config: https://developer.android.com/studio/build
- Environment Variables: https://docs.flutter.dev/cookbook/networking

---

**Última actualización:** 2026-03-02
**Estado:** ⏳ Pendiente de configurar
