from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter

W, H = 1024, 500
OUT = Path(r"C:\Users\Blas_\Downloads\homesync_feature_graphic_v3.png")
OUT_JPG = Path(r"C:\Users\Blas_\Downloads\homesync_feature_graphic_v3.jpg")

FONT_BLACK = r"C:\Windows\Fonts\Montserrat-Black.ttf"
FONT_EXTRA = r"C:\Windows\Fonts\Montserrat-ExtraBold.ttf"
FONT_BOLD = r"C:\Windows\Fonts\Montserrat-Bold.ttf"
FONT_SEMI = r"C:\Windows\Fonts\Montserrat-SemiBold.ttf"


def font(path, size):
    return ImageFont.truetype(path, size)


def lerp(a, b, t):
    return int(a + (b - a) * t)


def make_bg():
    im = Image.new("RGB", (W, H), "#FFF7EF")
    px = im.load()
    for y in range(H):
        for x in range(W):
            tx = x / W
            ty = y / H
            r = lerp(255, 250, ty)
            g = lerp(249, 237, ty)
            b = lerp(241, 230, ty)
            peach = max(0, 1 - (((x - 850) / 500) ** 2 + ((y - 80) / 340) ** 2))
            sage = max(0, 1 - (((x - 660) / 400) ** 2 + ((y - 520) / 250) ** 2))
            r = lerp(r, 255, peach * 0.33)
            g = lerp(g, 222, peach * 0.33)
            b = lerp(b, 202, peach * 0.33)
            r = lerp(r, 225, sage * 0.20)
            g = lerp(g, 242, sage * 0.20)
            b = lerp(b, 236, sage * 0.20)
            px[x, y] = (r, g, b)
    return im.convert("RGBA")


