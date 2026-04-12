# Blueprint de Producto: Modo Familia

## Objetivo

Definir `Modo Familia` como una experiencia completa, coherente y ejecutable antes de seguir implementando pantallas o lógica.

Este documento responde:

- quién usa el modo familia
- qué ve cada tipo de miembro
- cómo se separan roles visibles y permisos
- cómo funciona cada pestaña
- cómo se diferencian adultos e hijos
- cómo debe funcionar el sistema financiero familiar
- qué entra en el MVP y qué queda para una segunda fase

La idea no es solo tener una visión linda, sino un contrato claro de producto para no seguir improvisando.

## Tesis del producto

`Familia` no debe ser:

- `Pareja` con más avatares
- un hogar genérico sin identidad
- una app infantil de tareas aislada

`Familia` sí debe ser:

- un sistema de coordinación del hogar
- con administración adulta
- participación infantil
- tareas del hogar
- compras compartidas
- finanzas segmentadas
- recompensas y motivación

## Principio rector

Cada decisión de `Familia` debe responder explícitamente:

- qué ve un adulto admin
- qué ve un adulto no admin
- qué ve un hijo
- qué es un rol visible
- qué es un permiso
- si una acción pertenece a finanzas adultas o a dinero del hijo

Si una funcionalidad no puede responder eso con claridad, todavía no está lista.

## Tipos de usuario

Modo Familia tiene tres perfiles operativos.

## 1. Adulto admin

Es un adulto que además administra el hogar.

Necesita:

- coordinación diaria del hogar
- finanzas familiares
- gestión de miembros
- configuración de recompensas
- control del funcionamiento familiar

## 2. Adulto no admin

Es un adulto participante del hogar, pero sin control estructural.

Necesita:

- ver y usar el hogar
- participar en tareas
- participar en compras
- usar finanzas familiares
- ver actividad y progreso del hogar

No necesita administrar miembros ni configuración sensible.

## 3. Hijo

Es un integrante participante, no administrador.

Necesita:

- una experiencia simple
- sus tareas
- su progreso
- ranking semanal
- monedero
- tienda de recompensas
- participación limitada en compras

No necesita ver la superficie financiera adulta del hogar.

## Modelo de miembro

Cada miembro familiar debe modelarse con 3 dimensiones separadas.

## A. Tipo de miembro

Estructura base del integrante.

- `adult`
- `child`

## B. Rol visible

Es la identidad visible en UI.

Set inicial de MVP:

- `Padre`
- `Madre`
- `Hijo`
- `Hija`

Set futuro posible:

- `Tutor/a`
- `Abuelo/a`
- `Otro integrante`

## C. Permiso

Es la capacidad operativa interna.

- `admin`
- `non-admin`

## Regla clave

El usuario debe ver principalmente el `rol visible`, no el permiso.

Ejemplos:

- mostrar `Padre`, no `admin`
- mostrar `Hija`, no `member`

El permiso puede aparecer como badge secundario o en edición/configuración, pero no como identidad principal.

## Ejemplos válidos

- `Padre + adult + admin`
- `Madre + adult + admin`
- `Madre + adult + non-admin`
- `Hijo + child + non-admin`
- `Hija + child + non-admin`

## Pilares del modo familia

Modo Familia se apoya en 5 pilares:

1. Coordinación diaria
2. Finanzas del hogar
3. Participación infantil
4. Economía de recompensas familiar
5. Gestión del hogar

## Navegación principal

Pestañas del modo familia:

1. `Inicio`
2. `Tareas`
3. `Finanzas`
4. `Familia`
5. `Compras`

La navegación puede mantener la misma estructura externa de la app, pero el contenido de cada pestaña debe cambiar según el perfil.

## Resumen por perfil

## Adulto admin

Ve:

- home adulta
- finanzas del hogar
- tareas del hogar
- miembros y permisos
- compras
- recompensas

Puede:

- administrar miembros
- editar roles visibles
- invitar y quitar miembros
- configurar recompensas
- ver y operar finanzas del hogar

## Adulto no admin

Ve:

- home adulta
- finanzas del hogar
- tareas
- compras
- integrantes
- recompensas

Puede:

- usar tareas
- usar compras
- registrar gastos
- ver balances del hogar
- canjear recompensas

No puede:

- editar estructura del hogar
- cambiar roles de otros
- quitar miembros
- tocar settings sensibles

## Hijo

Ve:

- home infantil
- tareas propias
- ranking semanal
- monedero
- tienda
- compras si se decide mantenerlas visibles

No ve:

- balance entre adultos
- liquidaciones entre padres
- configuración del hogar
- edición de miembros

