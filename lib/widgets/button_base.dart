import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nextstory/foundation/safe_value_notifier.dart';
import 'package:nextstory/widgets/listenable_builder.dart';

// region :::: 도형 버튼 ::::

class SolidButton extends StatefulWidget {
  const SolidButton({
    super.key,
    this.onPressed,
    this.padding = const EdgeInsets.all(14.0),
    this.color,
    this.disabledColor,
    this.borderColor,
    this.borderDisabledColor,
    this.borderWidth,
    this.text = '',
    this.textStyle,
    this.textColor,
    this.textDisabledColor,
    this.fontSize,
    this.borderRadius = const BorderRadius.all(Radius.circular(20.0)),
    this.isEnabled = true,
    this.isClickable = true,
    this.pressedOpacity = 0.65,
    this.child,
  });

  final VoidCallback? onPressed;
  final EdgeInsets padding;
  final Color? color;
  final Color? disabledColor;
  final Color? borderColor;
  final Color? borderDisabledColor;
  final double? borderWidth;
  final String text;
  final TextStyle? textStyle;
  final Color? textColor;
  final Color? textDisabledColor;
  final double? fontSize;
  final BorderRadius borderRadius;
  final bool isEnabled;
  final bool isClickable;
  final double pressedOpacity;
  final Widget? child;

  @override
  State createState() => _SolidButtonState();
}

class _SolidButtonState extends State<SolidButton> {
  late final _heldDown = SafeValueNotifier(false);

  @override
  void dispose() {
    _heldDown.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !widget.isClickable,
      child: GestureDetector(
        onTapDown: (_) => _heldDown.value = widget.onPressed != null,
        onTapUp: (_) => _heldDown.value = false,
        onTapCancel: () => _heldDown.value = false,
        onTap: widget.isEnabled
            ? () {
                final onPressed = widget.onPressed;
                if (onPressed != null) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  onPressed();
                }
              }
            : null,
        child: SingleListenableBuilder(
          listenable: _heldDown,
          builder: (_) => _build(
            context,
            widget.isEnabled ? _heldDown.value : false,
          ),
        ),
      ),
    );
  }

  Widget _build(BuildContext context, bool isHeldDown) {
    final defaultTheme = CupertinoTheme.of(context);
    final textStyleImpl =
        (widget.textStyle ?? defaultTheme.textTheme.textStyle).copyWith(
      fontSize: widget.fontSize ??
          (widget.textStyle == null ? 14.0 : widget.textStyle!.fontSize),
      color: widget.isEnabled
          ? widget.textColor ??
              (widget.textStyle == null
                  ? CupertinoColors.white
                  : widget.textStyle!.color)
          : widget.textDisabledColor ?? CupertinoColors.white.withOpacity(0.6),
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      opacity: isHeldDown ? widget.pressedOpacity : 1.0,
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.isEnabled
              ? widget.color ?? CupertinoColors.systemBlue
              : widget.disabledColor ?? CupertinoColors.quaternarySystemFill,
          border: Border.all(
            color: widget.isEnabled
                ? widget.borderColor ?? Colors.transparent
                : widget.borderDisabledColor ?? Colors.transparent,
            width: widget.borderWidth ?? 0.0,
          ),
          borderRadius: widget.borderRadius,
        ),
        child: Align(
          alignment: Alignment.center,
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: widget.child ??
              AutoSizeText(
                widget.text,
                maxLines: 1,
                minFontSize: 1.0,
                maxFontSize: textStyleImpl.fontSize!,
                style: textStyleImpl,
              ),
        ),
      ),
    );
  }
}

// endregion :::: 도형 버튼 ::::

// region :::: 위젯 버튼 ::::

class WidgetButton extends StatefulWidget {
  const WidgetButton({
    super.key,
    this.onPressed,
    this.padding = EdgeInsets.zero,
    this.isClickable = true,
    this.isEnabled = true,
    this.pressedOpacity = 0.65,
    required this.child,
  });

  final VoidCallback? onPressed;
  final EdgeInsets padding;
  final bool isEnabled;
  final bool isClickable;
  final double pressedOpacity;
  final Widget child;

  @override
  State createState() => _WidgetButtonState();
}

class _WidgetButtonState extends State<WidgetButton> {
  late final _heldDown = SafeValueNotifier(false);

  @override
  void dispose() {
    _heldDown.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !widget.isClickable,
      child: GestureDetector(
        onTapDown: (_) => _heldDown.value = widget.onPressed != null,
        onTapUp: (_) => _heldDown.value = false,
        onTapCancel: () => _heldDown.value = false,
        onTap: widget.isEnabled
            ? () {
                final onPressed = widget.onPressed;
                if (onPressed != null) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  onPressed();
                }
              }
            : null,
        child: SingleListenableBuilder(
          listenable: _heldDown,
          builder: (_) => _build(context, _heldDown.value),
        ),
      ),
    );
  }

  Widget _build(BuildContext context, bool isHeldDown) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastLinearToSlowEaseIn,
      opacity: widget.isEnabled
          ? isHeldDown
              ? widget.pressedOpacity
              : 1.0
          : 0.4,
      child: Container(
        color: Colors.transparent,
        padding: widget.padding,
        child: widget.child,
      ),
    );
  }
}

// endregion :::: 위젯 버튼 ::::
