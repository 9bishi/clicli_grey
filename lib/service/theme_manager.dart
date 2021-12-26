import 'dart:math';

import 'package:flutter/material.dart';

import '../instance.dart';

class ThemeManager {
  static bool _isDark = false;
  static const bool amoledDark = true;

  static const primaryColor = Color.fromRGBO(148, 107, 230, 1);
  static const bgColor = Color.fromRGBO(240, 240, 245, 1);
  static final primarySwatch = generateMaterialColor(primaryColor);

  static bool isDark() {
    _isDark = Instances.sp.getBool('isDarkTheme') ?? false;
    return _isDark;
  }

  //#946be6
  static ThemeData get lightTheme => ThemeData(
        splashFactory: const NoSplashFactory(),
        primarySwatch: primarySwatch,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        brightness: Brightness.light,
        cardTheme: const CardTheme(shadowColor: Colors.transparent),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(color: Colors.white),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        splashFactory: const NoSplashFactory(),
        primarySwatch: primarySwatch,
        primaryColor: const Color.fromRGBO(148, 107, 230, 1),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        brightness: Brightness.dark,
        cardTheme: const CardTheme(shadowColor: Colors.transparent),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
      );

  // https://medium.com/@morgenroth/using-flutters-primary-swatch-with-a-custom-materialcolor-c5e0f18b95b0
  static MaterialColor generateMaterialColor(Color color) {
    return MaterialColor(color.value, {
      50: tintColor(color, 0.9),
      100: tintColor(color, 0.8),
      200: tintColor(color, 0.6),
      300: tintColor(color, 0.4),
      400: tintColor(color, 0.2),
      500: color,
      600: shadeColor(color, 0.1),
      700: shadeColor(color, 0.2),
      800: shadeColor(color, 0.3),
      900: shadeColor(color, 0.4),
    });
  }

  static int tintValue(int value, double factor) =>
      max(0, min((value + ((255 - value) * factor)).round(), 255));

  static Color tintColor(Color color, double factor) => Color.fromRGBO(
      tintValue(color.red, factor),
      tintValue(color.green, factor),
      tintValue(color.blue, factor),
      1);

  static int shadeValue(int value, double factor) =>
      max(0, min(value - (value * factor).round(), 255));

  static Color shadeColor(Color color, double factor) => Color.fromRGBO(
      shadeValue(color.red, factor),
      shadeValue(color.green, factor),
      shadeValue(color.blue, factor),
      1);
}

class NoSplashFactory extends InteractiveInkFeatureFactory {
  const NoSplashFactory();

  @override
  InteractiveInkFeature create({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  }) {
    return NoSplash(
      controller: controller,
      referenceBox: referenceBox,
      color: color,
      onRemoved: onRemoved,
    );
  }
}

class NoSplash extends InteractiveInkFeature {
  NoSplash({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Color color,
    VoidCallback? onRemoved,
  }) : super(
            color: color,
            controller: controller,
            referenceBox: referenceBox,
            onRemoved: onRemoved) {
    controller.addInkFeature(this);
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {}
}
