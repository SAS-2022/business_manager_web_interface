// Web-restricted Google Maps API key — see web/index.html for the matching
// script-tag key and the rationale for why web needs its own key separate
// from mobile's Android/iOS-restricted ones.
const webMaps = 'AIzaSyAztLZN9WAJrZiTMvi9PMkmv7JU8VfSiK0';

// RevenueCat Web Billing public API key — was going to back a direct
// Stripe checkout on the Subscribe screen, but that's on pause: Stripe
// doesn't support account registration from either Saudi Arabia (where the
// business currently operates) or Lebanon (the preferred registration
// country) — see subscribe_screen.dart's doc comment. Kept here rather
// than deleted since it's still valid and the JS interop wrapper built
// against it (revenuecat_web.dart) is real, working infrastructure worth
// keeping around if a Paddle-based (or other MoR) web checkout gets built
// later, or Stripe's country support changes.
const revenueCatWebSandbox = 'rcb_sb_aWufSauYiVJEuslUrabdCTLzu';

// App Store / Play Store listings — the Subscribe screen sends web
// visitors here instead of checking out directly on web (see
// subscribe_screen.dart). Same links as marketing_site/index.html's
// STORE_LINKS — update both places if these ever change.
const appStoreUrl = 'https://apps.apple.com/sa/app/costera/id6752457852';
const playStoreUrl =
    'https://play.google.com/store/apps/details?id=com.mini.manager';
