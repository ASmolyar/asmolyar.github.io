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

# Create particles.js with simplified global approach
echo "Creating JavaScript modules with global particles..."

cat > dist/scripts/particles.js << 'EOF'
// Simple global particles approach - always visible in the background

export default class ParticleBackground {
  constructor(canvasId) {
    this.canvas = document.getElementById(canvasId);
    this.ctx = this.canvas.getContext('2d');
    
    // Constants for particle behavior
    this.DEFAULT_SPEED = 0.3;
    this.FRICTION = 0.98;
    this.MIN_SPEED = 0.1;
    this.TRAIL_LENGTH = 3;
    
    // State variables
    this.mouseX = 0;
    this.mouseY = 0;
    this.isMouseMoving = false;
    this.isMouseDown = false;
    this.particles = [];
    this.resizeTimeout = null;
    this.frameCount = 0;
    this.shockwaves = [];
    
    // SVG paths for chess pieces
    this.chessPiecePaths = {
      // White pawn (Chess_plt45.svg)
      'pl': 'm 22.5,9 c -2.21,0 -4,1.79 -4,4 0,0.89 0.29,1.71 0.78,2.38 C 17.33,16.5 16,18.59 16,21 c 0,2.03 0.94,3.84 2.41,5.03 C 15.41,27.09 11,31.58 11,39.5 H 34 C 34,31.58 29.59,27.09 26.59,26.03 28.06,24.84 29,23.03 29,21 29,18.59 27.67,16.5 25.72,15.38 26.21,14.71 26.5,13.89 26.5,13 c 0,-2.21 -1.79,-4 -4,-4 z',
      
      // Black pawn (Chess_pdt45.svg)
      'pd': 'm 22.5,9 c -2.21,0 -4,1.79 -4,4 0,0.89 0.29,1.71 0.78,2.38 C 17.33,16.5 16,18.59 16,21 c 0,2.03 0.94,3.84 2.41,5.03 C 15.41,27.09 11,31.58 11,39.5 H 34 C 34,31.58 29.59,27.09 26.59,26.03 28.06,24.84 29,23.03 29,21 29,18.59 27.67,16.5 25.72,15.38 26.21,14.71 26.5,13.89 26.5,13 c 0,-2.21 -1.79,-4 -4,-4 z',
      
      // Knight, bishop, rook, queen, king paths would go here
      'kl': 'M22.5 11.63V6M20 8h5M22.5 25s4.5-7.5 3-10.5c0 0-1-2.5-3-2.5s-3 2.5-3 2.5c-1.5 3 3 10.5 3 10.5M12.5 37c5.5 3.5 14.5 3.5 20 0v-7s9-4.5 6-10.5c-4-6.5-13.5-3.5-16 4V27v-3.5c-2.5-7.5-12-10.5-16-4-3 6 6 10.5 6 10.5v7'
    };
    
    // Define particle appearance parameters
    this.particleParams = {
      primaryColor: '#3498db',
      secondaryColor: '#2980b9',
      particleCount: 150,
      particleSize: 5,
      speedFactor: 1
    };
    
    this.init();
  }

  init() {
    this.setupCanvas();
    this.setupEventListeners();
    this.createParticles();
    this.animate();
  }
  
  setupCanvas() {
    this.canvas.width = window.innerWidth;
    this.canvas.height = window.innerHeight;
    
    // Set canvas to fixed position covering the entire viewport
    this.canvas.style.position = 'fixed';
    this.canvas.style.top = '0';
    this.canvas.style.left = '0';
    this.canvas.style.width = '100%';
    this.canvas.style.height = '100%';
    this.canvas.style.zIndex = '-1';  // Behind all content
    this.canvas.style.pointerEvents = 'none';  // Allow clicks to pass through
  }
  
