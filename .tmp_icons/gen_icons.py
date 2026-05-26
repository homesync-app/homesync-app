#!/usr/bin/env python3
"""
Generador de iconos de la lista de compras (Camino 2) usando Gemini 2.5 Flash
Image ("Nano Banana") via la API REST de Gemini.

End-to-end:
  1. Genera el PNG desde un prompt (template fijo + design/colors por item)
  2. Recorta el fondo blanco a transparente (flood fill desde las esquinas)
  3. Centra, deja margen parejo y baja a 256x256
  4. Arma una grilla de revisión sobre el verde de las tarjetas de la app

USO:
  # 1) Seteá tu API key de Gemini (la misma del OCR sirve)
  #    PowerShell:  $env:GEMINI_API_KEY = "AIza..."
  #    bash:        export GEMINI_API_KEY="AIza..."
  #
  # 2) Generar + procesar todo lo de la lista ICONS:
  python .tmp_icons/gen_icons.py
  #
  # 3) Solo uno:               python .tmp_icons/gen_icons.py --only tangerine
  # 4) Re-procesar sin generar (si ya tenés los raw):
  python .tmp_icons/gen_icons.py --no-gen
  # 5) Solo armar la grilla de revisión:
  python .tmp_icons/gen_icons.py --sheet-only

Salidas:
  .tmp_icons/raw/<key>.png      <- crudo de la API (fondo blanco)
  .tmp_icons/staged/<key>.png   <- procesado 256x256 transparente (listo para wirear)
  .tmp_icons/check/<key>.png    <- preview sobre verde
  .tmp_icons/_contact_sheet.png <- grilla de revisión de todo el set
"""
import argparse
import base64
import json
import os
import sys
import time
from pathlib import Path

import numpy as np
import requests
from PIL import Image, ImageDraw, ImageFilter, ImageFont

# ----------------------------------------------------------------------------
# Config
# ----------------------------------------------------------------------------
API_KEY = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
# Se prueban en orden. Primero el Flash de imagen mas nuevo (Nano Banana 2,
# Gemini 3.1 Flash Image Preview), luego el Pro (Nano Banana Pro, mas caro pero
# top calidad), y al final el clasico 2.5 Flash Image. Nota: gemini-3.5-flash
# NO genera imagenes (solo texto), por eso no esta en esta lista.
MODELS = [
    "gemini-3.1-flash-image-preview",   # Nano Banana 2 (newest Flash, hasta 4K)
    "gemini-3-pro-image-preview",       # Nano Banana Pro
    "gemini-2.5-flash-image",           # Nano Banana
    "gemini-2.5-flash-image-preview",
]
ENDPOINT = "https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"

ROOT = Path(__file__).resolve().parent
RAW = ROOT / "raw"
STAGED = ROOT / "staged"
CHECK = ROOT / "check"
for d in (RAW, STAGED, CHECK):
    d.mkdir(exist_ok=True)

DELAY_S = 3          # pausa entre llamadas (gentil con el rate limit)
MAX_RETRIES = 4
APP_GREEN = (217, 236, 220)   # verde de las tarjetas de la app (para el preview)

# ----------------------------------------------------------------------------
# Template FIJO. No tocar las secciones de abajo: garantizan que todo el set
# salga como familia. Solo cambian {design} y {colors} por item.
# ----------------------------------------------------------------------------
TEMPLATE = """3D emoji-style icon of a {name} for app use. Technical specifications for clean implementation.

Design: {design}

Colors: {colors}

3D Effect: Soft shadows and highlights for pronounced 3D volume and glossy appearance. Main light source from top-left. Bright glossy highlight/shine on upper surface for shiny emoji style.

CRITICAL TECHNICAL REQUIREMENTS:
- NO drop shadow underneath the object
- NO cast shadow on ground
- Object is self-contained with all shading/highlights ON the object itself only
- Centered in frame with generous margin (object should not touch edges)
- Clean, isolated object ready for transparent background export
- All lighting and volume comes from the object's own surface shading

Background: Pure flat white background (#FFFFFF) with no gradients, no texture, no grid pattern. Completely uniform white that can be easily removed for transparency.

Style: Clean, simplified, glossy 3D emoji-style like a polished mobile app emoji (think Apple/Samsung food emoji). Smooth surfaces with minimal texture detail, soft rounded forms, one large soft glossy highlight. No outlines. Vibrant saturated colors. NOT photorealistic, not a realistic render, not a 3D studio render. Compact but with breathing room around edges. Viewed from a slight top-down angle.

Output: 1024x1024 square format, object centered, ready for clean background removal."""