## Matriz de experiencia por perfil

`Familia` no debe diseñarse como una sola app con permisos escondidos.

Debe diseñarse como dos superficies principales dentro del mismo hogar:

1. `superficie adulta de coordinación`
2. `superficie infantil de participación`

Y dentro de la superficie adulta, diferenciar qué puede hacer un `admin` y qué puede hacer un `non-admin`.

La pregunta correcta para cada sección no es solo `quién tiene permiso`, sino:

- qué necesita ver este perfil
- qué necesita hacer este perfil
- qué información le sobra o le genera ruido

### Regla general

Para cualquier pestaña del modo `Familia`, siempre debemos poder responder:

- qué ve un `adulto admin`
- qué ve un `adulto no admin`
- qué ve un `hijo`
- qué puede hacer cada uno

Si una pantalla no responde eso con claridad, todavía no está bien diseñada.

### 1. Inicio

#### Adulto admin

Ve:

- saludo
- contexto del hogar
- finanzas adultas
- tareas del hogar con foco en responsables
- movimientos del hogar
- compras del hogar

Hace:

- coordina
- detecta qué falta
- identifica quién tiene cada tarea

#### Adulto no admin

Ve:

- casi la misma home adulta
- finanzas adultas
- tareas con responsables
- compras
- actividad del hogar

Hace:

- participa
- completa
- registra gastos
- coordina en el día a día

#### Hijo

Ve:

- saludo
- monedero
- sus tareas
- ranking
- tienda

Hace:

- ejecuta sus tareas
- sigue su progreso
- gana monedas

No necesita:

- ver coordinación global del hogar con el mismo nivel de detalle
- ver balances o settlement de adultos

### 2. Tareas

#### Adulto admin

Ve:

- tareas del hogar
- responsables
- vencimientos
- sin asignar

Hace:

- crea
- asigna
- reprograma
- filtra por integrante

#### Adulto no admin

Ve:

- tareas del hogar
- responsables
- urgencia

Hace:

- completa
- colabora
- puede crear tareas si el producto lo habilita

#### Hijo

Ve:

- principalmente sus tareas
- progreso del día
- recompensas asociadas

Hace:

- completa sus tareas

No necesita:

- una vista de coordinación global
- demasiada información sobre responsables porque normalmente el responsable es él

### 3. Finanzas

#### Adulto admin

Ve:

- finanzas del hogar
- método de aporte adulto
- balances
- gastos
- recurrentes

Hace:

- configura modo igual o proporcional
- registra y revisa movimientos

#### Adulto no admin

Ve:

- finanzas del hogar
- balances
- gastos
- recurrentes

Hace:

- registra gastos
- consulta balances

#### Hijo

Ve:

- monedero y tienda como economía propia

No ve:

- balances entre adultos
- reparto del hogar
- configuración financiera adulta

### 4. Familia

#### Adulto admin

Ve:

- integrantes
- roles visibles
- permisos
- ajustes del hogar

Hace:

- invita
- edita rol visible
- ajusta configuración sensible

#### Adulto no admin

Ve:

- integrantes
- roles visibles
- estructura del hogar

Hace:

- edita su propio perfil si aplica

#### Hijo

Ve:

- integrantes del hogar
- vínculos básicos

No hace:

- gestión estructural

### 5. Compras

#### Adulto admin

Ve:

- lista completa
- prioridad
- estado

Hace:

- agrega
- edita
- marca comprado
- convierte en gasto

#### Adulto no admin

Ve:

- lista completa
- estado

Hace:

- agrega
- marca comprado
- colabora con la lista

#### Hijo

Ve:

- versión simple de la lista

Hace:

- puede colaborar marcando o viendo qué falta, si el MVP lo mantiene habilitado

No necesita:

- convertir compras en gasto adulto

### 6. Rewards / tienda

#### Adulto admin

Ve:

- catálogo
- canjes
- recompensas familiares

Hace:

- crea y ajusta recompensas

#### Adulto no admin

Ve:

- catálogo
- canjes

Hace:

- usa recompensas

#### Hijo

Ve:

- tienda
- premios posibles
- monedas disponibles

Hace:

- canjea
- sigue motivación y progreso

## Pestaña por pestaña

## 1. Inicio

La home debe ser distinta para adultos e hijos.

No debe existir una sola home genérica.

## Inicio para adulto

La home adulta debe sentirse más cercana a `Pareja`, pero con lógica de hogar.

### Orden recomendado

1. Saludo
2. Subtítulo/contexto del hogar
3. Finanzas familiares
4. Tareas de hoy
5. Movimientos del hogar
6. Compras del hogar
7. Ranking semanal como bloque secundario