  setupEventListeners() {
    // Resize event
    window.addEventListener('resize', () => {
      if (this.resizeTimeout) clearTimeout(this.resizeTimeout);
      
      this.resizeTimeout = setTimeout(() => {
        this.canvas.width = window.innerWidth;
        this.canvas.height = window.innerHeight;
        // No need to recreate particles on resize - they'll adapt
      }, 150);
    });
    
    // Mouse/touch interaction events
    window.addEventListener('mousemove', (e) => {
      this.mouseX = e.clientX;
      this.mouseY = e.clientY;
      this.isMouseMoving = true;
      
      setTimeout(() => { this.isMouseMoving = false; }, 3000);
    });
    
    window.addEventListener('mousedown', () => { this.isMouseDown = true; });
    window.addEventListener('mouseup', () => { this.isMouseDown = false; });
    
    window.addEventListener('click', (e) => {
      this.createShockwave(e.clientX, e.clientY, 0.7);
    });
    
    // Touch support
    window.addEventListener('touchmove', (e) => {
      if (e.touches.length > 0) {
        this.mouseX = e.touches[0].clientX;
        this.mouseY = e.touches[0].clientY;
        this.isMouseMoving = true;
      }
    });
    
    window.addEventListener('touchstart', (e) => {
      if (e.touches.length > 0) {
        this.isMouseDown = true;
        this.mouseX = e.touches[0].clientX;
        this.mouseY = e.touches[0].clientY;
      }
    });
    
    window.addEventListener('touchend', (e) => {
      this.isMouseDown = false;
      
      if (e.changedTouches.length > 0) {
        const touch = e.changedTouches[0];
        this.createShockwave(touch.clientX, touch.clientY, 0.7);
      }
      
      setTimeout(() => { this.isMouseMoving = false; }, 3000);
    });
  }
  
  createParticles() {
    this.particles = [];
    
    // Create a mix of different particle types
    const totalParticles = this.particleParams.particleCount;
    const chessCount = Math.floor(totalParticles * 0.3);  // 30% chess pieces
    const squareCount = Math.floor(totalParticles * 0.2); // 20% squares
    const circleCount = totalParticles - chessCount - squareCount; // Rest circles
    
    // Create chess piece particles
    for (let i = 0; i < chessCount; i++) {
      this.createParticle('chess');
    }
    
    // Create square particles
    for (let i = 0; i < squareCount; i++) {
      this.createParticle('square');
    }
    
    // Create circle particles
    for (let i = 0; i < circleCount; i++) {
      this.createParticle('circle');
    }
  }
  
  createParticle(shape) {
    const size = Math.random() * this.particleParams.particleSize + 1;
    const x = Math.random() * this.canvas.width;
    const y = Math.random() * this.canvas.height;
    
    const speedX = (Math.random() - 0.5) * this.DEFAULT_SPEED * this.particleParams.speedFactor;
    const speedY = (Math.random() - 0.5) * this.DEFAULT_SPEED * this.particleParams.speedFactor;
    
    const color = Math.random() > 0.5 ? this.particleParams.primaryColor : this.particleParams.secondaryColor;
    const rotation = Math.random() * Math.PI * 2;
    
    const rotationalVelocity = shape === 'chess' ? 0 : (Math.random() - 0.5) * 0.02;
    
    // Initialize trail
    const trail = [];
    for (let j = 0; j < this.TRAIL_LENGTH; j++) {
      trail.push({x, y});
    }
    
    // Determine chess piece if needed
    let chessPiece = '';
    let pieceColor = '';
    if (shape === 'chess') {
      const pieces = ['p', 'k'];  // Simplified to just pawn and king for example
      const pieceIndex = Math.floor(Math.random() * pieces.length);
      pieceColor = Math.random() > 0.5 ? 'd' : 'l';
      chessPiece = pieces[pieceIndex] + pieceColor;
    }
    
    this.particles.push({
      x,
      y,
      size,
      speedX,
      speedY,
      color,
      shape,
      rotation,
      rotationalVelocity,
      originalId: this.particles.length,
      trail,
      pieceColor,
      chessPiece,
      trailOpacity: 0.2 + Math.random() * 0.3
    });
  }
  
  createShockwave(x, y, intensity = 1.0) {
    this.shockwaves.push({
      x,
      y,
      radius: 0,
      intensity
    });
  }
  
  hexToRgba(hex, alpha) {
    const r = parseInt(hex.slice(1, 3), 16);
    const g = parseInt(hex.slice(3, 5), 16);
    const b = parseInt(hex.slice(5, 7), 16);
    return `rgba(${r}, ${g}, ${b}, ${alpha})`;
  }
  
