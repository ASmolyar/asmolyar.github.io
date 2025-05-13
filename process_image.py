import os
import sys
from PIL import Image
import urllib.request
from io import BytesIO
from extract_chess_pieces import extract_chess_pieces, create_sprite_sheet

def save_image_for_processing(image_path="chess_pieces.png"):
    """
    Save the chess pieces image to disk.
    If the image already exists, it will be used as is.
    """
    # Check if the image already exists
    if os.path.exists(image_path):
        print(f"Using existing image at {image_path}")
        return image_path
    
    # Otherwise, tell the user to save the image
    print(f"Please save the chess pieces image as {image_path} in the current directory.")
    print("The script will use this image to extract individual chess pieces.")
    return None

def main():
    try:
        # Define the image path
        image_path = "chess_pieces.png"
        
        # Check if the image exists
        image_path = save_image_for_processing(image_path)
        if not image_path:
            return
        
        # Verify the image can be opened
        try:
            with Image.open(image_path) as img:
                width, height = img.size
                print(f"Image dimensions: {width}x{height} pixels")
                
                # Basic validation - make sure the image is large enough to extract pieces
                if width < 12 or height < 2:
                    print("Error: Image is too small to extract chess pieces")
                    return
        except Exception as e:
            print(f"Error opening image: {e}")
            return
        
        # Extract chess pieces
        output_dir = "chess_pieces"
        print(f"\nExtracting chess pieces from {image_path} to {output_dir}/...")
        extract_chess_pieces(image_path, output_dir)
        
        # Create sprite sheets
        piece_types = ["queen", "king", "rook", "knight", "bishop", "pawn"]
        colors = ["black", "white"]
        
        # Create sprite sheet for regular pieces
        create_sprite_sheet(output_dir, "chess_sprite_sheet.png", piece_types, colors)
        
        # Create sprite sheet for transparent pieces
        transparent_output_dir = output_dir
        try:
            # Check if transparent pieces exist
            sample_path = os.path.join(transparent_output_dir, f"{colors[0]}_{piece_types[0]}_transparent.png")
            if os.path.exists(sample_path):
                print("\nCreating sprite sheet for transparent pieces...")
                
                # Modified piece filenames for transparent versions
                transparent_piece_types = [f"{pt}_transparent" for pt in piece_types]
                create_sprite_sheet(output_dir, "chess_sprite_sheet_transparent.png", transparent_piece_types, colors)
        except Exception as e:
            print(f"Error creating transparent sprite sheet: {e}")
        
        # Display information about the extracted pieces
        print("\nExtracted the following chess pieces:")
        for color in colors:
            print(f"\n{color.upper()} PIECES:")
            for piece in piece_types:
                # Regular piece
                piece_path = os.path.join(output_dir, f"{color}_{piece}.png")
                if os.path.exists(piece_path):
                    with Image.open(piece_path) as piece_img:
                        print(f"  - {color}_{piece}.png: {piece_img.size[0]}x{piece_img.size[1]} pixels")
                else:
                    print(f"  - {color}_{piece}.png: Not found")
                
                # Transparent piece
                transparent_path = os.path.join(output_dir, f"{color}_{piece}_transparent.png")
                if os.path.exists(transparent_path):
                    with Image.open(transparent_path) as transparent_img:
                        print(f"  - {color}_{piece}_transparent.png: {transparent_img.size[0]}x{transparent_img.size[1]} pixels")
        
        print("\nAll processing completed successfully!")
        print(f"- Individual pieces are saved in the '{output_dir}' directory")
        print("- Regular sprite sheet: chess_sprite_sheet.png")
        print("- Transparent sprite sheet: chess_sprite_sheet_transparent.png")

    except Exception as e:
        print(f"An error occurred: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main() 