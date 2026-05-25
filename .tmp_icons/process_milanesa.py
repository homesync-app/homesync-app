import numpy as np
from PIL import Image, ImageDraw, ImageFilter

SRC = ".tmp_icons/milanesa_ia.png"
OUT = ".tmp_icons/milanesas_256.png"
CHECK = ".tmp_icons/milanesas_check.png"

src = Image.open(SRC).convert("RGB")
w, h = src.size
print("source:", src.size)

# --- flood fill background (white, connected to corners) ---
flood = src.copy()
SENT = (255, 0, 255)
for corner in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]:
    ImageDraw.floodfill(flood, corner, SENT, thresh=34)
arr = np.asarray(flood)
bg = (arr[..., 0] == 255) & (arr[..., 1] == 0) & (arr[..., 2] == 255)
alpha = np.where(bg, 0.0, 1.0)

# --- feather + slight erode to kill white fringe ---
a_img = Image.fromarray((alpha * 255).astype(np.uint8))
a_img = a_img.filter(ImageFilter.GaussianBlur(max(1, w // 800)))
an = np.asarray(a_img).astype(np.float64) / 255.0
an = np.clip((an - 0.45) / 0.40, 0, 1)  # shrink opaque region a touch

rgba = np.dstack([np.asarray(src).astype(np.uint8), (an * 255).astype(np.uint8)])
img = Image.fromarray(rgba, "RGBA")

# --- trim to content bbox, add even margin, center on square ---
ys, xs = np.where(an > 0.05)
y0, y1, x0, x1 = ys.min(), ys.max(), xs.min(), xs.max()
crop = img.crop((x0, y0, x1 + 1, y1 + 1))
cw, ch = crop.size
side = int(max(cw, ch) * 1.12)  # ~6% margin each side
canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
canvas.paste(crop, ((side - cw) // 2, (side - ch) // 2), crop)

final = canvas.resize((256, 256), Image.LANCZOS)
final.save(OUT)
print("saved", OUT, final.size)

# --- preview composited over the app's green card color ---
bg_green = Image.new("RGBA", (256, 256), (217, 236, 220, 255))
bg_green.alpha_composite(final)
bg_green.convert("RGB").save(CHECK)
print("saved", CHECK)
