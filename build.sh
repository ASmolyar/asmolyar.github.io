#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "Creating a build with esbuild for TypeScript processing..."

# Clean dist directory if it exists
rm -rf dist
mkdir -p dist
mkdir -p dist/scripts

# Install esbuild (minimal, fast TypeScript/JS bundler)
echo "Installing esbuild..."
npm install --no-save esbuild

# Copy static assets first
echo "Copying static assets..."
cp -r src/*.html dist/
cp -r src/styles dist/

# Create assets directory
mkdir -p dist/assets
mkdir -p dist/assets/logos

# Copy and normalize image extensions to lowercase
echo "Normalizing image extensions to lowercase..."
for file in src/assets/*; do
  if [ -f "$file" ]; then
    # Get the basename and extension
    filename=$(basename "$file")
    # Convert to lowercase and copy
    lowercase_filename=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
    cp "$file" "dist/assets/$lowercase_filename"
  fi
done

# Copy subdirectories in assets except for files already processed
echo "Copying asset subdirectories..."
for dir in src/assets/*/; do
  dir_name=$(basename "$dir")
  mkdir -p "dist/assets/$dir_name"
  cp -r "$dir"* "dist/assets/$dir_name/" 2>/dev/null || true
done

# Process TypeScript files with esbuild (ensure proper module format)
echo "Processing TypeScript files..."
npx esbuild src/scripts/main.ts --bundle --outfile=dist/scripts/main.js --format=esm --target=es2020 --sourcemap

# Copy HTML files but modify the script reference
echo "Copying and modifying HTML files..."
for htmlfile in src/*.html; do
  # Replace the TypeScript script reference with the compiled JavaScript
  sed 's|<script type="module" src="./scripts/main.ts"></script>|<script type="module" src="./scripts/main.js"></script>|g' "$htmlfile" > "dist/$(basename "$htmlfile")"
done

# Copy CNAME file if it exists
if [ -f CNAME ]; then
  cp CNAME dist/
fi

echo "Build complete!"
echo "Files in dist directory:"
ls -la dist/ 