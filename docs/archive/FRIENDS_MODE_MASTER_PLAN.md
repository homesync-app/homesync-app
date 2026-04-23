# Friends Mode Master Plan

## Objetivo

Convertir `modo amigos` en una experiencia de producto clara, util y diferenciada dentro de HomeSync, enfocada en convivencia compartida entre roommates, companeros de piso o personas que viven juntas.

La meta no es crear un "grupo social" abstracto, sino una vertical de organizacion domestica para convivencia real:

- tareas del piso
- gastos compartidos
- compras comunes
- miembros del depto o casa
- acuerdos basicos de convivencia

## Decision de Producto Recomendada

### Posicionamiento principal

`Modo amigos` deberia evolucionar a un concepto mas preciso:

`roommates / convivencia compartida`

### Por que

- encaja mejor con las features actuales
- evita ambiguedad entre "amigos" y "gente que vive junta"
- hace mas util la promesa del producto
- ordena el copy
- facilita priorizar tareas, cuentas y compras por encima de features sociales blandas

### Traduccion recomendada en UX

No hace falta borrar el concepto de amigos a nivel tecnico, pero en producto visible conviene tender hacia:

- `Piso`
- `Depto compartido`
- `Casa compartida`
- `Convivencia`
- `Compañeros`

Segun el tono final que elijamos.

## Resultado Final Esperado

Al terminar este plan, el modo amigos deberia:

- tener identidad propia y consistente
- evitar lenguaje heredado de pareja y familia
- tener home de convivencia util y accionable
- permitir invitar y gestionar integrantes sin huecos
- mostrar gastos y tareas de forma natural para varios roommates
- tener un hub del piso operativo
- cubrir compras y actividad como partes centrales de la convivencia
- estar protegido por tests y criterios de regresion

## Estado Actual

## Lo que ya existe

- existe `HouseholdType.friends`
- `roommates` ya mapea internamente a `friends`
- hay home especifica de amigos
- hay copy diferencial
- el onboarding permite elegir `Grupo`
- el hub compartido adapta algunos labels a grupo/convivencia

## Lo que hoy se siente flojo

- la identidad no esta cerrada: mezcla amigos, grupo, piso y roommates
- la home tiene botones sin cablear
- hay texto visible de QA dentro de la UI
- el hub de amigos todavia es mas descriptivo que operativo
- el onboarding no configura nada propio de convivencia
- las tareas y finanzas siguen siendo compartidas pero no realmente optimizadas para roommates

## Principios de Producto

### 1. Convivencia util, no red social

El valor del modo no es "interactuar con amigos", sino convivir mejor.

### 2. Claridad de responsabilidades

Debe quedar claro:

- quien vive en el hogar
- quien hace cada tarea
- quien pago que cosa
- que falta comprar
- que acuerdos basicos rigen

### 3. Baja friccion

La convivencia tiene que resolverse rapido, sin demasiada ceremonia.

### 4. Identidad consistente

No mezclar:

- `amigos`
- `grupo`
- `piso`
- `roommates`
- `hogar`

sin criterio. Hay que elegir una narrativa principal y sostenerla.

## Propuesta de Identidad

## Nombre conceptual recomendado

`Modo convivencia`

## Nombre visible sugerido

Opciones:

- `Piso`
- `Convivencia`
- `Depto`
- `Grupo`

### Recomendacion

Usar:

- tab principal: `Piso` o `Convivencia`
- descripcion de onboarding: `Compartimos piso o depto`

Esto mantiene tono cercano pero aterrizado en el caso de uso real.

## Vision de Experiencia

## Onboarding Ideal

El onboarding de roommates deberia permitir:

- elegir modo convivencia
- crear o unirse a un piso/casa compartida
- definir nombre del hogar
- invitar companeros
- seleccionar tareas iniciales del piso
- opcionalmente definir reglas de gastos o acuerdo simple

No deberia usar lenguaje de pareja ni de familia.

## Home Ideal

La home del modo convivencia deberia responder rapido:

