import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info/device_info.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:focus_detector/focus_detector.dart';

/// 안드로이드 버전
var _androidVersion = -1;

/// 제스처 모드 유무
bool _hasGestureBar(BuildContext context) {
  if (Platform.isAndroid) {
    final insets = window.systemGestureInsets;
    return insets.right > 0 && insets.left > 0 && insets.bottom > 0;
  }
  return Device.get().hasNotch;
}

/// 상태바, 내비게이션바 겹치기 지원 유무
bool _isEdgeToEdgeSupported() {
  if (Platform.isIOS) {
    return true;
  }
  return _androidVersion >= 29;
}

/// [_androidVersion] 로딩
Future _setupAndroidVersion() async {
  if (_androidVersion == -1) {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      _androidVersion = androidInfo.version.sdkInt;
      return;
    }

    // iOS 버전 처리
    _androidVersion = 23;
  }
}

/// 기능 추가된 [Scaffold]
class ScaffoldBase extends StatelessWidget {
  const ScaffoldBase._({
    Key? key,
    required this.builder,
    this.backgroundColor,
    this.topInsetBackgroundColor,
    this.bottomInsetBackgroundColor,
    this.topInsetEnabled = true,
    this.bottomInsetEnabled = true,
    this.leftInsetEnabled = true,
    this.rightInsetEnabled = true,
    this.windowTheme = WindowTheme.translucent,
    this.orientation = Orientation.portrait,
    this.navigationBarColor,
    this.navigationBarIconType,
  }) : super(key: key);

  /// 기본 생성 factory
  factory ScaffoldBase({
    Key? key,
    Color backgroundColor = Colors.white,
    Color? topInsetBackgroundColor,
    Color? bottomInsetBackgroundColor,
    bool topInsetEnabled = false,
    bool bottomInsetEnabled = false,
    bool leftInsetEnabled = true,
    bool rightInsetEnabled = true,
    WindowTheme windowTheme = WindowTheme.translucent,
    Orientation? orientation = Orientation.portrait,
    Color? navigationBarColor,
    NavigationBarIconType? navigationBarIconType,
    PreferredSizeWidget? appBar,
    Widget? body,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    FloatingActionButtonAnimator? floatingActionButtonAnimator,
    List<Widget>? persistentFooterButtons,
    Widget? drawer,
    DrawerCallback? onDrawerChanged,
    Widget? endDrawer,
    DrawerCallback? onEndDrawerChanged,
    Widget? bottomNavigationBar,
    Widget? bottomSheet,
    bool? resizeToAvoidBottomInset,
    bool primary = true,
    DragStartBehavior drawerDragStartBehavior = DragStartBehavior.start,
    bool extendBody = false,
    bool extendBodyBehindAppBar = false,
    Color? drawerScrimColor,
    double? drawerEdgeDragWidth,
    bool drawerEnableOpenDragGesture = true,
    bool endDrawerEnableOpenDragGesture = true,
    String? restorationId,
  }) {
    final scaffold = Scaffold(
      key: key,
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      persistentFooterButtons: persistentFooterButtons,
      drawer: drawer,
      onDrawerChanged: onDrawerChanged,
      endDrawer: endDrawer,
      onEndDrawerChanged: onEndDrawerChanged,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      primary: primary,
      drawerDragStartBehavior: drawerDragStartBehavior,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      drawerScrimColor: drawerScrimColor,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
      restorationId: restorationId,
    );
    return ScaffoldBase._(
      key: key,
      backgroundColor: backgroundColor,
      topInsetBackgroundColor: topInsetBackgroundColor,
      bottomInsetBackgroundColor: bottomInsetBackgroundColor,
      topInsetEnabled: topInsetEnabled,
      bottomInsetEnabled: bottomInsetEnabled,
      leftInsetEnabled: leftInsetEnabled,
      rightInsetEnabled: rightInsetEnabled,
      windowTheme: windowTheme,
      orientation: orientation,
      navigationBarColor: navigationBarColor,
      navigationBarIconType: navigationBarIconType,
      builder: (context) => scaffold,
    );
  }

  /// 표시 자식 위젯
  final WidgetBuilder builder;

  /// 배경 색상
  final Color? backgroundColor;

  /// 상단 여백 배경 색상
  ///
  /// [topInsetEnabled]이 `true`일 경우에 표시되는 색상
  /// 값 지정이 없을 경우 [backgroundColor]가 표시됨
  final Color? topInsetBackgroundColor;

