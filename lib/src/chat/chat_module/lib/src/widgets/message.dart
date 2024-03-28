import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_ui/src/widgets/inherited_chat_theme.dart';

/// Base widget for all message types in the chat. Renders bubbles around
/// messages and status. Sets maximum width for a message for
/// a nice look on larger screens.
class Message extends StatelessWidget {
  /// Creates a particular message from any message type
  const Message({
    Key? key,
    this.customMessageBuilder,
    required this.message,
    this.imageMessageBuilder,
    this.videoMessageBuilder,
    required this.messageWidth,
    this.fileMessageBuilder,
    this.onMessageLongPress,
    this.onMessageTap,
    this.onPreviewDataFetched,
    required this.roundBorder,
    required this.showAvatar,
    required this.showName,
    required this.showStatus,
    required this.showUserAvatars,
    required this.usePreviewData,
  }) : super(key: key);

  /// Build a custom message inside predefined bubble
  final Widget Function(types.CustomMessage)? customMessageBuilder;

  /// Any message type
  final types.MessageData message;

  /// Maximum message width
  final int messageWidth;

  /// Build a file message inside predefined bubble
  final Widget Function(types.FileMessage, {required int messageWidth})?
      fileMessageBuilder;

  /// Called when user makes a long press on any message
  final void Function(types.MessageData)? onMessageLongPress;

  /// Called when user taps on any message
  final void Function(types.MessageData)? onMessageTap;

  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// Rounds border of the message to visually group messages together.
  final bool roundBorder;

  /// Show user avatar for the received message. Useful for a group chat.
  final bool showAvatar;

  final bool showName;

  /// Show message's status
  final bool showStatus;

  /// Show user avatars for received messages. Useful for a group chat.
  final bool showUserAvatars;

  final bool usePreviewData;

  /// Build an image message inside predefined bubble
  final Widget Function(types.ImageMessage, {required int messageWidth})?
      imageMessageBuilder;

  final Widget Function(types.VideoMessage, {required int messageWidth})?
      videoMessageBuilder;
  Widget _avatarBuilder(BuildContext context) {
    // final color = getUserAvatarNameColor(
    //   message.receiverId,
    //   InheritedChatTheme.of(context).theme.userAvatarNameColors,
    // );
    final hasImage = message.messageType == 2;
    // final name = getUserName(types.User());

    return showAvatar
        ? Container(
            margin: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              backgroundColor: hasImage
                  ? InheritedChatTheme.of(context)
                      .theme
                      .userAvatarImageBackgroundColor
                  : InheritedChatTheme.of(context)
                      .theme
                      .userAvatarImageBackgroundColor,
              backgroundImage:
                  hasImage ? NetworkImage(message.thumbnail.toString()) : null,
              radius: 16,
              child: !hasImage
                  ? Text(
                      '',
                      style: InheritedChatTheme.of(context)
                          .theme
                          .userAvatarTextStyle,
                    )
                  : null,
            ),
          )
        : const SizedBox(width: 40);
  }

  Widget _messageBuilder() {
    switch (message.messageType) {
      case 100:
        final customMessage = message as types.CustomMessage;
        return customMessageBuilder != null
            ? customMessageBuilder!(customMessage)
            : const SizedBox();
      case 10:
        final fileMessage = message as types.FileMessage;
        return fileMessageBuilder != null
            ? fileMessageBuilder!(fileMessage, messageWidth: messageWidth)
            : FileMessage(message: fileMessage);
      case 2:
        final imageMessage = message as types.ImageMessage;
        return imageMessageBuilder != null
            ? imageMessageBuilder!(imageMessage, messageWidth: messageWidth)
            : ImageMessage(message: imageMessage, messageWidth: messageWidth);
      case 3:
        final videoMessage = message as types.VideoMessage;
        return videoMessageBuilder != null
            ? videoMessageBuilder!(videoMessage, messageWidth: messageWidth)
            : VideoMessage(message: videoMessage, messageWidth: messageWidth);
      case 1:
        final textMessage = message as types.TextMessage;
        return TextMessage(
          message: textMessage,
          onPreviewDataFetched: onPreviewDataFetched,
          showName: showName,
          usePreviewData: usePreviewData,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _statusBuilder(BuildContext context) {
    switch (message.status) {
      case 2:
      case 1:
        return InheritedChatTheme.of(context).theme.deliveredIcon != null
            ? InheritedChatTheme.of(context).theme.deliveredIcon!
            : Image.asset(
                'assets/icon-delivered.png',
                color: const Color(0xFF17A6DD),
                package: 'flutter_chat_ui',
              );
      // case types.Status.error:
      //   return InheritedChatTheme.of(context).theme.errorIcon != null
      //       ? InheritedChatTheme.of(context).theme.errorIcon!
      //       : Image.asset(
      //           'assets/icon-error.png',
      //           color: InheritedChatTheme.of(context).theme.colorScheme.error,
      //           package: 'flutter_chat_ui',
      //         );
      case 3:
        return InheritedChatTheme.of(context).theme.seenIcon != null
            ? InheritedChatTheme.of(context).theme.seenIcon!
            : Image.asset(
                'assets/icon-seen.png',
                color: const Color(0xFF17A6DD),
                package: 'flutter_chat_ui',
              );
      // case types.Status.sending:
      //   return InheritedChatTheme.of(context).theme.sendingIcon != null
      //       ? InheritedChatTheme.of(context).theme.sendingIcon!
      //       : Center(
      //           child: SizedBox(
      //             height: 10,
      //             width: 10,
      //             child: CircularProgressIndicator(
      //               backgroundColor: Colors.transparent,
      //               strokeWidth: 1.5,
      //               valueColor: AlwaysStoppedAnimation<Color>(
      //                 InheritedChatTheme.of(context).theme.primaryColor,
      //               ),
      //             ),
      //           ),
      //         );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    // final _user = InheritedUser.of(context).user;
    final _currentUserIsAuthor = message.initiated == true;
    final _messageBorderRadius = 12.0;
    // InheritedChatTheme.of(context).theme.messageBorderRadius;
    final _borderRadius = BorderRadius.only(
      bottomLeft: Radius.circular(
        _currentUserIsAuthor || roundBorder ? _messageBorderRadius : 0,
      ),
      bottomRight: Radius.circular(_currentUserIsAuthor
          ?
          //  roundBorder
          //     ?
          _messageBorderRadius
          // : 0
          : _messageBorderRadius),
      topLeft: Radius.circular(_messageBorderRadius),
      topRight: Radius.circular(
        !_currentUserIsAuthor ? _messageBorderRadius : 0,
      ),
    );

    return Container(
      alignment:
          _currentUserIsAuthor ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.only(
        bottom: 4,
        left: 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_currentUserIsAuthor && showUserAvatars) _avatarBuilder(context),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: messageWidth.toDouble(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onLongPress: () => onMessageLongPress?.call(message),
                  onTap: () => onMessageTap?.call(message),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: _borderRadius,
                      // color: _currentUserIsAuthor
                      //     ? InheritedChatTheme.of(context).theme.secondaryColor
                      //     : InheritedChatTheme.of(context).theme.primaryColor,
                    ),
                    child: ClipRRect(
                      borderRadius: _borderRadius,
                      child: _messageBuilder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_currentUserIsAuthor)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Center(
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: showStatus ? _statusBuilder(context) : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