- que hay pendiente hoy
- quien vive aca
- como estan las cuentas
- que falta comprar
- que paso recientemente

Secciones ideales:

- resumen del piso
- integrantes
- tareas de hoy
- cuentas compartidas
- compras urgentes
- actividad reciente

## Hub Ideal

El hub del piso deberia ser el centro operativo de convivencia:

- miembros
- invitaciones
- apodos o alias
- roles visibles
- acuerdos del piso
- nombre del hogar
- reglas basicas

## Alcance por Fases

## Fase 0. Definicion del contrato de producto

### Objetivo

Cerrar semanticamente que es `modo amigos`.

### Tareas

- decidir narrativa principal visible
- unificar copy entre `friends`, `grupo`, `roommates`, `piso`
- definir nomenclatura oficial para:
  - hogar
  - integrantes
  - tab social/hub
  - gastos
  - tareas
- decidir si se renombra en UI sin tocar tipo tecnico

### Entregables

- glosario de producto
- matriz de copy permitido/prohibido
- decision de naming

### Criterio de salida

Ya no hay ambiguedad sobre que representa este modo.

## Fase 1. Cerrar MVP actual

### Objetivo

Dejar el modo amigos completamente navegable y sin fisuras visibles.

### Tareas

- cablear campana de notificaciones
- conectar CTA `Cuentas`
- conectar CTA `Ver todas`
- revisar vacios/loading/error states
- eliminar texto de QA visible en home
- revisar strings rotos por encoding

### Archivos probables

- `flutter_client/lib/features/dashboard/presentation/screens/modes/home_friends_view.dart`
- `flutter_client/lib/features/dashboard/presentation/screens/main_screen.dart`
- `flutter_client/lib/features/dashboard/presentation/screens/home_screen.dart`

### Criterio de salida

Un usuario en modo amigos puede navegar por la experiencia sin encontrar placeholders ni texto interno del equipo.

## Fase 2. Identidad y copy consistentes

### Objetivo

Hacer que todo el modo hable el mismo idioma.

### Problemas actuales

- `Grupo`
- `Mi Piso`
- `amigos`
- `roommates`
- `companeros`
- `hogar`

estan conviviendo de forma poco controlada.

### Tareas

- definir labels por pantalla
- revisar settings, onboarding, tabs y estados vacios
- unificar textos de invitacion
- adaptar mensajes de WhatsApp
- adaptar labels del hub

### Recomendacion de copy

- integrantes: `Compañeros`
- gastos: `Cuentas compartidas`
- tareas: `Tareas del piso`
- hub: `Convivencia`
- hogar: `Piso` o `Depto`

### Criterio de salida

El modo se siente como un producto consistente, no como una suma de nombres alternativos.

## Fase 3. Onboarding de convivencia

### Objetivo

Dar al modo amigos un onboarding pensado para roommates.

### Estado actual

Solo pareja tiene paso propio de division de gastos. Amigos salta directo a tareas.

### Propuesta

Pasos sugeridos:

1. Bienvenida
2. Identidad personal
3. Tipo de hogar
4. Crear o unirse
5. Configuracion del piso
6. Invitacion a companeros
7. Tareas iniciales

### Configuracion del piso

Podria incluir:

- nombre del piso/depto
- cantidad aproximada de integrantes
- acuerdo simple de gastos:
  - gastos compartidos
  - cada uno registra lo suyo
  - despues lo configuramos

### Criterio de salida

El onboarding ya no parece prestado de otros modos.

## Fase 4. Home de convivencia real

### Objetivo

Volver la home de amigos un tablero util para gente que comparte casa.

### Estructura propuesta

#### A. Resumen del piso

- cuantas tareas pendientes hay hoy
- cuantas cuentas quedaron abiertas
- si hay compras pendientes

#### B. Integrantes

- avatar
- nombre
- rol visible
- CTA para invitar/ver todos

#### C. Cuentas compartidas

- gasto total reciente
- ultimos pagos
- quien puso plata
- CTA al detalle

