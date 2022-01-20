import 'package:flutter/widgets.dart';

extension TextFieldUtils on TextEditingController {
  /// [TextEditingController]를 구독하고 있는 [EditableText] 위젯을 포커스 시킴
  void focus(BuildContext context) {
    for (final focusNode in FocusScope.of(context).children) {
      if (focusNode.context != null) {
        if (focusNode.context!.widget is EditableText) {
          final textField = focusNode.context!.widget as EditableText;
          if (textField.controller == this) {
            focusNode.requestFocus();
            break;
          }
        }
      }
    }
  }
}
