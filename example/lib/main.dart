import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ModularApp(
      module: AppModule(),
      child: const MaterialApp(
        title: 'Library Sample',
      ).modular(),
    ),
  );
}

class AppModule extends Module {
  @override
  List<ModularRoute> get routes {
    return [
    ];
  }
}
