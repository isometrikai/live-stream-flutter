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
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textIconColor = isDarkMode ? Colors.white : Colors.black;
    
    return Container(
      decoration: BoxDecoration(
        color: context.liveTheme?.backgroundColor ??
            (isDarkMode ? const Color(0xFF121212) : Colors.white),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            IsmLiveDelegate.bottomSheetBorderRadius?.topLeft.x ??
                IsmLiveDimens.thirty,
          ),
        ),
      ),
      child: Padding(
        padding: IsmLiveDimens.edgeInsets16_0_16_20.copyWith(bottom: 0),
        child: IsmLiveScrollSheet(
          separatedWidgat: IsmLiveDimens.boxHeight24,
          title: '',
          showHeader: false,
          showCancelIcon: true,
          cancelIconColor: textIconColor,
          itemCount: 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              // Take photo option
              return IsmLiveTapHandler(
                onTap: onCameraTap,
                child: Row(
                  children: [
                    IsmLiveImage.svg(
                      IsmLiveAssetConstants.takePhoto,
                      color: textIconColor,
                    ),
                    IsmLiveDimens.boxWidth10,
                    Text(
                      IsmLiveStrings.takePhoto,
                      style: context.dynamicTextTheme.bodyMedium?.copyWith(
                        color: textIconColor,
                      ),
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
                    IsmLiveImage.svg(
                      IsmLiveAssetConstants.chooseFromGallery,
                      color: textIconColor,
                    ),
                    IsmLiveDimens.boxWidth10,
                    Text(
                      IsmLiveStrings.chooseFromGallery,
                      style: context.dynamicTextTheme.bodyMedium?.copyWith(
                        color: textIconColor,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
