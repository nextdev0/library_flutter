// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:nextstory/exceptions/library_not_initialized.dart';
import 'package:nextstory/foundation/Selector.dart';
import 'package:nextstory/foundation/device.dart';
import 'package:nextstory/widgets/window_config.dart';

abstract final class Nextstory {
  static const methodChannel = MethodChannel('nextstory');
  static int _androidSdkVersion = -1;

  /// 안드로이드 SDK 버전 반환
  ///
  /// NOTE: 안드로이드를 제외한 플랫폼에서는 기본값을 반환합니다.
  static int get androidSdkVersion {
    if (Platform.isAndroid) {
      if (_androidSdkVersion == -1) {
        throw LibraryNotInitializedException();
      }
      return _androidSdkVersion;
    }
    return 30;
  }

  /// 미디어 스캔
  ///
  /// 안드로이드 전용 메소드
  static Future<void> mediaScan(File file) async {
    if (Platform.isAndroid) {
      await methodChannel.invokeMethod('mediaScan', {'path': file.path});
    }
  }

  /// 네이티브 로케일 적용
  ///
  /// [Selector]에서 로케일이 변경될 경우 내부적으로 해당 메소드가 호출됩니다.
  @protected
  static Future<void> applyNativeLocale(String locale) async {
    if (Platform.isIOS) {
      await methodChannel.invokeMethod(
        'applyNativeLocale',
        {'locale': locale},
      );
    }
  }
}

class LibraryInitializer extends StatefulWidget {
  const LibraryInitializer({
    super.key,
    required this.builder,
  });

  final WidgetBuilder builder;

  @override
  State createState() => _LibraryInitializerState();
}

class _LibraryInitializerState extends State<LibraryInitializer>
    with WidgetsBindingObserver {
  Widget? _childCache;

  SystemTheme? _pendingSystemTheme, _latestSystemTheme;
  SystemTheme? _pendingOrientationSystemTheme, _latestOrientationSystemTheme;

  @override
  void initState() {
    super.initState();

    // 일부 기기의 터치 문제를 해결
    if (Platform.isIOS) {
      Nextstory.methodChannel.invokeMethod('disableDelayTouchesBegan');
    }

    WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.instance.addPostFrameCallback(_updateSystemTheme);
  }

  @override
  void dispose() {
    _childCache = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(LibraryInitializer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.builder != oldWidget.builder) {
      _childCache = null;
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    Selector.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS || Nextstory._androidSdkVersion != -1) {
      return _childCache ??= widget.builder(context);
    }

    return FutureBuilder(
      future: Future.microtask(
        () async {
          final version = await Nextstory.methodChannel.invokeMethod(
            'getAndroidSdkVersion',
          );

          if (version != null) {
            Nextstory._androidSdkVersion = version;
          }
        },
      ),
      builder: (context, snapshot) {
        if (Nextstory._androidSdkVersion != -1 &&
            snapshot.connectionState == ConnectionState.done) {
          return _childCache ??= widget.builder(context);
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  void didChangePlatformBrightness() => Selector.reassemble();

  @override
  void didChangeLocales(List<Locale>? locales) => Selector.reassemble();

  void _updateSystemTheme(Duration timeStamp) {
    if (mounted) {
      final renderView = WidgetsBinding.instance.renderViews.first;
      final size = PlatformDispatcher.instance.views.first.physicalSize;
      final bounds = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
      final offset = Offset(bounds.center.dx, bounds.center.dy);

      final systemTheme = renderView.layer!.find<SystemTheme>(offset);
      if (systemTheme != null) {
        _applySystemTheme(systemTheme);
        _applyScreenOrientation(systemTheme);
      }

      SchedulerBinding.instance.addPostFrameCallback(_updateSystemTheme);
    }
  }

  Future<void> _applySystemTheme(SystemTheme systemTheme) async {
    if (_pendingSystemTheme != null) {
      _pendingSystemTheme = systemTheme;
      return;
    }

    if (systemTheme == _latestSystemTheme) {
      return;
    }

    _pendingSystemTheme = systemTheme;

    scheduleMicrotask(() {
      assert(_pendingSystemTheme != null);

      if (_pendingSystemTheme != _latestSystemTheme) {
        final systemTheme = _pendingSystemTheme!;
        Devices.currentSystemTheme = systemTheme;

        if (Platform.isIOS) {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarBrightness: systemTheme.statusDarkIcon
                  ? Brightness.light
                  : Brightness.dark,
            ),
          );
          SystemChrome.setEnabledSystemUIMode(
            systemTheme.fullscreen
                ? SystemUiMode.immersiveSticky
                : SystemUiMode.edgeToEdge,
            overlays: [
              SystemUiOverlay.top,
              SystemUiOverlay.bottom,
            ],
          );
        } else if (Platform.isAndroid) {
          Nextstory.methodChannel.invokeMethod(
            'applySystemTheme',
            {
              'fullscreen': systemTheme.fullscreen,
              'statusDarkIcon': systemTheme.statusDarkIcon,
              'navigationDarkIcon': systemTheme.navigationDarkIcon,
            },
          );
        }

        _latestSystemTheme = _pendingSystemTheme;
      }

      _pendingSystemTheme = null;
    });
  }

  Future<void> _applyScreenOrientation(SystemTheme systemTheme) async {
    if (systemTheme.orientation == ScreenOrientation.inherit &&
        systemTheme.inheritedOrientation == null) {
      systemTheme.orientation = _latestOrientationSystemTheme!.orientation;
      systemTheme.inheritedOrientation = systemTheme.orientation;
    }

    if (_pendingOrientationSystemTheme != null) {
      _pendingOrientationSystemTheme = systemTheme;
      return;
    }

    if (systemTheme == _latestOrientationSystemTheme) {
      return;
    }

    _pendingOrientationSystemTheme = systemTheme;

    scheduleMicrotask(() {
      assert(_pendingOrientationSystemTheme != null);

      if (_pendingOrientationSystemTheme != _latestOrientationSystemTheme) {
        final systemTheme = _pendingOrientationSystemTheme!;

        if (Platform.isIOS) {
          SystemChrome.setPreferredOrientations(
            _getScreenOrientation(systemTheme.orientation),
          );
        } else if (Platform.isAndroid) {
          Nextstory.methodChannel.invokeMethod(
            'applyScreenOrientation',
            {
              'orientations': _getScreenOrientation(systemTheme.orientation)
                  .map(
                    (e) => e.toString(),
                  )
                  .toList(),
            },
          );
        }

        _latestOrientationSystemTheme = _pendingOrientationSystemTheme;
      }

      _pendingOrientationSystemTheme = null;
    });
  }

  List<DeviceOrientation> _getScreenOrientation(ScreenOrientation orientation) {
    return orientation == ScreenOrientation.unspecified
        ? [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]
        : orientation == ScreenOrientation.portrait
            ? [
                DeviceOrientation.portraitUp,
                DeviceOrientation.portraitDown,
              ]
            : [
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ];
  }
}
