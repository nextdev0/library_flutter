import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// 지역화 적용 위젯
class LocalizationConfiguration extends StatelessWidget {
  const LocalizationConfiguration({
    Key? key,
    required this.locale,
    required this.child,
  }) : super(key: key);

  final Locale locale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Localizations(
      locale: locale,
      delegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: child,
    );
  }
}
