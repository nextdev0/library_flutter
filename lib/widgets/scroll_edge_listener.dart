import 'package:flutter/widgets.dart';

/// 스크롤 도달 인식 위젯
class ScrollEdgeListener extends StatefulWidget {
  const ScrollEdgeListener({
    Key? key,
    required this.child,
    required this.scrollController,
    this.onTop,
    this.onLeft,
    this.onRight,
    this.onBottom,
  }) : super(key: key);

  /// 하위 위젯
  final Widget child;

  /// 스크롤 상태 체크용 컨트롤러
  final ScrollController scrollController;

  /// 콜백
  final VoidCallback? onTop, onLeft, onRight, onBottom;

  @override
  _ScrollEdgeListenerState createState() => _ScrollEdgeListenerState();
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
