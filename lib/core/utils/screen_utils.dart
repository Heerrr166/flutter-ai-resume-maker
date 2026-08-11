import 'package:flutter/material.dart';

class ScreenUtils {
  ScreenUtils._();

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }
}
