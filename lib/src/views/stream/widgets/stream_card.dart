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
          margin: IsmLiveDimens.edgeInsets8,
          padding: IsmLiveDimens.edgeInsets8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(IsmLiveDimens.sixteen),
            color: Colors.black,
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                stream.streamImage ?? '',
              ),
              fit: BoxFit.cover,
              opacity: 0.8,
            ),
          ),
          alignment: Alignment.bottomCenter,
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
                      borderRadius: BorderRadius.circular(IsmLiveDimens.eight),
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
              Text(
                stream.initiatorName ?? '',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
}
