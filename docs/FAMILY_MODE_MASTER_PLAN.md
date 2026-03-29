# Family Mode Master Plan

## Objetivo

Dejar `modo familia` como una experiencia de producto completa, coherente y mantenible dentro de HomeSync, con foco en coordinacion real del hogar, gestion clara de miembros, tareas multi-miembro, finanzas familiares y una UX diferenciada del modo pareja.

Este plan busca llevar el modo familia desde su estado actual de "base funcional con adaptaciones" a un estado de "vertical completo" listo para crecer sin arrastrar decisiones pensadas para pareja.

## Resultado Final Esperado

Al terminar este plan, el modo familia deberia cumplir con esto:

- Tener onboarding propio y coherente para un hogar familiar.
- Tener home familiar accionable, no solo informativa.
- Permitir invitar, visualizar y administrar miembros sin huecos UX.
- Mostrar tareas pensadas para varios integrantes del hogar.
- Mostrar finanzas familiares con logica agregada y lenguaje correcto.
- Tener un hub familiar util para coordinacion del hogar.
- Evitar por completo copy, flows o supuestos exclusivos del modo pareja.
- Estar cubierto por tests funcionales y regresion minima.

## Estado Actual

### Lo que ya existe

- El tipo `family` existe como `HouseholdType`.
- El onboarding permite elegir `Familia`.
- La app despacha una home especifica para familia.
- Existe una vista social compartida para `family` y `friends`.
- La infraestructura de household, miembros, tareas, gastos y compras ya soporta hogares compartidos.

### Lo que falta o esta incompleto

- La home familiar tiene CTA sin cablear.
- El flujo de invitacion no esta integrado desde la home/hub.
- No existe una gestion real de roles familiares.
- El onboarding familiar no configura estructura del hogar.
- La experiencia familiar sigue heredando demasiadas decisiones de pareja.
- El hub familiar es descriptivo, pero no operativo.
- Faltan tests de UI y flujos especificos del modo familia.

## Principios de Producto para Familia

### 1. Coordinacion, no romance

El modo familia no debe sentirse como una variacion cosmetica del modo pareja. Su centro es la organizacion del hogar entre varios integrantes.

### 2. Multi-miembro como caso principal

Las pantallas deben asumir naturalmente 3 o mas integrantes. Todo lo que hoy se siente bien con 2 personas debe revisarse para 4, 5 o 6.

### 3. Claridad operacional

Debe quedar claro:

- quien integra el hogar
- quien administra
- quien tiene tareas
- quien pago
- quien debe hacer algo hoy

### 4. Base escalable

No conviene parchear el modo familia con `if family` aislados. Hay que consolidar una arquitectura de capacidades por tipo de hogar y componentes preparados para multi-miembro.

## Vision de Experiencia

## Onboarding Familiar Ideal

El onboarding familiar deberia permitir:

- elegir `Familia`
- definir si el hogar sera usado por adultos solamente o adultos y chicos
- crear o unirse a un hogar
- configurar nombre del hogar
- invitar miembros
- opcionalmente asignar roles visibles
- elegir tareas iniciales familiares

No deberia pasar por configuracion de division romantica de gastos ni usar lenguaje de pareja.

## Home Familiar Ideal

La home familiar deberia responder cuatro preguntas en menos de 10 segundos:

- que hay que hacer hoy
- quien esta participando
- como estamos de gastos
- que paso recientemente

Secciones recomendadas:

- resumen del dia
- integrantes del hogar
- tareas pendientes por persona
- finanzas del mes
- actividad reciente
- accesos rapidos: invitar, crear tarea, registrar gasto, abrir compras

## Hub Familiar Ideal

El hub familiar deberia ser el centro de gestion del hogar:

- miembros
- invitaciones
- roles visibles
- administradores
- acuerdos o notas del hogar
- configuraciones familiares futuras

## Alcance por Fases

## Fase 0. Definicion y saneamiento

### Objetivo

Congelar el contrato funcional del modo familia antes de tocar muchas pantallas.

### Tareas

