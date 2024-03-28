// import 'package:flavor_example/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_ui/src/widgets/inherited_chat_theme.dart';
import 'package:flutter_chat_ui/src/widgets/inherited_l10n.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

/// A class that represents file message widget
class FileMessage extends StatelessWidget {
  /// Creates a file message widget based on a [types.FileMessage]
  const FileMessage({
    Key? key,
    required this.message,
  }) : super(key: key);

  /// [types.FileMessage]
  final types.FileMessage message;

  @override
  Widget build(BuildContext context) {
    // final _user = InheritedUser.of(context).user;
    final _color = message.initiated == true
        ? InheritedChatTheme.of(context).theme.sentMessageDocumentIconColor
        : InheritedChatTheme.of(context).theme.receivedMessageDocumentIconColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: InheritedL10n.of(context).l10n.fileButtonAccessibilityLabel,
          child: Container(
            decoration: BoxDecoration(
              border: message.initiated == true
                  ? Border.all(color: Colors.grey)
                  : Border.all(color: Colors.blue),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              InheritedChatTheme.of(context).theme.messageInsetsVertical,
              InheritedChatTheme.of(context).theme.messageInsetsVertical,
              InheritedChatTheme.of(context).theme.messageInsetsHorizontal,
              InheritedChatTheme.of(context).theme.messageInsetsVertical,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(21),
                  ),
                  height: 42,
                  width: 42,
                  child: InheritedChatTheme.of(context).theme.documentIcon !=
                          null
                      ? InheritedChatTheme.of(context).theme.documentIcon!
                      : message.fileName.toString().contains('.pdf')
                          ? SvgPicture.asset(
                              'assets/pdf.svg',
                              package: 'flutter_chat_ui',
                            )
                          : message.fileName.toString().contains('.doc')
                              ? SvgPicture.asset(
                                  'assets/doc.svg',
                                  package: 'flutter_chat_ui',
                                )
                              : message.fileName.toString().contains('.txt')
                                  ? SvgPicture.asset(
                                      'assets/txt.svg',
                                      package: 'flutter_chat_ui',
                                    )
                                  : message.fileName.toString().contains('.xls')
                                      ? SvgPicture.asset(
                                          'assets/xls.svg',
                                          package: 'flutter_chat_ui',
                                        )
                                      : Image.asset(
                                          'assets/default-doc.png',
                                          package: 'flutter_chat_ui',
                                        ),
                ),
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.fileName.toString(),
                          style: message.initiated == true
                              ? InheritedChatTheme.of(context)
                                  .theme
                                  .sentMessageBodyTextStyle
                              : InheritedChatTheme.of(context)
                                  .theme
                                  .receivedMessageBodyTextStyle,
                          textWidthBasis: TextWidthBasis.longestLine,
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            top: 4,
                          ),
                          child: Text(
                            formatBytes(
                                int.tryParse(message.dataSize.toString()) ?? 0),
                            style: message.initiated == true
                                ? InheritedChatTheme.of(context)
                                    .theme
                                    .sentMessageCaptionTextStyle
                                : InheritedChatTheme.of(context)
                                    .theme
                                    .receivedMessageCaptionTextStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(5),
          child: Text(
            // '${DateFormat().format(DateF) message.createdAt}',
            '${DateFormat('h:mm a').format(DateTime.fromMicrosecondsSinceEpoch((int.tryParse(message.deliveredAt.toString()) ?? 0) * 1000))}',
            // style: Styles.grey10.copyWith(
            //   color: message.initiated == true
            //       ? Colors.black.withOpacity(.8)
            //       : Colors.grey,
            //   fontStyle: FontStyle.italic,
            // ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
