// ignore_for_file: non_constant_identifier_names
// ignore_for_file: library_private_types_in_public_api

import 'dart:ui';

import 'package:flutter/widgets.dart';

final Selector = _SelectorImpl();

final Map<Type, dynamic Function()> _factories = {};
final Map<Type, dynamic> _allocated = {};

class _SelectorImpl {
  final Map<Type, dynamic> _enums = {};
  var _selfReassemble = false;

  /// 현재 앱 테마
  Brightness? get brightness => _appBrightness;
  Brightness? _appBrightness;

  set brightness(Brightness? brightness) {
    _appBrightness = brightness;
    reassemble();
  }

  /// 테마에 해당하는 값을 선택하여 반환
  ///
  /// 라이트 테마는 [light]를 반환, 다크 테마는 [dark]를 반환합니다.
  /// [brightness]가 `null`로 설정되어 있다면 시스템 테마를 따라서 처리됩니다.
  ///
  /// 시스템 테마 예시:
  /// ```dart
  /// // `null`을 설정하게 되면 시스템 테마를 따르게 됩니다.
  /// Selector.brightness = null;
  ///
  /// final test = Selector.getByBrightness(
  ///   light: 'light mode',
  ///   dark: 'dark mode',
  /// );
  /// print(test);
  /// ```
  ///
  /// 커스텀 테마 예시:
  /// ```dart
  /// // 다크 테마 고정
  /// Selector.brightness = Brightness.dark;
  ///
  /// final test = Selector.getByBrightness(
  ///   light: 'light mode',
  ///   dark: 'dark mode',
  /// );
  /// print(test); // 'dark mode'
  /// ```
  T getByBrightness<T>({required T light, required T dark}) {
    final platformDispatcher = PlatformDispatcher.instance;
    final appBrightness = brightness ?? platformDispatcher.platformBrightness;
    return appBrightness == Brightness.dark ? dark : light;
  }

  /// 현재 앱 로케일
  Locale? get locale => _appLocale;
  Locale? _appLocale;

  set locale(Locale? locale) {
    _appLocale = locale;
    reassemble();
  }

  /// 현재 로케일에 맞는 값을 반환
  ///
  /// [locale]이 만약 `null`이라면 시스템 로케일에 따라 값을 반환합니다.
  ///
  /// 시스템 로케일 예시:
  /// ```dart
  /// // 시스템에 설정된 로케일을 사용합니다.
  /// Selector.locale = null;
  ///
  /// final test = Selector.getByLocale({
  ///   Locale('ko'): '안녕',
  ///   Locale('en'): 'hello',
  /// });
  /// print(test);
  /// ```
  ///
  /// 커스텀 로케일 예시:
  /// ```dart
  /// // 영문 로케일 사용
  /// Selector.locale = Locale('en');
  ///
  /// final test = Selector.getByLocale({
  ///   Locale('ko'): '안녕',
  ///   Locale('en'): 'hello',
  /// });
  /// print(test); // 'hello'
  /// ```
  T getByLocale<T>(Map<Locale, T> localeMap) {
    final platformDispatcher = PlatformDispatcher.instance;
    final appLocale = locale ?? platformDispatcher.locale;

    T? value;
    for (Locale locale in localeMap.keys) {
      if (locale == appLocale) {
        return localeMap[locale]!;
      }

      if (locale.languageCode == appLocale.languageCode) {
        if (locale.countryCode == appLocale.countryCode) {
          return localeMap[locale]!;
        }

        // 언어는 같지만 국가가 다른 값을 일단 선택
        value = localeMap[locale];
        continue;
      }

      // 일치하는 값이 없을 경우 선택
      value ??= localeMap[locale]!;
    }

    return value!;
  }

  /// 타입별 설정된 enum 값 반환
  ///
  /// 예시:
  /// ```dart
  /// final value = Selector.getEnum<TestEnum>();
  /// // ...
  ///
  /// enum TestEnum {
  ///   test1,
  ///   test2,
  ///   test3,
  /// }
  /// ```
  T? getEnum<T extends Enum>() {
    final type = T;
    return _enums.containsKey(type) ? _enums[type] : null;
  }

  /// 타입별 enum 값 설정
  ///
  /// 예시:
  /// ```dart
  /// Selector.setEnum(TestEnum.test2);
  ///
  /// enum TestEnum {
  ///   test1,
  ///   test2,
  ///   test3,
  /// }
  /// ```
  void setEnum<T extends Enum>(T? value) {
    final type = value.runtimeType;
    _enums[type] = value;
    reassemble();
  }

  /// 현재 설정된 enum 값에 따라 값을 반환
  ///
  /// 만약 설정된 값이 없을 경우에는 첫번째 값을 반환합니다.
  ///
  /// 예시:
  /// ```dart
  /// Selector.setEnum(TestEnum.test2);
  ///
  /// final result = Selector.getByEnum({
  ///   TestEnum.test1: 'test1..',
  ///   TestEnum.test2: 'test2!!',
  ///   TestEnum.test3: 'test3~',
  /// });
  /// // result = 'test2!!'
  ///
  /// enum TestEnum {
  ///   test1,
  ///   test2,
  ///   test3,
  /// }
  /// ```
  ///
  /// 값 미설정 예시:
  /// ```dart
  /// // 만약 값이 사전에 설정되어 있었으면 `null`을 넣습니다.
  /// // Selector.setEnum<TestEnum>(null);
  ///
  /// final result = Selector.getByEnum({
  ///   TestEnum.test3: 'test3~',
  ///   TestEnum.test1: 'test1..',
  ///   TestEnum.test2: 'test2!!',
  /// });
  /// // 가장 먼저 정의된 TestEnum.test3이 반환됩니다.
  /// // result = 'test3~'
  ///
  /// enum TestEnum {
  ///   test1,
  ///   test2,
  ///   test3,
  /// }
  /// ```
  V getByEnum<T extends Enum, V>(Map<T, V> enumMap) {
    final currentValue = getEnum<T>();
    if (currentValue == null) {
      return enumMap[enumMap.keys.first]!;
    }
    return enumMap[currentValue]!;
  }

  /// 재생성 가능 객체 등록
  ///
  /// Selector의 설정이 변경될 때 재생성이 발생할 객체를 등록합니다.
  ///
  /// 예시:
  /// ```dart
  /// /// 시스템 테마 또는 커스텀 테마가 설정될 경우에
  /// /// [ThemedResources]는 재생성됩니다.
  /// Selector.registerFactory(() => ThemedResources());
  ///
  /// class ThemedResources {
  ///   late final dark = Selector.getByBrightness(
  ///     light: Colors.black,
  ///     dark: Colors.white,
  ///   );
  ///
  ///   /// ...
  /// }
  /// ```
  T registerFactory<T>(T Function() factory) {
    if (!_factories.containsKey(T)) {
      _factories[T] = factory;
      _allocated[T] = factory();
    }
    return _allocated[T]!;
  }

  void reassemble() {
    if (!_selfReassemble) {
      _selfReassemble = true;

      for (final key in _factories.keys) {
        final newInstance = _factories[key]!();
        _allocated[key] = newInstance;
      }

      WidgetsBinding.instance.performReassemble();
      _selfReassemble = false;
    }
  }
}
