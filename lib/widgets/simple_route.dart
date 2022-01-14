import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

const double _kBackGestureWidth = 20.0;
const double _kMinFlingVelocity = 1.0;
const int _kMaxDroppedSwipePageForwardAnimationTime = 800;
const int _kMaxPageBackAnimationTime = 300;

/// 전환 효과 빌더
typedef PopGesturePageTransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Widget child,
);

/// 간단히 구현하기 위한 [Route]
class SimpleRoute<T> extends PageRoute<T> {
  static bool iosTestEnabled = false;
  static final Duration _defaultTransitionDuration =
      (Platform.isIOS || iosTestEnabled)
          ? const Duration(milliseconds: 400)
          : const Duration(milliseconds: 300);

  SimpleRoute({
    RouteSettings? settings,
    this.popGestureEnabled = true,
    this.popGestureDragRange = 1.0,
    required this.page,
    this.transition,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    this.opaque = true,
    this.barrierDismissible = false,
    this.barrierColor,
    this.barrierLabel,
    this.maintainState = true,
  }) : super(settings: settings, fullscreenDialog: !popGestureEnabled) {
    _transitionDuration = transitionDuration ?? _defaultTransitionDuration;
    _reverseTransitionDuration =
        reverseTransitionDuration ?? _defaultTransitionDuration;
  }

  /// 현재 설정을 복사하여 새 인스턴스 생성
  SimpleRoute<T> copyWith({
    RouteSettings? settings,
    bool? popGestureEnabled,
    double? popGestureDragRange,
    WidgetBuilder? page,
    PopGesturePageTransitionBuilder? transition,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    bool? opaque,
    bool? barrierDismissible,
    Color? barrierColor,
    String? barrierLabel,
    bool? maintainState,
  }) {
    return SimpleRoute(
      settings: settings ?? this.settings,
      popGestureEnabled: popGestureEnabled ?? this.popGestureEnabled,
      popGestureDragRange: popGestureDragRange ?? this.popGestureDragRange,
      page: page ?? this.page,
      transition: transition ?? this.transition,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      reverseTransitionDuration:
          reverseTransitionDuration ?? this.reverseTransitionDuration,
      opaque: opaque ?? this.opaque,
      barrierDismissible: barrierDismissible ?? this.barrierDismissible,
      barrierColor: barrierColor ?? this.barrierColor,
      barrierLabel: barrierLabel ?? this.barrierLabel,
      maintainState: maintainState ?? this.maintainState,
    );
  }

  /// 위젯 캐시
  Widget? _buildPageCache;

  /// 화면 전환 효과 지연시간
  late Duration _transitionDuration, _reverseTransitionDuration;

  /// 뒤로가기 제스처 사용 유무
  final bool popGestureEnabled;

  /// 페이지 빌더
  final WidgetBuilder page;

  /// 전환 효과 빌더
  final PopGesturePageTransitionBuilder? transition;

  /// 뒤로가기 제스처 동작 가능 범위
  ///
  /// 0.0 ~ 1.0 범위로 지정
  final double? popGestureDragRange;

  @override
  bool opaque;

  @override
  bool barrierDismissible;

  @override
  Color? barrierColor;

  @override
  String? barrierLabel;

  @override
  bool maintainState;

  @override
  Duration get transitionDuration => _transitionDuration;

