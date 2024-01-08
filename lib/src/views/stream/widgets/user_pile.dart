import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveUsersAvatar extends StatelessWidget {
  const IsmLiveUsersAvatar({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: IsmLiveDimens.forty,
        child: GetX<IsmLiveStreamController>(
          builder: (controller) {
            final viewerList = controller.streamViewersList;
            return Stack(
              children: List.generate(
                viewerList.length > 8 ? 8 : viewerList.length,
                (index) => Positioned(
                  left: index * 25,
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
                    child: index >= 8
                        ? const Icon(Icons.more_horiz)
                        : IsmLiveImage.network(
                            viewerList[index].imageUrl ?? '',
                            name: viewerList[index].userName,
                            isProfileImage: true,
                          ),
                  ),
                ),
              ).toList().reversed.toList(),
            );
          },
        ),
      );
}