- Definir alcance del modo familia v1.
- Decidir si `family` y `friends` comparten solo componentes o tambien ciertos flujos.
- Definir roles visibles iniciales:
  - `Administrador`
  - `Adulto`
  - `Hijo/a`
  - `Otro integrante`
- Definir reglas de negocio minimas para familia.
- Listar textos prohibidos o heredados de pareja.

### Entregables

- matriz de capacidades por household type
- reglas de negocio familia v1
- checklist de copy y UX no romantica

### Criterio de salida

No queda ninguna duda sobre que significa exactamente `modo familia` en esta version.

## Fase 1. Cerrar los huecos del MVP actual

### Objetivo

Dejar el modo familia completamente navegable y usable con lo que ya existe.

### Tareas UI

- Conectar campana de notificaciones desde la home familiar.
- Conectar CTA `Invitar` desde la home familiar.
- Conectar `Ver todos` en finanzas.
- Conectar `Ver panel` en tareas.
- Revisar vacios de error/loading/empty state en la home.
- Eliminar strings corruptos o con encoding roto.

### Tareas funcionales

- Reusar el flujo existente de generacion de codigo de invitacion.
- Exponer ese flujo desde home y hub familiar.
- Garantizar que refresh invalide providers correctos.

### Archivos probables

- `flutter_client/lib/features/dashboard/presentation/screens/modes/home_family_view.dart`
- `flutter_client/lib/features/dashboard/presentation/screens/home_screen.dart`
- `flutter_client/lib/features/dashboard/presentation/screens/main_screen.dart`
- `flutter_client/lib/features/settings/presentation/screens/settings_screen.dart`

### Criterio de salida

Una familia puede entrar al modo, invitar gente, navegar a tareas, navegar a finanzas y entender el estado del hogar sin encontrar botones muertos.

## Fase 2. Onboarding familiar propio

### Objetivo

Separar el onboarding de familia del de pareja donde hoy comparten pasos que no corresponden.

### Cambios propuestos

- Crear subflujo especifico para `family`.
- Reemplazar paso de division de gastos por configuracion inicial del hogar.
- Agregar nombre del hogar y mensaje de bienvenida familiar.
- Permitir elegir estructura del hogar:
  - adultos
  - adultos y chicos
- Permitir invitar miembros al final o saltar ese paso.

### UX propuesta

Pasos sugeridos:

1. Bienvenida
2. Identidad personal
3. Tipo de hogar
4. Crear o unirse
5. Configuracion inicial familiar
6. Invitacion
7. Tareas iniciales

### Backend y datos

- Ver si `households.name` ya alcanza o si conviene exponerlo mejor en onboarding.
- Evaluar si necesitamos un campo `family_profile_type` o si eso puede esperar.

### Criterio de salida

El onboarding de familia no contiene lenguaje, decisiones ni configuraciones exclusivas de pareja.

## Fase 3. Modelo de miembros y roles

### Objetivo

Pasar de un esquema binario `owner/member` a una capa de presentacion y organizacion familiar mas rica.

### Estado actual

Hoy existe:

- `role`: `owner/member`
- `display_role`: texto libre

Eso alcanza para mostrar cosas, pero no para ordenar una experiencia familiar robusta.

### Propuesta v1

Mantener `role` tecnico para permisos y profesionalizar `display_role` como rol visible normalizado.

Valores iniciales sugeridos:

- `admin`
- `adult`
- `child`
- `member`

### Tareas

- Definir mapping entre rol tecnico y rol visible.
- Mejorar edicion del `display_role`.
- Mostrar rol visible en cards, detalle de miembros y tareas.
- Agregar validaciones basicas para evitar basura o valores inconsistentes.

### Posible extension futura

- permisos por rol visible
- restricciones para ciertos integrantes
- filtros de tareas por tipo de miembro

### Criterio de salida

Cada integrante de una familia puede verse y entenderse como parte de una estructura real del hogar.

## Fase 4. Home familiar de verdad

### Objetivo

Convertir la home familiar en tablero operativo del hogar.

### Rediseño funcional

#### A. Hero de resumen diario

