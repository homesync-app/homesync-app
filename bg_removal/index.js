const { removeBackground } = require('@imgly/background-removal-node');
const fs = require('fs');
const path = require('path');

const inputDir = 'C:\\Users\\Blas_\\.gemini\\antigravity\\brain\\a113dcdf-83e3-4086-b78c-e6b999fca184';
const outputDir = 'C:\\Users\\Blas_\\Documents\\Aplicacion de Pareja\\bg_removal\\out';
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir);
}

const images = [
  { name: 'boy.png', path: 'boy_avatar_1772202973251.png' },
  { name: 'girl.png', path: 'girl_avatar_1772203159813.png' },
  { name: 'cat.png', path: 'cat_avatar_1772203186501.png' },
  { name: 'dog.png', path: 'dog_avatar_1772203214631.png' },
  { name: 'robot.png', path: 'robot_avatar_1772203284418.png' },
  { name: 'bird.png', path: 'bird_avatar_1772203464394.png' }
];

async function main() {
  for (const img of images) {
    const inputPath = path.join(inputDir, img.path);
    const outputPath = path.join(outputDir, img.name);
    
    console.log(`Processing URI file://${inputPath.replace(/\\/g, '/')}...`);
    try {
      const resBlob = await removeBackground(`file://${inputPath.replace(/\\/g, '/')}`);
      const buffer = Buffer.from(await resBlob.arrayBuffer());
      fs.writeFileSync(outputPath, buffer);
      console.log(`Success -> ${outputPath}`);
    } catch (e) {
      console.error(`Error processing ${img.path}:`, e);
    }
  }
}

main();