  updateParticles() {
    // Increment frame counter
    this.frameCount++;
    
    // Process shockwaves
    for (let i = this.shockwaves.length - 1; i >= 0; i--) {
      const shockwave = this.shockwaves[i];
      
      // Expand shockwave
      shockwave.radius += 10;
      shockwave.intensity *= 0.95;
      
      // Apply force to nearby particles
      this.particles.forEach(particle => {
        const dx = particle.x - shockwave.x;
        const dy = particle.y - shockwave.y;
        const distance = Math.sqrt(dx * dx + dy * dy);
        
        // Only affect particles near the shockwave
        const shockwaveWidth = 50;
        if (Math.abs(distance - shockwave.radius) < shockwaveWidth) {
          const angle = Math.atan2(dy, dx);
          const force = shockwave.intensity * (1 - Math.abs(distance - shockwave.radius) / shockwaveWidth);
          
          // Push particles away
          particle.speedX += Math.cos(angle) * force * 1.5;
          particle.speedY += Math.sin(angle) * force * 1.5;
          
          // Add rotational effect
          if (particle.shape === 'chess') {
            const torque = (Math.random() - 0.5) * force * 0.2;
            particle.rotationalVelocity += torque;
          } else {
            particle.rotationalVelocity += (Math.random() - 0.5) * force * 0.1;
          }
        }
      });
      
      // Remove expired shockwaves
      if (shockwave.intensity < 0.05 || shockwave.radius > Math.max(this.canvas.width, this.canvas.height)) {
        this.shockwaves.splice(i, 1);
      }
    }
    
    // Update all particles
    this.particles.forEach(particle => {
      // Update trail
      if (this.frameCount % 2 === 0) {
        particle.trail.shift();
        particle.trail.push({x: particle.x, y: particle.y});
      }
      
      // Move the particle
      particle.x += particle.speedX;
      particle.y += particle.speedY;
      
      // Update rotation
      particle.rotation += particle.rotationalVelocity;
      
      // Apply friction to rotation
      if (particle.shape === 'chess') {
        particle.rotationalVelocity *= 0.98;
        if (Math.abs(particle.rotationalVelocity) < 0.001) {
          particle.rotationalVelocity = 0;
        }
      } else {
        particle.rotationalVelocity = 0.01 + (particle.originalId % 5) * 0.001;
      }
      
      // Mouse interaction
      if (this.isMouseMoving || this.isMouseDown) {
        const dx = this.mouseX - particle.x;
        const dy = this.mouseY - particle.y;
        const distance = Math.sqrt(dx * dx + dy * dy);
        
        // Repel particles within range
        if (distance < 100) {
          const angle = Math.atan2(dy, dx);
          let force = (100 - distance) / 500;
          
          if (this.isMouseDown) force *= 1.5;
          
          particle.speedX -= Math.cos(angle) * force;
          particle.speedY -= Math.sin(angle) * force;
          
          // Add rotation for chess pieces
          if (particle.shape === 'chess') {
            const tangentialForce = Math.sin(angle + particle.rotation) * force;
            particle.rotationalVelocity += tangentialForce * 0.1;
          }
        }
      }
      
      // Apply friction
      particle.speedX *= this.FRICTION;
      particle.speedY *= this.FRICTION;
      
      // Random boost for slow particles
      const currentSpeed = Math.sqrt(particle.speedX * particle.speedX + particle.speedY * particle.speedY);
      if (currentSpeed < this.MIN_SPEED) {
        if (Math.random() < 0.05) {
          const angle = Math.random() * Math.PI * 2;
          const newSpeed = this.MIN_SPEED + Math.random() * this.DEFAULT_SPEED;
          
          particle.speedX = Math.cos(angle) * newSpeed * this.particleParams.speedFactor;
          particle.speedY = Math.sin(angle) * newSpeed * this.particleParams.speedFactor;
        }
      }
      
      // Wrap around screen bounds
      if (particle.x < 0) particle.x = this.canvas.width;
      if (particle.x > this.canvas.width) particle.x = 0;
      if (particle.y < 0) particle.y = this.canvas.height;
      if (particle.y > this.canvas.height) particle.y = 0;
    });
  }
  
