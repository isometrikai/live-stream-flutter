import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class IsmLiveLogoutBottomSheet extends StatelessWidget {
  const IsmLiveLogoutBottomSheet({
    super.key,
    required this.user,
  });

  final UserDetails user;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.liveTheme?.backgroundColor ??
        (isDarkMode ? const Color(0xFF121212) : Colors.white);
    final textColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);
    final subtitleColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            IsmLiveDelegate.bottomSheetBorderRadius?.topLeft.x ??
                IsmLiveDimens.thirty,
          ),
        ),
      ),
      child: Padding(
        padding: IsmLiveDimens.edgeInsets16,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IsmLiveImage.network(
              user.profileUrl,
              name: user.userName,
              isProfileImage: true,
              dimensions: IsmLiveDimens.forty,
            ),
            IsmLiveDimens.boxWidth10,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.userName,
                  style: TextStyle(color: textColor),
                ),
                Text(
                  user.userIdentifier,
                  style: TextStyle(color: subtitleColor),
                ),
              ],
            ),
            const Spacer(flex: 2),
            const IsmLiveButton.icon(
              icon: Icons.logout_rounded,
              onTap: IsmLiveApp.dispose,
            ),
          ],
        ),
      ),
    );
  }
}
