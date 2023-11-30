import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Lifecycle extends StatefulWidget {
  const Lifecycle({
    super.key,
    this.onStateInit,
    this.onInit,
    this.onDispose,
    this.ondDidUpdateWidget,
    this.onResume,
    this.onPause,
    this.onForeground,
    this.onBackground,
    this.onVisibilityGained,
    this.onVisibilityLost,
    required this.child,
  });

  /// 위젯 수명주기 콜백
  final VoidCallback? onStateInit, onInit, onDispose, ondDidUpdateWidget;

  /// 앱의 백그라운드 또는 포그라운드 상태 콜백
  final VoidCallback? onForeground, onBackground;

  /// 위젯의 가시성이 변경될 때의 콜백
  final VoidCallback? onVisibilityGained, onVisibilityLost;

  /// [onForeground], [onVisibilityGained] 중 하나라도 호출될 때 같이 호출되는 콜백
  final VoidCallback? onResume;

  /// [onBackground], [onVisibilityLost] 중 하나라도 호출될 때 같이 호출되는 콜백
  final VoidCallback? onPause;

  final Widget child;

  @override
  State createState() => _LifecycleState();
}

class _LifecycleState extends State<Lifecycle> with WidgetsBindingObserver {
  final _visibilityDetectorKey = UniqueKey();
  bool _isWidgetVisible = false, _isAppInForeground = true;

  @override
  void initState() {
    super.initState();

    _invokeNullable(widget.onStateInit);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _invokeNullable(widget.onInit);
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _invokeNullable(widget.onDispose);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(Lifecycle oldWidget) {
    super.didUpdateWidget(oldWidget);
    _invokeNullable(widget.ondDidUpdateWidget);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visibilityDetectorKey,
      onVisibilityChanged: _onVisibilityChanged,
      child: widget.child,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isWidgetVisible || !mounted) {
      return;
    }

    final isAppResumed = state == AppLifecycleState.resumed;
    final wasResumed = _isAppInForeground;
    if (isAppResumed && !wasResumed) {
      _isAppInForeground = true;
      _invokeNullable(widget.onResume);
      _invokeNullable(widget.onForeground);
      return;
    }

    final isAppPaused = state == AppLifecycleState.paused;
    if (isAppPaused && wasResumed) {
      _isAppInForeground = false;
      _invokeNullable(widget.onPause);
      _invokeNullable(widget.onBackground);
    }
  }

  void _onVisibilityChanged(VisibilityInfo visibilityInfo) {
    final visibleFraction = visibilityInfo.visibleFraction;

    if (!_isAppInForeground || !mounted) {
      return;
    }

    final wasFullyVisible = _isWidgetVisible;
    final isFullyVisible = visibleFraction == 1;
    if (!wasFullyVisible && isFullyVisible) {
      _isWidgetVisible = true;
      _invokeNullable(widget.onResume);
      _invokeNullable(widget.onVisibilityGained);
    }

    final isFullyInvisible = visibleFraction == 0;
    if (wasFullyVisible && isFullyInvisible) {
      _isWidgetVisible = false;
      _invokeNullable(widget.onPause);
      _invokeNullable(widget.onVisibilityLost);
    }
  }

  void _invokeNullable(VoidCallback? callback) {
    if (callback != null) {
      callback();
    }
  }
}