### 1. Saludo

Debe incluir:

- nombre del usuario
- fecha actual
- avatar/perfil
- acceso a notificaciones

Tono:

- cálido
- simple
- muy cercano a la home de pareja

### 2. Contexto del hogar

Frase breve debajo del saludo.

Ejemplos:

- `Todo lo importante del hogar, en un vistazo`
- `Hoy toca coordinar la casa`

No debería ser un bloque pesado.

### 3. Finanzas familiares

Visible para:

- `adulto admin`
- `adulto no admin`

No visible para:

- `hijo`

Debe sentirse como una evolución del widget de balance de pareja.

#### Regla de negocio

El balance superior solo debe considerar a los adultos.

Los hijos no participan del settlement principal.

#### Si hay 2 adultos

Usar una experiencia muy similar a `BalanceCard` de pareja:

- estado actual
- quién está arriba o abajo
- movimientos recientes
- acceso a finanzas

#### Si hay más de 2 adultos

Usar una vista más agregada:

- balance global del hogar
- total de gastos recientes
- resumen de participantes adultos

### 4. Tareas de hoy

Visible para adultos.

Debe mostrar solo:

- tareas programadas para hoy
- tareas vencidas
- tareas recurrentes del día

No debe mostrar:

- todo el backlog
- tareas futuras sin relevancia inmediata

Objetivo:

- que la home responda `qué hay que hacer hoy`

### 5. Movimientos del hogar

Visible para adultos.

Debe funcionar como feed operativo del hogar.

No debe verse como chat.

El patrón de burbujas izquierda/derecha sirve en `Pareja` porque hay dos actores claros.

En `Familia`, con varios integrantes, ese formato se vuelve confuso, repetitivo y poco útil para escanear.

### Decisión de diseño

`Movimientos del hogar` pasa a ser una `timeline / feed de actividad`.

No es conversación.

Es registro rápido de lo que pasó en casa.

Eventos válidos:

- tarea completada
- compra marcada como hecha
- gasto agregado
- recompensa canjeada
- dinero otorgado a un hijo

No debe ser un feed vacío o decorativo.

### Qué debe mostrar cada item

Cada item debe responder 4 preguntas:

- quién hizo la acción
- qué hizo
- cuándo pasó
- qué impacto tuvo

Por eso, cada item debe incluir:

- avatar del integrante
- nombre del integrante
- acción principal
- detalle breve
- tiempo relativo
- badges de impacto

### Ejemplos correctos

- `Mili completó una tarea`
  `Orden general de la casa`
- `Tomi completó una tarea`
  `Guardar / vaciar lavavajillas`
- `Ana registró un gasto`
  `Supermercado`
- `Blas marcó una compra`
  `3 productos comprados`

### Componentes visuales del item

Cada tarjeta de actividad debe tener:

- avatar pequeño a la izquierda
- bloque central con titular y detalle
- icono de tipo de acción a la derecha
- fila de metadata abajo

La metadata puede incluir:

- `Hace 12m`
- `+15 XP`
- `+1 coin`
- `$ 12.500`

### Tipos visuales

Usar un icono por tipo:

- tarea: icono de categoría de tarea
- gasto: recibo o billetera
- compra: carrito o check de compra
- recompensa: regalo o estrella

### Jerarquía visual

La línea principal debe ser:

- nombre + acción

La línea secundaria debe ser:

- nombre de la tarea, gasto, compra o premio

Esto mejora mucho el escaneo rápido porque la persona primero entiende `qué pasó` y después `en qué`.

### Cantidad visible en home

En la home no deben mostrarse demasiados eventos.

Regla:

- mostrar entre 3 y 4 eventos máximos
- el resto vive en una vista más completa o panel futuro

### Agrupación futura

No es prioridad del MVP, pero la evolución natural es agrupar por:

- Hoy
- Ayer
- Esta semana

### Qué evitar

- burbujas tipo chat
- alternancia izquierda/derecha
- cards gigantes por evento
- repetir la misma estructura visual como si fuera una conversación
- dar más protagonismo al feed que a tareas o finanzas

### Objetivo del bloque

El usuario adulto debe poder abrir `Inicio` y entender rápido:

- quién estuvo activo
- qué se hizo hoy
- qué movimiento financiero apareció
- si el hogar está avanzando o quieto

### 6. Compras del hogar

Visible para adultos.

Debe mostrar:

- pocos items prioritarios
- cuántos faltan
- acceso rápido a la pestaña completa

### 7. Ranking semanal

Visible para adultos como bloque secundario.

Debe responder:

