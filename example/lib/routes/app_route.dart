import 'package:flutter/cupertino.dart';
import 'package:nextstory/foundation/navigator_mixin.dart';
import 'package:nextstory/widgets/simple_route.dart';
import 'package:nextstory_example/pages/home.dart';

class AppRoutes extends ChangeNotifier with NavigatorMixin {
  SimpleRoute get home {
    return SimpleRoute(
      popGestureEnabled: false,
      page: (_) => const HomePage(),
    );
  }
}
