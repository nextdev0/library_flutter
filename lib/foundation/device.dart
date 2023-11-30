import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:nextstory/widgets/window_config.dart';

abstract final class Devices {
  static SystemTheme? currentSystemTheme;

  static bool hasGestureBar(BuildContext context) {
    final w = View.of(context);

    if (Platform.isAndroid) {
      final insets = w.systemGestureInsets;
      return insets.right > 0 && insets.left > 0 && insets.bottom > 0;
    }

    if (Platform.isIOS) {
      final dpr = w.devicePixelRatio;
      final width = w.physicalSize.width;
      final height = w.physicalSize.height;
      final notchDimension = max(width, height) / dpr;
      return [812, 896, 844, 926].contains(notchDimension);
    }

    return false;
  }
}
