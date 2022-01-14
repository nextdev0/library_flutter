import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 기능 추가된 [TextField]
class TextFieldBase extends StatelessWidget {
  const TextFieldBase._(
    this._widgetBuilder, {
    Key? key,
  }) : super(key: key);

  /// 기본 생성 factory
  ///
  /// [nextController] : 다음 포커스로 지정할 컨트롤러
  factory TextFieldBase({
    Key? key,
    TextEditingController? controller,
    TextEditingController? nextController,
    String? initialValue,
    FocusNode? focusNode,
    InputDecoration? decoration = const InputDecoration(),
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction textInputAction = TextInputAction.done,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    bool autofocus = false,
    bool readOnly = false,
    ToolbarOptions? toolbarOptions,
    bool? showCursor,
    String obscuringCharacter = '•',
    bool obscureText = false,
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool enableSuggestions = true,
    MaxLengthEnforcement? maxLengthEnforcement,
    int? maxLines = 1,
    int? minLines,
    bool expands = false,
    int? maxLength,
    ValueChanged<String>? onChanged,
    GestureTapCallback? onTap,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onFieldSubmitted,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    TextSelectionControls? selectionControls,
    InputCounterWidgetBuilder? buildCounter,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints,
    AutovalidateMode? autovalidateMode,
    ScrollController? scrollController,
    String? restorationId,
    bool enableIMEPersonalizedLearning = true,
  }) {
    return TextFieldBase._(
        (context) => TextFormField(
              controller: controller,
              initialValue: initialValue,
              focusNode: focusNode,
              decoration: decoration,
              keyboardType: keyboardType,
              textCapitalization: textCapitalization,
              textInputAction: textInputAction,
              style: style,
              strutStyle: strutStyle,
              textDirection: textDirection,
              textAlign: textAlign,
              textAlignVertical: textAlignVertical,
              autofocus: autofocus,
              readOnly: readOnly,
              toolbarOptions: toolbarOptions,
              showCursor: showCursor,
              obscuringCharacter: obscuringCharacter,
              obscureText: obscureText,
              autocorrect: autocorrect,
              smartDashesType: smartDashesType,
              smartQuotesType: smartQuotesType,
              enableSuggestions: enableSuggestions,
              maxLengthEnforcement: maxLengthEnforcement,
              maxLines: maxLines,
              minLines: minLines,
              expands: expands,
              maxLength: maxLength,
              onChanged: onChanged,
              onTap: onTap,
              onEditingComplete: onEditingComplete,
              onFieldSubmitted: (arg) {
                _resolveNextFocus(
                  context,
                  textInputAction,
                  nextController,
                );
                if (onFieldSubmitted != null) {
                  onFieldSubmitted(arg);
                }
              },
              onSaved: onSaved,
              validator: validator,
              inputFormatters: inputFormatters,
              enabled: enabled,
              cursorWidth: cursorWidth,
              cursorHeight: cursorHeight,
              cursorRadius: cursorRadius,
              cursorColor: cursorColor,
              keyboardAppearance: keyboardAppearance,
              scrollPadding: scrollPadding,
              enableInteractiveSelection: enableInteractiveSelection,
              selectionControls: selectionControls,
              buildCounter: buildCounter,
              scrollPhysics: scrollPhysics,
              autofillHints: autofillHints,
              autovalidateMode: autovalidateMode,
              scrollController: scrollController,
              restorationId: restorationId,
              enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
            ),
        key: key);
  }

  static void _resolveNextFocus(
    BuildContext context,
    TextInputAction? textInputAction,
    TextEditingController? nextController,
  ) {
    if (textInputAction != null && textInputAction == TextInputAction.next) {
      if (nextController == null) {
        do {
          final foundFocusNode = FocusScope.of(context).nextFocus();
          if (!foundFocusNode) return;
        } while (FocusScope.of(context).focusedChild?.context?.widget
            is! EditableText);
      } else {
        for (final focusNode in FocusScope.of(context).children) {
          if (focusNode.context != null) {
            if (focusNode.context!.widget is TextFormField) {
              final textField = focusNode.context!.widget as TextFormField;
              if (textField.controller == nextController) {
                focusNode.requestFocus();
                break;
              }
            }
          }
        }
      }
    }
  }

  final WidgetBuilder _widgetBuilder;

  @override
  Widget build(BuildContext context) {
    return _widgetBuilder(context);
  }
}
