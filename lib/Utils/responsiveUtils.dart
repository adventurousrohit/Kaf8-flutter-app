// lib/core/utils/responsive_utils.dart

import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isVerySmallScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.height < 600 || size.width < 360;
  }

  static bool isSmallScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.height < 700 || size.width < 380;
  }

  static bool isLargeScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.height > 900 || size.width > 420;
  }

  static double paddingScale(BuildContext context) {
    if (isVerySmallScreen(context)) return 0.6;
    if (isSmallScreen(context)) return 0.8;
    if (isLargeScreen(context)) return 1.1;
    return 1.0;
  }

  static double fontScale(BuildContext context) {
    if (isVerySmallScreen(context)) return 0.85;
    if (isSmallScreen(context)) return 0.95;
    if (isLargeScreen(context)) return 1.05;
    return 1.0;
  }

  static double spacingScale(BuildContext context) {
    if (isVerySmallScreen(context)) return 0.6;
    if (isSmallScreen(context)) return 0.75;
    if (isLargeScreen(context)) return 1.1;
    return 1.0;
  }

  static double componentScale(BuildContext context) {
    if (isVerySmallScreen(context)) return 0.7;
    if (isSmallScreen(context)) return 0.85;
    if (isLargeScreen(context)) return 1.1;
    return 1.0;
  }
}
