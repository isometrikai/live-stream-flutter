import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Builder function for customizing chat message items
///
/// - [context]: BuildContext for accessing theme and media query
/// - [message]: The message object containing all message data
/// - [defaultChild]: The default chat message widget that can be used or modified
///
/// Returns a custom Widget or the modified defaultChild
typedef IsmLiveChatMessageBuilder = Widget Function(
  BuildContext context,
  dynamic message,
  Widget defaultChild,
);

/// Callback function for customizing chat message background color
///
/// - [message]: The message object containing all message data
///
/// Returns a Color for the message background, or null to use default
typedef IsmLiveChatItemBgColorCallback = Color? Function(dynamic message);

class IsmLiveChatView extends StatefulWidget {
  IsmLiveChatView({
    super.key,
    required this.isHost,
    required this.streamId,
    this.chatMessageBuilder,
    this.chatItemBgColorCallback,
  });

  final bool isHost;
  final String streamId;
  final IsmLiveChatMessageBuilder? chatMessageBuilder;
  final IsmLiveChatItemBgColorCallback? chatItemBgColorCallback;

  @override
  State<IsmLiveChatView> createState() => _IsmLiveChatViewState();
}

class _IsmLiveChatViewState extends State<IsmLiveChatView> {
  final messagesListController = ScrollController();
  final _controller = Get.find<IsmLiveStreamController>();
  bool _isScrolling = false;

  @override
  void initState() {
    messagesListController.addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    if (!_isScrolling) {
      _isScrolling = true;
      _controller.messagePagination(messagesListController);
      Future.delayed(const Duration(milliseconds: 100), () {
        _isScrolling = false;
      });
    }
  }

  @override
  void dispose() {
    try {
      messagesListController.removeListener(_scrollListener);
      messagesListController.dispose();
    } catch (e) {
      IsmLiveLog('chat controller error $e');
    }
    super.dispose();
  }

  void _scrollToBottom() {
    if (messagesListController.hasClients) {
      messagesListController.animateTo(
        messagesListController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) => GetX<IsmLiveStreamController>(
        builder: (controller) {
          // Scroll to bottom when new message arrives
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.streamMessagesList.isNotEmpty) {
              _scrollToBottom();
            }
          });

          return ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.white,
                Colors.white,
              ],
              stops: [0.0, 0.1, 1.0],
            ).createShader(rect),
            blendMode: BlendMode.dstIn,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: controller.participantTracks.length < 2
                    ? IsmLiveDimens.percentHeight(0.35)
                    : controller.participantTracks.length < 4
                        ? IsmLiveDimens.percentHeight(0.3)
                        : IsmLiveDimens.percentHeight(0.15),
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: ListView.builder(
                controller: messagesListController,
                padding: IsmLiveDimens.edgeInsets0_8,
                shrinkWrap: true,
                itemCount: controller.streamMessagesList.length,
                itemBuilder: (context, index) {
                  final message = controller.streamMessagesList[index];

                  // Get custom background color if callback provided
                  final customBackgroundColor =
                      widget.chatItemBgColorCallback?.call(message);

                  // Build default chat message widget
                  final defaultMessageWidget = _ChatMessageItem(
                    message: message,
                    isHost: widget.isHost,
                    backgroundColor: customBackgroundColor,
                    onTap: () {
                      var openSheet = message.sentByHost
                          ? (controller.isCopublisher ||
                              controller.isModerator ||
                              controller.isMember ||
                              controller.isHost)
                          : true;
                      if (!message.isEvent && !message.isDeleted && openSheet) {
                        IsmLiveUtility.openBottomSheet(
                          ChatBottomSheet(
                            message: message,
                          ),
                        );
                      }
                    },
                  );

                  // Use custom builder if provided, otherwise use default
                  return widget.chatMessageBuilder?.call(
                        context,
                        message,
                        defaultMessageWidget,
                      ) ??
                      defaultMessageWidget;
                },
              ),
            ),
          );
        },
      );
}

class _ChatMessageItem extends StatelessWidget {
  const _ChatMessageItem({
    required this.message,
    required this.isHost,
    required this.onTap,
    this.backgroundColor,
  });

  final dynamic message;
  final bool isHost;
  final VoidCallback onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: IsmLiveTapHandler(
              onTap: onTap,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: backgroundColor ?? Colors.black26,
                  borderRadius: BorderRadius.circular(IsmLiveDimens.ten),
                ),
                child: Padding(
                  padding: IsmLiveDimens.edgeInsets8_4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IsmLiveImage.network(
                        IsmLiveDelegate.getUserProfileUrl
                                ?.call(message.imageUrl) ??
                            message.imageUrl,
                        name: message.userName,
                        dimensions: IsmLiveDimens.twentyFour,
                        isProfileImage: true,
                      ),
                      IsmLiveDimens.boxWidth4,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    '${message.userName}${message.sentByMe ? " (You)" : ""}',
                                    style:
                                        context.textTheme.labelSmall!.copyWith(
                                      color: IsmLiveColors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (message.sentByHost) ...[
                                  IsmLiveDimens.boxWidth8,
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: (context.liveTheme?.primaryColor ??
                                              IsmLiveColors.primary)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(
                                          IsmLiveDimens.four),
                                    ),
                                    child: Padding(
                                      padding: IsmLiveDimens.edgeInsets6_2,
                                      child: Text(
                                        'Host',
                                        style: context.textTheme.labelSmall
                                            ?.copyWith(
                                          color: IsmLiveColors.white
                                              .withOpacity(0.7),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (message.isDeleted)
                              Text(
                                ' ${message.body} Deleted Message',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            else ...[
                              if (message.isReply &&
                                  message.parentBody != null) ...[
                                Text(
                                  'Reply to ${message.parentBody}',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: Colors.white70,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              Column(
                                children: [
                                  Text(
                                    message.body,
                                    style:
                                        context.textTheme.labelMedium?.copyWith(
                                      color: IsmLiveColors.white,
                                    ),
                                    softWrap: true,
                                  ),
                                  if (message.isCopublisherRequest)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: IsmLiveDimens.hundred,
                                          height: IsmLiveDimens.thirtyTwo +
                                              IsmLiveDimens.two,
                                          child: IsmLiveButton(
                                            label: 'accept',
                                            onTap: () {
                                              final controller = Get.find<
                                                  IsmLiveStreamController>();
                                              controller
                                                  .acceptCopublisherRequest(
                                                requestById: message.userId,
                                                streamId:
                                                    controller.streamId ?? '',
                                              );
                                              controller.streamMessagesList[
                                                      controller
                                                          .streamMessagesList
                                                          .indexOf(message)] =
                                                  message.copyWith(
                                                      isCopublisherRequest:
                                                          false);
                                            },
                                          ),
                                        ),
                                        IsmLiveDimens.boxWidth2,
                                        SizedBox(
                                          width: IsmLiveDimens.hundred,
                                          height: IsmLiveDimens.thirtyTwo +
                                              IsmLiveDimens.two,
                                          child: IsmLiveButton(
                                            label: 'deny',
                                            onTap: () {
                                              final controller = Get.find<
                                                  IsmLiveStreamController>();
                                              controller.denyCopublisherRequest(
                                                requestById: message.userId,
                                                streamId:
                                                    controller.streamId ?? '',
                                              );
                                              controller.streamMessagesList[
                                                      controller
                                                          .streamMessagesList
                                                          .indexOf(message)] =
                                                  message.copyWith(
                                                      isCopublisherRequest:
                                                          false);
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
