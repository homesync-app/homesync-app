# HomeSync Design System

Este documento define la base visual para mejorar HomeSync pantalla por pantalla sin volver a resolver el mismo problema en cada archivo.

## Objetivo

HomeSync debe sentirse como una sola app, pero cada tipo de hogar necesita personalidad propia:

- **Pareja**: cálida, cercana y emocional. Prioriza vínculo, balance compartido y gestos.
- **Familia**: clara, colaborativa y contenedora. Prioriza coordinación, responsabilidades, aprobaciones y recompensas.
- **Compañeros**: ágil, neutral y práctica. Prioriza cuentas claras, reparto, convivencia y próximos pasos.
- **Solo**: calma, personal y enfocada. Prioriza progreso individual, orden y baja fricción.

La regla central: compartir estructura, cambiar intención.

## Capas

### 1. Capacidades

`HouseholdCapabilities` define qué puede hacer o ver cada hogar: tareas, split de gastos, social tab, stats, etc.

No debe cargar decisiones visuales complejas.

### 2. Personalidad visual

`HouseholdModeDesign` define cómo se siente cada modo:

- nombre y título principal
- subtítulo base
- tono de diseño
- acción primaria
- iconos
- acentos
- gradiente hero
- principios de diseño

Usar:

```dart
final modeDesign = caps.type.design;
```

### 3. Tokens

`AppRadii`, `AppInsets`, `AppControlSizes`, `AppElevation` y `AppMotion` son la escala base.

Evitar nuevos valores hardcodeados salvo que haya una razón explícita.

## Primitivas

Usar estas piezas antes de crear UI local:

- `AppCard`: contenedores de contenido.
- `AppSectionHeader`: encabezados de sección.
- `AppPill`: badges, estados, filtros y metadata compacta.
- `AppSheetShell`: estructura visual de bottom sheets.
- `AppScreenScaffold`: fondo y estructura base de pantalla.
- `AppFloatingActionButton`: FAB extendido estándar.
- `CustomBottomNav`: navegación principal estándar.
- `AppSegmentedTabs`: tabs segmentadas estándar.
- `AppEmptyState`, `AppLoadingState`, `AppErrorState`: estados base.

## Reglas Visuales

### Cards

- Usar `AppCard` para contenido repetido o bloques principales.
- Usar `AppCardVariant.hero` solo para el bloque principal de la pantalla.
- Evitar cards dentro de cards.
- Evitar sombras locales; usar `theme.cardShadow` o `AppElevation`.

### Radios

- `AppRadii.md`: controles pequeños.
- `AppRadii.lg`: botones y acciones.
- `AppRadii.xl`: cards estándar.
- `AppRadii.xxl`: hero cards.
- `AppRadii.modal`: sheets y diálogos.
- `AppRadii.pill`: pills, chips y badges.

### Tipografía

- `w900`: títulos principales, montos o datos hero.
- `w800`: títulos de card y estados seleccionados.
- `w700`: labels importantes.
- `w600`: texto de apoyo.
- Evitar que todos los textos usen `w800/w900`.
- Evitar `letterSpacing` negativo salvo en títulos hero o montos.

### Color

- No usar `Color(0x...)` en pantallas salvo casos aislados y justificados.
- Preferir `context.theme` para superficies, texto, bordes y sombras.
- Usar `HouseholdModeDesign` para acentos por modo.
- Usar `category_mapping.dart` para categorías.

### Gradientes

- Un gradiente por pantalla como máximo.
- Reservar gradientes para hero, onboarding o estados celebratorios.
- No usar gradientes para compensar falta de jerarquía.

### FAB

- Usar `AppFloatingActionButton`.
- El FAB debe representar la acción principal real de la pantalla.
- Si una pantalla tiene varias acciones, abrir un sheet con `AppSheetShell`.

### Bottom Sheets

- Usar `AppSheetShell`.
- El título debe explicar la acción, no la tecnología.
- Las acciones principales van abajo, con una jerarquía clara.

## Reglas Por Modo

### Pareja

- Puede usar más calidez, peach/naranja y microcopy afectivo.
- Balance y reciprocidad deben ser visibles.
- Evitar que lo lúdico tape dinero, tareas o acciones.

### Familia

- Debe ser más operativa que decorativa.
- Diferenciar niños, adolescentes y adultos con estados claros.
- Mostrar aprobación, responsabilidad y recompensa sin ambigüedad.

### Compañeros

- Tono directo: deuda, tarea, responsable, vencimiento, resolver.
- Evitar lenguaje romántico o de crianza.
- Priorizar escaneo rápido y acuerdos visibles.

### Solo

- Menos densidad social.
- Más foco en progreso, orden y continuidad.
- Estados vacíos deben invitar sin presión.

## Checklist Antes De Tocar Una Pantalla

1. Identificar el modo o modos que afectan la pantalla.
2. Revisar si existe una primitiva compartida que resuelva el patrón.
3. Usar `caps.type.design` para acento y tono.
4. Reducir hardcodes de color, sombra y radio.
5. Mantener una sola acción primaria visible.
6. Revisar copy en español argentino con acentos.
7. Verificar que el contenido no dependa de un único modo de hogar.
