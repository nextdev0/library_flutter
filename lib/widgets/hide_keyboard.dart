import 'package:flutter/widgets.dart';
import 'package:focus_detector/focus_detector.dart';

/// 키보드를 숨길 수 있도록 하는 위젯
class HideKeyboard extends StatelessWidget {
  const HideKeyboard({
    Key? key,
    required this.child,
    this.hideKeyboardOnTap = true,
    this.hideKeyboardOnFocusGained = true,
    this.hideKeyboardOnFocusLost = true,
  }) : super(key: key);

  final Widget child;

  /// 포커스가 불가능하거나 클릭 영역이 아닌곳에 탭할 경우 키보드 숨기기
  final bool hideKeyboardOnTap;

  /// 위젯이 화면에 다시 표시될 경우 키보드 숨기기
  final bool hideKeyboardOnFocusGained;

  /// 위젯이 화면에서 표시되지 않을 경우 키보드 숨기기
  final bool hideKeyboardOnFocusLost;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hideKeyboardOnTap ? () => FocusScope.of(context).unfocus() : null,
      child: FocusDetector(
        onFocusGained: hideKeyboardOnFocusGained
            ? () {
                try {
                  FocusScope.of(context).unfocus();
                } catch (_) {
                  // ignored
                }
              }
            : null,
        onFocusLost: hideKeyboardOnFocusLost
            ? () {
                try {
                  FocusScope.of(context).unfocus();
                } catch (_) {
                  // ignored
                }
              }
            : null,
        child: child,
      ),
    );
  }
}
