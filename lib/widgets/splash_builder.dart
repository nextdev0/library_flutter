import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 스플래시 빌더 타입
typedef SplashWidgetBuilder = Widget Function(bool isReady);

/// 스플래시 빌더
class SplashBuilder extends StatefulWidget {
  const SplashBuilder({
    Key? key,
    this.readyDuration,
    this.duration,
    required this.builder,
    this.onSplashStart,
    required this.onSplashEnd,
  }) : super(key: key);

  /// 스플래시 준비 지연 시간
  final Duration? readyDuration;

  /// 스플래시 지연 시간
  final Duration? duration;

  /// 빌더
  final SplashWidgetBuilder builder;

  /// 스플래시 시작 콜백
  final VoidCallback? onSplashStart;

  /// 스플래시 종료 콜백
  final VoidCallback onSplashEnd;

  @override
  _SplashBuilderState createState() => _SplashBuilderState();
}

class _SplashBuilderState extends State<SplashBuilder> {
  bool isReady = false;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance!.addPostFrameCallback((_) async {
      setState(() => isReady = false);

      await Future.delayed(
        widget.readyDuration ?? const Duration(milliseconds: 250),
      );

      if (widget.onSplashStart != null) {
        widget.onSplashStart!();
      }

      setState(() => isReady = true);

      await Future.delayed(
        widget.duration ?? const Duration(milliseconds: 2000),
      );

      widget.onSplashEnd();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(isReady);
  }
}