  @override
  Duration get reverseTransitionDuration => _reverseTransitionDuration;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    return nextRoute is SimpleRoute &&
        nextRoute.transition == null &&
        nextRoute.popGestureEnabled;
  }

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) {
    return true;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (Platform.isIOS || iosTestEnabled) {
      return _buildCupertinoTransition(
        context,
        animation,
        secondaryAnimation,
        popGestureEnabled
            ? _CupertinoBackGestureDetector<T>(
                popGestureDragRange: popGestureDragRange,
                enabledCallback: () => _isPopGestureEnabled(this),
                onStartPopGesture: () => _startPopGesture(this),
                child: child,
              )
            : child,
      );
    }
    return _buildMaterialTransition(
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }

  Widget _buildCupertinoTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final bool linearTransition = isPopGestureInProgress(this);
    final TextDirection textDirection = Directionality.of(context);

    if (transition != null) {
      return SlideTransition(
        position: (linearTransition
                ? secondaryAnimation
                : CurvedAnimation(
                    parent: secondaryAnimation,
                    curve: Curves.linearToEaseOut,
                    reverseCurve: Curves.easeInToLinear,
                  ))
            .drive(
          Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-1.0 / 3.0, 0.0),
          ),
        ),
        textDirection: textDirection,
        transformHitTests: false,
        child: FadeTransition(
          opacity: (linearTransition
                  ? secondaryAnimation
                  : CurvedAnimation(
                      parent: secondaryAnimation,
                      curve: Curves.linearToEaseOut,
                      reverseCurve: Curves.easeInToLinear,
                    ))
              .drive(
            Tween<double>(
              begin: 1.0,
              end: 0.9,
            ),
          ),
          child: transition!(
            context,
            animation,
            child,
          ),
        ),
      );
    }

    if (!popGestureEnabled) {
      return SlideTransition(
        position: (linearTransition
                ? secondaryAnimation
                : CurvedAnimation(
                    parent: secondaryAnimation,
                    curve: Curves.linearToEaseOut,
                    reverseCurve: Curves.easeInToLinear,
                  ))
            .drive(
          Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-1.0 / 3.0, 0.0),
          ),
        ),
        textDirection: textDirection,
        transformHitTests: false,
        child: FadeTransition(
          opacity: (linearTransition
                  ? secondaryAnimation
                  : CurvedAnimation(
                      parent: secondaryAnimation,
                      curve: Curves.linearToEaseOut,
                      reverseCurve: Curves.easeInToLinear,
                    ))
              .drive(
            Tween<double>(
              begin: 1.0,
              end: 0.9,
            ),
          ),
          child: SlideTransition(
            position: CurvedAnimation(
              parent: animation,
              curve: Curves.linearToEaseOut,
              reverseCurve: Curves.easeInToLinear,
            ).drive(
              Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ),
            ),
            transformHitTests: false,
            child: child,
          ),
        ),
      );
    }
    return SlideTransition(
      position: (linearTransition
              ? secondaryAnimation
              : CurvedAnimation(
                  parent: secondaryAnimation,
                  curve: Curves.linearToEaseOut,
                  reverseCurve: Curves.easeInToLinear,
                ))
          .drive(
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-1.0 / 3.0, 0.0),
        ),
      ),
      textDirection: textDirection,
      transformHitTests: false,
      child: FadeTransition(
        opacity: (linearTransition
                ? secondaryAnimation
                : CurvedAnimation(
                    parent: secondaryAnimation,
                    curve: Curves.linearToEaseOut,
                    reverseCurve: Curves.easeInToLinear,
                  ))
            .drive(
          Tween<double>(
            begin: 1.0,
            end: 0.9,
          ),
        ),
        child: SlideTransition(
          position: (linearTransition
                  ? animation
                  : CurvedAnimation(
                      parent: animation,
                      curve: Curves.linearToEaseOut,
                      reverseCurve: Curves.easeInToLinear,
                    ))
              .drive(
            Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ),
          ),
          textDirection: textDirection,
          child: child,
        ),
      ),
    );
  }

  Widget _buildMaterialTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (transition != null) {
      return transition!(
        context,
        animation,
        child,
      );
    }

    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: const Offset(0.0, 0.25),
          end: Offset.zero,
        ).chain(
          CurveTween(curve: Curves.fastOutSlowIn),
        ),
      ),
      child: FadeTransition(
        opacity: animation.drive(CurveTween(curve: Curves.easeIn)),
        child: child,
      ),
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _buildPageCache ??= Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: page(context),
    );
  }

  @override
  void dispose() {
    _buildPageCache = null;
    super.dispose();
  }

  static bool isPopGestureInProgress(Route<dynamic> route) {
    return route.navigator!.userGestureInProgress;
  }

  static bool _isPopGestureEnabled<T>(SimpleRoute<T> route) {
    if (route.isFirst) return false;
    if (route.willHandlePopInternally) return false;
    if (route.hasScopedWillPopCallback) return false;
    if (!route.popGestureEnabled) return false;
    if (route.animation!.status != AnimationStatus.completed) return false;
    if (route.secondaryAnimation!.status != AnimationStatus.dismissed) {
      return false;
    }
    if (isPopGestureInProgress(route)) return false;
    return true;
  }

  static _CupertinoBackGestureController<T> _startPopGesture<T>(
    SimpleRoute<T> route,
  ) {
    assert(_isPopGestureEnabled(route));
    return _CupertinoBackGestureController<T>(
      navigator: route.navigator!,
      controller: route.controller!,
    );
  }
}

class _CupertinoBackGestureDetector<T> extends StatefulWidget {
  const _CupertinoBackGestureDetector({
    Key? key,
    this.popGestureDragRange,
    required this.enabledCallback,
    required this.onStartPopGesture,
    required this.child,
  }) : super(key: key);

