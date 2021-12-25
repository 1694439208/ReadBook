import 'dart:math';
import 'dart:ui';

//import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:flutter/material.dart';

enum ScreenAdaptationType {
  byWidth,
  byHeight,
}

class ScreenAdaptation {
  static double screenWidth =
      window.physicalSize.width / window.devicePixelRatio;
  static double screenHeight =
      window.physicalSize.height / window.devicePixelRatio - window.padding.top;

  ///适配设计尺寸
  /// screenAdaptationType为byWidth时，此值为宽度
  /// screenAdaptationType为byWidth时，此值为高度
  static double designSize = screenWidth;

  static ScreenAdaptationType screenAdaptationType =
      ScreenAdaptationType.byWidth;

  //static double width = 0.0;
  //static double height = 0.0;
  static double statusBarHeight = 0.0;
  static init(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    //width = mediaQueryData.size.width - 20;
    //height = mediaQueryData.size.height - 20;

    statusBarHeight = mediaQueryData.padding.top;
    ScreenAdaptation.screenHeight =
        mediaQueryData.size.height - statusBarHeight - 20;
    ScreenAdaptation.screenWidth = mediaQueryData.size.width - 10;
//    double size =
//        mediaQueryData.size.longestSide * mediaQueryData.devicePixelRatio;
  }

  static Future<void> setBrightness(double brightness) async {
    //await DeviceDisplayBrightness.setBrightness(brightness);
  }
}

dp(value) {
  //宽度大于高度，被旋转了。
  var screenRotated =
      ScreenAdaptation.screenWidth > ScreenAdaptation.screenHeight;

  if (ScreenAdaptation.screenAdaptationType == ScreenAdaptationType.byWidth &&
      !screenRotated) {
    return value / ScreenAdaptation.designSize * ScreenAdaptation.screenWidth;
  } else {
    return value / ScreenAdaptation.designSize * ScreenAdaptation.screenHeight;
  }
}

/// 以iPhone7Plus作为适配尺寸 逻辑尺寸为(宽414，高736)
dpx(value) {
  return value / 414 * ScreenAdaptation.screenWidth;
}

/// 屏宽百分比
vw(value) {
  return window.physicalSize.width / window.devicePixelRatio * value / 100;
}

/// 屏高百分比
vh(value) {
//  return ScreenAdaptation.screenHeight * value / 100;
  return window.physicalSize.height / window.devicePixelRatio * value / 100;
}
