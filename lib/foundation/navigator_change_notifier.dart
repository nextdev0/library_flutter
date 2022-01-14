import 'package:flutter/widgets.dart';

class NavigatorChangeNotifier extends ChangeNotifier {
  final _key = NavigatorStateKey();

  NavigatorState get navigator => _key.currentState!;

  NavigatorStateKey get navigatorKey => _key;

  ValueNotifier<bool> get canPop => _key.canPop;

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }
}

class NavigatorStateKey extends GlobalKey<NavigatorState> {
  final canPop = ValueNotifier<bool>(true);

  NavigatorStateKey() : super.constructor();

  void dispose() {
    canPop.dispose();
  }
}
