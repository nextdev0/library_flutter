import 'package:flutter/material.dart';

class ButtonBase extends StatefulWidget {
  const ButtonBase({
    Key? key,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    this.padding = const EdgeInsets.all(16.0),
    this.constraints,
    this.color,
    this.pressedColor,
    this.boxShadow,
    this.pressedBoxShadow,
    this.border,
    this.pressedBorder,
    this.pressedOpacity = 0.8,
    this.alignment = Alignment.center,
    required this.child,
    this.onPressed,
    this.onLongPressed,
  }) : super(key: key);

  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final BoxConstraints? constraints;
  final Color? color, pressedColor;
  final List<BoxShadow>? boxShadow, pressedBoxShadow;
  final BoxBorder? border, pressedBorder;
  final double pressedOpacity;
  final AlignmentGeometry alignment;
  final Widget child;
  final VoidCallback? onPressed, onLongPressed;

  @override
  State<StatefulWidget> createState() => _ButtonBaseState();
}

class _ButtonBaseState extends State<ButtonBase> {
  bool _buttonHeldDown = false;

  void _handleTapDown(TapDownDetails event) {
    if (!_buttonHeldDown) {
      _buttonHeldDown = true;
      _animate();
    }
  }

  void _handleTapUp(TapUpDetails event) {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _handleTapCancel() {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _animate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null || widget.onLongPressed != null;
    final realColor = widget.color ?? Theme.of(context).primaryColor;
    final realPressedColor = widget.pressedColor ?? realColor;
    final defaultTextStyle = TextStyle(
      fontSize: 14.0,
      color: realColor.computeLuminance() < 0.5 ? Colors.white : Colors.black,
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? _handleTapDown : null,
      onTapUp: enabled ? _handleTapUp : null,
      onTapCancel: enabled ? _handleTapCancel : null,
      onTap: widget.onPressed,
      onLongPress: widget.onLongPressed,
      child: Semantics(
        button: true,
        child: ConstrainedBox(
          constraints: widget.constraints ?? const BoxConstraints(),
          child: AnimatedOpacity(
            opacity: _buttonHeldDown ? widget.pressedOpacity : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.decelerate,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.decelerate,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                color: _buttonHeldDown ? realPressedColor : realColor,
                border: _buttonHeldDown ? widget.pressedBorder : widget.border,
                boxShadow: _buttonHeldDown
                    ? widget.pressedBoxShadow ?? widget.boxShadow
                    : widget.boxShadow,
              ),
              child: Padding(
                padding: widget.padding,
                child: Align(
                  alignment: widget.alignment,
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: DefaultTextStyle(
                    style: defaultTextStyle,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
