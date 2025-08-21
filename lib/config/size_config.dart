import 'package:flutter/material.dart';

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;

  static void init(BuildContext context) {
    final mq = MediaQuery.of(context);

    final padding = mq.padding;
    screenWidth = mq.size.width - padding.horizontal;
    screenHeight = mq.size.height - padding.vertical;

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
  }

  static double ws(double px) {
    final scale = screenWidth / 375;
    return (px * scale).clamp(px * 0.85, px * 1.2);
  }

  static double hs(double px) {
    final scale = screenHeight / 812;
    return (px * scale).clamp(px * 0.85, px * 1.2);
  }

  static double fs(double fontSize) {
    final scale = (screenWidth / 375 + screenHeight / 812) / 2;
    return (fontSize * scale).clamp(fontSize * 0.9, fontSize * 1.3);
  }
}
