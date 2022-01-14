import 'package:flutter/material.dart';

/// [Route] 컨테이너
class RouteContainer extends StatelessWidget {
  const RouteContainer({
    Key? key,
    required this.navigatorKey,
    required this.initialRoute,
  }) : super(key: key);

  /// [NavigatorState]를 포함하는 [Key]
  final Key navigatorKey;

  /// 초기 표시 [Route]
  final Route initialRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Navigator(
        key: navigatorKey,
        initialRoute: '/',
        onGenerateRoute: (settings) => initialRoute,
      ),
    );
  }
}