#### D. Tareas del piso

- tareas pendientes
- asignadas o sin asignar
- urgentes o vencidas

#### E. Compras rapidas

- items faltantes
- CTA a lista completa

#### F. Actividad del piso

- quien agrego gasto
- quien completo tarea
- quien se unio

### Criterio de salida

La home se vuelve el centro diario de convivencia.

## Fase 5. Hub del piso operativo

### Objetivo

Evolucionar el hub actual para que sea un panel real de convivencia.

### Modulos esperados

- miembros
- invitaciones
- nombre del piso
- alias de miembros
- roles visibles
- acuerdos del piso

### Funciones clave

- generar codigo
- copiar/compartir invitacion
- ver integrantes
- editar rol visible
- remover integrante si corresponde
- ver informacion del hogar compartido

### Nota de producto

El hub de amigos deberia ser menos "social hub" y mas "panel del piso".

### Criterio de salida

La convivencia se administra desde un solo lugar claro.

## Fase 6. Modelo de miembros para roommates

### Objetivo

Adaptar miembros a un contexto de convivencia compartida.

### Roles visibles sugeridos

- admin
- companero
- invitado frecuente
- encargado

### Posible enfoque simple

Mantener `owner/member` para permisos y usar `display_role` como rol visible curado.

### UX recomendada

- mostrar apodo o nombre corto
- mostrar rol visible opcional
- marcar quien sos vos
- destacar admin solo cuando tenga valor funcional

### Criterio de salida

Los integrantes se entienden como personas que conviven, no solo como usuarios tecnicos.

## Fase 7. Tareas adaptadas a convivencia

### Objetivo

Optimizar tareas para roommates.

### Casos de uso prioritarios

- limpieza
- basura
- baño
- cocina
- compras
- cuentas
- mantenimiento chico del depto

### Mejoras sugeridas

- tareas por area
- tareas recurrentes de convivencia
- filtros por integrante
- agrupacion por responsable
- tareas sin asignar
- tareas de hoy

### Regla de producto

En convivencia, la claridad importa mas que la gamificacion.

### Criterio de salida

Las tareas ayudan a evitar friccion cotidiana entre companeros de piso.

## Fase 8. Cuentas compartidas para roommates

### Objetivo

Hacer que finanzas se sientan adecuadas para gente que comparte alquiler, compras y gastos comunes.

### V1 recomendada

Priorizar:

- gastos comunes
- quien pago
- cuanto va del mes
- balances rapidos
- categorias tipicas:
  - supermercado
  - limpieza
  - servicios
  - alquiler
  - salidas grupales opcionales

### No priorizar aun

- prorrateos complejos avanzados
- reglas contables muy sofisticadas
- settlement completo estilo app financiera pura

### Criterio de salida

La gente puede convivir mejor y entender las cuentas sin complejidad excesiva.

## Fase 9. Compras como feature central

### Objetivo

Elevar compras dentro del modo amigos, porque es una de las features mas naturales para convivencia.

### Oportunidades

- mostrar faltantes en home
- destacar items urgentes
- conectar compras con gastos de manera visible
- permitir limpiar y rearmar listas rapido

### Criterio de salida

La lista de compras deja de ser solo una tab y pasa a ser parte del flujo central de convivencia.

## Fase 10. Acuerdos del piso

### Objetivo

Agregar una capa minima de organizacion blanda sin convertirlo en app de chat.

### Posibles modulos

- reglas de convivencia
- nota fija del piso
- recordatorios comunes
- responsables semanales

### V1 simple

Un bloque de acuerdos cortos o notas del piso ya seria suficiente.

### Criterio de salida

El modo amigos resuelve no solo tareas y plata, sino tambien coordinacion cotidiana.

## Fase 11. Settings y administracion

### Objetivo

Llevar las decisiones permanentes del modo convivencia a settings de forma clara.

### Configuraciones candidatas

- nombre del piso
- tipo de convivencia
- invitaciones
- roles visibles
- administradores
- cambio de household type con warning

