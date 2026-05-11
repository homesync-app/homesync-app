const fs = require('node:fs/promises');
const path = require('node:path');
const { pathToFileURL } = require('node:url');
const { chromium } = require('playwright');

const htmlPath = 'C:\\Users\\Blas_\\Downloads\\homesync_play_final_clean.html';
const outputDir = 'C:\\Users\\Blas_\\Downloads\\homesync_play_final_8_clean';

const screens = [
  ['ss10', '01-modos-de-hogar.png'],
  ['ss2', '02-home.png'],
  ['ss3', '03-tareas.png'],
  ['ss4', '04-duelo-semanal.png'],
  ['ss11', '05-familia-ranking.png'],
  ['ss6', '06-finanzas.png'],
  ['ss7', '07-recurrentes.png'],
  ['ss8', '08-ocr-ticket.png'],
];

async function waitForImages(page) {
  await page.evaluate(async () => {
    await document.fonts.ready;
    await Promise.all(
      Array.from(document.images).map((img) => {
        if (img.complete) return Promise.resolve();
        return new Promise((resolve) => {
          img.addEventListener('load', resolve, { once: true });
          img.addEventListener('error', resolve, { once: true });
        });
      }),
    );
  });
}

async function main() {
  await fs.mkdir(outputDir, { recursive: true });
  for (const file of await fs.readdir(outputDir).catch(() => [])) {
    if (file.endsWith('.png')) await fs.unlink(path.join(outputDir, file));
  }

  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({
    viewport: { width: 1080, height: 1920 },
    deviceScaleFactor: 1,
  });

  for (const [id, fileName] of screens) {
    await page.goto(pathToFileURL(htmlPath).href, { waitUntil: 'networkidle' });
    await waitForImages(page);
    await page.evaluate((targetId) => {
      const target = document.getElementById(targetId);
      if (!target) throw new Error(`Missing screenshot block: ${targetId}`);

      document.body.innerHTML = '';
      document.body.appendChild(target.cloneNode(true));

      document.documentElement.style.width = '1080px';
      document.documentElement.style.height = '1920px';
      document.documentElement.style.margin = '0';
      document.documentElement.style.padding = '0';
      document.documentElement.style.overflow = 'hidden';

      document.body.style.width = '1080px';
      document.body.style.height = '1920px';
      document.body.style.margin = '0';
      document.body.style.padding = '0';
      document.body.style.overflow = 'hidden';
      document.body.style.background = 'transparent';

      const ss = document.querySelector('.ss');
      ss.style.transform = 'none';
      ss.style.margin = '0';
      ss.style.boxShadow = 'none';
    }, id);
    await waitForImages(page);
    await page.screenshot({
      path: path.join(outputDir, fileName),
      clip: { x: 0, y: 0, width: 1080, height: 1920 },
    });
    console.log(fileName);
  }

  await browser.close();
  console.log(`Exported ${screens.length} screenshots to ${outputDir}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
