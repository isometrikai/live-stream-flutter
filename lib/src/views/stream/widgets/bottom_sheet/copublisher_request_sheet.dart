import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveCopublishingViewerSheet extends StatelessWidget {
  const IsmLiveCopublishingViewerSheet({
    super.key,
    required this.images,
    required this.label,
    required this.title,
    required this.description,
    this.imageNames,
    this.imageInitials,
    this.onTap,
  });
  final List<String> images;
  final List<String>? imageNames;
  final List<String?>? imageInitials;
  final String label;
  final VoidCallback? onTap;
  final String title;
  final String description;

  String _fallbackNameForIndex(int index) {
    if (imageNames != null && index >= 0 && index < imageNames!.length) {
      final value = imageNames![index].trim();
      if (value.isNotEmpty) return value;
    }
    // Backwards compatible behavior (previously we used label/title).
    return images.length == 1 ? label : title;
  }

  String? _fallbackInitialsForIndex(int index, String name) {
    if (imageInitials != null &&
        index >= 0 &&
        index < imageInitials!.length) {
      final value = imageInitials![index]?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return IsmLiveInitials.extract(name);
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets16.copyWith(
          top: IsmLiveDimens.thirtyTwo,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (images.isEmpty)
              IsmLiveDimens.box0
            else if (images.length == 1)
              Builder(
                builder: (context) {
                  final name = _fallbackNameForIndex(0);
                  return IsmLiveImage.network(
                    images.first,
                    name: name,
                    initials: _fallbackInitialsForIndex(0, name),
                    height: IsmLiveDimens.hundred,
                    width: IsmLiveDimens.hundred,
                    isProfileImage: true,
                  );
                },
              )
            else
              SizedBox(
                width: IsmLiveDimens.twoHundred,
                height: IsmLiveDimens.hundred,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ...images.indexed.map(
                      (e) {
                        final right = e.$1 *
                            (IsmLiveDimens.twoHundred / (images.length + 1));
                        final name = _fallbackNameForIndex(e.$1);
                        return Positioned(
                          right: e.$1 == 0 ? 0 : right,
                          child: IsmLiveImage.network(
                            e.$2,
                            name: name,
                            initials: _fallbackInitialsForIndex(e.$1, name),
                            height: IsmLiveDimens.hundred,
                            width: IsmLiveDimens.hundred,
                            isProfileImage: true,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            IsmLiveDimens.boxHeight10,
            Text(
              title,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            IsmLiveDimens.boxHeight10,
            Text(
              description,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            IsmLiveDimens.boxHeight20,
            if (onTap == null)
              Padding(
                padding: IsmLiveDimens.edgeInsets16,
                child: Text(
                  label,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.liveTheme?.primaryColor ??
                        IsmLiveColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              IsmLiveButton(
                label: label,
                onTap: () {
                  IsmLiveRoute.pop();
                  onTap?.call();
                },
              ),
            IsmLiveDimens.boxHeight10,
          ],
        ),
      );
}
