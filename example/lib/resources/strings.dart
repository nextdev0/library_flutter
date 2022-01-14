import 'dart:ui';

import 'package:nextstory/foundation/system_change_notifier.dart';

class AppString {
  final SystemChangeNotifier systemChangeNotifier;
  final korean = const Locale('ko');
  final english = const Locale('en');

  AppString(this.systemChangeNotifier);
}
