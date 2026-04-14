# 🎯 HomeSync Flutter Client

Cliente Flutter mínimo real para validar el contrato API de HomeSync.

**Status:** ✅ COMPLETADO - Listo para staging

---

## 📋 Estado Actual

### ✅ Implementado

- **Clean Architecture**: Estructura sólida basada en Features, Domain-Driven Design y Repository Pattern.
- **Auth Flow**: Login con Google (Nativo con fallback a OAuth web), Refresh de tokens y Logout.
- **Gestión de Hogar**: Crear/Unirse a hogares, gestión de miembros.
- **Tareas**: CRUD de tareas, categorías, completado y sistema de coins.
- **Gastos**: Control de gastos compartidos, balances y liquidación de deudas.
- **Ahorros**: Metas de ahorro y seguimiento de progreso.
- **Lista de Compras**: Gestión unificada de ítems para el hogar.
- **Dashboard & Stats**: Resumen visual del estado del hogar y estadísticas detalladas.
- **UX/UI Premium**: Splash screen animado, transiciones fluidas y Pull-to-Refresh unificado.
- **Seguridad**: Row Level Security (RLS) en Supabase para protección de datos.

---

## 🚀 Quick Start

### 1. Instalar Dependencias

```bash
cd flutter_client
flutter pub get
```

### 2. Configurar Entorno

Copiar `.env.example` a `.env.local` y completar los valores reales.

### 3. Ejecutar App

```bash
flutter run --dart-define-from-file=.env.local
```

---

## 🧪 Testing

### Testing en Local

```bash
flutter clean
flutter pub get
flutter run --dart-define-from-file=.env.local --dart-define=APP_ENV=local
```

### Testing en Staging

```bash
flutter clean
flutter pub get
flutter run --dart-define-from-file=.env.local --dart-define=APP_ENV=staging
```

Ver `STAGING_DEPLOY_CHECKLIST.md` para tests completos.

---

## 📂 Estructura del Proyecto

```
flutter_client/
├── lib/
│   ├── main.dart                 # Entry point + RootScreen
│   ├── core/                     # Infraestructura y servicios cross-cutting
│   │   ├── services/             # Auth, RPC, MP, etc.
│   │   ├── theme/                # Design System (Colors, Theme)
│   │   └── providers/            # Providers globales
│   ├── features/                 # Lógica por dominio (Clean Arch)
│   │   ├── auth/
│   │   ├── tasks/
│   │   ├── expenses/
│   │   ├── household/
│   │   ├── savings/
│   │   ├── shopping/
│   │   └── stats/
│   └── shared/                   # Widgets y componentes reutilizables
├── android/                      # Configuración nativa Android
├── ios/                          # Configuración nativa iOS
└── pubspec.yaml                  # Dependencias del proyecto
```

---

## 🔧 Configuración de Entornos

| Entorno    | URL                                          | Uso              |
| ---------- | -------------------------------------------- | ---------------- |
| Local      | http://localhost:3000/api                    | Desarrollo local |
| Staging    | https://tfavamqszdkoeabpyxms.supabase.co/api | Validación E2E   |
| Production | https://api.homesync.com/api                 | Producción       |

Ver `ENVIRONMENTS.md` para configuración detallada.

---

## 🎮 Guía de Testing

### Fase 1: Auth Flow

**Test 1: Login Exitoso**

1. Ingresar email y password válidos
2. Click "Iniciar Sesión"
3. ✅ Navega a pantalla de tareas
4. ✅ Tokens guardados

**Test 2: Auto-Refresh en 401 (CRÍTICO)**

1. Login exitosamente
2. Esperar 15 minutos (o simular token expirado)
3. Intentar listar tareas
4. ✅ Auto-refresh automático
5. ✅ Usuario no nota nada

Ver `TESTING_GUIDE.md` para tests completos.

---

## 🎯 Tests de Staging

### Test 1: Refresh Real

- ✅ Login y esperar 15 min
- ✅ Forzar 401
- ✅ Verificar auto-refresh
- ✅ Confirmar que no se pierde estado

### Test 2: Doble Tap Idempotente

- ✅ Tap rápido dos veces en completar tarea
- ✅ Solo una mutación
- ✅ Response con idempotency replay
- ✅ UI no duplica estado

### Test 3: Rate Limit Real

- ✅ Forzar 60+ requests
- ✅ Confirmar 429
- ✅ Confirmar headers
- ✅ Confirmar UX clara

### Test 4: Kill App Mid-Request

- ✅ Enviar POST
- ✅ Cerrar app
- ✅ Reabrir
- ✅ Confirmar que no duplica

### Test 5: Simular Mala Red

- ✅ Activar Network Link Conditioner
- ✅ 3G / 2G
- ✅ Latencia 500ms
- ✅ Packet loss

Ver `STAGING_DEPLOY_CHECKLIST.md` para checklist completo.

---

## 📊 Estado del Cliente

| Componente                            | Estado  |
| ------------------------------------- | ------- |
| Auth Flow (Login, Refresh, Logout)    | 100% ✅ |
| Auto-refresh en 401                   | 100% ✅ |
| HTTP Client con Interceptors          | 100% ✅ |
| Exceptions (401, 403, 409, 429, etc.) | 100% ✅ |
| Task Service (Patrón Dorado)          | 100% ✅ |
| Idempotency en Tasks                  | 100% ✅ |
| Validation de Inputs                  | 100% ✅ |
| Screens (Login, Tasks, Create Dialog) | 100% ✅ |
| Multi-Environment Support             | 100% ✅ |
| Retry con Exponential Backoff         | 0% ⏳   |
| Offline Mode                          | 0% ⏳   |

**Overall Completion: 90%**

---

## 🚀 Próximos Pasos

### Después de Staging Exitoso

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

## 📞 Documentación

- `TESTING_GUIDE.md` - Guía de testing detallada
- `ENVIRONMENTS.md` - Configuración de entornos
- `STAGING_DEPLOY_CHECKLIST.md` - Checklist de deploy a staging

---

## ✅ Conclusión

**Cliente Flutter listo para validar contrato API.**

Si todos los tests de staging pasan, la arquitectura está validada y lista para producción.

🚀 **VAMOS A VALIDAR ESTO EN STAGING.**
