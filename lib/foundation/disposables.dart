import 'dart:developer';

import 'package:flutter/widgets.dart';

/// `dispose()` 메소드가 있는 객체 처리용 클래스
///
/// [disposeAll]로 추가된 객체에 있는 `dispose()` 메소드를 일괄적으로 실행함
class CompositeDisposable {
  final _disposables = [];

  void add(dynamic disposable) {
    _disposables.add(disposable);
  }

  @Deprecated('[add] 사용')
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

/// [dispose], [disposeAll] 보일러 플레이트 클래스
abstract class CompositeDisposableState<T extends StatefulWidget>
    extends State<T> with CompositeDisposableMixin {
  @override
  void dispose() {
    disposeAll();
    super.dispose();
  }
}

/// [dispose], [disposeAll] 보일러 플레이트 클래스
abstract class AbstractDisposable with CompositeDisposableMixin {
  void dispose() {
    disposeAll();
  }
}

/// 미리 구현된 [CompositeDisposable]
mixin CompositeDisposableMixin on Object {
  final disposables = CompositeDisposable();

  void addDisposable(dynamic disposable) {
    disposables.add(disposable);
  }

  void disposeAll() {
    disposables.disposeAll();
  }
}

extension AutoDisposableExtensions on dynamic {
  @Deprecated("[addDisposableTo]를 대신 사용")
  void disposable(CompositeDisposableMixin autoDisposeMixin) {
    autoDisposeMixin.addDisposable(this);
  }

  void addDisposableTo(dynamic target) {
    if (target is CompositeDisposable) {
      target.add(this);
    }

    if (target is CompositeDisposableMixin) {
      target.addDisposable(this);
    }
  }
}
