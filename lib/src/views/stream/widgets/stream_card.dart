import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class IsmLiveStreamCard extends StatelessWidget {
  const IsmLiveStreamCard(
    this.stream, {
    super.key,
    this.onTap,
  });

  final IsmLiveStreamModel stream;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => IsmLiveTapHandler(
        onTap: onTap,
        child: Container(
          height: IsmLiveDimens.twoHundredTwenty,
          margin: IsmLiveDimens.edgeInsets8,
          padding: IsmLiveDimens.edgeInsets4_8,
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
          child: Text(
            stream.initiatorName ?? '',
            style: IsmLiveTheme.of(context).textTheme?.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      );
}
