import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class IsmLiveLogoutBottomSheet extends StatelessWidget {
  const IsmLiveLogoutBottomSheet({
    super.key,
    required this.user,
  });

  final UserDetails user;

  @override
  Widget build(BuildContext context) => Padding(
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
                Text(user.userName),
                Text(user.userIdentifier),
              ],
            ),
            const Spacer(flex: 2),
            const IsmLiveButton.icon(
              icon: Icons.logout_rounded,
              onTap: IsmLiveApp.dispose,
            ),
          ],
        ),
      );
}
