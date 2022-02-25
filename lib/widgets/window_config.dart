import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:focus_detector/focus_detector.dart';

/// iOS를 제외한 플래폼에서 화면 최상단 탭 시 최상단 스크롤 이동 테스트
bool cupertinoScrollToTopTest = false;

/// 테마 설정
enum WindowTheme {
  /// 상태바 검정색 아이콘
  darkIcon,

  /// 상태바 하얀색 아이콘
  lightIcon,

  /// 전체화면
  fullscreen,
}

/// 시스템 UI 설정 위젯
///
/// [Material]
class WindowConfig extends StatefulWidget {
  const WindowConfig({
    Key? key,
    required this.child,
    this.color = Colors.white,
    this.windowTheme = WindowTheme.darkIcon,
    this.orientation,
    this.navigationBarColor,
    this.navigationBarIconBrightness,
  }) : super(key: key);

  /// 자식 위젯
  final Widget child;

  /// 배경 색상
  final Color color;

  /// 테마 설정
  final WindowTheme windowTheme;

  /// 화면 방향
  final Orientation? orientation;

  /// 안드로이드 내비게이션바 색상
  final Color? navigationBarColor;

  /// 안드로이드 내비게이션바 아이콘 타입
  final Brightness? navigationBarIconBrightness;

  @override
  _WindowConfigState createState() => _WindowConfigState();
}

class _WindowConfigState extends State<WindowConfig> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Material(
      borderRadius: BorderRadius.zero,
      color: widget.color,
      elevation: 0.0,
      child: FutureBuilder(
        future: _setupAndroidVersion(),
        builder: (_, __) {
          if (_androidVersion == -1) {
            return const SizedBox.shrink();
          }

          _applyScreenOrientation();
          _applyTheme();

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarBrightness: _getStatusBarIconBrightness(context),
              statusBarIconBrightness: _getStatusBarIconBrightness(context),
              systemNavigationBarColor: _hasGestureBar(context)
                  ? Colors.transparent
                  : widget.navigationBarColor ?? Colors.black,
              systemNavigationBarIconBrightness:
                  _getNavigationBarIconBrightness(context),
            ),
            child: FocusDetector(
              onFocusGained: () {
                _applyScreenOrientation();
                _applyTheme();
              },
              child: Stack(
                children: [
                  SafeArea(
                    top: false,
                    left: false,
                    right: false,
                    bottom: _hasGestureBar(context) ? false : true,
                    child: widget.child,
                  ),
                  Positioned(
                    left: 0.0,
                    right: 0.0,
                    bottom: 0.0,
                    height: _hasGestureBar(context)
                        ? 0.0
                        : mediaQuery.padding.bottom,
                    child: const ColoredBox(color: Colors.black),
                  ),
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    right: 0.0,
                    height: mediaQuery.padding.top,
                    child: GestureDetector(
                      excludeFromSemantics: true,
                      onTap: Platform.isIOS
                          ? () {
                              final _primaryScrollController =
                                  PrimaryScrollController.of(context);
                              if (_primaryScrollController != null &&
                                  _primaryScrollController.hasClients) {
                                _primaryScrollController.animateTo(
                                  0.0,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.linearToEaseOut,
                                );
                              }
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _applyTheme() {
    if (widget.windowTheme == WindowTheme.fullscreen) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [
          SystemUiOverlay.top,
          SystemUiOverlay.bottom,
        ],
      );
    } else {
      SystemChrome.setEnabledSystemUIMode(
        _isEdgeToEdgeSupported()
            ? SystemUiMode.edgeToEdge
            : SystemUiMode.manual,
        overlays: [
          SystemUiOverlay.top,
          SystemUiOverlay.bottom,
        ],
      );
    }
  }

  void _applyScreenOrientation() {
    if (widget.orientation == null) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else if (widget.orientation == Orientation.portrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else if (widget.orientation == Orientation.landscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  Brightness _getStatusBarIconBrightness(BuildContext context) {
    return widget.windowTheme == WindowTheme.darkIcon
        ? Platform.isIOS
            ? Brightness.light
            : Brightness.dark
        : Platform.isIOS
            ? Brightness.dark
            : Brightness.light;
  }

  Brightness _getNavigationBarIconBrightness(BuildContext context) {
    if (widget.navigationBarIconBrightness == null) {
      return Brightness.light;
    }
    return widget.navigationBarIconBrightness == Brightness.dark
        ? Platform.isIOS
            ? Brightness.light
            : Brightness.dark
        : Platform.isIOS
            ? Brightness.dark
            : Brightness.light;
  }
}

var _androidVersion = -1;

bool _hasGestureBar(BuildContext context) {
  if (Platform.isAndroid) {
    final insets = window.systemGestureInsets;
    return insets.right > 0 && insets.left > 0 && insets.bottom > 0;
  }
  return Device.get().hasNotch;
}

bool _isEdgeToEdgeSupported() {
  if (Platform.isIOS) {
    return true;
  }
  return _androidVersion >= 29;
}

Future _setupAndroidVersion() async {
  if (_androidVersion == -1) {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _androidVersion = androidInfo.version.sdkInt ?? 23;
      return;
    }

    // iOS 버전 처리
    _androidVersion = 23;
  }
}
