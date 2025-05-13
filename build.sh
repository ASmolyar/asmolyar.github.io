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

# Create particles.js with section visibility modification
echo "Creating JavaScript modules with section-specific particles..."

cat > dist/scripts/particles.js << 'EOF'
// Complete restoration of original particle system with section-specific particles

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
    this.sections = [];
    this.resizeTimeout = null;
    this.frameCount = 0;
    this.shockwaves = [];
    this.currentSection = 'about'; // Track the current visible section
    
    // SVG paths for chess pieces
    this.chessPiecePaths = {
      // White pawn (Chess_plt45.svg)
      'pl': 'm 22.5,9 c -2.21,0 -4,1.79 -4,4 0,0.89 0.29,1.71 0.78,2.38 C 17.33,16.5 16,18.59 16,21 c 0,2.03 0.94,3.84 2.41,5.03 C 15.41,27.09 11,31.58 11,39.5 H 34 C 34,31.58 29.59,27.09 26.59,26.03 28.06,24.84 29,23.03 29,21 29,18.59 27.67,16.5 25.72,15.38 26.21,14.71 26.5,13.89 26.5,13 c 0,-2.21 -1.79,-4 -4,-4 z',
      
      // Black pawn (Chess_pdt45.svg)
      'pd': 'm 22.5,9 c -2.21,0 -4,1.79 -4,4 0,0.89 0.29,1.71 0.78,2.38 C 17.33,16.5 16,18.59 16,21 c 0,2.03 0.94,3.84 2.41,5.03 C 15.41,27.09 11,31.58 11,39.5 H 34 C 34,31.58 29.59,27.09 26.59,26.03 28.06,24.84 29,23.03 29,21 29,18.59 27.67,16.5 25.72,15.38 26.21,14.71 26.5,13.89 26.5,13 c 0,-2.21 -1.79,-4 -4,-4 z',
      
      // White knight (Chess_nlt45.svg)
      'nl': 'M 22,10 C 32.5,11 38.5,18 38,39 L 15,39 C 15,30 25,32.5 23,18 M 24,18 C 24.38,20.91 18.45,25.37 16,27 C 13,29 13.18,31.34 11,31 C 9.958,30.06 12.41,27.96 11,28 C 10,28 11.19,29.23 10,30 C 9,30 5.997,31 6,26 C 6,24 12,14 12,14 C 12,14 13.89,12.1 14,10.5 C 13.27,9.506 13.5,8.5 13.5,7.5 C 14.5,6.5 16.5,10 16.5,10 L 18.5,10 C 18.5,10 19.28,8.008 21,7 C 22,7 22,10 22,10',
      
      // Black knight (Chess_ndt45.svg)
      'nd': 'M 22,10 C 32.5,11 38.5,18 38,39 L 15,39 C 15,30 25,32.5 23,18 M 24,18 C 24.38,20.91 18.45,25.37 16,27 C 13,29 13.18,31.34 11,31 C 9.958,30.06 12.41,27.96 11,28 C 10,28 11.19,29.23 10,30 C 9,30 5.997,31 6,26 C 6,24 12,14 12,14 C 12,14 13.89,12.1 14,10.5 C 13.27,9.506 13.5,8.5 13.5,7.5 C 14.5,6.5 16.5,10 16.5,10 L 18.5,10 C 18.5,10 19.28,8.008 21,7 C 22,7 22,10 22,10',
      
      // White bishop (Chess_blt45.svg)
      'bl': 'M 9,36 C 12.39,35.03 19.11,36.43 22.5,34 C 25.89,36.43 32.61,35.03 36,36 C 36,36 37.65,36.54 39,38 C 38.32,38.97 37.35,38.99 36,38.5 C 32.61,37.53 25.89,38.96 22.5,37.5 C 19.11,38.96 12.39,37.53 9,38.5 C 7.65,38.99 6.68,38.97 6,38 C 7.35,36.54 9,36 9,36 z M 15,32 C 17.5,34.5 27.5,34.5 30,32 C 30.5,30.5 30,30 30,30 C 30,27.5 27.5,26 27.5,26 C 33,24.5 33.5,14.5 22.5,10.5 C 11.5,14.5 12,24.5 17.5,26 C 17.5,26 15,27.5 15,30 C 15,30 14.5,30.5 15,32 z',
      
      // Black bishop (Chess_bdt45.svg)
      'bd': 'M 9,36 C 12.39,35.03 19.11,36.43 22.5,34 C 25.89,36.43 32.61,35.03 36,36 C 36,36 37.65,36.54 39,38 C 38.32,38.97 37.35,38.99 36,38.5 C 32.61,37.53 25.89,38.96 22.5,37.5 C 19.11,38.96 12.39,37.53 9,38.5 C 7.65,38.99 6.68,38.97 6,38 C 7.35,36.54 9,36 9,36 z M 15,32 C 17.5,34.5 27.5,34.5 30,32 C 30.5,30.5 30,30 30,30 C 30,27.5 27.5,26 27.5,26 C 33,24.5 33.5,14.5 22.5,10.5 C 11.5,14.5 12,24.5 17.5,26 C 17.5,26 15,27.5 15,30 C 15,30 14.5,30.5 15,32 z',
      
      // White rook (Chess_rlt45.svg)
      'rl': 'M 9,39 L 36,39 L 36,36 L 9,36 L 9,39 z M 12,36 L 12,32 L 33,32 L 33,36 L 12,36 z M 11,14 L 11,9 L 15,9 L 15,11 L 20,11 L 20,9 L 25,9 L 25,11 L 30,11 L 30,9 L 34,9 L 34,14 M 34,14 L 31,17 L 14,17 L 11,14 M 31,17 L 31,29.5 L 14,29.5 L 14,17 M 31,29.5 L 32.5,32 L 12.5,32 L 14,29.5',
      
      // Black rook (Chess_rdt45.svg)
      'rd': 'M 9,39 L 36,39 L 36,36 L 9,36 L 9,39 z M 12.5,32 L 14,29.5 L 31,29.5 L 32.5,32 L 12.5,32 z M 12,36 L 12,32 L 33,32 L 33,36 L 12,36 z M 14,29.5 L 14,16.5 L 31,16.5 L 31,29.5 L 14,29.5 z M 14,16.5 L 11,14 L 34,14 L 31,16.5 L 14,16.5 z M 11,14 L 11,9 L 15,9 L 15,11 L 20,11 L 20,9 L 25,9 L 25,11 L 30,11 L 30,9 L 34,9 L 34,14 L 11,14 z',
      
      // White queen (Chess_qlt45.svg)
      'ql': 'M 9,26 C 17.5,24.5 30,24.5 36,26 L 38.5,13.5 L 31,25 L 30.7,10.9 L 25.5,24.5 L 22.5,10 L 19.5,24.5 L 14.3,10.9 L 14,25 L 6.5,13.5 L 9,26 z M 9,26 C 9,28 10.5,28 11.5,30 C 12.5,31.5 12.5,31 12,33.5 C 10.5,34.5 11,36 11,36 C 9.5,37.5 11,38.5 11,38.5 C 17.5,39.5 27.5,39.5 34,38.5 C 34,38.5 35.5,37.5 34,36 C 34,36 34.5,34.5 33,33.5 C 32.5,31 32.5,31.5 33.5,30 C 34.5,28 36,28 36,26 C 27.5,24.5 17.5,24.5 9,26 z',
      
      // Black queen (Chess_qdt45.svg)
      'qd': 'M 9,26 C 17.5,24.5 30,24.5 36,26 L 38.5,13.5 L 31,25 L 30.7,10.9 L 25.5,24.5 L 22.5,10 L 19.5,24.5 L 14.3,10.9 L 14,25 L 6.5,13.5 L 9,26 z M 9,26 C 9,28 10.5,28 11.5,30 C 12.5,31.5 12.5,31 12,33.5 C 10.5,34.5 11,36 11,36 C 9.5,37.5 11,38.5 11,38.5 C 17.5,39.5 27.5,39.5 34,38.5 C 34,38.5 35.5,37.5 34,36 C 34,36 34.5,34.5 33,33.5 C 32.5,31 32.5,31.5 33.5,30 C 34.5,28 36,28 36,26 C 27.5,24.5 17.5,24.5 9,26 z',
      
      // White king (Chess_klt45.svg)
      'kl': 'M22.5 11.63V6M20 8h5M22.5 25s4.5-7.5 3-10.5c0 0-1-2.5-3-2.5s-3 2.5-3 2.5c-1.5 3 3 10.5 3 10.5M12.5 37c5.5 3.5 14.5 3.5 20 0v-7s9-4.5 6-10.5c-4-6.5-13.5-3.5-16 4V27v-3.5c-2.5-7.5-12-10.5-16-4-3 6 6 10.5 6 10.5v7',
      
      // Black king (Chess_kdt45.svg)
      'kd': 'M 22.5,11.63 L 22.5,6 M 22.5,25 C 22.5,25 27,17.5 25.5,14.5 C 25.5,14.5 24.5,12 22.5,12 C 20.5,12 19.5,14.5 19.5,14.5 C 18,17.5 22.5,25 22.5,25 M 12.5,37 C 18,40.5 27,40.5 32.5,37 L 32.5,30 C 32.5,30 41.5,25.5 38.5,19.5 C 34.5,13 25,16 22.5,23.5 L 22.5,27 L 22.5,23.5 C 20,16 10.5,13 6.5,19.5 C 3.5,25.5 12.5,30 12.5,30 L 12.5,37 M 20,8 L 25,8'
    };
    
    // Define themes for each section
    this.themes = {
      default: {
        primaryColor: '#3498db',
        secondaryColor: '#2980b9',
        backgroundColor: '#ffffff',
        particleShape: 'circle',
        particleCount: 100,
        particleSize: 5,
        speedFactor: 1
      },
      cleo: {
        primaryColor: '#3498db',
        secondaryColor: '#ffffff',
        backgroundColor: '#e8f4fc',
        particleShape: 'circle',
        particleCount: 100,
        particleSize: 5,
        speedFactor: 0.8
      },
      brainrot: {
        primaryColor: '#f1c40f',
        secondaryColor: '#e67e22',
        backgroundColor: '#fffceb',
        particleShape: 'square',
        particleCount: 80,
        particleSize: 6,
        speedFactor: 0.9
      },
      chess: {
        primaryColor: '#2c3e50',
        secondaryColor: '#ecf0f1',
        backgroundColor: '#d5d8dc',
        particleShape: 'chess',
        particleCount: 120,
        particleSize: 15,
        speedFactor: 0.4
      },
      camprsm: {
        primaryColor: '#27ae60',
        secondaryColor: '#ffffff',
        backgroundColor: '#eafaf1',
        particleShape: 'leaf',
        particleCount: 70,
        particleSize: 7,
        speedFactor: 0.7
      },
      tomadoro: {
        primaryColor: '#e74c3c',
        secondaryColor: '#ffffff',
        backgroundColor: '#fdedec',
        particleShape: 'clock',
        particleCount: 60,
        particleSize: 6,
        speedFactor: 0.75
      },
      hack4impact: {
        primaryColor: '#9b59b6',
        secondaryColor: '#2ecc71',
        backgroundColor: '#f5eef8',
        particleShape: 'code',
        particleCount: 90,
        particleSize: 5,
        speedFactor: 0.85
      },
      about: {
        primaryColor: '#3498db',
        secondaryColor: '#2980b9',
        backgroundColor: '#ffffff',
        particleShape: 'circle',
        particleCount: 100,
        particleSize: 5,
        speedFactor: 1
      },
      music: {
        primaryColor: '#3498db',
        secondaryColor: '#2980b9',
        backgroundColor: '#f8f9fa',
        particleShape: 'circle',
        particleCount: 100, 
        particleSize: 5,
        speedFactor: 1
      },
      contact: {
        primaryColor: '#3498db',
        secondaryColor: '#2980b9',
        backgroundColor: '#f8f9fa',
        particleShape: 'circle',
        particleCount: 100,
        particleSize: 5,
        speedFactor: 1
      }
    };
    
    this.init();
  }

  init() {
    this.setupCanvas();
    this.setupEventListeners();
    this.initSections();
    this.setupSectionObserver();
    this.animate();
  }
  
  setupSectionObserver() {
    // Create an intersection observer to track visible sections
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.currentSection = entry.target.id;
        }
      });
    }, {
      root: null,
      rootMargin: "0px",
      threshold: 0.5  // Consider section visible when 50% is in viewport
    });
    
    // Observe all sections with IDs
    document.querySelectorAll('section[id]').forEach(section => {
      observer.observe(section);
    });
  }
  
  setupCanvas() {
    this.canvas.width = window.innerWidth;
    this.canvas.height = window.innerHeight;
  }
  
  setupEventListeners() {
    // Resize event
    window.addEventListener('resize', () => {
      if (this.resizeTimeout) {
        clearTimeout(this.resizeTimeout);
      }
      this.resizeTimeout = window.setTimeout(() => {
        this.canvas.width = window.innerWidth;
        this.canvas.height = window.innerHeight;
      }, 150);
    });
    
    // Mouse move event with improved interaction
    window.addEventListener('mousemove', (e) => {
      this.mouseX = e.clientX;
      this.mouseY = e.clientY;
      this.isMouseMoving = true;
      
      // Reset after a bit of inactivity
      setTimeout(() => {
        this.isMouseMoving = false;
      }, 3000);
    });
    
    // Mouse down event for continuous pushing
    window.addEventListener('mousedown', () => {
      this.isMouseDown = true;
    });
    
    // Mouse up event
    window.addEventListener('mouseup', () => {
      this.isMouseDown = false;
    });
    
    // Click event for shockwave effect (weaker now)
    window.addEventListener('click', (e) => {
      this.createShockwave(e.clientX, e.clientY, 0.7); // Reduced intensity
    });
    
    // Add touch support for mobile devices
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
      
      // Create shockwave on touch end (weaker)
      if (e.changedTouches.length > 0) {
        const touch = e.changedTouches[0];
        this.createShockwave(touch.clientX, touch.clientY, 0.7);
      }
      
      setTimeout(() => {
        this.isMouseMoving = false;
      }, 3000);
    });
  }
  
  initSections() {
    this.sections = [];
    
    // Find all sections with IDs
    const sectionElements = document.querySelectorAll('section[id]');
    
    // Create sections array with particle arrays for each
    sectionElements.forEach((element, index) => {
      const id = element.id;
      const theme = this.themes[id] || this.themes.default;
      
      // Create particles for this section
      const particles = this.createParticlesForTheme(theme, index);
      
      this.sections.push({
        id,
        element: element,
        theme,
        particles
      });
    });
  }
  
  createParticlesForTheme(theme, seedOffset) {
    const particles = [];
    
    for (let i = 0; i < theme.particleCount; i++) {
      const size = Math.random() * theme.particleSize + 1;
      const x = Math.random() * this.canvas.width;
      const y = Math.random() * this.canvas.height;
      
      // Set default speed with some randomness
      const speedX = ((Math.random() - 0.5) * this.DEFAULT_SPEED) * theme.speedFactor;
      const speedY = ((Math.random() - 0.5) * this.DEFAULT_SPEED) * theme.speedFactor;
      
      const color = Math.random() > 0.5 ? theme.primaryColor : theme.secondaryColor;
      const rotation = (Math.random() + seedOffset) * Math.PI * 2;
      
      // Initial rotational velocity
      const rotationalVelocity = theme.particleShape === 'chess' ? 0 : (Math.random() - 0.5) * 0.02;
      
      // Initialize with empty trail
      const trail = [];
      for (let j = 0; j < this.TRAIL_LENGTH; j++) {
        trail.push({x, y});
      }
      
      // Determine chess piece color if needed
      const pieceColor = Math.random() > 0.5 ? 'd' : 'l';
      
      // Determine chess piece type if needed
      let chessPiece = '';
      if (theme.particleShape === 'chess') {
        const pieces = ['p', 'n', 'b', 'r', 'q', 'k'];
        const pieceIndex = Math.floor(Math.random() * pieces.length);
        chessPiece = pieces[pieceIndex] + pieceColor;
      }
      
      particles.push({
        x,
        y,
        size,
        speedX,
        speedY,
        color,
        shape: theme.particleShape,
        rotation,
        rotationalVelocity,
        originalId: i + (seedOffset * 1000), // Ensure uniqueness
        trail,
        pieceColor,
        chessPiece,
        trailOpacity: 0.2 + Math.random() * 0.3
      });
    }
    
    return particles;
  }
  
  // Create a shockwave effect at the given position with adjustable intensity
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
      
      // Expand shockwave radius and decrease intensity
      shockwave.radius += 10;
      shockwave.intensity *= 0.95;
      
      // Apply shockwave force only to current section's particles
      const currentSectionObj = this.sections.find(section => section.id === this.currentSection);
      if (currentSectionObj) {
        currentSectionObj.particles.forEach(particle => {
          const dx = particle.x - shockwave.x;
          const dy = particle.y - shockwave.y;
          const distance = Math.sqrt(dx * dx + dy * dy);
          
          // Only affect particles near the shockwave front
          const shockwaveWidth = 50; // Width of the shockwave effect
          if (Math.abs(distance - shockwave.radius) < shockwaveWidth) {
            const angle = Math.atan2(dy, dx);
            const force = shockwave.intensity * (1 - Math.abs(distance - shockwave.radius) / shockwaveWidth);
            
            // Push particles away from the shockwave center
            particle.speedX += Math.cos(angle) * force * 1.5;
            particle.speedY += Math.sin(angle) * force * 1.5;
            
            // Add rotational velocity based on force and particle shape
            if (particle.shape === 'chess') {
              // Calculate torque based on off-center collision
              const torque = (Math.random() - 0.5) * force * 0.2;
              particle.rotationalVelocity += torque;
            } else {
              particle.rotationalVelocity += (Math.random() - 0.5) * force * 0.1;
            }
          }
        });
      }
      
      // Remove shockwave when it's no longer visible
      if (shockwave.intensity < 0.05 || shockwave.radius > Math.max(this.canvas.width, this.canvas.height)) {
        this.shockwaves.splice(i, 1);
      }
    }
    
    // Update all particles' positions but only apply mouse interaction to visible section
    this.sections.forEach(section => {
      const isVisible = section.id === this.currentSection;
      
      section.particles.forEach(particle => {
        // Update trail before moving the particle
        if (this.frameCount % 2 === 0) { // Only update every other frame for performance
          // Remove oldest trail position and add current position
          particle.trail.shift();
          particle.trail.push({x: particle.x, y: particle.y});
        }
        
        // Normal movement
        particle.x += particle.speedX;
        particle.y += particle.speedY;
        
        // Update rotation with inertia system
        particle.rotation += particle.rotationalVelocity;
        
        // Apply rotational friction/damping (only meaningful for chess pieces)
        if (particle.shape === 'chess') {
          // Gradually slow down rotation
          particle.rotationalVelocity *= 0.98;
          
          // Stop very small rotations to prevent endless tiny spinning
          if (Math.abs(particle.rotationalVelocity) < 0.001) {
            particle.rotationalVelocity = 0;
          }
        } else {
          // For non-chess shapes, just slowly rotate with varying speeds based on id
          particle.rotationalVelocity = 0.01 + (particle.originalId % 5) * 0.001;
        }
        
        // Only apply mouse interaction to particles in the visible section
        if (isVisible && (this.isMouseMoving || this.isMouseDown)) {
          const dx = this.mouseX - particle.x;
          const dy = this.mouseY - particle.y;
          const distance = Math.sqrt(dx * dx + dy * dy);
          
          // Repel particles within 100px of the mouse
          if (distance < 100) {
            const angle = Math.atan2(dy, dx);
            let force = (100 - distance) / 500;
            
            // Stronger continuous push when mouse is held down
            if (this.isMouseDown) {
              force *= 1.5;
            }
            
            particle.speedX -= Math.cos(angle) * force;
            particle.speedY -= Math.sin(angle) * force;
            
            // Add rotational effect for chess pieces based on off-center collision
            if (particle.shape === 'chess') {
              // Calculate torque based on tangential component of force
              const tangentialForce = Math.sin(angle + particle.rotation) * force;
              particle.rotationalVelocity += tangentialForce * 0.1;
            }
          }
        }
        
        // Apply friction
        particle.speedX *= this.FRICTION;
        particle.speedY *= this.FRICTION;
        
        // If the particle gets too slow, give it a small random boost
        const currentSpeed = Math.sqrt(particle.speedX * particle.speedX + particle.speedY * particle.speedY);
        if (currentSpeed < this.MIN_SPEED) {
          if (Math.random() < 0.05) { // 5% chance to boost
            const angle = Math.random() * Math.PI * 2;
            const newSpeed = this.MIN_SPEED + Math.random() * this.DEFAULT_SPEED;
            
            particle.speedX = Math.cos(angle) * newSpeed * section.theme.speedFactor;
            particle.speedY = Math.sin(angle) * newSpeed * section.theme.speedFactor;
          }
        }
        
        // Boundary check - wrap around
        if (particle.x < 0) particle.x = this.canvas.width;
        if (particle.x > this.canvas.width) particle.x = 0;
        if (particle.y < 0) particle.y = this.canvas.height;
        if (particle.y > this.canvas.height) particle.y = 0;
      });
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
    
    // Find current visible section
    const currentSectionObj = this.sections.find(section => section.id === this.currentSection);
    if (!currentSectionObj) return;
    
    // Only draw particles for the current section
    currentSectionObj.particles.forEach(particle => {
      // Skip rendering particles that are too small
      if (particle.size < 0.1) return;
      
      // Draw trail first (behind the particle)
      this.ctx.save();
      
      // Only draw trail if particle is moving fast enough
      const speed = Math.sqrt(particle.speedX * particle.speedX + particle.speedY * particle.speedY);
      if (speed > this.MIN_SPEED * 2) {
        for (let i = 0; i < particle.trail.length - 1; i++) {
          const pos = particle.trail[i];
          const nextPos = particle.trail[i + 1];
          
          // Skip if positions are too far apart (likely due to wrapping)
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
      
      // Draw the particle based on its shape
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
      else if (particle.shape === 'triangle') {
        this.ctx.save();
        this.ctx.translate(particle.x, particle.y);
        this.ctx.rotate(particle.rotation);
        this.ctx.beginPath();
        this.ctx.moveTo(0, -particle.size);
        this.ctx.lineTo(particle.size, particle.size);
        this.ctx.lineTo(-particle.size, particle.size);
        this.ctx.closePath();
        this.ctx.fillStyle = particle.color;
        this.ctx.fill();
        this.ctx.restore();
      }
      else if (particle.shape === 'chess') {
        // Draw chess pieces using the SVG path data
        this.ctx.save();
        this.ctx.translate(particle.x, particle.y);
        this.ctx.rotate(particle.rotation);
        this.ctx.scale(particle.size / 20, particle.size / 20); // Scale based on particle size
        
        const pieceKey = particle.chessPiece;
        if (pieceKey && this.chessPiecePaths[pieceKey]) {
          const path = new Path2D(this.chessPiecePaths[pieceKey]);
          this.ctx.fillStyle = particle.pieceColor === 'l' ? '#FFFFFF' : '#000000';
          this.ctx.fill(path);
          
          // Add stroke for visibility
          this.ctx.strokeStyle = particle.pieceColor === 'l' ? '#000000' : '#FFFFFF';
          this.ctx.lineWidth = 0.5;
          this.ctx.stroke(path);
        } else {
          // Fallback if piece not found
          this.ctx.beginPath();
          this.ctx.arc(0, 0, 10, 0, Math.PI * 2);
          this.ctx.fillStyle = particle.color;
          this.ctx.fill();
        }
        this.ctx.restore();
      }
      else if (particle.shape === 'leaf') {
        // Draw leaf shape
        this.ctx.save();
        this.ctx.translate(particle.x, particle.y);
        this.ctx.rotate(particle.rotation);
        this.ctx.scale(particle.size / 10, particle.size / 10);
        
        this.ctx.beginPath();
        // Draw a leaf shape
        this.ctx.moveTo(0, -10);
        this.ctx.bezierCurveTo(5, -5, 10, 0, 0, 10);
        this.ctx.bezierCurveTo(-10, 0, -5, -5, 0, -10);
        
        // Draw the stem
        this.ctx.moveTo(0, 10);
        this.ctx.lineTo(0, 15);
        
        this.ctx.fillStyle = particle.color;
        this.ctx.fill();
        this.ctx.strokeStyle = this.hexToRgba(particle.color, 0.8);
        this.ctx.lineWidth = 1;
        this.ctx.stroke();
        this.ctx.restore();
      }
      else if (particle.shape === 'clock') {
        // Draw clock shape
        this.ctx.save();
        this.ctx.translate(particle.x, particle.y);
        
        // Draw clock face
        this.ctx.beginPath();
        this.ctx.arc(0, 0, particle.size, 0, Math.PI * 2);
        this.ctx.fillStyle = particle.color;
        this.ctx.fill();
        this.ctx.strokeStyle = '#FFFFFF';
        this.ctx.lineWidth = particle.size * 0.1;
        this.ctx.stroke();
        
        // Draw hour hand
        this.ctx.save();
        this.ctx.rotate(particle.rotation * 0.1); // Slower rotation
        this.ctx.beginPath();
        this.ctx.moveTo(0, 0);
        this.ctx.lineTo(0, -particle.size * 0.5);
        this.ctx.strokeStyle = '#FFFFFF';
        this.ctx.lineWidth = particle.size * 0.15;
        this.ctx.stroke();
        this.ctx.restore();
        
        // Draw minute hand
        this.ctx.save();
        this.ctx.rotate(particle.rotation); // Normal rotation
        this.ctx.beginPath();
        this.ctx.moveTo(0, 0);
        this.ctx.lineTo(0, -particle.size * 0.7);
        this.ctx.strokeStyle = '#FFFFFF';
        this.ctx.lineWidth = particle.size * 0.1;
        this.ctx.stroke();
        this.ctx.restore();
        
        this.ctx.restore();
      }
      else if (particle.shape === 'code') {
        // Draw code-like symbols
        this.ctx.save();
        this.ctx.translate(particle.x, particle.y);
        this.ctx.rotate(particle.rotation);
        
        // Choose a code symbol based on the particle's ID
        const symbols = ['{ }', '< >', '( )', '[ ]', '//', '/*', '*/'];
        const symbolIndex = particle.originalId % symbols.length;
        const symbol = symbols[symbolIndex];
        
        this.ctx.font = `${particle.size * 1.5}px monospace`;
        this.ctx.fillStyle = particle.color;
        this.ctx.textAlign = 'center';
        this.ctx.textBaseline = 'middle';
        this.ctx.fillText(symbol, 0, 0);
        
        this.ctx.restore();
      }
      else {
        // Default fallback shape
        this.ctx.beginPath();
        this.ctx.arc(particle.x, particle.y, particle.size, 0, Math.PI * 2);
        this.ctx.fillStyle = particle.color;
        this.ctx.fill();
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

# Create main.js file with updated ParticleBackground initialization
cat > dist/scripts/main.js << 'EOF'
import ParticleBackground from './particles.js';

document.addEventListener('DOMContentLoaded', () => {
  // Initialize particle background with section-specific functionality
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

  // Set up project navigation highlighting
  const sections = document.querySelectorAll('section[id]');
  const navLinks = document.querySelectorAll('.project-nav__link');
  
  // Set up intersection observer for sections
  const observerOptions = {
    root: null, // viewport
    rootMargin: '-50% 0px', // trigger when middle of the viewport
    threshold: 0 // trigger as soon as even 1px is visible
  };
  
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      // When a section enters the viewport
      if (entry.isIntersecting) {
        const id = entry.target.id;
        
        // Remove active class from all links
        navLinks.forEach(link => {
          link.classList.remove('active');
        });
        
        // Don't highlight anything if we're in the about section
        if (id === 'about') {
          return;
        }
        
        // Add active class to corresponding link
        const activeLink = document.querySelector(`.project-nav__link[data-section="${id}"]`);
        if (activeLink) {
          activeLink.classList.add('active');
        }
      }
    });
  }, observerOptions);
  
  // Observe all sections including the about section
  sections.forEach(section => {
    observer.observe(section);
  });
  
  // Mobile menu toggle functionality
  const menuToggle = document.querySelector('.header__menu-toggle');
  const nav = document.querySelector('.header__nav');

  if (menuToggle && nav) {
    menuToggle.addEventListener('click', () => {
      nav.classList.toggle('active');
      
      // Animate the menu icon
      const spans = menuToggle.querySelectorAll('span');
      if (nav.classList.contains('active') && typeof gsap !== 'undefined') {
        gsap.to(spans[0], { rotation: 45, y: 8, duration: 0.3 });
        gsap.to(spans[1], { opacity: 0, duration: 0.3 });
        gsap.to(spans[2], { rotation: -45, y: -8, duration: 0.3 });
      } else if (typeof gsap !== 'undefined') {
        gsap.to(spans[0], { rotation: 0, y: 0, duration: 0.3 });
        gsap.to(spans[1], { opacity: 1, duration: 0.3 });
        gsap.to(spans[2], { rotation: 0, y: 0, duration: 0.3 });
      }
    });
  }

  // Close mobile menu when clicking on a link
  const mobileNavLinks = document.querySelectorAll('.header__nav a');
  mobileNavLinks.forEach(link => {
    link.addEventListener('click', () => {
      if (window.innerWidth <= 768) {
        nav.classList.remove('active');
        
        // Reset hamburger icon
        if (menuToggle && typeof gsap !== 'undefined') {
          const spans = menuToggle.querySelectorAll('span');
          gsap.to(spans[0], { rotation: 0, y: 0, duration: 0.3 });
          gsap.to(spans[1], { opacity: 1, duration: 0.3 });
          gsap.to(spans[2], { rotation: 0, y: 0, duration: 0.3 });
        }
      }
    });
  });
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