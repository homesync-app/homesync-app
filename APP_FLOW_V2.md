# HomeSync - Arquitectura de Flujo v2.0

**Fecha:** 2026-02-20
**Estado:** Producción

---

## Arquitectura General

```
┌─────────────────────────────────────────────────────────────┐
│                        HOME SYNC                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
│  │  INICIO │  │ TAREAS  │  │ GASTOS  │  │ TIENDA  │  │  STATS  │
│  │Dashboard│  │Gestión  │  │Deudas   │  │Premios  │  │Análisis │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘  └─────────┘
│       │            │            │            │            │
│       │            │            │            │            │
│  ┌────▼────────────▼────────────▼────────────▼────────────▼────┐
│  │                    SUPABASE BACKEND                         │
│  │  - Auth (Supabase Auth)                                     │
│  │  - Database (PostgreSQL + RLS)                              │
│  │  - RPC Functions (Transacciones atómicas)                   │
│  │  - Realtime (opcional)                                      │
│  └─────────────────────────────────────────────────────────────┘
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Flujo de la Aplicación

### 1. Onboarding (Setup Screen)

```
┌──────────────────────────────────────────────────────────────┐
│                      NUEVO USUARIO                           │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  Paso 1: Modo de uso                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  👤 Solo yo  │  │  💑 Pareja   │  │ 👨‍👩‍👧‍👦 Familia  │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                              │
│  Paso 2: Equipo (solo si no es Solo)                        │
│  ┌──────────────┐  ┌──────────────┐                         │
│  │ ➕ Crear     │  │ 🔗 Unirse    │                         │
│  │   equipo     │  │  con código  │                         │
│  └──────────────┘  └──────────────┘                         │
│                                                              │
│  Paso 3: Selección de tareas                                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  🧹 Limpieza  │  🍽️ Cocina   │  🛏️ Dormitorio  │ ... │   │
│  │  ─────────────────────────────────────────────────── │   │
│  │  [x] Barrer el piso      ⭐ 5  💰 3                  │   │
│  │  [x] Hacer la cama       ⭐ 5  💰 3                  │   │
│  │  [ ] Lavar los platos    ⭐ 10 💰 5                  │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  [Comenzar]                                                  │
└──────────────────────────────────────────────────────────────┘
```

### 2. Inicio (Home Screen) - Dashboard del Día

```
┌──────────────────────────────────────────────────────────────┐
│  INICIO                                    ⚙️ Settings       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  ⭐ 150 XP              💰 85 Coins                  │    │
│  │              [Balance Card]                          │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ─── COMPLETADAS HOY (3) ───                                │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 🧹 Barrer el piso      ✅ ⭐5 💰3                   │    │
│  │ 🛏️ Hacer la cama       ✅ ⭐5 💰3                   │    │
│  │ 🍽️ Lavar platos        ✅ ⭐10 💰5                  │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ─── TAREAS FRECUENTES ───                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 🚿 Limpiar baño        [🔄 Diario]    [✓]           │    │
│  │ 🧹 Trapear piso        [🔄 Semanal]   [✓]           │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ─── BALANCE DE GASTOS ───                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  👤 María           +$150                            │    │
│  │  👤 Juan            -$150                            │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│         ┌────────────────────────────────┐                  │
│         │  ➕ REGISTRAR                  │ ← FAB            │
│         └────────────────────────────────┘                  │
└──────────────────────────────────────────────────────────────┘
```

**Botón Registrar (FAB):**

```
┌──────────────────────────────────┐
│  ¿Qué querés registrar?          │
├──────────────────────────────────┤
│  ┌────────────────────────────┐  │
│  │ ✅ Tarea completada        │  │
│  │    Ganá XP y coins         │  │
│  └────────────────────────────┘  │
│  ┌────────────────────────────┐  │
│  │ 🧾 Gasto                   │  │
│  │    Registrar gasto común   │  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

### 3. Tareas (Tasks Screen) - Gestión