- quién viene liderando
- cuántas tareas completó cada integrante
- cómo va la semana

No debe competir visualmente con finanzas o tareas.

## Inicio para hijo

La home infantil debe ser más simple, motivadora y personal.

### Orden recomendado

1. Saludo
2. Monedero
3. Tareas de hoy
4. Ranking semanal
5. Tienda
6. Compras opcionales

### 1. Saludo

Simple y directo.

Ejemplos:

- `Hola, Mili`
- `Tus tareas de hoy`

### 2. Monedero

Debe ser protagonista en la home infantil.

Debe mostrar:

- monedas actuales
- monedas ganadas esta semana
- acceso a tienda

### 3. Tareas de hoy

Debe mostrar principalmente:

- tareas asignadas al hijo
- tareas vencidas del hijo
- progreso del día

No debe mezclar tareas del resto del hogar salvo que lo definamos explícitamente.

### 4. Ranking semanal

En chicos debe ser más relevante que en adultos.

Debe sentirse:

- motivador
- claro
- entendible

### 5. Tienda

Debe estar muy visible.

Objetivo:

- conectar tarea -> monedas -> recompensa

### 6. Compras

Opcional en MVP.

Si se muestran:

- deben ser simples
- no deben abrir complejidad financiera adulta

## 2. Tareas

Las tareas son la columna vertebral del modo familia.

## Tareas para adulto admin

Puede:

- ver todas las tareas del hogar
- crear tareas
- asignar tareas
- editar tareas
- reprogramar tareas
- filtrar por integrante
- ver hoy, semana, vencidas
- aprobar o rechazar tareas infantiles cuando el flujo lo requiera

## Tareas para adulto no admin

Puede:

- ver tareas del hogar
- completar tareas
- crear tareas si decidimos habilitarlo
- filtrar por integrante
- aprobar o rechazar tareas infantiles si el producto habilita verificación por cualquier adulto

No puede:

- tocar configuraciones avanzadas del sistema si las hubiera

## Tareas para hijo

Debe ver principalmente:

- sus tareas
- las tareas del día
- progreso simple
- tareas abiertas del hogar para tomar

Puede:

- completar sus tareas
- tomar tareas abiertas

No debería entrar por defecto a una vista de gestión global.

## Regla de completado

Completar una tarea debe impactar de forma consistente en:

- estado de la tarea
- home
- ranking semanal
- actividad reciente
- monedas si aplica
- recompensas si aplica

Si no pasa eso, la experiencia familiar se rompe.

## Reglas operativas del MVP para tareas familiares

Las tareas familiares no deben pensarse solo como una lista fija de responsables.

También deben servir como herramienta para:

- coordinación adulta
- autonomía infantil
- acuerdos entre hermanos
- distribución espontánea de tareas abiertas

## Tipos prácticos de tarea en el MVP

### 1. Tarea asignada a un hijo

- solo ese hijo la puede completar
- un adulto la puede revisar
- al completarse puede pasar por aprobación o verificación adulta

### 2. Tarea asignada a un adulto

- solo ese adulto la puede completar
- no requiere aprobación posterior en el MVP

### 3. Tarea sin asignar

No es una tarea "sin dueño" ni una tarea residual.

Es una `tarea abierta del hogar`.

Sirve para que:

- los hijos se organicen
- dos hermanos acuerden quién la hace
- un adulto la tome si corresponde
- el hogar tenga margen de coordinación real

Por lo tanto:

- una tarea sin asignar debe poder ser visible y elegible
- no debe reservarse solo a adultos
- no debe interpretarse como error de configuración

## Regla de toma de tarea

Las tareas abiertas del hogar deben poder `tomarse`.

Eso significa:

- un hijo puede tomar una tarea abierta
- un adulto puede tomar una tarea abierta
- al tomarla, la tarea pasa a tener responsable

## Regla de completado por responsable

- si la tarea está asignada, solo el responsable la completa
- si la tarea está abierta, primero debe poder tomarse o completarse desde una acción equivalente que deje claro quién la ejecutó
- los hijos no deben completar tareas asignadas a otros
- los adultos no deben cerrar tareas de hijos como si las hubieran hecho ellos, salvo acción administrativa explícita futura

## Regla de aprobación

Para el MVP se recomienda:

- `hijo completa tarea` -> puede requerir aprobación adulta
- `adulto completa tarea` -> queda resuelta sin aprobación adicional

Esto protege:

- sistema de monedas
- recompensas
- justicia entre hermanos
- confianza de los padres en el sistema

## Regla de desaprobación

Un adulto debe poder:

- aprobar una tarea infantil
- rechazar o devolver una tarea infantil

