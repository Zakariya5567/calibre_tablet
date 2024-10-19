import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//primary swatch
class AppColor {
  static const Map<int, Color> primaryColor = {
    50: Color.fromRGBO (0, 0, 0, 0.1),
    100: Color.fromRGBO(0, 0, 0, 0.2),
    200: Color.fromRGBO(0, 0, 0, 0.3),
    300: Color.fromRGBO(0, 0, 0, 0.4),
    400: Color.fromRGBO(0, 0, 0, 0.5),
    500: Color.fromRGBO(0, 0, 0, 0.6),
    600: Color.fromRGBO(0, 0, 0, 0.7),
    700: Color.fromRGBO(0, 0, 0, 0.8),
    800: Color.fromRGBO(0, 0, 0, 0.9),
    900: Color.fromRGBO(0, 0, 0, 1),
  };

  static const redPrimary = Color.fromRGBO(255, 0, 0, 1);
  static const blackPrimary = Color.fromRGBO(30, 30, 30, 1);
  static const blackSecondary = Color.fromRGBO(39, 39, 39, 1);
  static const whitePrimary = Color.fromRGBO(255, 255, 255, 1);
  static const whiteSecondary = Color.fromRGBO(207, 207, 207, 1);
  static const greenPrimary = Color.fromRGBO(33, 153, 66, 1);
  static const shimmerBaseColor = Color.fromRGBO(200, 200, 200, 0.6);
  static const shimmerHighlightColor = Color.fromRGBO(243, 243, 243, 0.66);

// statusBar
 static const defaultStatusBar =
        SystemUiOverlayStyle(
        statusBarColor: blackPrimary,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: blackPrimary,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: blackPrimary);

  transparentStatusBar() {
    return const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent);
  }
}
