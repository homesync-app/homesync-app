# HomeSync UI Visual Improvement Plan

## Objetivo

Elevar la calidad visual de HomeSync desde una base ya prometedora hacia una experiencia mas consistente, premium y confiable, sin perder la calidez del producto ni romper el trabajo funcional ya implementado.

Este plan prioriza:

1. Corregir lo que hoy baja mas la percepcion de calidad.
2. Unificar el sistema visual para que todas las pantallas hablen el mismo idioma.
3. Mejorar jerarquia, navegacion y claridad sin sobrecargar la interfaz.
4. Ejecutar los cambios por iteraciones pequenas y verificables.

## Diagnostico Actual

## Lo que ya esta bien

- La app tiene una identidad visual reconocible.
- La paleta calida y la tipografia `Outfit` transmiten cercania y hogar.
- Hay una buena base de fondos, gradientes suaves, tarjetas redondeadas y componentes con personalidad.
- La `home` tiene intencion editorial y se siente mas cercana a producto que a prototipo.
- El sistema de tema claro/oscuro ya tiene una direccion bastante trabajada.

## Problemas principales detectados

### 1. Problemas de encoding visibles

Impacto: muy alto.

- Hay textos con caracteres rotos como `Ã`, `Â`, `ðŸ`.
- Esto afecta labels, mensajes, categorias, textos de onboarding y algunos iconos/textos decorativos.
- Aunque el layout sea bueno, este problema hace que la app se perciba inestable o poco pulida.

### 2. Inconsistencia entre modulos

Impacto: muy alto.

- Algunas pantallas usan bien el sistema de tema y tokens.
- Otras usan mucho `Colors.white`, colores hardcodeados, bordes locales y estilos duplicados.
- Resultado: la app se siente visualmente fuerte en unas secciones y generica en otras.

### 3. Jerarquia visual irregular

Impacto: alto.

- En ciertas pantallas demasiados elementos compiten por atencion.
- Algunas cards "hero", cards secundarias, chips y CTA tienen pesos visuales parecidos.
- Falta una escala mas clara entre encabezado, contenido principal, contenido secundario y acciones.

### 4. Lenguaje de componentes parcialmente fragmentado

Impacto: alto.

- Hay varios estilos de sheet, chips, tab bars, cards y botones.
- No siempre comparten mismos radios, paddings, bordes o sombras.
- La app parece hecha con buenas decisiones locales, pero no termina de sentirse como un sistema unico.

### 5. Copy y tono de producto mejorables

Impacto: medio-alto.

- Hay textos correctos pero poco refinados.
- Se mezclan tonos: utilitario, emocional, gamificado y administrativo.
- Algunas microcopias pueden ser mas claras y mas "producto", sobre todo en auth, rewards y settings.

### 6. Calidad visual desigual en modulos de finanzas y rewards

Impacto: medio-alto.

- `Home` y `Settings` muestran una direccion mas madura.
- `Expenses`, `Rewards` y algunos sheets tienen momentos muy buenos, pero otros se sienten mas funcionales que premium.

### 7. Riesgo de degradacion futura

Impacto: medio.

- Sin reglas visuales concretas, cada nueva pantalla puede agregar una variante mas.
- Eso haria que la deuda de UI siga creciendo.

## Vision Visual Recomendada

## Direccion de producto

HomeSync deberia sentirse como:

- una app de hogar compartido,
- emocional pero no infantil,
- premium pero accesible,
- utilitaria pero amable,
- ordenada y confiable para tareas y finanzas,
- con pequenos toques ludicos bien controlados.

## Principios visuales

### Calidez funcional

La app debe verse humana y cercana, pero seguir siendo clara para tareas, finanzas y coordinacion.

### Menos ruido, mas foco

Cada pantalla deberia tener una sola idea principal y una accion primaria obvia.

### Consistencia por encima de creatividad aislada

Es mejor repetir bien 6 patrones de calidad que inventar 20 variantes parecidas.

### Premium silencioso

El valor premium debe venir de ritmo, espaciado, claridad, motion y detalles, no de adornos excesivos.

## Roadmap de Mejora

## Fase 0. Blindaje de calidad

Objetivo: evitar que sigan entrando defectos visuales basicos.

### Tareas

- Crear este plan como documento vivo.
- Agregar checklist de revision visual por PR.
- Definir reglas basicas de UI:
  - no usar `Colors.white` o `Colors.black` directo salvo casos justificados,
  - no crear radios o sombras arbitrarios sin token,
  - no introducir texto visible sin validar encoding,
  - no agregar variantes nuevas de cards/chips/buttons si ya existe una equivalente.

