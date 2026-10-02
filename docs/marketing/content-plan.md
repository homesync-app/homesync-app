# Plan de contenido para Muse: capturas y videos

Qué grabar con los hogares demo para que Muse tenga material de los dos modos
principales. El tono y lo que se puede prometer están en `muse-brief.md`.

## Cuentas

| Hogar | Para qué | Datos | Cómo se refresca |
| --- | --- | --- | --- |
| Sofi & Mati (pareja premium) | Contenido de pareja | `tmp/seed/gen_seed.py` + `gen_refresh_2026_09.py` | Aditivo: hay que correr las fechas a mano |
| Familia Romero (familia premium) | Contenido de familia | `tmp/seed/gen_family.py` | `python tmp/seed/gen_family.py` + `bash tmp/seed/q.sh tmp/seed/family.sql`; resiembra todo con fecha de hoy |

La Familia Romero tiene 4 integrantes. Para grabar hacen falta cuentas de
Firebase de **Caro** (vista de adulto) y **Benja** (vista de chico); con Juli es
opcional. El paso a paso está en `docs/playbooks/store-screenshots.md`.

Antes de cada tanda: volver a sembrar la familia **el mismo día** (el feed del
Inicio solo muestra lo de hoy y las tareas tienen vencimiento relativo a hoy).

## Capturas (9:16, 1080×1920 enmarcadas con Goldie)

### Familia (nuevas)
1. **Inicio de Caro**: ranking de la semana, tareas de hoy de cada integrante y feed familiar.
2. **Inicio de Benja**: el héroe infantil con sus monedas y sus tareas del día.
3. **Aprobar una tarea**: Benja marcó "Ordenar habitación" y espera aprobación.
4. **Premios de la familia**: catálogo para chicos, para adultos y para todos, y el canje pendiente de Benja ("Elegir la cena").
5. **Mesada**: el envío mensual a Juli (Modo Padres).
6. **Gastos de la familia**: alquiler, colegio y prepaga repartidos entre Caro y Diego.
7. **Lista de compras**: con lo que agregó cada uno (Benja pidió chocolate y jugo).

### Pareja (ya existen en `goldie/out`, rehacer si cambió la UI)
La semana de ustedes, saldo y saldar, foto al ticket, metas, propuestas y notas.

## Videos cortos (Reels / TikTok / Shorts)

Grabación de pantalla vertical, 15–30 s, sin audio (Muse le pone música y
texto). Se graba con:

```bash
adb shell screenrecord --bit-rate 12000000 --time-limit 30 /sdcard/clip.mp4
```

```bash
adb pull /sdcard/clip.mp4 tmp/marketing/raw/
```

Antes de grabar, activar el modo demo de la barra de estado (ver el playbook).
Un clip por idea, con el gesto principal en los primeros 3 segundos.

| # | Modo | Idea (gancho) | Qué se ve en pantalla |
| --- | --- | --- | --- |
| 1 | Familia | "Mi hijo de 9 años ordena la pieza sin que se lo pida" | Benja completa la tarea, suenan monedas, Caro la aprueba |
| 2 | Familia | "Le pagamos con monedas, no con plata" | Benja abre Premios y canjea "Elegir la cena" |
| 3 | Familia | "La mesada se manda sola" | Caro abre Mesada y muestra el envío mensual a Juli |
| 4 | Familia | "¿Quién ganó la semana en casa?" | Ranking familiar: los chicos arriba, mamá y papá atrás |
| 5 | Pareja | "Dejamos de discutir por quién lava los platos" | La semana de ustedes con la propuesta de turnarse la cocina |
| 6 | Pareja | "Le saco una foto al ticket y listo" | Escáner de ticket con el monto completado solo |
| 7 | Pareja | "¿Quién le debe a quién?" | Saldo y saldar con un toque |
| 8 | Ambos | "La lista del súper que se actualiza sola" | Uno agrega, el otro tilda en vivo (dos emuladores lado a lado) |

## Entrega a Muse

1. Exportar las capturas enmarcadas (`goldie/out/screenshots/...`) y los clips
   crudos (`tmp/marketing/raw/`, gitignoreado por `tmp/`) a una carpeta compartida.
2. Pasarle a Muse `muse-brief.md` y esta tabla de ideas.
3. Conectar el conector de métricas (`growth-mcp`) para que cada campaña lleve su link con UTM y se pueda medir.
