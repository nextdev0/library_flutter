import 'package:flutter/material.dart';

/// 가로 스크롤 제스처 방지
class PreventHorizontalScroll extends StatelessWidget {
  const PreventHorizontalScroll({
    super.key,
    required this.child,
  });

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
    super.key,
    required this.child,
  });

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
    super.key,
    required this.child,
  });

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

/// 스크롤 도달 인식 위젯
class ScrollEdgeListener extends StatefulWidget {
  const ScrollEdgeListener({
    super.key,
    required this.child,
    required this.scrollController,
    this.onTop,
    this.onLeft,
    this.onRight,
    this.onBottom,
  });

  /// 하위 위젯
  final Widget child;

  /// 스크롤 상태 체크용 컨트롤러
  final ScrollController scrollController;

  /// 콜백
  final VoidCallback? onTop, onLeft, onRight, onBottom;

  @override
  State createState() => _ScrollEdgeListenerState();
}

class _ScrollEdgeListenerState extends State<ScrollEdgeListener> {
  @override
  void initState() {
    super.initState();

    try {
      widget.scrollController.addListener(_onScrollUpdate);
    } catch (_) {
      // ignored
    }
  }

  @override
  void dispose() {
    try {
      widget.scrollController.removeListener(_onScrollUpdate);
    } catch (_) {
      // ignored
    }

    super.dispose();
  }

  void _onScrollUpdate() {
    if (!mounted) {
      return;
    }

    if (widget.scrollController.position.axis == Axis.vertical) {
      if (widget.scrollController.position.pixels ==
              widget.scrollController.position.minScrollExtent &&
          !widget.scrollController.position.outOfRange) {
        widget.onTop?.call();
      }
      if (widget.scrollController.position.pixels ==
              widget.scrollController.position.maxScrollExtent &&
          !widget.scrollController.position.outOfRange) {
        widget.onBottom?.call();
      }
    } else {
      if (widget.scrollController.position.pixels ==
              widget.scrollController.position.minScrollExtent &&
          !widget.scrollController.position.outOfRange) {
        widget.onLeft?.call();
      }
      if (widget.scrollController.position.pixels ==
              widget.scrollController.position.maxScrollExtent &&
          !widget.scrollController.position.outOfRange) {
        widget.onRight?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
