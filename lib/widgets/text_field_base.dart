// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final Map<TextEditingController, FocusNode> _focusNodes = {};

extension FocusableTextEditingController on TextEditingController {
  /// [TextFieldBase]에 정의된 컨트롤러일 경우 포커스를 지정할 수 있습니다.
  void focus() {
    if (_focusNodes.containsKey(this)) {
      final focusNode = _focusNodes[this];
      if (focusNode != null && focusNode.context != null) {
        FocusScope.of(focusNode.context!).requestFocus(focusNode);
      }
    }
  }
}

class TextFieldBase extends StatefulWidget {
  const TextFieldBase({
    super.key,
    this.controller,
    this.nextController,
    this.initialValue,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.done,
    this.style,
    this.strutStyle,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.autofocus = false,
    this.readOnly = false,
    this.toolbarOptions,
    this.showCursor,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLengthEnforcement,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.buildCounter,
    this.scrollPhysics,
    this.autofillHints,
    this.autovalidateMode,
    this.scrollController,
    this.restorationId,
    this.enableIMEPersonalizedLearning = true,
  });

  final TextEditingController? controller;
  final TextEditingController? nextController;
  final String? initialValue;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool autofocus;
  final bool readOnly;
  final ToolbarOptions? toolbarOptions;
  final bool? showCursor;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final InputCounterWidgetBuilder? buildCounter;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final AutovalidateMode? autovalidateMode;
  final ScrollController? scrollController;
  final String? restorationId;
  final bool enableIMEPersonalizedLearning;

  @override
  State createState() => _TextFieldBaseState();
}

class _TextFieldBaseState extends State<TextFieldBase> {
  TextEditingController? _controller;
  FocusNode? _focusNode;

  TextEditingController get _controllerImpl =>
      _controller ?? widget.controller!;

  FocusNode get _focusNodeImpl => _focusNode ?? _focusNodes[widget.controller]!;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      _focusNodes[widget.controller!] = FocusNode();
    } else {
      _controller = TextEditingController();
      _focusNode = FocusNode();
    }
  }

  @override
  void dispose() {
    final focusNode = _focusNodes.remove(widget.controller);
    focusNode?.dispose();

    _controller?.dispose();
    _controller = null;

    _focusNode?.dispose();
    _focusNode = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controllerImpl,
      initialValue: widget.initialValue,
      focusNode: _focusNodes[widget.controller],
      decoration: widget.decoration,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      textInputAction: widget.textInputAction,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textDirection: widget.textDirection,
      textAlign: widget.textAlign,
      textAlignVertical: widget.textAlignVertical,
      autofocus: widget.autofocus,
      readOnly: widget.readOnly,
      toolbarOptions: widget.toolbarOptions,
      showCursor: widget.showCursor,
      obscuringCharacter: widget.obscuringCharacter,
      obscureText: widget.obscureText,
      autocorrect: widget.autocorrect,
      smartDashesType: widget.smartDashesType,
      smartQuotesType: widget.smartQuotesType,
      enableSuggestions: widget.enableSuggestions,
      maxLengthEnforcement: widget.maxLengthEnforcement,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      expands: widget.expands,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      onEditingComplete: () {
        if (widget.onEditingComplete != null) {
          widget.onEditingComplete!();
        } else {
          widget.controller?.clearComposing();

          switch (widget.textInputAction) {
            case TextInputAction.none:
            case TextInputAction.unspecified:
            case TextInputAction.done:
            case TextInputAction.go:
            case TextInputAction.search:
            case TextInputAction.send:
            case TextInputAction.continueAction:
            case TextInputAction.join:
            case TextInputAction.route:
            case TextInputAction.emergencyCall:
            case TextInputAction.newline:
              _focusNodeImpl.unfocus();
              break;

            case TextInputAction.next:
              _resolveNextFocus();
              break;

            case TextInputAction.previous:
              _focusNodeImpl.previousFocus();
              break;
          }

          if (widget.onFieldSubmitted != null) {
            widget.onFieldSubmitted!(_controllerImpl.text);
          }
        }
      },
      onFieldSubmitted: null,
      onSaved: widget.onSaved,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      enabled: widget.enabled,
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorColor: widget.cursorColor,
      keyboardAppearance: widget.keyboardAppearance,
      scrollPadding: widget.scrollPadding,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      selectionControls: widget.selectionControls,
      buildCounter: widget.buildCounter,
      scrollPhysics: widget.scrollPhysics,
      autofillHints: widget.autofillHints,
      autovalidateMode: widget.autovalidateMode,
      scrollController: widget.scrollController,
      restorationId: widget.restorationId,
      enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
    );
  }

  void _resolveNextFocus() {
    try {
      if (widget.nextController == null) {
        _focusNodeImpl.nextFocus();
        return;
      }

      final focusNode = _focusNodes[widget.nextController];
      if (focusNode != null) {
        FocusScope.of(context).requestFocus(focusNode);
      }
    } catch (_) {
      // NOOP: ignore
    }
  }
}

class SimpleTextField extends StatefulWidget {
  const SimpleTextField({
    super.key,
    this.controller,
    this.nextController,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.hint,
    this.isPassword = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 8.0,
    ),
    this.color,
    this.focusedColor,
    this.border,
    this.focusedBorder,
    this.textStyle,
    this.hintTextStyle,
  });

  final TextEditingController? controller;
  final TextEditingController? nextController;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final int maxLines;
  final int? minLines;
  final bool isPassword;
  final String? hint;
  final EdgeInsets padding;
  final Color? color, focusedColor;
  final InputBorder? border, focusedBorder;
  final TextStyle? textStyle, hintTextStyle;

  @override
  State createState() => _SimpleTextFieldState();
}

class _SimpleTextFieldState extends State<SimpleTextField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textStyle =
        widget.textStyle ?? theme.primaryTextTheme.headlineMedium!;

    return TextFieldBase(
      controller: widget.controller,
      nextController: widget.nextController,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      cursorColor: primaryColor,
      onFieldSubmitted: widget.onFieldSubmitted,
      obscureText: widget.isPassword,
      style: textStyle,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        hintText: widget.hint,
        hintStyle: widget.hintTextStyle ??
            textStyle.copyWith(
              color: textStyle.color!.withOpacity(0.25),
            ),
        contentPadding: widget.padding,
        fillColor: widget.color,
        focusColor: widget.focusedColor ?? widget.color,
        border: widget.border,
        enabledBorder: widget.border,
        disabledBorder: widget.border,
        errorBorder: widget.border,
        focusedBorder: widget.focusedBorder,
        focusedErrorBorder: widget.focusedBorder,
      ),
    );
  }
}
