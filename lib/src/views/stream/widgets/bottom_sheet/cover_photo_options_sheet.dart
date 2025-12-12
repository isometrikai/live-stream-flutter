import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class IsmLiveCoverPhotoOptionsSheet extends StatelessWidget {
  const IsmLiveCoverPhotoOptionsSheet({
    super.key,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets16_0_16_20,
        child: IsmLiveScrollSheet(
          separatedWidgat: IsmLiveDimens.boxHeight24,
          title: '',
          showHeader: false,
          showCancelIcon: true,
          itemCount: 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              // Take photo option
              return IsmLiveTapHandler(
                onTap: onCameraTap,
                child: Row(
                  children: [
                    const IsmLiveImage.svg(
                      IsmLiveAssetConstants.takePhoto,
                    ),
                    IsmLiveDimens.boxWidth10,
                    Text(
                      IsmLiveStrings.takePhoto,
                      style: context.dynamicTextTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            } else {
              // Choose from gallery option
              return IsmLiveTapHandler(
                onTap: onGalleryTap,
                child: Row(
                  children: [
                    const IsmLiveImage.svg(
                      IsmLiveAssetConstants.chooseFromGallery,
                    ),
                    IsmLiveDimens.boxWidth10,
                    Text(
                      IsmLiveStrings.chooseFromGallery,
                      style: context.dynamicTextTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      );
}
