import 'dart:ui';

import 'package:flutter/widgets.dart';

/// selector 설정
final selectorConfig = _SelectorConfig();

/// 테마 설정 유무에 따른 값 선택
T selectByBrightness<T>({required T light, required T dark}) {
  return selectorConfig.brightness == Brightness.dark ? dark : light;
}

/// 로케일 설정에 따른 값 선택
V selectByLocale<V>(Map<Locale, V> localeMap) {
  final appLocale = selectorConfig.locale ?? window.locale;

  V? value;
  for (Locale locale in localeMap.keys) {
    if (locale == appLocale) {
      return localeMap[locale]!;
    }

    if (locale.languageCode == appLocale.languageCode) {
      if (locale.countryCode == appLocale.countryCode) {
        return localeMap[locale]!;
      }

      // 언어는 같지만 국가가 다른 값을 일단 선택
      value = localeMap[locale]!;
      continue;
    }

    // 일치하는 값이 없을 경우 선택
    value ??= localeMap[locale]!;
  }

  // `null`일 경우는 [localeMap]에 내용이 없는것으로 간주
  if (value == null) {
    throw FlutterError("localeMap can't be empty.");
  }

  return value;
}

class _SelectorConfig with WidgetsBindingObserver {
  final _factories = <Type, dynamic Function()>{};
  final _allocated = <Type, dynamic>{};

  Locale? _appLocale;
  Brightness? _appBrightness;

  /// 현재 앱 로케일
  @mustCallSuper
  Locale? get locale => _appLocale;

  /// 로케일 설정
  @mustCallSuper
  set locale(Locale? locale) {
    _appLocale = locale;
    _reassemble();
  }

  /// 현재 앱 테마
  @mustCallSuper
  Brightness? get brightness => _appBrightness;

  /// 앱 테마 설정
  @mustCallSuper
  set brightness(Brightness? brightness) {
    _appBrightness = brightness;
    _reassemble();
  }

  /// 설정이 변경될 경우 재할당되는 객체 등록
  @mustCallSuper
  T registerFactory<T>(T Function() factory) {
    if (!_factories.containsKey(T)) {
      _factories[T] = factory;
      _allocated[T] = factory();
    }
    return _allocated[T]!;
  }

  @mustCallSuper
  @override
  void didChangePlatformBrightness() => _reassemble();

  @mustCallSuper
  @override
  void didChangeLocales(List<Locale>? locales) => _reassemble();

  void _reassemble() {
    for (final key in _factories.keys) {
      final newInstance = _factories[key]!();
      _allocated[key] = newInstance;
    }

    final binding = WidgetsBinding.instance ?? WidgetsFlutterBinding();
    binding.performReassemble();
  }

  @mustCallSuper
  void initialize() {
    final binding = WidgetsBinding.instance ?? WidgetsFlutterBinding();
    binding.addObserver(this);
  }
}
