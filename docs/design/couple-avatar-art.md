# Avatares de Inicio en modo pareja

El catálogo contiene ocho retratos circulares y 36 escenas compartidas. Cada escena se dibujó como una composición propia, con poses complementarias y una planta que ambos cuidan. Se conserva la identidad y el estilo de acuarela de los personajes originales.

`PremiumAvatarArt` resuelve el asset a partir de los dos avatares seleccionados. Ordena los IDs para que ambas personas vean la misma ilustración. Incluye los ocho pares del mismo personaje. Solo se usan escenas del catálogo cuando ambos avatares tienen una identidad premium reconocida. Si alguno usa foto, emoji, iniciales o un avatar personalizado, Inicio muestra una sola ilustración del hogar. Los retratos personales se conservan en tareas, notas y selectores.

Los retratos nuevos se usan mediante `CustomUserAvatar(forceCircular: true)`, incluidos los círculos de tareas, selectores y notas. Los personajes de cuerpo completo siguen usando el catálogo original.

Assets: `flutter_client/assets/images/avatar_art/`. Las escenas se exportan a 512 px de ancho y los retratos a 256 px, con transparencia y codificación WebP sin pérdida. Los PNG originales de alta resolución se conservaron en `output/couple-home/avatar-art/sources/` (ignorado por Git).

La generación se hizo con la herramienta integrada `image_gen.imagegen`. Las instrucciones, referencias e identificadores de los originales quedan en [couple-avatar-prompts.json](couple-avatar-prompts.json).

Al incorporar otro premium, hay que agregar su retrato y una escena con cada personaje existente, además del par consigo mismo. `premium_avatar_art_test.dart` compara el catálogo y renderiza todas las imágenes en fondos claros y oscuros. `couple_home_design_test.dart` verifica el Inicio y la selección independiente del orden.

Capturas de Flutter: `flutter_client/build/couple_home/`, generadas con `--dart-define=CAPTURE_HOME=true`. Incluyen catálogo, Inicio claro/oscuro, 320 dp con texto a 1.3x, hogar esperando pareja, tareas vacías, deuda en ambas direcciones, finanzas compartidas, nota pendiente, emoji, iniciales, foto y foto sin conexión. Los datos son fixtures de pruebas; no corresponden a una cuenta real.
