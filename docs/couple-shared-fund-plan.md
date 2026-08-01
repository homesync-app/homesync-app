# Modo pareja: del saldo personal al fondo compartido

Propuesta de rediseño de la economía del modo pareja. Reemplaza el circuito
actual *"hago tareas → gano moneda personal → compro algo que mi pareja me
debe"* por un fondo común del hogar y un espacio de propuestas sin precio.

Estado: implementado (1.3.0).

Ya está en la app y en la base:

- Propuestas gratuitas y rechazables (`couple_proposals` + RPCs), que son la
  Regla 2 completa.
- Muere la economía de coins en pareja: sin tienda, sin canjes, sin coins en
  el ledger ni en Stats.
- Muere el duelo semanal en pareja: sin ganador, sin ranking, sin card de duelo.
- El desafío semanal deja recuerdo y no crédito.
- El XP sobrevive como progreso personal, tal como argumenta este documento.
  Ojo: la migración original lo había matado junto con las coins; se corrigió
  en `20260801120000_restore_couple_personal_xp.sql`.
- **El fondo compartido** (`20260801130000_couple_shared_fund.sql`): las tres
  tablas de §6, la acumulación dentro de la transacción de completar tarea, el
  ritual de dos llaves, y la celebración que abre una propuesta en vez de
  comprar el plan.
