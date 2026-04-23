# 🧪 STAGING TESTS - Manual Testing Checklist

**Fecha:** 2026-03-02
**URL Staging:** https://tfavamqszdkoeabpyxms.supabase.co
**GitHub Actions:** ✅ Configurados

---

## 📋 PRE-TESTING SETUP

### 1. Descargar APK de Staging
```
1. Ir a: https://github.com/[TU_REPO]/actions
2. Seleccionar workflow "Deploy to Staging"
3. Hacer click en el último run exitoso
4. Descargar artifact: homesync-staging-apk
5. Instalar en dispositivo Android
```

### 2. Crear Cuenta de Prueba
```
Email: staging-test-1@example.com
Password: StagingTest123!
```

---

## 🔴 TEST 1: REFRESH REAL (CRÍTICO)

### Objetivo
Validar auto-refresh bajo condiciones reales de token expiración

### Pasos
```
1. Abrir app
2. Login con cuenta de prueba
3. Esperar 15 minutos (o simular token expirado)
   - Opcional: Cambiar token expiración a 1 minuto en backend
4. Intentar hacer cualquier request:
   - Navegar a pantalla de tareas
   - Intentar crear una tarea
5. Observar comportamiento
```

### Expected Results
- ✅ Cliente detecta 401 Unauthorized
- ✅ Cliente llama a `/auth/refresh` automáticamente
- ✅ Cliente guarda nuevos tokens (rotación segura)
- ✅ Cliente reintenta request original
- ✅ Usuario no nota nada (transparente)
- ✅ App NO crashea
- ✅ App NO muestra error

### Console Logs esperados
```
⚠️ 401 Unauthorized - Attempting token refresh...
✅ Tokens refreshed successfully
✅ Request retried with new token
```

### Validation Checklist
- [ ] 401 detectado
- [ ] Refresh automático ejecutado
- [ ] Tokens rotados correctamente
- [ ] Request original reintentado exitosamente
- [ ] Usuario no vio error ni glitch
- [ ] App se mantuvo funcional

### Screenshots
- Antes de refresh:
- Después de refresh:

---

## 🔴 TEST 2: DOBLE TAP IDEMPOTENTE (CRÍTICO)

### Objetivo
Validar idempotencia bajo condiciones reales de double tap en mobile

### Pasos
```
1. Login con cuenta de prueba
2. Navegar a pantalla de tareas
3. Crear una tarea de prueba
4. Dar doble tap rápido en botón "Completar"
   - Simular: Tap rápido dos veces en <200ms
5. Observar comportamiento
```

### Expected Results
- ✅ Primer tap: Task completada exitosamente
- ✅ Segundo tap: Detecta idempotency replay
- ✅ Solo una mutación en backend
- ✅ Response con header `X-Idempotency-Key-Status: replay`
- ✅ NO se otorgan XP/Coins dobles
- ✅ UI muestra solo una tarea completada
- ✅ App NO se confunde

### Response esperado (segundo tap)
```json
{
  "success": true,
  "data": {
    "status": "pending_verification",
    "message": "Task already completed",
    "idempotencyKey": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

### Validation Checklist
- [ ] Primer request: 200 OK
- [ ] Segundo request: 200 OK (NO 409)
- [ ] Header idempotency replay presente
- [ ] Solo una entrada en ledger
- [ ] XP/Coins NO duplicados
- [ ] UI muestra solo una tarea completada
- [ ] Ledger balance correcto

### Screenshots
- Lista de tareas antes:
- Lista de tareas después:

---

## 🔴 TEST 3: RATE LIMIT REAL (CRÍTICO)

### Objetivo
Validar rate limiting bajo condiciones reales de carga

### Pasos
```
1. Login con cuenta de prueba
2. Usar herramienta (Postman/curl) para hacer requests rápidos:
   ```bash
   # Hacer 65 requests en <1 minuto
   for i in {1..65}; do
     curl -X POST https://tfavamqszdkoeabpyxms.supabase.co/rest/v1/rpc/get_tasks \
       -H "apikey: YOUR_ANON_KEY" \
       -H "Content-Type: application/json" \
       -d '{}'
     sleep 0.8
   done
   ```
