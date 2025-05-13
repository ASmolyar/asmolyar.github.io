#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "Removing any existing lock files..."
rm -f package-lock.json
rm -f yarn.lock

echo "Installing dependencies with standard npm install..."
# Ensure all optional dependencies are installed
npm install --include=optional

# Explicitly install platform-specific watcher
echo "Installing platform-specific dependencies..."
npm install @parcel/watcher-linux-x64-glibc --no-save

# Create simple .parcelrc to avoid native module issues
echo "Creating simplified Parcel configuration..."
cat > .parcelrc << EOF
{
  "extends": "@parcel/config-default",
  "transformers": {
    "*.css": ["@parcel/transformer-postcss", "@parcel/transformer-css-experimental"]
  },
  "optimizers": {
    "*.js": [],
    "*.css": []
  }
}
EOF

echo "Building project..."
npx parcel build src/index.html --dist-dir dist --no-optimize --no-cache

echo "Build complete!" 