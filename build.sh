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

# Create a JavaScript version of particles.js first with full functionality
echo "Creating JavaScript modules with full functionality..."

# Create particles.js
cat > dist/scripts/particles.js << 'EOF'
// Full-featured particle system - restored from original TypeScript file
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
        particleCount: 60,
        particleSize: 8,
        speedFactor: 0.4
      },
      hack4impact: {
        primaryColor: '#9b59b6',
        secondaryColor: '#2ecc71',
        backgroundColor: '#f5eef8',
        particleShape: 'circle',
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
      }
    };
    
    this.init();
  }

  init() {
    this.setupCanvas();
    this.setupEventListeners();
    this.initSections();
    this.animate();
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
    
    // Click event for shockwave effect
    window.addEventListener('click', (e) => {
      this.createShockwave(e.clientX, e.clientY, 0.7);
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
      
      // Create shockwave on touch end
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
        trail
      });
    }
    
    return particles;
  }
  
  createShockwave(x, y, intensity = 1.0) {
    this.shockwaves.push({
      x,
      y,
      radius: 0,
      intensity
    });
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
      
      // Apply shockwave force to all particles
      this.sections.forEach(section => {
        section.particles.forEach(particle => {
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
            
            // Add rotational velocity based on force
            const torque = (Math.random() - 0.5) * force * 0.2;
            particle.rotationalVelocity += torque;
          }
        });
      });
      
      // Remove shockwave when it's no longer visible
      if (shockwave.intensity < 0.05 || shockwave.radius > Math.max(this.canvas.width, this.canvas.height)) {
        this.shockwaves.splice(i, 1);
      }
    }
    
    // Update particle positions in each section
    this.sections.forEach(section => {
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
        
        // Apply rotational friction/damping
        particle.rotationalVelocity *= 0.98;
        
        // Interact with mouse if it's moving or pressed down
        if (this.isMouseMoving || this.isMouseDown) {
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
            
            // Add rotational effect based on off-center collision
            const tangentialForce = Math.sin(angle + particle.rotation) * force;
            particle.rotationalVelocity += tangentialForce * 0.1;
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
    
    // Draw particles from all sections
    this.sections.forEach(section => {
      section.particles.forEach(particle => {
        this.ctx.save();
        
        // Draw the particle based on its shape
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
        
        this.ctx.restore();
      });
    });
  }
  
  animate() {
    this.updateParticles();
    this.draw();
    requestAnimationFrame(() => this.animate());
  }
}
EOF

# Create main.js with the original functionality restored
cat > dist/scripts/main.js << 'EOF'
import ParticleBackground from './particles.js';

document.addEventListener('DOMContentLoaded', () => {
  // Initialize particle background
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