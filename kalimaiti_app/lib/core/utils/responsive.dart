import 'package:flutter/material.dart';

class Responsive {
  // Check if device is mobile (width < 600)
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  // Check if device is tablet (width >= 600 && width < 1024)
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  // Check if device is desktop (width >= 1024)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  // Get responsive value based on screen size
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  // Get responsive padding
  static EdgeInsets padding(BuildContext context) {
    return EdgeInsets.all(
      value(context, mobile: 16.0, tablet: 24.0, desktop: 32.0),
    );
  }

  // Get responsive horizontal padding
  static EdgeInsets horizontalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: value(context, mobile: 16.0, tablet: 24.0, desktop: 32.0),
    );
  }

  // Get responsive font size
  static double fontSize(BuildContext context, double baseSize) {
    return baseSize * value(context, mobile: 1.0, tablet: 1.1, desktop: 1.2);
  }

  // Get responsive grid columns
  static int gridColumns(BuildContext context) {
    return value(context, mobile: 1, tablet: 2, desktop: 3);
  }

  // Get max content width for centered layouts
  static double maxContentWidth(BuildContext context) {
    return value(
      context,
      mobile: double.infinity,
      tablet: 800.0,
      desktop: 1200.0,
    );
  }

  // Build responsive layout
  static Widget builder({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  // Get responsive spacing
  static double spacing(BuildContext context) {
    return value(context, mobile: 8.0, tablet: 12.0, desktop: 16.0);
  }

  // Get responsive card elevation
  static double cardElevation(BuildContext context) {
    return value(context, mobile: 2.0, tablet: 4.0, desktop: 6.0);
  }

  // Get responsive border radius
  static double borderRadius(BuildContext context) {
    return value(context, mobile: 12.0, tablet: 16.0, desktop: 20.0);
  }
}

// Extension on BuildContext for easier access to responsive utilities
extension ResponsiveContext on BuildContext {
  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);

  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  EdgeInsets get responsivePadding => Responsive.padding(this);
  EdgeInsets get responsiveHorizontalPadding =>
      Responsive.horizontalPadding(this);
  double get responsiveSpacing => Responsive.spacing(this);
}
