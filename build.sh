#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "Removing any existing lock files..."
rm -f package-lock.json
rm -f yarn.lock

echo "Installing minimal dependencies..."
# Install with all optionals to get platform binaries
npm install --no-package-lock --include=optional

# Explicitly install the Linux watcher
echo "Installing platform-specific watcher..."
npm install @parcel/watcher-linux-x64-glibc --no-save

echo "Creating a minimal build setup..."
# Create a very minimal Parcel config that disables transformers
cat > .parcelrc << EOF
{
  "extends": "@parcel/config-default",
  "resolvers": ["@parcel/resolver-default"],
  "transformers": {
    "*.{css,scss}": ["...", "@parcel/transformer-raw"],
    "*.{js,jsx,ts,tsx}": ["@parcel/transformer-js"]
  },
  "packagers": {
    "*.html": "@parcel/packager-html",
    "*.css": "@parcel/packager-raw-url",
    "*.js": "@parcel/packager-js",
    "*": "@parcel/packager-raw"
  },
  "optimizers": {
    "*.js": [],
    "*.css": [],
    "*.html": []
  },
  "reporters": ["@parcel/reporter-cli"]
}
EOF

echo "Installing direct dependencies..."
npm install @parcel/transformer-raw @parcel/packager-raw @parcel/packager-raw-url --no-save

echo "Building project..."
# Use explicit flags to bypass watcher issues
npx parcel build src/index.html --dist-dir dist --no-cache --detailed-report 0 --target=default

echo "Build complete!" 