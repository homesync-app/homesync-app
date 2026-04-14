# Iconography And Microinteractions

## Objetivo

Unificar la lectura visual de HomeSync para que los iconos no cambien de criterio entre secciones y para que las acciones mas valiosas se sientan mas "premium".

## Sistema de iconografia

### Outlined

Usar iconos `outlined` o `outline` cuando el elemento este en estado exploratorio, secundario o no confirmado:

- tabs inactivos de la navegacion principal
- acciones secundarias del app bar, como `settings`
- campos de formulario, placeholders y vacios informativos
- accesos de soporte o contexto, no de conversion

### Filled / Rounded

Usar iconos `rounded` o `filled` cuando el elemento este activo, confirmado o tenga peso principal:

- tab activo de la navegacion principal
- CTA principales y acciones de guardado
- estados positivos o de exito
- categorias, rewards y bloques de contenido destacados

## Zonas que siguen mezclando estilos

Estas zonas todavia usan una mezcla valida pero no del todo sistematizada:

1. `lib/features/dashboard/presentation/screens/modes/home_family_view.dart`
   Conviven `notifications_outlined`, `emoji_events_outlined` y `account_balance_wallet_outlined` con muchos `rounded` de accion y estado en la misma superficie.

2. `lib/features/dashboard/presentation/screens/household_social_hub_screen.dart`
   Las cards principales usan `rounded`, pero hay acciones secundarias como `edit_outlined` sin una regla documentada.

3. `lib/features/auth/presentation/screens/login_screen.dart`
   Los inputs usan `outlined` y varias acciones o bloques usan `rounded`. Visualmente funciona, pero conviene consolidar la regla para auth.

4. `lib/core/theme/category_mapping.dart`
   La mayoria de las categorias usan `rounded`, que hoy vamos a considerar el estandar correcto para contenido.

## 4 microinteracciones premium elegidas

1. Navegacion principal
   Los tabs ahora responden con `press scale`, haptica liviana y cambio animado de `outlined` a `filled`.

2. Boton de ajustes
   Pasa de `IconButton` plano a superficie tactil con borde suave y respuesta de presion.

3. Crear tarea
   El CTA principal ahora pasa por tres estados: idle, loading, success.

4. Guardar gasto/ingreso
   El CTA principal ahora pasa por tres estados: idle, loading, success.

## Siguiente barrido recomendado

- aplicar la misma regla outlined/filled a acciones del dashboard y stats
- revisar shopping y rewards para separar mejor iconos de navegacion, contenido y estado
- extender el patron `idle -> loading -> success` a compras, liquidacion de deuda y acciones premium
