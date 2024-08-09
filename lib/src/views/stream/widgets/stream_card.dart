import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class IsmLiveStreamCard extends StatelessWidget {
  const IsmLiveStreamCard(
    this.stream, {
    super.key,
    this.onTap,
    this.isCreatedByMe = false,
  });

  final IsmLiveStreamDataModel stream;
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isCreatedByMe)
                      Expanded(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            padding: IsmLiveDimens.edgeInsets8_4,
                            decoration: BoxDecoration(
                              color: context.liveTheme?.primaryColor ??
                                  IsmLiveColors.primary,
                              borderRadius:
                                  BorderRadius.circular(IsmLiveDimens.eight),
                            ),
                            child: Text(
                              stream.isScheduledStream ?? false
                                  ? '${DateFormat('yyyy MMMM dd, h:mm').format(stream.scheduleStartTime ?? DateTime.now())}'
                                  : 'Continue',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (stream.isPaid ?? false)
                      IsmLiveCoins(
                        coins: stream.isBuy ?? false
                            ? 'Paid'
                            : stream.amount.toString(),
                      ),
                    Row(
                      children: [
                        IsmLiveImage.network(
                          stream.userDetails?.userProfile ?? '',
                          name: stream.userDetails?.userName ?? 'U',
                          dimensions: IsmLiveDimens.thirtyTwo,
                          isProfileImage: true,
                        ),
                        IsmLiveDimens.boxWidth10,
                        Flexible(
                          child: Text(
                            stream.userDetails?.userName ?? 'U',
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      stream.streamDescription ?? '',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
