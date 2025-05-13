# Chess Piece Extraction Tool

This tool extracts individual chess pieces from an image containing a grid of chess pieces. It's designed specifically for the provided image with black pieces in the top row and white pieces in the bottom row, both ordered as queen, king, rook, knight, bishop, and pawn from left to right.

## Features

- Extracts individual chess pieces from the source image
- Creates transparent background versions of each piece
- Generates sprite sheets for both regular and transparent pieces
- Provides detailed information about the extracted images

## Requirements

- Python 3.6 or higher
- PIL (Pillow) library
- NumPy

## Installation

1. Make sure you have Python installed on your system.
2. Install the required packages:

```bash
pip install pillow numpy
```

## Usage

1. Save the chess pieces image as `chess_pieces.png` in the same directory as the scripts.
2. Run the main script:

```bash
python process_image.py
```

3. The script will:
   - Extract individual pieces and save them to the `chess_pieces` directory
   - Create transparent versions of each piece
   - Generate sprite sheets for both regular and transparent pieces
   - Display information about all extracted images

## Output Files

- `chess_pieces/` directory:
  - `black_queen.png`, `black_king.png`, etc. (12 individual pieces)
  - `black_queen_transparent.png`, `black_king_transparent.png`, etc. (12 transparent pieces)
- `chess_sprite_sheet.png`: A sprite sheet containing all regular pieces
- `chess_sprite_sheet_transparent.png`: A sprite sheet containing all transparent pieces

## Advanced Usage

You can also use the extraction functions directly in your own code:

```python
from extract_chess_pieces import extract_chess_pieces, make_transparent_background, create_sprite_sheet

# Extract pieces from an image
extract_chess_pieces("my_chess_image.png", "output_directory")

# Create a sprite sheet
piece_types = ["queen", "king", "rook", "knight", "bishop", "pawn"]
colors = ["black", "white"]
create_sprite_sheet("output_directory", "my_sprite_sheet.png", piece_types, colors)
```

## Customization

- Adjust the transparency threshold in `make_transparent_background()` if needed.
- Modify the script to handle different piece layouts or additional piece types.

## Troubleshooting

- If the transparent background doesn't look right, try adjusting the threshold in the `make_transparent_background()` function.
- For images with different layouts, modify the piece type order in the scripts. 