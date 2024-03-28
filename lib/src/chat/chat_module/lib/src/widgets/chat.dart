import 'dart:math';

// import 'package:chewie/chewie.dart';
// import 'package:flavor_example/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_ui/src/conditional/conditional.dart';
import 'package:flutter_chat_ui/src/models/date_header.dart';
import 'package:flutter_chat_ui/src/models/message_spacer.dart';
import 'package:flutter_chat_ui/src/models/preview_image.dart';
import 'package:flutter_chat_ui/src/util.dart';
import 'package:flutter_chat_ui/src/widgets/inherited_chat_theme.dart';
import 'package:flutter_chat_ui/src/widgets/inherited_l10n.dart';
// import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view_gallery.dart';
// import 'package:video_player/video_player.dart';

/// Entry widget, represents the complete chat. If you wrap it in [SafeArea] and
/// it should be full screen, set [SafeArea]'s `bottom` to `false`.
class Chat extends StatefulWidget {
  /// Creates a chat widget
  const Chat(
      {Key? key,
      this.customBottomWidget,
      this.customDateHeaderText,
      this.customMessageBuilder,
      this.dateFormat,
      this.dateLocale,
      this.disableImageGallery,
      this.emptyState,
      this.imageMessageBuilder,
      this.videoMessageBuilder,
      this.fileMessageBuilder,
      this.isAttachmentUploading,
      this.isLastPage,
      this.l10n = const ChatL10nEn(),
      required this.messages,
      this.onAttachmentPressed,
      this.onEndReached,
      this.onEndReachedThreshold,
      this.onMessageLongPress,
      this.onMessageTap,
      this.onPreviewDataFetched,
      required this.onSendPressed,
      this.onTextChanged,
      this.onTextFieldTap,
      this.sendButtonVisibilityMode = SendButtonVisibilityMode.editing,
      this.showUserAvatars = false,
      this.showUserNames = false,
      this.theme = const DefaultChatTheme(),
      this.timeFormat,
      this.usePreviewData = true,
      required this.appBarWidget})
      : super(key: key);

  /// Allows you to replace the default Input widget e.g. if you want to create
  /// a channel view.
  final Widget? customBottomWidget;

  /// If [dateFormat], [dateLocale] and/or [timeFormat] is not enough to
  /// customize date headers in your case, use this to return an arbitrary
  /// string based on a [DateTime] of a particular message. Can be helpful to
  /// return "Today" if [DateTime] is today. IMPORTANT: this will replace
  /// all default date headers, so you must handle all cases yourself, like
  /// for example today, yesterday and before. Or you can just return the same
  /// date header for any message.
  final String Function(DateTime)? customDateHeaderText;

  /// See [Message.customMessageBuilder]
  final Widget Function(types.MessageData)? customMessageBuilder;

  /// See [Message.fileMessageBuilder]
  final Widget Function(types.FileMessage, {required int messageWidth})?
      fileMessageBuilder;

  /// Allows you to customize the date format. IMPORTANT: only for the date,
  /// do not return time here. See [timeFormat] to customize the time format.
  /// [dateLocale] will be ignored if you use this, so if you want a localized date
  /// make sure you initialize your [DateFormat] with a locale. See [customDateHeaderText]
  /// for more customization.
  final DateFormat? dateFormat;

  final Widget appBarWidget;

  /// Locale will be passed to the `Intl` package. Make sure you initialized
  /// date formatting in your app before passing any locale here, otherwise
  /// an error will be thrown. Also see [customDateHeaderText], [dateFormat], [timeFormat].
  final String? dateLocale;

  /// Disable automatic image preview on tap.
  final bool? disableImageGallery;

  /// Allows you to change what the user sees when there are no messages.
  /// `emptyChatPlaceholder` and `emptyChatPlaceholderTextStyle` are ignored
  /// in this case.
  final Widget? emptyState;

  /// See [Input.isAttachmentUploading]
  final bool? isAttachmentUploading;

  /// See [ChatList.isLastPage]
  final bool? isLastPage;

  /// Localized copy. Extend [ChatL10n] class to create your own copy or use
  /// existing one, like the default [ChatL10nEn]. You can customize only
  /// certain properties, see more here [ChatL10nEn].
  final ChatL10n l10n;

  /// List of [types.MessageData] to render in the chat widget
  final List<types.MessageData> messages;

  /// See [Input.onAttachmentPressed]
  final void Function()? onAttachmentPressed;

  /// See [ChatList.onEndReached]
  final Future<void> Function()? onEndReached;

  /// See [ChatList.onEndReachedThreshold]
  final double? onEndReachedThreshold;

