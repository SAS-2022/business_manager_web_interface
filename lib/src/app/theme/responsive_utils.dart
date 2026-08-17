import 'package:flutter/material.dart';
import '../constants/dimensions.dart';

class ResponsiveUtils {
  final BuildContext context;

  ResponsiveUtils(this.context);

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;
  TextScaler get textScale => MediaQuery.of(context).textScaler;

  // For more precise device classification
  int get deviceType {
    if (screenWidth < 600) return 1;
    if (screenWidth < 900) return 2;
    if (screenWidth < 1200) return 3;
    return 4;
  }

  // Reference size the scale factor is capped at — the design is tuned for
  // phone/small-tablet widths (baseWidth/baseHeight below). Past this, a wide
  // desktop browser window would otherwise scale every dimension (logo,
  // icons, spacing) up linearly and unboundedly, causing overflow/overlap.
  static const double _maxScaleWidth = 480;
  static const double _maxScaleHeight = 900;

  // Scale dimensions based on screen width
  double scaleWidth(double size) =>
      (size / AppDimensions.baseWidth) * screenWidth.clamp(0, _maxScaleWidth);

  // Scale dimensions based on screen height
  double scaleHeight(double size) =>
      (size / AppDimensions.baseHeight) *
      screenHeight.clamp(0, _maxScaleHeight);

  // Fixed: Scale font size with proper constraints
  double scaleFont(double size, {double minSize = 8, double? maxSize}) {
    maxSize ??= 24;
    // Simple scaling based on screen width ratio with constraints
    double scaleFactor = screenWidth.clamp(0, _maxScaleWidth) / AppDimensions.baseWidth;
    double scaledSize = size * scaleFactor;

    // Apply text scaling
    scaledSize = textScale.scale(scaledSize);

    return scaledSize.clamp(minSize, maxSize);
  }

  // Get responsive padding
  EdgeInsetsGeometry get responsivePaddingES => EdgeInsets.symmetric(
        horizontal: scaleWidth(AppDimensions.paddingExtraSmall),
        vertical: scaleHeight(AppDimensions.paddingExtraSmall),
      );
  EdgeInsetsGeometry get responsivePaddingS => EdgeInsets.symmetric(
        horizontal: scaleWidth(AppDimensions.paddingSmall),
        vertical: scaleHeight(AppDimensions.paddingSmall),
      );
  EdgeInsetsGeometry get responsivePaddingM => EdgeInsets.symmetric(
        horizontal: scaleWidth(AppDimensions.paddingMedium),
        vertical: scaleHeight(AppDimensions.paddingMedium),
      );
  EdgeInsetsGeometry get responsivePaddingL => EdgeInsets.symmetric(
        horizontal: scaleWidth(AppDimensions.paddingLarge),
        vertical: scaleHeight(AppDimensions.paddingLarge),
      );
  EdgeInsetsGeometry get responsivePaddingBottomS =>
      EdgeInsets.only(bottom: scaleHeight(AppDimensions.paddingSmall));
  EdgeInsetsGeometry get responsivePaddingBottom =>
      EdgeInsets.only(bottom: scaleHeight(AppDimensions.paddingMedium));

  EdgeInsetsGeometry get responsivePaddingLBottom =>
      EdgeInsets.only(bottom: scaleHeight(AppDimensions.paddingExtraLarge));

  EdgeInsetsGeometry get responsivePaddingRight =>
      EdgeInsets.only(right: scaleHeight(AppDimensions.paddingMedium));

  EdgeInsetsGeometry get responsivePaddingVer => EdgeInsets.symmetric(
        vertical: scaleHeight(AppDimensions.paddingSmall),
      );
  EdgeInsetsGeometry get responsivePaddingHor => EdgeInsets.symmetric(
        horizontal: scaleHeight(AppDimensions.paddingSmall),
      );
  EdgeInsetsGeometry get responsivePaddingHorM => EdgeInsets.symmetric(
        horizontal: scaleHeight(AppDimensions.paddingMedium),
      );

  // Get responsive margin
  EdgeInsetsGeometry get responsiveMargin => EdgeInsets.all(
        scaleWidth(AppDimensions.paddingMedium),
      );
}
