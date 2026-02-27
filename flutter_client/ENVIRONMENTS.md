# 🔧 CONFIGURACIÓN DE ENTORNOS

## 📋 Resumen

Este proyecto tiene soporte para múltiples entornos:
- **Local**: Desarrollo local (http://localhost:3000)
- **Staging**: Validación real (https://tfavamqszdkoeabpyxms.supabase.co/api)
- **Production**: Producción (https://api.homesync.com/api)

---

## 🚀 Cómo Cambiar de Entorno

### Opción 1: Cambiar en Código

Editar `lib/config/app_environment.dart`:

```dart
static const Environment current = Environment.staging; // Cambiar a local, staging, o production
```

### Opción 2: Usar Build Flavor (Recomendado para producción)

```bash
# Staging
flutter run --dart-define=ENVIRONMENT=staging

# Production
flutter run --dart-define=ENVIRONMENT=production

# Local
flutter run --dart-define=ENVIRONMENT=local
```

**Nota:** Build flavors requieren configuración adicional en el proyecto.

---

## 📋 Configuración por Entorno

### Local (Desarrollo)

**URL:** `http://localhost:3000/api`

**Uso:**
- Desarrollo local
- Testing de features nuevas
- Debugging con hot reload

**Backend:**
- Server local (ej: Node.js, Express)
- Database local o staging de Supabase

---

### Staging (Validación)

**URL:** `https://tfavamqszdkoeabpyxms.supabase.co/api`

**Uso:**
- Validación end-to-end
- Testing con condiciones reales
- Pre-producción

**Backend:**
- Supabase real
- HTTPS real
- Rate limiting real
- Idempotency real

**Tests:**
- Refresh real
- Doble tap idempotente
- Rate limit real
- Kill app mid-request
- Mala red simulada
- Concurrent requests
- Token rotation attack

---

### Production

**URL:** `https://api.homesync.com/api`

**Uso:**
- Producción real
- Usuarios finales
- Analytics reales

**Backend:**
- Infraestructura dedicada
- Monitoring completo
- Alerting completo
- Backup completo

---

## 🔧 Configuración Detallada

### AppEnvironment Class

Ubicación: `lib/config/app_environment.dart`

```dart
class AppEnvironment {
  static const Environment current = Environment.staging;

  static String get baseUrl {
    switch (current) {
      case Environment.local:
        return 'http://localhost:3000/api';
      case Environment.staging:
        return 'https://tfavamqszdkoeabpyxms.supabase.co/api';
      case Environment.production:
        return 'https://api.homesync.com/api';
    }
  }

  static String get apiUrl {
    switch (current) {
      case Environment.local:
        return 'http://localhost:3000';
      case Environment.staging:
        return 'https://tfavamqszdkoeabpyxms.supabase.co';
      case Environment.production:
        return 'https://api.homesync.com';
    }
  }

  static bool get isLocal => current == Environment.local;
  static bool get isStaging => current == Environment.staging;
  static bool get isProduction => current == Environment.production;
}

enum Environment {
  local,
  staging,
  production,
}
```

---

## 🧪 Testing por Entorno

### Testing en Local

```bash
# 1. Configurar entorno a local
# Editar lib/config/app_environment.dart
static const Environment current = Environment.local;

# 2. Limpiar cache
flutter clean

# 3. Instalar dependencias
flutter pub get

# 4. Ejecutar
flutter run
```

**Tests:**
- Unit tests
- Integration tests básicos
- UI tests básicos

---

### Testing en Staging

```bash
# 1. Configurar entorno a staging
# Editar lib/config/app_environment.dart
static const Environment current = Environment.staging;

# 2. Limpiar cache
flutter clean

# 3. Instalar dependencias
flutter pub get

# 4. Ejecutar
flutter run
```

**Tests:**
- E2E tests reales
- Refresh real
- Idempotencia real
- Rate limiting real
- Network conditions
- Mobile-specific behaviors

---

### Testing en Production

```bash
# 1. Configurar entorno a production
# Editar lib/config/app_environment.dart
static const Environment current = Environment.production;

# 2. Build para producción
flutter build apk --release
# o
flutter build ios --release

# 3. Deploy a Play Store / App Store
```

**Tests:**
- Smoke tests
- Monitoring
- Analytics
- User feedback

---

## 📊 Variables de Configuración

### Variables de Backend

| Variable | Local | Staging | Production |
|----------|-------|---------|------------|
| API URL | http://localhost:3000/api | https://tfavamqszdkoeabpyxms.supabase.co/api | https://api.homesync.com/api |
| HTTPS | ❌ | ✅ | ✅ |
| Rate Limiting | ❌ | ✅ | ✅ |
| Idempotency | ✅ | ✅ | ✅ |
| Observabilidad | ✅ | ✅ | ✅ |

### Variables de Flutter

| Variable | Local | Staging | Production |
|----------|-------|---------|------------|
| Debug Mode | ✅ | ✅ | ❌ |
| Console Logs | ✅ | ✅ | ❌ |
| Analytics | ❌ | ❌ | ✅ |
| Crash Reporting | ❌ | ✅ | ✅ |

---

## 🔒 Seguridad por Entorno

### Local
- Sin HTTPS
- Sin auth real (opcional)
- Logs detallados

### Staging
- HTTPS real
- Auth real
- Rate limiting activo
- Logs detallados

### Production
- HTTPS real
- Auth real
- Rate limiting activo
- Logs minimizados
- Analytics activos
- Crash reporting activos

---

## 📝 Best Practices

### Development
1. **Usar local** para desarrollo de features
2. **Usar staging** para validación E2E
3. **Usar production** solo para deployment final

### Testing
1. **Unit tests**: Cualquier entorno
2. **Integration tests**: Staging
3. **E2E tests**: Staging
4. **Smoke tests**: Production

### Deployment
1. **Never deploy directly** de local a production
2. **Always go through staging**
3. **Always test** en staging antes de production

---

## 🚨 Common Issues

### Issue: App no conecta a backend

**Solución:**
1. Verificar que el entorno es correcto en `lib/config/app_environment.dart`
2. Verificar que el backend está corriendo
3. Verificar conexión de red
4. Limpiar cache: `flutter clean`

---

### Issue: Tests fallan en staging pero pasan en local

**Causas comunes:**
- Latencia real
- HTTPS/TLS
- CORS
- Rate limiting
- Network conditions

**Solución:**
1. Revisar logs de backend
2. Revisar console logs de Flutter
3. Simular condiciones de red en local
4. Ajustar timeouts si necesario

---

## 📞 Soporte

Para problemas de configuración:
- Revisar `lib/config/app_environment.dart`
- Revisar `STAGING_DEPLOY_CHECKLIST.md`
- Revisar logs del backend
- Revisar console logs de Flutter

---

## ✅ Checklist de Cambio de Entorno

Antes de cambiar de entorno:

- [ ] Backup del código
- [ ] Commits hechos
- [ ] Tests pasados en entorno actual
- [ ] Documentación actualizada
- [ ] Team informado

Después de cambiar de entorno:

- [ ] `flutter clean`
- [ ] `flutter pub get`
- [ ] Tests de sanity
- [ ] Logs revisados
- [ ] Funcionalidad verificada

---

## 🎯 Conclusión

**Staging es el entorno crítico.**

Es donde:
- ✅ Validamos arquitectura real
- ✅ Encontramos bugs reales
- ✅ Probamos condiciones móviles
- ✅ Preparamos para producción

**Nunca saltear staging.**
**Nunca deploy directo a production.**

🚀 **Validación real primero. Producción después.**
