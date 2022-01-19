import 'dart:collection';

import 'package:flutter/foundation.dart';

/// [Listenable]가 구현된 [List]
class ListNotifier<E> extends Listenable with ListMixin<E> {
  final _list = <E>[];
  final _listeners = <VoidCallback>[];

  ListNotifier([List<E> list = const []]) {
    _list.addAll(list);
  }

  factory ListNotifier.filled(int length, E fill, {bool growable = false}) {
    return ListNotifier(List.filled(length, fill, growable: growable));
  }

  factory ListNotifier.empty({bool growable = false}) {
    return ListNotifier(List.empty(growable: growable));
  }

  factory ListNotifier.from(Iterable elements, {bool growable = true}) {
    return ListNotifier(List.from(elements, growable: growable));
  }

  factory ListNotifier.of(Iterable<E> elements, {bool growable = true}) {
    return ListNotifier(List.of(elements, growable: growable));
  }

  factory ListNotifier.generate(
    int length,
    E Function(int index) generator, {
    bool growable = true,
  }) {
    return ListNotifier(List.generate(length, generator, growable: growable));
  }

  factory ListNotifier.unmodifiable(Iterable elements) {
    return ListNotifier(List.unmodifiable(elements));
  }

  @override
  Iterator<E> get iterator => _list.iterator;

  @override
  void operator []=(int index, E val) {
    _list[index] = val;
    notifyListeners();
  }

  @override
  E operator [](int index) {
    return _list[index];
  }

  @override
  void add(E element) {
    _list.add(element);
    notifyListeners();
  }

  @override
  void addAll(Iterable<E> iterable) {
    _list.addAll(iterable);
    notifyListeners();
  }

  @override
  void removeWhere(bool Function(E element) test) {
    _list.removeWhere(test);
    notifyListeners();
  }

  @override
  void retainWhere(bool Function(E element) test) {
    _list.retainWhere(test);
    notifyListeners();
  }

  @override
  int get length => _list.length;

  @override
  set length(int newLength) {
    _list.length = newLength;
    notifyListeners();
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    _list.insertAll(index, iterable);
    notifyListeners();
  }

  @override
  Iterable<E> get reversed => _list.reversed;

  @override
  Iterable<E> where(bool Function(E) test) {
    return _list.where(test);
  }

  @override
  Iterable<T> whereType<T>() {
    return _list.whereType<T>();
  }

  @override
  void sort([int Function(E a, E b)? compare]) {
    _list.sort(compare);
    notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    try {
      for (final listener in _listeners) {
        listener();
      }
    } catch (e) {
      // ignored
    }
  }

  void dispose() {
    try {
      _listeners.clear();
    } catch (e) {
      // ignored
    }
  }
}
