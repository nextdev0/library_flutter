import 'package:flutter/material.dart';

/// 가로 스크롤 제스처 방지
class PreventHorizontalScroll extends StatelessWidget {
  const PreventHorizontalScroll({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) {},
      child: SizedBox(
        height: double.infinity,
        child: child,
      ),
    );
  }
}

/// 세로 스크롤 제스처 방지
class PreventVerticalScroll extends StatelessWidget {
  const PreventVerticalScroll({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: (_) {},
      child: SizedBox(
        width: double.infinity,
        child: child,
      ),
    );
  }
}

/// 오버스크롤 효과 방지
class PreventOverScroll extends StatelessWidget {
  const PreventOverScroll({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: _NonScrollBehavior(),
      child: child,
    );
  }
}

class _NonScrollBehavior extends MaterialScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