Si la tarea se rechaza:

- vuelve a estado activo
- no entrega recompensa final
- debe poder comunicarse claramente al hijo que necesita corregirla

## Decisión de producto para tareas abiertas

Las tareas sin asignar NO quedan definidas como "solo adultos".

Quedan definidas como:

- `tareas abiertas del hogar`
- disponibles para organización familiar
- especialmente útiles para hijos cuando queremos fomentar autonomía y acuerdos

## 3. Finanzas

Esta es la pestaña más delicada y más importante de definir bien.

## Principio central

`Familia` no debe tener una sola experiencia financiera.

Debe haber dos capas:

1. `Finanzas adultas del hogar`
2. `Dinero del hijo`

## Finanzas adultas del hogar

Es la evolución natural de `Pareja`.

Cubre:

- gastos compartidos del hogar
- quién pagó
- balances entre adultos
- recurrentes
- planificación básica
- historial financiero del hogar

### Modelo de aporte adulto

`Familia` no debe asumir por defecto que los adultos dividen todo `50/50`.

En un hogar con hijos, muchas veces los adultos:

- aportan igual
- aportan en proporción a sus ingresos
- o combinan fondo común con dinero personal

Para el MVP, vamos a soportar 2 modelos cerrados y simples:

1. `Igual`
2. `Proporcional`

No vamos a abrir todavía modelos más complejos por categoría o reglas distintas por gasto.

### Modelo `Igual`

Significa:

- los gastos compartidos del hogar se reparten mitad y mitad entre los adultos
- si hay exactamente 2 adultos, el comportamiento es equivalente al split clásico de pareja

Este modelo sirve como default simple y entendible.

### Modelo `Proporcional`

Significa:

- los gastos compartidos del hogar se reparten según una proporción definida entre los adultos
- esa proporción reemplaza el `50/50`

Ejemplos:

- `60 / 40`
- `70 / 30`
- `80 / 20`

Para MVP, el modelo proporcional se diseña principalmente para hogares con 2 adultos.

Si a futuro hay más de 2 adultos, se podrá extender, pero no es requisito de la primera versión.

### Configuración inicial en onboarding

Durante la configuración inicial de un hogar `Familia`, si se detectan 2 adultos, el setup debe pedir:

1. `¿Cómo quieren dividir los gastos del hogar?`
2. opción `Igual`
3. opción `Proporcional`

Si eligen `Igual`:

- se guarda `50 / 50`
- no hace falta mostrar controles adicionales

Si eligen `Proporcional`:

- aparece una barra o control visual para definir la proporción
- el control debe dejar claro cuánto aporta cada adulto

### Control visual recomendado para MVP

Cuando el usuario elige `Proporcional`, debe aparecer un selector simple y muy legible:

- una barra horizontal
- con dos extremos, uno por cada adulto
- y un valor central visible

Ejemplo de lectura:

- `Blas 60% - Ana 40%`

La UX debe permitir:

- arrastrar el porcentaje principal
- ver reflejado automáticamente el complemento del otro adulto

No hace falta permitir porcentajes ultra finos.

Para MVP:

- pasos de 5% o 10% son suficientes
- límite mínimo razonable para cada lado

### Persistencia

El hogar debe guardar al menos:

- `finance_split_mode`: `equal` o `proportional`
- `adult_a_share`
- `adult_b_share`

Si el modo es `equal`, igual conviene persistir `50 / 50` para simplificar render y cálculos.

### Edición posterior en configuración

La decisión financiera inicial no debe quedar fija.

Debe poder editarse desde configuración del hogar.

Ubicación recomendada:

- `Familia > Ajustes del hogar > Finanzas del hogar`

Ahí debe existir una sección llamada:

- `Modo de aporte adulto`

Con:

- selector `Igual`
- selector `Proporcional`
- barra de proporción si corresponde

### Efecto en la UI

El widget financiero del home y la pestaña `Finanzas` deben leer este modo.

Eso implica:

- si el modo es `Igual`, el balance puede mostrarse con copy similar a pareja
- si el modo es `Proporcional`, el resumen debe dejar claro que el reparto sigue una proporción configurada

Ejemplos:

- `Aporte igual entre adultos`
- `Aporte proporcional 60 / 40`

### Efecto en los cálculos

Todo gasto compartido del hogar entre adultos debe tomar este modelo como default.

Eso impacta:

- carga de gasto
- previsualización del split
- balances del hogar
- resumen del widget de finanzas

### Reglas del MVP

Para mantenerlo implementable:

