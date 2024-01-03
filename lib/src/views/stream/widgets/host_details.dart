import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveHostDetail extends StatelessWidget {
  const IsmLiveHostDetail({
    super.key,
    required this.name,
    required this.imageUrl,
  });

  final String name;
  final String imageUrl;

  Color _color(BuildContext context) => context.liveTheme.backgroundColor ?? IsmLiveColors.white;

  @override
  Widget build(BuildContext context) => IsmLiveTapHandler(
        onTap: () {
          IsmLiveUtility.openBottomSheet(
            StreamLiveSheet(
              widget: IsmLiveImage.network(
                imageUrl,
                isProfileImage: true,
                name: name,
                height: IsmLiveDimens.hundred,
                width: IsmLiveDimens.hundred,
              ),
              title: '@$name',
            ),
          );
        },
        child: Container(
          width: IsmLiveDimens.hundredFourty,
          decoration: BoxDecoration(
            color: _color(context).withOpacity(0.3),
            borderRadius: BorderRadius.circular(IsmLiveDimens.hundred),
            border: Border.all(color: _color(context)),
          ),
          padding: IsmLiveDimens.edgeInsets2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IsmLiveImage.network(
                imageUrl,
                name: name,
                isProfileImage: true,
                height: IsmLiveDimens.forty,
                width: IsmLiveDimens.forty,
                border: Border.all(color: _color(context)),
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
                          size: IsmLiveDimens.sixteen,
                          color: IsmLiveColors.white,
                        ),
                        IsmLiveDimens.boxWidth2,
                        GetX<IsmLiveStreamController>(
                          builder: (controller) => Text(
                            controller.streamViewersList.length.toString(),
                            style: IsmLiveStyles.white12,
                          ),
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
