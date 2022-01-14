import 'dart:developer';

/// `dispose()` 메소드가 있는 객체 처리용 클래스
///
/// [disposeAll]로 추가된 객체에 있는 `dispose()` 메소드를 일괄적으로 실행함
class CompositeDisposable {
  final _disposables = [];

  void addDisposable(dynamic disposable) {
    _disposables.add(disposable);
  }

  void disposeAll() {
    for (final disposable in _disposables) {
      try {
        disposable.dispose();
        log('${disposable.runtimeType} disposed.');
      } catch (e) {
        // ignored
      }
    }
    _disposables.clear();
  }
}

/// 미리 구현된 [CompositeDisposable]
mixin CompositeDisposableMixin on Object {
  final disposables = CompositeDisposable();

  void addDisposable(dynamic disposable) {
    disposables.addDisposable(disposable);
  }

  void disposeAll() {
    disposables.disposeAll();
  }
}

extension CompositeDisposableExtension on dynamic {
  void disposable(CompositeDisposableMixin autoDisposeMixin) {
    autoDisposeMixin.addDisposable(this);
  }
}
