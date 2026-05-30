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
    # --- Ronda 3: 18 mas egregios (emojis claramente wrong / inapropiados) ---
    {
        "key": "sugar",
        "name": "stack of white sugar cubes",
        "design": "A small stack/pile of 3-4 pure white sugar cubes arranged together "
                  "with one resting on top. Crisp clean cube shapes with crystalline "
                  "surface. Single group centered, viewed at a slight top-down angle.",
        "colors": "Pure white tones - bright white cubes (#FFFFFF) with subtle cool gray "
                  "shadows (#D8D8D8) and crystalline highlights (#FAFAFA). Slight blue-"
                  "gray cast in shadows for crystalline feel.",
    },
    {
        "key": "sweetener",
        "name": "sweetener sachet packet",
        "design": "A small flat rectangular paper sachet packet of artificial sweetener "
                  "(like Splenda/Hermesetas style), with a horizontal colored band across "
                  "the middle. Single packet centered, slight angle showing it lying flat.",
        "colors": "Soft pale tones - white packet body (#FAFAFA) with light pastel blue "
                  "accent stripe (#A8C8E8 to #5A88B8) horizontally across, subtle gray "
                  "shadow underneath (#D8D8D8). Clean minimal look.",
    },
    {
        "key": "pepperSpice",
        "name": "black pepper grinder mill",
        "design": "A wooden pepper grinder/mill standing upright - cylindrical wooden "
                  "body slightly tapered toward the top, with a metal grinder cap on top. "
                  "Classic pepper mill silhouette. Single grinder centered.",
        "colors": "Warm wooden tones - body in rich dark walnut brown (#5C3A1A to "
                  "#2C1A0A) with lighter highlights on the curves (#8B5A3C). Metallic "
                  "silver-gray cap on top (#A0A0A0 to #6A6A6A) with subtle sheen.",
    },
    {
        "key": "chickpeas",
        "name": "pile of dry chickpeas",
        "design": "A small mound/pile of dry chickpeas (garbanzos) - small round beige "
                  "spherical legumes grouped together in a heap, each with the "
                  "characteristic slight point/beak shape. Individual chickpeas visible. "
                  "Single pile centered, viewed slightly from above.",
        "colors": "Warm beige-tan tones - main body in light beige (#E8C896) to deeper "
                  "tan (#B88B4E) with subtle highlights (#F0DBA8) and shadow underneath "
                  "(#8B6B2E).",
    },
    {
        "key": "cocoa",
        "name": "bowl of cocoa powder",
        "design": "A small white ceramic bowl filled with rich dark cocoa powder - a "
                  "mound of fine chocolate-brown powder rising from the bowl, viewed "
                  "slightly from above. Single bowl centered.",
        "colors": "Rich chocolate brown cocoa powder (#5C3A1A to #3D1F0A) with subtle "
                  "highlights on the mound (#7B4F2A), in a clean white ceramic bowl "
                  "(#FAFAFA with cool gray shadow #D8D8D8).",
    },
    {
        "key": "mayonnaise",
        "name": "jar of mayonnaise",
        "design": "A round glass jar of mayonnaise with a screw-top lid, creamy white-"
                  "cream mayo visible through the clear glass, with a simple label band "
                  "around the middle. Single jar centered, viewed straight on.",
        "colors": "Clear glass jar with creamy white-cream mayo inside (#F8F4E0 to "
                  "#E8DEC8), simple white label band (#FFFFFF) with a thin blue accent "
                  "line (#5A88B8), colored cap (#F4C842 yellow or #4A8FBA blue).",
    },
    {
        "key": "jam",
        "name": "jar of strawberry jam",
        "design": "A round glass jar of strawberry/red fruit jam with a red gingham-"
                  "checkered cloth covering the lid (rustic style). Rich red jam visible "
                  "through the clear glass. Single jar centered, slightly angled.",
        "colors": "Clear glass jar with deep red-magenta jam (#C4283D to #7E1A2A), red "
                  "and white checkered gingham cloth lid (#E84A5A and #FFFFFF in a "
                  "small checker pattern). Subtle highlights on glass.",
    },
    {
        "key": "mustard",
        "name": "yellow mustard squeeze bottle",
        "design": "A small plastic squeeze bottle of yellow mustard - cylindrical bottle "
                  "with a pointed nozzle/tip cap on top, vivid yellow mustard visible "
                  "through the bottle. Standing upright centered.",
        "colors": "Vibrant yellow mustard (#F4D03F to #B8941A) visible through bottle, "
                  "white bottle plastic (#FAFAFA) with simple label, yellow pointed cap "
                  "(#F4D03F to #C8A018).",
    },
    {
        "key": "ketchup",
        "name": "red ketchup squeeze bottle",
        "design": "A red plastic squeeze bottle of ketchup - cylindrical bottle with a "
                  "pointed nozzle/tip cap, vivid red ketchup visible. Iconic ketchup "
                  "bottle silhouette. Single bottle standing upright centered.",
        "colors": "Vibrant red ketchup (#D32F2F to #8B0E0E), white bottle with red label "
                  "band wrapping the middle (#FAFAFA and #D32F2F), red pointed cap on top.",
    },
    {
        "key": "soySauce",
        "name": "soy sauce bottle",
        "design": "A small dark glass bottle of soy sauce with a small red cap, very "
                  "dark brown soy sauce visible through the glass. Iconic Asian soy sauce "
                  "bottle silhouette (rounded shoulders, narrow neck). Single bottle "
                  "centered. No brand text.",
        "colors": "Clear glass showing very dark brown soy sauce (#3D1F0A to #1A0805) "
                  "inside, small bright red cap on top (#D32F2F to #8B0E0E), simple "
                  "label area (#FAFAFA).",
    },
    {
        "key": "vinegar",
        "name": "vinegar bottle",
        "design": "A tall slim glass bottle of vinegar - cylindrical bottle with a long "
                  "narrow neck and a small cap, mostly transparent showing pale vinegar "
                  "liquid inside, with a small label around the middle. Single bottle "
                  "standing upright centered.",
        "colors": "Clear glass with pale yellow-tinted vinegar liquid (#F4EFD8) showing "
                  "through, white label area (#FAFAFA) with simple text accent, small "
                  "dark cap (#3D2A15).",
    },
    {
        "key": "chocolateMilk",
        "name": "chocolate milk bottle",
        "design": "A small rounded plastic bottle of chocolate milk with a brown cap, "
                  "rich chocolate-brown milk visible through the bottle. Small label area "
                  "showing a chocolate drop or hint. Single bottle centered.",
        "colors": "Plastic bottle with rich chocolate milk inside (#8B5A3C to #5C3A1A) "
                  "visible through transparent body, dark brown cap (#3D2A15), small "
                  "white-cream label area (#FAFAFA with #8B5A3C accents).",
    },
    {
        "key": "tofu",
        "name": "block of fresh white tofu",
        "design": "A clean rectangular block of fresh firm white tofu - sharp clean "
                  "square-edged block with a smooth slightly translucent surface, "
                  "uniformly white. Single block centered, viewed at a slight angle "
                  "showing depth.",
        "colors": "Soft cool white tones - body in bright white (#FAFAFA to #E8E8E8) "
                  "with cool blue-gray shadows (#C8D0D8) for translucency feel, subtle "
                  "warm highlight on top edge (#FFFCF0).",
    },
    {
        "key": "lentils",
        "name": "pile of red lentils",
        "design": "A small mound or pile of dry red-orange lentils - small flat round "
                  "disc-shaped legumes piled together. Many tiny discs visible. Single "
                  "pile centered, viewed slightly from above.",
        "colors": "Warm coral-orange tones - main pile in deep coral-orange (#D87838 to "
                  "#A85020) with subtle highlights on top (#E8A878) and shadow underneath "
                  "(#7A3A1A).",
    },
    {
        "key": "alcohol",
        "name": "bottle of medical rubbing alcohol",
        "design": "A small clear plastic bottle of medical rubbing alcohol (ethyl "
                  "alcohol antiseptic) with a screw cap, with a label showing a small "
                  "red medical cross symbol. Single bottle standing upright centered.",
        "colors": "Clear plastic bottle with pale liquid inside (#F0F4F8 with cool blue "
                  "tint), white label (#FAFAFA) with red medical cross (#D32F2F) and blue "
                  "accent (#2A6FB4), darker cap (#5A7892).",
    },
    {
        "key": "gummies",
        "name": "colorful gummy candies",
        "design": "A small cluster of 4-5 colorful translucent gummy candies (small "
                  "rounded bear-shaped or coin-shaped candies) in different colors: red, "
                  "yellow, green, orange. Grouped together, single cluster centered.",
        "colors": "Vibrant translucent jewel tones - red (#E84A5A), golden yellow "
                  "(#F4C842), bright green (#7AB04A), orange (#F49A3A). All glossy with "
                  "subtle highlights for jelly-like translucency.",
    },
    {
        "key": "insecticide",
        "name": "insecticide aerosol spray can",
        "design": "A cylindrical aerosol spray can of insecticide with a pressable "
                  "nozzle on top, with a label showing a small mosquito/insect graphic "
                  "indicating purpose. Single can standing upright centered.",
        "colors": "Metallic green can body (#3A8B3A to #1F4F1F) with white horizontal "
                  "label band (#FAFAFA) showing a small dark insect silhouette (#1A1A1A) "
                  "and red accent (#D32F2F), darker pressable nozzle cap (#3D2A15).",
    },
    {
        "key": "bleach",
        "name": "bleach bottle",
        "design": "A plastic bottle of bleach (lavandina) - tall white cylindrical "
                  "bottle with rounded shoulders and a bright blue cap on top, with a "
                  "blue label band around the middle. Single bottle standing upright "
                  "centered.",
        "colors": "Bright white plastic body (#FAFAFA to #E0E0E0) with bright blue cap "
                  "(#2A6FB4 to #1A4F8A), blue label area (#5AA8D0) with small accent. "
                  "Clean clinical look.",
    },
    # --- Ronda 4 (Tier 2): emojis indirectos / abstractos ---
    {
        "key": "oil",
        "name": "bottle of cooking oil",
        "design": "A tall slim glass bottle of cooking oil with a thin neck and a small "
                  "cap on top, pale golden oil visible inside. A simple label band "
                  "around the middle. Single bottle standing upright centered.",
        "colors": "Clear glass with pale golden-yellow oil (#F4D680 to #C8A040) visible "
                  "inside, simple white label band (#FAFAFA) with green accent (#5C8E3A), "
                  "small darker cap (#3D2A15).",
    },
    {
        "key": "flour",
        "name": "bag of flour",
        "design": "A paper bag of wheat flour - rectangular paper sack standing upright "
                  "with a folded top, with a label showing wheat stalks or a small wheat "
                  "icon. Single bag centered, slight angle showing depth.",
        "colors": "Cream-white paper bag (#F8F4E8 to #E8DEC0) with golden wheat accents "
                  "on label (#D4A848 to #8B6B2E), brown bottom shadow (#A87848). Slight "
                  "paper texture.",
    },
    {
        "key": "sunscreen",
        "name": "sunscreen bottle",
        "design": "A cylindrical squeeze bottle of sunscreen lotion with a flip-top cap, "
                  "white-yellow body with a sun graphic on the label. Single bottle "
                  "standing upright centered.",
        "colors": "White bottle (#FAFAFA to #E8E8E8) with bright sunny yellow accents "
                  "(#F4D03F) and a small sun icon on label (#F4A03F orange-yellow). "
                  "Small darker cap (#5A7892 or matching yellow).",
    },
    {
        "key": "toothpaste",
        "name": "tube of toothpaste",
        "design": "A horizontal tube of toothpaste with a screw cap at one end (the "
                  "smaller end), with the body in white-blue colors and a small mint "
                  "or stripe accent. Lying flat showing the tube shape, slightly squished "
                  "or full, single tube centered.",
        "colors": "White-cyan tube body (#FAFAFA to #B4D8E8) with bright blue accents "
                  "(#2A8FBA to #1A5F8A) and a stripe band, white cap (#FFFFFF).",
    },
    {
        "key": "dogFood",
        "name": "bag of dog food",
        "design": "A standing paper bag of dog food kibble with a label showing a small "
                  "dog silhouette/illustration. Rectangular bag shape with folded top. "
                  "Single bag centered, slight angle.",
        "colors": "Warm brown paper bag (#A57848 to #5C3A1A) with cream label area "
                  "(#F8F4E8) and a small brown dog silhouette (#3D2A15), small red "
                  "accent (#D32F2F).",
    },
    {
        "key": "catFood",
        "name": "bag of cat food",
        "design": "A standing paper bag of cat food kibble with a label showing a small "
                  "cat silhouette/illustration. Rectangular bag shape with folded top. "
                  "Single bag centered, slight angle.",
        "colors": "Soft pastel orange or blue paper bag (#F4B07A or #7AB0D8) with cream "
                  "label area (#F8F4E8) and small black cat silhouette (#1A1A1A), small "
                  "accent color (#F4C842).",
    },
    {
        "key": "drinkableYogurt",
        "name": "drinkable yogurt bottle",
        "design": "A small plastic bottle of drinkable yogurt with a colored cap, "
                  "creamy pink-white liquid visible through the bottle, with a small "
                  "strawberry or fruit icon on the label. Single bottle standing upright "
                  "centered.",
        "colors": "Creamy pink-white liquid (#FFE0E0 to #F0C8C8) visible through "
                  "transparent bottle, white-pink label (#FAFAFA with #F4A8B8 accent), "
                  "matching pink cap.",
    },
    {
        "key": "seasonings",
        "name": "spice jar",
        "design": "A small glass jar of mixed seasonings/spices with a perforated shaker "
                  "top (red or black cap with holes), with mixed dark red and orange "
                  "spices visible inside through the clear glass. Single jar centered.",
        "colors": "Clear glass jar with mixed red-orange spices visible (#A05028 to "
                  "#7A3A1A with hints of #E84A1A), red or black shaker cap on top "
                  "(#D32F2F or #1A1A1A), simple label band.",
    },
    {
        "key": "tuna",
        "name": "can of tuna",
        "design": "A short cylindrical aluminum can of tuna with a pull-tab lid on top, "
                  "with a small label showing a fish icon. Single can sitting flat, viewed "
                  "from a slight angle showing the lid and side.",
        "colors": "Metallic silver/gray can body (#C8C8C8 to #888888) with metallic "
                  "highlights, blue and white label band (#2A6FB4 and #FAFAFA) with a "
                  "small dark fish silhouette (#1A1A1A).",
    },
    {
        "key": "polenta",
        "name": "bowl of polenta",
        "design": "A small ceramic bowl filled with bright yellow polenta (cornmeal "
                  "porridge or dry grits), creamy or grainy mound visible from above. "
                  "Single bowl centered, viewed slightly from above.",
        "colors": "Bright golden-yellow polenta (#F4D03F to #B8941A) with subtle "
                  "highlights (#F8E078), in a white ceramic bowl (#FAFAFA with cool "
                  "shadow #D8D8D8).",
    },
    {
        "key": "oats",
        "name": "bowl of oat flakes",
        "design": "A small white ceramic bowl filled with rolled oat flakes - cream-"
                  "beige loose flakes piled in the bowl, viewed slightly from above "
                  "showing the texture of the oats.",
        "colors": "Cream-beige oats (#E8D8B0 to #A88848) with subtle highlights "
                  "(#F4E8C8) showing individual flake texture, white ceramic bowl "
                  "(#FAFAFA with cool gray shadow #D8D8D8).",
    },
    {
        "key": "celery",
        "name": "celery stalk",
        "design": "A stalk of fresh celery - a few thick light-green celery ribs with "
                  "their characteristic vertical ridges, topped with bright leafy green "
                  "leaves at the top. Single bunch centered, viewed at a slight angle.",
        "colors": "Pale yellow-green stalks (#C8D850 to #8AA830) with vertical ridge "
                  "details, brighter green leaves at top (#5C8E3A to #3D6F2A), subtle "
                  "highlights on the curves.",
    },
    {
        "key": "tomatoSauce",
        "name": "bottle of tomato sauce",
        "design": "A tall slim glass bottle of tomato sauce/passata with a small white "
                  "or red cap, deep red tomato sauce visible through the glass, with a "
                  "simple label showing a small tomato. Single bottle standing upright "
                  "centered.",
        "colors": "Deep red tomato sauce (#C42828 to #7A1A1A) visible through the "
                  "glass, simple white label area (#FAFAFA) with small tomato icon "
                  "(#E84A1A green leaf #5C8E3A), darker cap (#3D2A15).",
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
