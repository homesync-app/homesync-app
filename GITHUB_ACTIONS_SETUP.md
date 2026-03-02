# 🚀 SETUP GITHUB ACTIONS & STAGING

**Fecha:** 2026-03-02
**Estado:** ⏳ Configuración en progreso

---

## ✅ PASO 1: CONFIGURAR SECRETS EN GITHUB

### Secrets Necesarios

Ir a: https://github.com/[TU_REPO]/settings/secrets/actions

Crear los siguientes secrets:

#### 1. SUPABASE_STAGING_URL
```
Valor: https://tfavamqszdkoeabpyxms.supabase.co
```

#### 2. SUPABASE_STAGING_ANON_KEY
```
Valor: TU_ANON_KEY_DE_SUPABASE_STAGING

Cómo obtenerlo:
1. Ir a https://supabase.com/dashboard/project/tfavamqszdkoeabpyxms/settings/api
2. Copiar "anon public" key
```

#### 3. GITHUB_TOKEN
```
Valor: AUTOMÁTICO (no es necesario crearlo)

GitHub Actions lo provee automáticamente
para poder crear releases y subir artifacts
```

#### 4. SLACK_WEBHOOK (OPCIONAL)
```
Valor: TU_WEBHOOK_DE_SLACK

Cómo obtenerlo:
1. Ir a Slack > Apps > Incoming Webhooks
2. Crear nuevo webhook
3. Copiar URL del webhook
```

#### 5. TEAMS_WEBHOOK (OPCIONAL)
```
Valor: TU_WEBHOOK_DE_TEAMS

Cómo obtenerlo:
1. Ir a Teams > Apps > Incoming Webhooks
2. Crear nuevo webhook
3. Copiar URL del webhook
```

---

## ✅ PASO 2: CONFIGURAR FLAVORS EN ANDROID

### 2.1 Modificar android/app/build.gradle

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
        }
        
        production {
            dimension "environment"
            applicationId "com.homesync.app"
            resValue "string/app_name", "HomeSync"
        }
    }
}
```

### 2.2 Configurar environment-specific values

Crear `android/app/src/staging/res/values/strings.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">HomeSync Staging</string>
</resources>
```

Crear `android/app/src/production/res/values/strings.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">HomeSync</string>
</resources>
```

---

## ✅ PASO 3: CONFIGURAR AMBIENTE EN FLUTTER

### 3.1 Modificar lib/config/app_environment.dart

```dart
enum Environment {
  local,
  staging,
  production;
}

class AppEnvironment {
  static const Environment current = Environment.staging;

  static String get supabaseUrl {
    switch (current) {
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
    switch (current) {
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

## ✅ PASO 4: EJECUTAR SETUP INICIAL

### 4.1 Crear directorio de workflows
```bash
mkdir -p .github/workflows
```

### 4.2 Verificar archivos creados
```bash
ls -la .github/workflows/
# Debe mostrar:
# - tests.yml
# - deploy-staging.yml
```

### 4.3 Verificar secrets configurados
```bash
# Ir a: https://github.com/[TU_REPO]/settings/secrets/actions
# Verificar que existen:
# - SUPABASE_STAGING_URL
# - SUPABASE_STAGING_ANON_KEY
```

---

## ✅ PASO 5: PRIMER DEPLOY A STAGING

### 5.1 Hacer commit de configuración
```bash
git add .github/
git add android/app/build.gradle
git add lib/config/app_environment.dart
git add pubspec.yaml
git commit -m "ci: add GitHub Actions and staging configuration"
git push origin main
```

### 5.2 Verificar GitHub Actions
1. Ir a: https://github.com/[TU_REPO]/actions
2. Verificar que workflows se ejecutan:
   - Flutter Tests (debe pasar)
   - Deploy to Staging (debe pasar)
3. Esperar a que termine el workflow de deploy
4. Descargar APK del artifact
5. Instalar en dispositivo
6. Testear app

---

## 🎯 VERIFICACIÓN POST-DEPLOY

### Checklist de Verificación

#### GitHub Actions
- [ ] Workflow "Flutter Tests" ejecutó exitosamente
- [ ] Workflow "Deploy to Staging" ejecutó exitosamente
- [ ] APK generado exitosamente
- [ ] APK subido como artifact
- [ ] GitHub Release creada
- [ ] Notificación enviada (Slack/Teams)

#### APK Instalado
- [ ] APK se instaló correctamente
- [ ] App se abre sin errores
- [ ] Login funciona
- [ ] Conexión a Supabase Staging funciona
- [ ] Se conecta al ambiente correcto (staging)

#### Tests Manuales
- [ ] Test 1: Refresh Real
- [ ] Test 2: Doble Tap Idempotente
- [ ] Test 3: Rate Limit Real
- [ ] Test 4: Kill App Mid-Request
- [ ] Test 5: Simular Mala Red
- [ ] Test 6: Concurrent Requests
- [ ] Test 7: Token Rotation Attack
- [ ] Test 8: Flujo Onboarding
- [ ] Test 9: Integración Realtime
- [ ] Test 10: Error Handling

---

## 🔧 COMANDOS ÚTILES

### Construir APK de Staging Localmente
```bash
flutter build apk --release --flavor staging
```

### Construir APK de Production Localmente
```bash
flutter build apk --release --flavor production
```

### Correr Tests
```bash
flutter test
flutter test integration_test/
```

### Ver GitHub Actions Logs
```bash
# En la web:
https://github.com/[TU_REPO]/actions

# En CLI:
gh run list
gh run view [RUN_ID]
```

---

## 📚 RECURSOS ÚTILES

### Documentación
- GitHub Actions: https://docs.github.com/en/actions
- Flutter Deployment: https://docs.flutter.dev/deployment
- Supabase Flutter: https://supabase.com/docs/guides/getting-started/flutter

### Herramientas
- Network Link Conditioner (macOS): Simular mala red
- Charles Proxy: Debugging de HTTP
- Firebase App Distribution: Distribución de APKs

---

## 🐛 SOLUCIÓN DE PROBLEMAS COMUNES

### Problema 1: Tests fallan en GitHub Actions
```
Solución:
1. Verificar logs en GitHub Actions
2. Verificar que flutter test funciona localmente
3. Verificar versiones de Flutter y Dart
```

### Problema 2: Build falla en GitHub Actions
```
Solución:
1. Verificar que flutter build apk funciona localmente
2. Verificar configuración de Android build.gradle
3. Verificar que dependencies están en pubspec.yaml
```

### Problema 3: Secrets no funcionan
```
Solución:
1. Verificar que secrets existen en GitHub
2. Verificar que nombres coinciden exactamente
3. Verificar que no hay espacios en blanco
```

### Problema 4: APK no se puede instalar
```
Solución:
1. Verificar que flavor está configurado correctamente
2. Verificar que applicationId es correcto
3. Verificar que APK no está corrupto
```

---

## 📝 NOTAS

- **Persona de configuración:** [TU NOMBRE]
- **Fecha de configuración:** 2026-03-02
- **Próxima revisión:** Después del primer deploy exitoso
- **Repositorio:** [TU_REPO]

---

**Estado Actual:** ⏳ Configuración en progreso
**Próximo Paso:** Configurar secrets en GitHub