- **El reparto y el ritmo** (`20260801140000_household_contribution_split.sql`):
  la Fase 4 y lo que faltaba de la Fase 6. En Progreso, donde estaba el duelo,
  ahora va el ritmo del hogar contra su propio pasado y una foto de quién hizo
  qué, con la lectura accionable de §5 ("las de cocina cayeron siempre del mismo
  lado"). Los miembros salen en orden de ingreso, nunca por quién hizo más.

Decisiones que este documento dejaba abiertas en §10 y que la implementación
resolvió — el detalle y el porqué están en el encabezado de la migración:

- La meta se cancela sin gastar el fondo, así que llegar nunca obliga a canjear.
- El desbloqueo pide confirmación de **todos** los miembros actuales, no de dos.
- Se puede retirar una confirmación mientras la meta no se haya desbloqueado.
- Cambiar el tipo de hogar no destruye el fondo: solo deja de acumular.
- **Los cosméticos premium quedaron fuera del catálogo a propósito.** El propio
  §10 marca que su solape con lo que vende el paywall es una decisión sin tomar,
  y regalar paletas premium por tareas la tomaría de hecho. El mecanismo soporta
  agregarlos cuando esa decisión exista; hoy todas las metas son celebraciones.

Una precisión sobre "en tareas y **tiempo**": `public.tasks` no tiene ninguna
columna de duración, así que el reparto **no** reporta minutos — inventarlos
sería fabricar datos. Reporta cuántas de las exigentes (dificultad big/heavy)
tomó cada uno, que es el proxy de carga que la app ya le muestra al usuario como
"qué tan demandante es". Si algún día se registra duración real, el modelo tiene
lugar para ella.

Sigue pendiente: la **Fase 6** solo a medias — el duelo ya no se muestra en
pareja y el ritmo ocupó su lugar, pero la reescritura de la pantalla que
menciona la fase ya no aplica: `couple_rewards_screen` (1830 líneas) se borró y
`CoupleConnectionScreen` nació partida en widgets. La calibración de costos de
§10 es provisoria: el catálogo va de 150 a 700 contra tareas de 5 a 50, o sea una
meta chica a ~2 semanas de ritmo normal. Hay que mirarla con uso real.

Contexto de datos: el owner confirma que la base activa es despreciable, así que
el esquema puede rehacerse sin plan de migración de usuarios. Ojo con una
lectura errónea que ya circuló: el comentario de
`20260719120500_consolidate_rls_ledger_and_task_approvals.sql:6` menciona "un
usuario real ve 295 ledger_entries" — es un smoke test de RLS sobre el hogar
demo seedeado en prod, no evidencia de base activa.

Igual, antes de cualquier migración destructiva: **dump de `ledger_entries`,
`rewards` y `reward_redemptions`**. Es higiene barata y habilita rollback.

---

## 1. El principio rector

> **El esfuerzo doméstico alimenta algo que es de los dos.
> Nunca genera un crédito de una persona contra la otra.**

De ahí se derivan tres reglas que resuelven todas las decisiones de detalle:

**Regla 1 — El fondo solo compra planes conjuntos o cosas de la app.
Nunca conducta de una persona.**
Una noche de cine juntos, sí. Una paleta de colores premium, sí. Un masaje que
te debe tu pareja, no. Si el desbloqueo requiere que alguien *sirva* a alguien,
no pertenece a la economía.

**Regla 2 — Los pedidos interpersonales existen, pero son gratis y rechazables.**
Querer un masaje no está mal; está mal *comprarlo*. Los deseos que involucran al
otro salen de la economía y viven en Propuestas: sin precio, sin saldo, sin
deuda pendiente, con "ahora no" siempre disponible y sin penalización.

**Regla 3 — La desigualdad se muestra en tareas y tiempo, nunca en moneda.**
HomeSync existe en parte para hacer visible el trabajo invisible, así que el
desequilibrio *tiene* que verse. Pero expresarlo en moneda invita a "yo gané
más, me merezco más"; expresarlo en tareas invita a "hay que redistribuir". Misma
información, marco distinto. El fondo nunca muestra desglose por persona.

### Qué muere y qué nace

| Muere | Nace |
|---|---|
| Saldo de coins personal en pareja | Fondo común del hogar |
| Tienda de vouchers con precio | Catálogo de desbloqueos conjuntos |
| "Canjear" → "pendiente de entrega" | "Acordar" → se agenda o se hace |
| Duelo semanal con ganador | Ritmo del hogar contra sí mismo |
| Premios que compran consentimiento | Propuestas gratuitas y rechazables |
| Coins por desafío de pareja | Desafío deja recuerdo, no crédito |

**El XP se queda, pero acotado.** Es progreso autorreferencial: subir de nivel no
es un reclamo sobre nadie. Solo las coins eran convertibles en conducta ajena.
Pero el XP se vuelve tóxico apenas se pone en contexto comparativo, así que en
pareja queda bajo cuatro condiciones estrictas:

- Visible **solo para uno mismo**. Nunca el XP del otro.
- Nunca en una vista compartida ni al lado del de la pareja.
- Nunca determina ganador, rango ni estatus.
- Nunca genera bonus competitivo.

Con esas cuatro no hace falta ocultarlo: sin comparación posible, el XP es un
contador personal y nada más.

---

## 2. El fondo compartido

### Mecánica

Cada tarea completada suma al fondo del hogar. Los dos ven crecer el mismo
número. No hay dos saldos que comparar porque hay uno solo.

El fondo llena **una meta activa por vez**, elegida entre los dos de un catálogo
(o creada a mano). Una sola meta activa evita que se vuelva un grind sin
horizonte y hace que el progreso se lea de un vistazo.

### El ritual de desbloqueo

Cuando el fondo llega a la meta, **ninguno puede gastarlo solo**. Aparece un
estado "listo" y hacen falta las dos confirmaciones. Es una cerradura de dos
llaves: impide el gasto unilateral y convierte el momento en algo compartido en
vez de una transacción.

### Qué se puede desbloquear — y la asimetría entre los dos tipos

**Cosméticos de la app** — se desbloquean directo al confirmar.
Paletas premium por tiempo limitado · Marcos de avatar · Temas de temporada ·
Un avatar animado extra.

Son el desbloqueo más limpio del sistema: gratificantes, inmediatos, y
estructuralmente incapaces de generar obligación entre personas. Vale apoyarse
fuerte en ellos.

**Planes del mundo real** — *no* se desbloquean, se proponen.
Noche de cine en casa · Cena afuera · Picnic · Escapada de fin de semana.

Acá hay una trampa que conviene evitar: aunque un plan sea conjunto, sigue
requiriendo plata, tiempo y ganas *en el momento*. Si llegar a la meta significa
"ahora tenemos que ir a cenar", el fondo volvió a fabricar una obligación —
ahora del hogar contra sí mismo en vez de una persona contra la otra, pero
obligación al fin.

Por eso: llegar a la meta **no compra el plan**. Dispara una celebración y abre
una propuesta en el bloque de Propuestas, que se acuerda, se modifica o se
posterga como cualquier otra. El copy no es "desbloquearon: cena afuera" sino:

> **Llegaron a la meta. Elijan juntos cómo quieren celebrarlo.**

El fondo compra el *derecho a celebrar*, no un evento específico agendado.

### Qué se ve

```
Nuestro fondo
─────────────────────────────────
  🪙 340
  ▓▓▓▓▓▓▓▓▓░░  340 / 400 → Noche de cine en casa

  Esta semana sumaron 85 · activos 3 de las últimas 4
```

Sin desglose por persona. Sin "vos aportaste X". El desequilibrio se ve en
Progreso, en tareas y tiempo.

---

## 3. Fondo vs. Metas de ahorro: cómo no confundirlos

Ya existe **Metas** (`savings_goals`), que es un fondo común de **plata real**.
Poner al lado un fondo común de monedas simbólicas es un riesgo de confusión
serio. Se separan en cinco ejes, y la separación tiene que ser visible:

| | Metas de ahorro | Fondo del hogar |
|---|---|---|
| Sustancia | Pesos reales | Monedas simbólicas |
| Cómo entra | Aportás plata | Completás tareas |
| Dónde vive | Finanzas | Espacio de pareja |
| Verbo | "Aportar" | "Sumar" |
| Símbolo | $ | 🪙 |

Regla de copy: **nunca usar "ahorro", "aporte" ni "$" en el fondo**, y nunca
usar "sumar" ni 🪙 en Metas. Si un texto funcionaría igual en las dos pantallas,
está mal escrito.

---

## 4. El espacio de pareja

Reemplaza a `CoupleRewardsScreen`. Tres bloques, en este orden:

### 1. Nuestro fondo
Progreso a la meta activa, aporte de la semana, ritmo. Acción principal:
cambiar meta o desbloquear si está llena.

### 2. Propuestas
Los deseos interpersonales, sin precio.

`couple_rewards_screen.dart:591-741` ya tiene `_buildPendingProposalsSection`,
`_buildProposalCard` y `_showProposalDecisionSheet`, así que **el diseño de
interacción y buena parte de la UI se reusan**. Pero conviene no exagerar el
ahorro: el dominio es nuevo. `RewardModel` exige `cost`, los providers hablan de
aprobar/canjear/entregar, el repositorio escribe en `rewards`, los permisos son
otros, y las redenciones generan deuda pendiente. Modelo, repositorio y
providers hay que escribirlos; lo que se hereda son los widgets y el flujo.

Estados: `abierta → acordada / para después / ahora no / retirada`.

Reglas:
- No tiene costo. No hay gate de saldo.
- El que propone no puede responderse a sí mismo.
- Acordar **no** crea una obligación irreversible: cualquiera puede reabrir o
  cerrar después, sin penalización ni registro de incumplimiento.
- No existe "entregado", "cumplido por" ni contador de deudas.
- Vocabulario: Proponer · Dale · Para después · Ahora no · Retirar.
  Nunca: canjear · saldo · aprobar · entregar · pendiente de entrega.

### 3. Para conectar
Los desafíos semanales de pareja, tal cual existen hoy pero **sin `coinReward`**.
Completar deja un recuerdo en el feed y una celebración visual. Omitir no tiene
consecuencia.

---

## 5. El ritmo, en lugar del duelo

El duelo semanal ya fue suavizado antes (la card muestra solo datos propios
reales, sin barras de ventaja). Este paso lo completa: el hogar se compara
**contra su propio pasado**, no una persona contra la otra.

**No usar racha consecutiva.** Una racha funciona por miedo a perderla: una
semana de enfermedad, un viaje o una mudanza "rompen" algo que costó construir,
y la app termina castigando exactamente las semanas en que la pareja más
necesitaba flexibilidad. Es motivación por pérdida, que es el mismo vicio que
estamos sacando por otro lado.

En su lugar, **ritmo**: semanas activas dentro de las últimas cuatro. No requiere
consecutividad, se recupera solo, y una semana floja lo baja sin romper nada.

- **Ritmo**: "3 de las últimas 4 semanas" — nunca "racha de N".
- **Pausa**: se puede pausar una semana explícitamente, sin marca ni castigo.
- **Semana**: tareas planificadas, hechas, vencidas.
- **Nunca**: rojo, "perdieron", "se rompió", iconografía de fracaso. Una semana
  sin actividad se muestra en neutro, no en alarma.

Se elimina: corona, ganador, perdedor, posiciones, bonus competitivo, y la
pantalla de ganador semanal en modo pareja.

**Dónde sí se ve el desequilibrio:** en Progreso, una vista de reparto honesta —
quién hizo qué, cuántas, de qué tipo, y cuáles se repiten siempre en la misma
persona. En tareas y tiempo. Con una lectura tipo *"las de cocina cayeron
siempre del mismo lado esta semana"*, que es accionable, en vez de un puntaje,
que es un juicio.

---

## 6. Esquema

### Por qué el fondo NO puede derivarse de `ledger_entries`

Una versión anterior de este documento proponía calcular el fondo sumando
`ledger_entries` por `household_id`, argumentando que no hacía falta tabla nueva.
**Es incorrecto, por tres razones independientes.** Queda documentado para que no
se reintente:

1. **Doble conteo por performer.** `complete_task_v1` inserta una fila por
   usuario (`foreach v_user_id in array p_user_ids loop`,
   `20260618190343:253`). Una tarea de 10 coins completada por dos personas
   genera dos filas de 10. Sumado por hogar da 20 para un esfuerzo de 10.
2. **Los gastos no usan el tipo que se asumía.** `redeem_reward` escribe
   `type = 'reward_redemption'` con monto negativo
   (`20260712120000:98`), no `coins_spent`. Cualquier filtro por `coins_spent`
   ignora todos los canjes históricos.
3. **La idempotencia es personal.** El unique es
   `(user_id, type, reference_id)`; una entrada a nivel hogar con `user_id` nulo
   la rompe.

Además el ledger es conceptualmente *personal* — mezclar en él un saldo de hogar
contamina los balances y las estadísticas individuales que ya lo consultan.

### Tablas nuevas

**`household_fund_entries`** — el ledger del fondo, separado del personal.

| Columna | Tipo | Notas |
|---|---|---|
| id | UUID | PK |
| household_id | UUID | FK households |
| amount | INTEGER | positivo suma, negativo gasta |
| entry_type | TEXT | `earned` / `spent` |
| source_type | TEXT | `task` / `goal_unlock` |
| source_id | TEXT | id de la actividad o de la meta |
| created_at | TIMESTAMPTZ | |

`UNIQUE (household_id, source_type, source_id)` — una tarea aporta **una vez al
hogar**, sin importar cuántas personas la completaron. Esto es exactamente lo
que resuelve el doble conteo.

El saldo es `sum(amount)` sobre esta tabla. `ledger_entries` queda intacto para
XP y para la economía personal de familia.

**Importante: no hay RPC público `add_to_household_fund`.** El insert va dentro
de la transacción de completar tarea, después de validar la tarea y el hogar. Un
RPC invocable libremente sería el mismo agujero que el bug #1 de §8.

**`household_fund_goals`** — la meta activa y las desbloqueadas.

| Columna | Tipo | Notas |
|---|---|---|
| id | UUID | PK |
| household_id | UUID | FK households |
| catalog_key | TEXT | null si es a medida |
| title | TEXT | |
| icon | TEXT | |
| cost | INTEGER | |
| status | TEXT | `active` / `ready` / `unlocked` |
| unlocked_at | TIMESTAMPTZ | |

Índice parcial único sobre `(household_id) where status in ('active','ready')`.
**Tiene que cubrir los dos estados**: con `where status = 'active'` solamente, en
cuanto una meta pasa a `ready` esperando confirmaciones se podría crear una
segunda activa en paralelo.

**`household_fund_goal_confirmations`** — las llaves del desbloqueo.

| Columna | Tipo | Notas |
|---|---|---|
| goal_id | UUID | FK, PK compuesta |
| user_id | UUID | FK, PK compuesta |
| confirmed_at | TIMESTAMPTZ | |

Tabla en vez de `confirmed_by UUID[]`: una confirmación es una relación entre
persona y meta, no un atributo de la meta. Da integridad referencial, timestamp
por persona, y permite retirar una confirmación borrando la fila. Con el array
no hay forma limpia de hacer nada de eso.

**`couple_proposals`** — los deseos sin precio.

| Columna | Tipo | Notas |
|---|---|---|
| id | UUID | PK |
| household_id | UUID | FK households |
| created_by | UUID | FK users |
| title / note / icon | TEXT | |
| status | TEXT | `open` / `agreed` / `deferred` / `declined` / `withdrawn` |
| responded_by | UUID | FK users, nullable |
| scheduled_for | DATE | nullable |
| created_at / updated_at / closed_at | TIMESTAMPTZ | |

Tabla nueva en vez de reusar `rewards`: deja `rewards` como lo que realmente es
—la tienda de familia— y evita arrastrar `cost` y estados de canje a un dominio
que no los tiene.

RLS con `current_app_user_id()`: leen los miembros del hogar; solo el creador
retira o edita mientras esté abierta; solo el otro responde; las transiciones
inválidas se rechazan en el servidor.

### RPC

- La suma al fondo ocurre **dentro de `complete_task_v1`**, no en un RPC aparte.
  Lee el monto de la fila de la tarea e ignora lo que mande el cliente (§8).
- `set_active_fund_goal` — cambia la meta; falla si hay una en `active` o `ready`.
- `confirm_fund_goal` / `withdraw_fund_goal_confirmation` — insertan o borran la
  fila de confirmación. Cuando se junta la segunda, el desbloqueo se ejecuta en
  la misma transacción: entrada negativa en `household_fund_entries` con
  `source_type = 'goal_unlock'` y `source_id = goal_id`, que por el unique es
  idempotente aunque los dos confirmen en simultáneo.
- `respond_to_proposal` — valida la máquina de estados y que no sea el creador.
- `complete_couple_challenge_v1` — se modifica para **no** acreditar coins.

`weekly_winners` deja de escribirse en pareja; se conserva para familia.

---

## 7. Matriz de modos

| | Tareas | XP | Coins | Ranking | Premios |
|---|---|---|---|---|---|
| **Pareja** | Compartidas | Solo propio | **Fondo del hogar** | Ritmo propio | Propuestas sin precio |
| **Familia** | Compartidas | Personal | Personales | Sí | Tienda familiar |
| **Amigos** | Compartidas | Personal | No | No | No |
| **Solo** | Personales | Personal | *(a decidir)* | Autoprogreso | No |

**Familia no se toca.** Es el único contexto donde las economías de fichas
tienen respaldo empírico real, y donde la asimetría adulto/chico es legítima por
diseño en vez de ser un accidente.

En `household_capabilities.dart` ya existen `usesRewardsStore` y
`usesCompetitiveRanking`, ambos ya restringidos a familia. Solo hay que agregar
`usesSharedFund => couple` y `usesCoupleProposals => couple`, y hacer que
`usesCoupleRewardsExperience` deje de implicar tienda personal.

**Solo** queda como decisión abierta: las coins ahí no generan deuda ni coerción
sobre nadie, así que el argumento en contra no aplica. Se puede dejar como está.

---

## 8. Bugs que se arreglan de paso

Cuatro hallazgos verificados en el código, independientes del debate de producto,
que este trabajo toca igual:

1. **Recompensas confiadas al cliente.** `complete_task_v1` y
   `complete_couple_challenge_v1` reciben `p_xp_reward` / `p_coin_reward` como
   parámetros y los acreditan sin validar contra la fila de la tarea. Cualquiera
   con el token puede acuñar monedas arbitrarias vía RPC. Hay que leer el monto
   de la base e ignorar el del cliente. **Esto es un exploit, no una opinión de
   diseño** — y aplica también a familia, donde las coins siguen vivas.
2. **Pantalla de ganador semanal sin gate de modo.**
   `_checkWeeklyWinner()` en `main_screen.dart:220` no consulta capabilities, así
   que un hogar de convivencia puede recibir una pantalla de ganador que su
   propio diseño dice que no debería existir.
3. **RLS de premios solo para el owner.** `rewards` exige
   `is_current_household_owner` para insert/update, con `role = 'owner'` estricto.
   En un hogar de pares, solo quien lo creó puede crear premios; el otro ve una
   tienda que no puede abastecer.
   **No corregirlo abriéndolo a `is_current_household_member`**: eso dejaría a
   los chicos administrando la tienda familiar, que es una regresión peor que el
   bug. La condición correcta es *adulto del hogar*. Y con este rediseño pareja
   deja de necesitar permisos sobre `rewards` — pasa a ser una tabla de familia.
4. **XP y coins personalizables sin tope** en `create_task_dialog.dart`.

---

## 9. Fases

El orden pone **primero lo que arregla el problema relacional** y deja el fondo
—que es la parte hipotética— para después. Si el fondo resulta no funcionar, el
cambio que importaba ya está hecho y no se revierte nada.

**Fase 1 — Servidor autoritativo y gates de modo.**
Los cuatro bugs de §8. Sin cambios de UI. Se puede hacer y verificar sola, y
aplica también a familia, donde las coins siguen vivas.

**Fase 2 — Sacar la deuda interpersonal.**
Las tareas dejan de acreditar coins personales en pareja. Se elimina el duelo y
la pantalla de ganador. `complete_couple_challenge_v1` deja de acreditar coins.
Se saca del catálogo lo que no sobrevive a la Regla 1 — en particular
`rewardTemplateYesToAnyPlanVoucher` ("sí a cualquier plan") y
`rewardTemplateNoDishesVoucher` ("vale por no lavar los platos"): uno compra
consentimiento anticipado, el otro traslada carga literal al otro.

**Fase 3 — Propuestas.**
`couple_proposals` + RLS + repositorio + providers. Se reusan los widgets del
flujo existente, despegados de la capa de precio.

**Fase 4 — Progreso compartido.**
La vista de reparto en Progreso: quién hizo qué, cuántas, de qué tipo, qué se
repite siempre del mismo lado. En tareas y tiempo. Esta es la contraparte
necesaria de haber sacado el desglose por persona del fondo.

**Fase 5 — El fondo.**
`household_fund_entries`, `household_fund_goals`, confirmaciones, catálogo de
desbloqueos, ritual de dos llaves, celebración → propuesta.

**Fase 6 — Espacio de pareja y ritmo.**
Se reescribe la pantalla (hoy 1830 líneas, conviene partirla) y se reemplaza el
duelo por el indicador de ritmo.

**Fase 7 — Copy, i18n y limpieza.**
Barrido de vocabulario en `app_es.arb` / `app_en.arb`, actualización de
`PRODUCT.md` —incorporando la Regla 1 literalmente al documento—, `docs/schema.md`,
`docs/provider-map.md`, y baja del código muerto de duelo y tienda en pareja.

---

## 10. Riesgos y decisiones abiertas

- **El fondo puede sentirse lento.** Con una sola meta activa y un costo mal
  calibrado, la barra casi no se mueve y el loop muere. Hay que calibrar los
  costos contra el ritmo real de tareas de un hogar — probablemente una meta
  chica alcanzable en 1-2 semanas, no en dos meses.
- **Sin desglose por persona, alguien puede sentir que carga solo.** Es
  deliberado: esa conversación pertenece a Progreso, con tareas y tiempo. Pero
  hay que asegurarse de que esa vista sea buena, no un gráfico enterrado — si no,
  se pierde información que el producto promete dar.
- **Los cosméticos como desbloqueo tocan monetización.** Si las paletas premium
  se pueden ganar con tareas, se solapan con lo que vende el paywall. Hay que
  decidir qué se gana y qué se compra antes de armar el catálogo.
- **Solo mode**: decisión pendiente sobre si conserva coins.
- **Casos borde del fondo, sin resolver todavía.** Hay que definir qué pasa
  cuando: un miembro se va del hogar con una meta en `ready`; el hogar cambia de
  tipo (couple → family) con fondo acumulado; alguien retira su confirmación
  después de darla; la meta queda lista y uno simplemente no quiere
  desbloquearla (¿caduca? ¿se puede cambiar de meta sin gastar?); un hogar de
  más de dos personas entra en modo pareja por error de configuración —
  ¿"las dos llaves" son *todos* los miembros o exactamente dos?
- **Familia queda con dos vocabularios de moneda** (personal ahí, compartida en
  pareja). Es aceptable porque los modos ya divergen mucho en tono, pero conviene
  que el componente visual del contador sea distinguible entre uno y otro.
