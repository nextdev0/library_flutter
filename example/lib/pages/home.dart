import 'package:flutter/material.dart';
import 'package:nextstory/widgets/button_base.dart';
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
          children: [
            ButtonBase(
              child: const Text('default'),
              onPressed: () {
                appRoute.navigator.push(
                  appRoute.home,
                );
              },
            ),
            ButtonBase(
              child: const Text('fullscreen dialog'),
              onPressed: () {
                appRoute.navigator.push(
                  appRoute.home.copyWith(
                    fullscreenDialog: true,
                  ),
                );
              },
            ),
            ButtonBase(
              child: const Text('custom transition'),
              onPressed: () {
                appRoute.navigator.push(
                  appRoute.home.copyWith(
                      popGestureDragRange: 0.4,
                      transition: (context, animation, child) =>
                          SlideTransition(
                            position: CurvedAnimation(
                              parent: animation,
                              curve: Curves.linearToEaseOut,
                              reverseCurve: Curves.fastLinearToSlowEaseIn,
                            ).drive(
                              Tween<Offset>(
                                begin: const Offset(0.0, 0.4),
                                end: const Offset(0.0, 0.0),
                              ),
                            ),
                            child: FadeTransition(
                              opacity: CurvedAnimation(
                                parent: animation,
                                curve: Curves.linearToEaseOut,
                                reverseCurve: Curves.fastLinearToSlowEaseIn,
                              ).drive(
                                Tween<double>(
                                  begin: 0.0,
                                  end: 1.0,
                                ),
                              ),
                              child: child,
                            ),
                          ),
                      previousPopTransition: (context, animation, child) =>
                          SlideTransition(
                            position: CurvedAnimation(
                              parent: animation,
                              curve: Curves.linearToEaseOut,
                              reverseCurve: Curves.fastLinearToSlowEaseIn,
                            ).drive(
                              Tween<Offset>(
                                begin: Offset.zero,
                                end: const Offset(0.0, -0.025),
                              ),
                            ),
                            transformHitTests: false,
                            child: FadeTransition(
                              opacity: CurvedAnimation(
                                parent: animation,
                                curve: Curves.linearToEaseOut,
                                reverseCurve: Curves.fastLinearToSlowEaseIn,
                              ).drive(
                                Tween<double>(
                                  begin: 1.0,
                                  end: 0.75,
                                ),
                              ),
                              child: child,
                            ),
                          )),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
