#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "Creating a static build without Parcel..."

# Clean dist directory if it exists
rm -rf dist
mkdir -p dist
mkdir -p dist/scripts

# Install TypeScript for transpilation
echo "Installing dependencies..."
npm install typescript --no-save

# Transpile TypeScript files to JavaScript using tsconfig
echo "Transpiling TypeScript files..."
npx tsc --project tsconfig.json

# Copy HTML files directly but modify the script tag
echo "Copying and modifying HTML files..."
# Replace TypeScript extension with JavaScript in the HTML
sed 's/src="\.\/scripts\/main.ts"/src="\.\/scripts\/main.js"/' src/index.html > dist/index.html

# Copy main directories
echo "Copying static assets..."
cp -r src/styles dist/
cp -r src/assets dist/

# Copy CNAME file if it exists
if [ -f CNAME ]; then
  cp CNAME dist/
fi

# Create proper MIME types configuration
echo "Setting up proper MIME types..."
cat > dist/_headers << EOF
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: no-referrer-when-downgrade

/*.js
  Content-Type: application/javascript

/*.css
  Content-Type: text/css

/scripts/*.js
  Content-Type: application/javascript
EOF

# Create a debug index.js to verify TypeScript compilation
echo "Creating debug info..."
echo "console.log('Build timestamp: $(date)');" > dist/scripts/debug.js

echo "Build complete!"
echo "Files in dist directory:"
ls -la dist/
echo "Files in scripts directory:"
ls -la dist/scripts/ 