import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class IsmLiveHostDetail extends StatelessWidget {
  const IsmLiveHostDetail({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.isHost,
    required this.userIdentifier,
  });

  final String name;
  final String imageUrl;
  final String description;
  final String userIdentifier;
  final bool isHost;

  Color _pillColor(BuildContext context) =>
      context.liveTheme?.primaryColor ??
      (Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final pillColor = _pillColor(context);
    // Text contrast with pill border/background
    final textColor = pillColor.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;
    final pillFillColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.2);

    return IsmLiveTapHandler(
      onTap: () async {
        final hostTopProfileCallback =
            IsmLiveDelegate.hostTopProfileClickCallback;
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
      },
      child: Container(
        width: IsmLiveDimens.hundredFourty,
        decoration: BoxDecoration(
          color: pillFillColor,
          borderRadius: BorderRadius.circular(IsmLiveDimens.hundred),
          border: Border.all(color: pillColor),
        ),
        padding: IsmLiveDimens.edgeInsets2,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IsmLiveImage.network(
              imageUrl,
              name: name,
              isProfileImage: true,
              height: IsmLiveDimens.forty,
              width: IsmLiveDimens.forty,
              border: Border.all(color: pillColor),
            ),
            IsmLiveDimens.boxWidth4,
            SizedBox(
              width: IsmLiveDimens.seventy,
              child: Text(
                '@$name',
                style: IsmLiveStyles.white12,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
