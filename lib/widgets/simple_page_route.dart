import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

const double _kBackGestureWidth = 20.0;
const double _kMinFlingVelocity = 1.0;

/// 전환 효과 빌더
typedef SimplePageRouteTransitionBuilder = Widget Function(
  BuildContext context,
  Animation<double> animation,
  Widget child,
);

/// 간단히 구현하기 위한 [Route]
class SimplePageRoute<T> extends PageRoute<T> {
  SimplePageRoute({
    RouteSettings? settings,
    this.usingCupertinoTransition = false,
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
    final defaultDuration = (Platform.isIOS || usingCupertinoTransition)
        ? const Duration(milliseconds: 500)
        : const Duration(milliseconds: 300);
    _transitionDuration = transitionDuration ?? defaultDuration;
    _reverseTransitionDuration = reverseTransitionDuration ?? defaultDuration;
  }

  /// 현재 설정을 복사하여 새 인스턴스 생성
  SimplePageRoute<T> copyWith({
    RouteSettings? settings,
    bool? usingCupertinoTransition,
    bool? popGestureEnabled,
    double? popGestureDragRange,
    WidgetBuilder? page,
    SimplePageRouteTransitionBuilder? transition,
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
      usingCupertinoTransition:
          usingCupertinoTransition ?? this.usingCupertinoTransition,
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

  /// 강제 iOS 전환 효과 사용
  ///
  /// [transition]가 지정되지 않았을때 기본 iOS 전환 스타일 사용
  final bool usingCupertinoTransition;

  /// 페이지 빌더
  final WidgetBuilder page;

  /// 전환 효과 빌더
  final SimplePageRouteTransitionBuilder? transition;

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
    return nextRoute is SimplePageRoute &&
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
    if (Platform.isIOS || usingCupertinoTransition) {
      return _buildCupertinoTransition(
        context,
        animation,
        secondaryAnimation,
        popGestureEnabled
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
                  if (!popGestureEnabled) {
                    return false;
                  }
                  if (this.animation!.status != AnimationStatus.completed) {
                    return false;
                  }
                  if (this.secondaryAnimation!.status !=
                      AnimationStatus.dismissed) {
                    return false;
                  }
                  if (isPopGestureInProgress(this)) {
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
      return SlideTransition(
        position: CurvedAnimation(
          parent: secondaryAnimation,
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
            parent: secondaryAnimation,
            curve: Curves.linearToEaseOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
          ).drive(
            Tween<double>(
              begin: 1.0,
              end: 0.75,
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

    return SlideTransition(
      position: CurvedAnimation(
        parent: secondaryAnimation,
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
          parent: secondaryAnimation,
          curve: Curves.linearToEaseOut,
          reverseCurve: Curves.fastLinearToSlowEaseIn,
        ).drive(
          Tween<double>(
            begin: 1.0,
            end: 0.75,
          ),
        ),
        child: SlideTransition(
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
        ),
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
