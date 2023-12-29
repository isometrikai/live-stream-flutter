import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/models/stream/viewer_details_model.dart';
import 'package:flutter/material.dart';

class StreamHeader extends StatelessWidget {
  const StreamHeader({
    super.key,
    required this.name,
    required this.viewerCont,
    required this.imageUrl,
    this.onTabCross,
    required this.viewerList,
    this.onTabViewers,
  });
  final String name;
  final String imageUrl;
  final int viewerCont;
  final List<IsmLiveStreamViewerDetailsModel> viewerList;
  final Function()? onTabCross;
  final Function()? onTabViewers;
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
            child: IsmLiveTapHandler(
              onTap: onTabViewers,
              child: IsmLiveUsersAvatar(
                viewerList: viewerList,
              ),
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
