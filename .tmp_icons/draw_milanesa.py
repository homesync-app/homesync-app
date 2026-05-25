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

def value_noise(cells, seed):
    r = np.random.default_rng(seed).random((cells, cells))
    im = Image.fromarray((r * 255).astype(np.uint8)).resize((W, W), Image.BICUBIC)
    a = np.asarray(im).astype(np.float64) / 255.0
    return (a - a.mean()) / (a.std() + 1e-9)

rgb = np.zeros((W, W, 3)); alpha = np.zeros((W, W))

cx, cy = W * 0.50, W * 0.50
rx, ry = W * 0.40, W * 0.30

def shape(center_y):
    ex = (xx - cx) / rx
    ey = (yy - center_y) / ry
    rad = np.sqrt(ex ** 2 + ey ** 2)
    th = np.arctan2(ey, ex)
    outline = (1.0 + 0.045 * np.sin(3 * th + 0.5) + 0.03 * np.sin(5 * th + 1.7)
               + 0.02 * np.sin(7 * th + 3.1) + 0.018 * np.sin(2 * th + 0.2))
    return rad, outline

# ---------------- drop shadow ----------------
sh = np.exp(-(((xx - cx) / (rx * 1.02)) ** 2 + ((yy - (cy + ry * 0.92)) / (ry * 0.30)) ** 2))
rgb, alpha = over(rgb, alpha, np.zeros((W, W, 3)), np.clip(sh, 0, 1) * 0.22)

# ---------------- side / thickness (crust band, shifted down) ----------------
rad_s, out_s = shape(cy + W * 0.045)
side_a = smoothstep(0.016, -0.016, rad_s - out_s)
side_shade = 0.72 + 0.20 * smoothstep(ry * 1.2, -ry, (yy - cy))
side_rgb = np.stack([np.full((W, W), 170.), np.full((W, W), 110.), np.full((W, W), 52.)], -1) * side_shade[..., None]
rgb, alpha = over(rgb, alpha, np.clip(side_rgb, 0, 255), side_a)

# ---------------- top surface ----------------
rad, outline = shape(cy)
top_a = smoothstep(0.014, -0.014, rad - outline)
inside = rad < outline

# breaded crumb texture
n1 = value_noise(14, 1)
n2 = value_noise(46, 2)
n3 = value_noise(95, 3)
tex = 0.5 * n1 + 0.32 * n2 + 0.18 * n3
texn = np.clip(0.5 + 0.42 * tex, 0, 1)

dark = np.array([150., 96., 44.])
mid = np.array([214., 158., 90.])
light = np.array([240., 200., 134.])
lo = (texn < 0.5)[..., None]
t1 = (texn / 0.5)[..., None]; t2 = ((texn - 0.5) / 0.5)[..., None]
col = np.where(lo, dark * (1 - t1) + mid * t1, mid * (1 - t2) + light * t2)

# gentle dome lighting
dome = np.clip(1 - (rad / np.clip(outline, 1e-6, None)) ** 2, 0, 1)
height = np.sqrt(dome) * (W * 0.05)
gx = np.gradient(height, axis=1); gy = np.gradient(height, axis=0)
Nz = np.ones_like(gx)
nl = np.sqrt(gx ** 2 + gy ** 2 + 1) + 1e-9
L = np.array([-0.35, -0.45, 0.82]); L = L / np.linalg.norm(L)
diff = np.clip((-gx) * L[0] + (-gy) * L[1] + Nz * L[2], 0, 1) / nl * nl  # keep simple
diff = np.clip((-gx / nl) * L[0] + (-gy / nl) * L[1] + (Nz / nl) * L[2], 0, 1)
bright = 0.80 + 0.26 * diff
col = col * bright[..., None]

# crust rim darkening near edge
rim = smoothstep(0.0, 0.16, outline - rad)
col = col * (0.82 + 0.18 * rim)[..., None]

# toasted crispy spots + a few light crumbs
rng = np.random.default_rng(11)
for _ in range(26):
    a = rng.uniform(0, 2 * np.pi); rr = rng.uniform(0.28, 0.86)
    bxx = cx + np.cos(a) * rr * rx; byy = cy + np.sin(a) * rr * ry
    rad_b = rng.uniform(W * 0.008, W * 0.020)
    blob = np.exp(-(((xx - bxx) ** 2 + (yy - byy) ** 2) / (2 * rad_b ** 2)))
    col = col - (blob * rng.uniform(30, 55))[..., None]
for _ in range(18):
    a = rng.uniform(0, 2 * np.pi); rr = rng.uniform(0, 0.8)
    bxx = cx + np.cos(a) * rr * rx; byy = cy + np.sin(a) * rr * ry
    rad_b = rng.uniform(W * 0.006, W * 0.014)
    blob = np.exp(-(((xx - bxx) ** 2 + (yy - byy) ** 2) / (2 * rad_b ** 2)))
    col = col + (blob * rng.uniform(20, 40))[..., None]

# broad soft sheen
sheen = np.exp(-(((xx - (cx - rx * 0.25)) / (W * 0.16)) ** 2 + ((yy - (cy - ry * 0.30)) / (W * 0.12)) ** 2))
col = col + (sheen * 16)[..., None] * inside[..., None]

col = np.clip(col, 0, 255)
rgb, alpha = over(rgb, alpha, col, top_a)

out = np.dstack([np.clip(rgb, 0, 255), np.clip(alpha * 255, 0, 255)]).astype(np.uint8)
img = Image.fromarray(out, "RGBA").resize((S, S), Image.LANCZOS)
img.save(".tmp_icons/milanesa_v3.png")
print("saved", img.size)
