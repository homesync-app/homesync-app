import numpy as np
from PIL import Image

SS = 4
S = 256
W = S * SS

yy, xx = np.mgrid[0:W, 0:W].astype(np.float64)

def smoothstep(e0, e1, x):
    t = np.clip((x - e0) / (e1 - e0), 0, 1)
    return t * t * (3 - 2 * t)

def over(dst_rgb, dst_a, src_rgb, src_a):
    out_a = src_a + dst_a * (1 - src_a)
    sa = src_a[..., None]; da = dst_a[..., None]
    out_rgb = (src_rgb * sa + dst_rgb * da * (1 - sa)) / np.clip(out_a[..., None], 1e-9, None)
    return out_rgb, out_a

rgb = np.zeros((W, W, 3))
alpha = np.zeros((W, W))

# ---------------- BODY geometry (oblate citrus) ----------------
cx, cy = W * 0.50, W * 0.525
rx, ry = W * 0.400, W * 0.350

# ---------------- DROP SHADOW (under everything) ----------------
sh = np.exp(-(((xx - cx) / (rx * 0.92)) ** 2 + ((yy - (cy + ry * 1.02)) / (ry * 0.14)) ** 2))
sh_a = np.clip(sh, 0, 1) * 0.20
rgb, alpha = over(rgb, alpha, np.zeros((W, W, 3)), sh_a)

# ---------------- BODY ----------------
nx = (xx - cx) / rx
ny = (yy - cy) / ry
rr = nx ** 2 + ny ** 2
z = np.sqrt(np.clip(1 - rr, 0, 1))

Nx, Ny, Nz = nx.copy(), ny.copy(), z.copy()
nlen = np.sqrt(Nx ** 2 + Ny ** 2 + Nz ** 2) + 1e-9
Nx, Ny, Nz = Nx / nlen, Ny / nlen, Nz / nlen

# vertical ripeness gradient: orange (top) -> ripe red (bottom)
vfrac = np.clip((yy - (cy - ry)) / (2 * ry), 0, 1)
w = (smoothstep(0.18, 0.98, vfrac) * 0.72)[..., None]
topc = np.array([253., 160., 52.])
botc = np.array([233., 92., 44.])
base = topc * (1 - w) + botc * w

# soft top-lit spherical shading (high floor -> luminous, not muddy)
L = np.array([-0.32, -0.58, 0.75]); L = L / np.linalg.norm(L)
diff = np.clip(Nx * L[0] + Ny * L[1] + Nz * L[2], 0, 1)
bright = 0.76 + 0.30 * diff
col = base * bright[..., None]

# soft glossy sheen (upper-left, diffuse)
hlx, hly = cx - rx * 0.30, cy - ry * 0.46
hl = np.exp(-(((xx - hlx) / (W * 0.115)) ** 2 + ((yy - hly) / (W * 0.095)) ** 2))
col = col + (hl * 58)[..., None] * (z > 0)[..., None]

# tight specular dot (subtle)
H = L + np.array([0, 0, 1.0]); H = H / np.linalg.norm(H)
spec = np.clip(Nx * H[0] + Ny * H[1] + Nz * H[2], 0, 1) ** 48
col = col + (spec * 0.30)[..., None] * 255.0

# faint sunken navel at top
d = np.exp(-(((xx - cx) / (W * 0.045)) ** 2 + ((yy - (cy - ry * 0.90)) / (W * 0.034)) ** 2))
col = col - (d * 22)[..., None]

# subtle dimpled skin texture
rng = np.random.default_rng(7)
noise = rng.normal(0, 1, (W, W))
col = col + (noise * 2.0 * (z > 0))[..., None]

col = np.clip(col, 0, 255)
rad = np.sqrt(rr)
body_a = smoothstep(1.004, 0.984, rad)
rgb, alpha = over(rgb, alpha, col, body_a)

# ---------------- GREEN STEM (slightly curved) ----------------
# centerline as a small quadratic from fruit top going up
t = np.linspace(0, 1, 60)
base_x, base_y = cx - W * 0.005, cy - ry * 0.95
ctrl_x, ctrl_y = cx - W * 0.045, cy - ry * 1.02
end_x, end_y = cx + W * 0.005, cy - ry * 1.16
px = (1 - t) ** 2 * base_x + 2 * (1 - t) * t * ctrl_x + t ** 2 * end_x
py = (1 - t) ** 2 * base_y + 2 * (1 - t) * t * ctrl_y + t ** 2 * end_y
dist = np.full((W, W), 1e9)
for i in range(len(t)):
    dist = np.minimum(dist, np.sqrt((xx - px[i]) ** 2 + (yy - py[i]) ** 2))
thick = W * 0.020 * (1 - 0.35 * np.linspace(0, 1, 1))  # base thickness
stem_a = smoothstep(W * 0.021, W * 0.013, dist)
stem_shade = 0.7 + 0.3 * smoothstep(W * 0.02, -W * 0.02, (xx - cx))
stem_rgb = np.stack([np.full((W, W), 96.), np.full((W, W), 146.), np.full((W, W), 56.)], -1) * stem_shade[..., None]
rgb, alpha = over(rgb, alpha, np.clip(stem_rgb, 0, 255), stem_a)

# ---------------- LEAF ----------------
A = np.radians(-48)
lx0, ly0 = cx + W * 0.012, cy - ry * 0.92
dx, dy = xx - lx0, yy - ly0
lu = dx * np.cos(A) + dy * np.sin(A)
lv = -dx * np.sin(A) + dy * np.cos(A)
leaf_len = W * 0.30
leaf_half = W * 0.082
tu = np.clip(lu / leaf_len, 0, 1)
env = leaf_half * np.sin(np.pi * tu)
ua = smoothstep(-2.5, 2.5, lu) * smoothstep(-2.5, 2.5, leaf_len - lu)
va = smoothstep(-2.5, 2.5, env - np.abs(lv))
leaf_a = np.clip(ua * va, 0, 1)
leaf_dark = np.array([46., 122., 50.])
leaf_light = np.array([138., 202., 88.])
leaf_col = leaf_dark * (1 - tu[..., None]) + leaf_light * tu[..., None]
across_shade = 0.80 + 0.30 * smoothstep(leaf_half, -leaf_half, lv)
leaf_col = leaf_col * across_shade[..., None]
vein = smoothstep(W * 0.006, 0, np.abs(lv)) * (env > W * 0.004)
leaf_col = leaf_col + (vein * 26)[..., None]
# leaf sheen
leaf_hl = np.exp(-(((lu - leaf_len * 0.35) / (W * 0.05)) ** 2 + ((lv + leaf_half * 0.3) / (W * 0.03)) ** 2))
leaf_col = leaf_col + (leaf_hl * 40)[..., None]
leaf_col = np.clip(leaf_col, 0, 255)
rgb, alpha = over(rgb, alpha, leaf_col, leaf_a)

# ---------------- output ----------------
out = np.dstack([np.clip(rgb, 0, 255), np.clip(alpha * 255, 0, 255)]).astype(np.uint8)
img = Image.fromarray(out, "RGBA").resize((S, S), Image.LANCZOS)
img.save(".tmp_icons/mandarina_v4.png")
print("saved", img.size, img.mode)
