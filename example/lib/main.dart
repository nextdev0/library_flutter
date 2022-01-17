import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nextstory/nextstory.dart';
import 'package:nextstory/widgets/scaffold_base.dart';
import 'package:nextstory_example/resources/app_resource.dart';
import 'package:nextstory_example/routes/app_route.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Nextstory.enableAndroidTransparentNavigationBar();
  await Nextstory.disableDelayTouchesBeganIOS();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppRoutes>(
          create: (_) => AppRoutes(),
        ),
        ChangeNotifierProvider<AppResources>(
          create: (_) => AppResources(),
        ),
      ],
      child: _App(),
    ),
  );
}

class _App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<_App> with TickerProviderStateMixin {
  late final AnimationController _controller;
  bool animationCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(_animateListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_animateListener);
    _controller.dispose();
    super.dispose();
  }

  void _animateListener() {
    if (_controller.isCompleted) {
      setState(() {
        animationCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final routes = context.read<AppRoutes>();
    final resources = context.watch<AppResources>();
    return MaterialApp(
      navigatorKey: routes.navigatorKey,
      debugShowCheckedModeBanner: false,
      home: ScaffoldBase(
        windowTheme: resources.colors.darkIconTheme,
        orientation: Orientation.portrait,
        topInsetEnabled: false,
        bottomInsetEnabled: false,
        backgroundColor: resources.colors.appBackground,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FractionallySizedBox(
                widthFactor: 0.7,
                child: Lottie.asset(
                  'assets/lotties/coin_falling.json',
                  fit: BoxFit.fitWidth,
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller
                      ..duration = composition.duration
                      ..forward();
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              AnimatedOpacity(
                onEnd: () => navigateHome(),
                duration: const Duration(milliseconds: 500),
                opacity: animationCompleted ? 1.0 : 0.0,
                child: Text(
                  'Sample',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: resources.colors.dark,
                  ),
                ),
              ),
              const SizedBox(height: 64.0),
            ],
          ),
        ),
      ),
    );
  }

  void navigateHome() async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final routes = context.read<AppRoutes>();
    routes.navigator.pushReplacement(
      routes.home.copyWith(
        transition: (context, animation, child) {
          return FadeTransition(
            opacity: animation.drive(
              Tween<double>(
                begin: 0.0,
                end: 1.0,
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }
}