Debe mostrar:

- saludo
- cantidad de tareas pendientes hoy
- cantidad de gastos nuevos o del periodo
- acceso rapido a acciones clave

#### B. Integrantes

Debe mostrar:

- avatar
- nombre
- rol visible
- estado resumido opcional
- CTA para invitar y ver todos

#### C. Tareas del hogar

Debe mostrar:

- pendientes de hoy
- asignadas por integrante
- vencidas o urgentes
- CTA a panel completo

#### D. Finanzas familiares

Debe mostrar:

- gasto total del mes
- ultimo movimiento relevante
- quienes pagaron recientemente
- CTA a finanzas

#### E. Actividad reciente

Debe priorizar:

- quien creo/completo tarea
- quien registro gasto
- quien se unio al hogar

### Tareas tecnicas

- Revisar providers de dashboard para familia.
- Si hace falta, crear providers especificos `familyHomeSummaryProvider`.
- Evitar duplicar logica entre `family` y `friends` si solo cambia presentacion.

### Criterio de salida

La home familiar sirve como centro real de coordinacion diaria.

## Fase 5. Hub familiar accionable

### Objetivo

Evolucionar el hub familiar para que deje de ser una pantalla informativa.

### Modulos esperados

- listado de miembros
- detalle individual
- rol visible
- invitar miembro
- remover miembro si corresponde
- ver codigo de invitacion
- configurar nombre del hogar
- informacion del hogar

### Funcionalidades clave

- admin puede invitar
- admin puede remover
- cualquier miembro puede ver quienes forman el hogar
- roles visibles pueden editarse con control

### Archivos probables

- `flutter_client/lib/features/dashboard/presentation/screens/household_social_hub_screen.dart`
- `flutter_client/lib/features/household/presentation/screens/members_screen.dart`
- nuevos sheets/dialogs para gestion de miembros

### Criterio de salida

El hub familiar se vuelve el panel de administracion del hogar.

## Fase 6. Tareas adaptadas a multi-miembro real

### Objetivo

Ajustar tareas para que familia no se vea como pareja con mas gente.

### Problemas a revisar

- asignacion pensada implicitamente para 2 personas
- copy de verificacion o reparto no neutral
- ausencia de filtros por integrante
- carencia de agrupacion por responsable

### Mejoras propuestas

- filtros por miembro
- seccion "Hoy por persona"
- tareas sin asignar
- tareas vencidas
- tareas recurrentes familiares
- visualizacion de carga por integrante

### Regla importante

No conviene reescribir toda la feature de tareas en la primera iteracion. Hay que priorizar adaptaciones de alto impacto con bajo riesgo.

### Criterio de salida

Una familia de 4 o mas miembros puede organizarse con claridad desde tareas.

## Fase 7. Finanzas familiares

### Objetivo

Alinear finanzas con un hogar familiar y no con una dinamica de dos personas.

### Revisiones necesarias

- textos que sugieran pareja o "vos vs otra persona"
- balance cards pensadas para split de dos
- flows con supuestos 50/50

### Enfoque v1 recomendado

Para familia v1, priorizar:

- gastos compartidos del hogar
- gasto total del mes
- quien pago
- categorias
- ultimos movimientos

Dejar para mas adelante:

- reparto complejo multi-miembro
- prorrateo por peso personalizado
- cuentas individuales avanzadas

### Criterio de salida

Las finanzas familiares se sienten correctas aunque todavia no sean un sistema contable sofisticado.

## Fase 8. Configuracion del hogar familiar

### Objetivo

Llevar a settings las decisiones permanentes del hogar.

### Configuraciones candidatas

- nombre del hogar
- tipo de hogar
- invitacion
- roles visibles
- administradores
- privacidad de ciertos modulos

### Riesgo

Cambiar `household_type` despues de usar la app puede impactar UI, copy y expectativas. Hay que definir si se permite libremente o con warnings.

### Criterio de salida

El hogar familiar puede mantenerse y administrarse sin depender de workarounds.

## Fase 9. Backend y reglas de negocio

### Objetivo

