import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// 설정 변경 확인 [ChangeNotifier]
abstract class SystemChangeNotifier extends ChangeNotifier
    with WidgetsBindingObserver {
  SystemChangeNotifier() {
    _widgetBinding.addObserver(this);
  }

  /// 다크모드 유무
  bool get darkModeEnabled => systemDarkModeEnabled;

  /// 로케일
  Locale get locale => systemLocale;

  /// 시스템 다크모드 유무
  bool get systemDarkModeEnabled =>
      window.platformBrightness == Brightness.dark;

  /// 시스템 로케일
  Locale get systemLocale => window.locale;

  /// 다크모드 설정 유무에 따른 값 선택
  T switchDarkMode<T>({required T light, required T dark}) {
    return darkModeEnabled ? dark : light;
  }

  /// 로케일 설정에 따른 값 선택
  V switchLocale<V>(Map<Locale, V> localeMap) {
    V? value;
    for (Locale locale in localeMap.keys) {
      if (locale == this.locale) {
        return localeMap[locale]!;
      }

      if (locale.languageCode == this.locale.languageCode) {
        if (locale.countryCode == this.locale.countryCode) {
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

  @nonVirtual
  @mustCallSuper
  @override
  void didChangeTextScaleFactor() => dispatchOnSystemChanged();

  @nonVirtual
  @mustCallSuper
  @override
  void didChangePlatformBrightness() => dispatchOnSystemChanged();

  @nonVirtual
  @mustCallSuper
  @override
  void didChangeLocales(List<Locale>? locales) => dispatchOnSystemChanged();

  @mustCallSuper
  @override
  void dispose() {
    _widgetBinding.removeObserver(this);
    super.dispose();
  }

  @mustCallSuper
  void dispatchOnSystemChanged() {
    onSystemChanged();
    notifyListeners();
  }

  @mustCallSuper
  void onSystemChanged() {
    // no-op
  }

  WidgetsBinding get _widgetBinding {
    return WidgetsBinding.instance ?? WidgetsFlutterBinding();
  }
}
