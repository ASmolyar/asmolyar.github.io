#!/bin/bash
echo "Installing dependencies with standard npm install..."
npm install
echo "Building project..."
npm run build
echo "Build complete!" 