3. Observar comportamiento en request 61+
```

### Expected Results
- ✅ Primeras 60 requests: 200 OK
- ✅ Request 61+: 429 Rate Limit Exceeded
- ✅ Headers `X-RateLimit-*` presentes
- ✅ Cliente muestra mensaje claro de espera
- ✅ UX informada (no confusa)

### Response esperado (request 61+)
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded (61/60 requests)",
    "details": {
      "limit": 60,
      "windowMs": 60000,
      "resetAt": "2026-03-02T12:01:00.000Z",
      "currentCount": 61
    }
  }
}
```

### Validation Checklist
- [ ] Rate limit activo
- [ ] Headers correctos:
  - [ ] X-RateLimit-Limit: 60
  - [ ] X-RateLimit-Remaining: 0
  - [ ] X-RateLimit-Reset: timestamp
- [ ] 429 response correcta
- [ ] Mensaje de error claro en UI
- [ ] UX no confusa para usuario

### Screenshots
- Primeros 60 requests (200 OK):
- Request 61+ (429):

---

## 🔴 TEST 4: KILL APP MID-REQUEST (CRÍTICO)

### Objetivo
Validar comportamiento ante interrupciones abruptas

### Pasos
```
1. Login con cuenta de prueba
2. Navegar a crear tarea
3. Iniciar creación de tarea:
   - Llenar formulario
   - Click en "Crear tarea"
4. Mientras carga (loading spinner):
   - Cerrar app completamente (swipe up desde multitasking)
5. Esperar 5 segundos
6. Reabrir app
7. Navegar a tareas
```

### Expected Results
- ✅ Request pendiente NO se duplica
- ✅ Idempotency key previene duplicación
- ✅ Estado consistente
- ✅ NO hay datos corruptos
- ✅ Tarea creada correctamente o no creada (consistente)

### Validation Checklist
- [ ] App cierra correctamente
- [ ] Request NO duplicado (no 2 tareas iguales)
- [ ] Estado consistente después de reabrir
- [ ] NO hay ledger entries duplicados
- [ ] App se reabre sin errores
- [ ] Estado de tareas consistente

### Screenshots
- Antes de cerrar app:
- Después de reabrir app:

---

## 🔴 TEST 5: SIMULAR MALA RED (CRÍTICO)

### Objetivo
Validar comportamiento en condiciones móviles reales de mala red

### Pasos
```
1. Usar Network Link Conditioner (macOS) o Charles Proxy:
   - Configurar:
     * Red: 3G
     * Latencia: 500ms
     * Packet Loss: 2%
     * Bandwidth: 1 Mbps
2. Login con cuenta de prueba
3. Ejecutar operaciones:
   - Login
   - Navegar a tareas
   - Crear tarea
   - Completar tarea
   - Ver gastos
4. Observar comportamiento
```

### Expected Results
- ✅ App NO crashea
- ✅ Errores de red manejados correctamente
- ✅ Timeout apropiado (30s)
- ✅ UX clara sobre problemas de red
- ✅ Loading states visibles
- ✅ Retry automático (si está implementado)
- ✅ Mensajes de error claros

### Validation Checklist
- [ ] App maneja latencia alta sin crashear
- [ ] App maneja packet loss sin crashear
- [ ] Timeout funciona (30s max)
- [ ] Errores mostrados claramente
- [ ] UX no confunde al usuario
- [ ] Loading states visibles
- [ ] Retry automático funciona (si implementado)

### Screenshots
- Durante timeout:
- Mensaje de error:
- App después de recuperación:

---

## 🔴 TEST 6: CONCURRENT REQUESTS (IMPORTANTE)

### Objetivo
Validar race conditions en operaciones concurrentes

### Pasos
```
1. Login con cuenta de prueba
2. Crear 5 tareas simultáneamente (usando script o multiple tabs)
   - Tarea 1: "Limpieza A"
   - Tarea 2: "Limpieza B"
   - Tarea 3: "Limpieza C"
   - Tarea 4: "Limpieza D"
   - Tarea 5: "Limpieza E"
3. Completar las 5 tareas casi simultáneamente
   - Tap rápido en completar cada una (<500ms entre cada tap)
4. Navegar a gastos/ledger
5. Verificar balances
```

### Expected Results
- ✅ NO hay race conditions
- ✅ Idempotencia previene duplicación
- ✅ Ledger consistente
- ✅ XP/Coins correctos (no duplicados)
- ✅ Tareas en estado correcto

### Validation Checklist
- [ ] NO hay datos duplicados
- [ ] Ledger consistente
- [ ] Balances correctos por usuario
- [ ] XP/Coins correctos
- [ ] Tareas en estado correcto
- [ ] NO hay inconsistencies en datos

