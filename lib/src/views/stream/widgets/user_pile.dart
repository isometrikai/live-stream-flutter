import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/models/stream/viewer_details_model.dart';
import 'package:flutter/material.dart';

class IsmLiveUsersAvatar extends StatelessWidget {
  const IsmLiveUsersAvatar({
    Key? key,
    required this.viewerList,
  }) : super(key: key);

  final List<IsmLiveStreamViewerDetailsModel> viewerList;

  @override
  Widget build(BuildContext context) {
    // viewerList.insert(0, null);
    return SizedBox(
      height: IsmLiveDimens.forty,
      child: Stack(
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
              child: 0 == index
                  ? const Icon(Icons.more_horiz)
                  : IsmLiveImage.network(
                      viewerList[index].userProfileImageUrl ?? '',
                      name: viewerList[index].userName ?? 'U',
                      isProfileImage: true,
                    ),
            ),
          ),
        ).toList().reversed.toList(),
      ),
    );
  }
}