# ----------------------------------------------------------------------------
# Lista de iconos a generar.  key == clave del catalogo (= nombre de archivo).
# Agregar mas items abajo siguiendo el mismo formato.
# ----------------------------------------------------------------------------
ICONS = [
    {
        "key": "tangerine",
        "name": "mandarin tangerine",
        "design": "ONE whole mandarin tangerine, distinctly OBLATE spheroid shape — "
                  "clearly wider than tall, visibly flattened at top and bottom (NOT a "
                  "round sphere like an orange, must look squashed/pressed). Smooth "
                  "dimpled citrus skin, one small green leaf and short stem on top. "
                  "Viewed slightly from above. Filling most of the frame.",
        "colors": "Vibrant orange-red tones - gradients from bright orange (#FBA13C) to "
                  "deep red-orange (#E14E27). More intensely red than a regular orange. "
                  "Fresh, juicy appearance.",
    },
    {
        "key": "grapefruit",
        "name": "grapefruit half",
        "design": "ONE single grapefruit half viewed face-on (the cut side facing the "
                  "camera), showing pink segmented juicy flesh in a radial pattern with "
                  "thin white pith around the rim. Round circular shape filling most of "
                  "the frame. Single object, not two halves.",
        "colors": "Pink and yellow tones - flesh gradients from light pink (#FFB3B3) to "
                  "deep rosy pink (#E85C6B), rind in pale yellow (#F7E6A8). Fresh, juicy "
                  "appearance.",
    },
    {
        "key": "chorizo",
        "name": "chorizo sausage",
        "design": "A single chorizo sausage, a thick slightly curved sausage link. "
                  "Smooth glossy casing, simple twisted ends. Simplified emoji shape, "
                  "minimal texture.",
        "colors": "Deep reddish tones - gradients from warm red-brown (#C0523A) to dark "
                  "maroon (#7E2C1E) creating depth and volume. Savory, appetizing appearance.",
    },
    {
        "key": "gratedCheese",
        "name": "pile of grated cheese",
        "design": "A small mound or pile of grated cheese (shredded cheese strands) - "
                  "thin yellow curls heaped together forming a soft fluffy pile. Single "
                  "mound centered, viewed from a slight top-down angle, simplified emoji "
                  "shape with visible individual shreds.",
        "colors": "Warm cheese tones - gradients from light buttery yellow (#FFE082) to "
                  "deeper golden cheese (#E8A93B), with slight orange shadow underneath "
                  "(#C4862A). Appetizing fresh dairy appearance.",
    },
    # --- Camada 1: lacteos / quesos ---
    {
        "key": "creamCheese",
        "name": "soft cream cheese dollop",
        "design": "A small soft round dollop or scoop of cream cheese — smooth glossy "
                  "white spreadable cheese, slightly mounded with a soft creamy texture. "
                  "Single dollop centered, viewed from a slight top-down angle.",
        "colors": "Soft white-cream tones - body in bright white (#FAFAFA) with warm "
                  "creamy yellow tint (#FFF4D6) and subtle warm shadow (#E8DEC8). Fresh "
                  "dairy appearance.",
    },
    {
        "key": "mozzarella",
        "name": "fresh mozzarella ball",
        "design": "ONE single round ball of fresh mozzarella cheese (bocconcini style), "
                  "smooth glossy milky-white sphere with subtle creamy highlights. Single "
                  "sphere centered, viewed slightly from above.",
        "colors": "Milky white tones - bright white body (#FFFFFF) with cool gray-blue "
                  "shadows (#D8D8D8 to #B0B0B0) and warm white highlights (#FFF8E7).",
    },
    {
        "key": "provolone",
        "name": "wedge of provolone cheese",
        "design": "A triangular wedge of provolone cheese with deep golden-yellow flesh "
                  "and a thin brown waxy rind on the curved outer edge. Single wedge "
                  "centered, viewed from a slight angle showing both the cut face and "
                  "side.",
        "colors": "Rich golden yellow tones - flesh in deep yellow (#F5C84A) to amber "
                  "(#D9A02C), thin brown rind (#8B5A2B). Appetizing aged cheese look.",
    },
    {
        "key": "freshCheese",
        "name": "white fresh cheese block",
        "design": "A small rectangular block of fresh white cheese (queso fresco), "
                  "rustic soft block with slightly rounded edges, plain smooth surface, "
                  "no holes. Single block centered, viewed at a slight angle showing "
                  "depth.",
        "colors": "Soft white tones - body in bright white (#FAFAFA) with cool gray "
                  "shadows (#D5D5D5) and subtle warm highlight on top (#FFF6E0).",
    },
    {
        "key": "yogurt",
        "name": "open yogurt cup",
        "design": "A small round yogurt cup/tub with the foil lid peeled back, showing "
                  "creamy white yogurt with a small mound inside. Single cup centered, "
                  "slight angle.",
        "colors": "White cup (#FFFFFF to #E0E0E0) with creamy yogurt inside (#FFF8E5 to "
                  "#F0E0C0). Foil silver-blue (#9FB7C8).",
    },
    {
        "key": "butter",
        "name": "stick of butter",
        "design": "A rectangular stick/block of butter with slightly soft rounded edges "
                  "and a smooth glossy surface, soft creamy yellow color. Single block "
                  "centered, viewed from a slight angle showing depth.",
        "colors": "Warm buttery yellow - body (#FFE082) with deeper golden shadows "
                  "(#F4C842) and subtle highlight on top (#FFF4C2).",
    },
    # --- Camada 1: despensa / argentinos ---
    {
        "key": "dulceDeLeche",
        "name": "dollop of dulce de leche",
        "design": "A glossy thick mound of dulce de leche (Argentine caramel spread) — "
                  "smooth soft heap of rich caramel-brown spread, slightly glossy with "
                  "a soft peak on top. Single mound centered.",
        "colors": "Rich warm caramel tones - main body in deep caramel brown (#A87038) "
                  "to darker shadow (#5C3A12), shiny highlight on top (#D4965A).",
    },
    {
        "key": "alfajor",
        "name": "Argentine alfajor sandwich cookie",
        "design": "A round alfajor sandwich cookie: two soft round cookie discs with a "
                  "thick layer of dulce de leche caramel filling visible at the side "
                  "(slightly oozing). Top dusted with white powdered sugar. Viewed from "
                  "a slight angle.",
        "colors": "Golden cookie discs (#F0DAA8 to #C89E5C), thick caramel filling "
                  "(#9C6024 to #5C3A12), white powdered sugar dusting on top (#FFFFFF).",
    },
    {
        "key": "breadcrumbs",
        "name": "pile of breadcrumbs",
        "design": "A small heap or mound of dry golden breadcrumbs - granular pile of "
                  "small light-brown crumbs with visible texture. Single pile centered, "
                  "viewed from a slight top-down angle.",
        "colors": "Warm golden-tan tones - main pile in light tan (#E8C896) with deeper "
                  "brown specks (#B88B4E) and lighter highlights (#F5E0B8).",
    },
    # --- Camada 1: snacks / frutos secos ---
    {
        "key": "peanuts",
        "name": "cluster of peanuts in shells",
        "design": "A small cluster of 2-3 whole peanuts in their natural tan shells, "
                  "with the characteristic peanut-shell bumpy peanut-shape (two bumps "
                  "per shell). Grouped together at slight angles, single cluster "
                  "centered.",
        "colors": "Warm tan-cream tones - shells in light cream-tan (#E8C58A) with "
                  "subtle darker veins/lines (#B8924A) and shadow underneath (#8B6B2E).",
    },
    {
        "key": "almonds",
        "name": "cluster of whole almonds",
        "design": "A small cluster of 3-4 whole shelled almonds — the smooth oval "
                  "tear-drop-shaped brown nuts grouped together with one slightly on "
                  "top. Single cluster centered.",
        "colors": "Warm nutty brown tones - body in light tan-brown (#C89860) to deeper "
                  "brown shadow (#8B5A2B), with subtle highlight on top (#E8C896).",
    },
    {
        "key": "walnuts",
        "name": "walnut and half-cracked walnut",
        "design": "Two walnuts: one whole walnut in its bumpy wrinkled brown shell, "
                  "next to a half walnut showing the wrinkly brain-like nut meat inside. "
                  "Paired together at a slight angle, single small cluster.",
        "colors": "Warm woody tones - shell brown (#A57848 to #5C3A12), nut meat lighter "
                  "cream-brown (#E8C896 to #B88B4E).",
    },
    # --- Camada 1: bebida + chocolate ---
    {
        "key": "fernet",
        "name": "dark green liqueur bottle",
        "design": "A slim dark green glass bottle with a long neck (Italian-style "
                  "liqueur bottle), a small dark label on the body and a metal cap on "
                  "top. Single bottle centered, viewed straight on. No brand names.",
        "colors": "Deep emerald green tones - bottle in dark green (#1F4F1F) with darker "
                  "shadow (#0A2A0A) and lighter green highlights (#4A8A4A). Black-gray "
                  "label area (#1A1A1A), silver cap (#B0B0B0).",
    },
    {
        "key": "chocolate",
        "name": "chocolate bar",
        "design": "A chocolate bar with several embossed squares visible on top, a "
                  "corner broken off showing the rich dark chocolate cross-section, with "
                  "the silver foil wrapper peeled back at one end. Viewed from a slight "
                  "angle.",
        "colors": "Rich brown chocolate tones - body in dark cocoa (#6B3A1A) to deep "
                  "brown (#3D1F0A) with glossy highlight reflections (#A57848). Silver "
                  "foil edge (#C8C8C8 to #888888).",
    },
    # --- Ronda 2: emojis genuinamente malos / wrong / colisiones grandes ---
    {
        "key": "cocaCola",
        "name": "classic cola glass bottle",
        "design": "A classic curvy glass cola bottle (iconic hourglass / waist shape) "
                  "with dark brown cola liquid inside, a vivid red label wrapping around "
                  "the middle, and a small metal cap on top. Single bottle centered, "
                  "viewed straight on, no brand text or logos.",
        "colors": "Vivid red label (#E32636 to #B0181D), dark cola brown (#3C1810 to "
                  "#1A0805) visible through clear glass with subtle highlights (#FFFFFF "
                  "soft sheen), silver cap (#B0B0B0).",
    },
    {
        "key": "softener",
        "name": "fabric softener bottle",
        "design": "A plastic bottle of fabric softener with a rounded curvy shape and a "
                  "colored cap, pastel pink-lavender liquid visible through the plastic, "
                  "small flower-like accent on the label. Single bottle centered, slight "
                  "angle.",
        "colors": "Soft pastel pink-lavender tones (#F2A8C8 to #C878A0) for the liquid, "
                  "white-pink translucent bottle (#FFE8F0), white cap (#FFFFFF to #E0E0E0).",
    },
    {
        "key": "sparklingWater",
        "name": "Argentine soda siphon bottle",
        "design": "A traditional Argentine glass soda siphon (sifon de soda) — clear "
                  "ribbed glass bottle with a metallic chrome trigger nozzle on top, "
                  "filled with sparkling carbonated water visible inside. Iconic cylindrical "
                  "shape with the lever spout. Single bottle centered.",
        "colors": "Clear glass with light blue tint (#D8E8F4) and visible carbonation "
                  "bubbles, chrome silver trigger nozzle (#C8C8C8 to #7A7A7A) with metallic "
                  "highlights.",
    },
    {
        "key": "terma",
        "name": "bottled yerba mate herbal drink",
        "design": "A tall plastic bottle of bottled iced yerba mate herbal drink "
                  "(Argentine 'Terma' style), straight-sided plastic bottle with a dark "
                  "screw cap on top. The bottle has a PROMINENT central label showing a "
                  "stylized illustration of yerba mate leaves (green leaves) on a cream/"
                  "beige background. Amber-green herbal liquid clearly visible through the "
                  "transparent plastic. Single bottle standing upright, centered, viewed "
                  "slightly from the front.",
        "colors": "Bottle: transparent plastic with amber-green herbal liquid (#9F8A3C "
                  "to #6B5A1F) visible through it. Label: cream/beige background "
                  "(#F2E6C0) with bold green yerba leaves (#3D6F2A to #5C8E3A), small "
                  "brown accents (#8B5A2B). Dark brown cap (#3D2A15).",
    },
    {
        "key": "plantMilk",
        "name": "plant milk carton",
        "design": "A small rectangular paper carton of plant-based milk (almond or oat "
                  "milk) with a slanted gable top, white/cream color with a small green "
                  "leaf or plant motif on the front label. Single carton centered, slight "
                  "angle showing depth.",
        "colors": "Cream-white carton body (#F8F4E8 to #E8DCC0) with a small green leaf "
                  "accent (#7AB04A), warm beige bottom accent (#A87848), subtle shadows "
                  "(#C8B898).",
    },
    {
        "key": "deodorant",
        "name": "stick deodorant",
        "design": "A modern cylindrical stick deodorant — sleek bottle with an oval cross "
                  "section and a colored cap on top, smooth glossy surface. Single bottle "
                  "centered, viewed from a slight angle.",
        "colors": "Cool tones - white-light blue body (#E8F0F4 to #B4C8D8), darker blue "
                  "cap (#5A7892) with subtle metallic sheen.",
    },
    {
        "key": "mushrooms",
        "name": "brown cremini mushrooms",
        "design": "A small cluster of 2-3 whole BROWN cremini mushrooms (NOT red toadstool) "
                  "— round caps with stems, natural earthy beige-brown color. Grouped "
                  "together, viewed slightly from above, single cluster centered.",
        "colors": "Warm earthy tones - caps in light brown-tan (#A8896A) to deeper warm "
                  "brown (#6B4A2B), stems in lighter cream-beige (#D8C49A), subtle gills "
                  "shadow underneath cap.",
    },
    # --- ya generados antes (mantener en la lista para re-procesar si hace falta) ---
    {
        "key": "yerbaMate",
        "name": "Argentine yerba mate cup",
        "design": "A traditional Argentine mate cup (round bulbous gourd) with a curved "
                  "silver metal bombilla straw sticking out of the top. The mate is filled "
                  "with green yerba leaves visible at the rim. Single object centered, "
                  "slightly tilted, simplified emoji shape.",
        "colors": "Warm wooden tones - gourd in rich nutty brown (#8B5A3C) with darker "
                  "shadow side (#5D3A20) and lighter highlight (#A87749). Green yerba at top "
                  "(#6FA84A to #3D6F2A). Silver bombilla in cool metallic gray (#C8C8C8 to "
                  "#7A7A7A) with shiny highlight.",
    },
]

