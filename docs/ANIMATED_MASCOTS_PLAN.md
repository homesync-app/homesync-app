# Mascotas Animadas — Plan de Diseño

Estado: **en ejecución — solo animales por ahora** · Última actualización: 2026-06-10

> **Ejecución actual:** se avanza solo con los 3 animales (gato listo; perro y
> pajarito en generación). Los humanos quedan **diferidos** (no cancelados): el
> diseño y el gate de validación 1a siguen vigentes para cuando se retomen.

## 1. La decisión (actualizada 2026-06-10)

Animamos **todos los avatares premium** (animales **y** humanos), con estas
reglas:

- **Disponibles para todos.** Sin bloqueo por edad ni por recompensa: quedan
  como el resto de los premium, seleccionables por cualquiera. (Se descarta el
  sub-proyecto de unlock/gamificación que se había planteado.)
- **Prompt personalizado por avatar (obligatorio).** Cada personaje tiene su
  gesto propio, pensado a partir de lo que sostiene en la mano y de sus partes
  animables. **Nada de prompts genéricos** ("breathes, blinks, nods") — esa fue
  la causa de que los humanos parecieran hablar.
- **Riesgo conocido — humanos busto.** Los humanos están cortados al pecho; sin
  cuerpo, el movimiento tiende a la cara → riesgo de "parece que habla". Se
  mitiga con: gesto centrado en el objeto/manos, cuerpo sutil, y **boca
  bloqueada** (ver §2). No se elimina al 100% → se valida con UN humano antes de
  generar el resto (ver §8, Fase 1a).

## 2bis. Modelo de reproducción: "Llegada" one-shot (2026-06-14)

Reemplaza al idle loopeable. Feedback del usuario: el ping-pong se veía
antinatural (la cola "se des-movía" al rebobinar) y el loop infinito no era
el objetivo.

- **Idle = "Llegada":** UNA pasada al entrar a la app (y al volver de
  background), termina en la pose de reposo del arte, y se queda quieto.
  **Sin loop, sin ping-pong, sin "respiro" repetido.**
- Concepto coherente: el avatar "llega y presenta lo que trae", luego se
  acomoda. Gato/perro: levantan su bolsa con la boca y la dejan; pajarito:
  presenta su llave. Todos arrancan y terminan en la pose del input.
- **Eventos** (victory/versus/celebrate): igual, one-shot al dispararse,
  terminan en reposo.
- Implementado en `PremiumAnimatedAvatar` (play once en mount + en resume, sin
  timer de repetición; se quitó `restBetweenPlays`). Pipeline: idle ahora es
  one-shot (sin ping-pong) en generate.mjs y postprocess.mjs.
- Mouth/boca: se soltó la regla global de "boca cerrada" (los animales abren
  la boca para agarrar la bolsa). Para HUMANOS reincorporar "mouth/lips stay
  closed" en su prompt. Cláusula de silencio se mantiene (filtro de audio).
- PENDIENTE: regenerar los 3 idles con el prompt de llegada cuando vuelva la
  cuota de Veo (hoy agotada). Los eventos ya generados se conservan.

## 2. Principios de animación (para TODA mascota nueva)

1. **Cara calma:** sonrisa sutil permitida, pero **nunca abrir la boca/pico** ni
   mover labios como al hablar. Cláusula de silencio obligatoria en el prompt
   (`scene is completely silent, does not speak/talk/sing, mouth/beak stays
   closed`) + negative prompt con `speaking, talking, singing, voice, open mouth`.
2. **El movimiento nace del objeto y del cuerpo del personaje.** Prompts
   **bespoke por mascota**: mirar qué tiene en la mano/pata y qué partes
   animables tiene (cola, orejas, alas, plumas). Nada de prompts genéricos
   tipo "breathes, blinks, nods".
3. **Sutil y loopeable.** El idle vive en un avatar chico del home: gestos
   pequeños, lentos, sin desplazar al personaje del centro.
4. **"Respiro":** el player reproduce una pasada y descansa (hoy 10s). Pendiente
   evaluar si baja a ~5s para que se sienta más vivo (ver §7).

## 3. Alcance

Todos los avatares premium, cada uno con prompt personalizado y objeto propio:

| Avatar | id | Tipo | Objeto / partes animables | Estado |
|---|---|---|---|---|
| Gatito Naranja | `premium_orange_cat` | animal | bolsa de verdura, bandana, cola | ✅ Listo (4 movs, bundleado) |
| Perrito Súper | `premium_market_dog` | animal | bolsa de compras, orejas, cola | ⬜ A generar |
| Pajarito Llaves | `premium_key_bird` | animal | llave/llavero casa, alas, plumas | ⬜ A generar |
| Matecito | `premium_mate_boy` | humano | mate + bombilla, vapor | ⬜ **Validación 1a** |
| Llaves de Casa | `premium_keys_girl` | humano | llaves que tintinean, pelo | ⬜ A generar |
| Mini Aventurero | `premium_paper_plane_kid` | humano | avioncito de papel, mochila | ⬜ A generar |
| Mini Estrella | `premium_star_girl` | humano | estrella que titila, cuaderno | ⬜ A generar |
| Hombre Herramientas | `premium_tool_adult_man` | humano | planta, caja de herramientas | ⬜ A generar |
| Chica Planta | `premium_plant_adult` | humano | maceta, hojas | ⬜ (sumar al picker antes) |

Movimientos por avatar (4, igual que el gato): `idle`, `victory`, `versus`,
`celebrate`. Puntos de uso ya cableados: header home (idle), face-off (versus),
ganador semanal (victory), saldar deuda (celebrate).

