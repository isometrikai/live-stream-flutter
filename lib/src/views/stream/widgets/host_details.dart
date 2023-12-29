import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveHostDetail extends StatelessWidget {
  const IsmLiveHostDetail({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.viewerCont,
  });
  final String name;
  final String imageUrl;
  final int viewerCont;
  @override
  Widget build(BuildContext context) => IsmLiveTapHandler(
        onTap: () {
          Get.bottomSheet(
              StreamLiveSheet(
                widget: IsmLiveImage.network(
                  '',
                  isProfileImage: true,
                  name: name,
                  height: IsmLiveDimens.hundred,
                  width: IsmLiveDimens.hundred,
                ),
                title: '@$name',
              ),
              backgroundColor: IsmLiveColors.white);
        },
        child: Container(
          width: IsmLiveDimens.hundredFourty,
          height: IsmLiveDimens.forty,
          decoration: BoxDecoration(
              color: IsmLiveColors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(IsmLiveDimens.fifty),
              border: Border.all(color: IsmLiveColors.white)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IsmLiveImage.network(
                imageUrl,
                name: name,
                isProfileImage: true,
                height: IsmLiveDimens.forty,
                width: IsmLiveDimens.forty,
              ),
              IsmLiveDimens.boxWidth4,
              SizedBox(
                width: IsmLiveDimens.seventy,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@$name',
                      style: IsmLiveStyles.white12,
                      maxLines: 1,
                    ),
                    IsmLiveDimens.boxHeight2,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.person,
                          size: IsmLiveDimens.fifteen,
                          color: IsmLiveColors.white,
                        ),
                        IsmLiveDimens.boxWidth2,
                        Text(
                          '$viewerCont',
                          style: IsmLiveStyles.white12,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
