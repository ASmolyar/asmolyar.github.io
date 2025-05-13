#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "Removing any existing lock files..."
rm -f package-lock.json
rm -f yarn.lock

echo "Installing minimal dependencies..."
npm install --no-package-lock

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
npx parcel build src/index.html --dist-dir dist --no-cache --detailed-report 0

echo "Build complete!" 