import 'dart:math';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveListSheet extends StatelessWidget {
  const IsmLiveListSheet({
    super.key,
    this.title,
    required this.items,
    this.trailing,
    this.scrollController,
  });

  final String? title;
  final List<IsmLiveViewerModel> items;
  final ViewerBuilder? trailing;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(
          maxHeight: min(items.length.sheetHeight, context.height * 0.85),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: IsmLiveDimens.edgeInsets20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title ?? 'Top Viewers',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IsmLiveDimens.boxHeight16,
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var viewer = items[index];
                  return ListTile(
                    contentPadding: IsmLiveDimens.edgeInsets0,
                    leading: IsmLiveImage.network(
                      viewer.imageUrl ?? '',
                      name: viewer.userName,
                      dimensions: IsmLiveDimens.forty,
                      isProfileImage: true,
                    ),
                    title: Text(
                      '@${viewer.userName}',
                      style: context.textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      viewer.identifier,
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
