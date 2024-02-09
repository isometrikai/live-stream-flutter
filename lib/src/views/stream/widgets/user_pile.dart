import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveUsersAvatar extends StatelessWidget {
  const IsmLiveUsersAvatar({super.key});

  @override
  Widget build(BuildContext context) => Container(
        height: IsmLiveDimens.forty,
        constraints: BoxConstraints(
          maxWidth: Get.width * 0.25,
        ),
        child: GetX<IsmLiveStreamController>(
          builder: (controller) {
            final viewerList = controller.streamViewersList.reversed.toList();

            return Stack(
              alignment: Alignment.center,
              children: List.generate(
                viewerList.length > 5 ? 5 : viewerList.length,
                (index) => Positioned(
                  right: index * 20,
                  child: Container(
                    height: IsmLiveDimens.forty,
                    width: IsmLiveDimens.forty,
                    decoration: BoxDecoration(
                      color: IsmLiveColors.white,
                      borderRadius: BorderRadius.circular(IsmLiveDimens.fifty),
                      border: Border.all(
                        color: IsmLiveColors.white,
                      ),
                    ),
                    child: index == 4
                        ? const Icon(
                            Icons.more_horiz,
                          )
                        : IsmLiveImage.network(
                            viewerList[index].imageUrl ?? '',
                            name: viewerList[index].userName,
                            isProfileImage: true,
                          ),
                  ),
                ),
                growable: false,
              ).toList(),
            );
          },
        ),
      );
}
