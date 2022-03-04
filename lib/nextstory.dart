import 'dart:io';

import 'package:flutter/services.dart';

const _methodChannel = MethodChannel('nextstory');

class Nextstory {
  Nextstory._();

  /// 투명 내비게이션바 활성화
  ///
  /// 안드로이드 10 이상의 제스처 영역의 투명화를 위해 사용
  static Future enableAndroidTransparentNavigationBar() async {
    if (Platform.isAndroid) {
      await _methodChannel.invokeMethod(
        'enableAndroidTransparentNavigationBar',
      );
    }
  }

  /// iOS 터치 지연 해제
  ///
  /// iOS 좌측 드래그 제스처 버벅임 문제를 해결함
  static Future disableDelayTouchesBeganIOS() async {
    if (Platform.isIOS) {
      await _methodChannel.invokeMethod(
        'disableDelayTouchesBeganIOS',
      );
    }
  }

  /// 미디어 스캔
  ///
  /// 안드로이드 전용 메소드
  static Future mediaScan(File file) async {
    if (Platform.isIOS) {
      await _methodChannel.invokeMethod(
        'mediaScan',
        {'path': file.path},
      );
    }
  }
}
