type ParticleTheme = {
  primaryColor: string;
  secondaryColor: string;
  backgroundColor: string;
  particleShape: 'circle' | 'square' | 'triangle' | 'chess' | 'leaf' | 'clock' | 'code';
  particleCount: number;
  particleSize: number;
  speedFactor: number;
};

type Particle = {
  x: number;
  y: number;
  size: number;
  speedX: number;
  speedY: number;
  color: string;
  shape: ParticleTheme['particleShape'];
  rotation: number;
  rotationalVelocity: number;
  originalId: number;
  trail: {x: number, y: number}[];
  pieceColor?: 'l' | 'd'; // Light or dark chess piece color
};

// Simplified section info
interface SectionInfo {
  id: string;
  element: HTMLElement;
  theme: ParticleTheme;
  particles: Particle[];
}

class ParticleBackground {
  private canvas: HTMLCanvasElement;
  private ctx: CanvasRenderingContext2D;
  private mouseX: number = 0;
  private mouseY: number = 0;
  private isMouseMoving: boolean = false;
  private isMouseDown: boolean = false; // Track mouse/touch press state
  private sections: SectionInfo[] = [];
  private resizeTimeout: number | null = null;
  private themes: Record<string, ParticleTheme> = {};
  private frameCount: number = 0;
  
  // Constants for particle behavior
  private readonly DEFAULT_SPEED: number = 0.3; 
  private readonly FRICTION: number = 0.98; 
  private readonly MIN_SPEED: number = 0.1;
  private readonly TRAIL_LENGTH: number = 3; // Number of positions to keep in the trail
  
  // For shockwave effect
  private shockwaves: Array<{x: number, y: number, radius: number, intensity: number}> = [];

