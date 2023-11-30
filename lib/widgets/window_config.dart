import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nextstory/exceptions/library_not_initialized.dart';
import 'package:nextstory/foundation/device.dart';
import 'package:nextstory/nextstory.dart';

class SystemTheme {
  bool fullscreen;
  bool statusDarkIcon;
  bool navigationDarkIcon;
  ScreenOrientation orientation;
  ScreenOrientation? inheritedOrientation;

  SystemTheme({
    this.fullscreen = false,
    this.statusDarkIcon = false,
    this.navigationDarkIcon = false,
    this.orientation = ScreenOrientation.unspecified,
  });
}

enum ScreenOrientation {
  /// 방향 없음
  unspecified,

  /// 세로 모드
  portrait,

  /// 가로 모드
  landscape,

  /// 가장 최근에 지정된 방향으로 맞춤
  inherit,
}

/// 시스템 UI 설정 위젯
class WindowConfig extends StatefulWidget {
  const WindowConfig({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.orientation = ScreenOrientation.unspecified,
    this.navigationBarColor,
    this.navigationBarDividerColor,
    this.navigationBarIconBrightness,
    this.statusBarIconBrightness,
    this.forceEdgeToEdge = false,
    this.fullscreen = false,
  });

  /// 자식 위젯
  final Widget child;

  /// 배경 색상
  final Color color;

  /// 화면 방향
  final ScreenOrientation orientation;

  /// 안드로이드 내비게이션바 색상
  final Color? navigationBarColor;

  /// 안드로이드 내비게이션바 선 색상
  final Color? navigationBarDividerColor;

  /// 안드로이드 내비게이션바 아이콘 타입
  final Brightness? navigationBarIconBrightness;

  /// 안드로이드 상태바 아이콘 타입
  final Brightness? statusBarIconBrightness;

  /// 강제로 EdgeToEdge를 사용하도록 합니다.
  final bool forceEdgeToEdge;

  /// 전체화면 사용
  final bool fullscreen;

  @override
  State<WindowConfig> createState() => _WindowConfigState();
}

class _WindowConfigState extends State<WindowConfig> {
  bool get _edgeToEdgeMode {
    return Devices.hasGestureBar(context) ||
        widget.forceEdgeToEdge ||
        Platform.isIOS;
  }

  Brightness get _navigationBarIconBrightness {
    if (widget.navigationBarIconBrightness == null) {
      return Brightness.light;
    }

    // android: 구버전 지원
    if (Platform.isAndroid && Nextstory.androidSdkVersion < 26) {
      return Brightness.light;
    }

    // iOS: 내비게이션바가 없으므로 임의값 지정
    if (Platform.isIOS) {
      return Brightness.light;
    }

    return widget.navigationBarIconBrightness!;
  }

  @override
  Widget build(BuildContext context) {
    final lib = context.findAncestorWidgetOfExactType<LibraryInitializer>();
    if (lib == null) {
      throw LibraryNotInitializedException();
    }

    final statusBarIconBrightness = widget.statusBarIconBrightness;
    final navigationIconBrightness = _navigationBarIconBrightness;
    return AnnotatedRegion<SystemTheme>(
      value: SystemTheme(
        fullscreen: widget.fullscreen,
        statusDarkIcon: statusBarIconBrightness == Brightness.dark,
        navigationDarkIcon: navigationIconBrightness == Brightness.dark,
        orientation: widget.orientation,
      ),
      child: Material(
        borderRadius: BorderRadius.zero,
        color: widget.color,
        elevation: 0.0,
        child: Stack(
          children: [
            // 컨텐츠 영역
            SafeArea(
              top: false,
              left: _edgeToEdgeMode ? false : true,
              right: _edgeToEdgeMode ? false : true,
              bottom: _edgeToEdgeMode ? false : true,
              child: widget.child,
            ),

            // android: 내비게이션바 색상
            _buildNavigationBar(),

            // iOS: 터치 시 맨 위로 스크롤 영역
            Container(
              alignment: Alignment.topCenter,
              width: double.infinity,
              height: MediaQuery.paddingOf(context).top,
              child: GestureDetector(
                excludeFromSemantics: true,
                onTap: () {
                  if (Platform.isIOS) {
                    final sc = PrimaryScrollController.of(context);
                    if (sc.hasClients) {
                      sc.animateTo(
                        0.0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.linearToEaseOut,
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    if (_edgeToEdgeMode) {
      return const SizedBox.shrink();
    }

    final padding = MediaQuery.paddingOf(context);
    final navigationBarDividerColor =
        widget.navigationBarDividerColor ?? Colors.transparent;

    if (padding.left > 0) {
      return Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: padding.left,
          height: double.infinity,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: widget.navigationBarColor ?? Colors.black,
                  border: Border(
                    right: BorderSide(
                      color: navigationBarDividerColor,
                      width: Nextstory.androidSdkVersion >= 26 ? 1.0 : 0.0,
                    ),
                  ),
                ),
              ),
              // 구버전 지원 반투명 색상
              Container(
                width: double.infinity,
                height: double.infinity,
                color: (Nextstory.androidSdkVersion >= 26 || _edgeToEdgeMode)
                    ? Colors.transparent
                    : Colors.black.withOpacity(0.2),
              ),
            ],
          ),
        ),
      );
    }

    if (padding.right > 0) {
      return Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: padding.right,
          height: double.infinity,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: widget.navigationBarColor ?? Colors.black,
                  border: Border(
                    left: BorderSide(
                      color: navigationBarDividerColor,
                      width: Nextstory.androidSdkVersion >= 26 ? 1.0 : 0.0,
                    ),
                  ),
                ),
              ),
              // 구버전 지원 반투명 색상
              Container(
                width: double.infinity,
                height: double.infinity,
                color: (Nextstory.androidSdkVersion >= 26 || _edgeToEdgeMode)
                    ? Colors.transparent
                    : Colors.black.withOpacity(0.2),
              ),
            ],
          ),
        ),
      );
    }

    // bottom
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: double.infinity,
        height: padding.bottom,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.navigationBarColor ?? Colors.black,
                border: Border(
                  top: BorderSide(
                    color: navigationBarDividerColor,
                    width: Nextstory.androidSdkVersion >= 26 ? 1.0 : 0.0,
                  ),
                ),
              ),
            ),
            // 구버전 지원 반투명 색상
            Container(
              width: double.infinity,
              height: double.infinity,
              color: (Nextstory.androidSdkVersion >= 26 || _edgeToEdgeMode)
                  ? Colors.transparent
                  : Colors.black.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }
}
