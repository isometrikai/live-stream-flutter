import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveStreamCard extends StatelessWidget {
  const IsmLiveStreamCard(
    this.stream, {
    super.key,
    this.onTap,
    this.isCreatedByMe = false,
  });

  final IsmLiveStreamModel stream;
  final VoidCallback? onTap;
  final bool isCreatedByMe;

  @override
  Widget build(BuildContext context) => IsmLiveTapHandler(
        onTap: onTap,
        child: Container(
          height: IsmLiveDimens.twoHundredTwenty,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(IsmLiveDimens.sixteen),
            color: Colors.black,
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                stream.streamImage ?? '',
              ),
              fit: BoxFit.cover,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.bottomCenter,
          child: Stack(
            children: [
              const SizedBox.expand(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black26,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: IsmLiveDimens.edgeInsets8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isCreatedByMe)
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: IsmLiveDimens.edgeInsets8_4,
                          decoration: BoxDecoration(
                            color: IsmLiveTheme.of(context).primaryColor,
                            borderRadius:
                                BorderRadius.circular(IsmLiveDimens.eight),
                          ),
                          child: Text(
                            'Continue',
                            style: context.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    Row(
                      children: [
                        IsmLiveImage.network(
                          stream.initiatorImage ?? '',
                          name: stream.initiatorName ?? 'U',
                          dimensions: IsmLiveDimens.thirtyTwo,
                          isProfileImage: true,
                        ),
                        IsmLiveDimens.boxWidth10,
                        Text(
                          stream.initiatorName ?? '',
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
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
