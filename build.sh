#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "Creating a static build without Parcel..."

# Clean dist directory if it exists
rm -rf dist
mkdir -p dist

# Copy HTML files directly
echo "Copying source files to dist..."
cp src/*.html dist/

# Copy main directories
cp -r src/styles dist/
cp -r src/scripts dist/
cp -r src/assets dist/

# Copy CNAME file if it exists
if [ -f CNAME ]; then
  cp CNAME dist/
fi

echo "Build complete!"
echo "Files in dist directory:"
ls -la dist/ 