Asegurar que el backend acompane el modo familia y no solo lo tolere.

### Revisiones

- RPC de invitacion
- RPC de join
- membresia maxima o ilimitada
- permisos de owner/admin
- visibilidad de miembros
- impacto de remover miembros
- consistencia de `display_role`

### Cambios posibles

- nuevas RPC para editar rol visible
- nuevas RPC para renombrar hogar
- endurecer validaciones de miembro/remocion
- auditoria de RLS en tablas relacionadas

### Criterio de salida

El backend expresa claramente las reglas de familia y no depende de convenciones solo del frontend.

## Fase 10. Observabilidad y calidad

### Objetivo

Poder verificar y mantener el modo familia sin romperlo.

### Tests minimos

#### Unit / provider

- resolucion correcta de `HouseholdType.family`
- capacidades correctas del hogar familiar
- providers de home con data vacia, parcial y completa

#### Widget

- render de home familiar
- render de miembros
- estados vacios
- visibilidad de CTA por rol

#### Integration / e2e

- onboarding familia
- crear hogar familiar
- invitar miembro
- abrir hub familiar
- navegar a tareas y finanzas desde la home

### Instrumentacion

- logs por household type
- errores de invitacion
- errores de members management
- eventos clave del onboarding familiar

### Criterio de salida

Podemos tocar el modo familia con confianza razonable.

## Orden de Implementacion Recomendado

### Sprint 1

- Fase 0
- Fase 1

Resultado:

modo familia usable y sin botones muertos

### Sprint 2

- Fase 2
- Fase 3

Resultado:

onboarding y miembros con identidad propia

### Sprint 3

- Fase 4
- Fase 5

Resultado:

home y hub familiar realmente fuertes

### Sprint 4

- Fase 6
- Fase 7

Resultado:

tareas y finanzas bien alineadas a multi-miembro

### Sprint 5

- Fase 8
- Fase 9
- Fase 10

Resultado:

modo familia mantenible, testeado y listo para iterar

## Priorizacion Realista

Si queremos maximizar impacto rapido, el orden pragmatico seria:

1. cerrar huecos de navegacion y CTA
2. mejorar onboarding familia
3. reforzar miembros e invitaciones
4. rediseñar home familiar
5. volver operativo el hub familiar
6. ajustar tareas
7. ajustar finanzas

## Definicion de "Perfecto" para esta etapa

No significa "terminado para siempre". Significa:

- producto claro
- UX consistente
- cero huecos visibles
- arquitectura entendible
- base extensible
- sin herencias molestas del modo pareja

## Riesgos

### Riesgo 1. Hacer demasiados `if family`

Solucion:

centralizar capacidades por tipo de hogar y reutilizar componentes preparados para multi-miembro.

### Riesgo 2. Reescribir demasiado pronto

Solucion:

primero cerrar MVP y luego profundizar en verticales.

### Riesgo 3. Mezclar `family` y `friends`

Solucion:

compartir infraestructura, pero no confundir identidad de producto.

### Riesgo 4. Sobrecomplicar finanzas

Solucion:

para v1 familiar, priorizar claridad de gasto por sobre reparto complejo.

## Checklist Ejecutivo

- [ ] Contrato funcional del modo familia definido
- [ ] Home familiar sin CTA muertos
- [ ] Onboarding familiar propio
- [ ] Invitaciones accesibles desde home y hub
- [ ] Roles visibles de miembros
- [ ] Hub familiar operativo
- [ ] Tareas adaptadas a multi-miembro
- [ ] Finanzas familiares con lenguaje correcto
- [ ] Settings del hogar familiar
- [ ] Tests de familia
- [ ] Logs y observabilidad minima

## Primer Bloque Recomendado para Empezar Ya

El mejor primer bloque para implementar es:

1. cerrar `home_family_view`
2. conectar invitaciones
3. conectar navegacion a tareas y finanzas
4. limpiar copy/encoding
5. revisar onboarding familiar para separar lo de pareja

Ese bloque nos da una mejora visible rapida y deja el terreno listo para el rediseño fuerte.
