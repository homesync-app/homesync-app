# 🚀 DEPLOY A STAGING + TEST END-TO-END

## 📋 Status
- ✅ Proyecto Supabase: HomeSync App (tfavamqszdkoeabpyxms)
- ✅ URL Staging: https://tfavamqszdkoeabpyxms.supabase.co/api
- ✅ Cliente Flutter configurado para staging
- ⏳ Tests pendientes

---

## 🎯 OBJETIVO

Validar la arquitectura bajo **condiciones reales** antes de producción.

**NO testear en local. NO agregar más features.**

---

## 🧭 ORDEN EJECUTIVO

### PASO 1: Deploy Backend a Staging

#### 1.1 Configuración del Backend

[ ] Verificar que Supabase está listo para staging
[ ] Configurar CORS para permitir requests desde mobile
[ ] Configurar rate limiting activo
[ ] Configurar logs estructurados
[ ] Verificar que idempotency storage está activo (no in-memory)

#### 1.2 Deploy Real

```bash
# Ejemplo de deploy (ajustar según tu setup)
# Asumiendo que el backend usa Supabase como BaaS

# 1. Aplicar migrations a staging
supabase db push --project-url https://tfavamqszdkoeabpyxms.supabase.co

# 2. Verificar deployment
curl https://tfavamqszdkoeabpyxms.supabase.co/api/health
```

#### 1.3 Verificación Post-Deploy

[ ] `/health` endpoint responde 200
[ ] Variables de entorno configuradas correctamente
[ ] Rate limiting activo
[ ] Logs activados
[ ] HTTPS funcionando

---

### PASO 2: Apuntar Flutter a Staging

Ya configurado en `lib/config/app_environment.dart`:

```dart
static const Environment current = Environment.staging;

static String get baseUrl {
  switch (current) {
    case Environment.staging:
      return 'https://tfavamqszdkoeabpyxms.supabase.co/api';
    ...
  }
}
```

[ ] Verificar que `current = Environment.staging` está activo
[ ] Limpiar cache de Flutter: `flutter clean`
[ ] Reinstalar dependencias: `flutter pub get`
[ ] Ejecutar app: `flutter run`

---

### PASO 3: Ejecutar Tests Reales

#### 🔥 TEST 1: Refresh Real

**Objetivo:** Validar auto-refresh bajo condiciones reales

**Pasos:**
1. Login exitoso
2. Esperar 15 minutos (o simular token expirado)
3. Forzar 401 navegando a tareas
4. Verificar auto-refresh automático
5. Confirmar que no se pierde estado

**Expected Results:**
- ✅ Cliente detecta 401
- ✅ Llama a `/auth/refresh` automáticamente
- ✅ Guarda nuevos tokens (rotación segura)
- ✅ Reintenta request original
- ✅ Usuario no nota nada (transparente)

**Console Logs:**
```
⚠️ 401 Unauthorized - Attempting token refresh...
✅ Tokens refreshed successfully
✅ Request retried with new token
```

**Validation:**
- [ ] 401 detectado
- [ ] Refresh automático ejecutado
- [ ] Tokens rotados correctamente
- [ ] Request original reintentado exitosamente
- [ ] Usuario no vio error

---

#### 🔥 TEST 2: Doble Tap Idempotente

**Objetivo:** Validar idempotencia bajo condiciones reales

**Pasos:**
1. Crear tarea
2. Tap rápido dos veces en "Completar" (simular mobile double tap)
3. Observar comportamiento

**Expected Results:**
- ✅ Primer tap: Task completada exitosamente
- ✅ Segundo tap: Detecta idempotency replay
- ✅ Solo una mutación en backend
- ✅ Response con header `X-Idempotency-Key-Status: replay`
- ✅ NO se otorgan XP/Coins dobles
- ✅ UI no duplica estado

**Response Headers:**
```
X-Idempotency-Key-Status: replay
```

**Validation:**
- [ ] Primer request: 200 OK
- [ ] Segundo request: 200 OK (no 409)
- [ ] Header idempotency replay presente
- [ ] Solo una entrada en ledger
- [ ] XP/Coins no duplicados
- [ ] UI muestra solo una tarea completada

---

#### 🔥 TEST 3: Rate Limit Real

**Objetivo:** Validar rate limiting bajo condiciones reales

**Pasos:**
1. Crear script o hacer 60+ requests manualmente
2. Observar comportamiento cuando se excede el límite
3. Verificar headers de rate limit

**Expected Results:**
- ✅ Primeras 60 requests: 200 OK
- ✅ Request 61+: 429 Rate Limit Exceeded
- ✅ Headers `X-RateLimit-*` presentes
- ✅ Cliente muestra mensaje claro
- ✅ UX informada (no confusa)

**Response Headers:**
```
HTTP/1.1 429 Too Many Requests
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1708166400
```

