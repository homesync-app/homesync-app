from pathlib import Path
from PIL import Image, ImageFilter

source_dir = Path(r"C:\Users\Blas_\Downloads\assets")
target_dir = Path(r"C:\Users\Blas_\Downloads\assets_clean")

target_dir.mkdir(parents=True, exist_ok=True)

for source in sorted(source_dir.glob("real-*.png")):
    image = Image.open(source).convert("RGB")
    width, height = image.size
    status_h = max(84, round(height * 0.048))

    sample_top = min(height - 1, status_h)
    sample_bottom = min(height, status_h * 2)
    sample = image.crop((0, sample_top, width, sample_bottom))
    clean_bar = sample.resize((width, status_h), Image.Resampling.BICUBIC)
    clean_bar = clean_bar.filter(ImageFilter.GaussianBlur(radius=max(18, status_h // 5)))

    cleaned = image.copy()
    cleaned.paste(clean_bar, (0, 0))
    cleaned.save(target_dir / source.name, optimize=True)

    print(f"{source.name}: cleaned top {status_h}px")
