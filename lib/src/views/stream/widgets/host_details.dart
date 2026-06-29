import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class IsmLiveHostDetail extends StatelessWidget {
  const IsmLiveHostDetail({
    super.key,
    required this.name,
    required this.handle,
    required this.imageUrl,
    required this.description,
    required this.isHost,
    required this.userIdentifier,
    required this.initials,
  });

  final String name;
  /// Shown in the header pill as @handle (metadata or root login name).
  final String handle;
  final String imageUrl;
  final String description;
  final String initials;
  final String userIdentifier;
  final bool isHost;

  Color _pillColor(BuildContext context) =>
      context.liveTheme?.primaryColor ??
      (Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black);

  Future<void> _onProfileTap(BuildContext context) async {
    final hostTopProfileCallback =
        IsmLiveDelegate.streamScreenConfigure.hostTopProfileClickCallback;
    if (hostTopProfileCallback != null) {
      final handled = await hostTopProfileCallback(
        context,
        isHost,
        userIdentifier,
        name,
        imageUrl,
        description,
      );

      if (handled) {
        return;
      }
    }

    final sheetBg = context.liveTheme?.backgroundColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF121212)
            : Colors.white);

    IsmLiveUtility.openBottomSheet(
      StreamLiveSheet(
        widget: IsmLiveImage.network(
          imageUrl,
          isProfileImage: true,
          name: name,
          initials: initials,
          height: IsmLiveDimens.hundred,
          width: IsmLiveDimens.hundred,
        ),
        title: name,
        subTitle: description.trim().isEmpty ? null : description,
        buttonLable: isHost ? null : IsmLiveStrings.viewProfile,
        onTap: isHost
            ? null
            : () {
                IsmLiveDelegate.openUserProfileView?.call(userIdentifier);
              },
      ),
      isScrollController: true,
      backgroundColor: sheetBg,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final pillColor = _pillColor(context);
    final pillFillColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.2);
    final showAddIcon =
        IsmLiveDelegate.streamScreenConfigure.showHostProfileAddIcon &&
            !isHost;

    return Container(
        width: showAddIcon
            ? IsmLiveDimens.oneHundredFifty
            : IsmLiveDimens.hundredFourty,
        decoration: BoxDecoration(
          color: pillFillColor,
          borderRadius: BorderRadius.circular(IsmLiveDimens.hundred),
          border: Border.all(color: pillColor),
        ),
        padding: IsmLiveDimens.edgeInsets2,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IsmLiveTapHandler(
              onTap: () => _onProfileTap(context),
              child: IsmLiveImage.network(
                imageUrl,
                name: name,
                initials: initials,
                isProfileImage: true,
                height: IsmLiveDimens.forty,
                width: IsmLiveDimens.forty,
                border: Border.all(color: pillColor),
              ),
            ),
            IsmLiveDimens.boxWidth4,
            if (showAddIcon)
              Expanded(
                child: Text(
                  handle.isEmpty ? '$name' : '@$handle',
                  style: IsmLiveStyles.white12,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              SizedBox(
                width: IsmLiveDimens.seventy,
                child: Text(
                  handle.isEmpty ? '$name' : '@$handle',
                  style: IsmLiveStyles.white12,
                  maxLines: 1,
                ),
              ),
            if (showAddIcon) ...[
              IsmLiveDimens.boxWidth2,
              IsmLiveTapHandler(
                onTap: () => _onProfileTap(context),
                child: Container(
                  height: IsmLiveDimens.twenty,
                  width: IsmLiveDimens.twenty,
                  decoration: BoxDecoration(
                    color: pillColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.add,
                    size: IsmLiveDimens.sixteen,
                    color: IsmLiveColors.white,
                  ),
                ),
              ),
              IsmLiveDimens.boxWidth4,
            ],
          ],
        ),
      );
  }
}
