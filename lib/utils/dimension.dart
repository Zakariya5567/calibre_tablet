import 'package:calibre_tablet/main.dart';
import 'package:flutter/material.dart';

import 'constant.dart';

mediaQuerySize() {
  mediaQuery = MediaQuery.of(navKey.currentContext!).size;
}

// ignore: prefer_typing_uninitialized_variables
var mediaQuery;

double get screenHeight => mediaQuery.height;
double get screenWidth => mediaQuery.width;

double widgetHeight(double pixels) {
  mediaQuerySize();
  return mediaQuery.height / (AppConstant.designHeight / pixels);
}

double widgetWidth(double pixels) {
  mediaQuerySize();
  return mediaQuery.width / (AppConstant.designWidth / pixels);
}
