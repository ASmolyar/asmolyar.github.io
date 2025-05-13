#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "Removing any existing lock files..."
rm -f package-lock.json
rm -f yarn.lock

echo "Installing dependencies with standard npm install..."
npm install

echo "Building project..."
npx parcel build src/index.html --dist-dir dist --no-optimize --no-cache

echo "Build complete!" 