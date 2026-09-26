# Ficha de Play Store — septiembre 2026

Reemplaza a `STORE_LISTING_es-AR_v46.md` y `PLAYSTORE_UPLOAD_GUIDE_v46.md` (hablaban de recompensas, desafíos y el fondo común, que ya no están en pareja).

## Textos (copiar y pegar en Play Console)

| Campo | es-AR | en-US | Límite |
|---|---|---|---|
| Nombre | `listing/es-AR/title.txt` (25) | `listing/en-US/title.txt` (27) | 30 |
| Descripción corta | `listing/es-AR/short_description.txt` (74) | `listing/en-US/short_description.txt` (76) | 80 |
| Descripción completa | `listing/es-AR/full_description.txt` (~2470) | `listing/en-US/full_description.txt` (~2490) | 4000 |
| Novedades | `whatsnew/es-AR/whatsnew.txt` (474) | `whatsnew/en-US/whatsnew.txt` (467) | 500 |

Los nombres de archivo siguen el formato de fastlane `supply`, por si más adelante se automatiza la ficha. Las novedades ya las toma el workflow `deploy-production.yml` en cada release.

Posicionamiento: la ficha abre con pareja ("que la casa sea pareja": parejo + pareja) porque es el segmento con la propuesta más distinta. Familia, convivencia y solo aparecen como "también sirve para", no como protagonistas. Todo lo que dice la ficha está verificado contra el código (OCR gratis con límite anti-abuso, sin SDK de anuncios, monedas soportadas, qué es Premium).

## Capturas (teléfono)

Play acepta hasta 8. Para aparecer en superficies de recomendación conviene tener al menos 4 en 9:16 con 1080 px o más de lado corto. Ojo: una captura cruda de un teléfono 20:9 (1080×2400) no sirve, porque el lado largo supera el doble del corto. Hay que componerla en un lienzo de **1080×1920**: título arriba y la pantalla abajo, sobre el fondo crema de la app (`#FFFCF9`) con el acento durazno (`#EE652B`).

Orden pensado para que las 3 primeras vendan solas:

| # | Pantalla y estado a preparar | Título es-AR | Título en-US |
|---|---|---|---|
| 1 | Pareja → "La semana de ustedes": reparto 9 / 6, lectura por categoría ("Cocina: esta semana lo hizo casi todo Sofi.") y el botón de propuesta | Vean cómo se repartió la semana | See how the week was split |
| 2 | Inicio en pareja: saldo con "Registrar pago" y 3 o 4 tareas de hoy | La casa, en un vistazo | Your home at a glance |
| 3 | Finanzas → Movimientos: 5 o 6 gastos reales del mes con quién pagó | Quién pagó qué, sin hacer cuentas | Who paid what, no mental math |
| 4 | Tareas: lista con repetición y responsable en cada una | Cada tarea con su responsable | Every chore has an owner |
| 5 | Formulario de gasto recién escaneado (ticket de súper) | Sacale una foto al ticket | Snap the receipt |
| 6 | Compras: lista por categorías con 2 o 3 ítems tildados | Una lista para los dos, en vivo | One list, shared live |
| 7 | Pareja → "Entre ustedes": una propuesta pendiente y una aceptada | Pídanse cosas sin reclamos | Ask without it becoming a fight |
| 8 | Onboarding → invitar a tu pareja (código visible) | Empiecen en un minuto | Get started in a minute |

Datos de demo: un hogar de prueba con "Sofi" y "Tomi" (nunca datos reales), montos en pesos para es-AR (súper $48.300, luz $21.900, alquiler) y en dólares para en-US. Idioma del teléfono en el idioma de cada juego de capturas. Las capturas de `screenshots/2026-07/` muestran la pestaña Pareja vieja y el selector de tipo de hogar: reemplazarlas.

Feature graphic (1024×500, obligatorio): fondo crema, la gata de la bienvenida (`assets/images/onboarding_welcome_cat.webp`) a la derecha y a la izquierda "Que la casa sea pareja" / "Share the load at home" en Outfit 900. Sin marco de teléfono ni texto chico: en muchas superficies se ve recortado.

## Palabras clave (para revisar en la consola, no para pegar en la ficha)

- es-AR: tareas del hogar, gastos compartidos, gastos en pareja, dividir gastos, lista de compras, organizar la casa.
- en-US: chore app, shared expenses, split bills with partner, household chores, grocery list, couple budget.

Ya aparecen de forma natural en los textos. Repetirlas más es relleno y Play lo penaliza.

## Checklist de publicación

- [ ] Probar en un teléfono real el onboarding completo: crear hogar, tareas, invitar, y unirse con el código desde una segunda cuenta.
- [ ] Cargar textos es-AR (idioma principal) y en-US.
- [ ] Subir 8 capturas por idioma y el feature graphic.
- [ ] Publicar la versión. **Ojo: cada push a `main` dispara `deploy-production.yml`, que construye con `shorebird release android` y publica directo en producción.** Mergear a `main` solo cuando la prueba en teléfono esté ok.
- [ ] Este cambio conviene como release completa y no como patch OTA: el onboarding es lo primero que ve alguien que recién instala, y un patch de Shorebird recién se aplica en el segundo arranque de la app.