### Entregables

- `UI_VISUAL_IMPROVEMENT_PLAN.md`
- checklist corta de criterios visuales para cambios futuros

## Fase 1. Reparacion urgente de percepcion

Objetivo: corregir todo lo que hoy hace que la app parezca menos profesional.

### 1.1 Corregir encoding en textos visibles

#### Alcance

- Auth
- Dashboard
- Expenses
- Rewards
- Settings
- Tasks
- Helpers de categorias y labels globales

#### Tareas

- Reemplazar textos rotos por UTF-8 valido.
- Revisar categorias con acentos y emojis mal serializados.
- Validar snackbars, dialogs, labels, tabs, CTA y placeholders.
- Revisar archivos de soporte de colores/categorias que hoy mezclan strings mal codificados.

#### Criterio de aceptacion

- Ninguna pantalla principal muestra caracteres rotos.
- Ning?n string visible contiene patrones de mojibake en pantallas principales.

### 1.2 Unificar copy base

#### Tareas

- Estandarizar titulos y subtitulos.
- Definir tono por modulo:
  - Auth: confianza + claridad.
  - Home: estado del hogar + calidez.
  - Tasks: accion + organizacion.
  - Finanzas: claridad + control.
  - Rewards: juego + elegancia.
  - Settings: calma + control.

#### Criterio de aceptacion

- Los textos se sienten escritos por el mismo producto.
- Las acciones usan verbos consistentes.

### 1.3 Reemplazar assets remotos criticos

#### Tareas

- Evitar `Image.network` para iconos clave como el logo de Google en login.
- Mover assets criticos a local si son parte del flujo principal.

#### Criterio de aceptacion

- Login no depende de una imagen remota para verse correcto.

## Fase 2. Consolidacion del sistema visual

Objetivo: hacer que la app se vea consistentemente "HomeSync" en todos los modulos.

### 2.1 Definir tokens faltantes

#### Tareas

- Revisar y ampliar tokens de:
  - superficies,
  - border radii,
  - sombras,
  - espaciados,
  - estados de seleccion,
  - colores semanticos,
  - fondos de chips y pills,
  - gradientes hero.

#### Resultado esperado

- Menos estilos inline.
- Menos decisiones visuales sueltas.

### 2.2 Estandarizar componentes base

#### Componentes a unificar

- Hero cards
- Section headers
- Bottom sheets
- Dialogs
- Chips
- Tabs segmentadas
- CTA primario/secundario
- Empty states
- Loading states
- Banner/feedback states

#### Criterio de aceptacion

- Cada patron tiene una sola implementacion o una familia bien definida.
- Se reducen variantes duplicadas.

### 2.3 Reforzar dark mode

#### Tareas

- Revisar componentes que aun dependen de blancos duros o colores no tematizados.
- Revisar contraste de textos secundarios y pills.

#### Criterio de aceptacion

- No hay superficies que "rompan" visualmente el dark mode.

## Fase 3. Rediseño por pantalla

Objetivo: pulir experiencia modulo por modulo sobre un sistema ya coherente.

## 3.1 Login y Auth

### Estado actual

- Buena base emocional.
- Fondo con blobs y glass bien orientado.
- El formulario todavia puede sentirse mas premium y mas confiable.

### Mejoras

- Refinar copy:
  - menos frases genericas,
  - mas claridad sobre beneficio y seguridad.
- Mejorar composicion vertical:
  - reducir sensacion de bloque central aislado,
  - reforzar aire arriba/abajo.
- Unificar radios y elevacion del formulario.
- Llevar el boton Google a un nivel visual igual de cuidado que el CTA principal.
- Revisar densidad de sombras para que no parezca "dribbblizado".

### Resultado buscado

- Login calido, limpio y muy confiable.

## 3.2 Home

### Estado actual

- Es una de las pantallas mejor encaminadas.
- Tiene personalidad, jerarquia y movimiento.

### Mejoras

- Afinar jerarquia entre hero, resumen financiero y secciones.
- Dar mas respiro entre bloques grandes.
- Reducir pequenas competencias entre chips, cards y CTA flotante.
- Revisar naming de acciones:
  - "Nueva Accion" puede ser mas especifica o mas humana.
- Consolidar estilo de listas y empty states para que combinen mejor con el hero.

### Resultado buscado

- Una home editorial, clara y energica, con foco inmediato.

## 3.3 Tasks

### Estado actual

- Buen trabajo en filtros, cards y estructura.
- Puede ordenarse mejor para sentirse menos cargada.

### Mejoras

