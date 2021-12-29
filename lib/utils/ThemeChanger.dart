import 'package:flutter/material.dart';

class AppInfoProvider with ChangeNotifier {
  // 这里最好要分开写
  Brightness _brightness = Brightness.light;

  Brightness get brightness => _brightness;

  void setTheme(Brightness themeColor) {
    _brightness = themeColor;
    notifyListeners();
  }
}