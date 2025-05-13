// Import GSAP functionality
// Note: We're using the 'any' type here to avoid TypeScript errors
// since we're not installing the @types/gsap package
declare const gsap: any;
declare const ScrollTrigger: any;

// Import our particle background
import ParticleBackground from './particles';

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

  // Set up project navigation
  setupProjectNavHighlighting();

  // Mobile menu toggle functionality
  const menuToggle = document.querySelector('.header__menu-toggle') as HTMLButtonElement;
  const nav = document.querySelector('.header__nav') as HTMLElement;

  if (menuToggle && nav) {
    menuToggle.addEventListener('click', () => {
      nav.classList.toggle('active');
      const isActive = nav.classList.contains('active');
      
      // Animate the menu icon
      const spans = menuToggle.querySelectorAll('span');
      if (isActive && typeof gsap !== 'undefined') {
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
  const navLinks = document.querySelectorAll('.header__nav a');
  navLinks.forEach(link => {
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

  // Sticky header with background color change on scroll
  const header = document.querySelector('.header') as HTMLElement;
  let lastScrollTop = 0;

  if (header) {
    window.addEventListener('scroll', () => {
      const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
      
      if (scrollTop > 100) {
        header.style.backgroundColor = 'rgba(255, 255, 255, 1)';
        header.style.boxShadow = '0 4px 6px rgba(0, 0, 0, 0.1)';
      } else {
        header.style.backgroundColor = 'rgba(255, 255, 255, 1)';
        header.style.boxShadow = 'var(--shadow-sm)';
      }
      
      lastScrollTop = scrollTop;
    });
  }
  
  // Only run GSAP animations if GSAP is loaded
  if (typeof gsap !== 'undefined') {
    // Hero section fade in
    gsap.from('.hero__title', { 
      opacity: 0, 
      y: 50, 
      duration: 1,
      delay: 0.2
    });
    
    gsap.from('.hero__subtitle', { 
      opacity: 0, 
      y: 30, 
      duration: 1,
      delay: 0.4
    });
    
    gsap.from('.hero__text', { 
      opacity: 0, 
      y: 30, 
      duration: 1,
      delay: 0.6
    });
    
    gsap.from('.hero__buttons', { 
      opacity: 0, 
      y: 30, 
      duration: 1,
      delay: 0.8
    });
    
    // Project nav animation - fade in from top
    gsap.fromTo('.project-nav', 
      { 
        y: -20,
        opacity: 0,
      },
      {
        y: 0,
        opacity: 1,
        duration: 0.8,
        delay: 1.0,
        ease: "power2.out"
      }
    );
    
    // Project sections
    if (typeof ScrollTrigger !== 'undefined') {
      // Project sections
      document.querySelectorAll('.project-section').forEach((section) => {
        const textContent = section.querySelector('.project-content__text');
        const mediaContent = section.querySelector('.project-content__media');
        
        if (textContent) {
          gsap.from(textContent, {
            scrollTrigger: {
              trigger: section,
              start: 'top 70%'
            },
            opacity: 0,
            x: -50,
            duration: 0.8
          });
        }
        
        if (mediaContent) {
          gsap.from(mediaContent, {
            scrollTrigger: {
              trigger: section,
              start: 'top 70%'
            },
            opacity: 0,
            x: 50,
            duration: 0.8
          });
        }
      });
      
      // Contact section
      gsap.from('.contact__text', {
        scrollTrigger: {
          trigger: '.contact',
          start: 'top 80%'
        },
        opacity: 0,
        y: 30,
        duration: 0.8
      });
      
      gsap.from('.contact__links', {
        scrollTrigger: {
          trigger: '.contact',
          start: 'top 70%'
        },
        opacity: 0,
        y: 30,
        duration: 0.8,
        delay: 0.2
      });
      
      gsap.from('.contact__tagline', {
        scrollTrigger: {
          trigger: '.contact',
          start: 'top 60%'
        },
        opacity: 0,
        y: 30,
        duration: 0.8,
        delay: 0.4
      });
    }
  }
});

// Function to highlight the current section in the navigation
function setupProjectNavHighlighting(): void {
  const sections = document.querySelectorAll('section[id]');
  const navLinks = document.querySelectorAll('.project-nav__link');
  const aboutSection = document.getElementById('about');
  
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
          
          // Optional: Scroll the nav to show the active link
          const projectNav = document.querySelector('.project-nav') as HTMLElement;
          if (projectNav) {
            const navRect = projectNav.getBoundingClientRect();
            const linkRect = activeLink.getBoundingClientRect();
            
            // If link is not fully visible in the nav
            if (linkRect.left < navRect.left || linkRect.right > navRect.right) {
              // Smooth scroll to link
              projectNav.scrollTo({
                left: (activeLink as HTMLElement).offsetLeft - projectNav.clientWidth / 2 + activeLink.clientWidth / 2,
                behavior: 'smooth'
              });
            }
          }
        }
      }
    });
  }, observerOptions);
  
  // Observe all sections including the about section
  sections.forEach(section => {
    observer.observe(section);
  });
} 