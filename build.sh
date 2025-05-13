#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "Creating a static build without Parcel..."

# Clean dist directory if it exists
rm -rf dist
mkdir -p dist

# Install TypeScript for transpilation
echo "Installing dependencies..."
npm install typescript --no-save

# Transpile TypeScript files to JavaScript
echo "Transpiling TypeScript files..."
npx tsc src/scripts/main.ts --outDir dist/scripts --target es2015 --module es2015 --esModuleInterop
npx tsc src/scripts/particles.ts --outDir dist/scripts --target es2015 --module es2015 --esModuleInterop

# Copy HTML files directly but modify the script tag
echo "Copying and modifying HTML files..."
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

/*.mjs
  Content-Type: application/javascript

/*.css
  Content-Type: text/css
EOF

echo "Build complete!"
echo "Files in dist directory:"
ls -la dist/ 