```
┌──────────────────────────────────────────────────────────────┐
│  TAREAS                                    ⚙️ Settings       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ─── TAREAS ACTIVAS (5) ───                                 │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 🧹 Barrer el piso                                    │    │
│  │    General | ⭐5 💰3                                 │    │
│  │    [🕐 Programar] [🗑️]                              │    │
│  ├─────────────────────────────────────────────────────┤    │
│  │ 🚿 Limpiar baño                     [🔄 Diario]     │    │
│  │    Baño | ⭐20 💰10                                  │    │
│  │    [🕐 Programar] [🗑️]                              │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ─── COMPLETADAS RECIENTEMENTE ───                          │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ ✅ Hacer la cama                        Completada   │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│         ┌────────────────────────────────┐                  │
│         │  ➕ NUEVA TAREA                │ ← FAB            │
│         └────────────────────────────────┘                  │
└──────────────────────────────────────────────────────────────┘
```

**Crear Nueva Tarea:**

```
┌──────────────────────────────────────────────────────────┐
│  ➕ Nueva Tarea                                          │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ¿Qué hay que hacer?                                     │
│  [____________________________]                          │
│                                                          │
│  Categoría:                                              │
│  [🧹 Limpieza ▼]                                         │
│                                                          │
│  Frecuencia (opcional):                                  │
│  [Sin repetir ▼]  → Diario | Semanal | Mensual          │
│                                                          │
│  Asignar a (opcional):                                   │
│  [Cualquiera ▼]                                          │
│                                                          │
│  ─── DIFICULTAD ───                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐               │
│  │  Fácil   │  │  Medio   │  │ Difícil  │               │
│  │ ⭐5 💰3  │  │ ⭐10 💰5  │  │ ⭐20 💰10 │               │
│  └──────────┘  └──────────┘  └──────────┘               │
│                                                          │
│  ─── RECOMPENSAS ───────────────────── [✓] Personalizar  │
│  │  ⭐ XP    [10___]    💰 Coins  [5___]               │
│  └──────────────────────────────────────────────────────│
│                                                          │
│  [Cancelar]                    [Crear tarea]             │
└──────────────────────────────────────────────────────────┘
```

### 4. Gastos y Ahorros (Expenses & Savings)

```
┌──────────────────────────────────────────────────────────────┐
│  GASTOS                                    ⚙️ Settings       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ─── BALANCE DE PAREJA ───                                   │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  👤 María debe recibir    +$150                      │    │
│  │  👤 Juan debe pagar       -$150                      │    │
│  │                                                       │    │
│  │  [Liquidar deuda]                                     │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ─── METAS DE AHORRO 🎯 ───                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  🚗 Auto Nuevo      ██████░░░░  60%  $12.000/$20.000 │    │
│  │  🏝️ Vacaciones      ██░░░░░░░░  25%   $2.500/$10.000 │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ─── GASTOS RECIENTES ───                                   │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 🛒 Supermercado        $300    María   20/02        │    │
│  │ 💡 Electricidad        $150    Juan    19/02        │    │
│  │ 🚗 Nafta               $200    María   18/02        │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 5. Tienda (Rewards Screen)

```
┌──────────────────────────────────────────────────────────────┐
│  TIENDA                                    ⚙️ Settings       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  💰 85 Coins disponibles                             │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ─── PREMIOS ───                                            │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ 🍕 Pizza night           50 coins   [Canjear]       │    │
│  │ 🎬 Película a elección   100 coins  [Canjear]       │    │
│  │ 🧹 Día libre de tareas   200 coins  [Canjear]       │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ─── CREAR PREMIO ───                                       │
│  [+ Crear premio personalizado]                             │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 6. Stats (Statistics Screen)

