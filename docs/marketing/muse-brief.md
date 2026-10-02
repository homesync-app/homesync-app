# Brief de HomeSync para Muse

Material para que Muse escriba y programe contenido sin inventar funciones. Muse
no puede usar la app: trabaja con este brief, con las capturas y videos de
`docs/marketing/content-plan.md` y con las métricas del conector `growth-mcp`.

## Qué es, en una línea

HomeSync es la app para que la casa sea pareja: tareas, gastos y compras
repartidos entre todos y a la vista, sin planillas y sin llevar la cuenta de cabeza.

- Android (Google Play). **Todavía no hay versión de iPhone**: no prometerla.
- Gratis, sin publicidad. Premium es opcional.
- Español (argentino) e inglés. Pesos argentinos, chilenos y uruguayos, dólares, euros y reales.

## Los dos públicos principales

### Pareja (modo `couple`)

Parejas que conviven, 25–40 años, los dos trabajan. El dolor: uno siente que hace
más, y hablarlo termina en discusión. "¿Quién sacó la basura?", "te debo la mitad
del súper", "¿pagaste la luz?".

Lo que les damos:
- **La semana de ustedes**: cuántas tareas hizo cada uno y qué quedó cargado de un
  solo lado, con una propuesta concreta ("¿Nos turnamos con la cocina?").
  **No hay ranking ni ganadores en pareja**: es una lectura, no un reproche.
- **Gastos compartidos**: mitad y mitad u otro porcentaje, el saldo dice quién le
  debe a quién y saldar es un toque. O economía integrada, sin deudas.
- **Foto al ticket**: la app lee el monto y el comercio sola.
- **Propuestas y notas**: pedirse cosas sin que suene a reclamo.
- **Lista de compras** compartida, en tiempo real.

### Familia (modo `family`)

Madres y padres con chicos de 6 a 17. El dolor: repetir mil veces "ordená la
pieza", que los chicos no colaboren, y que la mesada sea un tema.

Lo que les damos:
- **Tareas para cada integrante**, con el avatar de cada uno. Los chicos
  ganan **monedas** por cada tarea.
- **Aprobación de los adultos**: el chico marca "hecha" y mamá o papá la aprueba
  (Modo Padres).
- **Premios que se canjean con monedas**: postre especial, elegir la cena, 15
  minutos más de pantalla, noche de peli en familia. Los arma la familia.
- **Ranking familiar de la semana**: acá sí hay ganador, y muchas veces son los chicos.
- **Mesada** de los adultos al adolescente, automática cada mes, y el adolescente
  registra en qué la gasta. Los gastos de la casa (alquiler, colegio) se
  reparten **solo entre los adultos**.
- Lista de compras donde cada uno agrega lo suyo.

### Otros modos (mencionar, no protagonizar)

- **Convivencia** (`friends`): gastos del depto y fondos para un asado o un viaje.
- **Solo**: tus tareas y tus gastos, en calma.

## Tono

- Voseo argentino, cálido, con humor de casa: "¿a quién le toca?", "la casa no se
  limpia sola". Nada de jerga de productividad ni de "optimizá tu hogar".
- **Nunca culpar** a nadie (ni a la pareja ni a los chicos). El conflicto es la
  carga mental, no la persona.
- En pareja, cómplice. En familia, de equipo ("todos ponen su parte").
- Emojis con moderación, los clásicos: 🏠 🧹 🛒 💸 ✅ 🪙.
- En inglés (en-US): neutro, "Household", "Parent Mode", "chores".

## Qué se puede decir y qué no

| Sí | No |
| --- | --- |
| "Gratis y sin publicidad" | "Gratis para siempre" o precios: los planes pueden cambiar |
| "Sacale una foto al ticket y se carga solo" | "Se conecta con tu banco / Mercado Pago" (no existe) |
| "Tus chicos ganan monedas y las canjean por premios que eligen ustedes" | "Les pagás a tus hijos por hacer tareas" (las monedas no son plata) |
| "Mesada automática para tu adolescente" (Premium) | Mostrar menores reales: solo los personajes demo |
| "Disponible en Android" | "En App Store" / "en iPhone" |
| Testimonios reales si los hay, con permiso | Reseñas, cifras de usuarios o premios inventados |

Premium incluye: pagos recurrentes (alquiler, servicios, suscripciones),
presupuestos por categoría, resumen del mes, exportar a CSV, Modo Padres con
mesada, temas y avatares. Todo lo demás es gratis.

## Personajes del contenido

Son hogares demo con datos de mentira, pensados para capturas. Usar siempre estos
nombres para que el contenido sea coherente:

- **Sofi y Mati** (pareja): viven juntos, ahorran para Bariloche, Mati se hace
  cargo de la cocina esta semana.
- **Familia Romero**: Caro (mamá) y Diego (papá), Juli (15, mesada de $40.000) y
  Benja (9, junta monedas para canjear y ahorra para una bici).

## Links y medición

Cada posteo o campaña lleva su propio link de Play con UTM. Así el conector
`growth-mcp` sabe de dónde vino cada hogar:

```
https://play.google.com/store/apps/details?id=com.blas.homesync&referrer=utm_source%3D<red>%26utm_medium%3D<organic|paid>%26utm_campaign%3D<campaña>
```

- `utm_source`: `instagram`, `tiktok`, `facebook`, `youtube`, `whatsapp`.
- `utm_medium`: `organic` para posteos, `paid` para anuncios.
- `utm_campaign`: en minúsculas y con guiones, con el modo adelante:
  `pareja-ticket-oct26`, `familia-monedas-oct26`.

Con el conector, Muse puede preguntar:
- `get_growth_overview`: altas, activación a 7 días y hogares nuevos por modo.
- `get_acquisition_funnel` con `group_by: campaign`: qué campaña trae hogares que
  se activan y pagan, no solo descargas.
- `get_daily_signups`: el efecto de un posteo día por día.

La métrica que importa es **hogares activados** (cargaron una tarea, un gasto o
una compra en la primera semana), no las descargas.
