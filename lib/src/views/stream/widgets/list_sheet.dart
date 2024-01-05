import 'dart:math';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveListSheet extends StatelessWidget {
  const IsmLiveListSheet({
    super.key,
    required this.list,
    required this.isHost,
    this.trailing,
    required this.controller,
  });

  final List<IsmLiveViewerModel> list;
  final bool isHost;
  final ViewerBuilder? trailing;
  final IsmLiveStreamController controller;
  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(
          maxHeight: min(list.length.sheetHeight, context.height * 0.85),
        ),
        child: SingleChildScrollView(
          controller: controller.viewerListController,
          padding: IsmLiveDimens.edgeInsets20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Viewers',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IsmLiveDimens.boxHeight16,
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 15,
                itemBuilder: (context, index) {
                  var viewer = list[0];
                  return ListTile(
                    contentPadding: IsmLiveDimens.edgeInsets0,
                    leading: IsmLiveImage.network(
                      viewer.userProfileImageUrl ?? '',
                      name: viewer.userName,
                      dimensions: IsmLiveDimens.forty,
                      isProfileImage: true,
                    ),
                    title: Text(
                      '@${viewer.userName}',
                      style: context.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      viewer.userIdentifier,
                      style: context.textTheme.bodySmall,
                    ),
                    trailing: trailing?.call(context, viewer),
                  );
                },
              ),
            ],
          ),
        ),
      );
}
