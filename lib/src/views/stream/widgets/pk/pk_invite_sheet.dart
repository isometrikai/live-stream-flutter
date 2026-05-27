// ignore_for_file: must_be_immutable

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLivePkInviteSheet extends StatelessWidget {
  IsmLivePkInviteSheet({
    super.key,
    required this.images,
    required this.userName,
    required this.reciverName,
    required this.title,
    required this.description,
    this.onTap,
    this.isInvite = false,
    this.inviteId,
    this.reciverStreamId,
  });
  final List<String> images;
  final String userName;
  final String reciverName;
  final VoidCallback? onTap;
  final String title;
  final String description;
  final String? inviteId;
  final String? reciverStreamId;

  final bool isInvite;
  static const String updateId = 'pk-invite-sheet';
  var controller = Get.find<IsmLivePkController>();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.liveTheme?.backgroundColor ??
        (isDarkMode ? const Color(0xFF121212) : Colors.white);
    final textColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);
    final subtitleColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey);
    final iconColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);
    final dividerColor = context.liveTheme?.borderColor ??
        (isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade300);

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
        padding: IsmLiveDimens.edgeInsets16.copyWith(
          top: IsmLiveDimens.thirtyTwo,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: IsmLiveDimens.twoHundred,
              height: IsmLiveDimens.hundred,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Row(
                    children: [
                      IsmLiveImage.network(
                        images.first,
                        name: userName,
                        height: IsmLiveDimens.hundred,
                        width: IsmLiveDimens.hundred,
                        isProfileImage: true,
                      ),
                      IsmLiveImage.network(
                        images.last,
                        name: reciverName,
                        height: IsmLiveDimens.hundred,
                        width: IsmLiveDimens.hundred,
                        isProfileImage: true,
                      ),
                    ],
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: IsmLiveImage.svg(IsmLiveAssetConstants.linking),
                  ),
                ],
              ),
            ),
            IsmLiveDimens.boxHeight10,
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            IsmLiveDimens.boxHeight10,
            Text(
              description,
              style: context.textTheme.bodyMedium?.copyWith(
                color: subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
            IsmLiveDimens.boxHeight20,
            if (isInvite)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: IsmLiveButton(
                      label: IsmLiveStrings.reject,
                      onTap: () {
                        IsmLiveRoute.pop();
                        controller.invitationPk(
                          inviteId: inviteId ?? '',
                          reciverStreamId: reciverStreamId ?? '',
                          response: IsmLivePkResponceToSend.rejected.value,
                          context: context,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: IsmLiveButton(
                      label: IsmLiveStrings.accept,
                      onTap: () {
                        IsmLiveRoute.pop();
                        controller.invitationPk(
                          inviteId: inviteId ?? '',
                          reciverStreamId: reciverStreamId ?? '',
                          response: IsmLivePkResponceToSend.accepted.value,
                          context: context,
                        );
                      },
                    ),
                  )
                ],
              )
            else
              LinearProgressIndicator(
                minHeight: IsmLiveDimens.ten,
                borderRadius: BorderRadius.circular(IsmLiveDimens.eight),
                color: iconColor,
                backgroundColor: dividerColor,
              ),
          ],
        ),
      ),
    );
  }
}
