part of '../stream_view.dart';

/// Applies [IsmLiveStreamScreenConfigure] chat width rules to [chatView].
Widget _wrapStreamChatView(BuildContext context, Widget chatView) {
  final screenConfigure = IsmLiveDelegate.streamScreenConfigure;

  // Keep chat anchored to the left in all modes so keyboard/layout changes
  // don't visually shift it horizontally when sibling widgets hide/show.
  if (screenConfigure.resolveConstrainChatViewWidth()) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width *
              screenConfigure.resolveChatViewMaxWidthFraction(),
        ),
        child: chatView,
      ),
    );
  }

  return Align(
    alignment: Alignment.centerLeft,
    child: chatView,
  );
}