### Screenshots
- Lista de tareas creadas:
- Ledger después de completar:
- Balances finales:

---

## 🔴 TEST 7: TOKEN ROTATION ATTACK (CRÍTICO)

### Objetivo
Validar seguridad de refresh tokens

### Pasos
```
1. Login con cuenta de prueba
2. Capturar refresh token (desde SharedPreferences o logs)
3. Hacer refresh (token rota):
   - Navegar a cualquier pantalla para forzar refresh
   - O esperar 15 minutos
4. Intentar usar refresh token anterior (capturado en paso 2)
   - Usar curl/Postman:
     ```bash
     curl -X POST https://tfavamqszdkoeabpyxms.supabase.co/auth/v1/token?grant_type=refresh_token \
       -H "apikey: YOUR_ANON_KEY" \
       -H "Content-Type: application/json" \
       -d '{
         "refresh_token": "ANTIGUO_REFRESH_TOKEN"
       }'
     ```
```

### Expected Results
- ✅ Refresh token anterior rechazado
- ✅ Error 401/403
- ✅ App hace logout automático
- ✅ Usuario redirigido a pantalla de login
- ✅ Tokens limpiados localmente
- ✅ Mensaje de error claro

### Response esperado (refresh token antiguo)
```json
{
  "success": false,
  "error": {
    "code": "INVALID_REFRESH_TOKEN",
    "message": "Invalid refresh token"
  }
}
```

### Validation Checklist
- [ ] Refresh antiguo NO funciona
- [ ] Security valida tokens correctamente
- [ ] Logout automático ocurre
- [ ] Tokens limpiados localmente
- [ ] Usuario redirigido a login
- [ ] Mensaje de error claro

### Screenshots
- Error al usar refresh antiguo:
- Pantalla de login (auto logout):

---

## 🟡 TEST 8: FLUJO COMPLETO DE ONBOARDING (IMPORTANTE)

### Objetivo
Validar flujo completo de setup inicial

### Pasos
```
1. Crear nueva cuenta (fresh install)
2. Completar onboarding:
   - Paso 1: Seleccionar modo de uso (Solo/Pareja/Familia)
   - Paso 2: Crear equipo o unirse con código
   - Paso 3: Seleccionar tareas iniciales (templates)
3. Verificar que todo se configura correctamente
4. Cerrar app y reabrir
5. Verificar que NO pide setup de nuevo
```

### Expected Results
- ✅ Onboarding fluye correctamente
- ✅ Creación de hogar funciona
- ✅ Selección de tareas funciona
- ✅ Datos persisten correctamente
- ✅ App no pide setup en reabertura
- ✅ Dashboard muestra tareas seleccionadas

### Validation Checklist
- [ ] Onboarding se completa sin errores
- [ ] Hogar creado correctamente
- [ ] Tareas iniciales creadas
- [ ] Datos persisten en reabertura
- [ ] No pide setup de nuevo
- [ ] Dashboard funcional desde el inicio

### Screenshots
- Paso 1: Modo de uso:
- Paso 2: Equipo:
- Paso 3: Tareas iniciales:
- Dashboard inicial:

---

## 🟡 TEST 9: INTEGRACIÓN SUPABASE REALTIME (IMPORTANTE)

### Objetivo
Validar que actualizaciones realtime funcionan

### Pasos
```
1. Usar 2 dispositivos o 1 dispositivo + navegador
2. Dispositivo 1: Login con cuenta de prueba A
3. Dispositivo 2: Login con cuenta de prueba B (mismo hogar)
4. Dispositivo 1: Crear tarea nueva
5. Dispositivo 2: Verificar que tarea aparece automáticamente
6. Dispositivo 2: Completar tarea
7. Dispositivo 1: Verificar que tarea se marca completada
8. Verificar que XP/Coins se actualizan en ambos
```

### Expected Results
- ✅ Actualizaciones en tiempo real
- ✅ Tareas aparecen automáticamente en dispositivo 2
- ✅ Completaciones se sincronizan
- ✅ XP/Coins se actualizan en ambos
- ✅ NO glitch en UI
- ✅ Transiciones suaves

### Validation Checklist
- [ ] Realtime funciona correctamente
- [ ] Actualizaciones en <3 segundos
- [ ] NO glitches en UI
- [ ] Datos consistentes entre dispositivos
- [ ] XP/Coins sincronizados
- [ ] App mantiene estable

