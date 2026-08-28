// Regenerates ../assets/social-preview.png and (kept in sync manually)
// ../../web/social-preview.png from og-card.html.
//
// Usage: npm install playwright && node generate.js
// (npx playwright install chromium first, if Chromium isn't cached yet)
const { chromium } = require('playwright');
const path = require('path');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({
    viewport: { width: 1200, height: 630 },
    deviceScaleFactor: 2, // render sharp, downscale to spec size below
  });
  await page.goto('file://' + path.join(__dirname, 'og-card.html'));
  const buffer = await page.screenshot();
  await browser.close();

  // Downscale the 2x render to the exact 1200×630 OG spec size using sips
  // (macOS) — avoids pulling in an image-resize npm dependency for a
  // one-off asset script.
  const fs = require('fs');
  const os = require('os');
  const { execSync } = require('child_process');
  const tmp = path.join(os.tmpdir(), 'og-card-2x.png');
  fs.writeFileSync(tmp, buffer);
  const out = path.join(__dirname, '..', 'assets', 'social-preview.png');
  execSync(`sips -z 630 1200 "${tmp}" --out "${out}"`, { stdio: 'inherit' });
  fs.unlinkSync(tmp);
  console.log('Wrote', out);
  console.log('Remember to copy it to web/social-preview.png too (or update that path to match).');
})();
