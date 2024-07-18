import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoVideoWidget extends StatelessWidget {
  const NoVideoWidget({
    super.key,
    required this.imageUrl,
    this.name = 'U',
  }) : assert(name.length > 0, 'Length of the name should be atleast 1');
  final String name;
  final String imageUrl;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IsmLiveImage.network(
              imageUrl,
              name: name,
              isProfileImage: true,
              height: IsmLiveDimens.hundred,
              width: IsmLiveDimens.hundred,
              showError: false,
            ),
            IsmLiveDimens.boxHeight10,
            Text(
              name,
              style: IsmLiveStyles.blackBold16.copyWith(
                color: IsmLiveColors.white,
              ),
            )
          ],
        ),
      );
}

class NoVideoIconWidget extends StatelessWidget {
  const NoVideoIconWidget();

  @override
  Widget build(BuildContext context) => Container(
        height: Get.height * 0.3,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 0.1),
          color: Colors.black,
        ),
        width: Get.width / 4,
        child: const Center(
          child: Icon(
            Icons.person_add,
            color: Colors.white,
          ),
        ),
      );
}
