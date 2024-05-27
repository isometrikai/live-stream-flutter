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
  Widget build(BuildContext context) => Padding(
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
                    child: IsmLiveImage.svg(
                      IsmLiveAssetConstants.linking,
                    ),
                  ),
                ],
              ),
            ),
            IsmLiveDimens.boxHeight10,
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            IsmLiveDimens.boxHeight10,
            Text(
              description,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            IsmLiveDimens.boxHeight20,
            if (isInvite)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: Get.width * 0.4,
                    child: IsmLiveButton(
                      label: 'Reject',
                      onTap: () {
                        Get.back();
                        controller.invitationPk(
                          inviteId: inviteId ?? '',
                          reciverStreamId: reciverStreamId ?? '',
                          response: IsmLivePkResponce.rejected.value,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: Get.width * 0.4,
                    child: IsmLiveButton(
                      label: 'Accept',
                      onTap: () {
                        Get.back();
                        controller.invitationPk(
                          inviteId: inviteId ?? '',
                          reciverStreamId: reciverStreamId ?? '',
                          response: IsmLivePkResponce.accepted.value,
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
              ),
          ],
        ),
      );
}
