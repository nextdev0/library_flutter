import 'package:nextstory/foundation/navigator_change_notifier.dart';
import 'package:nextstory/widgets/simple_route.dart';
import 'package:nextstory_example/pages/home.dart';

class AppRoutes extends NavigatorChangeNotifier {
  SimpleRoute get home {
    return SimpleRoute(
      popGestureEnabled: false,
      page: (_) => const HomePage(),
    );
  }
}
