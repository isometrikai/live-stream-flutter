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
  Widget build(BuildContext context) => ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) => ListTile(
          leading: IsmLiveImage.network(
            list[index].userProfileImageUrl ?? '',
            name: list[index].userName,
          ),
          title: Text(list[index].userName),
        ),
        itemCount: list.length,
      );
}
