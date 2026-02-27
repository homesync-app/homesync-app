# PLAN INMEDIATO: FLUTTER + SUPABASE RPC

## Estado Actual - v2.0

**Arquitectura implementada:**
```
┌─────────────┐
│   Flutter   │ (Mobile Client - Web/Android/iOS)
└──────┬──────┘
       │ Supabase SDK
       ▼
┌─────────────────┐
│    Supabase     │
│                 │
│ - Auth          │
│ - RPC Functions │
│ - PostgreSQL    │
│ - RLS Policies  │
└─────────────────┘
```

---

## Flujo de Pantallas v2.0

```
┌─────────────────────────────────────────────────────────────────┐
│                         HOME SYNC                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌────────┐
│  │  INICIO │  │ TAREAS  │  │ GASTOS  │  │ TIENDA  │  │ STATS  │
│  │Dashboard│  │Gestión  │  │Deudas   │  │Premios  │  │Análisis│
│  │ del día │  │  ONLY   │  │         │  │         │  │        │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘  └───┬────┘
│       │            │            │            │            │
│       │ Completar  │ Crear/     │ Registrar  │ Canjear   │ Ver
│       │ tareas     │ Editar/    │ gastos     │ premios   │ stats
│       │ Registrar  │ Eliminar   │ Liquidar   │           │
│       │ gastos     │            │ deudas     │           │
│       │            │            │            │            │
└───────┴────────────┴────────────┴────────────┴────────────┴────────┘
```

---

## MVP Features Completadas

### Inicio (Tab 1) - NUEVO
- [x] Balance de XP y Coins
- [x] Historial de tareas completadas hoy
- [x] Tareas frecuentes del día (con recurrencia)
- [x] Balance de gastos/deudas
- [x] Botón "Registrar" → Tarea completada o Gasto

### Tareas (Tab 2) - REESTRUCTURADO
- [x] Gestión de tareas (ver, crear, editar, eliminar)
- [x] Crear tarea con frecuencia personalizable
- [x] Crear tarea con XP/Coins personalizables
- [x] Programar frecuencia (diario/semanal/mensual)
- [x] 47 templates predefinidos en 7 categorías
- [x] SIN botón completar (eso va en Inicio)

### Gastos (Tab 3)
- [x] Agregar gastos con categorías
- [x] 8 categorías de gastos
- [x] Split automático entre miembros
- [x] Balance de cada usuario
- [x] Deudas pendientes
- [x] Liquidación de deudas
- [x] Historial de gastos

### Tienda (Tab 4)
- [x] Canjear premios con coins
- [x] Premios personalizados por hogar
- [x] Historial de canjes
- [x] Transferir coins entre miembros

### Stats (Tab 5)
- [x] Estadísticas por categoría
- [x] Historial de XP
- [x] Historial de actividad

### Backend & Seguridad
- [x] Supabase Auth
- [x] RLS Policies en todas las tablas
- [x] RPC Functions con transacciones
- [x] Observabilidad (logs, audits)
- [x] Persistencia de sesión (no pide setup cada vez)

---

## Setup Screen (Onboarding)

1. **Modo de uso**: Solo / Pareja / Familia
2. **Equipo**: Crear nuevo o unirse con código (6 caracteres)
3. **Selección de tareas**: Elegir de templates predefinidos

---

## Crear Tarea (Mejorado)

1. **Título**: Nombre de la tarea
2. **Categoría**: Limpieza, Cocina, Dormitorio, etc.
3. **Frecuencia**: Sin repetir / Diario / Semanal / Mensual
4. **Asignar a**: Cualquiera o miembro específico
5. **Dificultad**: Fácil (5XP/3💰), Medio (10XP/5💰), Difícil (20XP/10💰)
6. **Personalizar**: Checkbox para editar XP y Coins manualmente

---

## Diferenciador vs Nipto

| Feature | Nipto | HomeSync |
|---------|-------|----------|
| Tareas predefinidas | ✅ | ✅ |
| Sistema de puntos | ✅ | ✅ |
| Categorías | ✅ | ✅ |
| **Dashboard del día** | ❌ | ✅ |
| **Tareas frecuentes** | ❌ | ✅ |
| **Historial diario** | ❌ | ✅ |
| **Gastos compartidos** | ❌ | ✅ |
| **Split automático** | ❌ | ✅ |
| **Balance deudas** | ❌ | ✅ |
| **Liquidación** | ❌ | ✅ |
| **Monedas virtuales** | ❌ | ✅ |
| **Tienda de premios** | ❌ | ✅ |

**HomeSync = Nipto + División de gastos + Monedas + Dashboard del día**

---

## Para Probar

```bash
cd flutter_client
"C:\user\blas_\develop\flutter\bin\flutter" run -d chrome
```

### Flujo de prueba:
1. Registrar nuevo usuario
2. Onboarding → seleccionar modo → crear/unirse → elegir tareas
3. **Inicio**: Ver balance, tareas frecuentes, balance gastos
4. **Botón Registrar**: Completar tarea o registrar gasto
5. **Tareas**: Crear nueva tarea con frecuencia
6. **Gastos**: Ver balances y liquidar
7. **Tienda**: Canjear premio
8. Cerrar y reabrir → No pide setup de nuevo ✅

---

## Próximos Pasos

### Prioridad Alta
- [ ] Notificaciones push para recordatorios
- [ ] Indicador de racha diaria
- [ ] Mostrar días de frecuencia (ej: "Lun/Mié/Vie")

### Prioridad Media
- [ ] Modo oscuro
- [ ] Animaciones al completar tareas
- [ ] Gráficos mejorados en Stats

### Prioridad Baja
- [ ] Chat entre miembros
- [ ] Exportar historial
- [ ] Temas personalizables

---

## Archivos del Proyecto

| Archivo | Descripción |
|---------|-------------|
| `APP_FLOW_V2.md` | Documentación del flujo actualizado |
| `FLUTTER_FEATURES_IMPLEMENTED.md` | Features implementados |
| `database/RLS_DOCUMENTATION.md` | Documentación RLS |
| `flutter_client/lib/` | Código Flutter |

---

## Comandos Útiles

```bash
# Correr Flutter
cd flutter_client
"C:\user\blas_\develop\flutter\bin\flutter" run -d chrome

# Analizar código
"C:\user\blas_\develop\flutter\bin\flutter" analyze lib/

# Ver logs Supabase
# Dashboard > Logs > Postgres
```
