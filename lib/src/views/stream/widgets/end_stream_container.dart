import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveEndStreamContainer extends StatelessWidget {
  const IsmLiveEndStreamContainer({
    super.key,
    required this.title,
    required this.points,
    required this.assetConstant,
  });

  final String title;
  final String points;
  final String assetConstant;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IsmLiveImage.svg(
            assetConstant,
          ),
          Text(
            title,
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          Text(
            points,
            style: context.textTheme.titleMedium,
          ),
        ],
      );
}
