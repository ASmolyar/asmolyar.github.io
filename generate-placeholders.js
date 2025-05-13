const fs = require('fs');
const path = require('path');

// Generate SVG placeholders
const placeholders = {
  'brainrot-placeholder.jpg': { title: 'BrainRot App', color: '#3498db' },
  'chess-league-placeholder.jpg': { title: 'Chess League', color: '#2c3e50' },
  'camp-maps-placeholder.jpg': { title: 'Camp Maps Tool', color: '#27ae60' },
  'camp-rsm-placeholder.jpg': { title: 'Camp RSM', color: '#27ae60' },
  'tomadoro-placeholder.jpg': { title: 'Tomadoro App', color: '#e74c3c' },
  'h4i-guitars-placeholder.jpg': { title: 'Guitars Over Guns', color: '#f39c12' },
  'h4i-catalyst-placeholder.jpg': { title: 'Catalyst Kitchens', color: '#f39c12' }
};

const assetsDir = path.join(__dirname, 'src', 'assets');

// Ensure assets directory exists
if (!fs.existsSync(assetsDir)) {
  fs.mkdirSync(assetsDir, { recursive: true });
  console.log(`Created directory: ${assetsDir}`);
}

// Create an SVG placeholder
function createSvgPlaceholder(title, bgColor) {
  const width = 800;
  const height = 600;
  
  return `<svg width="${width}" height="${height}" xmlns="http://www.w3.org/2000/svg">
    <rect width="100%" height="100%" fill="${bgColor}"/>
    <text x="50%" y="50%" font-family="Arial, sans-serif" font-size="32" fill="white" text-anchor="middle" dy=".3em">${title}</text>
  </svg>`;
}

// Generate each placeholder image
Object.entries(placeholders).forEach(([filename, { title, color }]) => {
  const filePath = path.join(assetsDir, filename.replace('.jpg', '.svg'));
  
  // If file already exists with content, skip
  if (fs.existsSync(filePath) && fs.statSync(filePath).size > 0) {
    console.log(`Skipping ${filename} - already exists`);
    return;
  }
  
  console.log(`Creating ${filename} placeholder`);
  
  const svgContent = createSvgPlaceholder(title, color);
  fs.writeFileSync(filePath, svgContent);
  console.log(`Created ${filePath}`);
});

// Update HTML file references from .jpg to .svg
const htmlPath = path.join(__dirname, 'src', 'index.html');

if (fs.existsSync(htmlPath)) {
  let htmlContent = fs.readFileSync(htmlPath, 'utf8');
  
  // Replace all .jpg extensions with .svg for our placeholder images
  Object.keys(placeholders).forEach(filename => {
    const jpgPath = `./assets/${filename}`;
    const svgPath = `./assets/${filename.replace('.jpg', '.svg')}`;
    htmlContent = htmlContent.replace(new RegExp(jpgPath, 'g'), svgPath);
  });
  
  fs.writeFileSync(htmlPath, htmlContent);
  console.log('Updated HTML file with SVG references');
}

console.log('Placeholder generation script completed'); 