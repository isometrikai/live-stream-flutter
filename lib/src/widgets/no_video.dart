import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class NoVideoWidget extends StatelessWidget {
  const NoVideoWidget({
    super.key,
    required this.imageUrl,
    this.name = '',
    this.showConnectingState = false,
    this.connectingText,
    this.initials,
  });
  final String name;
  final String imageUrl;
  final bool showConnectingState;
  final String? connectingText;
  final String? initials;
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IsmLiveImage.network(
              IsmLiveDelegate.getUserProfileUrl?.call(imageUrl) ?? imageUrl,
              name: name,
              isProfileImage: true,
              initials: initials,
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
            ),
            if (showConnectingState) ...[
              IsmLiveDimens.boxHeight8,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        IsmLiveColors.white,
                      ),
                    ),
                  ),
                  IsmLiveDimens.boxWidth8,
                  Text(
                    connectingText ?? IsmLiveStrings.joiningLiveStream,
                    style: IsmLiveStyles.blackBold16.copyWith(
                      fontSize: 14,
                      color: IsmLiveColors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
}

class NoVideoIconWidget extends StatelessWidget {
  const NoVideoIconWidget();

  @override
  Widget build(BuildContext context) => Container(
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 0.1),
          color: Colors.black,
        ),
        width: MediaQuery.of(context).size.width / 4,
        child: const Center(
          child: Icon(
            Icons.person_add,
            color: Colors.white,
          ),
        ),
      );
}
