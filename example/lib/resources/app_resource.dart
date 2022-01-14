import 'package:nextstory/foundation/system_change_notifier.dart';
import 'package:nextstory_example/resources/colors.dart';
import 'package:nextstory_example/resources/strings.dart';

class AppResources extends SystemChangeNotifier {
  late AppColor? _colors = AppColor(this);
  late AppString? _strings = AppString(this);

  AppResources();

  AppColor get colors => _colors!;

  AppString get strings => _strings!;

  @override
  void onSystemChanged() {
    super.onSystemChanged();

    _colors = AppColor(this);
    _strings = AppString(this);
  }

  @override
  void dispose() {
    _colors = null;
    _strings = null;

    super.dispose();
  }
}
