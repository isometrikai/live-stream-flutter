import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class IsmLiveLogoutBottomSheet extends StatelessWidget {
  const IsmLiveLogoutBottomSheet({
    super.key,
    required this.user,
  });

  final UserDetails user;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: IsmLiveTheme.of(context).cardBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(IsmLiveDimens.sixteen),
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
              const Flexible(
                flex: 3,
                child: IsmLiveButton(
                  onTap: IsmLiveApp.logout,
                  label: 'LogOut',
                ),
              ),
            ],
          ),
        ),
      );
}