def shadow(base, box, radius, blur=22, alpha=28, offset=(0, 10)):
    x0, y0, x1, y1 = box
    w, h = x1 - x0, y1 - y0
    layer = Image.new("RGBA", (w + blur * 4, h + blur * 4), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.rounded_rectangle((blur * 2, blur * 2, blur * 2 + w, blur * 2 + h), radius, fill=(83, 55, 42, alpha))
    layer = layer.filter(ImageFilter.GaussianBlur(blur))
    base.alpha_composite(layer, (x0 - blur * 2 + offset[0], y0 - blur * 2 + offset[1]))


def line(draw, points, fill, width=4):
    draw.line(points, fill=fill, width=width, joint="curve")


def draw_scene(img):
    d = ImageDraw.Draw(img)

    # Soft stage behind the illustration.
    stage = Image.new("RGBA", (500, 430), (0, 0, 0, 0))
    sd = ImageDraw.Draw(stage)
    sd.ellipse((20, 22, 500, 430), fill=(255, 239, 226, 150))
    sd.ellipse((140, 215, 510, 450), fill=(229, 242, 237, 115))
    stage = stage.filter(ImageFilter.GaussianBlur(4))
    img.alpha_composite(stage, (520, 34))

    # Room arch.
    shadow(img, (642, 68, 800, 310), 56, blur=18, alpha=16, offset=(0, 8))
    d.rounded_rectangle((650, 78, 790, 310), 70, fill=(255, 246, 234, 215), outline=(234, 205, 181, 150), width=2)
    d.rounded_rectangle((678, 105, 772, 310), 48, fill=(221, 139, 91, 210), outline=(181, 100, 62, 95), width=2)
    d.arc((678, 105, 772, 196), 180, 360, fill=(181, 100, 62, 95), width=2)
    d.ellipse((760, 210, 768, 218), fill="#F4C56E")

    # Entry console and plant.
    d.rounded_rectangle((600, 230, 675, 296), 8, fill=(223, 180, 130, 185), outline=(181, 140, 98, 80), width=1)
    d.rectangle((611, 250, 664, 294), fill=(218, 170, 116, 160))
    d.line((637, 250, 637, 294), fill=(181, 140, 98, 90), width=1)
    d.rounded_rectangle((625, 204, 651, 230), 7, fill=(248, 236, 213, 230), outline=(210, 176, 130, 90), width=1)
    for pts in [
        [(638, 205), (632, 187)],
        [(638, 205), (646, 188)],
        [(638, 205), (621, 196)],
        [(638, 205), (655, 196)],
    ]:
        line(d, pts, "#84A59D", 3)

    # Lamp.
    d.line((875, 202, 850, 330), fill=(178, 130, 88, 170), width=5)
    d.line((875, 202, 912, 330), fill=(178, 130, 88, 170), width=5)
    d.line((882, 202, 882, 330), fill=(178, 130, 88, 120), width=4)
    d.rounded_rectangle((832, 160, 924, 214), 18, fill=(255, 235, 194, 230), outline=(217, 172, 112, 120), width=1)
    d.rectangle((850, 214, 907, 221), fill=(216, 171, 111, 120))
    d.ellipse((852, 132, 906, 176), fill=(255, 232, 185, 110))

    # Floor.
    d.polygon([(550, 365), (1000, 330), (1000, 500), (525, 500)], fill=(244, 221, 198, 108))
    for yy in [385, 424, 462]:
        d.line((550, yy, 1000, yy - 28), fill=(224, 194, 165, 60), width=2)

    # Grocery bag.
    shadow(img, (745, 318, 855, 435), 12, blur=14, alpha=22, offset=(0, 8))
    d.polygon([(758, 332), (840, 318), (856, 418), (770, 438)], fill=(226, 184, 122, 220), outline=(185, 136, 84, 100))
    d.arc((780, 300, 833, 360), 180, 360, fill=(132, 165, 157, 190), width=5)
    d.polygon([(780, 330), (796, 286), (812, 330)], fill="#84A59D")
    d.polygon([(812, 328), (835, 292), (837, 340)], fill="#E8943A")
    d.ellipse((790, 294, 822, 326), fill="#EE652B")

    # Cat, warm and friendly but simple.
    cat = Image.new("RGBA", (260, 210), (0, 0, 0, 0))
    cd = ImageDraw.Draw(cat)
    cd.ellipse((88, 74, 194, 170), fill=(205, 111, 49, 238))
    cd.ellipse((72, 42, 152, 118), fill=(222, 133, 61, 245))
    cd.polygon([(84, 50), (94, 18), (112, 55)], fill=(222, 133, 61, 245))
    cd.polygon([(130, 54), (154, 25), (148, 70)], fill=(222, 133, 61, 245))
    cd.ellipse((95, 72, 108, 85), fill="#3F3633")
    cd.ellipse((130, 72, 143, 85), fill="#3F3633")
    cd.polygon([(118, 88), (128, 88), (123, 96)], fill="#7A3B2A")
    cd.arc((106, 92, 122, 108), 0, 150, fill="#7A3B2A", width=2)
    cd.arc((124, 92, 140, 108), 30, 180, fill="#7A3B2A", width=2)
    for sx in [96, 140]:
        cd.line((sx, 92, sx - 34, 82), fill=(122, 62, 36, 160), width=2)
        cd.line((sx, 99, sx - 35, 101), fill=(122, 62, 36, 130), width=2)
    for tx in [104, 118, 166]:
        cd.arc((tx, 70, tx + 38, 158), 92, 254, fill=(151, 74, 36, 140), width=5)
    cd.arc((8, 30, 116, 150), 100, 270, fill=(205, 111, 49, 238), width=22)
    cd.ellipse((126, 148, 158, 194), fill=(193, 92, 41, 230))
    cd.ellipse((162, 146, 194, 192), fill=(193, 92, 41, 230))
    cat = cat.filter(ImageFilter.GaussianBlur(0.15))
    img.alpha_composite(cat, (548, 252))


def brand_text(img):
    d = ImageDraw.Draw(img)
    shadow(img, (42, 56, 514, 443), 42, blur=22, alpha=18, offset=(0, 12))
    d.rounded_rectangle((42, 56, 514, 443), 42, fill=(255, 255, 255, 142), outline=(255, 229, 214, 120), width=1)

    # Pill
    d.rounded_rectangle((70, 82, 226, 122), 20, fill=(255, 255, 255, 218), outline="#F5C7B4", width=1)
    d.ellipse((88, 97, 99, 108), fill="#EE652B")
    d.text((112, 90), "HomeSync", font=font(FONT_EXTRA, 18), fill="#EE652B")

    d.text((70, 155), "Tu hogar,", font=font(FONT_BLACK, 65), fill="#2B2321")
    d.text((70, 224), "en ", font=font(FONT_BLACK, 65), fill="#2B2321")
    d.text((168, 224), "sintonía", font=font(FONT_BLACK, 65), fill="#EE652B")
    d.text(
        (70, 317),
        "Organizá tareas, gastos y compras\ncompartidas sin perder el ritmo.",
        font=font(FONT_SEMI, 26),
        fill="#746662",
        spacing=8,
    )

    x, y = 70, 402
    for label, accent, width in [
        ("Pareja", "#EE652B", 102),
        ("Familia", "#84A59D", 108),
        ("Convivencia", "#E8943A", 150),
    ]:
        d.rounded_rectangle((x, y, x + width, y + 34), 17, fill=(255, 255, 255, 170), outline=accent, width=1)
        d.ellipse((x + 14, y + 12, x + 24, y + 22), fill=accent)
        d.text((x + 34, y + 7), label, font=font(FONT_BOLD, 15), fill="#3F3633")
        x += width + 10


def chip(img, x, y, label, accent, icon):
    w = 178 if len(label) < 12 else 218
    h = 48
    shadow(img, (x, y, x + w, y + h), 24, blur=13, alpha=24, offset=(0, 6))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((x, y, x + w, y + h), 24, fill=(255, 255, 255, 222), outline=(255, 226, 211, 140), width=1)
    d.ellipse((x + 16, y + 14, x + 34, y + 32), fill=accent)
    d.text((x + 21, y + 9), icon, font=font(FONT_BOLD, 17), fill="#FFFFFF")
    d.text((x + 48, y + 12), label, font=font(FONT_BOLD, 18), fill="#3F3633")


def main():
    img = make_bg()
    draw_scene(img)
    chip(img, 710, 338, "Tarea lista", "#EE652B", "✓")
    chip(img, 740, 400, "Gasto pago", "#84A59D", "$")
    chip(img, 558, 392, "Lista al día", "#E8943A", "+")
    brand_text(img)

    rgb = img.convert("RGB")
    rgb.save(OUT, optimize=True)
    rgb.save(OUT_JPG, quality=94, optimize=True)
    print(OUT)
    print(OUT_JPG)


if __name__ == "__main__":
    main()