- el modelo se aplica solo a adultos
- los hijos nunca entran en este split principal
- el modelo por default del hogar es uno solo
- no se permite por ahora configurar un modelo distinto por categoría o por gasto recurrente

### Casos donde no aplica

Si el hogar tiene solo 1 adulto:

- no se muestra configuración de split adulto
- la home no debe hablar de reparto entre adultos
- la pantalla de finanzas debe funcionar como finanzas del hogar sin settlement

Si el hogar tiene más de 2 adultos:

- el MVP no debe abrir configuración proporcional compleja
- se puede caer temporalmente a una versión `igual entre adultos`
- y marcar la configuración avanzada como fase posterior

### Qué ve un adulto admin

- balance del hogar
- gastos recientes
- recurrentes
- movimientos
- acceso a ajustes más sensibles

### Qué ve un adulto no admin

- balance del hogar
- gastos recientes
- recurrentes
- movimientos

Puede participar, pero no administrar la estructura financiera sensible si más adelante la agregamos.

### Qué ve un hijo

No ve la experiencia financiera adulta.

No ve:

- balances entre padres
- settlement de adultos
- deuda entre adultos
- herramientas de ajuste

## Dinero del hijo

Es una capa separada.

No debe colapsarse dentro de la misma lógica de balance adulto.

Cubre:

- monedas
- historial de ganancia
- canjes
- eventualmente mesada
- eventualmente movimientos supervisados

## Decisión de MVP

En MVP:

- adultos sí tienen pestaña `Finanzas` completa
- hijos no ven la pantalla adulta
- hijos usan `Monedero + Tienda` como su primera experiencia financiera
- hogares con 2 adultos pueden elegir `Igual` o `Proporcional`
- esa decisión se toma en onboarding y se puede editar luego

## Fase posterior

Más adelante, la pestaña `Finanzas` para hijos puede tener una versión segura con:

- monedero
- historial de monedas
- historial de mesada
- compras aprobadas

Pero eso no debe entrar en el primer MVP.

## Qué pasa si un hijo usa dinero o compra algo

El documento de producto debe tomar una decisión clara.

### Decisión recomendada para MVP

No modelar todavía compras reales del hijo dentro del settlement principal.

En MVP:

- el hijo gana monedas
- el hijo canjea recompensas
- el hijo puede participar en compras visibles, pero no como actor financiero adulto

### Fase posterior

Agregar una capa de `gasto supervisado del hijo` o `pedido de dinero`.

Ese movimiento:

- se registra como movimiento infantil
- puede ser visible para adultos
- no altera directamente el balance adulto principal

## Conclusión financiera

La regla correcta para `Familia` es:

- `finanzas adultas` para padres/adultos
- `dinero del hijo` como capa distinta
- `split adulto configurable` al menos entre `igual` y `proporcional`

No conviene mezclar a los hijos en la misma vista de balance que los adultos.

## 4. Familia

Esta pestaña debe dejar de ser un hub abstracto.

Debe convertirse en una pestaña de gestión real del hogar.

## Objetivo de la pestaña

Responder:

- quién vive acá
- qué rol tiene cada uno
- quién administra
- cómo se gestiona el hogar

## Estructura recomendada

1. Encabezado del hogar
2. Integrantes
3. Acciones sobre miembros
4. Ajustes del hogar

## 1. Encabezado del hogar

Debe mostrar:

- nombre de la familia
- resumen corto
- cantidad de integrantes

No hace falta un gran bloque conceptual.

## 2. Integrantes

Es el bloque principal.

Cada tarjeta debe mostrar:

- avatar
- nombre
- rol visible
- badge de tipo: `Adulto` o `Hijo`
- badge de `Admin` si aplica

La identidad principal siempre debe ser el rol visible.

### Ejemplo correcto

- `Ana`
- `Madre`
- `Adulto`
- `Admin`

### Ejemplo incorrecto

- `Ana`
- `Member`

## 3. Acciones sobre miembros

### Adulto admin

Puede:

- editar avatar
- editar rol visible
- invitar miembro
- quitar miembro
- cambiar permisos

### Adulto no admin

Puede:

- ver integrantes
- quizá editar su propio perfil si se decide habilitarlo

No puede:

- editar otros
- quitar miembros
- cambiar permisos

### Hijo

Puede:

- ver integrantes

No puede:

- editar estructura
- invitar
- quitar
- cambiar roles

## 4. Ajustes del hogar

Visible principalmente para `adulto admin`.

Debe incluir:

- nombre del hogar
- configuración familiar
- catálogo de recompensas
- reglas futuras

## 5. Compras

Compras es una pestaña común del hogar, con distinto nivel de capacidad según perfil.

