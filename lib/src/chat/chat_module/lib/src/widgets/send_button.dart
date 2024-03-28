import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/src/widgets/inherited_l10n.dart';
import 'package:flutter_svg/svg.dart';

/// A class that represents send button widget
class SendButton extends StatelessWidget {
  /// Creates send button widget
  const SendButton({
    Key? key,
    required this.onPressed,
    this.clickable = false,
  }) : super(key: key);

  /// Callback for send button tap event
  final void Function() onPressed;
  final bool clickable;

  @override
  Widget build(BuildContext context) => Container(
        height: 24,
        margin: const EdgeInsets.only(left: 5),
        width: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: IconButton(
          icon: Transform.translate(
            offset: const Offset(-2, 0),
            child: SvgPicture.asset('assets/icons/send_button.svg'),
          ),
          //  InheritedChatTheme.of(context).theme.sendButtonIcon != null
          //     ? InheritedChatTheme.of(context).theme.sendButtonIcon!
          //     : CircleAvatar(
          //         backgroundColor: clickable ? Colors.blue : Colors.grey,
          //         radius: 20,
          //         child: SvgPicture.asset(
          //           'assets/icons/send_button.svg',
          //           color: Colors.white,
          //           height: 20,
          //           package: 'flutter_chat_ui',
          //         ),
          //       ),
          onPressed: clickable ? onPressed : null,
          padding: EdgeInsets.zero,
          tooltip: InheritedL10n.of(context).l10n.sendButtonAccessibilityLabel,
        ),
      );
}