- Reforzar separacion entre filtros, contenido y acciones.
- Simplificar visualmente chips de categoria y de busqueda.
- Unificar cards expandidas/colapsadas.
- Hacer que estados vacios y grupos de categorias respiren mas.
- Revisar saturacion de pills y badges por tarea.

### Resultado buscado

- Pantalla utilitaria, agil y escaneable.

## 3.4 Expenses

### Estado actual

- Tiene bastante funcionalidad.
- Visualmente es de los modulos que mas alterna entre muy bueno y muy crudo.

### Mejoras

- Consolidar la tarjeta resumen principal como pieza hero del modulo.
- Unificar cards del feed, metas y recurrentes.
- Reducir uso de blanco duro.
- Mejorar separadores de fechas y grupos.
- Revisar sheets de crear meta y contribuciones:
  - mas consistencia con el resto del producto,
  - menos apariencia de modal improvisado.

### Resultado buscado

- Finanzas claras, elegantes y creibles.

## 3.5 Rewards

### Estado actual

- Buena idea de producto.
- Necesita mas cohesion para no sentirse una mini app distinta.

### Mejoras

- Integrar rewards al mismo lenguaje visual del resto.
- Refinar hero y secciones para que se sientan menos "cards apiladas".
- Mejorar la boutique:
  - categorias mas sobrias,
  - cards mas consistentes,
  - mejor manejo de icons/emojis.
- Revisar challenge semanal para que luzca importante sin romper sistema.

### Resultado buscado

- Gamificacion elegante, no infantil.

## 3.6 Shopping

### Mejoras

- Alinear estructura con Tasks y Expenses.
- Revisar jerarquia del item y acciones.
- Integrar mejor estados completado, pendiente y agregado rapido.

## 3.7 Stats

### Mejoras

- Simplificar lectura de datos.
- Evitar exceso de decoracion si afecta claridad.
- Unificar tabs, cards metricas y graficos bajo una misma densidad visual.

## 3.8 Settings

### Estado actual

- Ordenada y relativamente madura.

### Mejoras

- Refinar secciones para que no todo tenga el mismo peso.
- Mejorar el tratamiento de switches y cards de preferencia.
- Hacer que Premium se vea menos "modo simulador" y mas "area de beneficios".
- Revisar zona de peligro para mayor claridad y serenidad.

### Resultado buscado

- Configuracion clara, premium y tranquila.

## Fase 4. Motion, feedback y microinteracciones

Objetivo: que el movimiento sume calidad sin distraer.

### Tareas

- Definir duraciones base y curvas comunes.
- Revisar stagger y entrance animations para que no se repitan demasiado.
- Reforzar transiciones de:
  - tabs,
  - bottom sheets,
  - dialogs,
  - cambios de seleccion.
- Revisar haptics para que acompañen solo acciones importantes.

### Criterio de aceptacion

- La app se siente fluida, no sobreanimada.

## Fase 5. Accesibilidad y legibilidad

Objetivo: mejorar calidad real, no solo look.

### Tareas

- Revisar contraste en claro y oscuro.
- Revisar tamano minimo de labels y chips.
- Validar targets tactiles.
- Revisar consistencia de iconografia.
- Revisar textos largos en pantallas chicas.

### Criterio de aceptacion

- La app sigue viendose bien y siendo entendible en uso real, no solo en mockups.

## Fase 6. Gobernanza visual

Objetivo: que las mejoras no se pierdan con el tiempo.

### Tareas

- Crear mini guia de UI interna.
- Documentar componentes reutilizables.
- Registrar decisiones visuales clave.
- Crear checklist de revision para pantallas nuevas.

## Priorizacion Ejecutiva

## Prioridad P0

- Corregir encoding.
- Corregir textos visibles rotos.
- Reducir hardcodes visuales mas graves.
- Alinear componentes base de alto trafico.

## Prioridad P1

- Home, Tasks, Expenses y Rewards.
- Bottom sheets y dialogs.
- Jerarquia y spacing global.

## Prioridad P2

- Shopping, Stats, refinamientos de motion.
- Ajustes finos de dark mode.
- Documentacion de sistema visual.

## Iteraciones Recomendadas

## Iteracion 1

Objetivo: reparar percepcion de calidad.

### Alcance

- encoding
- copy base
- login
- textos globales

### Resultado

- la app deja de verse rota
- mejora inmediata de confianza

## Iteracion 2

Objetivo: consolidar sistema.

### Alcance

- theme tokens
- chips
- cards
- tab bars
- sheets

### Resultado

- consistencia visual transversal

## Iteracion 3

Objetivo: pulir modulos clave.

### Alcance

- home
- tasks
- expenses
- rewards

### Resultado

- experiencia mas premium y coherente