## Compras para adulto admin

Puede:

- agregar
- editar
- borrar
- completar
- organizar la lista

## Compras para adulto no admin

Puede:

- agregar
- completar
- editar items simples

## Compras para hijo

En MVP:

- puede ver la lista
- opcionalmente puede marcar como comprado si queremos

No debería abrir flujos financieros adultos desde acá.

## Sistema de recompensas

Las recompensas son centrales en familia, especialmente para chicos.

Deben existir tres niveles:

1. Recompensas personales para chicos
2. Recompensas personales para adultos
3. Recompensas compartidas familiares

## Recompensas de chicos

Ejemplos:

- postre
- elegir cena
- tiempo de pantalla
- videojuego
- salida

## Recompensas de adultos

Ejemplos:

- tiempo personal
- hobby budget
- salida personal

## Recompensas familiares

Ejemplos:

- noche de peli
- pedir comida
- salida familiar
- plan del fin de semana

## Ranking semanal

El ranking debe ser semanal, no hiperactivo en tiempo real.

Debe apoyarse en:

- tareas completadas
- monedas ganadas
- participación en el hogar

## Adultos

Lo ven como un resumen secundario.

## Hijos

Lo ven como una pieza central de motivación.

## Matriz de permisos cerrada

## Adulto admin

Puede:

- ver finanzas adultas
- registrar gastos
- gestionar miembros
- editar roles visibles
- editar permisos
- invitar y quitar miembros
- configurar recompensas
- tocar settings sensibles

## Adulto no admin

Puede:

- ver finanzas adultas
- registrar gastos
- usar tareas
- usar compras
- ver integrantes
- canjear recompensas

No puede:

- editar permisos
- editar estructura del hogar
- quitar miembros
- cambiar configuración sensible

## Hijo

Puede:

- ver sus tareas
- completar tareas
- ver ranking
- usar monedero
- usar tienda
- ver integrantes
- participar en compras de forma limitada si lo habilitamos

No puede:

- ver settlement adulto
- gestionar miembros
- editar estructura del hogar
- tocar settings

## MVP cerrado recomendado

Para evitar ambigüedad, el MVP de `Familia` debería cerrarse así:

1. Roles visibles del MVP:
- `Padre`
- `Madre`
- `Hijo`
- `Hija`

2. Tipos estructurales:
- `adult`
- `child`

3. Permisos:
- `admin`
- `non-admin`

4. Home adulta:
- saludo
- contexto del hogar
- finanzas adultas
- tareas de hoy
- movimientos del hogar
- compras

5. Home infantil:
- saludo
- monedero
- tareas de hoy
- ranking
- tienda

6. Finanzas:
- completas para adultos
- no exponer la vista adulta a hijos

7. Pestaña Familia:
- miembros
- roles
- permisos
- ajustes

8. Compras:
- visibles para todos
- con capacidades recortadas en hijos

9. Completar tareas:
- siempre actualiza actividad, ranking y monedas si corresponde

## Decisiones cerradas del MVP

Para que este blueprint sea implementable de forma consistente, estas decisiones quedan cerradas desde ahora.

## 1. Adulto no admin en tareas

`Adulto no admin` sí puede:

- crear tareas
- editar tareas propias o tareas comunes del hogar
- completar tareas
- reasignar tareas simples si el flujo ya existe

`Adulto no admin` no puede:

- cambiar configuraciones estructurales del sistema de tareas
- tocar reglas globales del hogar

### Motivo

En una familia real, un adulto no admin igualmente participa en la coordinación cotidiana.

Si lo dejamos solo como observador, la experiencia queda artificial y poco útil.

### Regla de implementación

El permiso `admin` no debe bloquear la operación normal del hogar.

Debe bloquear solo:

- estructura del hogar
- miembros
- permisos
- configuraciones sensibles

## 2. Compras para hijos

En el MVP, los hijos sí pueden:

- ver la lista de compras
- marcar items como comprados

En el MVP, los hijos no pueden:

- editar estructura compleja de la lista
- borrar items
- disparar lógica financiera adulta

### Motivo

Esto permite participación real en el hogar sin mezclar a los hijos en settlement o administración.

### Regla de producto

Cuando un hijo marca una compra como hecha:

- impacta en la lista
- impacta en actividad del hogar
- puede impactar en ranking o monedas si después decidimos premiar esa acción

Pero:

- no se registra como gasto adulto del hogar por defecto

## 3. Finanzas para hijos en MVP

En el MVP, los hijos no tendrán la pestaña `Finanzas` adulta ni una versión financiera propia completa.

En esta etapa, la experiencia económica infantil vive en:

