import 'package:flutter/widgets.dart';

mixin NavigatorMixin on Object {
  final _key = GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> get navigatorKey => _key;

  NavigatorState get navigator => _key.currentState!;
}