  /// See [Message.onMessageLongPress]
  final void Function(types.MessageData)? onMessageLongPress;

  /// See [Message.onMessageTap]
  final void Function(types.MessageData)? onMessageTap;

  /// See [Message.onPreviewDataFetched]
  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// See [Input.onSendPressed]
  final void Function(types.PartialText) onSendPressed;

  /// See [Input.onTextChanged]
  final void Function(String)? onTextChanged;

  /// See [Input.onTextFieldTap]
  final void Function()? onTextFieldTap;

  /// See [Input.sendButtonVisibilityMode]
  final SendButtonVisibilityMode sendButtonVisibilityMode;

  /// See [Message.showUserAvatars]
  final bool showUserAvatars;

  /// Show user names for received messages. Useful for a group chat. Will be
  /// shown only on text messages.
  final bool showUserNames;

  /// See [Message.imageMessageBuilder]
  final Widget Function(types.ImageMessage, {required int messageWidth})?
      imageMessageBuilder;

  final Widget Function(types.VideoMessage, {required int messageWidth})?
      videoMessageBuilder;

  /// Chat theme. Extend [ChatTheme] class to create your own theme or use
  /// existing one, like the [DefaultChatTheme]. You can customize only certain
  /// properties, see more here [DefaultChatTheme].
  final ChatTheme theme;

  /// Allows you to customize the time format. IMPORTANT: only for the time,
  /// do not return date here. See [dateFormat] to customize the date format.
  /// [dateLocale] will be ignored if you use this, so if you want a localized time
  /// make sure you initialize your [DateFormat] with a locale. See [customDateHeaderText]
  /// for more customization.
  final DateFormat? timeFormat;

  /// See [Message.usePreviewData]
  final bool usePreviewData;

  @override
  _ChatState createState() => _ChatState();
}

/// [Chat] widget state
class _ChatState extends State<Chat> {
  List<Object> _chatMessages = [];
  List<PreviewImage> _gallery = [];
  int _imageViewIndex = 0;
  bool isImageViewVisible = false;

  @override
  void initState() {
    super.initState();

    didUpdateWidget(widget);
  }

