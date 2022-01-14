import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// 안드로이드 내비게이션바 투명화
class TransparentNavigationBarAndroid extends StatefulWidget {
  const TransparentNavigationBarAndroid({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  State createState() => _TransparentNavigationBarAndroidState();
}

class _TransparentNavigationBarAndroidState
    extends State<TransparentNavigationBarAndroid> {
  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      const methodChannel = MethodChannel('nextstory');
      methodChannel.invokeMethod('initializeActivity');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
