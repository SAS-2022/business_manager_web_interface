class AppDimensions {
  static const double baseWidth = 375.0; // iPhone 13 mini width
  static const double baseHeight = 812.0; // iPhone 13 mini height
  static const double baseFontSize = 16.0;

  // Matches ResponsiveUtils._maxScaleWidth — the width the scale factor is
  // tuned for. Content should be constrained to this on wide screens,
  // otherwise layouts (grids, cards, buttons) stretch full-bleed even
  // though every individual dimension inside them stopped scaling up.
  static const double maxContentWidth = 480.0;

  // Wider cap for pages built around a multi-column grid (business type
  // picker, category picker, dashboards). Single-column forms should stay at
  // maxContentWidth for readable line length; grid pages should get more
  // room so cards can add columns instead of stacking with wasted width on
  // wide screens.
  static const double maxGridContentWidth = 760.0;

  // Wider still, for product-catalog-style pages — matches the container
  // width convention most e-commerce/catalog sites use (~1280px) so the
  // grid doesn't float unanchored in a huge blank canvas on a wide monitor,
  // without stretching product cards edge-to-edge on an ultrawide screen.
  static const double maxCatalogWidth = 1280.0;

  // Padding
  static const double paddingExtraSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 16.0;

  // Icon
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
}