### Screenshots
- Dispositivo 1 (antes):
- Dispositivo 2 (después, en tiempo real):
- Ambos dispositivos (sincronizados):

---

## 🟡 TEST 10: ERROR HANDLING (IMPORTANTE)

### Objetivo
Validar que errores se manejen correctamente

### Pasos
```
1. Login con cuenta de prueba
2. Probar diferentes escenarios de error:

   Escenario A: Credenciales inválidas
   - Intentar login con email/password incorrectos
   - Verificar mensaje de error claro

   Escenario B: Crear tarea sin título
   - Intentar crear tarea sin título
   - Verificar validación en cliente

   Escenario C: Crear gasto negativo
   - Intentar crear gasto con monto negativo
   - Verificar validación

   Escenario D: Canjear premio sin coins
   - Intentar canjear premio sin coins suficientes
   - Verificar mensaje de error

   Escenario E: Error de red
   - Poner app en modo avión
   - Intentar crear tarea
   - Verificar mensaje de error de red
```

### Expected Results
- ✅ Todos los errores tienen mensajes claros
- ✅ No hay errores silenciosos
- ✅ App NO crashea
- ✅ UX no es confusa
- ✅ Mensajes en español
- ✅ Íconos/colores apropiados (error = rojo)

### Validation Checklist
- [ ] Credenciales inválidas: mensaje claro
- [ ] Validaciones en cliente funcionan
- [ ] Error de red: mensaje claro
- [ ] Canje sin coins: mensaje claro
- [ ] NO errors silenciosos
- [ ] App se mantiene estable

### Screenshots
- Error credenciales inválidas:
- Error validación:
- Error red:
- Error canje:

---

## 🟢 TEST 11: PERFORMANCE (Opcional)

### Objetivo
Validar rendimiento de la app

### Pasos
```
1. Usar Flutter DevTools (Performance)
2. Probar diferentes escenarios:
   - Scroll en lista de 100+ tareas
   - Navegación entre tabs
   - Crear múltiples tareas rápidamente
3. Medir métricas:
   - FPS durante scroll
   - Tiempo de navegación entre screens
   - Tiempo de respuesta en acciones
   - Memoria usada
```

### Expected Results
- ✅ FPS >= 60 durante scroll
- ✅ Navegación entre screens <500ms
- ✅ Crear tarea <300ms
- ✅ Memoria usada <200MB
- ✅ NO janks/stutters

### Validation Checklist
- [ ] FPS >= 60 (60fps)
- [ ] Navegación <500ms
- [ ] Crear tarea <300ms
- [ ] Memoria <200MB
- [ ] NO stutters notables

---

## 📊 RESUMEN DE RESULTADOS

### Test Status
| Test | Estado | Observaciones |
|------|--------|-------------|
| 1. Refresh Real | ⏳ Pendiente | |
| 2. Doble Tap Idempotente | ⏳ Pendiente | |
| 3. Rate Limit Real | ⏳ Pendiente | |
| 4. Kill App Mid-Request | ⏳ Pendiente | |
| 5. Simular Mala Red | ⏳ Pendiente | |
| 6. Concurrent Requests | ⏳ Pendiente | |
| 7. Token Rotation Attack | ⏳ Pendiente | |
| 8. Flujo Onboarding | ⏳ Pendiente | |
| 9. Integración Realtime | ⏳ Pendiente | |
| 10. Error Handling | ⏳ Pendiente | |
| 11. Performance | ⏳ Pendiente | |

### Overall Assessment
- **Tests Pasados:** 0/11
- **Tests Fallados:** 0/11
- **Tests Pendientes:** 11/11
- **Estado Staging:** ⚠️ Sin validar

---

## 🐛 BUGS ENCONTRADOS

| Bug | Severidad | Descripción |
|-----|-----------|-------------|
| - | - | - |

---

## 💡 SUGERENCIAS DE MEJORA

1. 
2. 
3. 

---

## 📝 NOTAS ADICIONALES

- **Fecha de inicio:**
- **Hora de inicio:**
- **Tester:**
- **Dispositivo:**
- **Versión Android/iOS:**
- **Conexión:**
- **Ubicación de pruebas:**

---

**Última actualización:** 2026-03-02
**Próxima revisión:** Después de completar todos los tests