```
┌──────────────────────────────────────────────────────────────┐
│  STATS                                     ⚙️ Settings       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ─── ESTA SEMANA ───                                        │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Tareas completadas: 12                              │    │
│  │  XP ganado: 85                                       │    │
│  │  Coins ganados: 45                                   │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ─── POR CATEGORÍA ───                                      │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  🧹 Limpieza     ████████░░  8 tareas               │    │
│  │  🍽️ Cocina       █████░░░░░  5 tareas               │    │
│  │  🛏️ Dormitorio   ███░░░░░░░  3 tareas               │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## Filosofía del Flujo

### Separación de Responsabilidades

| Pantalla   | Propósito               | Acciones                                                          |
| ---------- | ----------------------- | ----------------------------------------------------------------- |
| **Inicio** | Dashboard operativo     | Ver estado del día, completar tareas frecuentes, registrar gastos |
| **Tareas** | Gestión y configuración | Crear, editar, eliminar, programar tareas                         |
| **Gastos** | Control financiero      | Ver balances, liquidar deudas, historial                          |
| **Tienda** | Motivación              | Canjear premios, crear premios custom                             |
| **Stats**  | Análisis                | Ver progreso, estadísticas                                        |

### Principios de UX

1. **Acciones frecuentes accesibles**: El botón "Registrar" siempre visible en Inicio
2. **Información relevante primero**: Lo más importante es qué tenés que hacer hoy
3. **Configuración separada**: Crear/editar tareas es algo que se hace esporádicamente
4. **Feedback inmediato**: Al completar tarea, se ve reflejado en el historial del día

---

## Estructura de Archivos

```
flutter_client/lib/
├── main.dart                      # App entry point
├── config/
│   └── app_environment.dart       # URLs y configuración
├── services/
│   ├── supabase_auth_service.dart # Autenticación
│   ├── supabase_rpc_service.dart  # Funciones RPC
│   ├── expense_service.dart       # Lógica de gastos
│   └── template_service.dart      # Templates de tareas
├── screens/
│   ├── home_screen.dart           # Dashboard del día ★ NUEVO
│   ├── tasks_screen.dart          # Gestión de tareas
│   ├── expenses_screen.dart       # Gastos compartidos
│   ├── rewards_screen.dart        # Tienda de premios
│   ├── stats_screen.dart          # Estadísticas
│   ├── login_screen.dart          # Login/Registro
│   └── setup_screen.dart          # Onboarding
├── widgets/
│   ├── balance_card.dart          # Card de XP/Coins
│   ├── create_task_dialog.dart    # Crear/editar tarea
│   └── schedule_dialog.dart       # Programar frecuencia
└── theme/
    ├── app_colors.dart            # Paleta de colores
    └── app_theme.dart             # Glassmorphism theme
```

---

## Base de Datos

### Tablas Principales

| Tabla                | Descripción            |
| -------------------- | ---------------------- |
| `users`              | Usuarios de la app     |
| `households`         | Hogares/Equipos        |
| `household_members`  | Relación usuario-hogar |
| `tasks`              | Tareas del hogar       |
| `task_templates`     | Plantillas de tareas   |
| `expenses`           | Gastos compartidos     |
| `expense_splits`     | División de gastos     |
| `rewards`            | Premios disponibles    |
| `reward_redemptions` | Canjes realizados      |
| `ledger_entries`     | Historial de XP/Coins  |

### Funciones RPC Principales

| Función                     | Uso                              |
| --------------------------- | -------------------------------- |
| `create_task`               | Crear nueva tarea                |
| `complete_task_transaction` | Completar tarea (ganar XP/Coins) |
| `get_user_balance`          | Obtener balance de XP/Coins      |
| `get_tasks`                 | Listar tareas del hogar          |
| `generate_invitation_code`  | Generar código para invitar      |
| `join_household`            | Unirse a un hogar                |
| `create_expense`            | Registrar gasto                  |
| `get_expense_balance`       | Balance de deudas                |
| `redeem_reward`             | Canjear premio                   |

---

## Próximas Mejoras

### Prioridad Alta

- [ ] Notificaciones push para recordatorios
- [ ] Indicador de racha diaria
- [ ] Mostrar días de frecuencia (ej: "Lun/Mié/Vie")

### Prioridad Media

- [ ] Modo oscuro
- [ ] Animaciones al completar tareas
- [ ] Gráficos en Stats

### Prioridad Baja

- [ ] Chat entre miembros
- [ ] Exportar historial
- [ ] Temas personalizables

---

## Diferenciador vs Competencia

| Feature                | Nipto | HomeSync |
| ---------------------- | ----- | -------- |
| Tareas predefinidas    | ✅    | ✅       |
| Sistema de puntos      | ✅    | ✅       |
| Categorías             | ✅    | ✅       |
| **Gastos compartidos** | ❌    | ✅       |
| **Split automático**   | ❌    | ✅       |
| **Balance deudas**     | ❌    | ✅       |
| **Monedas virtuales**  | ❌    | ✅       |
| **Tienda de premios**  | ❌    | ✅       |
| **Dashboard del día**  | ❌    | ✅       |
| **Tareas frecuentes**  | ❌    | ✅       |

**HomeSync = Gestión de tareas + División de gastos + Gamificación completa**
