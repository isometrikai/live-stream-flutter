import 'package:flutter/widgets.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

/// Used to make provided [ChatTheme] class available through the whole package
class InheritedChatTheme extends InheritedWidget {
  /// Creates [InheritedWidget] from a provided [ChatTheme] class
  const InheritedChatTheme({
    Key? key,
    required this.theme,
    required Widget child,
  }) : super(key: key, child: child);

  /// Represents chat theme
  final ChatTheme theme;

  static InheritedChatTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedChatTheme>()!;

  @override
  bool updateShouldNotify(InheritedChatTheme oldWidget) =>
      theme.hashCode != oldWidget.theme.hashCode;
}