  @override
  void didUpdateWidget(covariant Chat oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.messages.isNotEmpty) {
      final result = calculateChatMessages(
        widget.messages,
        customDateHeaderText: widget.customDateHeaderText,
        dateFormat: widget.dateFormat,
        dateLocale: widget.dateLocale,
        showUserNames: widget.showUserNames,
        timeFormat: widget.timeFormat,
      );

      _chatMessages = result[0] as List<Object>;
      _gallery = result[1] as List<PreviewImage>;
    }
  }

  Widget _emptyStateBuilder() =>
      widget.emptyState ??
      Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: Text(
          widget.l10n.emptyChatPlaceholder,
          style: widget.theme.emptyChatPlaceholderTextStyle,
          textAlign: TextAlign.center,
        ),
      );

  Widget imageGalleryBuilder() => Dismissible(
        key: const Key('photo_view_gallery'),
        direction: DismissDirection.down,
        onDismissed: (direction) => _onCloseGalleryPressed(),
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              builder: (BuildContext context, int index) =>
                  PhotoViewGalleryPageOptions(
                imageProvider:
                    Conditional().getProvider(_gallery[index].payload),
              ),
              itemCount: _gallery.length,
              loadingBuilder: _imageGalleryLoadingBuilder,
              onPageChanged: _onPageChanged,
              pageController: PageController(initialPage: _imageViewIndex),
              scrollPhysics: const ClampingScrollPhysics(),
            ),
            Positioned(
              right: 16,
              top: 56,
              child: CloseButton(
                color: Colors.white,
                onPressed: _onCloseGalleryPressed,
              ),
            ),
          ],
        ),
      );

  Widget _imageGalleryLoadingBuilder(
    BuildContext context,
    ImageChunkEvent? event,
  ) =>
      Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            value: event == null || event.expectedTotalBytes == null
                ? 0
                : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
          ),
        ),
      );

  Widget _messageBuilder(Object object, BoxConstraints constraints) {
    if (object is DateHeader) {
      return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(
          bottom: 32,
          top: 16,
        ),
        child: Text(
          object.text,
          style: widget.theme.dateDividerTextStyle,
        ),
      );
    } else if (object is MessageSpacer) {
      return SizedBox(
        height: object.height,
      );
    } else {
      final map = object as Map<String, Object>;
      final message = map['message']! as types.MessageData;
      final _messageWidth = widget.showUserAvatars
          // && message.receiverId != widget.user.receiverId
          ? min(constraints.maxWidth * 0.72, 440).floor()
          : min(constraints.maxWidth * 0.78, 440).floor();

      return Message(
        customMessageBuilder: widget.customMessageBuilder,
        message: message,
        imageMessageBuilder: widget.imageMessageBuilder,
        videoMessageBuilder: widget.videoMessageBuilder,
        messageWidth: _messageWidth,
        fileMessageBuilder: widget.fileMessageBuilder,
        onMessageLongPress: widget.onMessageLongPress,
        onMessageTap: (tappedMessage) async {
          //   final stringToBase64 = utf8.fuse(base64);
          //   // final _homeController = Get.find<HomeController>();

          //   if (tappedMessage is types.ImageMessage &&
          //       widget.disableImageGallery != true) {
          //     _onImagePressed(tappedMessage);
          //   }
          //   if (tappedMessage is types.VideoMessage) {
          //     // final _controller = VideoPlayerController.network(
          //     //     '${_homeController.mediaBaseUrl}/${stringToBase64.decode(tappedMessage.payload!)}');
          //     // await _controller.initialize();
          //     // await _controller.play();

          //     final _chewieController = ChewieController(
          //       videoPlayerController: _controller,
          //       aspectRatio: _controller.value.aspectRatio,
          //       autoInitialize: true,
          //       autoPlay: true,
          //       looping: true,
          //       errorBuilder: (context, errorMessage) => Center(
          //         child: Text(
          //           errorMessage,
          //           style: const TextStyle(color: Colors.white),
          //         ),
          //       ),
          //     );
          //     if (!Get.isDialogOpen!) {
          //       await showDialog<void>(
          //         context: context,
          //         builder: (context) => Center(
          //           child: Container(
          //             color: Colors.black,
          //             height: 300,
          //             width: MediaQuery.of(context).size.width - 32,
          //             child: Center(
          //               child: Material(
          //                 child: Chewie(
          //                   controller: _chewieController,
          //                 ),
          //               ),
          //             ),
          //             // child: VideoPlayer(_controller),
          //           ),
          //         ),
          //       ).then((value) {
          //         _controller.dispose();
          //         _chewieController.dispose();
          //       });
          //     }
          //   }

          widget.onMessageTap?.call(tappedMessage);
        },
        onPreviewDataFetched: _onPreviewDataFetched,
        roundBorder: map['nextMessageInGroup'] == true,
        showAvatar: map['nextMessageInGroup'] == false,
        showName: map['showName'] == true,
        showStatus: map['showStatus'] == true,
        showUserAvatars: widget.showUserAvatars,
        usePreviewData: widget.usePreviewData,
      );
    }
  }

  void _onCloseGalleryPressed() {
    setState(() {
      isImageViewVisible = false;
    });
  }

  void _onImagePressed(types.ImageMessage message) {
    setState(() {
      _imageViewIndex = _gallery.indexWhere(
        (element) =>
            element.messageId == message.messageId &&
            element.payload == message.payload,
      );
      isImageViewVisible = true;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _imageViewIndex = index;
    });
  }

  void _onPreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    widget.onPreviewDataFetched?.call(message, previewData);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: widget.appBarWidget,
        ),
        body: InheritedChatTheme(
          theme: widget.theme,
          child: InheritedL10n(
            l10n: widget.l10n,
            child: Stack(
              children: [
                Container(
                  color: widget.theme.backgroundColor,
                  child: Column(
                    children: [
                      Flexible(
                        child: widget.messages.isEmpty
                            ? SizedBox.expand(
                                child: _emptyStateBuilder(),
                              )
                            : GestureDetector(
                                onTap: () => FocusManager.instance.primaryFocus
                                    ?.unfocus(),
                                child: LayoutBuilder(
                                  builder: (BuildContext context,
                                          BoxConstraints constraints) =>
                                      ChatList(
                                    isLastPage: widget.isLastPage,
                                    itemBuilder: (item, index) =>
                                        _messageBuilder(item, constraints),
                                    items: _chatMessages,
                                    onEndReached: widget.onEndReached,
                                    onEndReachedThreshold:
                                        widget.onEndReachedThreshold,
                                  ),
                                ),
                              ),
                      ),
                      widget.customBottomWidget ??
                          Input(
                            isAttachmentUploading: widget.isAttachmentUploading,
                            onAttachmentPressed: widget.onAttachmentPressed,
                            onSendPressed: widget.onSendPressed,
                            onTextChanged: widget.onTextChanged,
                            onTextFieldTap: widget.onTextFieldTap,
                            sendButtonVisibilityMode:
                                widget.sendButtonVisibilityMode,
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
