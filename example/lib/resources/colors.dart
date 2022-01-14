import 'dart:ui';

import 'package:nextstory/foundation/system_change_notifier.dart';
import 'package:nextstory/widgets/scaffold_base.dart';

class AppColor {
  final SystemChangeNotifier systemChangeNotifier;

  AppColor(this.systemChangeNotifier);

  WindowTheme get darkIconTheme {
    return systemChangeNotifier.switchDarkMode(
      light: WindowTheme.darkIcon,
      dark: WindowTheme.lightIcon,
    );
  }

  WindowTheme get lightIconTheme {
    return systemChangeNotifier.switchDarkMode(
      light: WindowTheme.lightIcon,
      dark: WindowTheme.darkIcon,
    );
  }

  Color get appBackground {
    return systemChangeNotifier.switchDarkMode(
      light: const Color(0xffffffff),
      dark: const Color(0xff000000),
    );
  }

  Color get light {
    return systemChangeNotifier.switchDarkMode(
      light: const Color(0xffffffff),
      dark: const Color(0xff000000),
    );
  }

  Color get dark {
    return systemChangeNotifier.switchDarkMode(
      light: const Color(0xff000000),
      dark: const Color(0xffffffff),
    );
  }
}
