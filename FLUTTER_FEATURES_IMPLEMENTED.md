# HomeSync - Funcionalidades Implementadas

**Última Actualización:** 2026-02-25
**Estado:** Arquitectura Riverpod Validada - Nivel Pro

---

## 📊 Resumen de Progreso Real

| Feature                | Estado | Descripción                                    |
| ---------------------- | ------ | ---------------------------------------------- |
| **Core: Tasks**        | ✅     | Riverpod + Realtime + Recurrencia + Calendario |
| **Finanzas: Expenses** | ✅     | Shared/Personal + Couple Balance + MercadoPago |
| **Compras: Shopping**  | ✅     | Estilo Bring! + Categorías + Sugerencias       |
| **Gamification**       | ✅     | Weekly Winner + Rewards + XP System            |
| **Settings**           | ✅     | Household Mgmt + Avatar Picker + MP Config     |
| **Auth**               | ✅     | Email/Password + Google (OAuth)                |
| **Notificaciones**     | 🟨     | In-App Realtime (OK), Push Nativo (Pendiente)  |

---

## 1. Gestión de Tareas (Tasks) 📋

- **Arquitectura:** Migrado 100% a Riverpod (`AsyncNotifier`).
- **Realtime:** Los cambios se reflejan instantáneamente en todos los dispositivos del hogar.
- **Recurrencia Avanzada:** Soporte para tareas diarias, semanales, mensuales y custom.
- **Visualización:** Toggle entre vista de Lista y Vista de Calendario.
- **Gamification:** Sistema de XP y Coins ganado por completar tareas.

## 2. Finanzas Compartidas (Expenses) 💸

- **Vistas Duales:** Switch entre "Nuestras Finanzas" (compartido) y "Mis Finanzas" (personal).
- **Couple Balance:** Dashboard que muestra quién debe a quién con una barra visual de balance.
- **Integración MercadoPago:**
  - Generación de links de pago para saldar deudas.
  - Soporte para copiar Alias de transferencia.
  - Deep Linking para retorno automático después del pago.
- **Gráficos:** Estructura preparada para visualización de gastos por categoría.

## 3. Lista de Compras (Shopping) 🛒

- **UX Estilo Bring!:** Grilla de items con emojis, agrupados por categorías.
- **Sugerencias Inteligentes:** Buscador con autocompletado de items predefinidos.
- **Recently Used:** Sección colapsable con items comprados frecuentemente para re-agregado rápido.
- **Sync:** Actualización inmediata cuando el otro miembro de la pareja agrega algo.

## 4. Perfil y Hogar (Settings) ⚙️

- **Avatar Picker:** Selector premium de avatares con temática de animales/gatos.
- **Miembros:** Gestión de roles (Owner/Member) y visualización de integrantes del hogar.
- **Invitaciones:** Generación de códigos alfanuméricos de 6 caracteres para unir a la pareja.
- **Modo Oscuro:** Soporte nativo para temas Claro/Oscuro persistente.

## 5. Notificaciones 🔔

- **In-App Banner:** Sistema de notificaciones que deslizan desde la parte superior mientras la app está abierta.
- **Historial:** Pantalla dedicada para revisar notificaciones pasadas (Read/Unread).
- **Backend:** Triggers en base de datos que generan registros al completar tareas o agregar gastos.

## 6. Gamificación y Premios 🏆

- **Weekly Winner:** Pantalla especial con confeti que aparece los domingos/lunes mostrando al miembro más productivo.
- **Rewards Shop:** Tienda donde se pueden canjear Coins por premios configurados o personalizados.
- **Transferencias:** Posibilidad de enviar Coins a la pareja como regalo o incentivo.

---

## 🚀 Próximos Pasos (Pendiente)

1. **Activación de Push Notifications (Firebase):**
   - Configurar `google-services.json` y `GoogleService-Info.plist`.
   - Descomentar lógicas en `notification_service.dart`.
2. **Refinamiento de Google Login:**
   - Asegurar que el callback URL en producción funcione correctamente en iOS/Android.
3. **Modo Offline:**
   - Implementar persistencia local (sqflite) para permitir la visualización de la lista de compras sin internet.
4. **Analytics & Bug Reporting:**
   - Integración final con el sistema de logs persistentes en Supabase para errores de producción.

---

## Estructura de Proyecto Activa

```
flutter_client/
├── lib/
│   ├── models/        # Task, Expense, Member, ShoppingItem
│   ├── providers/     # Lógica Riverpod (TaskProvider, ExpenseProvider, etc)
│   ├── repositories/  # Capa de datos (Supabase Client)
│   ├── services/      # Auth, RPC, MercadoPago, Notifications
│   ├── screens/       # UI Screens (15+ pantallas)
│   ├── widgets/       # Componentes reutilizables
│   └── theme/         # Design System (AppColors, AppTheme)
```