  draw() {
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    
    // Draw shockwaves
    this.shockwaves.forEach(shockwave => {
      this.ctx.beginPath();
      this.ctx.arc(shockwave.x, shockwave.y, shockwave.radius, 0, Math.PI * 2);
      this.ctx.strokeStyle = `rgba(255, 255, 255, ${shockwave.intensity * 0.3})`;
      this.ctx.lineWidth = 2;
      this.ctx.stroke();
    });
    
    // Draw all particles
    this.particles.forEach(particle => {
      // Skip tiny particles
      if (particle.size < 0.1) return;
      
      // Draw trail
      this.ctx.save();
      const speed = Math.sqrt(particle.speedX * particle.speedX + particle.speedY * particle.speedY);
      if (speed > this.MIN_SPEED * 2) {
        for (let i = 0; i < particle.trail.length - 1; i++) {
          const pos = particle.trail[i];
          const nextPos = particle.trail[i + 1];
          
          // Skip large jumps
          const dx = Math.abs(pos.x - nextPos.x);
          const dy = Math.abs(pos.y - nextPos.y);
          if (dx > 100 || dy > 100) continue;
          
          const alpha = (i / particle.trail.length) * particle.trailOpacity;
          
          this.ctx.beginPath();
          this.ctx.moveTo(pos.x, pos.y);
          this.ctx.lineTo(nextPos.x, nextPos.y);
          this.ctx.strokeStyle = this.hexToRgba(particle.color, alpha);
          this.ctx.lineWidth = particle.size * 0.8 * (i / particle.trail.length);
          this.ctx.stroke();
        }
      }
      this.ctx.restore();
      
      // Draw particles based on shape
      this.ctx.save();
      
      if (particle.shape === 'circle') {
        this.ctx.beginPath();
        this.ctx.arc(particle.x, particle.y, particle.size, 0, Math.PI * 2);
        this.ctx.fillStyle = particle.color;
        this.ctx.fill();
      } 
      else if (particle.shape === 'square') {
        this.ctx.save();
        this.ctx.translate(particle.x, particle.y);
        this.ctx.rotate(particle.rotation);
        this.ctx.fillStyle = particle.color;
        this.ctx.fillRect(-particle.size, -particle.size, particle.size * 2, particle.size * 2);
        this.ctx.restore();
      }
      else if (particle.shape === 'chess') {
        // Draw chess pieces
        this.ctx.save();
        this.ctx.translate(particle.x, particle.y);
        this.ctx.rotate(particle.rotation);
        this.ctx.scale(particle.size / 20, particle.size / 20);
        
        const pieceKey = particle.chessPiece;
        if (pieceKey && this.chessPiecePaths[pieceKey]) {
          const path = new Path2D(this.chessPiecePaths[pieceKey]);
          this.ctx.fillStyle = particle.pieceColor === 'l' ? '#FFFFFF' : '#000000';
          this.ctx.fill(path);
          
          this.ctx.strokeStyle = particle.pieceColor === 'l' ? '#000000' : '#FFFFFF';
          this.ctx.lineWidth = 0.5;
          this.ctx.stroke(path);
        } else {
          this.ctx.beginPath();
          this.ctx.arc(0, 0, 10, 0, Math.PI * 2);
          this.ctx.fillStyle = particle.color;
          this.ctx.fill();
        }
        this.ctx.restore();
      }
      
      this.ctx.restore();
    });
  }
  
  animate() {
    this.updateParticles();
    this.draw();
    requestAnimationFrame(() => this.animate());
  }
}
EOF

# Create main.js file
cat > dist/scripts/main.js << 'EOF'
import ParticleBackground from './particles.js';

document.addEventListener('DOMContentLoaded', () => {
  // Initialize the global particle background
  const particlesCanvas = document.getElementById('particles-canvas');
  if (particlesCanvas) {
    new ParticleBackground('particles-canvas');
  }

  // If GSAP is loaded, register plugins
  if (typeof gsap !== 'undefined' && typeof ScrollTrigger !== 'undefined') {
    gsap.registerPlugin(ScrollTrigger);
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
      
      if (typeof gsap !== 'undefined') {
        const spans = menuToggle.querySelectorAll('span');
        if (nav.classList.contains('active')) {
          gsap.to(spans[0], { rotation: 45, y: 8, duration: 0.3 });
          gsap.to(spans[1], { opacity: 0, duration: 0.3 });
          gsap.to(spans[2], { rotation: -45, y: -8, duration: 0.3 });
        } else {
          gsap.to(spans[0], { rotation: 0, y: 0, duration: 0.3 });
          gsap.to(spans[1], { opacity: 1, duration: 0.3 });
          gsap.to(spans[2], { rotation: 0, y: 0, duration: 0.3 });
        }
      }
    });
  }
});
EOF

# Copy HTML files
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