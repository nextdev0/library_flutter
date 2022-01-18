import 'package:nextstory/foundation/navigator_change_notifier.dart';
import 'package:nextstory/widgets/simple_page_route.dart';
import 'package:nextstory_example/pages/home.dart';

class AppRoutes extends NavigatorChangeNotifier {
  SimplePageRoute get home {
    return SimplePageRoute(
      popGestureEnabled: false,
      page: (_) => const HomePage(),
    );
  }
}
