import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/models/stream/users_pile_model.dart';
import 'package:flutter/material.dart';

class StreamHeader extends StatelessWidget {
  const StreamHeader(
      {super.key,
      required this.name,
      required this.viewerCont,
      required this.imageUrl,
      this.onTabCross});
  final String name;
  final String imageUrl;
  final int viewerCont;
  final Function()? onTabCross;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          IsmLiveHostDetail(
            imageUrl: imageUrl,
            name: name,
            viewerCont: viewerCont,
          ),
          IsmLiveDimens.boxWidth16,
          Expanded(
            child: IsmLiveUsersAvatar(
              viewerList: [
                IsmLiveProfileModel(userName: 'tarr'),
                IsmLiveProfileModel(userName: 'tarr'),
                IsmLiveProfileModel(userName: 'tarr'),
                IsmLiveProfileModel(userName: 'tarr'),
                IsmLiveProfileModel(userName: 'tarr'),
                IsmLiveProfileModel(userName: 'tarr'),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              color: IsmLiveColors.white,
            ),
            onPressed: onTabCross,
          ),
        ],
      );
}
