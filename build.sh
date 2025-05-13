#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "Creating a vanilla JS build..."

# Clean dist directory if it exists
rm -rf dist
mkdir -p dist
mkdir -p dist/scripts
mkdir -p dist/styles
mkdir -p dist/assets

# Install TypeScript for transpilation
echo "Installing dependencies..."
npm install typescript --no-save

# Create a JavaScript version of particles.js first
echo "Creating JavaScript modules..."

# Create particles.js
cat > dist/scripts/particles.js << 'EOF'
export default class ParticleBackground {
  constructor(canvasId) {
    this.canvas = document.getElementById(canvasId);
    this.ctx = this.canvas.getContext('2d');
    this.particles = [];
    this.init();
  }

  init() {
    this.canvas.width = window.innerWidth;
    this.canvas.height = window.innerHeight;
    this.createParticles();
    this.animate();
    
    window.addEventListener('resize', () => {
      this.canvas.width = window.innerWidth;
      this.canvas.height = window.innerHeight;
      this.createParticles();
    });
  }

  createParticles() {
    this.particles = [];
    const particleCount = 100;
    
    for (let i = 0; i < particleCount; i++) {
      this.particles.push({
        x: Math.random() * this.canvas.width,
        y: Math.random() * this.canvas.height,
        radius: Math.random() * 2 + 1,
        color: '#3498db',
        speedX: (Math.random() - 0.5) * 0.5,
        speedY: (Math.random() - 0.5) * 0.5
      });
    }
  }

  draw() {
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    
    this.particles.forEach(particle => {
      this.ctx.beginPath();
      this.ctx.arc(particle.x, particle.y, particle.radius, 0, Math.PI * 2);
      this.ctx.fillStyle = particle.color;
      this.ctx.fill();
      
      // Update position
      particle.x += particle.speedX;
      particle.y += particle.speedY;
      
      // Boundary check
      if (particle.x < 0 || particle.x > this.canvas.width) particle.speedX *= -1;
      if (particle.y < 0 || particle.y > this.canvas.height) particle.speedY *= -1;
    });
  }

  animate() {
    this.draw();
    requestAnimationFrame(() => this.animate());
  }
}
EOF

# Create main.js
cat > dist/scripts/main.js << 'EOF'
import ParticleBackground from './particles.js';

document.addEventListener('DOMContentLoaded', () => {
  // Initialize particle background
  const particlesCanvas = document.getElementById('particles-canvas');
  if (particlesCanvas) {
    new ParticleBackground('particles-canvas');
  }

  // Update current year in footer
  const currentYearElement = document.getElementById('current-year');
  if (currentYearElement) {
    currentYearElement.textContent = new Date().getFullYear().toString();
  }
  
  // Mobile menu toggle functionality
  const menuToggle = document.querySelector('.header__menu-toggle');
  const nav = document.querySelector('.header__nav');

  if (menuToggle && nav) {
    menuToggle.addEventListener('click', () => {
      nav.classList.toggle('active');
    });
  }
});
EOF

# Copy HTML files directly but modify the script tag
echo "Copying and modifying HTML files..."
cat src/index.html | sed 's/type="module" src="\.\/scripts\/main.ts"/type="module" src="\.\/scripts\/main.js"/' > dist/index.html

# Copy assets and styles
echo "Copying static assets..."
cp -r src/styles/* dist/styles/
cp -r src/assets/* dist/assets/

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

/scripts/*.js
  Content-Type: application/javascript

/*.css
  Content-Type: text/css
EOF

echo "Build complete!"
echo "Files in dist directory:"
ls -la dist/
echo "Files in scripts directory:"
ls -la dist/scripts/ 