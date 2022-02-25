import 'package:flutter/material.dart';
import 'package:nextstory/nextstory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Nextstory.enableAndroidTransparentNavigationBar();
  await Nextstory.disableDelayTouchesBeganIOS();

  runApp(const MaterialApp());
}
