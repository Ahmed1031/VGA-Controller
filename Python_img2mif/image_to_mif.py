import os
from PIL import Image

def image_to_mif(image_filename, mif_filename, width=640, height=480, bitwidth=8):
    """
    Convert a grayscale image into a Quartus .mif file.
    - Looks for the image in the same folder as this script.
    - Writes the .mif file in the same folder.
    """
    # Resolve absolute paths relative to the script’s location
    script_dir = os.path.dirname(os.path.abspath(__file__))
    image_path = os.path.join(script_dir, image_filename)
    mif_path   = os.path.join(script_dir, mif_filename)

    # Defensive check
    if not os.path.isfile(image_path):
        raise FileNotFoundError(f"Image file not found: {image_path}")

    # Load and process image
    img = Image.open(image_path).convert("L")
    img = img.resize((width, height))
    pixels = list(img.get_flattened_data())
    depth = width * height

    # Write MIF file
    with open(mif_path, "w") as f:
        f.write(f"WIDTH={bitwidth};\n")
        f.write(f"DEPTH={depth};\n")
        f.write("ADDRESS_RADIX=UNS;\n")
        f.write("DATA_RADIX=UNS;\n")
        f.write("CONTENT BEGIN\n")
        for addr, val in enumerate(pixels):
            f.write(f"{addr} : {val};\n")
        f.write("END;\n")

# Example usage:
# Place img_640_480.bmp in the same folder as image2mif.py
# Then call:
# image_to_mif("img_640_480.bmp", "image.mif")

