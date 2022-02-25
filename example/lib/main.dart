import 'package:flutter/material.dart';
import 'package:nextstory/foundation/selector.dart';
import 'package:nextstory/nextstory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Nextstory.enableAndroidTransparentNavigationBar();
  await Nextstory.disableDelayTouchesBeganIOS();

  selectorConfig.initialize();

  runApp(const MaterialApp());
}