## Iteracion 4

Objetivo: refinamiento final.

### Alcance

- settings
- shopping
- stats
- motion
- dark mode
- accesibilidad

## Quick Wins inmediatos

Estas son las mejoras con mejor relacion impacto/esfuerzo:

1. Corregir todos los strings con encoding roto.
2. Reemplazar `Image.network` del login por asset local o icono estable.
3. Crear una sola familia de cards base reutilizable.
4. Crear una sola familia de section headers.
5. Reducir `Colors.white` hardcodeado en `Expenses`, `Rewards` y `Settings`.
6. Refinar copy visible de auth, rewards y settings.

## Primera ejecucion propuesta

Para empezar de forma segura y con alto impacto:

### Paso 1

Corregir encoding y copy visible en archivos de alto trafico.

### Paso 2

Crear reglas visuales base para evitar seguir agregando estilos hardcodeados.

### Paso 3

Tomar `Login` y `Expenses` como primer bloque de refinamiento real.

## Checklist de aceptacion final

- No hay caracteres rotos en pantallas principales.
- El tema claro/oscuro se mantiene consistente.
- Los componentes repetidos comparten el mismo lenguaje visual.
- Cada pantalla tiene una accion primaria clara.
- La app se percibe mas estable, premium y cuidada.
- Las nuevas pantallas ya no aumentan la deuda visual.

## Estado

- Plan creado.
- Primera prioridad definida: encoding + consistencia base.
- Siguiente paso recomendado: ejecutar Iteracion 1.

## Bitacora de ejecucion

### 2026-03-20 - Iteracion 1 en curso

#### Hecho

- Corregidos textos visibles de `Login`.
- Corregidos labels rotos en `Shopping`.
- Corregidos textos y picker de iconos en `Rewards`.
- Corregidos normalizadores de categorias y acentos en `app_colors.dart`.
- El plan queda actualizado a medida que avanzamos.
- Reemplazado el logo remoto de Google en login por un icono estable local al bundle de la app.
- Refinadas superficies y microcopias visibles en `Rewards`.
- Refinado el sheet de proyeccion en `Expenses` para que respete mejor el theme.
- Reparada la seccion hero de `Rewards` para evitar errores de layout (`RenderBox was not laid out`).
- Eliminados null assertions fragiles en `Rewards` (`grouped[category]!`, `reward.description!`).
- Endurecido `_buildRewardsGrid` para manejar constraints no finitos y prevenir tarjetas sin layout.
- Robustecido `RewardModel.fromJson` con parseo tolerante a `null` y fechas invalidas.
- `flutter analyze lib/features/rewards` sin errores de compilacion (solo hints de `const`).
- Limpiado mojibake en `Rewards` (acentos, signos y emojis visibles).
- Compactadas las cards de `Premios` para que entren mas items por pantalla y se reduzca el espacio en blanco.
- Rediseñadas las cards de `Premios` con una grilla 2-up real, icono protagonista y CTA mas premium sin repetir la categoria dentro de cada tarjeta.
- Rediseñada la tarjeta de `Evento especial` con mejor jerarquia, menos bloques apilados y una franja de accion mas profesional.

#### Siguiente bloque

- Validar en dispositivo que `Premios` vuelva a renderizar sin spam de excepciones de semantica.
- Corregir mojibake restante en copy visible de `CoupleChallenge` y mensajes secundarios.
- Seguir reduciendo hardcodes visuales en `Rewards` y `Expenses` hacia `context.theme`.
- Unificar componentes base reutilizables para cards, pills y sheets.
- Consolidar `Progreso` como experiencia emocional centrada en `Duelo semanal`, con XP rival oculta y lenguaje visual alineado al resto.
- Extender la nueva navegacion segmentada a las secciones con tabs para unificar el sistema visual transversal.
- Confirmar y aprovechar la relacion `Duelo semanal -> coins` en la futura arquitectura de producto.
- Avanzar la fusion funcional de `Premios` + `Duelo semanal` bajo una seccion compartida (`Pareja`) con tabs internas `Duelo | Premios`.
- Refactorizar la navegacion para reemplazar `Premios` por una seccion mas amplia (`Pareja` o equivalente) con tabs internas `Duelo | Premios`.
- Sacar `Evolucion` de la navegacion principal y redefinir si sobrevive como vista secundaria o se elimina.
- Mover `Logros` a una entrada mas personal bajo el avatar/perfil junto con `Perfil`, `Racha` y `Ajustes`.
- Rediseñar la ventana de `Ganador semanal` para que se vea premium, especial y totalmente alineada con el nuevo lenguaje visual de la app.
