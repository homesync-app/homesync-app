import sys
from PIL import Image, ImageOps

def process_image(input_path, output_path):
    # Load the image and convert it to RGBA so it has an alpha channel
    img = Image.open(input_path).convert("RGBA")
    
    # Get the image data
    data = img.getdata()
    
    # Find background color (assuming top-left pixel is the background)
    bg_color = data[0]
    
    new_data = []
    
    # We will compute the bounding box manually
    min_x, min_y = img.width, img.height
    max_x, max_y = 0, 0
    
    # Threshold for considering a pixel "white enough" to be background
    # Background in the image is near #FDFDFD or #FAFAFA
    threshold = 240
    
    x = 0
    y = 0
    for item in data:
        # Check if the pixel is white-ish
        if item[0] > threshold and item[1] > threshold and item[2] > threshold:
            new_data.append((255, 255, 255, 0)) # Fully transparent
        else:
            new_data.append(item)
            # Update bounding box
            if x < min_x: min_x = x
            if y < min_y: min_y = y
            if x > max_x: max_x = x
            if y > max_y: max_y = y
            
        x += 1
        if x >= img.width:
            x = 0
            y += 1

    img.putdata(new_data)
    
    # Add a bit of padding (e.g., 20 pixels) to the bounding box
    padding = 20
    min_x = max(0, min_x - padding)
    min_y = max(0, min_y - padding)
    max_x = min(img.width - 1, max_x + padding)
    max_y = min(img.height - 1, max_y + padding)
    
    # Crop to the computed bounding box
    if max_x > min_x and max_y > min_y:
        img = img.crop((min_x, min_y, max_x, max_y))
    
    # Save the transparent, cropped image
    img.save(output_path, "PNG")

if __name__ == "__main__":
    input_file = r"c:\Users\Blas_\Documents\Aplicacion de Pareja\flutter_client\assets\images\logo_premium.png"
    output_file = r"c:\Users\Blas_\Documents\Aplicacion de Pareja\flutter_client\assets\images\logo_premium_transparent.png"
    try:
        process_image(input_file, output_file)
        print(f"BBOX cropping and transparency applied successfully to {output_file}")
    except Exception as e:
        print(f"Error: {e}")
