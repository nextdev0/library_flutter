import 'package:nextstory/foundation/list_notifier.dart';

/// 항목 선택용 [ListNotifier]
class SelectionNotifier<T> extends ListNotifier<T> {
  var _selectedIndex = -1;

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  T? get selected {
    return _selectedIndex == -1 ? null : elementAtOrNull(_selectedIndex);
  }
}
