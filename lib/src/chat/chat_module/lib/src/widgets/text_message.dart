import 'dart:convert';

// import 'package:flavor_example/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/src/widgets/inherited_chat_theme.dart';
import 'package:intl/intl.dart';

// import 'package:flutter_link_previewer/flutter_link_previewer.dart'
//     show LinkPreview;
const regexLink =
    r'((http|ftp|https):\/\/)?([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?';

/// A class that represents text message widget with optional link preview
class TextMessage extends StatelessWidget {
  /// Creates a text message widget from a [types.TextMessage] class
  const TextMessage({
    Key? key,
    required this.message,
    this.onPreviewDataFetched,
    required this.usePreviewData,
    required this.showName,
  }) : super(key: key);

  /// [types.TextMessage]
  final types.TextMessage message;

  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// Show user name for the received message. Useful for a group chat.
  final bool showName;

  /// Enables link (URL) preview
  final bool usePreviewData;

  // void _onPreviewDataFetched(types.PreviewData previewData) {
  //   if (message.previewData == null) {
  //     onPreviewDataFetched?.call(message, previewData);
  //   }
  // }
  // Widget _linkPreview(
  //   types.User user,
  //   double width,
  //   BuildContext context,
  // ) {
  //   final bodyTextStyle = user.id == message.author.id
  //       ? InheritedChatTheme.of(context).theme.sentMessageBodyTextStyle
  //       : InheritedChatTheme.of(context).theme.receivedMessageBodyTextStyle;
  //   final linkDescriptionTextStyle = user.id == message.author.id
  //       ? InheritedChatTheme.of(context)
  //           .theme
  //           .sentMessageLinkDescriptionTextStyle
  //       : InheritedChatTheme.of(context)
  //           .theme
  //           .receivedMessageLinkDescriptionTextStyle;
  //   final linkTitleTextStyle = user.id == message.author.id
  //       ? InheritedChatTheme.of(context).theme.sentMessageLinkTitleTextStyle
  //       : InheritedChatTheme.of(context)
  //           .theme
  //           .receivedMessageLinkTitleTextStyle;
  //
  //   final color = getUserAvatarNameColor(message.author,
  //       InheritedChatTheme.of(context).theme.userAvatarNameColors);
  //   final name = getUserName(message.author);
  //   return LinkPreview(
  //     enableAnimation: true,
  //     header: showName ? name : null,
  //     headerStyle: InheritedChatTheme.of(context)
  //         .theme
  //         .userNameTextStyle
  //         .copyWith(color: color),
  //     linkStyle: bodyTextStyle,
  //     metadataTextStyle: linkDescriptionTextStyle,
  //     metadataTitleStyle: linkTitleTextStyle,
  //     onPreviewDataFetched: _onPreviewDataFetched,
  //     padding: EdgeInsets.symmetric(
  //       horizontal:
  //           InheritedChatTheme.of(context).theme.messageInsetsHorizontal,
  //       vertical: InheritedChatTheme.of(context).theme.messageInsetsVertical,
  //     ),
  //     previewData: message.previewData,
  //     text: message.text,
  //     textStyle: bodyTextStyle,
  //     width: width,
  //   );
  // }

  Widget _textWidgetBuilder(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showName)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: InheritedChatTheme.of(context).theme.userNameTextStyle,
              ),
            ),
          SelectableText(
            utf8.fuse(base64).decode(message.payload.toString()),
            style: message.initiated == true
                ? InheritedChatTheme.of(context)
                    .theme
                    .sentMessageBodyTextStyle
                    .copyWith(color: Colors.white)
                : InheritedChatTheme.of(context)
                    .theme
                    .receivedMessageBodyTextStyle,
            textWidthBasis: TextWidthBasis.longestLine,
          ),
          Text(
            // '${DateFormat().format(DateF) message.createdAt}',
            '${DateFormat('h:mm a').format(DateTime.fromMicrosecondsSinceEpoch((int.tryParse(message.deliveredAt.toString()) ?? 0) * 1000))}',
            // style: Styles.grey10.copyWith(
            //   color: message.initiated == true
            //       ? Colors.white.withOpacity(.8)
            //       : Colors.grey,
            //   fontStyle: FontStyle.italic,
            // ),
            textAlign: TextAlign.right,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          // border: message.initiated == true
          //     ? Border.all(color: Colors.grey)
          //     : Border.all(color: Colors.blue),
          borderRadius: const BorderRadius.only(
              // topLeft: Radius.circular(20),
              // bottomLeft: Radius.circular(20),
              // bottomRight: Radius.circular(20),
              // topRight: Radius.circular(20),
              ),
          color: message.initiated == true
              ? Theme.of(context).secondaryHeaderColor
              : Colors.white,
        ),
        padding: const EdgeInsets.all(15.0),
        child: _textWidgetBuilder(context),
      );
}