**Response Body:**
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded (61/60 requests)",
    "details": {
      "limit": 60,
      "windowMs": 60000,
      "resetAt": "2026-02-17T12:01:00.000Z",
      "currentCount": 61,
      "tier": "free"
    }
  }
}
```

**Validation:**
- [ ] Rate limit activo
- [ ] Headers correctos
- [ ] 429 response correcta
- [ ] Mensaje de error claro
- [ ] UX informada

---

#### 🔥 TEST 4: Kill App en Medio de Request

**Objetivo:** Validar comportamiento ante interrupciones

**Pasos:**
1. Iniciar POST (ej: crear tarea)
2. Cerrar app mientras está en proceso
3. Reabrir app
4. Verificar estado

**Expected Results:**
- ✅ Request pendiente no se duplica
- ✅ Idempotency key previene duplicación
- ✅ Estado consistente
- ✅ No hay datos corruptos

**Validation:**
- [ ] App cierra correctamente
- [ ] Request no duplicado
- [ ] Estado consistente después de reabrir
- [ ] No hay ledger entries duplicados

---

#### 🔥 TEST 5: Simular Mala Red

**Objetivo:** Validar comportamiento en condiciones móviles reales

**Pasos:**
1. Activar Network Link Conditioner (macOS) o Charles Proxy
2. Configurar:
   - 3G / 2G
   - Latencia 500ms+
   - Packet loss 1-5%
3. Ejecutar operaciones:
   - Login
   - Crear tarea
   - Completar tarea
4. Observar comportamiento

**Expected Results:**
- ✅ App no crashea
- ✅ Errores de red manejados correctamente
- ✅ Timeout apropiado (30s)
- ✅ UX clara sobre problemas de red

**Validation:**
- [ ] App maneja latencia alta
- [ ] App maneja packet loss
- [ ] Timeout funciona
- [ ] Errores mostrados claramente
- [ ] UX no confunde al usuario

---

## 🚨 TESTS DE CONDICIONES EXTREMAS

### TEST 6: Concurrent Requests

**Objetivo:** Validar race conditions

**Pasos:**
1. Crear 5 tareas simultáneas
2. Completarlas casi simultáneamente
3. Observar comportamiento

**Expected Results:**
- ✅ No hay race conditions
- ✅ Idempotency previene duplicación
- ✅ Ledger consistente

**Validation:**
- [ ] No hay datos duplicados
- [ ] Ledger consistente
- [ ] Balances correctos

---

### TEST 7: Token Rotation Attack

**Objetivo:** Validar seguridad de refresh tokens

**Pasos:**
1. Login
2. Copiar refresh token
3. Hacer refresh (token rota)
4. Intentar usar refresh token anterior

**Expected Results:**
- ✅ Refresh token anterior rechazado
- ✅ Security enfoque previene reuso
- ✅ Logout automático

**Validation:**
- [ ] Refresh antiguo no funciona
- [ ] Security valida tokens
- [ ] Logout automático

---

## 📊 CHECKLIST COMPLETO

### Deployment
- [ ] Supabase staging listo
- [ ] CORS configurado
- [ ] Rate limiting activo
- [ ] Logs estructurados
- [ ] HTTPS funcionando
- [ ] Flutter apuntando a staging

### Tests Core
- [ ] Test 1: Refresh real ✅
- [ ] Test 2: Doble tap idempotente ✅
- [ ] Test 3: Rate limit real ✅
- [ ] Test 4: Kill app mid-request ✅
- [ ] Test 5: Mala red simulada ✅

### Tests Extremos
- [ ] Test 6: Concurrent requests ✅
- [ ] Test 7: Token rotation attack ✅

### Observabilidad
- [ ] Logs estructurados presentes
- [ ] Request ID tracking funciona
- [ ] Error logs capturados
- [ ] Performance logs capturados

---

## 🎯 CRITERIOS DE ÉXITO

El staging es exitoso si:

1. **✅ Auth Flow Robusto**
   - Login, refresh, logout funcionan
   - Auto-refresh transparente
   - Token rotation segura

2. **✅ Idempotencia Real**
   - Doble submit NO causa efectos duplicados
   - Headers de idempotency correctos
   - Ledger inmutable

3. **✅ Rate Limiting Funcional**
   - 429 se detecta y maneja
   - Headers informativos
   - UX clara

4. **✅ Mobile-Ready**
   - Maneja mala red
   - Maneja timeouts
   - Maneja interrupciones
   - No crashea

5. **✅ Observabilidad**
   - Logs estructurados
   - Request ID tracking
   - Debugging eficiente

---

## 📝 RESULTADOS ESPERADOS

**Si todos los tests pasan:**
- ✅ Arquitectura validada
- ✅ Mobile-ready confirmado
- ✅ Production-ready técnico
- ✅ Listo para implementar retry/backoff
- ✅ Listo para producción

**Si algún test falla:**
- 📝 Documentar el fallo
- 🔧 Corregir el problema
- 🔄 Re-ejecutar tests
- 📈 Mejorar arquitectura

---

## 🚀 PRÓXIMOS PASOS DESPUÉS DE STAGING EXITOSO

1. **Implementar Retry con Exponential Backoff**
   - Retry en 429 con wait time apropiado
   - Retry en network errors con backoff
   - Jitter para evitar thundering herd

2. **Agregar Queue Offline Mínima**
   - Cache local de requests fallidos
   - Reintentar cuando conexión vuelve
   - Queue FIFO con prioridad

3. **Replicar Patrón Dorado**
   - Aplicar a todos los endpoints
   - Consistencia en todo el API

4. **Preparar Producción**
   - Configurar dominio real
   - Configurar SSL cert
   - Configurar monitoring real
   - Configurar alerts reales

---

## 📞 CONTACTO DE SOPORTE

Si encuentras problemas críticos:
- Revisar logs de Supabase
- Revisar console logs de Flutter
- Documentar el problema
- Contactar al equipo de backend

---

## ✅ CONCLUSIÓN

**Este es el momento crítico:**

De arquitectura teórica → producto validado bajo estrés real.

**NO skipear este paso.**
**NO testear en local.**
**NO agregar más features.**

Primero validación real. Después optimizaciones.

🚀 **VAMOS A VALIDAR ESTO.**