  /// 하단 여백 배경 색상
  ///
  /// [bottomInsetEnabled]이 `true`일 경우에 표시되는 색상
  /// 값 지정이 없을 경우 [backgroundColor]가 표시됨
  final Color? bottomInsetBackgroundColor;

  /// 시스템 여백 표시 설정
  final bool topInsetEnabled,
      bottomInsetEnabled,
      leftInsetEnabled,
      rightInsetEnabled;

  /// 테마 설정
  final WindowTheme windowTheme;

  /// 화면 방향
  final Orientation? orientation;

  /// 안드로이드 내비게이션바 색상
  final Color? navigationBarColor;

  /// 안드로이드 내비게이션바 아이콘 타입
  final NavigationBarIconType? navigationBarIconType;

  /// [windowOrientation] 적용
  void _applyTheme() {
    if (windowTheme == WindowTheme.fullscreen) {
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

  /// [windowTheme] 적용
  void _applyScreenOrientation() {
    if (orientation == null) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else if (orientation == Orientation.portrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else if (orientation == Orientation.landscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  /// 상단바 아이콘 색상 설정 반환
  Brightness _getStatusBarIconBrightness(BuildContext context) {
    return windowTheme == WindowTheme.translucent
        ? Platform.isIOS
            ? Brightness.dark
            : Brightness.light
        : windowTheme == WindowTheme.darkIcon
            ? Platform.isIOS
                ? Brightness.light
                : Brightness.dark
            : Platform.isIOS
                ? Brightness.dark
                : Brightness.light;
  }

  /// 내비게이션바 아이콘 밝기 설정 반환
  Brightness _getNavigationBarIconBrightness(BuildContext context) {
    if (navigationBarIconType == null) {
      return Brightness.light;
    }
    return navigationBarIconType == NavigationBarIconType.darkIcon
        ? Platform.isIOS
            ? Brightness.light
            : Brightness.dark
        : Platform.isIOS
            ? Brightness.dark
            : Brightness.light;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _setupAndroidVersion(),
      builder: (_, __) {
        if (_androidVersion == -1) {
          return Container(color: backgroundColor);
        }

        final mediaQuery = MediaQuery.of(context);

        _applyScreenOrientation();
        _applyTheme();

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: _getStatusBarIconBrightness(context),
            statusBarIconBrightness: _getStatusBarIconBrightness(context),
            systemNavigationBarColor: _hasGestureBar(context)
                ? Colors.transparent
                : navigationBarColor ?? Colors.black,
            systemNavigationBarIconBrightness:
                _getNavigationBarIconBrightness(context),
          ),
          child: FocusDetector(
            onFocusGained: () {
              _applyScreenOrientation();
              _applyTheme();
            },
            child: Container(
              color: backgroundColor,
              child: Stack(
                children: [
                  SafeArea(
                    top: topInsetEnabled,
                    left: leftInsetEnabled,
                    right: rightInsetEnabled,
                    bottom: _hasGestureBar(context) ? bottomInsetEnabled : true,
                    child: builder(context),
                  ),
                  Visibility(
                    visible: topInsetEnabled,
                    child: Container(
                      color: topInsetBackgroundColor ?? backgroundColor,
                      height: mediaQuery.padding.top,
                    ),
                  ),
                  Visibility(
                    visible: windowTheme == WindowTheme.translucent &&
                        _androidVersion >= 23,
                    child: Container(
                      color: Colors.black.withAlpha((0.2 * 0xff).toInt()),
                      height: mediaQuery.padding.top,
                    ),
                  ),
                  Visibility(
                    visible: _hasGestureBar(context) && bottomInsetEnabled,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        color: bottomInsetBackgroundColor ?? backgroundColor,
                        height: mediaQuery.padding.bottom,
                      ),
                    ),
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
          ),
        );
      },
    );
  }
}

/// 테마 설정
enum WindowTheme {
  /// 투명 상태바 + 상태바 검정색 아이콘
  darkIcon,

  /// 투명 상태바 + 상태바 하얀색 아이콘
  lightIcon,

  /// 반투명 상태바
  translucent,

  /// 전체화면
  fullscreen,
}

/// 안드로이드 내비게이션바 아이콘 밝기 타입
enum NavigationBarIconType {
  /// 검정색 아이콘
  darkIcon,

  /// 하얀색 아이콘
  lightIcon,
}
