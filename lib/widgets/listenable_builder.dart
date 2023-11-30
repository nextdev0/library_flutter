import 'package:flutter/widgets.dart';

/// [Listenable] 구독 빌더
///
/// 구독된 [listenable]의 변화를 감지하여 위젯을 빌드함
class SingleListenableBuilder extends StatefulWidget {
  const SingleListenableBuilder({
    super.key,
    required this.listenable,
    required this.builder,
  });

  final Listenable listenable;
  final WidgetBuilder builder;

  @override
  State createState() => _SingleListenableBuilderState();
}

class _SingleListenableBuilderState extends State<SingleListenableBuilder> {
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
    super.key,
    required this.listenables,
    required this.builder,
  });

  final List<Listenable> listenables;
  final WidgetBuilder builder;

  @override
  State createState() => _MultiListenableBuilderState();
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

extension SingleListenableExtension on Listenable {
  Widget subscribe(WidgetBuilder builder) {
    return SingleListenableBuilder(
      listenable: this,
      builder: builder,
    );
  }
}

extension MultiListenableExtension on List<Listenable> {
  Widget subscribe(WidgetBuilder builder) {
    return MultiListenableBuilder(
      listenables: this,
      builder: builder,
    );
  }
}
