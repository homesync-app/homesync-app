from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter

W, H = 1024, 500
OUT = Path(r"C:\Users\Blas_\Downloads\homesync_feature_graphic_final.png")
OUT_JPG = Path(r"C:\Users\Blas_\Downloads\homesync_feature_graphic_final.jpg")

ASSETS = Path(r"C:\Users\Blas_\Downloads\assets")
FONT_BLACK = r"C:\Windows\Fonts\Montserrat-Black.ttf"
FONT_EXTRA = r"C:\Windows\Fonts\Montserrat-ExtraBold.ttf"
FONT_BOLD = r"C:\Windows\Fonts\Montserrat-Bold.ttf"
FONT_SEMI = r"C:\Windows\Fonts\Montserrat-SemiBold.ttf"
FONT_MED = r"C:\Windows\Fonts\Montserrat-Medium.ttf"


def font(path, size):
    return ImageFont.truetype(path, size)


def lerp(a, b, t):
    return int(a + (b - a) * t)


def gradient_bg():
    img = Image.new("RGB", (W, H), "#FFF6EE")
    px = img.load()
    for y in range(H):
        for x in range(W):
            tx = x / W
            ty = y / H
            base = (
                lerp(255, 250, ty),
                lerp(247, 238, ty),
                lerp(238, 229, ty),
            )
            peach = max(0, 1 - (((x - 850) / 430) ** 2 + ((y - 95) / 270) ** 2))
            sage = max(0, 1 - (((x - 690) / 360) ** 2 + ((y - 470) / 250) ** 2))
            r, g, b = base
            r = lerp(r, 255, peach * 0.35)
            g = lerp(g, 211, peach * 0.35)
            b = lerp(b, 189, peach * 0.35)
            r = lerp(r, 218, sage * 0.28)
            g = lerp(g, 240, sage * 0.28)
            b = lerp(b, 234, sage * 0.28)
            px[x, y] = (r, g, b)
    return img


def rounded_rect_layer(size, radius, fill, outline=None, width=1):
    layer = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.rounded_rectangle((0, 0, size[0] - 1, size[1] - 1), radius, fill=fill, outline=outline, width=width)
    return layer


def paste_shadow(base, box, radius=36, blur=28, offset=(0, 16), alpha=42):
    x, y, w, h = box
    shadow = Image.new("RGBA", (w + blur * 4, h + blur * 4), (0, 0, 0, 0))
    d = ImageDraw.Draw(shadow)
    d.rounded_rectangle((blur * 2, blur * 2, blur * 2 + w, blur * 2 + h), radius, fill=(74, 54, 45, alpha))
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur))
    base.alpha_composite(shadow, (x - blur * 2 + offset[0], y - blur * 2 + offset[1]))


