# marketing_site/

The public landing page at `costera.biz` — plain static HTML/CSS/JS, no
build step, no framework. Kept deliberately separate from the Flutter app
(`lib/`, `web/`) so it's real crawlable DOM text instead of the Flutter web
build's CanvasKit `<canvas>` output. See the comment block at the top of
`index.html` for the full reasoning.

## Why it exists

`lib/src/features/landing/landing_page.dart` (the Flutter version) is
still what a signed-out visitor sees if they land *inside* the app (e.g. a
bookmarked `app.costera.biz/` URL). This static page is the one meant to
actually rank in search results and get shared on social — same content,
same design intent, hand-kept in sync.

## Deploying

Login/Register/Contact Us links here are relative (`/login`, `/register`,
`/contactUs`) and resolve on this same `costera.biz` domain: run
`../build/web` through `./sync-app-shell.sh` first (copies the built
Flutter app in as `app-shell.html` + its JS/asset files, all
`.gitignore`'d — generated, not authored), then
`firebase deploy --only hosting:marketing`. Firebase Hosting serves this
folder's own files (`index.html`, `privacy.html`, `terms.html`,
`robots.txt`, `sitemap.xml`, `site-assets/`) directly, and falls back to
`app-shell.html` (via the catch-all rewrite in `firebase.json`) for
anything else — `/login`, `/register`, `/contactUs`, and any other in-app
route. `app.costera.biz` (the Flutter app's own separate Hosting target,
`build/web` deployed directly) still exists for bookmarked links, but
nothing here needs to point at it.

## Known placeholders — fix before going live

- **Copy is in English only.** The Flutter app is fully localized (5
  languages); this page isn't yet. Worth doing once the pitch/copy has
  settled — see `landing_page.dart`'s own doc comment for the same note.

## The share image (`site-assets/social-preview.png`)

This is what shows up as the preview thumbnail when someone shares
`costera.biz` on Facebook, LinkedIn, WhatsApp, Slack, X/Twitter, iMessage,
etc. — referenced by the `og:image`/`twitter:image` tags in `index.html`'s
`<head>`. It's a real 1200×630 designed card (logo, headline, feature
chips), not a cropped app icon. Source lives in `og-card-source/` — edit
`og-card-source/og-card.html` and run `node generate.js` there (needs
`npm install playwright` once) to regenerate it if the branding or copy
changes. Remember to copy the result to `../web/social-preview.png` too —
the Flutter app's own `web/index.html` points at the same image.

## Mobile → app-store prompt

iOS/Android visitors (detected via user agent, client-side) see a
full-screen "Get the CostEra app" prompt pointing at the real App
Store/Play Store listings, with a "Continue to website instead" link to
dismiss it (remembered for that browser session via `sessionStorage`, not
forever). Deliberately not a silent hard redirect — Google's mobile-
usability guidelines specifically flag content-hiding app-install
interstitials as a negative ranking signal, and a redirect with no way out
would apply to Googlebot's mobile crawler too. See the `.app-prompt` CSS
comment and the script near the end of `index.html` for the actual logic.
Store links live in the `STORE_LINKS` object in that same script — update
them there if the app's Store URLs ever change.

## Keeping the two landing pages in sync

There's no shared source of truth between this file and
`landing_page.dart` — they're independent files that happen to say the
same thing. When the pitch, feature list, or pricing changes, update both
by hand.