# ----------------------------------------------------------------------------
# Generacion (API REST)
# ----------------------------------------------------------------------------
def generate_png(prompt: str) -> bytes:
    """Llama a Gemini y devuelve los bytes del PNG. Reintenta en 429."""
    body = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {"responseModalities": ["TEXT", "IMAGE"]},
    }
    last_err = None
    for model in MODELS:
        url = ENDPOINT.format(model=model)
        for attempt in range(MAX_RETRIES):
            r = requests.post(
                url,
                headers={"x-goog-api-key": API_KEY, "Content-Type": "application/json"},
                data=json.dumps(body),
                timeout=120,
            )
            if r.status_code == 200:
                data = r.json()
                for part in data["candidates"][0]["content"]["parts"]:
                    inline = part.get("inlineData") or part.get("inline_data")
                    if inline and inline.get("data"):
                        return base64.b64decode(inline["data"])
                raise RuntimeError(f"Respuesta sin imagen: {json.dumps(data)[:400]}")
            if r.status_code == 429:
                wait = 15 * (attempt + 1)
                print(f"    rate limit (429), espero {wait}s...")
                time.sleep(wait)
                continue
            if r.status_code in (403, 404):  # modelo no disponible / sin acceso -> probar el siguiente
                last_err = f"{r.status_code} {model}: {r.text[:200]}"
                break
            raise RuntimeError(f"HTTP {r.status_code}: {r.text[:400]}")
    raise RuntimeError(f"No se pudo generar. Ultimo error: {last_err}")

