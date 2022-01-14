import 'package:flutter/material.dart';
import 'package:nextstory/widgets/scaffold_base.dart';
import 'package:nextstory_example/resources/app_resource.dart';
import 'package:nextstory_example/routes/app_route.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appRoute = context.watch<AppRoutes>();
    final resources = context.watch<AppResources>();
    return ScaffoldBase(
      topInsetEnabled: true,
      orientation: Orientation.portrait,
      windowTheme: resources.colors.darkIconTheme,
      backgroundColor: resources.colors.appBackground,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [],
        ),
      ),
    );
  }
}
