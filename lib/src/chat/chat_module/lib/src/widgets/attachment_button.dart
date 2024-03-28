import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/src/widgets/inherited_l10n.dart';
import 'package:flutter_svg/svg.dart';

/// A class that represents attachment button widget
class AttachmentButton extends StatelessWidget {
  /// Creates attachment button widget
  const AttachmentButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  /// Callback for attachment button tap event
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) => Container(
        height: 24,
        margin: const EdgeInsets.only(right: 5),
        width: 24,
        child: IconButton(
          icon: SvgPicture.asset('assets/icons/attatcthment.svg'),
          // InheritedChatTheme.of(context).theme.attachmentButtonIcon != null
          //     ? InheritedChatTheme.of(context).theme.attachmentButtonIcon!
          //     : const Icon(Icons.attach_file,color: Colors.black,),
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          tooltip:
              InheritedL10n.of(context).l10n.attachmentButtonAccessibilityLabel,
        ),
      );
}
