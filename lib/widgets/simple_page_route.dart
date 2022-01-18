import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

const bool _kIOSDebug = false;
const double _kBackGestureWidth = 20.0;
const double _kMinFlingVelocity = 1.0;
const Animation<double> kAlwaysDismissedAnimation = _AlwaysDismissedAnimation();

/// 전환 효과 빌더
typedef SimplePageRouteTransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Widget child,
);

/// 간단 구현용 [PageRoute]
class SimplePageRoute<T> extends PageRoute<T> {
  SimplePageRoute({
    RouteSettings? settings,
    bool fullscreenDialog = false,
    this.popGestureDragRange = 1.0,
    required this.page,
    SimplePageRouteTransitionBuilder? transition,
    SimplePageRouteTransitionBuilder? previousPopTransition,
    SimplePageRouteTransitionBuilder? fullscreenDialogTransition,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    this.opaque = true,
    this.barrierDismissible = false,
    this.barrierColor,
    this.barrierLabel,
    this.maintainState = true,
  }) : super(settings: settings, fullscreenDialog: fullscreenDialog) {
    _transitionDuration = transitionDuration;
    _reverseTransitionDuration = reverseTransitionDuration;

    if (transition == null) {
      if (Platform.isIOS || _kIOSDebug) {
        this.transition = (context, animation, child) {
          final linearTransition = Navigator.of(context).userGestureInProgress;
          final textDirection = Directionality.of(context);
          return SlideTransition(
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
            child: DecoratedBoxTransition(
              decoration: (linearTransition
                      ? animation
                      : CurvedAnimation(
                          parent: animation,
                          curve: Curves.linearToEaseOut,
                        ))
                  .drive(
                DecorationTween(
                  begin: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x00000000),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      )
                    ],
                  ),
                  end: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0f000000),
                        blurRadius: 24.0,
                        spreadRadius: 8.0,
                      )
                    ],
                  ),
                ),
              ),
              child: child,
            ),
          );
        };
      } else {
        this.transition = (_, animation, child) {
          return SlideTransition(
            position: CurvedAnimation(
              parent: animation,
              curve: Curves.linearToEaseOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
            ).drive(
              Tween<Offset>(
                begin: const Offset(0.0, 0.4),
                end: const Offset(0.0, 0.0),
              ),
            ),
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.linearToEaseOut,
                reverseCurve: Curves.fastLinearToSlowEaseIn,
              ).drive(
                Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ),
              ),
              child: child,
            ),
          );
        };
      }
    } else {
      this.transition = transition;
    }

    if (previousPopTransition == null) {
      if (Platform.isIOS || _kIOSDebug) {
        this.previousPopTransition = (context, animation, child) {
          final linearTransition = Navigator.of(context).userGestureInProgress;
          final textDirection = Directionality.of(context);
          return SlideTransition(
            position: (linearTransition
                    ? animation
                    : CurvedAnimation(
                        parent: animation,
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
                      ? animation
                      : CurvedAnimation(
                          parent: animation,
                          curve: Curves.linearToEaseOut,
                          reverseCurve: Curves.easeInToLinear,
                        ))
                  .drive(
                Tween<double>(
                  begin: 1.0,
                  end: 0.9,
                ),
              ),
              child: child,
            ),
          );
        };
      } else {
        this.previousPopTransition = (_, animation, child) {
          return SlideTransition(
            position: CurvedAnimation(
              parent: animation,
              curve: Curves.linearToEaseOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
            ).drive(
              Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(0.0, -0.025),
              ),
            ),
            transformHitTests: false,
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.linearToEaseOut,
                reverseCurve: Curves.fastLinearToSlowEaseIn,
              ).drive(
                Tween<double>(
                  begin: 1.0,
                  end: 0.75,
                ),
              ),
              child: child,
            ),
          );
        };
      }
    } else {
      this.previousPopTransition = previousPopTransition;
    }

    if (fullscreenDialogTransition == null) {
      if (Platform.isIOS || _kIOSDebug) {
        this.fullscreenDialogTransition =
            (_, animation, child) => SlideTransition(
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
                );
      } else {
        this.fullscreenDialogTransition = (_, __, child) => child;
      }
    } else {
      this.fullscreenDialogTransition = fullscreenDialogTransition;
    }
  }

  /// 현재 설정을 복사하여 새 인스턴스 생성
  SimplePageRoute<T> copyWith({
    RouteSettings? settings,
    bool? fullscreenDialog,
    bool? usingCupertinoTransition,
    double? popGestureDragRange,
    WidgetBuilder? page,
    SimplePageRouteTransitionBuilder? transition,
    SimplePageRouteTransitionBuilder? previousPopTransition,
    SimplePageRouteTransitionBuilder? fullscreenDialogTransition,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    bool? opaque,
    bool? barrierDismissible,
    Color? barrierColor,
    String? barrierLabel,
    bool? maintainState,
  }) {
    return SimplePageRoute(
      settings: settings ?? this.settings,
      fullscreenDialog: fullscreenDialog ?? this.fullscreenDialog,
      popGestureDragRange: popGestureDragRange ?? this.popGestureDragRange,
      page: page ?? this.page,
      transition: transition ?? this.transition,
      previousPopTransition:
          previousPopTransition ?? this.previousPopTransition,
      fullscreenDialogTransition:
          fullscreenDialogTransition ?? this.fullscreenDialogTransition,
      transitionDuration: transitionDuration ?? _transitionDuration,
      reverseTransitionDuration:
          reverseTransitionDuration ?? _reverseTransitionDuration,
      opaque: opaque ?? this.opaque,
      barrierDismissible: barrierDismissible ?? this.barrierDismissible,
      barrierColor: barrierColor ?? this.barrierColor,
      barrierLabel: barrierLabel ?? this.barrierLabel,
      maintainState: maintainState ?? this.maintainState,
    );
  }

  /// 페이지 빌더
  final WidgetBuilder page;

  /// 전환 효과 빌더
  late final SimplePageRouteTransitionBuilder transition;

  /// 이전 페이지에 적용될 전환 효과 빌더
  late final SimplePageRouteTransitionBuilder previousPopTransition;

  /// [fullscreenDialog] 전환 효과 빌더
  late final SimplePageRouteTransitionBuilder fullscreenDialogTransition;

  /// iOS 뒤로가기 제스처 동작 가능 범위
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
  Duration get transitionDuration {
    if (_transitionDuration == null) {
      return (Platform.isIOS || _kIOSDebug)
          ? const Duration(milliseconds: 500)
          : const Duration(milliseconds: 300);
    }
    return _transitionDuration!;
  }

  @override
  Duration get reverseTransitionDuration {
    if (_reverseTransitionDuration == null) {
      return (Platform.isIOS || _kIOSDebug)
          ? const Duration(milliseconds: 500)
          : const Duration(milliseconds: 300);
    }
    return _reverseTransitionDuration!;
  }

  Widget? _buildPageCache;
  Duration? _transitionDuration, _reverseTransitionDuration;
  SimplePageRouteTransitionBuilder? _nextRouteSecondaryTransition;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    if (nextRoute is SimplePageRoute) {
      if (!((Platform.isIOS || _kIOSDebug) && nextRoute.fullscreenDialog)) {
        _nextRouteSecondaryTransition = nextRoute.previousPopTransition;
        return true;
      }
    }
    _nextRouteSecondaryTransition = null;
    return false;
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
    final cupertinoGestureChild =
        ((Platform.isIOS || _kIOSDebug) && !fullscreenDialog)
            ? _CupertinoBackGestureDetector<T>(
                popGestureDragRange: popGestureDragRange,
                enabledCallback: () {
                  if (isFirst) {
                    return false;
                  }
                  if (willHandlePopInternally) {
                    return false;
                  }
                  if (hasScopedWillPopCallback) {
                    return false;
                  }
                  if (fullscreenDialog) {
                    return false;
                  }
                  if (this.animation!.status != AnimationStatus.completed) {
                    return false;
                  }
                  if (this.secondaryAnimation!.status !=
                      AnimationStatus.dismissed) {
                    return false;
                  }
                  if (Navigator.of(context).userGestureInProgress) {
                    return false;
                  }
                  return true;
                },
                onStartPopGesture: () => _CupertinoBackGestureController<T>(
                  navigator: navigator!,
                  controller: controller!,
                  transitionDuration: transitionDuration,
                  reverseTranstionDuration: reverseTransitionDuration,
                ),
                child: child,
              )
            : child;

    final proxyChild = (_nextRouteSecondaryTransition != null)
        ? _nextRouteSecondaryTransition!(
            context,
            secondaryAnimation,
            cupertinoGestureChild,
          )
        : cupertinoGestureChild;

    if ((Platform.isIOS || _kIOSDebug) && fullscreenDialog) {
      return fullscreenDialogTransition(
        context,
        animation,
        proxyChild,
      );
    } else {
      return transition(
        context,
        animation,
        proxyChild,
      );
    }
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
    _nextRouteSecondaryTransition = null;
    super.dispose();
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

    _recognizer = HorizontalDragGestureRecognizer()
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
    _backGestureController = widget.onStartPopGesture();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (_backGestureController != null) {
      if (_backGestureController!.controller.value >
          1.0 - (widget.popGestureDragRange ?? 1.0)) {
        _backGestureController!.dragUpdate(
          _convertToLogical(
            details.primaryDelta! / context.size!.width,
          ),
        );
      } else {
        _backGestureController?.dragEnd(1.0);
        _backGestureController = null;
      }
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    _backGestureController?.dragEnd(
      _convertToLogical(
        details.velocity.pixelsPerSecond.dx / context.size!.width,
      ),
    );
    _backGestureController = null;
  }

  void _handleDragCancel() {
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
    required this.transitionDuration,
    required this.reverseTranstionDuration,
  }) {
    navigator.didStartUserGesture();
  }

  final AnimationController controller;
  final NavigatorState navigator;
  final Duration transitionDuration, reverseTranstionDuration;

  void dragUpdate(double delta) {
    controller.value -= delta;
  }

  void dragEnd(double velocity) {
    final bool animateForward;

    if (velocity.abs() >= _kMinFlingVelocity) {
      animateForward = velocity <= 0;
    } else {
      animateForward = controller.value > 0.5;
    }

    if (animateForward) {
      controller.animateTo(
        1.0,
        duration: transitionDuration * 0.5,
        curve: Curves.linearToEaseOut,
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
      controller.animateTo(
        0.0,
        duration: transitionDuration * 0.5,
        curve: Curves.linearToEaseOut,
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

class _AlwaysDismissedAnimation extends Animation<double> {
  const _AlwaysDismissedAnimation();

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  void addStatusListener(AnimationStatusListener listener) {}

  @override
  void removeStatusListener(AnimationStatusListener listener) {}

  @override
  AnimationStatus get status => AnimationStatus.dismissed;

  @override
  double get value => 0.0;

  @override
  String toString() => 'kAlwaysDismissedAnimation';
}
