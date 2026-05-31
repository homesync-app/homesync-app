# HomeSync · Brief de iconos de lista de compras

Dirección de arte + prompts para generar iconos con un generador de imágenes
(nanobanana / Gemini 2.5 Flash Image, DALL·E, etc.) que se sientan parte de la
app. Calibrado al **Warm Scandi Theme** real de HomeSync (`app_colors.dart`).

---

## 1. Dirección de arte (el "alma" del set)

| Atributo        | Decisión                                                                 |
|-----------------|--------------------------------------------------------------------------|
| Estilo          | Ilustración flat moderna, esquinas suaves, **sin outline negro**         |
| Sombras         | Una sola sombra interna suave por forma (soft shading), nada de realismo |
| Geometría       | Formas redondeadas, bordes generosos, aspecto "amable" no técnico        |
| Iluminación     | Plana y pareja, highlight sutil arriba-izquierda                          |
| Fondo           | **Transparente** (PNG con alpha). NUNCA fondo de color ni tarjeta        |
| Encuadre        | Objeto centrado, ~14% de padding (safe area), no toca los bordes          |
| Ángulo          | Vista frontal o 3/4 leve y consistente en TODO el set                     |
| Detalle         | Bajo. Debe leerse claro a 34 px                                          |
| Densidad color  | 2-3 colores por icono + 1 sombra. Nada de gradientes ruidosos             |

**Mood:** cálido, hogareño, escandinavo. Cercano, no corporativo. Los iconos
acompañan, no gritan.

---

## 2. Paleta (usar SÍ o SÍ estos hex)

Sacada de `flutter_client/lib/core/theme/app_colors.dart`. El secreto para que
el set se sienta "de la app" es que **todos compartan esta paleta cálida** y
eviten azules/rojos fríos saturados.

**Marca / base cálida**
- Terracota (acento principal): `#EE652B`
- Durazno: `#E88D67`
- Naranja claro: `#FF8A65`
- Crema fondo (NO usar de fondo, solo si la forma lo pide): `#FFFCF9`

**Acentos permitidos (versión cálida/apagada, no neón)**
- Verde salvia: `#84A59D`
- Verde fresco: `#22C55E`
- Amarillo dorado: `#FFBD3D` / `#D4C550`
- Azul suave (sólo lácteos/agua, apagado): `#5A94E1`
- Rojo coral (sólo carnes/frutas rojas): `#E57373`
- Sepia/marrón para pan, madera, café: `#B5762F` / `#7C3F1D`

**Regla de oro:** preferí siempre la versión cálida. Si dudás entre un azul
frío y uno apagado, va el apagado. El conjunto tiene que verse como una familia.

---

## 3. Specs técnicas (para que entren en el pipeline actual)

- **Formato final:** PNG con transparencia.
- **Resolución de generación:** 1024×1024 (después se baja).
- **Export a la app:** 192×192 px (cubre densidad xxhdpi a 64dp). Cuadrado.
- **Safe area:** el objeto ocupa ~72-80% del lienzo, centrado.
- **Nombre de archivo:** `products/{clave}.png` (clave = key del catálogo, en
  inglés y minúscula: `milk`, `apple`, `carrot`...). Ver `shopping_visuals.dart`.
- **Fondo:** 100% transparente. Si el generador mete fondo, hay que recortarlo
  (ya hay carpeta `bg_removal/` en el repo para eso).

---

## ✅ PROMPT VALIDADO (congelado tras iterar pan/leche/zanahoria/manzana)

Este es el preámbulo que quedó funcionando en `bg_removal/icons/generate.js`.
Aprendizajes de la iteración:
- "muted pastel" a secas = productos lavados/grises (leche sin vida). Usar
  "soft pastel, still warm and appetizing, NOT washed-out".
- Productos que SON de color fuerte natural (zanahoria naranja, manzana roja):
  poner el color explícito en el *noun* del catálogo, ej.
  `'a carrot with a bright natural orange body and green leafy top'`.
- Pan: pedir `'whole rustic round loaf, uncut, no slices'` o sale pan lactal
  cortado con agujero blanco.
- Referencias maestras: `bread`, `milk`, `carrot`, `apple` en
  `bg_removal/icons/out/icons/`. Usarlas como style refs del lote.

## 4. Prompt base (preámbulo de estilo — pegar SIEMPRE)

> Flat modern illustration of a single {OBJETO}, centered, front view.
> Soft rounded shapes, no black outlines, gentle soft inner shading, even flat
> lighting with a subtle highlight on the top-left. Warm Scandinavian palette:
> terracotta `#EE652B`, peach `#E88D67`, warm orange `#FF8A65`, sage green
> `#84A59D`, golden yellow `#FFBD3D`, warm sepia `#B5762F`. Cozy, friendly,
> homey mood. Minimal detail, must read clearly at small sizes. Fully
> transparent background, no shadow on the ground, no card, no frame, no text.
> Object occupies about 75% of the square canvas with even padding. 1024x1024.

Reemplazá `{OBJETO}` por el producto. Mantené TODO lo demás idéntico entre
generaciones — eso es lo que da la consistencia.

---

## 5. Prompts por producto (ejemplos listos)

- **leche / milk:** `...a milk carton (tetra-style)`, acento azul apagado `#5A94E1` sobre blanco crema.
- **manzana / apple:** `...a red apple with a small green leaf`, coral `#E57373` + hoja salvia.
- **zanahoria / carrot:** `...a carrot with green leafy top`, naranja `#FF8A65` + tallo `#84A59D`.
- **pan / bread:** `...a loaf of bread`, sepia cálido `#B5762F` / `#E3A35A`.
- **carne / meat:** `...a cut of red meat with a small white bone`, coral `#E57373`.
- **huevos / eggs:** `...two eggs, one with a yolk`, crema `#FFFCF9` + yema `#FFBD3D`.

---

## 6. Cómo mantener consistencia entre iconos (clave)

1. **Fijá una seed** si el generador lo permite, y no la cambies en el lote.
2. **Generá un icono "patrón" primero** (ej. la manzana). Cuando te guste, usalo
   como **imagen de referencia de estilo** para los demás ("same style as this").
3. Generá en **tandas chicas** (5-6) y revisá que compartan ángulo, padding y peso.
4. Si uno desentona, regeneralo solo, no toques los que ya funcionan.
5. Revisá SIEMPRE a 34 px (tamaño real en la lista), no a 1024.

---

## 7. Flujo de entrega (lo automatizo yo cuando tengas los PNG)

1. Vos generás los PNG con el brief de arriba.
2. Me los pasás (carpeta), yo: recorto fondo si hace falta, normalizo a 192×192,
   renombro a `{clave}.png`, regenero `manifest.json` con versiones.
3. Subo al bucket `shopping-icons/products/` de Supabase.
4. Aparecen en la app **sin release ni patch** (el manifest los activa).
