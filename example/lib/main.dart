import 'package:flutter/material.dart';
import 'package:nextstory/nextstory.dart';
import 'package:nextstory/widgets/window_config.dart';

void main() {
  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return LibraryInitializer(
      builder: (_) {
        return const MaterialApp(
          home: WindowConfig(
            color: Colors.white,
            navigationBarColor: Colors.white,
            navigationBarDividerColor: Color(0xffdddddd),
            navigationBarIconBrightness: Brightness.dark,
            child: Placeholder(),
          ),
        );
      },
    );
  }
}