def phone_mock(path, width, angle):
    shot = Image.open(path).convert("RGB")
    crop_top = max(72, round(shot.height * 0.052))
    shot = shot.crop((0, crop_top, shot.width, shot.height))
    target_h = int(width * 1920 / 1080)
    shot = shot.resize((width, target_h), Image.Resampling.LANCZOS)

    pad = max(8, width // 24)
    radius = width // 9
    outer = Image.new("RGBA", (width + pad * 2, target_h + pad * 2), (0, 0, 0, 0))
    d = ImageDraw.Draw(outer)
    d.rounded_rectangle((0, 0, outer.width - 1, outer.height - 1), radius + pad, fill=(35, 30, 29, 255))
    d.rounded_rectangle((pad, pad, pad + width - 1, pad + target_h - 1), radius, fill=(255, 247, 238, 255))

    mask = Image.new("L", (width, target_h), 0)
    md = ImageDraw.Draw(mask)
    md.rounded_rectangle((0, 0, width - 1, target_h - 1), radius, fill=255)
    outer.paste(shot, (pad, pad), mask)

    camera = max(7, width // 28)
    cx = outer.width // 2
    cy = pad + 24
    d.ellipse((cx - camera // 2, cy - camera // 2, cx + camera // 2, cy + camera // 2), fill=(22, 20, 20, 255))
    return outer.rotate(angle, expand=True, resample=Image.Resampling.BICUBIC)


def draw_multicolor_headline(draw, x, y):
    black = font(FONT_BLACK, 69)
    orange = font(FONT_BLACK, 69)
    line1 = "Tu hogar,"
    line2a = "en "
    line2b = "sincronía"
    draw.text((x, y), line1, font=black, fill="#2B2321")
    y2 = y + 72
    draw.text((x, y2), line2a, font=black, fill="#2B2321")
    x2 = x + draw.textlength(line2a, font=black)
    draw.text((x2, y2), line2b, font=orange, fill="#EE652B")


def chip(draw, x, y, text, color, bg, icon_color=None):
    f = font(FONT_BOLD, 18)
    tw = int(draw.textlength(text, font=f))
    w = tw + 52
    h = 38
    draw.rounded_rectangle((x, y, x + w, y + h), radius=19, fill=bg, outline=color, width=1)
    draw.ellipse((x + 15, y + 13, x + 25, y + 23), fill=icon_color or color)
    draw.text((x + 34, y + 8), text, font=f, fill="#3F3633")
    return w


def main():
    img = gradient_bg().convert("RGBA")
    draw = ImageDraw.Draw(img)

    # Soft card behind the message.
    paste_shadow(img, (42, 54, 455, 386), radius=42, blur=24, offset=(0, 14), alpha=18)
    card = rounded_rect_layer((455, 386), 42, (255, 255, 255, 150), (255, 225, 206, 110), 1)
    img.alpha_composite(card, (42, 54))

    # Brand pill.
    draw.rounded_rectangle((70, 82, 210, 122), radius=20, fill="#FFFFFF", outline="#F7CBB7", width=1)
    draw.ellipse((88, 97, 99, 108), fill="#EE652B")
    draw.text((112, 90), "HomeSync", font=font(FONT_EXTRA, 18), fill="#EE652B")

    draw_multicolor_headline(draw, 70, 145)
    draw.text(
        (70, 300),
        "Tareas, gastos y compras compartidas\npara cualquier forma de vivir.",
        font=font(FONT_SEMI, 25),
        fill="#6E5F5B",
        spacing=7,
    )

    x = 70
    y = 390
    x += chip(draw, x, y, "Pareja", "#F6B49A", "#FFF1E9", "#EE652B") + 10
    x += chip(draw, x, y, "Familia", "#B8DDD3", "#EFF8F5", "#84A59D") + 10
    chip(draw, 70, y + 48, "Convivencia", "#F0CC91", "#FFF7E8", "#E8943A")
    chip(draw, 224, y + 48, "Solo", "#BFD1F2", "#EEF4FF", "#6B9FE8")

    # Product mockups.
    home = phone_mock(ASSETS / "real-home.png", 220, -7)
    family = phone_mock(ASSETS / "real-familia-ranking.png", 205, 8)

    paste_shadow(img, (563, 74, home.width, home.height), radius=48, blur=22, offset=(0, 18), alpha=58)
    paste_shadow(img, (758, 105, family.width, family.height), radius=48, blur=22, offset=(0, 18), alpha=46)
    img.alpha_composite(home, (563, 74))
    img.alpha_composite(family, (758, 105))

    # Floating value labels.
    label = rounded_rect_layer((190, 50), 25, (255, 255, 255, 218), (255, 214, 193, 120), 1)
    img.alpha_composite(label, (730, 358))
    draw.rounded_rectangle((748, 374, 770, 396), radius=8, fill="#FFE8DD")
    draw.text((782, 369), "Todo en orden", font=font(FONT_BOLD, 18), fill="#3F3633")

    label2 = rounded_rect_layer((164, 46), 23, (255, 255, 255, 210), (190, 218, 210, 120), 1)
    img.alpha_composite(label2, (548, 404))
    draw.rounded_rectangle((565, 418, 584, 437), radius=7, fill="#E8F3EF")
    draw.text((596, 414), "En equipo", font=font(FONT_BOLD, 17), fill="#3F3633")

    img = img.convert("RGB")
    img.save(OUT, optimize=True)
    img.save(OUT_JPG, quality=94, optimize=True)
    print(OUT)
    print(OUT_JPG)


if __name__ == "__main__":
    main()