- `Inicio` a través del monedero
- `Tienda / Recompensas`

### Regla de navegación

La navegación principal puede mantenerse visualmente uniforme si el sistema lo requiere, pero si el hijo toca `Finanzas`, no debe entrar en la experiencia adulta.

La opción recomendada es:

- ocultar la experiencia financiera adulta a hijos
- redirigir eventualmente a una vista segura futura de `Mi dinero`

### Decisión concreta para implementar primero

En la primera entrega:

- adultos ven `Finanzas`
- hijos no usan esa pestaña como feature principal

Si la navegación técnica obliga a mantener la pestaña visible:

- debe abrir una pantalla segura y reducida
- nunca la pantalla adulta

## 4. Centro de gravedad del modo familia

El producto de `Familia` se organiza alrededor de dos centros distintos:

### Para adultos

- coordinación del hogar
- finanzas del hogar
- seguimiento de tareas
- compras
- gestión familiar

### Para hijos

- tareas del día
- motivación
- ranking
- monedas
- canjes

### Conclusión

No hay que diseñar una sola experiencia promedio.

Hay que diseñar dos experiencias complementarias dentro del mismo hogar.

## 5. Prioridad visual y funcional de cada pestaña

Para evitar que cada pantalla quede “mezcla de todo”, el peso de cada pestaña queda definido así.

### Inicio

#### Adultos

- prioridad alta en finanzas
- prioridad alta en tareas del día
- prioridad media en movimientos
- prioridad media en compras
- prioridad baja en ranking

#### Hijos

- prioridad alta en monedero
- prioridad alta en tareas del día
- prioridad alta en ranking
- prioridad media en tienda
- prioridad baja en compras

### Tareas

#### Adultos

- gestión completa del hogar

#### Hijos

- ejecución personal

### Finanzas

#### Adultos

- núcleo funcional

#### Hijos

- fuera del MVP principal

### Familia

#### Adultos admin

- gestión y estructura

#### Adultos no admin

- consulta de miembros

#### Hijos

- vista informativa simple

### Compras

#### Todos

- experiencia compartida

Con capacidades distintas según perfil.

## Qué no entra en el MVP

Para no sobrecargar el sistema, esto queda fuera de la primera entrega:

- finanzas completas para hijos
- mesada compleja
- transferencias reales entre miembros
- gasto infantil integrado al settlement adulto
- demasiados roles alternativos
- reglas avanzadas por edad

## Contrato final del MVP

Si mañana empezáramos a implementarlo, el comportamiento esperado sería este:

### Adulto admin

- entra a una home similar a `Pareja`, pero adaptada a hogar
- ve finanzas adultas arriba
- ve tareas del día del hogar
- ve movimientos y compras
- puede gestionar miembros y configuración en `Familia`

### Adulto no admin

- entra a la misma home adulta
- ve finanzas adultas
- participa en tareas y compras
- no gestiona estructura del hogar

### Hijo

- entra a una home distinta
- ve saludo, monedero, tareas del día, ranking y tienda
- no ve balance adulto
- puede participar en compras de forma limitada
- no administra miembros ni settings

### Miembros del hogar

Siempre se muestran como:

- `Padre`
- `Madre`
- `Hijo`
- `Hija`

Y nunca como:

- `admin`
- `member`

### Finanzas

- pertenecen a los adultos
- los hijos tienen economía propia separada por monedas y recompensas

### Tareas

- son el puente entre coordinación adulta y participación infantil
- deben actualizar actividad, ranking y monedas de forma consistente

## Orden recomendado de implementación futura

1. Identidad familiar
- roles visibles reales
- adulto vs hijo
- admin como permiso

2. Home adulta
- acercarla a pareja
- finanzas adultas arriba
- tareas del día

3. Home infantil
- monedero
- ranking
- tienda

4. Pestaña Familia
- sacar protagonismo al hub abstracto
- priorizar miembros y acciones reales

5. Consistencia de tareas
- completar tarea actualiza todo lo necesario

6. Finanzas familiares adultas
- reutilizar engine de pareja
- excluir hijos del settlement principal

7. Dinero del hijo
- fase posterior

## Conclusión final

`Familia` funciona mejor cuando se la piensa como dos experiencias dentro de un mismo hogar:

- experiencia adulta de coordinación y finanzas
- experiencia infantil de tareas, motivación y recompensas

El error a evitar es intentar que todos vean la misma app.

La regla de oro para seguir diseñando e implementando es:

- los adultos coordinan el hogar
- los hijos participan en el hogar
- ambos pertenecen al mismo sistema
- pero no deben ver ni operar la misma superficie
