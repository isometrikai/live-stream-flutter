import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/models/stream/viewer_details_model.dart';
import 'package:flutter/material.dart';

class IsmLiveListSheet extends StatelessWidget {
  const IsmLiveListSheet({
    super.key,
    required this.list,
  });
  final List<IsmLiveStreamViewerDetailsModel> list;
  @override
  Widget build(BuildContext context) => list.isEmpty
      ? const Center(
          child: Text('No Viewers Found!'),
        )
      : ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) => Padding(
            padding: IsmLiveDimens.edgeInsets12,
            child: Row(
              children: [
                IsmLiveImage.network(
                  list[index].userProfileImageUrl ?? '',
                  height: IsmLiveDimens.fifty,
                  width: IsmLiveDimens.fifty,
                  name: list[index].userName,
                  isProfileImage: true,
                ),
                IsmLiveDimens.boxWidth20,
                Text(list[index].userName),
              ],
            ),
          ),
          itemCount: list.length,
        );
}
