import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nextstory/foundation/navigator_change_notifier.dart';

/// [Route] 컨테이너
class RouteContainer extends StatelessWidget {
  const RouteContainer({
    Key? key,
    required this.navigatorKey,
    required this.initialRoute,
  }) : super(key: key);

  /// [NavigatorState]를 포함하는 [Key]
  final Key navigatorKey;

  /// 초기 표시 [Route]
  final Route initialRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Navigator(
        key: navigatorKey,
        initialRoute: '/',
        observers: [
          _Observer(navigatorKey is NavigatorStateKey
              ? navigatorKey as NavigatorStateKey
              : null)
        ],
        onGenerateRoute: (settings) => initialRoute,
      ),
    );
  }
}

class _Observer extends NavigatorObserver {
  final NavigatorStateKey? navigatorStateKey;

  _Observer(this.navigatorStateKey);

  void _notifyState() {
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      if (navigatorStateKey != null) {
        navigatorStateKey!.canPop.value = navigator!.canPop();
      }
    });
  }

  @override
  void didPush(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    _notifyState();
  }

  @override
  void didPop(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    _notifyState();
  }

  @override
  void didRemove(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    _notifyState();
  }

  @override
  void didReplace({
    Route<dynamic>? newRoute,
    Route<dynamic>? oldRoute,
  }) {
    _notifyState();
  }

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    _notifyState();
  }

  @override
  void didStopUserGesture() {
    _notifyState();
  }
}
