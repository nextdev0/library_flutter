import 'package:flutter/foundation.dart';

class SafeValueNotifier<T> extends ChangeNotifier
    implements ValueListenable<T> {
  bool _disposed = false;

  SafeValueNotifier(this._value) {
    if (kFlutterMemoryAllocationsEnabled) {
      ChangeNotifier.maybeDispatchObjectCreation(this);
    }
  }

  @override
  T get value => _value;
  T _value;

  set value(T newValue) {
    _value = newValue;
    notifyListeners();
  }

  void notify() {
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}