### Criterio de salida

El modo puede sostenerse y administrarse en el tiempo.

## Fase 12. Backend y reglas de negocio

### Objetivo

Asegurar que el backend exprese bien las reglas de convivencia.

### Revisiones

- maximo de miembros
- permisos de owner/admin
- join por codigo
- remocion de miembros
- consistencia de `display_role`
- efectos de cambio de household type

### Posibles mejoras

- RPC para editar nombre del hogar
- RPC para editar rol visible
- validaciones mas claras para convivencia

### Criterio de salida

El backend acompana el modo roommates como producto, no solo como alias tecnico.

## Fase 13. Calidad y observabilidad

### Objetivo

Poder evolucionar el modo sin romperlo.

### Tests minimos

#### Unit

- resolucion de `friends` y `roommates`
- capabilities correctas
- copy segun tipo

#### Widget

- render de home friends
- estados vacios
- miembros
- CTA visibles

#### Integration

- onboarding modo amigos
- crear grupo/piso
- unirse por codigo
- navegar home -> cuentas/tareas/compras
- hub del piso

### Observabilidad

- logs por household type
- errores de invitacion
- errores de carga de miembros
- eventos de onboarding convivencia

### Criterio de salida

Tenemos visibilidad minima para mantener el modo sin miedo.

## Orden de Implementacion Recomendado

### Sprint 1

- Fase 0
- Fase 1
- Fase 2

Resultado:

modo convivencia consistente y sin huecos visibles

### Sprint 2

- Fase 3
- Fase 4

Resultado:

onboarding y home propios

### Sprint 3

- Fase 5
- Fase 6

Resultado:

hub y miembros operativos

### Sprint 4

- Fase 7
- Fase 8
- Fase 9

Resultado:

tareas, cuentas y compras muy bien alineadas al caso de uso

### Sprint 5

- Fase 10
- Fase 11
- Fase 12
- Fase 13

Resultado:

modo convivencia robusto, testeado y extensible

## Priorizacion Pragmatica

Si queremos impacto rapido y visible:

1. cerrar home actual
2. eliminar ruido de QA
3. unificar identidad/copy
4. hacer onboarding propio
5. reforzar hub del piso
6. mejorar tareas y cuentas
7. elevar compras

## Definicion de "Perfecto" para esta etapa

`Perfecto` no significa terminado para siempre.

Significa:

- identidad clara
- UX coherente
- utilidad real para convivencia
- cero huecos visibles
- base tecnica ordenada
- margen limpio para crecer

## Riesgos

### Riesgo 1. Mantener demasiada ambiguedad semantica

Solucion:

elegir roommates/convivencia como narrativa dominante.

### Riesgo 2. Compartir demasiado con familia

Solucion:

reutilizar infraestructura, pero diferenciar producto y copy.

### Riesgo 3. Intentar hacer una app financiera compleja

Solucion:

mantener foco en convivencia cotidiana.

### Riesgo 4. Cargar demasiado de "social"

Solucion:

priorizar resolver roces reales del dia a dia.

## Checklist Ejecutivo

- [ ] Naming y narrativa definidos
- [ ] Home friends sin botones muertos
- [ ] Sin textos QA visibles
- [ ] Copy consistente de convivencia
- [ ] Onboarding propio
- [ ] Hub del piso operativo
- [ ] Miembros y roles visibles
- [ ] Tareas adaptadas a roommates
- [ ] Cuentas compartidas claras
- [ ] Compras integradas al centro de experiencia
- [ ] Settings adecuados
- [ ] Tests y observabilidad minima

## Primer Bloque Recomendado para Empezar Ya

El mejor bloque inicial es:

1. cerrar `home_friends_view`
2. limpiar copy y naming
3. eliminar textos QA visibles
4. conectar `Cuentas`, `Ver todas` y notificaciones
5. redefinir onboarding friends como convivencia

Ese bloque ordena identidad y utilidad al mismo tiempo, y deja la base lista para profundizar el resto.
