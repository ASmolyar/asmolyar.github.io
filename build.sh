#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "Creating a build with esbuild for TypeScript processing..."

# Clean dist directory if it exists
rm -rf dist
mkdir -p dist

# Install esbuild (minimal, fast TypeScript/JS bundler)
echo "Installing esbuild..."
npm install --no-save esbuild

# Copy static assets first
echo "Copying static assets..."
cp -r src/*.html dist/
cp -r src/styles dist/
cp -r src/assets dist/

# Process TypeScript files with esbuild
echo "Processing TypeScript files..."
npx esbuild src/scripts/main.ts --bundle --outfile=dist/scripts/main.js --format=esm --target=es2020

# Copy CNAME file if it exists
if [ -f CNAME ]; then
  cp CNAME dist/
fi

echo "Build complete!"
echo "Files in dist directory:"
ls -la dist/ 