# ----------------------------------------------------------------------------
# Procesado: recorte de fondo blanco + centrado + 256
# ----------------------------------------------------------------------------
def process(raw_path: Path, key: str):
    src = Image.open(raw_path).convert("RGB")
    w, h = src.size

    flood = src.copy()
    SENT = (255, 0, 255)
    for corner in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]:
        ImageDraw.floodfill(flood, corner, SENT, thresh=34)
    arr = np.asarray(flood)
    bg = (arr[..., 0] == 255) & (arr[..., 1] == 0) & (arr[..., 2] == 255)
    alpha = np.where(bg, 0.0, 1.0)

    a_img = Image.fromarray((alpha * 255).astype(np.uint8))
    a_img = a_img.filter(ImageFilter.GaussianBlur(max(1, w // 800)))
    an = np.asarray(a_img).astype(np.float64) / 255.0
    an = np.clip((an - 0.45) / 0.40, 0, 1)  # erode suave -> mata el halo blanco

    rgba = np.dstack([np.asarray(src).astype(np.uint8), (an * 255).astype(np.uint8)])
    img = Image.fromarray(rgba, "RGBA")

    ys, xs = np.where(an > 0.05)
    if len(xs) == 0:
        print(f"    !! {key}: no se detecto objeto (fondo no blanco?)")
        return None
    y0, y1, x0, x1 = ys.min(), ys.max(), xs.min(), xs.max()
    crop = img.crop((x0, y0, x1 + 1, y1 + 1))
    cw, ch = crop.size
    side = int(max(cw, ch) * 1.12)
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    canvas.paste(crop, ((side - cw) // 2, (side - ch) // 2), crop)
    final = canvas.resize((256, 256), Image.LANCZOS)

    out = STAGED / f"{key}.png"
    final.save(out)

    chk = Image.new("RGBA", (256, 256), APP_GREEN + (255,))
    chk.alpha_composite(final)
    chk.convert("RGB").save(CHECK / f"{key}.png")
    return out

# ----------------------------------------------------------------------------
# Grilla de revision
# ----------------------------------------------------------------------------
def contact_sheet():
    files = sorted(STAGED.glob("*.png"))
    if not files:
        print("No hay nada en staged/ para la grilla.")
        return
    cell, pad, cols = 160, 14, 4
    rows = (len(files) + cols - 1) // cols
    W = cols * cell + (cols + 1) * pad
    H = rows * cell + (rows + 1) * pad
    sheet = Image.new("RGB", (W, H), APP_GREEN)
    try:
        font = ImageFont.truetype("arial.ttf", 16)
    except Exception:
        font = ImageFont.load_default()
    d = ImageDraw.Draw(sheet)
    for i, f in enumerate(files):
        r, c = divmod(i, cols)
        x = pad + c * (cell + pad)
        y = pad + r * (cell + pad)
        icon = Image.open(f).convert("RGBA").resize((cell - 28, cell - 28), Image.LANCZOS)
        sheet.paste(icon, (x + 14, y + 4), icon)
        d.text((x + 8, y + cell - 20), f.stem, fill=(40, 40, 40), font=font)
    sheet.save(ROOT / "_contact_sheet.png")
    print(f"Grilla: {ROOT / '_contact_sheet.png'}")

# ----------------------------------------------------------------------------
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", help="generar/procesar solo esta key")
    ap.add_argument("--no-gen", action="store_true", help="no llamar API, solo re-procesar raws")
    ap.add_argument("--no-process", action="store_true", help="solo generar, no procesar")
    ap.add_argument("--sheet-only", action="store_true", help="solo armar la grilla")
    args = ap.parse_args()

    if args.sheet_only:
        contact_sheet()
        return

    if not args.no_gen and not API_KEY:
        sys.exit("ERROR: falta GEMINI_API_KEY en el entorno. "
                 "PowerShell: $env:GEMINI_API_KEY = \"AIza...\"")

    selected = (
        set(k.strip() for k in args.only.split(",") if k.strip())
        if args.only else None
    )
    items = [i for i in ICONS if (selected is None or i["key"] in selected)]
    if not items:
        sys.exit(f"No encontre la(s) key(s) '{args.only}' en ICONS.")

    for it in items:
        key = it["key"]
        print(f"== {key} ==")
        raw_path = RAW / f"{key}.png"
        if not args.no_gen:
            prompt = TEMPLATE.format(name=it["name"], design=it["design"], colors=it["colors"])
            try:
                png = generate_png(prompt)
                raw_path.write_bytes(png)
                print(f"    generado -> {raw_path}")
            except Exception as e:
                print(f"    !! error generando {key}: {e}")
                continue
            time.sleep(DELAY_S)
        if not args.no_process:
            if raw_path.exists():
                res = process(raw_path, key)
                if res:
                    print(f"    procesado -> {res}")
            else:
                print(f"    !! no existe {raw_path}, salteo procesado")

    if not args.no_process:
        contact_sheet()
    print("\nListo. Revisá .tmp_icons/staged/ y .tmp_icons/_contact_sheet.png")


if __name__ == "__main__":
    main()