  // SVG paths for chess pieces hardcoded directly
  private chessPiecePaths: Record<string, string> = {
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

  constructor(canvasId: string) {
    this.canvas = document.getElementById(canvasId) as HTMLCanvasElement;
    this.ctx = this.canvas.getContext('2d') as CanvasRenderingContext2D;
    
    // Define themes for each section
    this.themes = {
      default: {
        primaryColor: "#3498db",
        secondaryColor: "#2980b9",
        backgroundColor: "#ffffff",
        particleShape: "circle",
        particleCount: 200,
        particleSize: 5,
        speedFactor: 1,
      },
      cleo: {
        primaryColor: "#3498db",
        secondaryColor: "#ffffff",
        backgroundColor: "#e8f4fc",
        particleShape: "circle",
        particleCount: 200,
        particleSize: 5,
        speedFactor: 0.8,
      },
      brainrot: {
        primaryColor: "#f1c40f",
        secondaryColor: "#e67e22",
        backgroundColor: "#fffceb",
        particleShape: "square",
        particleCount: 200,
        particleSize: 6,
        speedFactor: 0.9,
      },
      chess: {
        primaryColor: "#2c3e50",
        secondaryColor: "#ecf0f1",
        backgroundColor: "#d5d8dc",
        particleShape: "chess",
        particleCount: 120,
        particleSize: 15,
        speedFactor: 0.4,
      },
      camprsm: {
        primaryColor: "#27ae60",
        secondaryColor: "#ffffff",
        backgroundColor: "#eafaf1",
        particleShape: "leaf",
        particleCount: 150,
        particleSize: 7,
        speedFactor: 0.7,
      },
      tomadoro: {
        primaryColor: "#e74c3c",
        secondaryColor: "#ffffff",
        backgroundColor: "#fdedec",
        particleShape: "clock",
        particleCount: 150,
        particleSize: 6,
        speedFactor: 0.75,
      },
      hack4impact: {
        primaryColor: "#9b59b6",
        secondaryColor: "#2ecc71",
        backgroundColor: "#f5eef8",
        particleShape: "code",
        particleCount: 200,
        particleSize: 5,
        speedFactor: 0.85,
      },
      projects: {
        primaryColor: "#3498db",
        secondaryColor: "#2980b9",
        backgroundColor: "#f8f9fa",
        particleShape: "circle",
        particleCount: 100,
        particleSize: 5,
        speedFactor: 1,
      },
      contact: {
        primaryColor: "#3498db",
        secondaryColor: "#2980b9",
        backgroundColor: "#f8f9fa",
        particleShape: "circle",
        particleCount: 100,
        particleSize: 5,
        speedFactor: 1,
      },
    };
    
    this.init();
  }
  
  private init(): void {
    this.setupCanvas();
    this.setupEventListeners();
    this.initSections();
    this.animate();
  }
  
  private setupCanvas(): void {
    this.canvas.width = window.innerWidth;
    this.canvas.height = window.innerHeight;
  }
  
  private initSections(): void {
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
        element: element as HTMLElement,
        theme,
        particles
      });
    });
  }
  
  private createParticlesForTheme(theme: ParticleTheme, seedOffset: number): Particle[] {
    const particles: Particle[] = [];
    
    for (let i = 0; i < theme.particleCount; i++) {
      const size = Math.random() * theme.particleSize + 1;
      const x = Math.random() * this.canvas.width;
      const y = Math.random() * this.canvas.height;
      
      // Set default speed with some randomness
      const speedX = ((Math.random() - 0.5) * this.DEFAULT_SPEED) * theme.speedFactor;
      const speedY = ((Math.random() - 0.5) * this.DEFAULT_SPEED) * theme.speedFactor;
      
      const color = Math.random() > 0.5 ? theme.primaryColor : theme.secondaryColor;
      const rotation = (Math.random() + seedOffset) * Math.PI * 2;
      
      // Initial rotational velocity - start with zero for chess pieces
      const rotationalVelocity = theme.particleShape === 'chess' ? 0 : (Math.random() - 0.5) * 0.02;
      
      // Initialize with empty trail
      const trail: {x: number, y: number}[] = [];
      for (let j = 0; j < this.TRAIL_LENGTH; j++) {
        trail.push({x, y});
      }
      
      // Determine chess piece color if needed
      const pieceColor = Math.random() > 0.5 ? 'd' : 'l';
      
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
        pieceColor
      });
    }
    
    return particles;
  }
  
  private setupEventListeners(): void {
    // Resize event
    window.addEventListener('resize', () => {
      if (this.resizeTimeout) {
        clearTimeout(this.resizeTimeout);
      }
      this.resizeTimeout = window.setTimeout(() => {
        this.canvas.width = window.innerWidth;
        this.canvas.height = window.innerHeight;
      }, 150) as unknown as number;
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
        this.createShockwave(touch.clientX, touch.clientY, 0.7); // Reduced intensity
      }
      
      setTimeout(() => {
        this.isMouseMoving = false;
      }, 3000);
    });
  }
  
  // Create a shockwave effect at the given position with adjustable intensity
  private createShockwave(x: number, y: number, intensity: number = 1.0): void {
    this.shockwaves.push({
      x,
      y,
      radius: 0,
      intensity
    });
  }
  
  private updateParticles(): void {
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
            
            // Push particles away from the shockwave center (weaker effect)
            particle.speedX += Math.cos(angle) * force * 1.5; // Reduced from 2
            particle.speedY += Math.sin(angle) * force * 1.5; // Reduced from 2
            
            // Add rotational velocity for chess pieces based on force
            if (particle.shape === 'chess') {
              // Calculate torque based on off-center collision
              const torque = (Math.random() - 0.5) * force * 0.2;
              particle.rotationalVelocity += torque;
            }
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
  
  private drawParticle(particle: Particle): void {
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
        if (dx > this.canvas.width / 2 || dy > this.canvas.height / 2) continue;

        // Calculate opacity based on position in trail (reduced by half)
        const opacity = 0.1 * (i / particle.trail.length); // Reduced from 0.2 to 0.1
        const color = this.hexToRgba(particle.color, opacity);

        // Draw trail segment
        this.ctx.beginPath();
        this.ctx.moveTo(pos.x, pos.y);
        this.ctx.lineTo(nextPos.x, nextPos.y);
        this.ctx.strokeStyle = color;
        this.ctx.lineWidth = particle.size * 0.5 * (i / particle.trail.length);
        this.ctx.stroke();
      }
    }
    this.ctx.restore();

    // Draw the actual particle
    this.ctx.save();
    this.ctx.translate(particle.x, particle.y);
    this.ctx.rotate(particle.rotation);

    // Set global opacity to 0.5 for all particles (reducing opacity by half)
    this.ctx.globalAlpha = 0.8;

    // Convert solid color to semi-transparent color
    const rgb = this.hexToRgb(particle.color);
    this.ctx.fillStyle = rgb
      ? `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, 0.5)`
      : particle.color;
    
    switch (particle.shape) {
      case "square":
        this.ctx.fillRect(
          -particle.size / 2,
          -particle.size / 2,
          particle.size,
          particle.size
        );
        break;

      case "triangle":
        this.ctx.beginPath();
        this.ctx.moveTo(0, -particle.size / 2);
        this.ctx.lineTo(particle.size / 2, particle.size / 2);
        this.ctx.lineTo(-particle.size / 2, particle.size / 2);
        this.ctx.closePath();
        this.ctx.fill();
        break;

      case "chess":
        // Draw a chess piece based on the particle's ID
        const pieceType = particle.originalId % 6; // 6 different chess piece types
        const isBlack = particle.pieceColor === "d"; // Use consistent color from particle
        const pieceSize = particle.size * 2; // Make pieces a bit larger

        // Setup images for chess pieces - using standard chess notation
        const pieceLetters = ["p", "n", "b", "r", "q", "k"]; // p=pawn, n=knight, b=bishop, r=rook, q=queen, k=king
        const pieceLetter = pieceLetters[pieceType];
        const colorLetter = particle.pieceColor || "l"; // Use stored color or default to light

        // Get SVG path for this piece
        const pieceKey = `${pieceLetter}${colorLetter}`;
        const pathData = this.chessPiecePaths[pieceKey];

        // Save context state
        const origFillStyle = this.ctx.fillStyle;
        const origStrokeStyle = this.ctx.strokeStyle;

        // Setup for drawing SVG path
        this.ctx.fillStyle = isBlack
          ? "rgba(0,0,0,0.5)"
          : "rgba(255,255,255,0.5)"; // Reduced opacity
        this.ctx.strokeStyle = "rgba(0,0,0,0.5)"; // Reduced opacity
        this.ctx.lineWidth = 1;

        // Scale to fit the particle size
        const scale = pieceSize / 40; // SVGs are 45x45, but we want a small margin
        this.ctx.scale(scale, scale);

        // Create path from SVG data
        const path = new Path2D(pathData);

        // Fill and stroke the path
        this.ctx.fill(path);
        if (!isBlack) {
          this.ctx.stroke(path);
        }

        // Restore context state
        this.ctx.scale(1 / scale, 1 / scale);
        this.ctx.fillStyle = origFillStyle;
        this.ctx.strokeStyle = origStrokeStyle;
        break;

      case "leaf":
        // Simple leaf shape
        this.ctx.beginPath();
        this.ctx.ellipse(
          0,
          0,
          particle.size / 2,
          particle.size,
          0,
          0,
          Math.PI * 2
        );
        this.ctx.fill();
        this.ctx.beginPath();
        this.ctx.moveTo(0, -particle.size);
        this.ctx.lineTo(0, particle.size);
        this.ctx.strokeStyle = rgb
          ? `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, 0.5)`
          : particle.color; // Reduced opacity
        this.ctx.lineWidth = 1;
        this.ctx.stroke();
        break;

      case "clock":
        // Clock face
        this.ctx.beginPath();
        this.ctx.arc(0, 0, particle.size, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.strokeStyle = "rgba(255,255,255,0.5)"; // Reduced opacity
        this.ctx.lineWidth = 1;

        // Hour hand
        this.ctx.beginPath();
        this.ctx.moveTo(0, 0);
        this.ctx.lineTo(0, -particle.size / 2);
        this.ctx.stroke();

        // Minute hand
        this.ctx.beginPath();
        this.ctx.moveTo(0, 0);
        this.ctx.lineTo(particle.size / 1.5, 0);
        this.ctx.stroke();
        break;

      case "code":
        // Code brackets
        this.ctx.beginPath();
        this.ctx.moveTo(-particle.size / 2, 0);
        this.ctx.lineTo(0, -particle.size / 2);
        this.ctx.lineTo(particle.size / 2, 0);
        this.ctx.lineTo(0, particle.size / 2);
        this.ctx.closePath();
        this.ctx.fill();
        break;

      case "circle":
      default:
        this.ctx.beginPath();
        this.ctx.arc(0, 0, particle.size, 0, Math.PI * 2);
        this.ctx.fill();
        break;
    }
    
    this.ctx.restore();
  }
  
  private draw(): void {
    // Clear canvas
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    
    // Get visible sections (in the viewport)
    const visibleSections = this.sections.filter(section => {
      const rect = section.element.getBoundingClientRect();
      return (
        rect.bottom >= 0 &&
        rect.top <= window.innerHeight
      );
    });
    
    // If no sections are visible, draw default particles
    if (visibleSections.length === 0) {
      // Fill with default background
      this.ctx.fillStyle = this.themes.default.backgroundColor;
      this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
      return;
    }
    
    // Draw each visible section
    visibleSections.forEach(section => {
      const rect = section.element.getBoundingClientRect();
      
      // Calculate clip region for this section
      const top = Math.max(0, rect.top);
      const bottom = Math.min(window.innerHeight, rect.bottom);
      
      // Only draw if there's something visible
      if (bottom > top) {
        // Create clipping region for this section
        this.ctx.save();
        this.ctx.beginPath();
        this.ctx.rect(0, top, this.canvas.width, bottom - top);
        this.ctx.clip();
        
        // Fill with section background
        this.ctx.fillStyle = section.theme.backgroundColor;
        this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
        
        // Draw particles for this section
        section.particles.forEach(particle => {
          this.drawParticle(particle);
        });
        
        this.ctx.restore();
      }
    });
  }
  
  private animate(): void {
    this.updateParticles();
    this.draw();
    requestAnimationFrame(this.animate.bind(this));
  }
  
  // Helper to convert hex color to RGB
  private hexToRgb(hex: string): { r: number, g: number, b: number } | null {
    // Check if it's already an rgb color
    const rgbMatch = hex.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/);
    if (rgbMatch) {
      return {
        r: parseInt(rgbMatch[1], 10),
        g: parseInt(rgbMatch[2], 10),
        b: parseInt(rgbMatch[3], 10)
      };
    }
    
    // Handle shorthand hex
    const shorthandRegex = /^#?([a-f\d])([a-f\d])([a-f\d])$/i;
    hex = hex.replace(shorthandRegex, (m, r, g, b) => r + r + g + g + b + b);
    
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
      r: parseInt(result[1], 16),
      g: parseInt(result[2], 16),
      b: parseInt(result[3], 16)
    } : null;
  }

  // Helper to convert hex color to RGBA
  private hexToRgba(hex: string, alpha: number): string {
    const rgb = this.hexToRgb(hex);
    if (!rgb) return hex;
    return `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, ${alpha})`;
  }
}

export default ParticleBackground; 