**Regla para humanos (busto):** el gesto va en el objeto + manos + un balanceo
corporal mínimo; la cara solo parpadea y la boca queda exactamente como el arte
(cerrada). El objeto es la estrella del movimiento.

## 4. Diseño de movimiento por mascota (bespoke)

### 🐱 Gatito Naranja — LISTO (referencia)
- idle: parpadea, cola se balancea suave.
- victory: saltito de festejo, levanta una patita, ojitos brillantes, vuelve a
  la pose.
- versus: se inclina con mirada competitiva, cola flickeando.
- celebrate: aplaude con las patitas y wiggle (trim 2.6s + ping-pong).

### 🐶 Perrito Súper — a generar
Cachorro dorado sentado, con bolsa de compras (zanahorias) y bandana de corazón.
- **idle:** la cola se mueve lento, las orejas se levantan un instante, el
  hocico se acerca curioso a la bolsa y vuelve. Hocico cerrado (sonrisa perruna).
- **victory:** rebote alegre, las orejas saltan, cola rápida, una patita arriba,
  vuelve a la pose inicial.
- **versus:** "play bow" (se agacha de adelante, cola arriba), mirada
  juguetona-decidida, listo para jugar.
- **celebrate:** wiggle de cuerpo entero feliz, cabeza ladea, cola en círculos.

### 🐤 Pajarito Llaves — a generar
Pollito amarillo de pie, sostiene una llave con llavero de casita, bandana.
- **idle:** esponja las plumas, las alas se ajustan, la llave se balancea suave,
  un saltito mínimo, plumas de la cola tiemblan. Pico cerrado.
- **victory:** saltito con aleteo, la llave tintinea, pecho inflado orgulloso.
- **versus:** se inclina con las alas un poco abiertas, decidido, llave en alto
  como trofeo.
- **celebrate:** aletea entusiasmado con un saltito, la llave se mece.

> Regla de oro para todos: **pico/hocico/boca cerrados**, sonrisa con los ojos y
> el cuerpo. El gesto característico (cola, alas, el objeto) es la estrella.

## 5. Disponibilidad

Las animadas quedan **disponibles para todos**, igual que el resto de los
avatares premium (gateadas por `isPremium`/suscripción, sin lógica de unlock por
coins ni segmentación por edad). En el picker se ve la imagen estática y, al
seleccionar, anima. **Descartado** por ahora el sub-proyecto de recompensas
/desbloqueo; podría retomarse a futuro como capa opcional, no bloquea nada.

## 6. Arquitectura técnica (ya construida)

- **Pipeline** `tools/avatar_animation/`: Veo 3.1 Fast (`generate.mjs`) →
  chroma magenta + loop → WebP transparente (`postprocess.mjs`). Cláusula de
  silencio ya integrada en `buildPrompt`.
- **Player** `PremiumAnimatedAvatar`: decodifica frames con `ui.Codec`, una
  pasada + respiro, pausa en background/reduce-motion. Acepta assets o archivos
  locales.
- **Entrega:** hoy **bundled** para el gato (confiable, offline). Para 3
  mascotas, bundlear todo es viable (~15 MB). Si el pack de recompensas crece,
  migrar las no-bandera a **descarga remota** (Supabase Storage, infra ya
  existe en `PremiumAvatarMotionCache`) — pero antes hay que debuggear por qué
  la descarga falló en el build real (ver §7).
- **Registro:** `kAnimatedPremiumAvatarFiles` + `kBundledAnimatedAvatars` en
  `premium_avatar_motion_cache.dart`.

## 7. Deuda técnica / pendientes

- **Limpieza inmediata:** revertir la integración del `premium_tool_adult_man`
  (humano, fuera de alcance): sacarlo de `kAnimatedPremiumAvatarFiles` y
  `kBundledAnimatedAvatars`, borrar sus 4 WebP de `assets/.../animated/` y de
  `dist/`. El gato queda.
- **Respiro:** evaluar bajar de 10s a ~5s o hacer el idle más continuo (2
  quejas de "se ve estático").
- **Descarga remota:** sin root-cause del fallo en build real; queda bundled
  hasta resolverlo. Necesario antes de escalar a un pack grande.
- **Peso:** ~1–2 MB por clip a 480px/q70. Aceptable bundleado para pocos; si
  crece el pack, revisar compresión/CDN.

## 8. Plan por fases

- **Fase 1a — Validar un humano** (gate de riesgo): regenerar el Matecito
  (`premium_mate_boy`) con prompt 100% personalizado y boca bloqueada. Verlo en
  device. Decisión: si convence → seguir con los humanos; si no → replantear
  (volver a "solo animales" o ajustar enfoque). El manitas ya generado se
  reaprovecha o regenera con el criterio nuevo.
- **Fase 1b — Resto de animales:** perro + pajarito con prompts bespoke (§4).
  (Bajo riesgo, se pueden hacer en paralelo a 1a.)
- **Fase 2 — Resto de humanos:** los 5 restantes con prompt personalizado, una
  vez validado 1a. Sumar `premium_plant_adult` al picker.
- **Fase 3 — Integración + pulido:** elegir takes, integrar, verificar en
  device, decidir bundled vs remoto según peso total, ajustar el respiro.

## 9. Decisiones abiertas

1. **Respiro:** ¿10s, 5s, o idle continuo? (2 quejas de "se ve estático").
2. **Entrega:** con 9 avatares × ~1–2 MB × 4 movs el peso bundleado es alto
   (~50 MB) → probablemente haya que resolver la descarga remota (hoy sin
   root-cause del fallo) o bundlear solo idles. Decisión técnica de Fase 3.