  final Widget child;

  final double? popGestureDragRange;

  final ValueGetter<bool> enabledCallback;

  final ValueGetter<_CupertinoBackGestureController<T>> onStartPopGesture;

  @override
  _CupertinoBackGestureDetectorState<T> createState() =>
      _CupertinoBackGestureDetectorState<T>();
}

class _CupertinoBackGestureDetectorState<T>
    extends State<_CupertinoBackGestureDetector<T>> {
  _CupertinoBackGestureController<T>? _backGestureController;

  late HorizontalDragGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = HorizontalDragGestureRecognizer(debugOwner: this)
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    assert(mounted);
    assert(_backGestureController == null);
    _backGestureController = widget.onStartPopGesture();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(mounted);

    if (_backGestureController != null) {
      if (_backGestureController!.controller.value >
          1.0 - (widget.popGestureDragRange ?? 1.0)) {
        _backGestureController!.dragUpdate(
            _convertToLogical(details.primaryDelta! / context.size!.width));
      } else {
        _backGestureController?.dragEnd(1.0);
        _backGestureController = null;
      }
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    assert(mounted);
    _backGestureController?.dragEnd(_convertToLogical(
        details.velocity.pixelsPerSecond.dx / context.size!.width));
    _backGestureController = null;
  }

  void _handleDragCancel() {
    assert(mounted);
    _backGestureController?.dragEnd(0.0);
    _backGestureController = null;
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.enabledCallback()) {
      _recognizer.addPointer(event);
    }
  }

  double _convertToLogical(double value) {
    switch (Directionality.of(context)) {
      case TextDirection.rtl:
        return -value;
      case TextDirection.ltr:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    double dragAreaWidth = Directionality.of(context) == TextDirection.ltr
        ? MediaQuery.of(context).padding.left
        : MediaQuery.of(context).padding.right;
    dragAreaWidth = max(dragAreaWidth, _kBackGestureWidth);
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        widget.child,
        PositionedDirectional(
          start: 0.0,
          width: dragAreaWidth,
          top: 0.0,
          bottom: 0.0,
          child: Listener(
            onPointerDown: _handlePointerDown,
            behavior: HitTestBehavior.translucent,
          ),
        ),
      ],
    );
  }
}

class _CupertinoBackGestureController<T> {
  _CupertinoBackGestureController({
    required this.navigator,
    required this.controller,
  }) {
    navigator.didStartUserGesture();
  }

  final AnimationController controller;
  final NavigatorState navigator;

  void dragUpdate(double delta) {
    controller.value -= delta;
  }

  void dragEnd(double velocity) {
    const Curve animationCurve = Curves.fastLinearToSlowEaseIn;
    final bool animateForward;

    if (velocity.abs() >= _kMinFlingVelocity) {
      animateForward = velocity <= 0;
    } else {
      animateForward = controller.value > 0.5;
    }

    if (animateForward) {
      final int droppedPageForwardAnimationTime = min(
        lerpDouble(
                _kMaxDroppedSwipePageForwardAnimationTime, 0, controller.value)!
            .floor(),
        _kMaxPageBackAnimationTime,
      );
      controller.animateTo(
        1.0,
        duration: Duration(milliseconds: droppedPageForwardAnimationTime),
        curve: animationCurve,
      );
      if (controller.isAnimating) {
        late AnimationStatusListener animationStatusCallback;
        animationStatusCallback = (AnimationStatus status) {
          navigator.didStopUserGesture();
          controller.removeStatusListener(animationStatusCallback);
        };
        controller.addStatusListener(animationStatusCallback);
      } else {
        navigator.didStopUserGesture();
      }
    } else {
      final int droppedPageBackAnimationTime = lerpDouble(
              0, _kMaxDroppedSwipePageForwardAnimationTime, controller.value)!
          .floor();
      controller.animateTo(
        0.0,
        duration: Duration(milliseconds: droppedPageBackAnimationTime),
        curve: animationCurve,
      );
      if (controller.isAnimating) {
        late AnimationStatusListener animationStatusCallback;
        animationStatusCallback = (AnimationStatus status) {
          if (status != AnimationStatus.dismissed) {
            navigator.pop();
          }
          if (status != AnimationStatus.completed) {
            navigator.didStopUserGesture();
          }
          controller.removeStatusListener(animationStatusCallback);
        };
        controller.addStatusListener(animationStatusCallback);
      } else {
        navigator.pop();
        navigator.didStopUserGesture();
      }
    }
  }
}
