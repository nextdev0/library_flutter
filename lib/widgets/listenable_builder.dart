import 'package:flutter/widgets.dart';

/// [Listenable] 구독 빌더
///
/// 구독된 [listenable]의 변화를 감지하여 위젯을 빌드함
class ListenableBuilder extends StatefulWidget {
  const ListenableBuilder({
    Key? key,
    required this.listenable,
    required this.builder,
  }) : super(key: key);

  final Listenable listenable;
  final WidgetBuilder builder;

  @override
  _ListenableBuilderState createState() => _ListenableBuilderState();
}

class _ListenableBuilderState extends State<ListenableBuilder> {
  @override
  void initState() {
    super.initState();
    try {
      widget.listenable.addListener(_onUpdate);
    } catch (e) {
      // ignored
    }
  }

  @override
  void dispose() {
    try {
      widget.listenable.removeListener(_onUpdate);
    } catch (e) {
      // ignored
    }
    super.dispose();
  }

  void _onUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}

/// 여러개의 [Listenable] 구독 빌더
///
/// 구독된 [listenables]의 변화를 감지하여 위젯을 빌드함
class MultiListenableBuilder extends StatefulWidget {
  const MultiListenableBuilder({
    Key? key,
    required this.listenables,
    required this.builder,
  }) : super(key: key);

  final List<Listenable> listenables;
  final WidgetBuilder builder;

  @override
  _MultiListenableBuilderState createState() => _MultiListenableBuilderState();
}

class _MultiListenableBuilderState extends State<MultiListenableBuilder> {
  @override
  void initState() {
    super.initState();
    for (final listenable in widget.listenables) {
      try {
        listenable.addListener(_onUpdate);
      } catch (e) {
        // ignored
      }
    }
  }

  @override
  void dispose() {
    for (final listenable in widget.listenables) {
      try {
        listenable.removeListener(_onUpdate);
      } catch (e) {
        // ignored
      }
    }
    super.dispose();
  }

  void _onUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
